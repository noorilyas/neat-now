from rest_framework import serializers
from .models import Report
from accounts.models import Account
from decimal import Decimal


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
        
        # Create report
        report = Report.objects.create(
            citizen=citizen,
            image_before=validated_data['image_before'],
            latitude=validated_data.get('latitude'),
            longitude=validated_data.get('longitude'),
            status='Pending',
            ai_result='Unverified',
        )
        
        return report


class ReportListSerializer(serializers.ModelSerializer):
    """
    Serializer for listing reports (read-only)
    """
    citizen_email = serializers.EmailField(source='citizen.email', read_only=True)
    citizen_name = serializers.CharField(source='citizen.name', read_only=True)
    worker_email = serializers.EmailField(source='worker.email', read_only=True, allow_null=True)
    worker_name = serializers.CharField(source='worker.name', read_only=True, allow_null=True)
    
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
        read_only_fields = '__all__'


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
        
        if status == 'Resolved' and instance.status != 'Resolved':
            from django.utils import timezone
            validated_data['resolved_at'] = timezone.now()
        
        return super().update(instance, validated_data)

