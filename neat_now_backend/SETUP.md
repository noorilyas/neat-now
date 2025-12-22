# Setup Instructions for Neat Now Backend

## Prerequisites
- Python 3.12+
- PostgreSQL database (neat_now_db)
- Virtual environment activated

## Installation Steps

1. **Activate Virtual Environment** (if not already activated):
   ```bash
   # Windows PowerShell
   .\venv\Scripts\Activate.ps1
   
   # Windows CMD
   venv\Scripts\activate.bat
   ```

2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure Database**:
   - Ensure PostgreSQL is running
   - Database `neat_now_db` should exist
   - Update database credentials in `neat_now_backend/settings.py` if needed

4. **Configure Email Settings** (in `neat_now_backend/settings.py`):
   ```python
   EMAIL_HOST_USER = 'your-email@gmail.com'
   EMAIL_HOST_PASSWORD = 'your-app-password'
   DEFAULT_FROM_EMAIL = 'your-email@gmail.com'
   ```

5. **Run Migrations**:
   ```bash
   cd neat_now_backend
   python manage.py makemigrations
   python manage.py migrate
   ```

6. **Create Superuser** (optional, for Django admin):
   ```bash
   python manage.py createsuperuser
   ```

7. **Run Development Server**:
   ```bash
   python manage.py runserver
   ```

## API Endpoints

### Registration
- **POST** `/api/accounts/register/`
  - Body: `{email, password, password_confirm, name, phone_number (optional), profile_image (optional)}`
  - Response: `{message, account_id, email}`

### Email Verification
- **POST** `/api/accounts/verify-email/`
  - Body: `{token}`
  - Response: `{message}`

### Resend Verification
- **POST** `/api/accounts/resend-verification/`
  - Body: `{email}`
  - Response: `{message}`

### Profile Management
- **GET** `/api/accounts/profile/` (Requires JWT)
- **PATCH** `/api/accounts/profile/` (Requires JWT)
  - Body: `{name, phone_number, profile_image}`

## Testing Registration Flow

1. Register a new account:
   ```bash
   POST http://localhost:8000/api/accounts/register/
   {
     "email": "test@example.com",
     "password": "SecurePass123!",
     "password_confirm": "SecurePass123!",
     "name": "Test User",
     "phone_number": "+923001234567"
   }
   ```

2. Check email for verification link

3. Verify email using the token from email

4. Login (to be implemented next)

