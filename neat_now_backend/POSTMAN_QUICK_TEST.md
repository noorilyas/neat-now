# Postman Quick Test Guide - All APIs

## 🚀 Server Start
```bash
python manage.py runserver
```
Server URL: `http://127.0.0.1:8000`

---

## ✅ API Endpoints Checklist

### 1. Registration API ✅
**POST** `http://127.0.0.1:8000/api/accounts/register/`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "email": "test1@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "name": "Test User 1",
    "phone_number": "+923001234567"
}
```

**Expected Response (201):**
```json
{
    "message": "Registration successful. Please check your email to verify your account.",
    "account_id": 1,
    "email": "test1@example.com"
}
```

**Check Console:** Verification token will be printed in Django console

---

### 2. Email Verification API ✅
**POST** `http://127.0.0.1:8000/api/accounts/verify-email/`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "token": "paste-token-from-console-here"
}
```

**Expected Response (200):**
```json
{
    "message": "Email verified successfully. You can now login."
}
```

**Error (400):**
```json
{
    "error": "Invalid or expired verification token."
}
```

---

### 3. Resend Verification Email API ✅
**POST** `http://127.0.0.1:8000/api/accounts/resend-verification/`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "email": "test1@example.com"
}
```

**Expected Response (200):**
```json
{
    "message": "Verification email sent. Please check your inbox."
}
```

---

### 4. Get Profile API (Requires JWT) ⚠️
**GET** `http://127.0.0.1:8000/api/accounts/profile/`

**Headers:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Expected Response (200):**
```json
{
    "account_id": 1,
    "email": "test1@example.com",
    "name": "Test User 1",
    "phone_number": "+923001234567",
    "profile_image": null,
    "role": "Citizen",
    "email_verified": true,
    "created_at": "2025-12-21T22:00:00Z"
}
```

**Note:** Login API abhi implement nahi hai, isliye yeh test nahi kar sakte abhi.

---

### 5. Update Profile API (Requires JWT) ⚠️
**PATCH** `http://127.0.0.1:8000/api/accounts/profile/`

**Headers:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "name": "Updated Name",
    "phone_number": "+923009876543"
}
```

**Note:** Login API abhi implement nahi hai, isliye yeh test nahi kar sakte abhi.

---

## 🧪 Testing Steps

### Step 1: Test Registration
1. Open Postman
2. Create new POST request
3. URL: `http://127.0.0.1:8000/api/accounts/register/`
4. Headers: `Content-Type: application/json`
5. Body (raw JSON): Copy registration JSON above
6. Click Send
7. ✅ Should get 201 response with account_id

### Step 2: Check Console for Token
1. Look at Django console/terminal
2. Find the verification email output
3. Copy the token from the verification URL
4. Example: `token=abc123-def456-ghi789`

### Step 3: Test Email Verification
1. Create new POST request
2. URL: `http://127.0.0.1:8000/api/accounts/verify-email/`
3. Headers: `Content-Type: application/json`
4. Body: `{"token": "paste-token-here"}`
5. Click Send
6. ✅ Should get 200 response with success message

### Step 4: Test Resend Verification
1. Create new POST request
2. URL: `http://127.0.0.1:8000/api/accounts/resend-verification/`
3. Headers: `Content-Type: application/json`
4. Body: `{"email": "test1@example.com"}`
5. Click Send
6. ✅ Should get 200 response

---

## ❌ Error Testing

### Test Duplicate Email
**Request:**
```json
{
    "email": "test1@example.com",  // Same email as before
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "name": "Another User"
}
```
**Expected:** 400 error with "Email already registered."

### Test Password Mismatch
**Request:**
```json
{
    "email": "test2@example.com",
    "password": "SecurePass123!",
    "password_confirm": "DifferentPass123!",
    "name": "Test User"
}
```
**Expected:** 400 error with "Passwords do not match."

### Test Invalid Phone
**Request:**
```json
{
    "email": "test3@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "name": "Test User",
    "phone_number": "1234567890"  // Invalid format
}
```
**Expected:** 400 error with phone validation message

---

## 📝 Current Status

✅ **Working APIs:**
- Registration
- Email Verification
- Resend Verification

⚠️ **Pending (Login needed first):**
- Get Profile (needs JWT)
- Update Profile (needs JWT)

---

## 🔍 Quick Debug Tips

1. **404 Error:** Check URL spelling: `/api/accounts/register/`
2. **400 Error:** Check JSON format and required fields
3. **500 Error:** Check Django console for detailed error
4. **Email not sending:** Check console backend is enabled in settings
5. **Token not found:** Check console output for verification email

---

## 📋 Postman Collection Setup

1. Create Collection: "Neat Now API"
2. Add Environment:
   - Variable: `base_url` = `http://127.0.0.1:8000`
   - Use: `{{base_url}}/api/accounts/register/`
3. Save all requests for easy testing

---

## ✅ Ready for Flutter Integration

Once all APIs are tested and working in Postman:
- ✅ Registration works
- ✅ Email verification works
- ✅ All error cases handled
- Then proceed with Flutter integration



