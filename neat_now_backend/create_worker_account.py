#!/usr/bin/env python
"""
Django Management Script to Create Worker Accounts
Usage: python manage.py shell < create_worker_account.py
Or: python create_worker_account.py (after setting up Django environment)
"""

import os
import sys
import django

# Setup Django environment
if __name__ == '__main__':
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'neat_now_backend.settings')
    django.setup()

from accounts.models import Account

def create_worker_account(email, name, password, phone_number='+923001234567'):
    """
    Create a worker account in the database
    
    Args:
        email: Worker email (must be unique)
        name: Worker name
        password: Worker password
        phone_number: Phone number in +92XXXXXXXXXX format
    """
    try:
        # Check if account already exists
        if Account.objects.filter(email=email).exists():
            print(f"❌ Account with email {email} already exists!")
            return False
        
        # Create worker account
        worker = Account.objects.create(
            email=email.lower().strip(),
            name=name.strip(),
            role='Worker',
            phone_number=phone_number,
            email_verified=True  # Important: Must be verified for login
        )
        
        # Set password
        worker.set_password(password)
        worker.save()
        
        print(f"✅ Worker account created successfully!")
        print(f"   Email: {worker.email}")
        print(f"   Name: {worker.name}")
        print(f"   Role: {worker.role}")
        print(f"   Account ID: {worker.account_id}")
        print(f"   Email Verified: {worker.email_verified}")
        print(f"\n📝 Login Credentials:")
        print(f"   Email: {worker.email}")
        print(f"   Password: {password}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error creating worker account: {e}")
        return False

if __name__ == '__main__':
    # Example: Create a test worker account
    print("=" * 50)
    print("Creating Worker Account")
    print("=" * 50)
    
    # Default test worker (matches Flutter demo credentials)
    create_worker_account(
        email='worker@demo.com',  # Matches Flutter AppCredentials.demoEmployeeEmail
        name='Demo Worker',
        password='Worker@123',    # Matches Flutter AppCredentials.demoEmployeePassword
        phone_number='+923001234567'
    )
    
    print("\n" + "=" * 50)
    print("To create more workers, modify the script or use Django shell:")
    print("python manage.py shell")
    print("=" * 50)
    print("""
from accounts.models import Account

worker = Account.objects.create(
    email='newworker@example.com',
    name='New Worker',
    role='Worker',
    phone_number='+923001234567',
    email_verified=True
)
worker.set_password('YourPassword123')
worker.save()
    """)

