import 'package:flutter/material.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/employee_dashboard_models.dart';
import 'package:neat_now/models/employee/tab_item_model.dart';
import 'package:neat_now/services/employee_service.dart';
import 'package:neat_now/services/auth_service.dart';
import 'package:neat_now/providers/notification_provider.dart';

class EmployeeDashboardViewModel extends ChangeNotifier {
  final AuthService _authService;
  final NotificationProvider _notificationProvider;

  // State
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isDemoMode = false;
  bool _isSideNavExpanded = true;
  bool _hasShownOverdueDialog = false;
  bool _showFAB = false;

  // Data
  EmployeeUser?  _user;
  EmployeeStats?  _stats;
  List<Report> _reports = [];
  List<Report> _acceptedReports = [];
  AnalyticsData? _analytics;
  List<LeaderboardEntry> _leaderboard = [];
  OverdueAlert _overdueAlert = const OverdueAlert(count:  0, reports: []);

  // Getters
  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;
  bool get isSideNavExpanded => _isSideNavExpanded;
  bool get hasOverdueAlerts => _overdueAlert.hasOverdue;
  int get overdueCount => _overdueAlert.count;
  bool get hasShownOverdueDialog => _hasShownOverdueDialog;
  bool get showFAB => _showFAB;

  EmployeeUser?  get user => _user;
  EmployeeStats? get stats => _stats;
  List<Report> get reports => _reports;
  List<Report> get acceptedReports => _acceptedReports;
  AnalyticsData? get analytics => _analytics;
  List<LeaderboardEntry> get leaderboard => _leaderboard;

  int get notificationCount => _notificationProvider. totalBadgeCount + overdueCount;

  String get userName => _user?.name ?? 'Employee';
  String get userEmail => _user?.email ?? '';
  String?  get userProfileImage => _user?. profileImage;
  String get userAvatarInitial => _user?. avatarInitial ?? 'E';

  // Tab items (static data)
  static const List<TabItem> tabItems = [
    TabItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      shortLabel: 'Home',
      color: Color(0xFF2AC2AB),
      backgroundColor: Color(0xFFF0FDFB),
    ),
    TabItem(
      icon: Icons.assignment_outlined,
      activeIcon:  Icons.assignment_rounded,
      label: 'Reports',
      shortLabel: 'Tasks',
      color: Color(0xFFFF6B6B),
      backgroundColor: Color(0xFFFFF5F5),
    ),
    TabItem(
      icon: Icons.map_outlined,
      activeIcon:  Icons.map_rounded,
      label: 'Bins Map',
      shortLabel: 'Map',
      color: Color(0xFF4ECDC4),
      backgroundColor:  Color(0xFFF0FDFC),
    ),
    TabItem(
      icon: Icons.analytics_outlined,
      activeIcon:  Icons.analytics_rounded,
      label: 'Analytics',
      shortLabel: 'Stats',
      color: Color(0xFF95E1D3),
      backgroundColor: Color(0xFFF5FDFB),
    ),
    TabItem(
      icon: Icons. leaderboard_outlined,
      activeIcon: Icons.leaderboard_rounded,
      label: 'Leaderboard',
      shortLabel: 'Rank',
      color: Color(0xFFFFD93D),
      backgroundColor: Color(0xFFFFFDF5),
    ),
    TabItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons. person_rounded,
      label: 'Profile',
      shortLabel: 'Me',
      color: Color(0xFF6C5CE7),
      backgroundColor: Color(0xFFF8F7FF),
    ),
  ];

  TabItem get currentTab => tabItems[_selectedIndex];
  Color get currentColor => currentTab.color;
  Color get currentBackgroundColor => currentTab.backgroundColor;

  EmployeeDashboardViewModel({
    AuthService? authService,
    NotificationProvider?  notificationProvider,
  })  : _authService = authService ?? AuthService(),
        _notificationProvider = notificationProvider ?? NotificationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _initializeNotifications();
    await loadAllData();
  }

  Future<void> _initializeNotifications() async {
    await _notificationProvider.initialize();
    _notificationProvider.addListener(notifyListeners);
  }

  // Load all data
  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadEmployeeData(),
        _loadStats(),
        _loadReports(),
        _loadAcceptedReports(),
        _loadAnalytics(),
        _loadLeaderboard(),
      ]);
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadEmployeeData() async {
    try {
      _isDemoMode = await _authService.checkDemoMode();
      final cachedData = await _authService.getCachedUserData();

      if (cachedData != null) {
        _user = EmployeeUser.fromMap(cachedData);
      } else {
        final result = await _authService.getProfile();
        if (result['success'] == true && result['user'] != null) {
          _user = EmployeeUser.fromMap(result['user']);
        }
      }
    } catch (e) {
      debugPrint('Error loading employee data: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final data = await EmployeeService.getEmployeeStats();
      _stats = EmployeeStats.fromJson(data);
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _loadReports() async {
    try {
      final data = await EmployeeService.getReports();
      _reports = data.map((item) => Report.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading reports: $e');
    }
  }

  Future<void> _loadAcceptedReports() async {
    try {
      final data = await EmployeeService.getAcceptedReports();
      _acceptedReports = data.map((item) => Report.fromJson(item)).toList();
      _checkOverdueReports();
    } catch (e) {
      debugPrint('Error loading accepted reports: $e');
    }
  }

  Future<void> _loadAnalytics() async {
    try {
      final data = await EmployeeService.getAnalytics();
      _analytics = AnalyticsData.fromJson(data);
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      _leaderboard = await EmployeeService.getLeaderboard();
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
    }
  }

  void _checkOverdueReports() {
    final overdueReports = _acceptedReports
        .where((report) => report.isActive && report.isOverdue)
        .toList();

    _overdueAlert = OverdueAlert(
      count: overdueReports.length,
      reports: overdueReports,
    );
  }

  // Navigation
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
    _hasShownOverdueDialog = true;
    notifyListeners();
  }

  // Actions
  Future<void> refresh() async {
    await loadAllData();
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
// Add these methods to the existing EmployeeDashboardViewModel class

  // Page titles and subtitles
  String getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Reports';
      case 2: return 'Bins Map';
      case 3: return 'Analytics';
      case 4: return 'Leaderboard';
      case 5: return 'Profile';
      default: return 'Dashboard';
    }
  }

  String getPageSubtitle() {
    switch (_selectedIndex) {
      case 0: return 'Welcome back!  Here\'s your overview';
      case 1: return hasOverdueAlerts
          ? '$overdueCount tasks overdue!'
          : 'Manage and track all reports';
      case 2: return 'View waste bins on the map';
      case 3: return 'Performance metrics and insights';
      case 4: return 'See top performers this month';
      case 5: return 'Manage your account settings';
      default: return '';
    }
  }

  // Tab-specific alert checking
  bool hasTabAlert(int tabIndex) {
    return tabIndex == 1 && hasOverdueAlerts;
  }

  // Get current tab item
  TabItem getTabItem(int index) {
    return tabItems[index];
  }
  @override
  void dispose() {
    _notificationProvider.removeListener(notifyListeners);
    super.dispose();
  }
}