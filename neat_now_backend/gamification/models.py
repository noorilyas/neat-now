from django.db import models
from django.utils import timezone
from django.core.validators import MinValueValidator, MaxValueValidator
from accounts.models import Account


class WorkerMonthlyStats(models.Model):
    """
    Worker monthly statistics for payroll and awards.
    Tracks resolved tasks, points, ratings, and badges for workers.
    """
    
    BADGE_CHOICES = [
        ('None', 'None'),
        ('Bronze', 'Bronze'),
        ('Silver', 'Silver'),
        ('Gold', 'Gold'),
        ('Diamond', 'Diamond'),
    ]
    
    # Primary key
    stat_id = models.BigAutoField(primary_key=True)
    
    # Foreign key to Account (Worker)
    worker = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='worker_monthly_stats',
        db_column='worker_id',
        limit_choices_to={'role': 'Worker'},
        help_text='The worker being tracked'
    )
    
    # Month-Year (Format: YYYY-MM)
    month_year = models.CharField(
        max_length=7,
        null=False,
        blank=False,
        db_index=True,
        help_text='Format: YYYY-MM (e.g., "2025-12")'
    )
    
    # Resolved tasks count
    resolved_tasks = models.IntegerField(
        default=0,
        help_text='Total tasks completed in that month'
    )
    
    # Points earned (5 points per completed report)
    points = models.IntegerField(
        default=0,
        help_text='Total points earned this month (5 points per completed report)'
    )
    
    # Average rating from citizens
    avg_rating = models.DecimalField(
        max_digits=3,
        decimal_places=2,
        default=0.00,
        validators=[MinValueValidator(0.00), MaxValueValidator(5.00)],
        help_text='Average rating from citizens for that month (0.00 to 5.00)'
    )
    
    # Badge (Diamond, Gold, Silver, Bronze, None)
    badge = models.CharField(
        max_length=10,
        choices=BADGE_CHOICES,
        default='None',
        db_index=True,
        help_text='Badge awarded: None, Bronze, Silver, Gold, Diamond'
    )
    
    # Timestamp
    updated_at = models.DateTimeField(auto_now=True, db_index=True)
    
    class Meta:
        db_table = 'worker_monthly_stats'
        ordering = ['month_year', '-points', '-avg_rating']
        unique_together = [['worker', 'month_year']]  # One stat per worker per month
        indexes = [
            models.Index(fields=['month_year', 'points'], name='gamif_w_month_year_points_idx'),
            models.Index(fields=['month_year', 'avg_rating'], name='gamif_w_month_year_avg_rt_idx'),
            models.Index(fields=['badge', 'month_year'], name='gamif_w_badge_month_year_idx'),
            models.Index(fields=['updated_at'], name='gamif_w_updated_at_idx'),
        ]
        verbose_name = 'Worker Monthly Stat'
        verbose_name_plural = 'Worker Monthly Stats'
    
    def __str__(self):
        return f'{self.worker.email} - {self.month_year} - {self.resolved_tasks} tasks - {self.points} points - {self.badge}'
    
    @staticmethod
    def get_current_month_year():
        """Get current month-year in YYYY-MM format"""
        now = timezone.now()
        return now.strftime('%Y-%m')
    
    @staticmethod
    def update_worker_stats(worker, month_year=None):
        """
        Update or create monthly stats for a worker.
        Recalculates resolved_tasks, points, avg_rating, and updates badge.
        """
        if month_year is None:
            month_year = WorkerMonthlyStats.get_current_month_year()
        
        from datetime import datetime as dt
        from reports.models import Report
        
        start_date = dt.strptime(f'{month_year}-01', '%Y-%m-%d').date()
        # Calculate end date (first day of next month)
        if start_date.month == 12:
            end_date = dt(start_date.year + 1, 1, 1).date()
        else:
            end_date = dt(start_date.year, start_date.month + 1, 1).date()
        
        # Count resolved reports in this month (based on resolved_at timestamp)
        resolved_reports = Report.objects.filter(
            worker=worker,
            status='Resolved',
            resolved_at__gte=timezone.make_aware(dt.combine(start_date, dt.min.time())),
            resolved_at__lt=timezone.make_aware(dt.combine(end_date, dt.min.time()))
        )
        
        resolved_count = resolved_reports.count()
        
        # Calculate points (5 points per completed report)
        points = resolved_count * 5
        
        # Calculate average rating from feedback
        feedbacks = Feedback.objects.filter(
            worker=worker,
            created_at__gte=timezone.make_aware(dt.combine(start_date, dt.min.time())),
            created_at__lt=timezone.make_aware(dt.combine(end_date, dt.min.time()))
        )
        
        avg_rating = 0.00
        if feedbacks.exists():
            total_rating = sum(f.rating for f in feedbacks)
            avg_rating = total_rating / feedbacks.count()
        
        # Get or create stats record
        stats, created = WorkerMonthlyStats.objects.get_or_create(
            worker=worker,
            month_year=month_year,
            defaults={
                'resolved_tasks': resolved_count,
                'points': points,
                'avg_rating': avg_rating
            }
        )
        
        if not created:
            stats.resolved_tasks = resolved_count
            stats.points = points
            stats.avg_rating = avg_rating
            stats.save()
        
        # Recalculate badge based on average rating
        WorkerMonthlyStats.update_badge(stats)
        
        # Refresh stats from database to get updated badge
        stats.refresh_from_db()
        
        return stats
    
    @staticmethod
    def update_badge(stats):
        """
        Update badge based on average rating calculated from feedback.
        Badge is determined by average rating:
        - Diamond: 4.5+ rating (excellent)
        - Gold: 4.0-4.4 rating (very good)
        - Silver: 3.5-3.9 rating (good)
        - Bronze: 3.0-3.4 rating (satisfactory)
        - None: < 3.0 rating or no ratings yet
        """
        avg_rating = float(stats.avg_rating) if stats.avg_rating else 0.0
        
        # Diamond: 4.5+ rating (excellent)
        if avg_rating >= 4.5:
            stats.badge = 'Diamond'
        # Gold: 4.0-4.4 rating (very good)
        elif avg_rating >= 4.0:
            stats.badge = 'Gold'
        # Silver: 3.5-3.9 rating (good)
        elif avg_rating >= 3.5:
            stats.badge = 'Silver'
        # Bronze: 3.0-3.4 rating (satisfactory)
        elif avg_rating >= 3.0:
            stats.badge = 'Bronze'
        else:
            stats.badge = 'None'
        
        stats.save()
    
    @staticmethod
    def award_points_for_resolved_report(worker, report):
        """
        Award 5 points to worker when they resolve a report.
        Updates monthly stats for the current month.
        """
        month_year = WorkerMonthlyStats.get_current_month_year()
        stats, created = WorkerMonthlyStats.objects.get_or_create(
            worker=worker,
            month_year=month_year,
            defaults={
                'resolved_tasks': 0,
                'points': 0,
                'avg_rating': 0.00
            }
        )
        
        # Increment resolved tasks and points
        stats.resolved_tasks += 1
        stats.points += 5
        stats.save()
        
        # Update badge based on new points
        WorkerMonthlyStats.update_badge(stats)
        
        return stats


class Feedback(models.Model):
    """
    User ratings and feedback for completed reports.
    Allows citizens to rate the cleanup quality once a report is marked as 'Resolved'.
    """
    
    # Primary key
    feedback_id = models.BigAutoField(primary_key=True)
    
    # Foreign key to Report (unique - one feedback per report)
    report = models.OneToOneField(
        'reports.Report',
        on_delete=models.CASCADE,
        related_name='feedback',
        db_column='report_id',
        unique=True,
        help_text='Link to a specific completed job'
    )
    
    # Foreign key to Account (Citizen - the rating provider)
    citizen = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='given_feedbacks',
        db_column='citizen_id',
        limit_choices_to={'role': 'Citizen'},
        help_text='ID of the rating provider'
    )
    
    # Foreign key to Account (Worker - the staff being rated)
    worker = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='received_feedbacks',
        db_column='worker_id',
        limit_choices_to={'role': 'Worker'},
        help_text='Staff being rated'
    )
    
    # Rating (1-5 stars)
    rating = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        null=False,
        help_text='Star rating (1-5)'
    )
    
    # Optional comment
    comment = models.TextField(
        null=True,
        blank=True,
        help_text='Optional written feedback'
    )
    
    # Timestamp
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'feedback'
        ordering = ['-created_at']
        # Indexes are already in database (from old feedback app or migration 0003)
        # Not including them in Meta to prevent Django from trying to recreate them
        verbose_name = 'Feedback'
        verbose_name_plural = 'Feedbacks'
    
    def __str__(self):
        return f'Feedback #{self.feedback_id} - Report #{self.report.report_id} - {self.rating} stars by {self.citizen.email}'
    
    @staticmethod
    def create_feedback(report, citizen, rating, comment=None):
        """
        Create feedback for a resolved report.
        Updates worker's average rating in monthly stats.
        """
        # Check if feedback already exists for this report
        if Feedback.objects.filter(report=report).exists():
            raise ValueError(f'Feedback already exists for report #{report.report_id}')
        
        # Verify report is resolved
        if report.status != 'Resolved':
            raise ValueError(f'Cannot create feedback for report #{report.report_id} - report is not resolved')
        
        # Verify citizen is the report owner
        if report.citizen != citizen:
            raise ValueError(f'Citizen {citizen.email} is not the owner of report #{report.report_id}')
        
        # Verify worker is assigned to the report
        if not report.worker:
            raise ValueError(f'Report #{report.report_id} has no assigned worker')
        
        # Create feedback
        feedback = Feedback.objects.create(
            report=report,
            citizen=citizen,
            worker=report.worker,
            rating=rating,
            comment=comment
        )
        
        # Update worker's monthly stats with new rating
        WorkerMonthlyStats.update_worker_stats(report.worker)
        
        # Create notification for worker about the feedback
        from notifications.models import Notification
        comment_text = f' Comment: {comment}' if comment else ''
        Notification.objects.create(
            recipient_type='Worker',
            recipient_id=report.worker.account_id,
            message=f'FEEDBACK: You received a {rating}-star rating for report #{report.report_id}.{comment_text}',
            report=report
        )
        
        return feedback


class UserMonthlyStats(models.Model):
    """
    Gamification table for leaderboard ranking based on resolved reports.
    Tracks monthly statistics and badges for citizens.
    """
    
    BADGE_CHOICES = [
        ('None', 'None'),
        ('Silver', 'Silver'),
        ('Gold', 'Gold'),
        ('Platinum', 'Platinum'),
    ]
    
    # Primary key
    stat_id = models.BigAutoField(primary_key=True)
    
    # Foreign key to Account (Citizen)
    user = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='monthly_stats',
        db_column='user_id',
        limit_choices_to={'role': 'Citizen'},
        help_text='The citizen being ranked'
    )
    
    # Month-Year (Format: YYYY-MM)
    month_year = models.CharField(
        max_length=7,
        null=False,
        blank=False,
        db_index=True,
        help_text='Format: YYYY-MM (e.g., "2025-12")'
    )
    
    # Verified reports count (points earned this month)
    verified_reports = models.IntegerField(
        default=0,
        help_text='Number of resolved reports this month'
    )
    
    # Badge (Top 3 only)
    badge = models.CharField(
        max_length=10,
        choices=BADGE_CHOICES,
        default='None',
        db_index=True,
        help_text='Badge awarded: None, Silver (3rd), Gold (2nd), Platinum (1st)'
    )
    
    # Monthly rank
    monthly_rank = models.IntegerField(
        null=True,
        blank=True,
        db_index=True,
        help_text='Position in leaderboard for this month (1st, 2nd, 3rd, etc.)'
    )
    
    # Timestamp
    updated_at = models.DateTimeField(auto_now=True, db_index=True)
    
    class Meta:
        db_table = 'user_monthly_stats'
        ordering = ['month_year', 'monthly_rank', '-verified_reports']
        unique_together = [['user', 'month_year']]  # One stat per user per month
        indexes = [
            models.Index(fields=['month_year', 'monthly_rank']),
            models.Index(fields=['month_year', 'verified_reports']),
            models.Index(fields=['badge', 'month_year']),
            models.Index(fields=['updated_at']),
        ]
        verbose_name = 'User Monthly Stat'
        verbose_name_plural = 'User Monthly Stats'
    
    def __str__(self):
        return f'{self.user.email} - {self.month_year} - Rank {self.monthly_rank or "N/A"} - {self.badge}'
    
    @staticmethod
    def get_current_month_year():
        """Get current month-year in YYYY-MM format"""
        now = timezone.now()
        return now.strftime('%Y-%m')
    
    @staticmethod
    def update_user_stats(user, month_year=None):
        """
        Update or create monthly stats for a user.
        Recalculates verified_reports count and updates rank/badge.
        """
        if month_year is None:
            month_year = UserMonthlyStats.get_current_month_year()
        
        # Count uploaded reports for this user in this month
        # Count all reports uploaded (submitted) in this month based on submitted_at
        # Later when AI is integrated, we'll count only AI-verified reports
        from datetime import datetime as dt
        from reports.models import Report
        
        start_date = dt.strptime(f'{month_year}-01', '%Y-%m-%d').date()
        # Calculate end date (first day of next month)
        if start_date.month == 12:
            end_date = dt(start_date.year + 1, 1, 1).date()
        else:
            end_date = dt(start_date.year, start_date.month + 1, 1).date()
        
        # Count all uploaded reports in this month (based on submitted_at timestamp)
        # Note: Currently counting all uploaded reports. When AI is integrated, 
        # we'll filter by ai_result='Waste' to count only verified reports
        verified_count = Report.objects.filter(
            citizen=user,
            submitted_at__gte=timezone.make_aware(dt.combine(start_date, dt.min.time())),
            submitted_at__lt=timezone.make_aware(dt.combine(end_date, dt.min.time()))
        ).count()
        
        # Get or create stats record
        stats, created = UserMonthlyStats.objects.get_or_create(
            user=user,
            month_year=month_year,
            defaults={'verified_reports': verified_count}
        )
        
        if not created:
            stats.verified_reports = verified_count
            stats.save()
        
        # Recalculate rankings for this month
        UserMonthlyStats.recalculate_monthly_rankings(month_year)
        
        # Refresh stats from database to get updated rank and badge
        stats.refresh_from_db()
        
        return stats
    
    @staticmethod
    def recalculate_monthly_rankings(month_year=None):
        """
        Recalculate all rankings and badges for a given month.
        Top 3 get badges: 1st=Platinum, 2nd=Gold, 3rd=Silver
        """
        if month_year is None:
            month_year = UserMonthlyStats.get_current_month_year()
        
        # Get all stats for this month, ordered by verified_reports (descending)
        stats_list = UserMonthlyStats.objects.filter(
            month_year=month_year
        ).order_by('-verified_reports', 'updated_at')
        
        # Update ranks and badges
        for index, stat in enumerate(stats_list, start=1):
            stat.monthly_rank = index
            
            # Assign badges to top 3
            if index == 1:
                stat.badge = 'Platinum'
            elif index == 2:
                stat.badge = 'Gold'
            elif index == 3:
                stat.badge = 'Silver'
            else:
                stat.badge = 'None'
            
            stat.save()
