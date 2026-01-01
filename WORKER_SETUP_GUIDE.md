# Worker Setup Guide

## Step 1: Django Admin se Worker Account Create Karein

### Django Admin Access:
1. Django server start karein:
   ```bash
   cd neat_now_backend
   python manage.py runserver
   ```

2. Browser mein open karein: `http://localhost:8000/admin/`

3. Superuser create karein (agar nahi hai):
   ```bash
   python manage.py createsuperuser
   ```

4. Admin panel mein login karein

5. **Accounts** section mein jayein

6. **Add Account** button click karein

7. Worker account details fill karein:
   - **Email**: `worker@example.com` (unique hona chahiye)
   - **Name**: Worker ka naam
   - **Role**: `Worker` select karein (dropdown se)
   - **Phone Number**: `+92XXXXXXXXXX` format mein
   - **Email Verified**: ✅ Check karein (login ke liye zaroori)
   - **Password**: Django admin mein password directly set nahi hota, isliye:
     - Account save karein
     - Phir account edit karein
     - **Password Hash** field mein Django ka hashed password set karein

### Better Method - Django Shell se:
```bash
python manage.py shell
```

```python
from accounts.models import Account

# Worker account create karein
worker = Account.objects.create(
    email='worker@example.com',
    name='Test Worker',
    role='Worker',
    phone_number='+923001234567',
    email_verified=True  # Important: login ke liye verified hona chahiye
)

# Password set karein
worker.set_password('Worker@123')
worker.save()

print(f"Worker created: {worker.email}")
```

## Step 2: Worker Login Test Karein

### Flutter App mein:
1. Login screen open karein
2. **Worker** toggle select karein
3. Credentials enter karein:
   - Email: `worker@example.com`
   - Password: `Worker@123`
4. Login button click karein

### Demo Mode (Server Off):
- Demo credentials use karein:
  - Email: `worker@demo.com`
  - Password: `Worker@123`

## Step 3: Development Bypass (Login ke bina Worker Panel)

Development ke liye, `flutter/lib/main.dart` file mein bypass add kar diya hai.

### Bypass Enable Karein:
1. `flutter/lib/main.dart` file open karein
2. Line 11 par jayein:
   ```dart
   const bool _bypassLoginForDevelopment = false; // Change to true
   ```
3. `false` ko `true` kar dein:
   ```dart
   const bool _bypassLoginForDevelopment = true; // Development mode
   ```
4. App restart karein - ab direct worker dashboard open hoga!

### ⚠️ Important:
- Production se pehle `false` kar dein
- Sirf development ke liye use karein

## Step 4: Quick Worker Account Creation Script

### Method 1: Python Script (Easiest)
```bash
cd neat_now_backend
python create_worker_account.py
```

### Method 2: Django Shell
```bash
cd neat_now_backend
python manage.py shell
```

Phir ye code run karein:
```python
from accounts.models import Account

# Create worker
worker = Account.objects.create(
    email='worker@example.com',
    name='Test Worker',
    role='Worker',
    phone_number='+923001234567',
    email_verified=True
)
worker.set_password('Worker@123')
worker.save()
print(f"✅ Worker created: {worker.email}")
```

## Step 5: Notification Work

Notification functionality abhi pending hai. Worker panel complete hone ke baad notifications implement karein.

## Summary:

✅ **Django Admin se worker create karein** (Step 1)
✅ **Worker login test karein** (Step 2)  
✅ **Development bypass use karein** (Step 3) - Login ke bina worker panel access
✅ **Notification work baad mein** (Step 5)

