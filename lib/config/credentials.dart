// lib/config/credentials.dart

class AppCredentials {
  // Demo User Credentials
  static const String demoUserEmail = 'user@neatnow.com';
  static const String demoUserPassword = 'user123';

  // Demo Employee Credentials
  static const String demoEmployeeEmail = 'employee@neatnow.com';
  static const String demoEmployeePassword = 'emp123';

  // Backend API Configuration
  static const String baseUrl = 'https://api.neatnow.com'; // Replace with your actual API URL
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';

  // API Timeout Settings
  static const Duration apiTimeout = Duration(seconds: 10);

  // Feature Flags
  static const bool useBackend = true; // Set to false to use only local credentials
  static const bool debugMode = true; // Enable for development logs

  // Validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Check if credentials match demo credentials
  static bool isDemoUser(String email, String password) {
    return email == demoUserEmail && password == demoUserPassword;
  }

  static bool isDemoEmployee(String email, String password) {
    return email == demoEmployeeEmail && password == demoEmployeePassword;
  }
}