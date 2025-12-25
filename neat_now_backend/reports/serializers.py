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
    
    class Meta:
        model = Report
        fields = [
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
                'Assigned': ['Resolved', 'Rejected'],
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
        
        return updated_instance
