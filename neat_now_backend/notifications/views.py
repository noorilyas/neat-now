from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Notification


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def list_notifications_view(request):
    """
    Get all notifications for the authenticated user
    GET /api/notifications/
    
    Returns:
    {
        "notifications": [
            {
                "notification_id": 1,
                "message": "New waste report #123 submitted.",
                "is_read": false,
                "created_at": "2025-12-25T10:30:00Z",
                "report_id": 123,
                "notification_type": "assignment",  # "assignment", "feedback", "general"
                "report": {
                    "report_id": 123,
                    "status": "Assigned",  # "Pending", "Assigned", "Rejected", etc.
                    "status_display": "Accepted",  # Frontend display text
                    "can_accept": true,
                    "can_decline": true,
                    ...
                }
            },
            ...
        ],
        "unread_count": 5,
        "total_count": 10
    }
    """
    user = request.user
    
    # Get notifications for this user based on their role
    notifications = Notification.objects.filter(
        recipient_type=user.role,
        recipient_id=user.account_id
    ).order_by('-created_at')
    
    # Count unread notifications
    unread_count = notifications.filter(is_read=False).count()
    total_count = notifications.count()
    
    # Serialize notifications
    notifications_data = []
    for notification in notifications:
        report_data = None
        notification_type = 'general'  # Default type
        
        if notification.report:
            # Include report submission time for timer calculation and action buttons
            from django.utils import timezone
            from datetime import timedelta
            
            report = notification.report
            # IMPORTANT: Refresh report from database to get latest status and worker assignment
            # This ensures existing notifications show correct status even if report was updated
            report.refresh_from_db()
            
            time_since_submission = timezone.now() - report.submitted_at
            timeout_minutes = 60
            
            # Determine notification type based on report status and message content
            # Check if message contains "overdue" or "OVERDUE ALERT" to identify overdue notifications
            if 'overdue' in notification.message.lower() or 'overdue alert' in notification.message.lower():
                notification_type = 'urgent'  # Overdue alerts should show in Alert tab
            elif 'feedback' in notification.message.lower() or 'rating' in notification.message.lower():
                notification_type = 'feedback'  # Feedback notifications
            elif report.status == 'Pending' and report.worker is None:
                notification_type = 'assignment'  # New assignment (can accept/decline)
            elif report.status == 'Assigned':
                notification_type = 'assignment'  # Accepted assignment (shows "Accepted")
            elif report.status == 'Rejected':
                notification_type = 'assignment'  # Rejected assignment (shows "Rejected")
            elif report.status in ['In Progress', 'Resolved']:
                notification_type = 'assignment'  # Assignment updates
            
            # Check if can accept/decline (only for pending reports)
            can_accept = (
                report.status == 'Pending' and 
                report.worker is None and
                time_since_submission <= timedelta(minutes=timeout_minutes)
            )
            
            # Determine status display text for frontend
            # IMPORTANT: Check if this worker accepted the report
            is_worker_assigned = False
            if report.worker is not None:
                # Check if this worker is assigned to the report
                # Use account_id comparison for accuracy
                try:
                    is_worker_assigned = (report.worker.account_id == user.account_id)
                except AttributeError:
                    # Fallback: check by ID if account_id not available
                    is_worker_assigned = (str(report.worker) == str(user.account_id))
            
            status_display = report.status
            if report.status == 'Assigned':
                if is_worker_assigned:
                    status_display = 'Accepted'  # This worker accepted it - show "Accepted"
                else:
                    status_display = 'Assigned'  # Another worker accepted it
            elif report.status == 'Rejected':
                status_display = 'Rejected'  # Frontend shows "Rejected" for Rejected status
            
            # Determine button state for frontend
            # "pending" = show Accept/Decline buttons (active)
            # "accepted" = show Accepted button (read-only/disabled style)
            # "rejected" = show Rejected button (read-only/disabled style)
            button_state = 'pending'
            if report.status == 'Assigned' and is_worker_assigned:
                button_state = 'accepted'  # Show "Accepted" button (this worker accepted)
            elif report.status == 'Rejected':
                button_state = 'rejected'  # Show "Rejected" button
            
            # Button visibility flags for frontend
            show_accept_button = can_accept  # Show active Accept button (for pending)
            show_decline_button = can_accept  # Show active Decline button (for pending)
            show_accepted_button = (report.status == 'Assigned' and is_worker_assigned)  # Show Accepted button (read-only) - only if this worker accepted
            show_rejected_button = (report.status == 'Rejected')  # Show Rejected button (read-only)
            
            report_data = {
                'report_id': report.report_id,
                'submitted_at': report.submitted_at.isoformat(),
                'status': report.status,  # Backend status: "Pending", "Assigned", "In Progress", "Resolved", "Rejected", etc.
                'status_display': status_display,  # Frontend display: "Accepted", "Rejected", etc.
                'can_accept': can_accept,  # For Accept/Decline buttons (only for pending)
                'can_decline': can_accept,  # Same condition for decline
                'timeout_minutes': timeout_minutes,
                'remaining_minutes': max(0, timeout_minutes - int(time_since_submission.total_seconds() / 60)) if can_accept else None,
                'worker_id': report.worker.account_id if report.worker else None,
                'worker_name': report.worker.name if report.worker else None,
                'citizen_id': report.citizen.account_id if report.citizen else None,
                'citizen_name': report.citizen.name if report.citizen else None,
                # Button state and visibility flags
                'button_state': button_state,  # "pending", "accepted", "rejected"
                'show_accept_button': show_accept_button,  # Show active Accept button
                'show_decline_button': show_decline_button,  # Show active Decline button
                'show_accepted_button': show_accepted_button,  # Show Accepted button (read-only)
                'show_rejected_button': show_rejected_button,  # Show Rejected button (read-only)
            }
        
        # For feedback notifications, get citizen name from feedback if available
        reviewer_name = None
        if notification_type == 'feedback' and notification.report:
            try:
                # Try to get citizen name from report
                if notification.report.citizen:
                    reviewer_name = notification.report.citizen.name
                # Also try to get from feedback model if available
                from gamification.models import Feedback
                feedback = Feedback.objects.filter(report=notification.report).first()
                if feedback and feedback.citizen:
                    reviewer_name = feedback.citizen.name
            except Exception:
                pass
        
        notification_data = {
            'notification_id': notification.notification_id,
            'message': notification.message,
            'is_read': notification.is_read,
            'created_at': notification.created_at.isoformat(),
            'report_id': notification.report.report_id if notification.report else None,
            'notification_type': notification_type,  # "assignment", "feedback", "general"
            'report': report_data,  # Include full report data for timer and actions
        }
        
        # Add reviewer_name for feedback notifications
        if reviewer_name:
            notification_data['reviewer_name'] = reviewer_name
        
        notifications_data.append(notification_data)
    
    # Generate display text for unread count
    unread_display_text = f'{unread_count} Unread' if unread_count > 0 else 'All Read'
    
    return Response(
        {
            'notifications': notifications_data,
            'unread_count': unread_count,
            'total_count': total_count,
            'unread_display_text': unread_display_text,  # "5 Unread" or "All Read"
            'has_unread': unread_count > 0,  # Boolean flag for showing mark all read button
        },
        status=status.HTTP_200_OK
    )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def unread_count_view(request):
    """
    Get unread notification count for the authenticated user
    GET /api/notifications/unread-count/
    
    Returns:
    {
        "unread_count": 5,
        "total_count": 10
    }
    """
    user = request.user
    
    unread_count = Notification.objects.filter(
        recipient_type=user.role,
        recipient_id=user.account_id,
        is_read=False
    ).count()
    
    total_count = Notification.objects.filter(
        recipient_type=user.role,
        recipient_id=user.account_id
    ).count()
    
    # Generate display text for unread count
    unread_display_text = f'{unread_count} Unread' if unread_count > 0 else 'All Read'
    
    return Response(
        {
            'unread_count': unread_count,
            'total_count': total_count,
            'unread_display_text': unread_display_text,  # "5 Unread" or "All Read"
            'has_unread': unread_count > 0,  # Boolean flag
        },
        status=status.HTTP_200_OK
    )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_read_view(request, notification_id):
    """
    Mark a notification as read
    POST /api/notifications/<notification_id>/read/
    """
    try:
        notification = Notification.objects.get(
            notification_id=notification_id,
            recipient_type=request.user.role,
            recipient_id=request.user.account_id
        )
    except Notification.DoesNotExist:
        return Response(
            {'error': 'Notification not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    notification.is_read = True
    notification.save()
    
    # Get updated unread count after marking as read
    user = request.user
    unread_count = Notification.objects.filter(
        recipient_type=user.role,
        recipient_id=user.account_id,
        is_read=False
    ).count()
    
    # Generate display text for updated unread count
    unread_display_text = f'{unread_count} Unread' if unread_count > 0 else 'All Read'
    
    return Response(
        {
            'message': 'Notification marked as read.',
            'notification_id': notification.notification_id,
            'unread_count': unread_count,  # Return updated unread count
            'unread_display_text': unread_display_text,  # "5 Unread" or "All Read"
            'has_unread': unread_count > 0,  # Boolean flag
        },
        status=status.HTTP_200_OK
    )


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def mark_all_read_view(request):
    """
    Mark all notifications as read for the authenticated user
    POST /api/notifications/mark-all-read/
    
    Returns:
    {
        "message": "5 notifications marked as read.",
        "updated_count": 5,
        "unread_count": 0  # Updated unread count after marking all as read
    }
    """
    user = request.user
    
    # Mark all unread notifications as read
    updated = Notification.objects.filter(
        recipient_type=user.role,
        recipient_id=user.account_id,
        is_read=False
    ).update(is_read=True)
    
    # Get updated unread count
    unread_count = Notification.objects.filter(
        recipient_type=user.role,
        recipient_id=user.account_id,
        is_read=False
    ).count()
    
    # Generate display text for updated unread count
    unread_display_text = f'{unread_count} Unread' if unread_count > 0 else 'All Read'
    
    return Response(
        {
            'message': f'{updated} notifications marked as read.',
            'updated_count': updated,
            'unread_count': unread_count,  # Return updated unread count
            'unread_display_text': unread_display_text,  # "5 Unread" or "All Read"
            'has_unread': unread_count > 0,  # Boolean flag
        },
        status=status.HTTP_200_OK
    )
