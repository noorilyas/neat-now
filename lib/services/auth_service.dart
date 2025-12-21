import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:neat_now/config/credentials.dart';

/// AuthService - Handles all authentication operations with Demo Mode Fallback
/// Implements FR-U1, FR-U2 (User Auth) & FR-W1 (Worker Auth)
///
/// Features:
/// - Attempts real server authentication first
/// - Falls back to demo mode if server is unavailable
/// - Stores demo users locally for offline registration
/// - Seamless user experience in both online and offline modes
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // API Configuration
  String get _baseUrl => AppCredentials.apiBaseUrl;

  // Demo Mode Flag
  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  // Endpoints
  static const String _loginEndpoint = '/auth/login/';
  static const String _workerLoginEndpoint = '/auth/worker/login/';
  static const String _registerEndpoint = '/auth/register/';
  static const String _logoutEndpoint = '/auth/logout/';
  static const String _passwordResetEndpoint = '/auth/password/reset/';
  static const String _refreshTokenEndpoint = '/auth/token/refresh/';
  static const String _profileEndpoint = '/auth/profile/';
  static const String _googleAuthEndpoint = '/auth/google/';

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _userTypeKey = 'user_type';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _savedEmailKey = 'saved_email';
  static const String _rememberMeKey = 'remember_me';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _demoModeKey = 'is_demo_mode';
  static const String _demoUsersKey = 'demo_users';

  // HTTP client
  final http. Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 10); // Reduced for faster fallback

  // ==================== DEMO USER DATA ====================

  /// Default demo users - used when server is unavailable
  static final Map<String, Map<String, dynamic>> _defaultDemoUsers = {
    // Citizen demo user
    AppCredentials.demoUserEmail. toLowerCase(): {
      'id': 'demo_citizen_001',
      'email': AppCredentials.demoUserEmail,
      'password': AppCredentials.demoUserPassword,
      'name': 'Demo Citizen',
      'phone_number': '+1234567890',
      'user_type': 'citizen',
      'profile_image': null,
      'is_verified': true,
      'created_at': DateTime. now().toIso8601String(),
    },
    // Worker demo user
    AppCredentials.demoEmployeeEmail.toLowerCase(): {
      'id': 'demo_worker_001',
      'email': AppCredentials.demoEmployeeEmail,
      'password': AppCredentials.demoEmployeePassword,
      'name': 'Demo Worker',
      'phone_number': '+0987654321',
      'user_type': 'worker',
      'profile_image': null,
      'is_verified': true,
      'created_at': DateTime.now().toIso8601String(),
    },
  };

  // ==================== SERVER CHECK ====================

  /// Check if the server is available
  Future<bool> isServerAvailable() async {
    try {
      final url = Uri.parse('$_baseUrl/health/'); // Health check endpoint
      final response = await _client.get(url). timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      debugPrint('Server check failed: $e');
      return false;
    }
  }

  /// Initialize demo mode based on server availability
  Future<void> initializeDemoMode() async {
    final serverAvailable = await isServerAvailable();
    _isDemoMode = ! serverAvailable;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_demoModeKey, _isDemoMode);

    if (_isDemoMode) {
      await _initializeDemoUsers();
      debugPrint('🔧 Demo Mode Activated - Server unavailable');
    } else {
      debugPrint('✅ Online Mode - Server connected');
    }
  }

  /// Initialize demo users in local storage
  Future<void> _initializeDemoUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final existingUsers = prefs.getString(_demoUsersKey);

    if (existingUsers == null) {
      // Initialize with default demo users
      await prefs.setString(_demoUsersKey, json.encode(_defaultDemoUsers));
    }
  }

  /// Get all demo users from local storage
  Future<Map<String, dynamic>> _getDemoUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_demoUsersKey);

    if (usersJson != null) {
      return Map<String, dynamic>.from(json.decode(usersJson));
    }

    return Map<String, dynamic>. from(_defaultDemoUsers);
  }

  /// Save demo user to local storage
  Future<void> _saveDemoUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getDemoUsers();
    users[user['email']. toString(). toLowerCase()] = user;
    await prefs.setString(_demoUsersKey, json.encode(users));
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Login for both Citizen and Worker - FR-U2, FR-W1
  /// Attempts server login first, falls back to demo mode if unavailable
  Future<Map<String, dynamic>> login(
      String email,
      String password,
      bool isUserLogin,
      ) async {
    final normalizedEmail = email. toLowerCase(). trim();

    // Try server login first
    try {
      final endpoint = isUserLogin ?  _loginEndpoint : _workerLoginEndpoint;
      final url = Uri.parse('$_baseUrl$endpoint');

      final response = await _client
          .post(
        url,
        headers: _getHeaders(),
        body: json.encode({
          'email': normalizedEmail,
          'password': password,
          'user_type': isUserLogin ? 'citizen' : 'worker',
        }),
      )
          . timeout(_timeout);

      final result = _handleResponse(response);

      if (result['success'] == true) {
        _isDemoMode = false;
        await _saveAuthData(result['data'], isUserLogin);
        return {
          'success': true,
          'message': 'Login successful',
          'user': result['data']['user'],
          'isDemoMode': false,
        };
      }

      // Server returned error (like wrong password)
      return result;
    } on SocketException {
      debugPrint('🔧 Server unavailable - Switching to Demo Mode');
      return await _demoLogin(normalizedEmail, password, isUserLogin);
    } on TimeoutException {
      debugPrint('🔧 Server timeout - Switching to Demo Mode');
      return await _demoLogin(normalizedEmail, password, isUserLogin);
    } on http.ClientException {
      debugPrint('🔧 Connection error - Switching to Demo Mode');
      return await _demoLogin(normalizedEmail, password, isUserLogin);
    } catch (e) {
      debugPrint('Login error: $e');
      // Try demo login as fallback
      return await _demoLogin(normalizedEmail, password, isUserLogin);
    }
  }

  /// Demo mode login - validates against local demo users
  Future<Map<String, dynamic>> _demoLogin(
      String email,
      String password,
      bool isUserLogin,
      ) async {
    _isDemoMode = true;
    await _initializeDemoUsers();

    final users = await _getDemoUsers();
    final user = users[email];

    if (user == null) {
      return {
        'success': false,
        'message': 'User not found.  Please register first or use demo credentials.',
        'isDemoMode': true,
        'hint': 'Demo: ${isUserLogin ? AppCredentials.demoUserEmail : AppCredentials.demoEmployeeEmail}',
      };
    }

    // Check password
    if (user['password'] != password) {
      return {
        'success': false,
        'message': 'Invalid password',
        'isDemoMode': true,
      };
    }

    // Check user type
    final expectedType = isUserLogin ?  'citizen' : 'worker';
    if (user['user_type'] != expectedType) {
      return {
        'success': false,
        'message': 'Please use the ${user['user_type'] == 'citizen' ? 'Citizen' : 'Worker'} login option',
        'isDemoMode': true,
      };
    }

    // Create demo auth data
    final authData = {
      'access': 'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
      'refresh': 'demo_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': user['id'],
        'email': user['email'],
        'name': user['name'],
        'phone_number': user['phone_number'],
        'user_type': user['user_type'],
        'profile_image': user['profile_image'],
        'is_verified': user['is_verified'],
      },
    };

    await _saveAuthData(authData, isUserLogin);

    final prefs = await SharedPreferences.getInstance();
    await prefs. setBool(_demoModeKey, true);

    return {
      'success': true,
      'message': '🔧 Demo Mode: Login successful',
      'user': authData['user'],
      'isDemoMode': true,
    };
  }

  /// Register new user - FR-U1
  /// Attempts server registration first, falls back to demo mode
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    File? profileImage,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();

    // Try server registration first
    try {
      final url = Uri.parse('$_baseUrl$_registerEndpoint');

      http.Response response;

      if (profileImage != null) {
        var request = http.MultipartRequest('POST', url);
        request.headers. addAll({'Accept': 'application/json'});
        request.fields['name'] = name. trim();
        request. fields['email'] = normalizedEmail;
        request.fields['password'] = password;
        request.fields['phone_number'] = phoneNumber.trim();
        request. files. add(
          await http.MultipartFile. fromPath('profile_image', profileImage. path),
        );

        final streamedResponse = await request.send(). timeout(_timeout);
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await _client
            .post(
          url,
          headers: _getHeaders(),
          body: json.encode({
            'name': name.trim(),
            'email': normalizedEmail,
            'password': password,
            'phone_number': phoneNumber.trim(),
          }),
        )
            .timeout(_timeout);
      }

      final result = _handleResponse(response);

      if (result['success'] == true) {
        _isDemoMode = false;
        return {
          'success': true,
          'message': 'Registration successful!  Please verify your email.',
          'data': result['data'],
          'isDemoMode': false,
        };
      }

      return result;
    } on SocketException {
      debugPrint('🔧 Server unavailable - Registering in Demo Mode');
      return await _demoRegister(
        name: name,
        email: normalizedEmail,
        password: password,
        phoneNumber: phoneNumber,
      );
    } on TimeoutException {
      debugPrint('🔧 Server timeout - Registering in Demo Mode');
      return await _demoRegister(
        name: name,
        email: normalizedEmail,
        password: password,
        phoneNumber: phoneNumber,
      );
    } on http.ClientException {
      debugPrint('🔧 Connection error - Registering in Demo Mode');
      return await _demoRegister(
        name: name,
        email: normalizedEmail,
        password: password,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('Registration error: $e');
      return await _demoRegister(
        name: name,
        email: normalizedEmail,
        password: password,
        phoneNumber: phoneNumber,
      );
    }
  }

  /// Demo mode registration - stores user locally
  Future<Map<String, dynamic>> _demoRegister({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    _isDemoMode = true;
    await _initializeDemoUsers();

    final users = await _getDemoUsers();

    // Check if user already exists
    if (users.containsKey(email)) {
      return {
        'success': false,
        'message': 'An account with this email already exists.',
        'isDemoMode': true,
      };
    }

    // Validate password strength
    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters.',
        'isDemoMode': true,
      };
    }

    // Create new demo user
    final newUser = {
      'id': 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'password': password,
      'name': name. trim(),
      'phone_number': phoneNumber.trim(),
      'user_type': 'citizen', // Default to citizen for registration
      'profile_image': null,
      'is_verified': true, // Auto-verify in demo mode
      'created_at': DateTime.now().toIso8601String(),
    };

    await _saveDemoUser(newUser);

    final prefs = await SharedPreferences.getInstance();
    await prefs. setBool(_demoModeKey, true);

    return {
      'success': true,
      'message': '🔧 Demo Mode: Registration successful!  You can now login.',
      'data': {
        'user': {
          'id': newUser['id'],
          'email': newUser['email'],
          'name': newUser['name'],
        },
      },
      'isDemoMode': true,
    };
  }

  /// Logout - FR-U2, FR-W8
  Future<Map<String, dynamic>> logout() async {
    // Try server logout if not in demo mode
    if (!_isDemoMode) {
      try {
        final token = await getAccessToken();
        if (token != null && ! token.startsWith('demo_')) {
          final url = Uri.parse('$_baseUrl$_logoutEndpoint');
          await _client
              . post(
            url,
            headers: await _getAuthHeaders(),
            body: json.encode({
              'refresh_token': await getRefreshToken(),
            }),
          )
              .timeout(_timeout);
        }
      } catch (e) {
        debugPrint('Logout API error: $e');
      }
    }

    // Always clear local data
    await _clearAuthData();

    return {
      'success': true,
      'message': 'Logged out successfully',
    };
  }

  /// Request password reset - FR-U1
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final normalizedEmail = email.toLowerCase().trim();

    // Try server first
    try {
      final url = Uri.parse('$_baseUrl$_passwordResetEndpoint');

      final response = await _client
          .post(
        url,
        headers: _getHeaders(),
        body: json.encode({'email': normalizedEmail}),
      )
          .timeout(_timeout);

      final result = _handleResponse(response);

      if (result['success'] == true) {
        return {
          'success': true,
          'message': 'Password reset email sent successfully.',
          'isDemoMode': false,
        };
      }

      return result;
    } catch (e) {
      // Demo mode password reset
      return await _demoPasswordReset(normalizedEmail);
    }
  }

  /// Demo mode password reset
  Future<Map<String, dynamic>> _demoPasswordReset(String email) async {
    final users = await _getDemoUsers();

    if (! users.containsKey(email)) {
      return {
        'success': false,
        'message': 'No account found with this email.',
        'isDemoMode': true,
      };
    }

    // In demo mode, we just pretend to send an email
    return {
      'success': true,
      'message': '🔧 Demo Mode: Password reset simulated.  Use your current password to login.',
      'isDemoMode': true,
      'hint': 'In demo mode, passwords cannot be reset. Please use your existing password.',
    };
  }

  /// Refresh access token - FR-U2
  Future<Map<String, dynamic>> refreshAccessToken() async {
    // In demo mode, just generate new tokens
    if (_isDemoMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _accessTokenKey,
        'demo_access_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      await _updateTokenExpiry();
      return {'success': true, 'message': 'Demo token refreshed'};
    }

    try {
      final refreshToken = await getRefreshToken();

      if (refreshToken == null || refreshToken.startsWith('demo_')) {
        return {
          'success': false,
          'message': 'No refresh token available',
          'requiresReauth': true,
        };
      }

      final url = Uri.parse('$_baseUrl$_refreshTokenEndpoint');

      final response = await _client
          . post(
        url,
        headers: _getHeaders(),
        body: json. encode({'refresh': refreshToken}),
      )
          . timeout(_timeout);

      final result = _handleResponse(response);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs. setString(_accessTokenKey, result['data']['access']);

        if (result['data']['refresh'] != null) {
          await prefs.setString(_refreshTokenKey, result['data']['refresh']);
        }

        await _updateTokenExpiry();

        return {'success': true, 'message': 'Token refreshed successfully'};
      }

      await _clearAuthData();
      return {
        'success': false,
        'message': 'Session expired. Please login again.',
        'requiresReauth': true,
      };
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return {
        'success': false,
        'message': 'Failed to refresh session.',
        'requiresReauth': true,
      };
    }
  }

  /// Google Sign-In - FR-U2
  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    try {
      final url = Uri.parse('$_baseUrl$_googleAuthEndpoint');

      final response = await _client
          .post(
        url,
        headers: _getHeaders(),
        body: json.encode({'id_token': idToken}),
      )
          .timeout(_timeout);

      final result = _handleResponse(response);

      if (result['success'] == true) {
        _isDemoMode = false;
        await _saveAuthData(result['data'], true);
        return {
          'success': true,
          'message': 'Google sign-in successful',
          'user': result['data']['user'],
          'isNewUser': result['data']['is_new_user'] ?? false,
          'isDemoMode': false,
        };
      }

      return result;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return {
        'success': false,
        'message': '🔧 Demo Mode: Google Sign-In not available offline.',
        'isDemoMode': true,
      };
    }
  }

  // ==================== PROFILE METHODS ====================

  /// Get user profile - FR-U1, FR-W2
  Future<Map<String, dynamic>> getProfile() async {
    // Check if in demo mode
    if (_isDemoMode) {
      return await _getDemoProfile();
    }

    try {
      final url = Uri.parse('$_baseUrl$_profileEndpoint');

      final response = await _client
          .get(url, headers: await _getAuthHeaders())
          . timeout(_timeout);

      final result = _handleResponse(response);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, json.encode(result['data']));
        return {'success': true, 'user': result['data']};
      }

      if (result['requiresReauth'] == true) {
        final refreshResult = await refreshAccessToken();
        if (refreshResult['success'] == true) {
          return getProfile();
        }
      }

      return result;
    } catch (e) {
      debugPrint('Get profile error: $e');
      // Fallback to cached/demo profile
      return await _getDemoProfile();
    }
  }

  /// Get demo profile from cached data
  Future<Map<String, dynamic>> _getDemoProfile() async {
    final cachedUser = await getCachedUserData();
    if (cachedUser != null) {
      return {
        'success': true,
        'user': cachedUser,
        'isDemoMode': true,
      };
    }

    return {
      'success': false,
      'message': 'No profile data available',
      'isDemoMode': true,
    };
  }

  /// Update user profile - FR-U1, FR-W2
  Future<Map<String, dynamic>> updateProfile({
    String?  name,
    String?  phoneNumber,
    File? profileImage,
  }) async {
    // In demo mode, update locally
    if (_isDemoMode) {
      return await _updateDemoProfile(name: name, phoneNumber: phoneNumber);
    }

    try {
      final url = Uri.parse('$_baseUrl$_profileEndpoint');

      http.Response response;

      if (profileImage != null) {
        var request = http.MultipartRequest('PATCH', url);
        request.headers. addAll(await _getAuthHeaders());

        if (name != null) request.fields['name'] = name.trim();
        if (phoneNumber != null) request.fields['phone_number'] = phoneNumber.trim();

        request.files. add(
          await http.MultipartFile.fromPath('profile_image', profileImage.path),
        );

        final streamedResponse = await request.send().timeout(_timeout);
        response = await http.Response.fromStream(streamedResponse);
      } else {
        Map<String, dynamic> body = {};
        if (name != null) body['name'] = name. trim();
        if (phoneNumber != null) body['phone_number'] = phoneNumber.trim();

        response = await _client
            .patch(
          url,
          headers: await _getAuthHeaders(),
          body: json.encode(body),
        )
            .timeout(_timeout);
      }

      final result = _handleResponse(response);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs. setString(_userDataKey, json.encode(result['data']));
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'user': result['data'],
        };
      }

      return result;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return await _updateDemoProfile(name: name, phoneNumber: phoneNumber);
    }
  }

  /// Update demo profile locally
  Future<Map<String, dynamic>> _updateDemoProfile({
    String?  name,
    String? phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = await getCachedUserData();

    if (userData == null) {
      return {
        'success': false,
        'message': 'No profile to update',
        'isDemoMode': true,
      };
    }

    // Update user data
    if (name != null) userData['name'] = name.trim();
    if (phoneNumber != null) userData['phone_number'] = phoneNumber.trim();

    await prefs.setString(_userDataKey, json.encode(userData));

    // Also update in demo users storage
    final email = userData['email']?.toString(). toLowerCase();
    if (email != null) {
      final users = await _getDemoUsers();
      if (users.containsKey(email)) {
        users[email]['name'] = userData['name'];
        users[email]['phone_number'] = userData['phone_number'];
        await prefs.setString(_demoUsersKey, json. encode(users));
      }
    }

    return {
      'success': true,
      'message': '🔧 Demo Mode: Profile updated locally',
      'user': userData,
      'isDemoMode': true,
    };
  }

  // ==================== DEMO USER MANAGEMENT ====================

  /// Get list of all registered demo users (for debugging)
  Future<List<Map<String, dynamic>>> getAllDemoUsers() async {
    final users = await _getDemoUsers();
    return users.values
        .map((user) => {
      'email': user['email'],
      'name': user['name'],
      'user_type': user['user_type'],
      'created_at': user['created_at'],
    })
        . toList();
  }

  /// Clear all demo users (reset to defaults)
  Future<void> resetDemoUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_demoUsersKey, json. encode(_defaultDemoUsers));
    debugPrint('Demo users reset to defaults');
  }

  /// Check if a demo user exists
  Future<bool> demoUserExists(String email) async {
    final users = await _getDemoUsers();
    return users. containsKey(email. toLowerCase());
  }

  // ==================== CREDENTIAL MANAGEMENT ====================

  /// Save credentials for "Remember me" - FR-U2
  Future<void> saveCredentials({
    required String email,
    required bool remember,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs. setString(_savedEmailKey, email);
      await prefs.setBool(_rememberMeKey, true);
    } else {
      await prefs.remove(_savedEmailKey);
      await prefs.setBool(_rememberMeKey, false);
    }
  }

  /// Get saved credentials
  Future<Map<String, dynamic>?> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberMeKey) ?? false;

    if (! remember) return null;

    return {
      'email': prefs.getString(_savedEmailKey),
      'remember': remember,
    };
  }

  /// Clear saved credentials
  Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedEmailKey);
    await prefs.setBool(_rememberMeKey, false);
  }

  // ==================== TOKEN MANAGEMENT ====================

  Future<String? > getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences. getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return false;

    // In demo mode, just check if we have cached user data
    if (_isDemoMode || (await getAccessToken())?.startsWith('demo_') == true) {
      final userData = await getCachedUserData();
      return userData != null;
    }

    // Check token expiry for real sessions
    final expiry = prefs.getInt(_tokenExpiryKey);
    if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
      final refreshResult = await refreshAccessToken();
      return refreshResult['success'] == true;
    }

    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isWorkerUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey) == 'worker';
  }

  Future<Map<String, dynamic>?> getCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs. getString(_userDataKey);
    if (userData != null) {
      return Map<String, dynamic>.from(json.decode(userData));
    }
    return null;
  }

  Future<String?> getUserType() async {
    final prefs = await SharedPreferences. getInstance();
    return prefs.getString(_userTypeKey);
  }

  /// Check session validity - FR-U2
  Future<bool> checkSessionValidity() async {
    // In demo mode, session is always valid if we have user data
    if (_isDemoMode) {
      final userData = await getCachedUserData();
      return userData != null;
    }

    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs. getInt(_tokenExpiryKey);

    if (expiry == null) return false;

    if (DateTime.now(). millisecondsSinceEpoch > expiry) {
      final result = await refreshAccessToken();
      return result['success'] == true;
    }

    await _updateTokenExpiry();
    return true;
  }

  /// Check if currently in demo mode
  Future<bool> checkDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDemoMode = prefs.getBool(_demoModeKey) ?? false;

    // Also check if token is a demo token
    final token = await getAccessToken();
    if (token?. startsWith('demo_') == true) {
      _isDemoMode = true;
    }

    return _isDemoMode;
  }

  // ==================== PRIVATE HELPERS ====================

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic> responseData;

    try {
      responseData = json.decode(response.body);
    } catch (e) {
      responseData = {'message': response.body};
    }

    if (statusCode >= 200 && statusCode < 300) {
      return {
        'success': true,
        'data': responseData,
        'statusCode': statusCode,
      };
    } else if (statusCode == 401) {
      return {
        'success': false,
        'message': responseData['detail'] ?? 'Session expired.  Please login again.',
        'statusCode': statusCode,
        'requiresReauth': true,
      };
    } else if (statusCode == 400) {
      String errorMessage = 'Invalid request';
      if (responseData. containsKey('non_field_errors')) {
        errorMessage = (responseData['non_field_errors'] as List). join(', ');
      } else if (responseData.containsKey('detail')) {
        errorMessage = responseData['detail'];
      } else if (responseData.containsKey('email')) {
        errorMessage = 'Email: ${(responseData['email'] as List).join(', ')}';
      } else if (responseData.containsKey('password')) {
        errorMessage = 'Password: ${(responseData['password'] as List).join(', ')}';
      } else {
        responseData. forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            errorMessage = '$key: ${value.join(', ')}';
          }
        });
      }
      return {
        'success': false,
        'message': errorMessage,
        'statusCode': statusCode,
        'errors': responseData,
      };
    } else if (statusCode == 403) {
      return {
        'success': false,
        'message': responseData['detail'] ??  'Access denied',
        'statusCode': statusCode,
      };
    } else if (statusCode == 404) {
      return {
        'success': false,
        'message': 'Resource not found',
        'statusCode': statusCode,
      };
    } else if (statusCode >= 500) {
      return {
        'success': false,
        'message': 'Server error.  Please try again later.',
        'statusCode': statusCode,
      };
    } else {
      return {
        'success': false,
        'message': responseData['detail'] ?? responseData['message'] ?? 'Unknown error occurred',
        'statusCode': statusCode,
      };
    }
  }

  Future<void> _saveAuthData(Map<String, dynamic> data, bool isUserLogin) async {
    final prefs = await SharedPreferences.getInstance();

    if (data['access'] != null) {
      await prefs.setString(_accessTokenKey, data['access']);
    }
    if (data['refresh'] != null) {
      await prefs.setString(_refreshTokenKey, data['refresh']);
    }
    if (data['user'] != null) {
      await prefs.setString(_userDataKey, json. encode(data['user']));
    }

    await prefs.setString(_userTypeKey, isUserLogin ? 'citizen' : 'worker');
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setBool(_demoModeKey, _isDemoMode);
    await _updateTokenExpiry();
  }

  Future<void> _updateTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now()
        .add(const Duration(minutes: 30))
        .millisecondsSinceEpoch;
    await prefs. setInt(_tokenExpiryKey, expiry);
  }

  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_userTypeKey);
    await prefs. remove(_tokenExpiryKey);
    await prefs.setBool(_isLoggedInKey, false);
    // Don't clear demo mode flag or demo users - they persist
  }

  Map<String, dynamic> _networkError() {
    return {
      'success': false,
      'message': 'No internet connection.  Please check your network.',
    };
  }

  Map<String, dynamic> _timeoutError() {
    return {
      'success': false,
      'message': 'Connection timeout. Please try again.',
    };
  }
}