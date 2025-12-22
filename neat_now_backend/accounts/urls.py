from django.urls import path
from . import views

app_name = 'accounts'

urlpatterns = [
    # Registration
    path('register/', views.register_view, name='register'),
    
    # Authentication
    path('login/', views.login_view, name='login'),
    
    # Email Verification
    path('verify-email/', views.verify_email_view, name='verify-email'),
    path('resend-verification/', views.resend_verification_view, name='resend-verification'),
    
    # Profile Management
    path('profile/', views.ProfileView.as_view(), name='profile'),
]

