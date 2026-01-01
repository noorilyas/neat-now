"""
Script to create notifications for existing pending reports
Run this once to create notifications for reports that were submitted before notification system was implemented
"""
import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'neat_now_backend.settings')
django.setup()

from reports.models import Report
from accounts.models import Account
from notifications.models import Notification


def create_notifications_for_pending_reports():
    """Create notifications for all pending reports"""
    
    # Get all pending reports (not assigned to any worker)
    pending_reports = Report.objects.filter(
        status='Pending',
        worker__isnull=True
    )
    
    # Get all workers
    workers = Account.objects.filter(role='Worker')
    
    if not workers.exists():
        print("❌ No workers found in database!")
        print("   Please create worker accounts first using create_worker_account.py")
        return
    
    notifications_created = 0
    
    for report in pending_reports:
        for worker in workers:
            # Check if notification already exists
            existing = Notification.objects.filter(
                recipient_type='Worker',
                recipient_id=worker.account_id,
                report=report
            ).exists()
            
            if not existing:
                location_text = f'Location: {report.latitude}, {report.longitude}' if report.has_gps_coordinates else 'Location not specified'
                Notification.objects.create(
                    recipient_type='Worker',
                    recipient_id=worker.account_id,
                    message=f'New Task: Waste report #{report.report_id} submitted. {location_text}',
                    report=report
                )
                notifications_created += 1
    
    print(f"✅ Created {notifications_created} notifications for {pending_reports.count()} pending reports")
    print(f"   Workers: {workers.count()}")
    print(f"   Pending Reports: {pending_reports.count()}")


if __name__ == '__main__':
    print("Creating notifications for existing pending reports...")
    create_notifications_for_pending_reports()
    print("Done!")

