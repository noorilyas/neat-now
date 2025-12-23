# NeatNow - Project Overview

## 📱 Project Description
**NeatNow** is an AI-powered waste management assistant app that connects citizens with waste management workers to report and clean up waste in their communities.

---

## 🏗️ Architecture

### **Frontend: Flutter Mobile App**
- **Location:** `flutter/`
- **Language:** Dart
- **Framework:** Flutter 3.0+
- **Platforms:** Android, iOS, Web, Windows, Linux, macOS

### **Backend: Django REST API**
- **Location:** `neat_now_backend/`
- **Language:** Python 3.12+
- **Framework:** Django 5.2.9
- **Database:** PostgreSQL (`neat_now_db`)
- **API Style:** RESTful with JWT authentication

---

## 📂 Project Structure

```
neat-now/
├── flutter/                          # Flutter mobile app
│   ├── main.dart                     # App entry point
│   ├── config/                       # Configuration files
│   │   └── credentials.dart          # API URLs, demo accounts, settings
│   ├── design/                       # Design system
│   │   └── user/
│   │       └── user_design_system.dart  # Color palette, themes
│   ├── assets/                       # Images, icons, animations
│   └── screens/                      # UI screens (referenced but may need creation)
│
└── neat_now_backend/                 # Django backend
    ├── manage.py                     # Django management script
    ├── accounts/                     # User authentication app
    │   ├── models.py                 # Account model (Citizen/Worker roles)
    │   ├── views.py                  # API endpoints
    │   ├── serializers.py            # Request/response serializers
    │   ├── urls.py                   # URL routing
    │   └── authentication.py        # JWT authentication
    ├── reports/                      # Waste reports app (placeholder)
    └── neat_now_backend/             # Django project settings
        ├── settings.py               # Django configuration
        └── urls.py                   # Main URL routing
```

---

## 🔐 User Roles

The app supports two main user types:

1. **Citizen** (Default role)
   - Report waste issues
   - Track cleanup progress
   - View community reports

2. **Worker** (Service Worker)
   - View assigned tasks
   - Accept/reject cleanup tasks
   - Upload cleanup verification photos

---

## 🚀 Backend API Endpoints

### **Authentication & Registration**

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/accounts/register/` | Register new account | ❌ |
| POST | `/api/accounts/login/` | Email/password login | ❌ |
| POST | `/api/accounts/google-login/` | Google OAuth login | ❌ |
| POST | `/api/accounts/verify-email/` | Verify email address | ❌ |
| POST | `/api/accounts/resend-verification/` | Resend verification email | ❌ |
| POST | `/api/accounts/forgot-password/` | Request password reset | ❌ |
| POST | `/api/accounts/reset-password/` | Reset password with token | ❌ |

### **Profile Management**

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/accounts/profile/` | Get user profile | ✅ |
| PATCH | `/api/accounts/profile/` | Update profile | ✅ |

---

## 🔑 Authentication System

- **JWT (JSON Web Tokens)** for authentication
- **Access Token:** 30 minutes lifetime
- **Refresh Token:** 7 days lifetime
- **Token Rotation:** Enabled
- **Token Blacklist:** Enabled after rotation

### **JWT Usage:**
```http
Authorization: Bearer YOUR_ACCESS_TOKEN
```

---

## 📊 Database Models

### **Account Model** (`accounts/models.py`)
- `account_id` - Primary key (BigAutoField)
- `email` - Unique email address
- `password_hash` - Hashed password (nullable for Google-only accounts)
- `role` - 'Citizen' or 'Worker'
- `name` - User's full name
- `phone_number` - Optional, format: +92XXXXXXXXXX
- `profile_image` - Optional profile picture
- `google_id` - Google OAuth ID (nullable)
- `email_verified` - Boolean flag
- `created_at`, `updated_at` - Timestamps

---

## 🎨 Flutter App Features

### **Dependencies:**
- `image_picker` - Camera/photo selection
- `geolocator` - Location services
- `permission_handler` - App permissions
- `http` - API communication
- `shared_preferences` - Local storage
- `google_fonts` - Typography
- `fluttertoast` - Toast notifications
- `lottie` - Animations
- `provider` - State management
- `video_player` - Video playback
- `flutter_map` - Map display
- `geocoding` - Address lookup

### **Screens (Referenced in main.dart):**
- `SplashScreen` - App launch screen
- `LoginScreen` - User authentication
- `UserDashboardView` - Citizen dashboard
- `EmployeeDashboard` - Worker dashboard
- `CameraScreen` - Photo/video capture

### **Design System:**
- **Primary Color:** Teal (#2AC2AB)
- **Font:** Poppins (via Google Fonts)
- **Material Design 3:** Enabled

---

## ⚙️ Configuration

### **Backend Settings** (`neat_now_backend/settings.py`)

**Database:**
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'neat_now_db',
        'USER': 'postgres',
        'PASSWORD': 'admin',
        'HOST': 'localhost',
        'PORT': '5432',
    }
}
```

**Email (Development):**
- Currently using console backend (emails print to console)
- Production: Configure SMTP settings

**CORS:**
- Allowed origins: `localhost:3000`, `127.0.0.1:3000`

### **Flutter Configuration** (`flutter/config/credentials.dart`)

**API URLs:**
- Development: `http://10.0.2.2:8000/api` (Android emulator)
- Staging: `https://staging-api.neatnow.com/api`
- Production: `https://api.neatnow.com/api`

**Demo Accounts:**
- Citizen: `citizen@demo.com` / `Demo@123`
- Worker: `worker@demo.com` / `Worker@123`
- Admin: `admin@neatnow.com` / `Admin@123`

**AI Configuration:**
- Waste detection threshold: 0.7
- Cleanup verification threshold: 0.8

---

## 🛠️ Setup Instructions

### **Backend Setup:**
1. Create virtual environment
2. Install dependencies: `pip install -r requirements.txt`
3. Create PostgreSQL database: `neat_now_db`
4. Run migrations: `python manage.py migrate`
5. Create superuser (optional): `python manage.py createsuperuser`
6. Start server: `python manage.py runserver`

### **Flutter Setup:**
1. Install Flutter SDK (3.0+)
2. Install dependencies: `flutter pub get`
3. Configure API URLs in `config/credentials.dart`
4. Run app: `flutter run`

---

## 📝 Current Status

### ✅ **Completed:**
- User registration with email verification
- JWT authentication system
- Google OAuth login
- Password reset flow
- Profile management (GET/PATCH)
- Account model with role-based system
- Email verification system

### 🚧 **In Progress / Pending:**
- Reports app (models not yet defined)
- Flutter screen implementations (referenced but may need creation)
- AI waste detection integration
- Worker task assignment system
- Map integration for location-based features

---

## 🧪 Testing

### **Postman Testing:**
See `neat_now_backend/POSTMAN_QUICK_TEST.md` for detailed API testing guide.

**Quick Test Flow:**
1. Register new account → Get account_id
2. Check console for verification token
3. Verify email with token
4. Login (once implemented)
5. Get/Update profile with JWT token

---

## 🔒 Security Features

- Password hashing (Django's make_password)
- JWT token rotation
- Token blacklisting
- Email verification required
- CORS protection
- Input validation (phone format, password strength)
- SQL injection protection (Django ORM)

---

## 📚 Documentation Files

- `README.md` - Main project description
- `neat_now_backend/SETUP.md` - Backend setup guide
- `neat_now_backend/POSTMAN_QUICK_TEST.md` - API testing guide
- `neat_now_backend/POSTMAN_TESTING_GUIDE.md` - Detailed testing guide
- `neat_now_backend/MIGRATION_CHECKLIST.md` - Database migration guide

---

## 🎯 Key Features (Planned/Implemented)

1. **User Authentication**
   - ✅ Email/password registration
   - ✅ Google OAuth login
   - ✅ Email verification
   - ✅ Password reset

2. **Waste Reporting** (Planned)
   - Report waste with photos
   - Location tagging
   - AI waste detection
   - Status tracking

3. **Worker Dashboard** (Planned)
   - Task assignment
   - Task acceptance/rejection
   - Cleanup verification
   - Photo upload

4. **Map Integration** (Planned)
   - View reports on map
   - Location-based filtering
   - Navigation to cleanup sites

---

## 🔗 Important Files to Review

1. **Backend:**
   - `neat_now_backend/accounts/models.py` - User data structure
   - `neat_now_backend/accounts/views.py` - API logic
   - `neat_now_backend/neat_now_backend/settings.py` - Configuration

2. **Frontend:**
   - `flutter/main.dart` - App entry point
   - `flutter/config/credentials.dart` - API configuration
   - `flutter/design/user/user_design_system.dart` - UI theme

---

## 📞 Next Steps

1. **Complete Reports App:**
   - Define Report model
   - Create report submission API
   - Implement status tracking

2. **Flutter Integration:**
   - Implement login screen
   - Connect to backend APIs
   - Build user dashboard
   - Implement report submission UI

3. **Worker Features:**
   - Task assignment system
   - Worker dashboard
   - Cleanup verification workflow

4. **AI Integration:**
   - Waste detection model
   - Image analysis API
   - Verification system

---

## 💡 Development Tips

- **Backend:** Use Django admin (`/admin/`) to manage accounts
- **Testing:** Use Postman for API testing before Flutter integration
- **Email:** Check Django console for verification tokens in development
- **Database:** Use PostgreSQL for production, SQLite for quick testing
- **CORS:** Update CORS settings when deploying Flutter app

---

*Last Updated: Based on current codebase structure*
