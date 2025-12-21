import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neat_now/models/employee/profile_models.dart';
import 'package:neat_now/design/profile_design.dart';
import 'dart:io';

/// ==================== PROFILE VIEW STATE ====================
enum ProfileViewState {
  initial,
  loading,
  loaded,
  updating,
  error,
}

/// ==================== PROFILE VIEWMODEL ====================
class ProfileViewModel extends ChangeNotifier {
  // State
  ProfileViewState _viewState = ProfileViewState.initial;
  EmployeeProfile? _profile;
  EmployeeStats? _stats;
  List<BadgeInfo> _badges = [];
  List<TaskHistoryItem> _taskHistory = [];
  SettingsModel _settings = SettingsModel();
  String?  _errorMessage;
  bool _isDemoMode;

  // Edit Mode
  bool _isEditMode = false;
  bool _showLogoutConfirm = false;

  // Constructor
  ProfileViewModel({
    Map<String, dynamic>? userData,
    Map<String, dynamic>? employeeStats,
    bool isDemoMode = false,
  }) :  _isDemoMode = isDemoMode {
    if (userData != null) {
      _profile = EmployeeProfile.fromJson(userData);
    }
    if (employeeStats != null) {
      _stats = EmployeeStats.fromJson(employeeStats);
    }
    _loadInitialData();
  }

  // Getters - State
  ProfileViewState get viewState => _viewState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _viewState == ProfileViewState.loading;
  bool get isUpdating => _viewState == ProfileViewState.updating;
  bool get hasError => _viewState == ProfileViewState.error;
  bool get isDemoMode => _isDemoMode;
  bool get isEditMode => _isEditMode;
  bool get showLogoutConfirm => _showLogoutConfirm;

  // Getters - Data
  EmployeeProfile? get profile => _profile;
  EmployeeStats? get stats => _stats;
  List<BadgeInfo> get badges => _badges;
  List<TaskHistoryItem> get taskHistory => _taskHistory;
  SettingsModel get settings => _settings;

  // Computed Properties
  String get name => _profile?.name ?? 'Employee';
  String get email => _profile?.email ?? '';
  String get phone => _profile?.phone ?? '';
  String get employeeId => _profile?.employeeId ?? 'N/A';
  String?  get profileImage => _profile?.profileImage;

  double get rating => _stats?.rating ??  4.5;
  int get completedTasks => _stats?.completedTasks ?? 0;
  int get pendingTasks => _stats?.pendingTasks ??  0;
  int get totalPoints => _stats?.totalPoints ??  0;
  double get completionRate => _stats?.completionRate ?? 0.0;

  BadgeTier get tier => BadgeTierExtension.fromRating(rating);

  // ==================== ACTIONS ====================

  /// Load initial data
  Future<void> _loadInitialData() async {
    _viewState = ProfileViewState.loading;
    notifyListeners();

    try {
      await Future.wait([
        _loadBadges(),
        _loadTaskHistory(),
        _loadSettings(),
      ]);

      _viewState = ProfileViewState.loaded;
    } catch (e) {
      _viewState = ProfileViewState. error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Load earned badges
  Future<void> _loadBadges() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _badges = [
      BadgeInfo(
        id: '1',
        name: 'Speed Star',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFF59E0B),
        description:  '50 tasks in a month',
        earnedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      BadgeInfo(
        id: '2',
        name: 'Top Rated',
        icon: Icons.star_rounded,
        color: const Color(0xFFFFD700),
        description: '5.0 average rating',
        earnedAt:  DateTime.now().subtract(const Duration(days: 15)),
      ),
      BadgeInfo(
        id: '3',
        name: 'Early Bird',
        icon: Icons. wb_sunny_rounded,
        color: const Color(0xFF10B981),
        description: '20 early completions',
        earnedAt:  DateTime.now().subtract(const Duration(days: 20)),
      ),
      BadgeInfo(
        id: '4',
        name: 'Team Player',
        icon: Icons.group_rounded,
        color: const Color(0xFF3B82F6),
        description: 'Helped colleagues',
        earnedAt: DateTime. now().subtract(const Duration(days: 25)),
      ),
      BadgeInfo(
        id: '5',
        name: 'Marathon',
        icon: Icons.directions_run_rounded,
        color: const Color(0xFF8B5CF6),
        description:  '100 tasks total',
        earnedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  /// Load task history
  Future<void> _loadTaskHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _taskHistory = [
      TaskHistoryItem(
        id: '1',
        type: 'Plastic Waste',
        location: 'Main Street Park',
        completedAt: DateTime.now().subtract(const Duration(hours: 3)),
        rating: 5.0,
      ),
      TaskHistoryItem(
        id: '2',
        type: 'Organic Waste',
        location: 'Central Avenue',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        rating: 4.5,
      ),
      TaskHistoryItem(
        id:  '3',
        type: 'Mixed Waste',
        location: 'Riverside Garden',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        rating: 5.0,
      ),
      TaskHistoryItem(
        id: '4',
        type:  'Electronic Waste',
        location: 'Tech Park',
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        rating: 4.8,
      ),
      TaskHistoryItem(
        id: '5',
        type: 'Construction Debris',
        location: 'Oak Street',
        completedAt:  DateTime.now().subtract(const Duration(days: 5)),
        rating: 4.2,
      ),
    ];
  }

  /// Load settings
  Future<void> _loadSettings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real app, load from SharedPreferences
    _settings = SettingsModel();
  }

  /// Update profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_profile == null) return false;

    _viewState = ProfileViewState.updating;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      _profile = _profile!.copyWith(
        name: data['name'],
        email: data['email'],
        phone: data['phone'],
        profileImage: data['profileImage'],
      );

      _viewState = ProfileViewState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _viewState = ProfileViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update profile image
  Future<bool> updateProfileImage(File image) async {
    _viewState = ProfileViewState.updating;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      // In real app, upload to server and get URL
      final imageUrl = image.path;

      _profile = _profile?. copyWith(profileImage: imageUrl);

      _viewState = ProfileViewState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _viewState = ProfileViewState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update settings
  Future<void> updateSettings(SettingsModel newSettings) async {
    _settings = newSettings;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      // In real app, save to SharedPreferences
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }

  /// Toggle setting
  void toggleSetting(String settingName, bool value) {
    switch (settingName) {
      case 'notifications':
        _settings = _settings.copyWith(notificationsEnabled: value);
        break;
      case 'location':
        _settings = _settings. copyWith(locationEnabled: value);
        break;
      case 'darkMode':
        _settings = _settings.copyWith(darkModeEnabled: value);
        break;
      case 'sound':
        _settings = _settings.copyWith(soundEnabled: value);
        break;
    }
    notifyListeners();
    updateSettings(_settings);
  }

  /// Refresh data
  Future<void> refresh() async {
    await _loadInitialData();
  }

  /// UI State Management
  void setEditMode(bool value) {
    _isEditMode = value;
    notifyListeners();
  }

  void setLogoutConfirm(bool value) {
    _showLogoutConfirm = value;
    notifyListeners();
  }

  /// Get FAQ items
  List<FAQItem> getFAQs() {
    return [
      FAQItem(
        'How do I complete a task?',
        'Navigate to the task, tap "Complete", take a photo of the cleaned area, and submit.',
      ),
      FAQItem(
        'How is my rating calculated?',
        'Your rating is based on citizen feedback after each completed task.',
      ),
      FAQItem(
        'What are badges?',
        'Badges are achievements you earn for milestones like completing tasks quickly or maintaining high ratings.',
      ),
      FAQItem(
        'How do I update my profile?',
        'Go to Profile > Edit Profile to update your name, email, phone, and photo.',
      ),
      FAQItem(
        'Who do I contact for support?',
        'Reach out to your supervisor or email support@neatnow.com for assistance.',
      ),
    ];
  }

  /// Format date helper
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date. month}/${date.year}';
    }
  }
}