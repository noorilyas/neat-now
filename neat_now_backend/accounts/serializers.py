from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import Account
import re


class AccountRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for Citizen registration"""
    
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password],
        style={'input_type': 'password'}
    )
    password_confirm = serializers.CharField(
        write_only=True,
        required=True,
        style={'input_type': 'password'}
    )
    
    class Meta:
        model = Account
        fields = ['email', 'password', 'password_confirm', 'name', 'phone_number', 'profile_image']
        extra_kwargs = {
            'email': {'required': True},
            'name': {'required': True},
        }
    
    def validate_email(self, value):
        """Check if email already exists"""
        if Account.objects.filter(email=value).exists():
            raise serializers.ValidationError("Email already registered.")
        return value.lower()
    
    def validate_phone_number(self, value):
        """Validate phone number format"""
        if value:
            # Remove any spaces or dashes
            value = value.replace(' ', '').replace('-', '')
            # Check format +92XXXXXXXXXX
            if not re.match(r'^\+92\d{10}$', value):
                raise serializers.ValidationError(
                    "Phone number must be in format +92XXXXXXXXXX"
                )
        return value
    
    def validate(self, attrs):
        """Validate password confirmation"""
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({
                'password_confirm': "Passwords do not match."
            })
        return attrs
    
    def create(self, validated_data):
        """Create new Citizen account"""
        from django.conf import settings
        
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        
        # In development mode, auto-verify email for easier testing
        # In production, email verification is required
        auto_verify = settings.DEBUG
        
        account = Account.objects.create(
            email=validated_data['email'],
            name=validated_data['name'],
            phone_number=validated_data.get('phone_number'),
            profile_image=validated_data.get('profile_image'),
            role='Citizen',
            email_verified=auto_verify,  # Auto-verify in development mode
        )
        account.set_password(password)
        account.save()
        
        return account


class AccountLoginSerializer(serializers.Serializer):
    """Serializer for email/password login"""
    
    email = serializers.EmailField(required=True)
    password = serializers.CharField(
        required=True,
        write_only=True,
        style={'input_type': 'password'}
    )
    
    def validate(self, attrs):
        """Validate email and password"""
        email = attrs.get('email', '').lower()
        password = attrs.get('password')
        
        if not email or not password:
            raise serializers.ValidationError({
                'error': 'Email and password are required.'
            })
        
        try:
            account = Account.objects.get(email=email)
        except Account.DoesNotExist:
            raise serializers.ValidationError({
                'error': 'Invalid email or password.'
            })
        
        # Check if email is verified
        if not account.email_verified:
            raise serializers.ValidationError({
                'error': 'Email not verified. Please verify your email first.'
            })
        
        # Check password
        if not account.check_password(password):
            raise serializers.ValidationError({
                'error': 'Invalid email or password.'
            })
        
        attrs['account'] = account
        return attrs


class GoogleLoginSerializer(serializers.Serializer):
    """Serializer for Google OAuth login"""
    
    access_token = serializers.CharField(required=True, write_only=True)
    
    def validate(self, attrs):
        """Validate and verify Google access token"""
        from google.oauth2 import id_token
        from google.auth.transport import requests
        from django.conf import settings
        
        access_token = attrs.get('access_token')
        
        if not settings.GOOGLE_CLIENT_ID:
            raise serializers.ValidationError({
                'error': 'Google OAuth is not configured. Please set GOOGLE_CLIENT_ID in settings.'
            })
        
        try:
            # Verify the token with Google
            idinfo = id_token.verify_oauth2_token(
                access_token,
                requests.Request(),
                settings.GOOGLE_CLIENT_ID
            )
            
            # Verify the issuer
            if idinfo['iss'] not in ['accounts.google.com', 'https://accounts.google.com']:
                raise serializers.ValidationError({
                    'error': 'Invalid token issuer.'
                })
            
            # Store verified token info in validated_data
            attrs['verified_token'] = idinfo
            return attrs
            
        except ValueError as e:
            raise serializers.ValidationError({
                'error': f'Invalid Google token: {str(e)}'
            })
        except Exception as e:
            raise serializers.ValidationError({
                'error': f'Token verification failed: {str(e)}'
            })


class EmailVerificationSerializer(serializers.Serializer):
    """Serializer for email verification"""
    
    token = serializers.CharField(required=True, max_length=255)


class ResendVerificationSerializer(serializers.Serializer):
    """Serializer for resending verification email"""
    
    email = serializers.EmailField(required=True)
    
    def validate_email(self, value):
        """Check if email exists and is not verified"""
        try:
            account = Account.objects.get(email=value.lower())
            if account.email_verified:
                raise serializers.ValidationError("Email is already verified.")
        except Account.DoesNotExist:
            raise serializers.ValidationError("Email not found.")
        return value.lower()


class ForgotPasswordSerializer(serializers.Serializer):
    """Serializer for forgot password request"""
    
    email = serializers.EmailField(required=True)
    
    def validate_email(self, value):
        """Check if email exists and has password"""
        try:
            account = Account.objects.get(email=value.lower())
            # Check if account has password (not Google-only)
            if not account.has_password:
                raise serializers.ValidationError(
                    "This email is registered with Google. Please use Google login."
                )
        except Account.DoesNotExist:
            # Don't reveal if email exists for security
            pass
        return value.lower()


class ResetPasswordSerializer(serializers.Serializer):
    """Serializer for password reset"""
    
    token = serializers.CharField(required=True, max_length=255)
    password = serializers.CharField(
        required=True,
        write_only=True,
        validators=[validate_password],
        style={'input_type': 'password'}
    )
    password_confirm = serializers.CharField(
        required=True,
        write_only=True,
        style={'input_type': 'password'}
    )
    
    def validate(self, attrs):
        """Validate password confirmation"""
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({
                'password_confirm': "Passwords do not match."
            })
        return attrs


class AccountProfileSerializer(serializers.ModelSerializer):
    """Serializer for account profile (read/update)"""
    
    # Leaderboard stats (read-only, computed fields)
    monthly_rank = serializers.SerializerMethodField()
    badge = serializers.SerializerMethodField()
    verified_reports = serializers.SerializerMethodField()
    
    class Meta:
        model = Account
        fields = ['account_id', 'email', 'name', 'phone_number', 'profile_image', 
                  'role', 'email_verified', 'created_at', 'monthly_rank', 'badge', 'verified_reports']
        read_only_fields = ['account_id', 'email', 'role', 'email_verified', 'created_at', 
                          'monthly_rank', 'badge', 'verified_reports']
    
    def validate_phone_number(self, value):
        """Validate phone number format"""
        if value:
            # Remove any spaces or dashes
            value = value.replace(' ', '').replace('-', '')
            # Check format +92XXXXXXXXXX
            if not re.match(r'^\+92\d{10}$', value):
                raise serializers.ValidationError(
                    "Phone number must be in format +92XXXXXXXXXX"
                )
        return value
    
    def validate_profile_image(self, value):
        """Validate profile image size and type"""
        if value:
            # Check file size (5MB max)
            if value.size > 5 * 1024 * 1024:
                raise serializers.ValidationError(
                    "Image file too large. Maximum size is 5MB."
                )
            # Check file type
            if not value.content_type.startswith('image/'):
                raise serializers.ValidationError(
                    "File must be an image."
                )
        return value
    
    def get_monthly_rank(self, obj):
        """Get current user's monthly rank"""
        try:
            from gamification.models import UserMonthlyStats
            month_year = UserMonthlyStats.get_current_month_year()
            stats = UserMonthlyStats.objects.filter(
                user=obj,
                month_year=month_year
            ).first()
            return stats.monthly_rank if stats else None
        except Exception:
            return None
    
    def get_badge(self, obj):
        """Get current user's badge"""
        try:
            from gamification.models import UserMonthlyStats
            month_year = UserMonthlyStats.get_current_month_year()
            stats = UserMonthlyStats.objects.filter(
                user=obj,
                month_year=month_year
            ).first()
            return stats.badge if stats else 'None'
        except Exception:
            return 'None'
    
    def get_verified_reports(self, obj):
        """Get current user's verified reports count for current month"""
        try:
            from gamification.models import UserMonthlyStats
            month_year = UserMonthlyStats.get_current_month_year()
            stats = UserMonthlyStats.objects.filter(
                user=obj,
                month_year=month_year
            ).first()
            return stats.verified_reports if stats else 0
        except Exception:
            return 0

