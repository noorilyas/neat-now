from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from accounts.models import Account


class Report(models.Model):
    """
    Core table for waste reports, AI analysis results, and GPS locations.
    Stores citizen reports with images, GPS coordinates, and AI analysis.
    """
    
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Assigned', 'Assigned'),
        ('Resolved', 'Resolved'),
        ('Rejected', 'Rejected'),
    ]
    
    AI_RESULT_CHOICES = [
        ('Unverified', 'Unverified'),
        ('Waste', 'Waste'),
        ('No Waste', 'No Waste'),
    ]
    
    # Primary key
    report_id = models.BigAutoField(primary_key=True)
    
    # Foreign keys
    citizen = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='reports',
        db_column='citizen_id',
        limit_choices_to={'role': 'Citizen'}
    )
    worker = models.ForeignKey(
        Account,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='assigned_reports',
        db_column='worker_id',
        limit_choices_to={'role': 'Worker'}
    )
    
    # Status fields
    status = models.CharField(
        max_length=10,
        choices=STATUS_CHOICES,
        default='Pending',
        db_index=True
    )
    
    # AI analysis fields
    ai_result = models.CharField(
        max_length=10,
        choices=AI_RESULT_CHOICES,
        default='Unverified',
        db_index=True
    )
    waste_type = models.CharField(
        max_length=255,
        null=True,
        blank=True,
        help_text='Waste type detected by AI. Can be any type or combination detected by AI (e.g., "Plastic", "Mixed Plastic Waste", "Organic Food Waste", etc.). No restrictions - AI can detect unlimited types.'
    )
    ai_confidence = models.DecimalField(
        max_digits=3,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[
            MinValueValidator(0.00),
            MaxValueValidator(1.00)
        ],
        help_text='AI confidence score between 0.00 and 1.00'
    )
    
    # GPS coordinates (separate fields for latitude and longitude)
    latitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        validators=[
            MinValueValidator(-90.0),
            MaxValueValidator(90.0)
        ],
        help_text='Latitude between -90.0 and 90.0'
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        validators=[
            MinValueValidator(-180.0),
            MaxValueValidator(180.0)
        ],
        help_text='Longitude between -180.0 and 180.0'
    )
    
    # Image fields
    image_before = models.ImageField(
        upload_to='reports/before/%Y/%m/%d/',
        null=False,
        blank=False,
        help_text='User\'s photo of the waste (required)'
    )
    image_after = models.ImageField(
        upload_to='reports/after/%Y/%m/%d/',
        null=True,
        blank=True,
        help_text='Worker\'s proof of cleanup (optional)'
    )
    
    # Timestamps
    submitted_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'reports'
        ordering = ['-submitted_at']
        indexes = [
            models.Index(fields=['citizen', 'status']),
            models.Index(fields=['worker', 'status']),
            models.Index(fields=['status', 'ai_result']),
            models.Index(fields=['submitted_at']),
        ]
    
    def __str__(self):
        return f'Report #{self.report_id} by {self.citizen.email} - {self.status}'
    
    @property
    def has_gps_coordinates(self):
        """Check if report has GPS coordinates"""
        return self.latitude is not None and self.longitude is not None
    
    def set_gps_coordinates(self, latitude, longitude):
        """Set GPS coordinates with validation"""
        if -90.0 <= latitude <= 90.0 and -180.0 <= longitude <= 180.0:
            self.latitude = latitude
            self.longitude = longitude
            return True
        return False
