from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import UserMonthlyStats


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def top_3_leaderboard_view(request):
    """
    Get Top 3 Leaderboard for current month
    GET /api/gamification/leaderboard/top-3/
    
    Returns top 3 users with badges (Platinum, Gold, Silver)
    """
    try:
        month_year = request.query_params.get('month', UserMonthlyStats.get_current_month_year())
        
        top_3 = UserMonthlyStats.objects.filter(
            month_year=month_year,
            monthly_rank__lte=3
        ).order_by('monthly_rank').select_related('user')[:3]
        
        leaderboard_data = []
        for stat in top_3:
            leaderboard_data.append({
                'rank': stat.monthly_rank,
                'user_id': stat.user.account_id,
                'user_name': stat.user.name,
                'user_email': stat.user.email,
                'verified_reports': stat.verified_reports,
                'badge': stat.badge,
                'profile_image': stat.user.profile_image.url if stat.user.profile_image else None,
            })
        
        return Response({
            'month_year': month_year,
            'top_3': leaderboard_data,
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def full_leaderboard_view(request):
    """
    Get Full Leaderboard for current month
    GET /api/gamification/leaderboard/full/
    
    Returns all users with their rank, badge, and verified reports count
    """
    try:
        month_year = request.query_params.get('month', UserMonthlyStats.get_current_month_year())
        limit = int(request.query_params.get('limit', 100))  # Default 100, max 1000
        
        if limit > 1000:
            limit = 1000
        
        leaderboard = UserMonthlyStats.objects.filter(
            month_year=month_year
        ).order_by('monthly_rank', '-verified_reports').select_related('user')[:limit]
        
        leaderboard_data = []
        for stat in leaderboard:
            leaderboard_data.append({
                'rank': stat.monthly_rank,
                'user_id': stat.user.account_id,
                'user_name': stat.user.name,
                'user_email': stat.user.email,
                'verified_reports': stat.verified_reports,
                'badge': stat.badge,
                'profile_image': stat.user.profile_image.url if stat.user.profile_image else None,
            })
        
        return Response({
            'month_year': month_year,
            'total_users': len(leaderboard_data),
            'leaderboard': leaderboard_data,
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_leaderboard_stats_view(request):
    """
    Get current user's leaderboard stats
    GET /api/gamification/leaderboard/my-stats/
    
    Returns user's current rank, badge, and verified reports for current month
    """
    try:
        user = request.user
        month_year = request.query_params.get('month', UserMonthlyStats.get_current_month_year())
        
        # Always update stats to ensure they reflect current uploaded reports count
        stats = UserMonthlyStats.update_user_stats(user, month_year)
        
        return Response({
            'month_year': month_year,
            'rank': stats.monthly_rank,
            'badge': stats.badge,
            'verified_reports': stats.verified_reports,
            'user_name': user.name,
            'user_email': user.email,
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
