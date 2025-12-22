from rest_framework import status, generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .models import Account
from .serializers import (
    AccountRegistrationSerializer,
    AccountLoginSerializer,
    EmailVerificationSerializer,
    ResendVerificationSerializer,
    AccountProfileSerializer
)
from .jwt_utils import get_tokens_for_account
from .utils import (
    generate_verification_token,
    store_verification_token,
    get_email_from_token,
    send_verification_email
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
