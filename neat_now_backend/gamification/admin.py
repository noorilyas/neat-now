from django.contrib import admin
from .models import UserMonthlyStats


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
