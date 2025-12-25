from django.contrib import admin
from .models import Report, ImageStorageLog


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = [
        'report_id',
        'citizen',
        'worker',
        'status',
        'ai_result',
        'waste_type',
        'submitted_at',
        'has_gps_coordinates',
    ]
    list_filter = [
        'status',
        'ai_result',
        'waste_type',
        'submitted_at',
    ]
    search_fields = [
        'report_id',
        'citizen__email',
        'citizen__name',
        'worker__email',
        'worker__name',
    ]
    readonly_fields = [
        'report_id',
        'submitted_at',
        'updated_at',
    ]
    fieldsets = (
        ('Basic Information', {
            'fields': ('report_id', 'citizen', 'worker', 'status')
        }),
        ('AI Analysis', {
            'fields': ('ai_result', 'waste_type', 'ai_confidence')
        }),
        ('Location', {
            'fields': ('latitude', 'longitude')
        }),
        ('Images', {
            'fields': ('image_before', 'image_after')
        }),
        ('Timestamps', {
            'fields': ('submitted_at', 'updated_at', 'resolved_at')
        }),
    )


@admin.register(ImageStorageLog)
class ImageStorageLogAdmin(admin.ModelAdmin):
    """Admin interface for Image Storage Log"""
    list_display = [
        'image_log_id',
        'report',
        'image_type',
        'storage_path',
        'uploaded_at',
    ]
    list_filter = [
        'image_type',
        'uploaded_at',
    ]
    search_fields = [
        'image_log_id',
        'report__report_id',
        'storage_path',
    ]
    readonly_fields = [
        'image_log_id',
        'uploaded_at',
    ]
    date_hierarchy = 'uploaded_at'
    raw_id_fields = ('report',)


