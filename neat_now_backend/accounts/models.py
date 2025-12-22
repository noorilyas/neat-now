from django.db import models
from django.contrib.auth.hashers import make_password, check_password
from django.core.validators import RegexValidator


class Account(models.Model):
    """
    Core table for all mobile app users (Citizen/Worker).
    Uses Role system to differentiate between Citizen and Service Worker.
    """
    
    ROLE_CHOICES = [
        ('Citizen', 'Citizen'),
        ('Worker', 'Worker'),
    ]
    
    # Primary key
    account_id = models.BigAutoField(primary_key=True)
    
    # Authentication fields
    email = models.EmailField(unique=True, max_length=255, db_index=True)
    password_hash = models.CharField(max_length=255, null=True, blank=True)  # Nullable for Google-only accounts
    
    # Role field
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='Citizen')
    
    # Profile fields
    name = models.CharField(max_length=150)
    phone_number = models.CharField(
        max_length=20,
        null=True,
        blank=True,
        validators=[
            RegexValidator(
                regex=r'^\+92\d{10}$',
                message='Phone number must be in format +92XXXXXXXXXX'
            )
        ]
    )
    profile_image = models.ImageField(upload_to='profiles/%Y/%m/%d/', null=True, blank=True)
    
    # Google OAuth
    google_id = models.CharField(max_length=255, null=True, blank=True, unique=True, db_index=True)
    
    # Email verification
    email_verified = models.BooleanField(default=False)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'accounts'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['google_id']),
            models.Index(fields=['role']),
        ]
    
    def set_password(self, raw_password):
        """Hash and set password"""
        self.password_hash = make_password(raw_password)
    
    def check_password(self, raw_password):
        """Check if provided password matches"""
        if not self.password_hash:
            return False
        return check_password(raw_password, self.password_hash)
    
    def __str__(self):
        return f"{self.name} ({self.email})"
    
    @property
    def has_password(self):
        """Check if account has a password set (not Google-only account)"""
        return bool(self.password_hash and self.password_hash != '')
    
    @property
    def is_authenticated(self):
        """Required for Django REST Framework authentication"""
        return True
    
    @property
    def is_anonymous(self):
        """Required for Django REST Framework authentication"""
        return False
