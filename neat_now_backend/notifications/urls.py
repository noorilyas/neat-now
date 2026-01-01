from django.urls import path
from . import views

app_name = 'notifications'

urlpatterns = [
    # List notifications
    path('', views.list_notifications_view, name='list-notifications'),
    
    # Get unread count (for notification badge)
    path('unread-count/', views.unread_count_view, name='unread-count'),
    
    # Mark notification as read
    path('<int:notification_id>/read/', views.mark_read_view, name='mark-read'),
    
    # Mark all as read
    path('mark-all-read/', views.mark_all_read_view, name='mark-all-read'),
]

