from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import UserMonthlyStats, WorkerMonthlyStats, Feedback
from reports.models import Report


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


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_feedback_view(request):
    """
    Create feedback for a resolved report
    POST /api/gamification/feedback/create/
    
    Body:
    {
        "report_id": 123,
        "rating": 5,
        "comment": "Great work!" (optional)
    }
    
    - Only citizens can create feedback
    - Report must be resolved
    - Report must belong to the citizen
    - One feedback per report
    """
    if request.user.role != 'Citizen':
        return Response(
            {'error': 'Only citizens can submit feedback.'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    report_id = request.data.get('report_id')
    rating = request.data.get('rating')
    comment = request.data.get('comment', None)
    
    if not report_id:
        return Response(
            {'error': 'report_id is required.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if not rating:
        return Response(
            {'error': 'rating is required.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        rating = int(rating)
        if rating < 1 or rating > 5:
            return Response(
                {'error': 'Rating must be between 1 and 5.'},
                status=status.HTTP_400_BAD_REQUEST
            )
    except (ValueError, TypeError):
        return Response(
            {'error': 'Rating must be a number between 1 and 5.'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        report = Report.objects.get(report_id=report_id)
    except Report.DoesNotExist:
        return Response(
            {'error': 'Report not found.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Use the static method to create feedback
    try:
        feedback = Feedback.create_feedback(
            report=report,
            citizen=request.user,
            rating=rating,
            comment=comment
        )
        
        return Response(
            {
                'message': 'Feedback submitted successfully.',
                'feedback_id': feedback.feedback_id,
                'rating': feedback.rating,
                'comment': feedback.comment,
            },
            status=status.HTTP_201_CREATED
        )
    except ValueError as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def worker_leaderboard_view(request):
    """
    Get Worker Leaderboard for current month
    GET /api/gamification/worker-leaderboard/
    
    Returns workers ranked by points, with badges based on rating
    """
    try:
        month_year = request.query_params.get('month', WorkerMonthlyStats.get_current_month_year())
        limit = int(request.query_params.get('limit', 100))
        
        if limit > 1000:
            limit = 1000
        
        # Get all worker stats for this month
        # We'll sort by badge first (Diamond > Gold > Silver > Bronze > None), then by points, then by rating
        all_worker_stats = list(WorkerMonthlyStats.objects.filter(
            month_year=month_year
        ).select_related('worker'))
        
        # Define badge order for sorting (higher badge = lower number = better rank)
        # Order: Diamond > Gold > Bronze > Silver > None
        badge_order = {
            'Diamond': 0,
            'Gold': 1,
            'Bronze': 2,
            'Silver': 3,
            'None': 4,
        }
        
        # Sort by badge first, then points, then rating
        all_worker_stats.sort(key=lambda s: (
            badge_order.get(s.badge, 4),  # Badge order (Diamond=0, Gold=1, etc.)
            -s.points,  # Points descending
            -float(s.avg_rating),  # Rating descending
        ))
        
        # Take limit
        worker_stats = all_worker_stats[:limit]
        
        # Calculate ranks (workers with same badge, points, and rating get same rank)
        leaderboard_data = []
        current_rank = 1
        previous_badge = None
        previous_points = None
        previous_rating = None
        
        for index, stat in enumerate(worker_stats):
            # If badge, points, or rating changed, update rank
            if previous_badge is not None and (
                stat.badge != previous_badge or 
                stat.points != previous_points or 
                float(stat.avg_rating) != previous_rating
            ):
                current_rank = index + 1
            
            # Get total all-time completed tasks for this worker
            from reports.models import Report
            total_all_time_tasks = Report.objects.filter(
                worker=stat.worker,
                status='Resolved'
            ).count()
            
            leaderboard_data.append({
                'rank': current_rank,
                'worker_id': stat.worker.account_id,
                'worker_name': stat.worker.name,
                'worker_email': stat.worker.email,
                'resolved_tasks': stat.resolved_tasks,  # Monthly tasks
                'total_tasks': total_all_time_tasks,  # All-time total tasks
                'points': stat.points,
                'avg_rating': float(stat.avg_rating),
                'badge': stat.badge,
                'profile_image': stat.worker.profile_image.url if stat.worker.profile_image else None,
            })
            
            previous_badge = stat.badge
            previous_points = stat.points
            previous_rating = float(stat.avg_rating)
        
        # Get current user's rank if they are a worker
        current_user_stats = None
        if request.user.role == 'Worker':
            try:
                # Find rank in leaderboard
                for entry in leaderboard_data:
                    if entry['worker_id'] == request.user.account_id:
                        current_user_stats = {
                            'rank': entry['rank'],
                            'points': entry['points'],
                            'avg_rating': entry['avg_rating'],
                            'badge': entry['badge'],
                            'resolved_tasks': entry['resolved_tasks'],  # Monthly
                            'total_tasks': entry['total_tasks'],  # All-time
                            'worker_name': entry['worker_name'],
                            'worker_email': entry['worker_email'],
                            'profile_image': entry['profile_image'],
                        }
                        break
                
                # If not found in leaderboard, create stats with user info
                if current_user_stats is None:
                    from reports.models import Report
                    total_all_time_tasks = Report.objects.filter(
                        worker=request.user,
                        status='Resolved'
                    ).count()
                    total_all_time_points = total_all_time_tasks * 5
                    
                    # Get monthly stats if available
                    try:
                        monthly_stat = WorkerMonthlyStats.objects.get(
                            worker=request.user,
                            month_year=month_year
                        )
                        current_user_stats = {
                            'rank': None,  # Not ranked (not in top workers)
                            'points': total_all_time_points,  # All-time points
                            'avg_rating': float(monthly_stat.avg_rating),
                            'badge': monthly_stat.badge,
                            'resolved_tasks': monthly_stat.resolved_tasks,  # Monthly
                            'total_tasks': total_all_time_tasks,  # All-time
                            'worker_name': request.user.name,
                            'worker_email': request.user.email,
                            'profile_image': request.user.profile_image.url if request.user.profile_image else None,
                        }
                    except WorkerMonthlyStats.DoesNotExist:
                        # No monthly stats yet, use all-time data only
                        current_user_stats = {
                            'rank': None,
                            'points': total_all_time_points,
                            'avg_rating': 0.0,
                            'badge': 'None',
                            'resolved_tasks': 0,
                            'total_tasks': total_all_time_tasks,
                            'worker_name': request.user.name,
                            'worker_email': request.user.email,
                            'profile_image': request.user.profile_image.url if request.user.profile_image else None,
                        }
            except Exception as e:
                # Log error but still try to return basic user info
                import logging
                logger = logging.getLogger(__name__)
                logger.error(f'Error getting current user stats: {e}')
                # Still create basic stats with user info even if there's an error
                try:
                    from reports.models import Report
                    total_all_time_tasks = Report.objects.filter(
                        worker=request.user,
                        status='Resolved'
                    ).count()
                    total_all_time_points = total_all_time_tasks * 5
                    current_user_stats = {
                        'rank': None,
                        'points': total_all_time_points,
                        'avg_rating': 0.0,
                        'badge': 'None',
                        'resolved_tasks': 0,
                        'total_tasks': total_all_time_tasks,
                        'worker_name': request.user.name if hasattr(request.user, 'name') else 'Worker',
                        'worker_email': request.user.email if hasattr(request.user, 'email') else '',
                        'profile_image': request.user.profile_image.url if hasattr(request.user, 'profile_image') and request.user.profile_image else None,
                    }
                except Exception:
                    # If even basic info fails, at least return name
                    current_user_stats = {
                        'rank': None,
                        'points': 0,
                        'avg_rating': 0.0,
                        'badge': 'None',
                        'resolved_tasks': 0,
                        'total_tasks': 0,
                        'worker_name': getattr(request.user, 'name', 'Worker'),
                        'worker_email': getattr(request.user, 'email', ''),
                        'profile_image': None,
                    }
        
        return Response({
            'month_year': month_year,
            'total_workers': len(leaderboard_data),
            'leaderboard': leaderboard_data,
            'current_user_stats': current_user_stats,
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
