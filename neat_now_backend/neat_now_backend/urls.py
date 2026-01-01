"""
URL configuration for neat_now_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from analytics import views as analytics_views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/accounts/', include('accounts.urls')),
    path('api/reports/', include('reports.urls')),
    path('api/gamification/', include('gamification.urls')),
    path('api/notifications/', include('notifications.urls')),
    path('api/analytics/', include('analytics.urls')),
    # Employee endpoints (aliases for analytics)
    path('api/employee/analytics/', analytics_views.worker_analytics_view, name='employee-analytics'),
    path('api/employee/analytics/export/csv/', analytics_views.export_analytics_csv, name='employee-export-csv'),
    path('api/employee/analytics/export/excel/', analytics_views.export_analytics_excel, name='employee-export-excel'),
    path('api/employee/analytics/export/pdf/', analytics_views.export_analytics_pdf, name='employee-export-pdf'),
    path('api/employee/analytics/export/image/', analytics_views.export_analytics_image, name='employee-export-image'),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
