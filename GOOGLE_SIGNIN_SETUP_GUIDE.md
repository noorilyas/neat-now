# Google Sign-In Complete Setup Guide

## Step 1: Google Cloud Console Setup

### 1.1 Create/Select Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Project name: "NeatNow" (or your preferred name)

### 1.2 Enable Google Sign-In API
1. Go to **APIs & Services** → **Library**
2. Search for "Google Sign-In API" or "Identity Toolkit API"
3. Click **Enable**

### 1.3 Configure OAuth Consent Screen
1. Go to **APIs & Services** → **OAuth consent screen**
2. Choose **External** (for testing) or **Internal** (for organization)
3. Fill required fields:
   - App name: "NeatNow"
   - User support email: Your email
   - Developer contact: Your email
4. Add scopes:
   - `email`
   - `profile`
5. Add test users (if External)
6. Save and Continue

## Step 2: Create OAuth 2.0 Client IDs

### 2.1 Web Client ID (Already Created)
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Application type: **Web application**
4. Name: "NeatNow Web Client"
5. Authorized JavaScript origins:
   - `http://localhost:8000` (for local development)
   - `http://127.0.0.1:8000` (for local development)
   - Your production domain (e.g., `https://neatnow.com`)
6. Authorized redirect URIs:
   - `http://localhost:8000/api/accounts/google-login/`
   - Your production callback URL
7. Click **Create**
8. **Copy the Client ID** - This is your Web Client ID

### 2.2 Android Client ID
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Application type: **Android**
4. Name: "NeatNow Android Client"
5. Package name: Check your `android/app/build.gradle` file
   - Look for `applicationId` (usually `com.example.neat_now` or similar)
6. SHA-1 certificate fingerprint:
   - **For Debug**: Run this command in terminal:
     ```bash
     cd android
     ./gradlew signingReport
     ```
   - Look for `SHA1` under `Variant: debug` → `Config: debug`
   - Copy the SHA-1 value
7. Click **Create**
8. **Copy the Client ID** - This is your Android Client ID

### 2.3 iOS Client ID
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **OAuth client ID**
3. Application type: **iOS**
4. Name: "NeatNow iOS Client"
5. Bundle ID: Check your `ios/Runner.xcodeproj` or `ios/Runner/Info.plist`
   - Look for `CFBundleIdentifier` (usually `com.example.neatNow` or similar)
6. Click **Create**
7. **Copy the Client ID** - This is your iOS Client ID

## Step 3: Configure Flutter App

### 3.1 Update credentials.dart
Open `flutter/lib/config/credentials.dart` and replace:

```dart
static const String googleClientIdAndroid =
    'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com';
static const String googleClientIdIOS =
    'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';
static const String googleClientIdWeb =
    'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
```

With your actual Client IDs from Step 2.

### 3.2 Android Configuration

#### Option A: Using google-services.json (Recommended)
1. Download `google-services.json` from Firebase Console:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create/Select project
   - Add Android app with your package name
   - Download `google-services.json`
2. Place file at: `flutter/android/app/google-services.json`
3. Update `flutter/android/app/build.gradle`:
   ```gradle
   dependencies {
       // ... existing dependencies
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
4. Update `flutter/android/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### Option B: Manual Configuration (If not using Firebase)
1. Update `flutter/android/app/build.gradle`:
   ```gradle
   defaultConfig {
       // ... existing config
       resValue "string", "default_web_client_id", "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com"
   }
   ```

### 3.3 iOS Configuration

1. Download `GoogleService-Info.plist` from Firebase Console:
   - Go to Firebase Console
   - Add iOS app with your Bundle ID
   - Download `GoogleService-Info.plist`
2. Place file at: `flutter/ios/Runner/GoogleService-Info.plist`
3. Open `flutter/ios/Runner.xcworkspace` in Xcode
4. Add `GoogleService-Info.plist` to Runner target
5. Update `Info.plist` to include:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```
   (Get REVERSED_CLIENT_ID from GoogleService-Info.plist)

### 3.4 Web Configuration

1. Update `flutter/web/index.html`:
   ```html
   <head>
       <!-- Add before closing </head> -->
       <script src="https://accounts.google.com/gsi/client" async defer></script>
   </head>
   ```

2. Update `flutter/lib/screens/login_screen.dart` (if needed for web):
   ```dart
   final GoogleSignIn googleSignIn = GoogleSignIn(
     scopes: ['email', 'profile'],
     // For web, you can specify client ID
     clientId: kIsWeb ? AppCredentials.googleClientIdWeb : null,
   );
   ```

## Step 4: Update Backend (Django)

### 4.1 Verify Backend Configuration
Your backend already has Google login endpoint at `/api/accounts/google-login/`

Make sure in `neat_now_backend/accounts/views.py`:
- Line 201: `'created_at': account.created_at.isoformat()` ✅ (Already done)

### 4.2 Update CORS Settings (if needed)
In `neat_now_backend/neat_now_backend/settings.py`:
```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8000",
    "http://127.0.0.1:8000",
    "http://localhost:3000",  # If using Flutter web
    # Add your production domains
]
```

## Step 5: Test

### 5.1 Install Dependencies
```bash
cd flutter
flutter pub get
```

### 5.2 Run App
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

### 5.3 Test Google Sign-In
1. Click "Continue with Google" button
2. Select Google account
3. Should navigate to dashboard
4. Check profile - "Member since" should show correct date

## Troubleshooting

### Issue: "DEVELOPER_ERROR" on Android
- **Solution**: Check SHA-1 fingerprint matches Google Cloud Console
- Run: `cd android && ./gradlew signingReport`
- Copy SHA-1 and add to Google Cloud Console

### Issue: "Sign-In Failed" on iOS
- **Solution**: Check Bundle ID matches Google Cloud Console
- Verify `GoogleService-Info.plist` is added to Xcode project

### Issue: "redirect_uri_mismatch" on Web
- **Solution**: Add your redirect URI to Google Cloud Console
- Check authorized redirect URIs in OAuth client settings

### Issue: created_at not showing
- **Solution**: 
  1. Logout and login again (to get fresh data)
  2. Check backend response includes `created_at`
  3. Verify `UserModel.fromMap` is parsing `created_at` correctly

## Quick Checklist

- [ ] Google Cloud Console project created
- [ ] OAuth consent screen configured
- [ ] Web Client ID created and copied
- [ ] Android Client ID created (with correct SHA-1)
- [ ] iOS Client ID created (with correct Bundle ID)
- [ ] Client IDs added to `credentials.dart`
- [ ] `google-services.json` added (Android)
- [ ] `GoogleService-Info.plist` added (iOS)
- [ ] `flutter pub get` run
- [ ] App tested on all platforms

## Notes

- **Web Client ID**: Already created (as you mentioned)
- **Android/iOS**: Need to create separately
- **SHA-1**: Required for Android (get from `./gradlew signingReport`)
- **Bundle ID**: Required for iOS (check in Xcode project settings)

