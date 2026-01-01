from django.contrib import admin
from .models import UserMonthlyStats, WorkerMonthlyStats, Feedback


@admin.register(WorkerMonthlyStats)
class WorkerMonthlyStatsAdmin(admin.ModelAdmin):
    """Admin interface for WorkerMonthlyStats"""
    
    list_display = ['stat_id', 'worker', 'month_year', 'resolved_tasks', 'points', 'avg_rating', 'badge', 'updated_at']
    list_filter = ['month_year', 'badge', 'updated_at']
    search_fields = ['worker__email', 'worker__name', 'month_year']
    readonly_fields = ['stat_id', 'updated_at']
    ordering = ['-month_year', '-points']
    
    fieldsets = (
        ('Worker Information', {
            'fields': ('worker',)
        }),
        ('Monthly Stats', {
            'fields': ('month_year', 'resolved_tasks', 'points', 'avg_rating', 'badge')
        }),
        ('Metadata', {
            'fields': ('stat_id', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(Feedback)
class FeedbackAdmin(admin.ModelAdmin):
    """Admin interface for Feedback"""
    
    list_display = ['feedback_id', 'report', 'citizen', 'worker', 'rating', 'created_at']
    list_filter = ['rating', 'created_at']
    search_fields = ['report__report_id', 'citizen__email', 'worker__email', 'comment']
    readonly_fields = ['feedback_id', 'created_at', 'updated_at']
    ordering = ['-created_at']
    
    fieldsets = (
        ('Feedback Information', {
            'fields': ('report', 'citizen', 'worker', 'rating', 'comment')
        }),
        ('Metadata', {
            'fields': ('feedback_id', 'created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(UserMonthlyStats)
class UserMonthlyStatsAdmin(admin.ModelAdmin):
    """Admin interface for UserMonthlyStats"""
    
    list_display = ['stat_id', 'user', 'month_year', 'monthly_rank', 'verified_reports', 'badge', 'updated_at']
    list_filter = ['month_year', 'badge', 'updated_at']
    search_fields = ['user__email', 'user__name', 'month_year']
    readonly_fields = ['stat_id', 'updated_at']
    ordering = ['-month_year', 'monthly_rank']
    
    fieldsets = (
        ('User Information', {
            'fields': ('user',)
        }),
        ('Monthly Stats', {
            'fields': ('month_year', 'verified_reports', 'monthly_rank', 'badge')
        }),
        ('Metadata', {
            'fields': ('stat_id', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
