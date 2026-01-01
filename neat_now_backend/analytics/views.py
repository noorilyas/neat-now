from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from django.db.models import Count, Q, Avg, F, Sum
from django.db.models.functions import TruncDate, TruncWeek, TruncMonth
from django.http import HttpResponse
from datetime import timedelta, datetime
from collections import defaultdict
import csv
import io
import json

try:
    from reportlab.lib import colors
    from reportlab.lib.pagesizes import letter, A4
    from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import inch
    REPORTLAB_AVAILABLE = True
except ImportError:
    REPORTLAB_AVAILABLE = False

try:
    from openpyxl import Workbook
    from openpyxl.styles import Font, Alignment, PatternFill
    OPENPYXL_AVAILABLE = True
except ImportError:
    OPENPYXL_AVAILABLE = False

try:
    from PIL import Image, ImageDraw, ImageFont
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

from reports.models import Report
from gamification.models import Feedback, WorkerMonthlyStats


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def worker_analytics_view(request):
    """
    Get analytics data for the authenticated worker
    GET /api/analytics/worker/
    
    Returns comprehensive analytics including:
    - Total, resolved, pending, in-progress reports
    - Weekly/daily activity data
    - Waste type distribution
    - Top locations
    - Performance metrics (efficiency, response time, ratings)
    - Reports over time
    """
    try:
        user = request.user
        
        # Verify user is a worker
        if user.role != 'Worker':
            return Response({
                'error': 'This endpoint is only available for workers'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Get all reports assigned to this worker
        worker_reports = Report.objects.filter(worker=user).exclude(status='Rejected')
        
        # Calculate date ranges
        now = timezone.now()
        week_ago = now - timedelta(days=7)
        month_ago = now - timedelta(days=30)
        year_ago = now - timedelta(days=365)
        
        # ==================== BASIC STATS ====================
        total_reports = worker_reports.count()
        resolved_reports = worker_reports.filter(status='Resolved').count()
        pending_reports = worker_reports.filter(status__in=['Pending', 'Assigned']).count()
        in_progress_reports = worker_reports.filter(status='In Progress').count()
        
        # ==================== WASTE DISTRIBUTION ====================
        waste_distribution = defaultdict(int)
        waste_type_counts = worker_reports.filter(
            status='Resolved'
        ).values('waste_type').annotate(
            count=Count('report_id')
        )
        
        for item in waste_type_counts:
            waste_type = item['waste_type'] or 'Other'
            # Normalize waste type names
            if 'plastic' in waste_type.lower():
                waste_distribution['Plastic Waste'] += item['count']
            elif 'organic' in waste_type.lower() or 'food' in waste_type.lower():
                waste_distribution['Organic Waste'] += item['count']
            elif 'electronic' in waste_type.lower() or 'e-waste' in waste_type.lower():
                waste_distribution['Electronic Waste'] += item['count']
            elif 'hazardous' in waste_type.lower() or 'chemical' in waste_type.lower():
                waste_distribution['Hazardous Waste'] += item['count']
            elif 'construction' in waste_type.lower() or 'debris' in waste_type.lower():
                waste_distribution['Construction Debris'] += item['count']
            elif 'medical' in waste_type.lower():
                waste_distribution['Medical Waste'] += item['count']
            elif 'mixed' in waste_type.lower():
                waste_distribution['Mixed Waste'] += item['count']
            else:
                waste_distribution['Other'] += item['count']
        
        # ==================== TOP LOCATIONS ====================
        # Group by approximate location (rounded coordinates)
        # Get all resolved reports with coordinates
        resolved_with_coords = worker_reports.filter(
            status='Resolved',
            latitude__isnull=False,
            longitude__isnull=False
        )
        
        # Group by rounded coordinates manually
        location_groups = defaultdict(int)
        for report in resolved_with_coords:
            # Round to 2 decimal places (approximately 1km precision)
            lat_rounded = round(float(report.latitude), 2)
            lng_rounded = round(float(report.longitude), 2)
            location_groups[(lat_rounded, lng_rounded)] += 1
        
        # Sort by count and get top 5
        sorted_locations = sorted(location_groups.items(), key=lambda x: x[1], reverse=True)[:5]
        
        top_locations = []
        for idx, ((lat, lng), count) in enumerate(sorted_locations):
            top_locations.append({
                'name': f'Location {idx + 1} ({lat}, {lng})',
                'reports': count
            })
        
        # ==================== DAILY ACTIVITY (Last 7 days) ====================
        daily_resolved = [0] * 7
        daily_reported = [0] * 7
        
        # Get resolved reports by day (last 7 days)
        resolved_by_day = worker_reports.filter(
            status='Resolved',
            resolved_at__gte=week_ago
        ).annotate(
            day=TruncDate('resolved_at')
        ).values('day').annotate(
            count=Count('report_id')
        )
        
        # Get all reports submitted in last 7 days (for comparison)
        reported_by_day = Report.objects.filter(
            submitted_at__gte=week_ago
        ).annotate(
            day=TruncDate('submitted_at')
        ).values('day').annotate(
            count=Count('report_id')
        )
        
        # Map to last 7 days
        today = now.date()
        for i in range(7):
            day = today - timedelta(days=6-i)
            # Find resolved count for this day
            resolved_count = next(
                (item['count'] for item in resolved_by_day if item['day'] == day),
                0
            )
            daily_resolved[i] = resolved_count
            
            # Find reported count for this day
            reported_count = next(
                (item['count'] for item in reported_by_day if item['day'] == day),
                0
            )
            daily_reported[i] = reported_count
        
        # ==================== REPORTS OVER TIME (Last 6 months) ====================
        # Get monthly resolved reports for last 6 months
        monthly_data = []
        monthly_labels = []
        
        for i in range(5, -1, -1):  # Last 6 months
            month_start = (now - timedelta(days=30*i)).replace(day=1, hour=0, minute=0, second=0, microsecond=0)
            month_end = (month_start + timedelta(days=32)).replace(day=1) - timedelta(days=1)
            
            count = worker_reports.filter(
                status='Resolved',
                resolved_at__gte=month_start,
                resolved_at__lte=month_end
            ).count()
            
            monthly_data.append(count)
            monthly_labels.append(month_start.strftime('%b'))
        
        # ==================== PERFORMANCE METRICS ====================
        # Calculate efficiency score (resolved / total * 100)
        efficiency_score = (resolved_reports / total_reports * 100) if total_reports > 0 else 0
        
        # Calculate average response time (time from assignment to resolution)
        resolved_with_times = worker_reports.filter(
            status='Resolved',
            resolved_at__isnull=False,
            accepted_at__isnull=False
        )
        
        avg_response_time_hours = 0
        if resolved_with_times.exists():
            total_hours = 0
            count = 0
            for report in resolved_with_times:
                if report.resolved_at and report.accepted_at:
                    delta = report.resolved_at - report.accepted_at
                    total_hours += delta.total_seconds() / 3600
                    count += 1
            avg_response_time_hours = total_hours / count if count > 0 else 0
        
        # Get average rating from feedback
        avg_rating = Feedback.objects.filter(
            worker=user
        ).aggregate(
            avg=Avg('rating')
        )['avg'] or 0
        
        # Calculate completion rate
        completion_rate = (resolved_reports / total_reports * 100) if total_reports > 0 else 0
        
        # Calculate growth rate (current month vs previous month)
        current_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        prev_month_start = (current_month_start - timedelta(days=32)).replace(day=1)
        prev_month_end = current_month_start - timedelta(days=1)
        
        current_month_resolved = worker_reports.filter(
            status='Resolved',
            resolved_at__gte=current_month_start
        ).count()
        
        prev_month_resolved = worker_reports.filter(
            status='Resolved',
            resolved_at__gte=prev_month_start,
            resolved_at__lte=prev_month_end
        ).count()
        
        growth_rate = 0
        if prev_month_resolved > 0:
            growth_rate = ((current_month_resolved - prev_month_resolved) / prev_month_resolved) * 100
        
        # ==================== BUILD RESPONSE ====================
        response_data = {
            'total_reports': total_reports,
            'resolved_reports': resolved_reports,
            'pending_reports': pending_reports,
            'in_progress_reports': in_progress_reports,
            'resolution_rate': round(completion_rate, 1),
            'growth_rate': round(growth_rate, 1),
            'avg_resolution_time_hours': round(avg_response_time_hours, 1),
            'reports_over_time': {
                'labels': monthly_labels,
                'data': monthly_data,
            },
            'waste_distribution': dict(waste_distribution),
            'top_locations': top_locations,
            'daily_activity': {
                'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                'resolved': daily_resolved,
                'reported': daily_reported,
            },
            'performance_metrics': {
                'efficiency_score': round(efficiency_score, 1),
                'response_time_avg': round(avg_response_time_hours, 1),
                'customer_satisfaction': round(float(avg_rating), 1),
                'tasks_per_day_avg': round(resolved_reports / 30.0, 1) if resolved_reports > 0 else 0,
            },
            'monthly_comparison': {
                'current_month': current_month_resolved,
                'previous_month': prev_month_resolved,
                'change_percentage': round(growth_rate, 1),
            },
        }
        
        return Response(response_data, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({
            'error': f'Failed to load analytics: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


def _get_analytics_data(user):
    """Helper function to get analytics data for a worker"""
    worker_reports = Report.objects.filter(worker=user).exclude(status='Rejected')
    
    now = timezone.now()
    week_ago = now - timedelta(days=7)
    month_ago = now - timedelta(days=30)
    
    total_reports = worker_reports.count()
    resolved_reports = worker_reports.filter(status='Resolved').count()
    pending_reports = worker_reports.filter(status__in=['Pending', 'Assigned']).count()
    in_progress_reports = worker_reports.filter(status='In Progress').count()
    
    # Waste distribution
    waste_distribution = defaultdict(int)
    waste_type_counts = worker_reports.filter(
        status='Resolved'
    ).values('waste_type').annotate(count=Count('report_id'))
    
    for item in waste_type_counts:
        waste_type = item['waste_type'] or 'Other'
        if 'plastic' in waste_type.lower():
            waste_distribution['Plastic Waste'] += item['count']
        elif 'organic' in waste_type.lower() or 'food' in waste_type.lower():
            waste_distribution['Organic Waste'] += item['count']
        elif 'electronic' in waste_type.lower() or 'e-waste' in waste_type.lower():
            waste_distribution['Electronic Waste'] += item['count']
        elif 'hazardous' in waste_type.lower() or 'chemical' in waste_type.lower():
            waste_distribution['Hazardous Waste'] += item['count']
        elif 'construction' in waste_type.lower() or 'debris' in waste_type.lower():
            waste_distribution['Construction Debris'] += item['count']
        elif 'medical' in waste_type.lower():
            waste_distribution['Medical Waste'] += item['count']
        elif 'mixed' in waste_type.lower():
            waste_distribution['Mixed Waste'] += item['count']
        else:
            waste_distribution['Other'] += item['count']
    
    # Top locations
    resolved_with_coords = worker_reports.filter(
        status='Resolved',
        latitude__isnull=False,
        longitude__isnull=False
    )
    
    location_groups = defaultdict(int)
    for report in resolved_with_coords:
        lat_rounded = round(float(report.latitude), 2)
        lng_rounded = round(float(report.longitude), 2)
        location_groups[(lat_rounded, lng_rounded)] += 1
    
    sorted_locations = sorted(location_groups.items(), key=lambda x: x[1], reverse=True)[:5]
    top_locations = []
    for idx, ((lat, lng), count) in enumerate(sorted_locations):
        top_locations.append({
            'name': f'Location {idx + 1} ({lat}, {lng})',
            'reports': count
        })
    
    # Performance metrics
    efficiency_score = (resolved_reports / total_reports * 100) if total_reports > 0 else 0
    
    resolved_with_times = worker_reports.filter(
        status='Resolved',
        resolved_at__isnull=False,
        accepted_at__isnull=False
    )
    
    avg_response_time_hours = 0
    if resolved_with_times.exists():
        total_hours = 0
        count = 0
        for report in resolved_with_times:
            if report.resolved_at and report.accepted_at:
                delta = report.resolved_at - report.accepted_at
                total_hours += delta.total_seconds() / 3600
                count += 1
        avg_response_time_hours = total_hours / count if count > 0 else 0
    
    avg_rating = Feedback.objects.filter(worker=user).aggregate(avg=Avg('rating'))['avg'] or 0
    completion_rate = (resolved_reports / total_reports * 100) if total_reports > 0 else 0
    
    # Monthly comparison
    current_month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    prev_month_start = (current_month_start - timedelta(days=32)).replace(day=1)
    prev_month_end = current_month_start - timedelta(days=1)
    
    current_month_resolved = worker_reports.filter(
        status='Resolved',
        resolved_at__gte=current_month_start
    ).count()
    
    prev_month_resolved = worker_reports.filter(
        status='Resolved',
        resolved_at__gte=prev_month_start,
        resolved_at__lte=prev_month_end
    ).count()
    
    growth_rate = 0
    if prev_month_resolved > 0:
        growth_rate = ((current_month_resolved - prev_month_resolved) / prev_month_resolved) * 100
    
    return {
        'worker_name': user.name,
        'total_reports': total_reports,
        'resolved_reports': resolved_reports,
        'pending_reports': pending_reports,
        'in_progress_reports': in_progress_reports,
        'resolution_rate': round(completion_rate, 1),
        'growth_rate': round(growth_rate, 1),
        'avg_resolution_time_hours': round(avg_response_time_hours, 1),
        'waste_distribution': dict(waste_distribution),
        'top_locations': top_locations,
        'performance_metrics': {
            'efficiency_score': round(efficiency_score, 1),
            'response_time_avg': round(avg_response_time_hours, 1),
            'customer_satisfaction': round(float(avg_rating), 1),
        },
        'monthly_comparison': {
            'current_month': current_month_resolved,
            'previous_month': prev_month_resolved,
            'change_percentage': round(growth_rate, 1),
        },
    }


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def export_analytics_csv(request):
    """Export analytics data as CSV"""
    try:
        user = request.user
        
        if user.role != 'Worker':
            return Response({
                'error': 'This endpoint is only available for workers'
            }, status=status.HTTP_403_FORBIDDEN)
        
        data = _get_analytics_data(user)
        
        # Create CSV response
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = f'attachment; filename="analytics_{user.name}_{timezone.now().strftime("%Y%m%d")}.csv"'
        
        writer = csv.writer(response)
        
        # Write header
        writer.writerow(['Worker Analytics Report'])
        writer.writerow(['Generated:', timezone.now().strftime('%Y-%m-%d %H:%M:%S')])
        writer.writerow(['Worker:', data['worker_name']])
        writer.writerow([])
        
        # Write stats
        writer.writerow(['Statistics'])
        writer.writerow(['Total Reports', data['total_reports']])
        writer.writerow(['Resolved Reports', data['resolved_reports']])
        writer.writerow(['Pending Reports', data['pending_reports']])
        writer.writerow(['In Progress Reports', data['in_progress_reports']])
        writer.writerow(['Resolution Rate (%)', data['resolution_rate']])
        writer.writerow(['Growth Rate (%)', data['growth_rate']])
        writer.writerow(['Avg Resolution Time (hours)', data['avg_resolution_time_hours']])
        writer.writerow([])
        
        # Write performance metrics
        writer.writerow(['Performance Metrics'])
        writer.writerow(['Efficiency Score (%)', data['performance_metrics']['efficiency_score']])
        writer.writerow(['Response Time Avg (hours)', data['performance_metrics']['response_time_avg']])
        writer.writerow(['Customer Satisfaction', data['performance_metrics']['customer_satisfaction']])
        writer.writerow([])
        
        # Write waste distribution
        writer.writerow(['Waste Distribution'])
        writer.writerow(['Waste Type', 'Count'])
        for waste_type, count in data['waste_distribution'].items():
            writer.writerow([waste_type, count])
        writer.writerow([])
        
        # Write top locations
        writer.writerow(['Top Locations'])
        writer.writerow(['Location', 'Reports'])
        for location in data['top_locations']:
            writer.writerow([location['name'], location['reports']])
        writer.writerow([])
        
        # Write monthly comparison
        writer.writerow(['Monthly Comparison'])
        writer.writerow(['Current Month', data['monthly_comparison']['current_month']])
        writer.writerow(['Previous Month', data['monthly_comparison']['previous_month']])
        writer.writerow(['Change (%)', data['monthly_comparison']['change_percentage']])
        
        return response
    
    except Exception as e:
        return Response({
            'error': f'Failed to export CSV: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def export_analytics_excel(request):
    """Export analytics data as Excel"""
    try:
        if not OPENPYXL_AVAILABLE:
            return Response({
                'error': 'Excel export requires openpyxl library'
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        
        user = request.user
        
        if user.role != 'Worker':
            return Response({
                'error': 'This endpoint is only available for workers'
            }, status=status.HTTP_403_FORBIDDEN)
        
        data = _get_analytics_data(user)
        
        # Create workbook
        wb = Workbook()
        ws = wb.active
        ws.title = "Analytics Report"
        
        # Header style
        header_fill = PatternFill(start_color="2AC2AB", end_color="2AC2AB", fill_type="solid")
        header_font = Font(bold=True, color="FFFFFF", size=12)
        
        # Title
        ws['A1'] = 'Worker Analytics Report'
        ws['A1'].font = Font(bold=True, size=16)
        ws.merge_cells('A1:B1')
        
        ws['A2'] = f'Generated: {timezone.now().strftime("%Y-%m-%d %H:%M:%S")}'
        ws['A3'] = f'Worker: {data["worker_name"]}'
        
        row = 5
        
        # Statistics
        ws[f'A{row}'] = 'Statistics'
        ws[f'A{row}'].font = header_font
        ws[f'A{row}'].fill = header_fill
        ws.merge_cells(f'A{row}:B{row}')
        row += 1
        
        stats = [
            ['Total Reports', data['total_reports']],
            ['Resolved Reports', data['resolved_reports']],
            ['Pending Reports', data['pending_reports']],
            ['In Progress Reports', data['in_progress_reports']],
            ['Resolution Rate (%)', data['resolution_rate']],
            ['Growth Rate (%)', data['growth_rate']],
            ['Avg Resolution Time (hours)', data['avg_resolution_time_hours']],
        ]
        
        for stat in stats:
            ws[f'A{row}'] = stat[0]
            ws[f'B{row}'] = stat[1]
            row += 1
        
        row += 1
        
        # Performance Metrics
        ws[f'A{row}'] = 'Performance Metrics'
        ws[f'A{row}'].font = header_font
        ws[f'A{row}'].fill = header_fill
        ws.merge_cells(f'A{row}:B{row}')
        row += 1
        
        perf_metrics = [
            ['Efficiency Score (%)', data['performance_metrics']['efficiency_score']],
            ['Response Time Avg (hours)', data['performance_metrics']['response_time_avg']],
            ['Customer Satisfaction', data['performance_metrics']['customer_satisfaction']],
        ]
        
        for metric in perf_metrics:
            ws[f'A{row}'] = metric[0]
            ws[f'B{row}'] = metric[1]
            row += 1
        
        row += 1
        
        # Waste Distribution
        ws[f'A{row}'] = 'Waste Distribution'
        ws[f'A{row}'].font = header_font
        ws[f'A{row}'].fill = header_fill
        ws.merge_cells(f'A{row}:B{row}')
        row += 1
        
        ws[f'A{row}'] = 'Waste Type'
        ws[f'B{row}'] = 'Count'
        ws[f'A{row}'].font = Font(bold=True)
        ws[f'B{row}'].font = Font(bold=True)
        row += 1
        
        for waste_type, count in data['waste_distribution'].items():
            ws[f'A{row}'] = waste_type
            ws[f'B{row}'] = count
            row += 1
        
        row += 1
        
        # Top Locations
        ws[f'A{row}'] = 'Top Locations'
        ws[f'A{row}'].font = header_font
        ws[f'A{row}'].fill = header_fill
        ws.merge_cells(f'A{row}:B{row}')
        row += 1
        
        ws[f'A{row}'] = 'Location'
        ws[f'B{row}'] = 'Reports'
        ws[f'A{row}'].font = Font(bold=True)
        ws[f'B{row}'].font = Font(bold=True)
        row += 1
        
        for location in data['top_locations']:
            ws[f'A{row}'] = location['name']
            ws[f'B{row}'] = location['reports']
            row += 1
        
        # Adjust column widths
        ws.column_dimensions['A'].width = 30
        ws.column_dimensions['B'].width = 20
        
        # Create response
        response = HttpResponse(
            content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        response['Content-Disposition'] = f'attachment; filename="analytics_{user.name}_{timezone.now().strftime("%Y%m%d")}.xlsx"'
        
        wb.save(response)
        return response
    
    except Exception as e:
        return Response({
            'error': f'Failed to export Excel: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def export_analytics_pdf(request):
    """Export analytics data as PDF"""
    try:
        if not REPORTLAB_AVAILABLE:
            return Response({
                'error': 'PDF export requires reportlab library'
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        
        user = request.user
        
        if user.role != 'Worker':
            return Response({
                'error': 'This endpoint is only available for workers'
            }, status=status.HTTP_403_FORBIDDEN)
        
        data = _get_analytics_data(user)
        
        # Create PDF buffer
        buffer = io.BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=A4)
        elements = []
        styles = getSampleStyleSheet()
        
        # Title
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            textColor=colors.HexColor('#2AC2AB'),
            spaceAfter=30,
        )
        elements.append(Paragraph('Worker Analytics Report', title_style))
        elements.append(Spacer(1, 0.2*inch))
        
        # Info
        info_style = styles['Normal']
        elements.append(Paragraph(f'<b>Generated:</b> {timezone.now().strftime("%Y-%m-%d %H:%M:%S")}', info_style))
        elements.append(Paragraph(f'<b>Worker:</b> {data["worker_name"]}', info_style))
        elements.append(Spacer(1, 0.3*inch))
        
        # Statistics Table
        stats_data = [
            ['Metric', 'Value'],
            ['Total Reports', str(data['total_reports'])],
            ['Resolved Reports', str(data['resolved_reports'])],
            ['Pending Reports', str(data['pending_reports'])],
            ['In Progress Reports', str(data['in_progress_reports'])],
            ['Resolution Rate (%)', f"{data['resolution_rate']}%"],
            ['Growth Rate (%)', f"{data['growth_rate']}%"],
            ['Avg Resolution Time (hours)', str(data['avg_resolution_time_hours'])],
        ]
        
        stats_table = Table(stats_data, colWidths=[4*inch, 2*inch])
        stats_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#2AC2AB')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 12),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ]))
        elements.append(Paragraph('<b>Statistics</b>', styles['Heading2']))
        elements.append(stats_table)
        elements.append(Spacer(1, 0.3*inch))
        
        # Performance Metrics
        perf_data = [
            ['Metric', 'Value'],
            ['Efficiency Score (%)', f"{data['performance_metrics']['efficiency_score']}%"],
            ['Response Time Avg (hours)', str(data['performance_metrics']['response_time_avg'])],
            ['Customer Satisfaction', str(data['performance_metrics']['customer_satisfaction'])],
        ]
        
        perf_table = Table(perf_data, colWidths=[4*inch, 2*inch])
        perf_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#2AC2AB')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 12),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ]))
        elements.append(Paragraph('<b>Performance Metrics</b>', styles['Heading2']))
        elements.append(perf_table)
        elements.append(Spacer(1, 0.3*inch))
        
        # Waste Distribution
        waste_data = [['Waste Type', 'Count']]
        for waste_type, count in data['waste_distribution'].items():
            waste_data.append([waste_type, str(count)])
        
        waste_table = Table(waste_data, colWidths=[4*inch, 2*inch])
        waste_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#2AC2AB')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 12),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
            ('GRID', (0, 0), (-1, -1), 1, colors.black),
        ]))
        elements.append(Paragraph('<b>Waste Distribution</b>', styles['Heading2']))
        elements.append(waste_table)
        
        # Build PDF
        doc.build(elements)
        buffer.seek(0)
        
        # Create response
        response = HttpResponse(buffer.read(), content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="analytics_{user.name}_{timezone.now().strftime("%Y%m%d")}.pdf"'
        return response
    
    except Exception as e:
        return Response({
            'error': f'Failed to export PDF: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def export_analytics_image(request):
    """Export analytics data as Image (PNG)"""
    try:
        if not PIL_AVAILABLE:
            return Response({
                'error': 'Image export requires Pillow library'
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
        
        user = request.user
        
        if user.role != 'Worker':
            return Response({
                'error': 'This endpoint is only available for workers'
            }, status=status.HTTP_403_FORBIDDEN)
        
        data = _get_analytics_data(user)
        
        # Create image
        img_width = 800
        img_height = 1200
        img = Image.new('RGB', (img_width, img_height), color='white')
        draw = ImageDraw.Draw(img)
        
        # Try to use a font, fallback to default if not available
        try:
            font_large = ImageFont.truetype("arial.ttf", 32)
            font_medium = ImageFont.truetype("arial.ttf", 24)
            font_small = ImageFont.truetype("arial.ttf", 18)
        except:
            font_large = ImageFont.load_default()
            font_medium = ImageFont.load_default()
            font_small = ImageFont.load_default()
        
        y = 30
        
        # Title
        draw.text((img_width//2, y), 'Worker Analytics Report', fill='#2AC2AB', font=font_large, anchor='mt')
        y += 60
        
        # Info
        draw.text((50, y), f'Generated: {timezone.now().strftime("%Y-%m-%d %H:%M:%S")}', fill='black', font=font_small)
        y += 30
        draw.text((50, y), f'Worker: {data["worker_name"]}', fill='black', font=font_small)
        y += 50
        
        # Statistics
        draw.text((50, y), 'Statistics', fill='#2AC2AB', font=font_medium)
        y += 40
        
        stats = [
            f'Total Reports: {data["total_reports"]}',
            f'Resolved Reports: {data["resolved_reports"]}',
            f'Pending Reports: {data["pending_reports"]}',
            f'In Progress Reports: {data["in_progress_reports"]}',
            f'Resolution Rate: {data["resolution_rate"]}%',
            f'Growth Rate: {data["growth_rate"]}%',
            f'Avg Resolution Time: {data["avg_resolution_time_hours"]} hours',
        ]
        
        for stat in stats:
            draw.text((70, y), stat, fill='black', font=font_small)
            y += 30
        
        y += 20
        
        # Performance Metrics
        draw.text((50, y), 'Performance Metrics', fill='#2AC2AB', font=font_medium)
        y += 40
        
        perf_metrics = [
            f'Efficiency Score: {data["performance_metrics"]["efficiency_score"]}%',
            f'Response Time Avg: {data["performance_metrics"]["response_time_avg"]} hours',
            f'Customer Satisfaction: {data["performance_metrics"]["customer_satisfaction"]}',
        ]
        
        for metric in perf_metrics:
            draw.text((70, y), metric, fill='black', font=font_small)
            y += 30
        
        y += 20
        
        # Waste Distribution
        draw.text((50, y), 'Waste Distribution', fill='#2AC2AB', font=font_medium)
        y += 40
        
        for waste_type, count in list(data['waste_distribution'].items())[:10]:  # Limit to 10
            draw.text((70, y), f'{waste_type}: {count}', fill='black', font=font_small)
            y += 30
        
        # Save to buffer
        buffer = io.BytesIO()
        img.save(buffer, format='PNG')
        buffer.seek(0)
        
        # Create response
        response = HttpResponse(buffer.read(), content_type='image/png')
        response['Content-Disposition'] = f'attachment; filename="analytics_{user.name}_{timezone.now().strftime("%Y%m%d")}.png"'
        return response
    
    except Exception as e:
        return Response({
            'error': f'Failed to export Image: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
