from django.urls import path
from . import views

app_name = 'gamification'

urlpatterns = [
    # Leaderboard endpoints (for citizens)
    path('leaderboard/top-3/', views.top_3_leaderboard_view, name='top-3-leaderboard'),
    path('leaderboard/full/', views.full_leaderboard_view, name='full-leaderboard'),
    path('leaderboard/my-stats/', views.user_leaderboard_stats_view, name='user-leaderboard-stats'),
    
    # Worker leaderboard endpoint
    path('worker-leaderboard/', views.worker_leaderboard_view, name='worker-leaderboard'),
    
    # Feedback endpoint
    path('feedback/create/', views.create_feedback_view, name='create-feedback'),
]

