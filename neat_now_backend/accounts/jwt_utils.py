from rest_framework_simplejwt.tokens import RefreshToken
from .models import Account


class AccountRefreshToken(RefreshToken):
    """Custom RefreshToken that uses account_id instead of user_id"""
    
    @classmethod
    def for_account(cls, account):
        """Create a token for an Account instance"""
        token = cls()
        token['user_id'] = account.account_id
        token['email'] = account.email
        token['role'] = account.role
        return token


def get_tokens_for_account(account):
    """
    Generate JWT tokens for an Account instance
    Returns access and refresh tokens
    """
    refresh = AccountRefreshToken.for_account(account)
    
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

