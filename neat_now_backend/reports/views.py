from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import models as django_models
from django.utils import timezone
from datetime import timedelta
from .models import Report, ImageStorageLog
from .serializers import (
    ReportCreateSerializer,
    ReportListSerializer,
    ReportDetailSerializer,
    ReportUpdateSerializer
)
from accounts.models import Account
from notifications.models import Notification


def check_and_create_overdue_notifications():
    """
    Check for overdue reports (> 12 hours) and create notifications for workers.
    This function is called when reports are fetched to ensure overdue notifications are created.
    
    Logic:
    - Check Pending and In Progress reports assigned to workers
    - Calculate hours since accepted_at (for Pending) or updated_at (for In Progress)
    - If > 12 hours, create notification with task number
    - Task number is based on acceptance order (same as frontend)
    """
    from django.db.models import Q, F
    
    # Get all active reports assigned to workers (Pending or In Progress)
    active_reports = Report.objects.filter(
        worker__isnull=False,
        status__in=['Pending', 'In Progress']
    ).exclude(
        status__in=['Resolved', 'Rejected']
    ).select_related('worker')
    
    if not active_reports.exists():
        return
    
    # Calculate task numbers for all accepted reports (same logic as frontend)
    # Get all reports assigned to workers (regardless of current status)
    # Include: Pending, In Progress, Resolved (but NOT Rejected)
    # Task number is based on WHEN worker accepted (accepted_at), not current status
    all_accepted_reports = Report.objects.filter(
        worker__isnull=False
    ).exclude(
        status='Rejected'
    ).filter(
        Q(accepted_at__isnull=False) | Q(updated_at__isnull=False)
    )
    
    # Sort by accepted_at (when worker accepted) - earliest first
    # This ensures Task #1, #2, #3, etc. based on acceptance order
    all_accepted_reports_list = list(all_accepted_reports)
    all_accepted_reports_list.sort(key=lambda r: (
        r.accepted_at if r.accepted_at else r.updated_at if r.updated_at else r.submitted_at,
        r.report_id
    ))
    
    # Create a mapping of report_id to task_number
    # Task number is based on acceptance order (earliest accepted = Task #1)
    task_number_map = {}
    task_number = 1
    for report in all_accepted_reports_list:
        task_number_map[report.report_id] = task_number
        task_number += 1
    
    now = timezone.now()
    overdue_threshold_hours = 12
    notifications_created = 0
    
    for report in active_reports:
        # Calculate hours since start
        start_time = None
        if report.status == 'In Progress':
            # For In Progress: Use updated_at (when status changed to In Progress)
            start_time = report.updated_at or report.accepted_at or report.submitted_at
        else:  # Pending
            # For Pending: Use accepted_at (when worker accepted) or submitted_at
            start_time = report.accepted_at or report.submitted_at
        
        if not start_time:
            continue
        
        hours_since_start = (now - start_time).total_seconds() / 3600
        
        # Check if overdue (> 12 hours)
        if hours_since_start >= overdue_threshold_hours:
            # Get task number
            task_no = task_number_map.get(report.report_id, 0)
            
            # Check if notification already exists for this overdue report
            existing_notification = Notification.objects.filter(
                recipient_type='Worker',
                recipient_id=report.worker.account_id,
                report=report,
                message__icontains='OVERDUE ALERT'
            ).exists()
            
            if not existing_notification:
                # Create notification with alert type indicator in message
                # Frontend will detect "overdue" keyword and set type to overdueAlert
                message = f'OVERDUE ALERT: Your task no. {task_no} has been overdue for more than 12 hours. Please resolve it.'
                Notification.objects.create(
                    recipient_type='Worker',
                    recipient_id=report.worker.account_id,
                    message=message,
                    report=report,
                    is_read=False
                )
                notifications_created += 1
    
    if notifications_created > 0:
        print(f'✅ Created {notifications_created} overdue notifications')


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_report_view(request):
    """
    Create new waste report
    POST /api/reports/create/
    
    Body (multipart/form-data):
    {
        "image_before": <file>,
        "source": "camera" | "gallery",
        "latitude": <decimal> (required if source=camera),
        "longitude": <decimal> (required if source=camera)
    }
    
    Rules:
    - If source="camera": GPS coordinates are required (auto-attached)
    - If source="gallery": GPS coordinates are optional (can be set manually via map)
    """
    serializer = ReportCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        report = serializer.save()
        
        # Create notification for all workers about new report
        # All workers receive notification with Accept/Decline options
        workers = Account.objects.filter(role='Worker')
        waste_type_text = f' ({report.waste_type})' if report.waste_type else ''
        location_text = f'Location: {report.latitude}, {report.longitude}' if report.has_gps_coordinates else 'Location not specified'
        
        for worker in workers:
            Notification.objects.create(
                recipient_type='Worker',
                recipient_id=worker.account_id,
                message=f'New Task Assignment: Waste report #{report.report_id}{waste_type_text} submitted. {location_text}. Please accept or decline.',
                report=report
            )
        
        return Response(
            {
                'message': 'Report submitted successfully.',
                'report_id': report.report_id,
                'status': report.status,
                'ai_result': report.ai_result,
                'has_gps': report.has_gps_coordinates,
            },
            status=status.HTTP_201_CREATED
        )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ReportListView(generics.ListAPIView):
    """
    List reports for authenticated user
    GET /api/reports/
    
    - Citizens see only their own reports
    - Workers see assigned reports
    - Admins see all reports
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ReportListSerializer
    
    def get_queryset(self):
        user = self.request.user
        
        # Check and create overdue notifications when reports are fetched
        # This ensures workers get notified about overdue tasks
        if user.role == 'Worker':
            check_and_create_overdue_notifications()
        
        # Citizens see only their own reports
        if user.role == 'Citizen':
            return Report.objects.filter(citizen=user).select_related('citizen', 'worker')
        
        # Workers see ONLY reports they have accepted (assigned to them)
        # Pending reports are shown in notifications only (for accepting)
        # Tasks tab shows only accepted reports (Assigned, In Progress, Resolved)
        elif user.role == 'Worker':
            # Only show reports assigned to this worker (accepted reports)
            # Exclude Rejected reports even if worker was assigned
            return Report.objects.filter(
                worker=user
            ).exclude(
                status='Rejected'
            ).select_related('citizen', 'worker').order_by('-submitted_at')
        
        # Admins see all reports (if admin role exists)
        else:
            return Report.objects.all().select_related('citizen', 'worker')
    
    def get_serializer_context(self):
        """Add request to serializer context for building absolute URLs"""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context


class ReportDetailView(generics.RetrieveAPIView):
    """
    Get report details
    GET /api/reports/<report_id>/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ReportDetailSerializer
    lookup_field = 'report_id'
    
    def get_queryset(self):
        user = self.request.user
        
        # Citizens see only their own reports
        if user.role == 'Citizen':
            return Report.objects.filter(citizen=user)
        
        # Workers see assigned reports
        elif user.role == 'Worker':
            return Report.objects.filter(worker=user)
        
        # Admins see all reports
        else:
            return Report.objects.all()


class ReportUpdateView(generics.UpdateAPIView):
    """
    Update report (for workers/admin)
    PATCH /api/reports/<report_id>/update/
    
    Body:
    {
        "status": "Assigned" | "Resolved" | "Rejected",
        "ai_result": "Waste" | "No Waste",
        "waste_type": "<any type detected by AI>",  # AI will detect and set this
        "ai_confidence": 0.85,
        "image_after": <file>,
    }
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ReportUpdateSerializer
    lookup_field = 'report_id'
    
    def get_queryset(self):
        user = self.request.user
        
        # Only workers and admins can update reports
        if user.role == 'Worker':
            return Report.objects.filter(worker=user)
        elif user.role == 'Citizen':
            # Citizens cannot update reports
            return Report.objects.none()
        else:
            # Admins can update all reports
            return Report.objects.all()
    
    def get_serializer_context(self):
        """Add request to serializer context for building absolute URLs"""
        context = super().get_serializer_context()
        context['request'] = self.request
        return context
    
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', True)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        
        if serializer.is_valid():
            self.perform_update(serializer)
            return Response(
                {
                    'message': 'Report updated successfully.',
                    'report_id': instance.report_id,
                    'status': instance.status,
                },
                status=status.HTTP_200_OK
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def accept_report_view(request, report_id):
    """
    Worker accepts a pending report
    POST /api/reports/<report_id>/accept/
    
    - Only workers can accept reports
    - Report must be in 'Pending' status
    - Report must be within 60 minutes of submission (timeout check)
    - Worker is assigned to the report
    - Status remains 'Pending' (worker side shows as "Pending", citizen side shows as "Assigned")
    - Timer starts from accepted_at timestamp
    - Citizen gets notification that their report was accepted
    """
    from django.utils import timezone
    from datetime import timedelta
    
    try:
        report = Report.objects.get(report_id=report_id, status='Pending', worker__isnull=True)
    except Report.DoesNotExist:
        # Check if report exists but already assigned
        try:
            existing_report = Report.objects.get(report_id=report_id)
            if existing_report.worker is not None:
                return Response(
                    {'error': 'This report has already been accepted by another worker.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            if existing_report.status != 'Pending':
                return Response(
                    {'error': f'Report is in {existing_report.status} status and cannot be accepted.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        except Report.DoesNotExist:
            return Response(
                {'error': 'Report not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        return Response(
            {'error': 'Report not found or already assigned.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Only workers can accept
    if request.user.role != 'Worker':
        return Response(
            {'error': 'Only workers can accept reports.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Check if 60 minutes have passed since report submission
    time_since_submission = timezone.now() - report.submitted_at
    timeout_minutes = 60
    
    if time_since_submission > timedelta(minutes=timeout_minutes):
        # Auto-reject if timeout exceeded
        report.status = 'Rejected'
        report.save()
        
        # Notify citizen about timeout
        Notification.objects.create(
            recipient_type='Citizen',
            recipient_id=report.citizen.account_id,
            message=f'Your report #{report.report_id} was not accepted within {timeout_minutes} minutes and has been automatically rejected. Please submit a new report.',
            report=report
        )
        
        return Response(
            {
                'error': f'Report acceptance timeout. Reports must be accepted within {timeout_minutes} minutes of submission.',
                'time_elapsed_minutes': int(time_since_submission.total_seconds() / 60),
                'timeout_minutes': timeout_minutes,
            },
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Assign worker to report and keep status as 'Pending'
    # Worker side: Shows as "Pending" (timer starts from accepted_at)
    # Citizen side: Shows as "Assigned" (based on worker field being set)
    report.worker = request.user
    report.status = 'Pending'  # Keep as Pending - worker accepted but not started yet
    # Set accepted_at timestamp when worker accepts (for consistent task numbering)
    # This timestamp will NOT change when status changes to 'In Progress' or 'Resolved'
    if report.accepted_at is None:
        report.accepted_at = timezone.now()
    report.save()
    
    # DELETE all previous "New Task" notifications for this report and this worker
    # (since the worker has now accepted it, we don't need the original assignment notification)
    Notification.objects.filter(
        recipient_type='Worker',
        recipient_id=request.user.account_id,
        report=report,
        message__icontains='New Task Assignment'  # Only delete the original assignment notification
    ).delete()
    
    # Create notification for worker showing they accepted (for Assignment tab)
    # This will show "Accepted" status in Assignment notifications
    # Mark it as read by default since worker just accepted it (they know they accepted)
    worker_name = request.user.name
    Notification.objects.create(
        recipient_type='Worker',
        recipient_id=request.user.account_id,
        message=f'You accepted report #{report.report_id}. Status: Accepted. Please proceed with the task.',
        report=report,
        is_read=True  # Mark as read since worker just accepted it
    )
    
    # Create notification for citizen that their report was accepted
    Notification.objects.create(
        recipient_type='Citizen',
        recipient_id=report.citizen.account_id,
        message=f'Your report #{report.report_id} has been accepted by {worker_name}. The worker will handle your request soon.',
        report=report
    )
    
    return Response(
        {
            'message': 'Report accepted successfully.',
            'report_id': report.report_id,
            'status': report.status,  # 'Pending' - worker side shows as "Pending", citizen side shows as "Assigned"
            'status_display': 'Pending',  # Frontend display text for worker side
            'button_state': 'accepted',  # For frontend button state
            'show_accepted_button': True,  # Show Accepted button (disabled)
            'worker_id': request.user.account_id,
            'worker_name': request.user.name,
        },
        status=status.HTTP_200_OK
    )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def reject_report_view(request, report_id):
    """
    Worker rejects a pending report
    POST /api/reports/<report_id>/reject/
    
    - Only workers can reject reports
    - Report must be in 'Pending' status
    - Report status changes to 'Rejected' (shows as "Declined" in frontend)
    - Report stays in "All" tab (not assigned to worker)
    - Citizen gets notification
    """
    try:
        report = Report.objects.get(report_id=report_id, status='Pending', worker__isnull=True)
    except Report.DoesNotExist:
        # Check if report exists but already assigned
        try:
            existing_report = Report.objects.get(report_id=report_id)
            if existing_report.worker is not None:
                return Response(
                    {'error': 'This report has already been accepted by another worker.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            if existing_report.status != 'Pending':
                return Response(
                    {'error': f'Report is in {existing_report.status} status and cannot be rejected.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        except Report.DoesNotExist:
            return Response(
                {'error': 'Report not found.'},
                status=status.HTTP_404_NOT_FOUND
            )
        return Response(
            {'error': 'Report not found or already assigned.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Only workers can reject
    if request.user.role != 'Worker':
        return Response(
            {'error': 'Only workers can reject reports.'},
            status=status.HTTP_403_FORBIDDEN
        )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def resolve_report_view(request, report_id):
    """
    Worker resolves a report (completes the task)
    POST /api/reports/<report_id>/resolve/
    
    Accepts multipart/form-data with:
    - verification_image: Image file (required)
    - status: "Resolved" (optional, defaults to Resolved)
    - resolved_at: ISO datetime string (optional, defaults to now)
    - resolution_latitude: float (optional)
    - resolution_longitude: float (optional)
    - resolution_address: string (optional)
    
    - Only workers can resolve reports
    - Report must be assigned to the worker (status: Assigned or In Progress)
    - Status changes to 'Resolved'
    - Image is saved as image_after
    - Citizen gets notification that their report was resolved
    """
    from django.utils import timezone
    from notifications.models import Notification
    
    try:
        # Get report - must be assigned to the current worker
        report = Report.objects.get(
            report_id=report_id,
            worker=request.user
        )
    except Report.DoesNotExist:
        return Response(
            {'error': 'Report not found or not assigned to you.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Only workers can resolve
    if request.user.role != 'Worker':
        return Response(
            {'error': 'Only workers can resolve reports.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    # Check if report is in a valid state to be resolved
    if report.status not in ['Pending', 'In Progress']:
        return Response(
            {'error': f'Report is in {report.status} status and cannot be resolved. Only Pending or In Progress reports can be resolved.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Get verification image (required)
    verification_image = request.FILES.get('verification_image')
    if not verification_image:
        return Response(
            {'error': 'verification_image is required.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Update report
    report.image_after = verification_image
    report.status = 'Resolved'
    
    # Set resolved_at timestamp
    resolved_at_str = request.data.get('resolved_at')
    if resolved_at_str:
        try:
            from django.utils.dateparse import parse_datetime
            resolved_at = parse_datetime(resolved_at_str)
            if resolved_at:
                report.resolved_at = resolved_at
            else:
                report.resolved_at = timezone.now()
        except Exception:
            report.resolved_at = timezone.now()
    else:
        report.resolved_at = timezone.now()
    
    # Optional: Save resolution location (if provided)
    resolution_lat = request.data.get('resolution_latitude')
    resolution_lng = request.data.get('resolution_longitude')
    if resolution_lat and resolution_lng:
        try:
            lat = float(resolution_lat)
            lng = float(resolution_lng)
            # Note: We're not overwriting the original report location
            # These are just stored in the request data for reference
            # If you want to store them separately, add fields to the Report model
        except (ValueError, TypeError):
            pass  # Ignore invalid coordinates
    
    report.save()
    
    # Award 5 points to worker for completing the report
    from gamification.models import WorkerMonthlyStats
    try:
        WorkerMonthlyStats.award_points_for_resolved_report(request.user, report)
    except Exception as e:
        # Log error but don't fail the request
        import logging
        logger = logging.getLogger(__name__)
        logger.warning(f'Could not award points to worker {request.user.account_id} for report {report.report_id}: {e}')
    
    # Notify citizen that their report was resolved
    worker_name = request.user.name
    Notification.objects.create(
        recipient_type='Citizen',
        recipient_id=report.citizen.account_id,
        message=f'Your report #{report.report_id} has been resolved by {worker_name}. Please rate the cleanup quality.',
        report=report
    )
    
    # Return success response
    return Response(
        {
            'message': 'Report resolved successfully.',
            'report_id': report.report_id,
            'status': report.status,
            'resolved_at': report.resolved_at.isoformat() if report.resolved_at else None,
        },
        status=status.HTTP_200_OK
    )
    
    # Reject report - status becomes 'Rejected'
    # Frontend will display this as "Rejected" or "Declined" in the All tab
    # Worker is NOT assigned (worker remains null), so it stays in "All" tab only (NOT in Assignment tab)
    report.status = 'Rejected'
    # IMPORTANT: Ensure worker is NOT assigned (null) so it doesn't appear in Assignment tab
    report.worker = None
    report.save()
    
    # DELETE all previous "New Task" notifications for this report and this worker
    # (since the worker has now declined it, we don't need the original assignment notification)
    Notification.objects.filter(
        recipient_type='Worker',
        recipient_id=request.user.account_id,
        report=report,
        message__icontains='New Task Assignment'  # Only delete the original assignment notification
    ).delete()
    
    # Create notification for worker showing they declined (for All tab)
    # This will show "Declined" status in All notifications
    # Mark it as read by default since worker just declined it (they know they declined)
    worker_name = request.user.name
    Notification.objects.create(
        recipient_type='Worker',
        recipient_id=request.user.account_id,
        message=f'You declined report #{report.report_id}. Status: Declined.',
        report=report,
        is_read=True  # Mark as read since worker just declined it
    )
    
    # Create notification for citizen that their report was rejected
    Notification.objects.create(
        recipient_type='Citizen',
        recipient_id=report.citizen.account_id,
        message=f'Your report #{report.report_id} has been declined by {worker_name}.',
        report=report
    )
    
    return Response(
        {
            'message': 'Report rejected successfully.',
            'report_id': report.report_id,
            'status': report.status,  # 'Rejected' - frontend will show as "Rejected" or "Declined"
            'status_display': 'Rejected',  # Frontend display text
            'button_state': 'rejected',  # For frontend button state
            'show_rejected_button': True,  # Show Rejected button (disabled)
        },
        status=status.HTTP_200_OK
    )
