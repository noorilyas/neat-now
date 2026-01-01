from django.urls import path
from . import views

app_name = 'analytics'

urlpatterns = [
    # Worker analytics endpoint
    path('worker/', views.worker_analytics_view, name='worker-analytics'),
    # Export endpoints
    path('export/csv/', views.export_analytics_csv, name='export-csv'),
    path('export/excel/', views.export_analytics_excel, name='export-excel'),
    path('export/pdf/', views.export_analytics_pdf, name='export-pdf'),
    path('export/image/', views.export_analytics_image, name='export-image'),
]

