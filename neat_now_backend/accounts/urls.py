from django.urls import path
from . import views

app_name = 'accounts'

urlpatterns = [
    # Registration
    path('register/', views.register_view, name='register'),
    
    # Authentication
    path('login/', views.login_view, name='login'),
    path('google-login/', views.google_login_view, name='google-login'),
    
    # Email Verification
    path('verify-email/', views.verify_email_view, name='verify-email'),
    path('resend-verification/', views.resend_verification_view, name='resend-verification'),
    
    # Password Reset
    path('forgot-password/', views.forgot_password_view, name='forgot-password'),
    path('reset-password/', views.reset_password_view, name='reset-password'),
    
    # Profile Management
    path('profile/', views.ProfileView.as_view(), name='profile'),
]

