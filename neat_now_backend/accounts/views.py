from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .models import Account
from .serializers import (
    AccountRegistrationSerializer,
    AccountLoginSerializer,
    GoogleLoginSerializer,
    EmailVerificationSerializer,
    ResendVerificationSerializer,
    ForgotPasswordSerializer,
    ResetPasswordSerializer,
    AccountProfileSerializer
)
from .jwt_utils import get_tokens_for_account
from .utils import (
    generate_verification_token,
    store_verification_token,
    get_email_from_token,
    send_verification_email,
    store_password_reset_token,
    get_email_from_reset_token,
    send_password_reset_email
)


@api_view(['POST'])
@permission_classes([AllowAny])
def register_view(request):
    """
    Citizen Registration Endpoint
    POST /api/accounts/register/
    
    Body:
    {
        "email": "user@example.com",
        "password": "securepassword123",
        "password_confirm": "securepassword123",
        "name": "John Doe",
        "phone_number": "+923001234567",  # Optional
        "profile_image": <file>  # Optional
    }
    """
    serializer = AccountRegistrationSerializer(data=request.data)
    
    if serializer.is_valid():
        account = serializer.save()
        
        # Only send verification email if email is not already verified
        # (In development mode, email is auto-verified)
        if not account.email_verified:
            # Generate verification token
            token = generate_verification_token()
            store_verification_token(account.email, token)
            
            # Send verification email
            send_verification_email(account, token)
            
            return Response(
                {
                    'message': 'Registration successful. Please check your email to verify your account.',
                    'account_id': account.account_id,
                    'email': account.email,
                },
                status=status.HTTP_201_CREATED
            )
        else:
            # Email already verified (development mode)
            return Response(
                {
                    'message': 'Registration successful. Your account is ready to use.',
                    'account_id': account.account_id,
                    'email': account.email,
                },
                status=status.HTTP_201_CREATED
            )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def login_view(request):
    """
    Email/Password Login Endpoint
    POST /api/accounts/login/
    
    Body:
    {
        "email": "user@example.com",
        "password": "securepassword123"
    }
    """
    serializer = AccountLoginSerializer(data=request.data)
    
    if serializer.is_valid():
        account = serializer.validated_data['account']
        
        # Generate JWT tokens
        tokens = get_tokens_for_account(account)
        
        # Return tokens and user data
        return Response(
            {
                'access': tokens['access'],
                'refresh': tokens['refresh'],
                'user': {
                    'account_id': account.account_id,
                    'email': account.email,
                    'name': account.name,
                    'role': account.role,
                    'phone_number': account.phone_number,
                    'profile_image': account.profile_image.url if account.profile_image else None,
                    'email_verified': account.email_verified,
                }
            },
            status=status.HTTP_200_OK
        )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def google_login_view(request):
    """
    Google OAuth Login Endpoint
    POST /api/accounts/google-login/
    
    Body:
    {
        "access_token": "google-access-token-from-oauth-playground"
    }
    """
    serializer = GoogleLoginSerializer(data=request.data)
    
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    # Get verified token info from validated_data
    idinfo = serializer.validated_data['verified_token']
    google_id = idinfo['sub']
    email = idinfo['email'].lower()
    name = idinfo.get('name', '')
    picture = idinfo.get('picture', None)
    
    try:
        # Check if account with this email exists
        account = Account.objects.filter(email=email).first()
        
        if account:
            # Email exists - link Google account or login
            if account.google_id:
                # Account already has Google ID - check if it matches
                if account.google_id != google_id:
                    return Response(
                        {'error': 'This email is already registered with a different Google account.'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                # Same Google account - proceed to login
            else:
                # Email exists but no Google ID - link the account
                account.google_id = google_id
                account.email_verified = True  # Google emails are pre-verified
                if picture and not account.profile_image:
                    # Optionally update profile image from Google
                    pass  # You can implement image download here if needed
                account.save()
        else:
            # Email doesn't exist - create new Citizen account
            account = Account.objects.create(
                email=email,
                name=name,
                google_id=google_id,
                role='Citizen',
                email_verified=True,  # Google emails are pre-verified
                password_hash=None,  # No password for Google-only accounts
            )
            if picture:
                # Optionally download and save profile image
                pass  # You can implement image download here if needed
        
        # Generate JWT tokens (same format as email login)
        tokens = get_tokens_for_account(account)
        
        # Return same response format as email login
        return Response(
            {
                'access': tokens['access'],
                'refresh': tokens['refresh'],
                'user': {
                    'account_id': account.account_id,
                    'email': account.email,
                    'name': account.name,
                    'role': account.role,
                    'phone_number': account.phone_number,
                    'profile_image': account.profile_image.url if account.profile_image else None,
                    'email_verified': account.email_verified,
                }
            },
            status=status.HTTP_200_OK
        )
    
    except Exception as e:
        return Response(
            {'error': f'Login failed: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def verify_email_view(request):
    """
    Email Verification Endpoint
    POST /api/accounts/verify-email/
    
    Body:
    {
        "token": "verification-token-from-email"
    }
    """
    serializer = EmailVerificationSerializer(data=request.data)
    
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    token = serializer.validated_data['token']
    email = get_email_from_token(token)
    
    if not email:
        return Response(
            {'error': 'Invalid or expired verification token.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        account = Account.objects.get(email=email)
        if account.email_verified:
            return Response(
                {'message': 'Email is already verified.'},
                status=status.HTTP_200_OK
            )
        
        account.email_verified = True
        account.save()
        
        return Response(
            {'message': 'Email verified successfully. You can now login.'},
            status=status.HTTP_200_OK
        )
    
    except Account.DoesNotExist:
        return Response(
            {'error': 'Account not found.'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def resend_verification_view(request):
    """
    Resend Verification Email Endpoint
    POST /api/accounts/resend-verification/
    
    Body:
    {
        "email": "user@example.com"
    }
    """
    serializer = ResendVerificationSerializer(data=request.data)
    
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    email = serializer.validated_data['email']
    
    try:
        account = Account.objects.get(email=email)
        
        # Generate new verification token
        token = generate_verification_token()
        store_verification_token(email, token)
        
        # Send verification email
        send_verification_email(account, token)
        
        return Response(
            {'message': 'Verification email sent. Please check your inbox.'},
            status=status.HTTP_200_OK
        )
    
    except Account.DoesNotExist:
        # Don't reveal if email exists or not for security
        return Response(
            {'message': 'If the email exists and is not verified, a verification email has been sent.'},
            status=status.HTTP_200_OK
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password_view(request):
    """
    Forgot Password Endpoint
    POST /api/accounts/forgot-password/
    
    Body:
    {
        "email": "user@example.com"
    }
    """
    serializer = ForgotPasswordSerializer(data=request.data)
    
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    email = serializer.validated_data['email']
    
    try:
        account = Account.objects.get(email=email)
        
        # Check if account has password (not Google-only)
        if not account.has_password:
            return Response(
                {'error': 'This email is registered with Google. Please use Google login.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Generate reset token
        token = generate_verification_token()
        store_password_reset_token(email, token)
        
        # Send reset email
        send_password_reset_email(account, token)
        
        # Don't reveal if email exists for security
        return Response(
            {'message': 'If the email exists, a password reset link has been sent.'},
            status=status.HTTP_200_OK
        )
    
    except Account.DoesNotExist:
        # Don't reveal if email exists for security
        return Response(
            {'message': 'If the email exists, a password reset link has been sent.'},
            status=status.HTTP_200_OK
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def reset_password_view(request):
    """
    Reset Password Endpoint
    POST /api/accounts/reset-password/
    
    Body:
    {
        "token": "reset-token-from-email",
        "password": "newpassword123",
        "password_confirm": "newpassword123"
    }
    """
    serializer = ResetPasswordSerializer(data=request.data)
    
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    token = serializer.validated_data['token']
    new_password = serializer.validated_data['password']
    
    # Get email from token
    email = get_email_from_reset_token(token)
    
    if not email:
        return Response(
            {'error': 'Invalid or expired reset token.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        account = Account.objects.get(email=email)
        
        # Update password
        account.set_password(new_password)
        account.save()
        
        return Response(
            {'message': 'Password reset successfully. You can now login with your new password.'},
            status=status.HTTP_200_OK
        )
    
    except Account.DoesNotExist:
        return Response(
            {'error': 'Account not found.'},
            status=status.HTTP_404_NOT_FOUND
        )


class ProfileView(generics.RetrieveUpdateAPIView):
    """
    Profile Management Endpoint
    GET /api/accounts/profile/ - Get current user profile
    PATCH /api/accounts/profile/ - Update profile (name, phone_number, profile_image)
    """
    serializer_class = AccountProfileSerializer
    permission_classes = [IsAuthenticated]
    
    def get_object(self):
        """Get the current authenticated user's account"""
        # The JWT will contain account_id, we need to get the Account object
        # We'll handle this in authentication backend
        return self.request.user
