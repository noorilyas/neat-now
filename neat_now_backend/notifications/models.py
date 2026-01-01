from django.db import models
from django.utils import timezone
from accounts.models import Account


class Notification(models.Model):
    """
    Push notification queue for status updates or admin alerts.
    Stores notifications for Citizens, Workers, and Admins.
    """
    
    RECIPIENT_TYPE_CHOICES = [
        ('Citizen', 'Citizen'),
        ('Worker', 'Worker'),
        ('Admin', 'Admin'),
    ]
    
    # Primary key
    notification_id = models.BigAutoField(primary_key=True)
    
    # Recipient identification
    recipient_type = models.CharField(
        max_length=10,
        choices=RECIPIENT_TYPE_CHOICES,
        db_index=True,
        help_text='Identifies the role of the receiver'
    )
    recipient_id = models.IntegerField(
        null=False,
        db_index=True,
        help_text='The ID from the corresponding role table (Account.account_id)'
    )
    
    # Message content
    message = models.TextField(
        null=False,
        blank=False,
        help_text='The actual text (e.g., "Your report has been resolved!")'
    )
    
    # Read status
    is_read = models.BooleanField(
        default=False,
        db_index=True,
        help_text='Tracks if the user has opened the alert'
    )
    
    # Timestamp
    created_at = models.DateTimeField(
        default=timezone.now,
        db_index=True,
        help_text='For sorting and "time ago" labels'
    )
    
    # Optional: Link to related report (for report-related notifications)
    report = models.ForeignKey(
        'reports.Report',
        on_delete=models.CASCADE,
        related_name='notifications',
        null=True,
        blank=True,
        help_text='Link to related report (if notification is about a report)'
    )
    
    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['recipient_type', 'recipient_id', 'is_read']),
            models.Index(fields=['recipient_id', 'is_read']),
            models.Index(fields=['created_at']),
        ]
    
    def __str__(self):
        return f'Notification #{self.notification_id} to {self.recipient_type} {self.recipient_id}: {self.message[:50]}'
    
    @property
    def recipient(self):
        """Get the recipient Account object"""
        try:
            return Account.objects.get(account_id=self.recipient_id, role=self.recipient_type)
        except Account.DoesNotExist:
            return None
