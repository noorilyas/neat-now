from django.urls import path
from . import views

app_name = 'gamification'

urlpatterns = [
    # Leaderboard endpoints
    path('leaderboard/top-3/', views.top_3_leaderboard_view, name='top-3-leaderboard'),
    path('leaderboard/full/', views.full_leaderboard_view, name='full-leaderboard'),
    path('leaderboard/my-stats/', views.user_leaderboard_stats_view, name='user-leaderboard-stats'),
]

