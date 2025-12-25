from django.db import models
from django.utils import timezone
from accounts.models import Account


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
