import 'package:flutter/material.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/employee_dashboard_models.dart';
import 'package:neat_now/models/employee/tab_item_model.dart';
import 'package:neat_now/services/employee_service.dart';
import 'package:neat_now/services/auth_service.dart';
import 'package:neat_now/providers/notification_provider.dart';

import '../../models/employee/leaderboard_models.dart';

class EmployeeMainDashboardViewModel extends ChangeNotifier {
  // Services
  final AuthService _authService;
  final NotificationProvider _notificationProvider;

  // State
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isDemoMode = false;
  bool _isSideNavExpanded = true;
  bool _showFAB = false;

  // Data
  EmployeeUser?  _user;
  OverdueData _overdueData = const OverdueData(count: 0);
  Map<String, dynamic> _employeeData = {};
  Map<String, dynamic> _employeeStats = {};

  // Futures for data loading
  Future<EmployeeStats>? _statsFuture;
  Future<List<Report>>? _reportsFuture;
  Future<List<Report>>? _acceptedReportsFuture;
  Future<AnalyticsData>? _analyticsFuture;
  Future<List<LeaderboardEntry>>? _leaderboardFuture;

  // Constructor
  EmployeeMainDashboardViewModel({
    AuthService? authService,
    NotificationProvider?   notificationProvider,
  })  : _authService = authService ?? AuthService(),
        _notificationProvider = notificationProvider ?? NotificationProvider() {
    _initialize();
  }

  // Getters - State
  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;
  bool get isSideNavExpanded => _isSideNavExpanded;
  bool get showFAB => _showFAB;

  // Getters - User
  EmployeeUser? get user => _user;
  Map<String, dynamic> get employeeData => _employeeData;
  Map<String, dynamic> get employeeStats => _employeeStats;
  String get userName => _user?.name ?? 'Employee';
  String get userEmail => _user?.email ?? '';
  String?  get userProfileImage => _user?. profileImage;
  String get userAvatarInitial => _user?. avatarInitial ?? 'E';

  // Getters - Overdue
  int get overdueCount => _overdueData.count;
  bool get hasOverdueAlerts => _overdueData.hasOverdue;
  bool get hasShownOverdueDialog => _overdueData.  hasShownDialog;

  // Getters - Notifications
  int get notificationCount =>
      _notificationProvider.totalBadgeCount + overdueCount;

  // Getters - Tabs
  List<TabItem> get tabItems => TabItem.defaultTabs;
  TabItem get currentTab => tabItems[_selectedIndex];
  Color get currentColor => currentTab.color;
  Color get currentBackgroundColor {
    const backgrounds = [
      Color(0xFFF0FDFB),
      Color(0xFFFFF5F5),
      Color(0xFFF0FDFC),
      Color(0xFFF5FDFB),
      Color(0xFFFFFDF5),
      Color(0xFFF8F7FF),
    ];
    return backgrounds[_selectedIndex];
  }

  // Getters - Data Futures
  Future<EmployeeStats>? get statsFuture => _statsFuture;
  Future<List<Report>>? get reportsFuture => _reportsFuture;
  Future<List<Report>>? get acceptedReportsFuture => _acceptedReportsFuture;
  Future<AnalyticsData>? get analyticsFuture => _analyticsFuture;
  Future<List<LeaderboardEntry>>?  get leaderboardFuture => _leaderboardFuture;
  // 1. Add to EmployeeMainDashboardViewModel:
  Future<List<LeaderboardEntry>> get safeLeaderboardFuture {
    return leaderboardFuture ?? Future<List<LeaderboardEntry>>. value(<LeaderboardEntry>[]);
  }





  // Initialize
  Future<void> _initialize() async {
    await _initializeNotifications();
    await _loadEmployeeData();
    _loadData();
  }

  Future<void> _initializeNotifications() async {
    await _notificationProvider.initialize();
    _notificationProvider.addListener(notifyListeners);
  }

  // Load employee data
  Future<void> _loadEmployeeData() async {
    try {
      _isDemoMode = await _authService.checkDemoMode();
      final cachedData = await _authService. getCachedUserData();

      if (cachedData != null) {
        _employeeData = cachedData;
        _user = EmployeeUser.fromMap(cachedData);
        _isLoading = false;
        notifyListeners();
      } else {
        final result = await _authService.getProfile();
        if (result['success'] == true && result['user'] != null) {
          _employeeData = result['user'];
          _user = EmployeeUser.fromMap(result['user']);
          _isLoading = false;
          notifyListeners();
        } else {
          _isLoading = false;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading employee data:  $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all dashboard data
  void _loadData() {
    _statsFuture = EmployeeService.getEmployeeStats().then((data) {
      _employeeStats = data;
      return EmployeeStats.fromJson(data);
    });

    _reportsFuture = EmployeeService.getReports()
        .then((data) => data.map((item) => Report.fromJson(item)).toList());

    _acceptedReportsFuture =
        EmployeeService.getAcceptedReports().then((data) {
          final reports = data.map((item) => Report.fromJson(item)).toList();
          _checkOverdueReports(reports);
          return reports;
        });

    _analyticsFuture = EmployeeService.getAnalytics()
        .then((data) => AnalyticsData.fromJson(data));

    _leaderboardFuture = EmployeeService.getLeaderboard();
  }

  // Check for overdue reports
  void _checkOverdueReports(List<Report> reports) {
    int overdueCount = 0;
    for (final report in reports) {
      if (report.isActive && report.isOverdue) {
        overdueCount++;
      }
    }

    _overdueData = OverdueData(
      count: overdueCount,
      hasOverdue: overdueCount > 0,
      hasShownDialog: _overdueData.hasShownDialog,
    );
    notifyListeners();
  }

  // Actions - Navigation
  void selectTab(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleSideNav() {
    _isSideNavExpanded = ! _isSideNavExpanded;
    notifyListeners();
  }

  void setFABVisibility(bool show) {
    if (_showFAB != show) {
      _showFAB = show;
      notifyListeners();
    }
  }

  void markOverdueDialogShown() {
    _overdueData = _overdueData.  copyWith(hasShownDialog:  true);
    notifyListeners();
  }

  // Actions - Data
  Future<void> refresh() async {
    _loadData();
    await _loadEmployeeData();
  }

  Future<bool> updateReportStatus(
      int reportId,
      String status, {
        String? imagePath,
        double? latitude,
        double? longitude,
        String? locationAddress,
      }) async {
    try {
      final success = await EmployeeService.updateReportStatus(
        reportId,
        status,
        verificationImagePath: imagePath,
        latitude: latitude,
        longitude: longitude,
        locationAddress: locationAddress,
      );

      if (success) {
        await refresh();
      }

      return success;
    } catch (e) {
      debugPrint('Error updating report status: $e');
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final result = await _authService.logout();
      return result['success'] == true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      return false;
    }
  }

  // Helper - Check if tab has alert
  bool hasTabAlert(int index) {
    return index == 1 && hasOverdueAlerts;
  }

  @override
  void dispose() {
    _notificationProvider.removeListener(notifyListeners);
    super.dispose();
  }
}