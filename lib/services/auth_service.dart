// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neat_now/config/credentials.dart';

class AuthService {
  // Login method that tries backend first, falls back to local credentials
  Future<Map<String, dynamic>> login(
      String email,
      String password,
      bool isUser,
      ) async {
    // Validate input
    if (!AppCredentials.isValidEmail(email)) {
      return {
        'success': false,
        'message': 'Please enter a valid email address',
      };
    }

    if (!AppCredentials.isValidPassword(password)) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    // Try backend authentication if enabled
    if (AppCredentials.useBackend) {
      try {
        final backendResult = await _authenticateWithBackend(email, password, isUser);

        if (backendResult['success']) {
          if (AppCredentials.debugMode) {
            print('✅ Backend authentication successful');
          }
          return backendResult;
        }
      } catch (e) {
        if (AppCredentials.debugMode) {
          print('⚠️ Backend authentication failed: $e');
          print('🔄 Falling back to local credentials...');
        }
      }
    }

    // Fallback to local credential validation
    return _authenticateLocally(email, password, isUser);
  }

  // Backend authentication
  Future<Map<String, dynamic>> _authenticateWithBackend(
      String email,
      String password,
      bool isUser,
      ) async {
    try {
      final url = Uri.parse('${AppCredentials.baseUrl}${AppCredentials.loginEndpoint}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'userType': isUser ? 'user' : 'employee',
        }),
      ).timeout(AppCredentials.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': 'Login successful',
          'data': data,
          'token': data['token'] ?? '',
          'userId': data['userId'] ?? '',
          'source': 'backend',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid email or password',
        };
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (AppCredentials.debugMode) {
        print('Backend error: $e');
      }
      rethrow;
    }
  }

  // Local credential authentication (fallback)
  Future<Map<String, dynamic>> _authenticateLocally(
      String email,
      String password,
      bool isUser,
      ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (isUser) {
      // Check user credentials
      if (AppCredentials.isDemoUser(email, password)) {
        if (AppCredentials.debugMode) {
          print('✅ Local user authentication successful');
        }
        return {
          'success': true,
          'message': 'Login successful (Demo Mode)',
          'data': {
            'userId': 'demo_user_001',
            'email': email,
            'name': 'Demo User',
            'userType': 'user',
          },
          'source': 'local',
        };
      }
    } else {
      // Check employee credentials
      if (AppCredentials.isDemoEmployee(email, password)) {
        if (AppCredentials.debugMode) {
          print('✅ Local employee authentication successful');
        }
        return {
          'success': true,
          'message': 'Login successful (Demo Mode)',
          'data': {
            'userId': 'demo_emp_001',
            'email': email,
            'name': 'Demo Employee',
            'userType': 'employee',
          },
          'source': 'local',
        };
      }
    }

    // Invalid credentials
    return {
      'success': false,
      'message': 'Invalid email or password',
    };
  }

  // Register method (for future use)
  Future<Map<String, dynamic>> register(
      String email,
      String password,
      String name,
      bool isUser,
      ) async {
    if (!AppCredentials.isValidEmail(email)) {
      return {
        'success': false,
        'message': 'Please enter a valid email address',
      };
    }

    if (!AppCredentials.isValidPassword(password)) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters',
      };
    }

    if (AppCredentials.useBackend) {
      try {
        final url = Uri.parse('${AppCredentials.baseUrl}${AppCredentials.registerEndpoint}');

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'password': password,
            'name': name,
            'userType': isUser ? 'user' : 'employee',
          }),
        ).timeout(AppCredentials.apiTimeout);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);

          return {
            'success': true,
            'message': 'Registration successful',
            'data': data,
          };
        } else {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Registration failed',
          };
        }
      } catch (e) {
        if (AppCredentials.debugMode) {
          print('Registration error: $e');
        }
        return {
          'success': false,
          'message': 'Registration failed. Please try again.',
        };
      }
    }

    // Local registration not supported
    return {
      'success': false,
      'message': 'Registration requires backend connection',
    };
  }

  // Logout method
  Future<void> logout() async {
    // Clear any stored tokens or session data
    if (AppCredentials.debugMode) {
      print('🚪 User logged out');
    }
    // Add your logout logic here (clear SharedPreferences, etc.)
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    // Check if there's a valid session
    // This would typically check SharedPreferences for a stored token
    return false;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    // Retrieve stored user data
    // This would typically get data from SharedPreferences
    return null;
  }
}