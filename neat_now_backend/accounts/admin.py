from django.contrib import admin
from .models import Account


@admin.register(Account)
class AccountAdmin(admin.ModelAdmin):
    list_display = ['account_id', 'email', 'name', 'role', 'email_verified', 'created_at']
    list_filter = ['role', 'email_verified', 'created_at']
    search_fields = ['email', 'name', 'phone_number']
    readonly_fields = ['account_id', 'created_at', 'updated_at']
    fieldsets = (
        ('Authentication', {
            'fields': ('email', 'password_hash', 'email_verified', 'google_id')
        }),
        ('Profile', {
            'fields': ('name', 'phone_number', 'profile_image', 'role')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
