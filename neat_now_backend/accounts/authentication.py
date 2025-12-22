from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, AuthenticationFailed
from .models import Account


class AccountJWTAuthentication(JWTAuthentication):
    """
    Custom JWT Authentication that uses Account model instead of Django User
    """
    
    def get_user(self, validated_token):
        """
        Get Account object from validated JWT token
        """
        try:
            account_id = validated_token['user_id']
        except KeyError:
            raise InvalidToken('Token contained no recognizable user identification')
        
        try:
            account = Account.objects.get(account_id=account_id)
        except Account.DoesNotExist:
            raise AuthenticationFailed('User not found', code='user_not_found')
        
        if not account.email_verified:
            raise AuthenticationFailed('Email not verified', code='email_not_verified')
        
        return account

