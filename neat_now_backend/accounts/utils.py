from django.core.cache import cache
from django.core.mail import send_mail
from django.conf import settings
from django.utils.html import strip_tags
import uuid


def generate_verification_token():
    """Generate a unique verification token"""
    return str(uuid.uuid4())


def store_verification_token(email, token):
    """Store verification token in cache with 24 hour expiry"""
    cache_key = f'email_verification_{token}'
    cache.set(cache_key, email, timeout=86400)  # 24 hours


def get_email_from_token(token):
    """Retrieve email from verification token"""
    cache_key = f'email_verification_{token}'
    email = cache.get(cache_key)
    if email:
        # Delete token after use (one-time use)
        cache.delete(cache_key)
    return email


def send_verification_email(account, token):
    """Send email verification email to user"""
    verification_url = f"{settings.FRONTEND_URL}/verify-email?token={token}"
    
    # HTML email template
    html_message = f"""
    <html>
    <body>
        <h2>Verify Your Email Address</h2>
        <p>Hello {account.name},</p>
        <p>Thank you for registering with Neat Now. Please verify your email address by clicking the link below:</p>
        <p><a href="{verification_url}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Verify Email</a></p>
        <p>Or copy and paste this link into your browser:</p>
        <p>{verification_url}</p>
        <p>This link will expire in 24 hours.</p>
        <p>If you did not create an account, please ignore this email.</p>
        <br>
        <p>Best regards,<br>Neat Now Team</p>
    </body>
    </html>
    """
    
    plain_message = strip_tags(html_message)
    
    try:
        # Use DEFAULT_FROM_EMAIL if set, otherwise use a default for console backend
        from_email = settings.DEFAULT_FROM_EMAIL or 'noreply@neatnow.com'
        
        send_mail(
            subject='Verify Your Email Address - Neat Now',
            message=plain_message,
            from_email=from_email,
            recipient_list=[account.email],
            html_message=html_message,
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False


def store_password_reset_token(email, token):
    """Store password reset token in cache with 1 hour expiry"""
    cache_key = f'password_reset_{token}'
    cache.set(cache_key, email, timeout=3600)  # 1 hour


def get_email_from_reset_token(token):
    """Retrieve email from password reset token"""
    cache_key = f'password_reset_{token}'
    email = cache.get(cache_key)
    if email:
        # Delete token after use (one-time use)
        cache.delete(cache_key)
    return email


def send_password_reset_email(account, token):
    """Send password reset email to user"""
    reset_url = f"{settings.FRONTEND_URL}/reset-password?token={token}"
    
    # HTML email template
    html_message = f"""
    <html>
    <body>
        <h2>Reset Your Password</h2>
        <p>Hello {account.name},</p>
        <p>You requested to reset your password for your Neat Now account.</p>
        <p>Click the link below to reset your password:</p>
        <p><a href="{reset_url}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Reset Password</a></p>
        <p>Or copy and paste this link into your browser:</p>
        <p>{reset_url}</p>
        <p>This link will expire in 1 hour.</p>
        <p>If you did not request a password reset, please ignore this email. Your password will remain unchanged.</p>
        <br>
        <p>Best regards,<br>Neat Now Team</p>
    </body>
    </html>
    """
    
    plain_message = strip_tags(html_message)
    
    try:
        from_email = settings.DEFAULT_FROM_EMAIL or 'noreply@neatnow.com'
        
        send_mail(
            subject='Reset Your Password - Neat Now',
            message=plain_message,
            from_email=from_email,
            recipient_list=[account.email],
            html_message=html_message,
            fail_silently=False,
        )
        return True
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

