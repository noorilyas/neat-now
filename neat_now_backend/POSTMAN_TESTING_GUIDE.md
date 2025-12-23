# Postman Testing Guide - Registration Endpoint

## Prerequisites
1. Django server should be running: `python manage.py runserver`
2. Server will run on: `http://127.0.0.1:8000` or `http://localhost:8000`

## Registration Endpoint Testing

### Endpoint Details
- **Method**: `POST`
- **URL**: `http://127.0.0.1:8000/api/accounts/register/`
- **Content-Type**: `application/json` (for JSON) or `multipart/form-data` (if including profile image)

---

## Test Case 1: Basic Registration (JSON - Without Profile Image)

### Request Setup:
1. **Method**: Select `POST`
2. **URL**: `http://127.0.0.1:8000/api/accounts/register/`
3. **Headers**:
   - `Content-Type`: `application/json`
4. **Body** (select `raw` → `JSON`):
```json
{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "name": "Test User",
    "phone_number": "+923001234567"
}
```

### Expected Response (201 Created):
```json
{
    "message": "Registration successful. Please check your email to verify your account.",
    "account_id": 1,
    "email": "test@example.com"
}
```

---

## Test Case 2: Registration with Profile Image (Form Data)

### Request Setup:
1. **Method**: Select `POST`
2. **URL**: `http://127.0.0.1:8000/api/accounts/register/`
3. **Headers**: 
   - Don't set Content-Type manually (Postman will set it automatically)
4. **Body** (select `form-data`):
   - Key: `email` → Value: `test2@example.com` (Text)
   - Key: `password` → Value: `SecurePass123!` (Text)
   - Key: `password_confirm` → Value: `SecurePass123!` (Text)
   - Key: `name` → Value: `Test User 2` (Text)
   - Key: `phone_number` → Value: `+923001234568` (Text)
   - Key: `profile_image` → Value: [Select File] (File) - Choose an image file

### Expected Response (201 Created):
```json
{
    "message": "Registration successful. Please check your email to verify your account.",
    "account_id": 2,
    "email": "test2@example.com"
}
```

---

## Test Case 3: Email Verification

### Endpoint Details:
- **Method**: `POST`
- **URL**: `http://127.0.0.1:8000/api/accounts/verify-email/`

### Request Setup:
1. **Method**: Select `POST`
2. **URL**: `http://127.0.0.1:8000/api/accounts/verify-email/`
3. **Headers**:
   - `Content-Type`: `application/json`
4. **Body** (select `raw` → `JSON`):
```json
{
    "token": "your-verification-token-from-email"
}
```

**Note**: The token will be sent to the registered email address. For testing, you can:
- Check Django console/logs for the token
- Or use the email verification link sent to your email

### Expected Response (200 OK):
```json
{
    "message": "Email verified successfully. You can now login."
}
```

---

## Test Case 4: Resend Verification Email

### Endpoint Details:
- **Method**: `POST`
- **URL**: `http://127.0.0.1:8000/api/accounts/resend-verification/`

### Request Setup:
1. **Method**: Select `POST`
2. **URL**: `http://127.0.0.1:8000/api/accounts/resend-verification/`
3. **Headers**:
   - `Content-Type`: `application/json`
4. **Body** (select `raw` → `JSON`):
```json
{
    "email": "test@example.com"
}
```

### Expected Response (200 OK):
```json
{
    "message": "Verification email sent. Please check your inbox."
}
```

---

## Error Test Cases

### Test Case 5: Duplicate Email
**Request**:
```json
{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "name": "Another User"
}
```
**Expected Response (400 Bad Request)**:
```json
{
    "email": ["Email already registered."]
}
```

### Test Case 6: Password Mismatch
**Request**:
```json
{
    "email": "new@example.com",
    "password": "SecurePass123!",
    "password_confirm": "DifferentPass123!",
    "name": "Test User"
}
```
**Expected Response (400 Bad Request)**:
```json
{
    "password_confirm": ["Passwords do not match."]
}
```

### Test Case 7: Invalid Phone Number
**Request**:
```json
{
    "email": "new@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "name": "Test User",
    "phone_number": "1234567890"
}
```
**Expected Response (400 Bad Request)**:
```json
{
    "phone_number": ["Phone number must be in format +92XXXXXXXXXX"]
}
```

### Test Case 8: Missing Required Fields
**Request**:
```json
{
    "email": "new@example.com",
    "password": "SecurePass123!"
}
```
**Expected Response (400 Bad Request)**:
```json
{
    "name": ["This field is required."],
    "password_confirm": ["This field is required."]
}
```

---

## Postman Collection Setup Tips

1. **Create a Collection**: Create a new collection named "Neat Now API"
2. **Save Requests**: Save each test case as a separate request
3. **Environment Variables**: Create an environment with:
   - `base_url`: `http://127.0.0.1:8000`
   - Then use: `{{base_url}}/api/accounts/register/`

---

## Quick Testing Steps

1. **Start Django Server**:
   ```bash
   python manage.py runserver
   ```

2. **Open Postman** and create a new request

3. **Set Method to POST** and enter URL: `http://127.0.0.1:8000/api/accounts/register/`

4. **Add Headers**: `Content-Type: application/json`

5. **Add Body** (raw JSON):
   ```json
   {
       "email": "test@example.com",
       "password": "SecurePass123!",
       "password_confirm": "SecurePass123!",
       "name": "Test User",
       "phone_number": "+923001234567"
   }
   ```

6. **Click Send** and check the response

---

## Notes

- **Email Verification**: After registration, check your email (or Django console if email is not configured) for the verification token
- **Profile Image**: Maximum size is 5MB, must be an image file
- **Phone Number**: Must be in format `+92XXXXXXXXXX` (Pakistan format)
- **Password**: Must meet Django's password validation requirements (min 8 chars, etc.)

---

## Troubleshooting

### Error: "Connection refused"
- Make sure Django server is running: `python manage.py runserver`

### Error: "CSRF verification failed"
- This is normal for API endpoints. The CORS middleware should handle this.

### Error: "No module named 'rest_framework_simplejwt'"
- Install requirements: `pip install -r requirements.txt`

### Email not sending
- Check `settings.py` for email configuration
- For testing, emails will print to console if using console backend



