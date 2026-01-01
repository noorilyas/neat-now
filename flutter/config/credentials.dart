/// Application credentials and configuration
/// Contains demo credentials, API configuration, and app settings

class AppCredentials {
  // ============================================================
  // DEMO CREDENTIALS - For testing purposes only
  // ============================================================

  // Citizen (User) Demo Account
  static const String demoUserEmail = 'citizen@demo.com';
  static const String demoUserPassword = 'Demo@123';

  // Worker (Employee) Demo Account
  static const String demoEmployeeEmail = 'worker@demo.com';
  static const String demoEmployeePassword = 'Worker@123';

  // Admin Demo Account (for web portal reference)
  static const String demoAdminEmail = 'admin@neatnow.com';
  static const String demoAdminPassword = 'Admin@123';

  // ============================================================
  // API CONFIGURATION
  // ============================================================

  // Production API Base URL
  static const String productionApiUrl = 'https://api.neatnow.com/api';

  // Staging API Base URL
  static const String stagingApiUrl = 'https://staging-api.neatnow.com/api';

  // Development API Base URL (Local Django Server)
  // Android Emulator: 10.0.2.2
  // iOS Simulator: localhost
  // Physical Device: Your computer's LAN IP
  static const String developmentApiUrl = 'http://10.0.2.2:8000/api';

  // Current environment
  static const AppEnvironment currentEnvironment = AppEnvironment.development;

  /// Get API URL based on current environment
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case AppEnvironment.production:
        return productionApiUrl;
      case AppEnvironment.staging:
        return stagingApiUrl;
      case AppEnvironment.development:
        return developmentApiUrl;
    }
  }

  // ============================================================
  // GOOGLE SIGN-IN CONFIGURATION
  // ============================================================

  static const String googleClientIdAndroid =
      'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com';
  static const String googleClientIdIOS =
      'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';
  static const String googleClientIdWeb =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  // ============================================================
  // MAP CONFIGURATION
  // ============================================================

  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Default map center (adjust to your location)
  static const double defaultLatitude = 31.5204;
  static const double defaultLongitude = 74.3587;
  static const double defaultZoom = 12.0;

  // ============================================================
  // APP SETTINGS
  // ============================================================

  // Session timeout in minutes (FR-U2)
  static const int sessionTimeoutMinutes = 30;

  // Task acceptance timeout in minutes (FR-W3)
  static const int taskAcceptanceTimeoutMinutes = 60;

  // Report pending threshold in hours (FR-A6)
  static const int reportPendingThresholdHours = 48;

  // Maximum image upload size in MB
  static const int maxImageSizeMB = 10;

  // Supported image formats
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // ============================================================
  // AI CONFIGURATION
  // ============================================================

  // AI waste detection confidence threshold (FR-U4)
  static const double wasteDetectionThreshold = 0.7;

  // AI cleanup verification threshold (FR-W5)
  static const double cleanupVerificationThreshold = 0.8;
}

/// App environment enum
enum AppEnvironment {
  development,
  staging,
  production,
}
