from django.urls import path
from . import views

app_name = 'reports'

urlpatterns = [
    # Create report
    path('create/', views.create_report_view, name='create-report'),
    
    # List reports
    path('', views.ReportListView.as_view(), name='list-reports'),
    
    # Report detail
    path('<int:report_id>/', views.ReportDetailView.as_view(), name='report-detail'),
    
    # Update report (for workers/admin)
    path('<int:report_id>/update/', views.ReportUpdateView.as_view(), name='update-report'),
    
    # Accept/Reject report (for workers)
    path('<int:report_id>/accept/', views.accept_report_view, name='accept-report'),
    path('<int:report_id>/reject/', views.reject_report_view, name='reject-report'),
    
    # Resolve report (for workers - with image upload)
    path('<int:report_id>/resolve/', views.resolve_report_view, name='resolve-report'),
]

