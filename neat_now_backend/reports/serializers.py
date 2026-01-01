from rest_framework import serializers
from .models import Report
from accounts.models import Account
from decimal import Decimal

# Import ImageStorageLog with try-except to handle missing table
try:
    from .models import ImageStorageLog
except Exception:
    ImageStorageLog = None


class ReportCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for creating new waste reports.
    Handles image upload, GPS coordinates, and validation.
    """
    
    # Override image_before to make it required in API
    image_before = serializers.ImageField(required=True)
    
    # GPS coordinates as separate fields
    latitude = serializers.DecimalField(
        max_digits=9,
        decimal_places=6,
        required=False,
        allow_null=True,
        help_text='Latitude (-90.0 to 90.0). Required if using camera, optional if uploading from gallery.'
    )
    longitude = serializers.DecimalField(
        max_digits=9,
        decimal_places=6,
        required=False,
        allow_null=True,
        help_text='Longitude (-180.0 to 180.0). Required if using camera, optional if uploading from gallery.'
    )
    
    # Source indicator (camera or gallery)
    source = serializers.ChoiceField(
        choices=[('camera', 'Camera'), ('gallery', 'Gallery')],
        required=True,
        write_only=True,
        help_text='Source of image: "camera" (auto GPS) or "gallery" (manual GPS)'
    )
    
    class Meta:
        model = Report
        fields = [
            'image_before',
            'latitude',
            'longitude',
            'source',
        ]
        read_only_fields = ['report_id', 'submitted_at']
    
    def validate_latitude(self, value):
        """Validate latitude range"""
        if value is not None:
            if value < Decimal('-90.0') or value > Decimal('90.0'):
                raise serializers.ValidationError(
                    'Latitude must be between -90.0 and 90.0.'
                )
        return value
    
    def validate_longitude(self, value):
        """Validate longitude range"""
        if value is not None:
            if value < Decimal('-180.0') or value > Decimal('180.0'):
                raise serializers.ValidationError(
                    'Longitude must be between -180.0 and 180.0.'
                )
        return value
    
    def validate(self, attrs):
        """Cross-field validation"""
        source = attrs.get('source')
        latitude = attrs.get('latitude')
        longitude = attrs.get('longitude')
        
        # If source is camera, GPS coordinates are required
        if source == 'camera':
            if latitude is None or longitude is None:
                raise serializers.ValidationError({
                    'error': 'GPS coordinates (latitude and longitude) are required when using camera.'
                })
        
        # If source is gallery, GPS coordinates are optional (can be set manually via map)
        # But if provided, both must be present
        if source == 'gallery':
            if (latitude is None) != (longitude is None):
                raise serializers.ValidationError({
                    'error': 'Both latitude and longitude must be provided together, or both should be null.'
                })
        
        return attrs
    
    def create(self, validated_data):
        """Create new report with citizen from authenticated user"""
        source = validated_data.pop('source')  # Remove source, not stored in model
        
        # Get citizen from request user
        citizen = self.context['request'].user
        
        # Get image file
        image_file = validated_data['image_before']
        
        # Create report
        report = Report.objects.create(
            citizen=citizen,
            image_before=image_file,
            latitude=validated_data.get('latitude'),
            longitude=validated_data.get('longitude'),
            status='Pending',
            ai_result='Unverified',
        )
        
        # Log image storage in IMAGE_STORAGE_LOG (if table exists)
        if ImageStorageLog:
            try:
                request = self.context['request']
                image_url = request.build_absolute_uri(report.image_before.url)
                
                ImageStorageLog.objects.create(
                    report=report,
                    image_type='before',
                    storage_path=image_url,
                )
            except Exception as e:
                # If ImageStorageLog table doesn't exist yet (migrations not run), continue without logging
                import logging
                logger = logging.getLogger(__name__)
                logger.warning(f'Could not log image to ImageStorageLog: {e}. Run migrations first.')
        
        # Update user monthly stats (for leaderboard) - count uploaded reports
        try:
            from gamification.models import UserMonthlyStats
            UserMonthlyStats.update_user_stats(citizen)
        except Exception as e:
            import logging
            logger = logging.getLogger(__name__)
            logger.warning(f'Could not update user stats: {e}')
        
        return report


class ReportListSerializer(serializers.ModelSerializer):
    """
    Serializer for listing reports (read-only)
    """
    citizen_email = serializers.EmailField(source='citizen.email', read_only=True)
    citizen_name = serializers.CharField(source='citizen.name', read_only=True)
    worker_email = serializers.EmailField(source='worker.email', read_only=True, allow_null=True)
    worker_name = serializers.CharField(source='worker.name', read_only=True, allow_null=True)
    
    # Override image fields to return full URLs
    image_before = serializers.SerializerMethodField()
    image_after = serializers.SerializerMethodField()
    
    # Assigned timestamp (when worker accepted the report)
    assigned_at = serializers.SerializerMethodField()
    
    # Timer fields for pending reports (60-minute timeout)
    can_accept = serializers.SerializerMethodField()
    can_decline = serializers.SerializerMethodField()
    remaining_minutes = serializers.SerializerMethodField()
    remaining_seconds = serializers.SerializerMethodField()
    timeout_minutes = serializers.SerializerMethodField()
    is_expired = serializers.SerializerMethodField()
    
    # Button state and visibility fields
    button_state = serializers.SerializerMethodField()
    show_accept_button = serializers.SerializerMethodField()
    show_decline_button = serializers.SerializerMethodField()
    show_accepted_button = serializers.SerializerMethodField()
    show_rejected_button = serializers.SerializerMethodField()
    status_display = serializers.SerializerMethodField()
    
    class Meta:
        model = Report
        fields = [
            'report_id',
            'citizen_email',
            'citizen_name',
            'worker_email',
            'worker_name',
            'status',
            'status_display',  # Frontend display text: "Accepted", "Rejected", etc.
            'ai_result',
            'waste_type',
            'ai_confidence',
            'latitude',
            'longitude',
            'image_before',
            'image_after',
            'submitted_at',
            'updated_at',
            'assigned_at',  # When worker accepted (for timer) - returns accepted_at value
            'accepted_at',  # When worker accepted (for task numbering) - never changes
            'resolved_at',
            # Timer fields
            'can_accept',
            'can_decline',
            'remaining_minutes',
            'remaining_seconds',
            'timeout_minutes',
            'is_expired',
            # Button fields
            'button_state',  # "pending", "accepted", "rejected"
            'show_accept_button',  # Show active Accept button
            'show_decline_button',  # Show active Decline button
            'show_accepted_button',  # Show Accepted button (read-only)
            'show_rejected_button',  # Show Rejected button (read-only)
        ]
        read_only_fields = [
            'report_id',
            'citizen_email',
            'citizen_name',
            'worker_email',
            'worker_name',
            'status',
            'ai_result',
            'waste_type',
            'ai_confidence',
            'latitude',
            'longitude',
            'image_before',
            'image_after',
            'submitted_at',
            'updated_at',
            'resolved_at',
        ]
    
    def get_image_before(self, obj):
        """Return full URL for image_before"""
        try:
            if obj.image_before:
                request = self.context.get('request')
                if request:
                    return request.build_absolute_uri(obj.image_before.url)
                return obj.image_before.url
        except Exception as e:
            # Log error but don't break the API
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f'Error getting image_before URL for report {obj.report_id}: {e}')
        return None
    
    def get_image_after(self, obj):
        """Return full URL for image_after"""
        try:
            if obj.image_after:
                request = self.context.get('request')
                if request:
                    return request.build_absolute_uri(obj.image_after.url)
                return obj.image_after.url
        except Exception as e:
            # Log error but don't break the API
            import logging
            logger = logging.getLogger(__name__)
            logger.error(f'Error getting image_after URL for report {obj.report_id}: {e}')
        return None
    
    def get_assigned_at(self, obj):
        """Return assigned_at timestamp (when worker accepted the report)"""
        # Return accepted_at if available (when worker first accepted)
        # This is consistent across all statuses (Assigned, In Progress, Resolved)
        # because accepted_at only gets set once when worker accepts, never changes
        if obj.accepted_at is not None:
            return obj.accepted_at
        # Fallback to updated_at for all accepted reports (for backward compatibility)
        # This handles reports that were accepted before accepted_at field was added
        # For old reports, we use updated_at as a fallback (not perfect but better than None)
        if obj.worker is not None:
            return obj.updated_at
        return None
    
    def get_accepted_at(self, obj):
        """Return accepted_at timestamp (when worker accepted the report) - never changes"""
        # This is the timestamp when worker first accepted the report
        # It NEVER changes, even when status changes (Assigned → In Progress → Resolved)
        # This ensures task numbers stay consistent across status changes
        return obj.accepted_at
    
    def get_can_accept(self, obj):
        """Check if report can be accepted (Pending status, no worker, within 60 min)"""
        if obj.status != 'Pending' or obj.worker is not None:
            return False
        
        from django.utils import timezone
        from datetime import timedelta
        
        time_since_submission = timezone.now() - obj.submitted_at
        timeout_minutes = 60
        return time_since_submission <= timedelta(minutes=timeout_minutes)
    
    def get_can_decline(self, obj):
        """Check if report can be declined (same as can_accept)"""
        return self.get_can_accept(obj)
    
    def get_remaining_minutes(self, obj):
        """Get remaining minutes before timeout (for pending reports)"""
        if obj.status != 'Pending' or obj.worker is not None:
            return None
        
        from django.utils import timezone
        from datetime import timedelta
        
        time_since_submission = timezone.now() - obj.submitted_at
        timeout_minutes = 60
        remaining = timeout_minutes - int(time_since_submission.total_seconds() / 60)
        return max(0, remaining)
    
    def get_remaining_seconds(self, obj):
        """Get remaining seconds within the current minute (for precise timer)"""
        if obj.status != 'Pending' or obj.worker is not None:
            return None
        
        from django.utils import timezone
        from datetime import timedelta
        
        time_since_submission = timezone.now() - obj.submitted_at
        timeout_seconds = 60 * 60  # 60 minutes in seconds
        remaining_total_seconds = timeout_seconds - int(time_since_submission.total_seconds())
        remaining_seconds = max(0, remaining_total_seconds % 60)
        return remaining_seconds
    
    def get_timeout_minutes(self, obj):
        """Get timeout duration in minutes"""
        if obj.status == 'Pending' and obj.worker is None:
            return 60
        return None
    
    def get_is_expired(self, obj):
        """Check if report acceptance has expired"""
        if obj.status != 'Pending' or obj.worker is not None:
            return False
        
        from django.utils import timezone
        from datetime import timedelta
        
        time_since_submission = timezone.now() - obj.submitted_at
        timeout_minutes = 60
        return time_since_submission > timedelta(minutes=timeout_minutes)
    
    def get_button_state(self, obj):
        """Get button state for frontend: 'pending', 'accepted', 'rejected'"""
        if obj.status == 'Assigned' and obj.worker is not None:
            return 'accepted'  # Show "Accepted" button
        elif obj.status == 'Rejected':
            return 'rejected'  # Show "Rejected" button
        elif obj.status == 'Pending' and obj.worker is None:
            return 'pending'  # Show Accept/Decline buttons
        return None
    
    def get_show_accept_button(self, obj):
        """Show active Accept button (for pending reports)"""
        return self.get_can_accept(obj)
    
    def get_show_decline_button(self, obj):
        """Show active Decline button (for pending reports)"""
        return self.get_can_accept(obj)
    
    def get_show_accepted_button(self, obj):
        """Show Accepted button (read-only, for accepted reports)"""
        return obj.status == 'Assigned' and obj.worker is not None
    
    def get_show_rejected_button(self, obj):
        """Show Rejected button (read-only, for rejected reports)"""
        return obj.status == 'Rejected'
    
    def get_status_display(self, obj):
        """Get status display text for frontend"""
        # Worker side: Show "Pending" if worker accepted but not started (status is Pending with worker set)
        # Citizen side: Show "Assigned" if worker is set (display only, backend status is Pending)
        if obj.status == 'Pending' and obj.worker is not None:
            # Worker accepted but not started - show as "Pending" for worker, "Assigned" for citizen
            # Frontend will handle display based on user role
            return 'Pending'  # Worker side display
        elif obj.status == 'Rejected':
            return 'Rejected'
        return obj.status


class ReportDetailSerializer(serializers.ModelSerializer):
    """
    Serializer for report details
    """
    citizen_email = serializers.EmailField(source='citizen.email', read_only=True)
    citizen_name = serializers.CharField(source='citizen.name', read_only=True)
    worker_email = serializers.EmailField(source='worker.email', read_only=True, allow_null=True)
    worker_name = serializers.CharField(source='worker.name', read_only=True, allow_null=True)
    
    class Meta:
        model = Report
        fields = '__all__'
        read_only_fields = [
            'report_id',
            'citizen',
            'submitted_at',
            'updated_at',
        ]


class ReportUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for updating report (for workers/admin)
    """
    class Meta:
        model = Report
        fields = [
            'status',
            'ai_result',
            'waste_type',
            'ai_confidence',
            'image_after',
            'resolved_at',
        ]
    
    def validate_status(self, value):
        """Validate status transitions"""
        if self.instance:
            current_status = self.instance.status
            
            # Only allow valid status transitions
            valid_transitions = {
                'Pending': ['Assigned', 'Rejected'],
                'Assigned': ['In Progress', 'Resolved', 'Rejected'],  # Can start (In Progress) or resolve directly
                'In Progress': ['Resolved', 'Rejected'],  # Can only resolve or reject from In Progress
                'Resolved': [],  # Cannot change from resolved
                'Rejected': [],  # Cannot change from rejected
            }
            
            if value not in valid_transitions.get(current_status, []):
                raise serializers.ValidationError(
                    f'Cannot change status from {current_status} to {value}.'
                )
        
        return value
    
    def update(self, instance, validated_data):
        """Update report and set resolved_at if status is Resolved"""
        status = validated_data.get('status', instance.status)
        image_after = validated_data.get('image_after')
        
        # Update the report first
        updated_instance = super().update(instance, validated_data)
        
        # If image_after is provided and it's a new upload, log it in IMAGE_STORAGE_LOG
        if image_after and updated_instance.image_after and ImageStorageLog:
            try:
                request = self.context.get('request')
                if request:
                    image_url = request.build_absolute_uri(updated_instance.image_after.url)
                    
                    # Check if this image is already logged
                    existing_log = ImageStorageLog.objects.filter(
                        report=updated_instance,
                        image_type='after',
                        storage_path=image_url
                    ).first()
                    
                    if not existing_log:
                        ImageStorageLog.objects.create(
                            report=updated_instance,
                            image_type='after',
                            storage_path=image_url,
                        )
            except Exception as e:
                # If ImageStorageLog table doesn't exist yet, continue without logging
                import logging
                logger = logging.getLogger(__name__)
                logger.warning(f'Could not log image_after to ImageStorageLog: {e}. Run migrations first.')
        
        # Set resolved_at if status changed to Resolved
        if updated_instance.status == 'Resolved' and instance.status != 'Resolved':
            from django.utils import timezone
            updated_instance.resolved_at = timezone.now()
            updated_instance.save()
            
            # Note: User stats are updated when report is created (uploaded), not when resolved
            # Leaderboard counts uploaded reports based on submitted_at, not resolved_at
        
        # Send notification to citizen when status changes to "In Progress"
        if updated_instance.status == 'In Progress' and instance.status != 'In Progress':
            from notifications.models import Notification
            worker_name = updated_instance.worker.name if updated_instance.worker else 'Worker'
            Notification.objects.create(
                recipient_type='Citizen',
                recipient_id=updated_instance.citizen.account_id,
                message=f'Your report #{updated_instance.report_id} is now in progress. {worker_name} has started working on your request.',
                report=updated_instance
            )
        
        return updated_instance
