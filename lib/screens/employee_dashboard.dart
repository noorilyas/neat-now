import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/services/employee_service.dart';
import 'package:neat_now/services/auth_service.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'package:neat_now/widgets/employee/dashboard_tab.dart';
import 'package:neat_now/widgets/employee/reports_tab.dart';
import 'package:neat_now/widgets/employee/map_tab.dart';
import 'package:neat_now/widgets/employee/analytics_tab.dart';
import 'package:neat_now/widgets/employee/profile_tab.dart';
import 'package:neat_now/widgets/employee/leaderboard_page.dart';
import 'package:neat_now/widgets/employee/notifications_page.dart';
import 'package:neat_now/widgets/employee/notification_overlay.dart';
import 'package:neat_now/providers/notification_provider.dart';
import 'dart:math' as math;

/// ==================== COLOR SYSTEM ====================
class AppColors {
  static const Color primaryGreen = Color(0xFF2AC2AB);
  static const Color primaryRed = Color(0xFFFF6B6B);
  static const Color primaryBlue = Color(0xFF4ECDC4);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color primaryMint = Color(0xFF95E1D3);

  static const Color success = Color(0xFF2AC2AB);
  static const Color error = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD93D);
  static const Color info = Color(0xFF4ECDC4);

  static const List<Color> tabColors = [
    Color(0xFF2AC2AB),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF95E1D3),
    Color(0xFFFFD93D),
    Color(0xFF6C5CE7),
  ];

  static const List<Color> tabBackgrounds = [
    Color(0xFFF0FDFB),
    Color(0xFFFFF5F5),
    Color(0xFFF0FDFC),
    Color(0xFFF5FDFB),
    Color(0xFFFFFDF5),
    Color(0xFFF8F7FF),
  ];
}

/// ==================== EMPLOYEE DASHBOARD ====================
class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard>
    with TickerProviderStateMixin {

  final AuthService _authService = AuthService();
  final NotificationProvider _notificationProvider = NotificationProvider();

  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isDemoMode = false;
  bool _isSideNavExpanded = true;
  bool _hasOverdueAlerts = false;
  int _overdueCount = 0;
  bool _hasShownOverdueDialog = false;
  bool _showFAB = false;

  late Future<EmployeeStats> _statsFuture;
  late Future<List<Report>> _reportsFuture;
  late Future<List<Report>> _acceptedReportsFuture;
  late Future<AnalyticsData> _analyticsFuture;
  late Future<List<LeaderboardEntry>> _leaderboardFuture;

  Map<String, dynamic> _employeeData = {};
  Map<String, dynamic> _employeeStats = {};

  // Animation Controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _sideNavController;
  late AnimationController _pageTransitionController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _alertController;
  late Animation<double> _alertAnimation;
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  static const List<_TabItem> _tabItems = [
    _TabItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard', 'Home', AppColors.primaryGreen),
    _TabItem(Icons.assignment_outlined, Icons. assignment_rounded, 'Reports', 'Tasks', AppColors.primaryRed),
    _TabItem(Icons.map_outlined, Icons. map_rounded, 'Bins Map', 'Map', AppColors.primaryBlue),
    _TabItem(Icons.analytics_outlined, Icons.analytics_rounded, 'Analytics', 'Stats', AppColors.primaryMint),
    _TabItem(Icons. leaderboard_outlined, Icons.leaderboard_rounded, 'Leaderboard', 'Rank', AppColors.primaryYellow),
    _TabItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', 'Me', AppColors.primaryPurple),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _initializeAnimations();
    _initializeNotifications();
    _setupScrollListener();
    _loadData();
    _loadEmployeeData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves. easeOutQuart);
    _fadeController.forward();

    _sideNavController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this, value: 1.0);

    _pageTransitionController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _slideAnimation = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(parent: _pageTransitionController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pageTransitionController, curve: Curves. easeOutCubic),
    );

    _shimmerController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this).. repeat();
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0). animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _rotateController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi). animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _fabController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _alertController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _alertAnimation = Tween<double>(begin: 0.0, end: 1.0). animate(
      CurvedAnimation(parent: _alertController, curve: Curves. easeInOut),
    );

    _logoController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _logoAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoController.forward();
  }

  void _setupScrollListener() {
    _scrollController. addListener(() {
      final shouldShowFAB = _scrollController.offset > 100;
      if (_showFAB != shouldShowFAB) {
        setState(() => _showFAB = shouldShowFAB);
        shouldShowFAB ?  _fabController.forward() : _fabController.reverse();
      }
    });
  }

  Future<void> _initializeNotifications() async {
    await _notificationProvider.initialize();
    _notificationProvider.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _toggleSideNav() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSideNavExpanded = !_isSideNavExpanded;
      _isSideNavExpanded ? _sideNavController.forward() : _sideNavController.reverse();
    });
  }

  void _loadData() {
    _statsFuture = EmployeeService. getEmployeeStats(). then((data) {
      _employeeStats = data;
      return EmployeeStats.fromJson(data);
    });

    _reportsFuture = EmployeeService.getReports()
        .then((data) => data.map((item) => Report.fromJson(item)).toList());

    _acceptedReportsFuture = EmployeeService.getAcceptedReports(). then((data) {
      final reports = data.map((item) => Report.fromJson(item)).toList();
      _checkOverdueReports(reports);
      return reports;
    });

    _analyticsFuture = EmployeeService.getAnalytics()
        .then((data) => AnalyticsData.fromJson(data));

    _leaderboardFuture = EmployeeService.getLeaderboard();
  }

  void _checkOverdueReports(List<Report> reports) {
    int overdueCount = 0;
    for (final report in reports) {
      if (report.isActive && report.isOverdue) {
        overdueCount++;
      }
    }

    if (mounted) {
      setState(() {
        _overdueCount = overdueCount;
        _hasOverdueAlerts = overdueCount > 0;
      });

      if (_hasOverdueAlerts) {
        _pulseController.repeat(reverse: true);
        _alertController.repeat(reverse: true);
        if (! _hasShownOverdueDialog) {
          _hasShownOverdueDialog = true;
          _showOverdueAlert();
        }
      }
    }
  }

  void _showOverdueAlert() {
    if (! mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (! mounted) return;
      HapticFeedback.heavyImpact();
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'Overdue Alert',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _OverdueAlertDialog(
            overdueCount: _overdueCount,
            onViewTasks: () {
              Navigator.pop(context);
              _onTabSelected(1);
            },
            onDismiss: () => Navigator.pop(context),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      );
    });
  }

  Future<void> _loadEmployeeData() async {
    try {
      _isDemoMode = await _authService.checkDemoMode();
      final cachedData = await _authService.getCachedUserData();

      if (cachedData != null) {
        if (mounted) {
          setState(() {
            _employeeData = cachedData;
            _isLoading = false;
          });
        }
      } else {
        final result = await _authService.getProfile();
        if (result['success'] == true && result['user'] != null && mounted) {
          setState(() {
            _employeeData = result['user'];
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error loading employee data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _refreshData() {
    HapticFeedback.mediumImpact();
    _rotateController.forward(from: 0.0);
    setState(() {
      _loadData();
      _loadEmployeeData();
    });
    _showEnhancedSnackBar('Data refreshed successfully', isSuccess: true);
  }

  void _showEnhancedSnackBar(String message, {bool isSuccess = true}) {
    if (! mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white. withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.error_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow. ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogout() async {
    HapticFeedback.heavyImpact();
    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Logout',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => _EnhancedLogoutDialog(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );

    if (confirm == true && mounted) {
      final result = await _authService.logout();
      if (result['success'] == true && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _onTabSelected(int index) {
    if (_selectedIndex == index) return;
    HapticFeedback.selectionClick();
    _pageTransitionController.forward(from: 0.0);
    setState(() => _selectedIndex = index);

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.selectionClick();
      _pageTransitionController.forward(from: 0.0);
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _updateReportStatus(
      int reportId,
      String status, {
        String?  imagePath,
        double? latitude,
        double?  longitude,
        String? locationAddress,
      }) async {
    final success = await EmployeeService.updateReportStatus(
      reportId,
      status,
      verificationImagePath: imagePath,
      latitude: latitude,
      longitude: longitude,
      locationAddress: locationAddress,
    );

    if (mounted) {
      _showEnhancedSnackBar(
        success
            ? (status == 'resolved' ? 'Report resolved!' : 'Status updated')
            : 'Failed to update',
        isSuccess: success,
      );
      if (success) _refreshData();
    }
  }

  void _showNotificationsPage() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EmployeeResponsiveHelper(
            builder: (context, responsive) => NotificationsPage(responsive: responsive),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero). animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves. easeOutCubic);
  }

  void _onLogoTap() {
    HapticFeedback.lightImpact();
    _bounceController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sideNavController.dispose();
    _pageTransitionController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    _rotateController. dispose();
    _fabController.dispose();
    _pulseController.dispose();
    _alertController. dispose();
    _logoController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        return NotificationOverlay(
          responsive: responsive,
          child: AnimatedContainer(
            duration: responsive.animationDuration,
            decoration: BoxDecoration(
              color: AppColors.tabBackgrounds[_selectedIndex],
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _isLoading
                      ? _buildEnhancedLoadingState(responsive)
                      : _buildLayout(responsive),
                ),
              ),
              floatingActionButton: responsive.showFab ?  _buildScrollToTopFAB(responsive) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollToTopFAB(EmployeeResponsiveData responsive) {
    if (! _showFAB) return const SizedBox. shrink();
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton. small(
        onPressed: _scrollToTop,
        backgroundColor: _tabItems[_selectedIndex]. color,
        elevation: 8,
        child: Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: responsive.iconSize(20)),
      ),
    );
  }

  Widget _buildLayout(EmployeeResponsiveData responsive) {
    // Determine layout based on screen size
    if (responsive.showSideNav) {
      return _buildDesktopLayout(responsive);
    } else if (responsive.showRailNav) {
      return _buildTabletLayout(responsive);
    } else {
      return _buildMobileLayout(responsive);
    }
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(EmployeeResponsiveData responsive) {
    return Column(
      children: [
        _buildMobileAppBar(responsive),
        if (_hasOverdueAlerts) _buildOverdueBanner(responsive),
        Expanded(
          child: AnimatedBuilder(
            animation: _pageTransitionController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_slideAnimation. value * 50, 0),
                child: Transform.scale(scale: _scaleAnimation. value, child: child),
              );
            },
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: _buildTabContent(responsive),
            ),
          ),
        ),
        if (responsive.showBottomNav) _buildMobileBottomNav(responsive),
      ],
    );
  }

  Widget _buildMobileAppBar(EmployeeResponsiveData responsive) {
    final notificationCount = _notificationProvider.totalBadgeCount + _overdueCount;
    final currentColor = _tabItems[_selectedIndex].color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive. horizontalPadding,
        vertical: responsive.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: responsive.cardShadow,
      ),
      child: Row(
        children: [
          // Logo
          if (responsive.showAnyIcons)
            GestureDetector(
              onTap: _onLogoTap,
              child: AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) => Transform.scale(scale: _bounceAnimation.value, child: child),
                child: ScaleTransition(
                  scale: _logoAnimation,
                  child: Container(
                    width: responsive.avatarSize,
                    height: responsive. avatarSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [currentColor, currentColor. withOpacity(0.7)],
                        begin: Alignment. topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
                      boxShadow: responsive.coloredShadow(currentColor),
                    ),
                    child: Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: responsive. iconSize(16),
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(width: responsive.microPadding),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize. min,
              children: [
                if (responsive.showMinimalText)
                  Text(
                    responsive.adaptiveText(
                      'Neat Now',
                      nano: 'N',
                      ultraMicro: 'NN',
                      micro: 'NN',
                      mini: 'Neat',
                    ),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight. bold,
                      fontSize: responsive.headingXS,
                      color: Colors.grey[900],
                    ),
                    overflow: TextOverflow. ellipsis,
                  ),
                if (responsive.showSecondaryText)
                  AnimatedDefaultTextStyle(
                    duration: responsive.animationDuration,
                    style: GoogleFonts.poppins(
                      fontSize: responsive.captionM,
                      color: currentColor,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Text(_tabItems[_selectedIndex].label),
                  ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasOverdueAlerts && responsive.showBadges)
                _buildPulsingOverdueIndicator(responsive),
              if (_isDemoMode && responsive. showAbbreviatedText)
                _buildDemoBadge(responsive),
              if (responsive.showAppBarActions)
                _buildRotatingRefreshButton(responsive),
              _buildNotificationButton(responsive, notificationCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingOverdueIndicator(EmployeeResponsiveData responsive) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
                margin: EdgeInsets. only(right: responsive.nanoPadding),
                padding: EdgeInsets. all(responsive.nanoPadding),
                decoration: BoxDecoration(
                  color: Colors.red. withOpacity(0.1),
                  borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
                  border: Border.all(
                    color: Colors. red.withOpacity(0.3 + (_pulseAnimation.value - 1) * 2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Icon(
                  Icons.warning_amber_rounded,
                  size: responsive.iconSize(14),
                  color: Colors.red,
                ),
                if (responsive.showShortLabels) ...[
            SizedBox(width: responsive.atomicPadding),
        Text(
        '$_overdueCount',
        style: GoogleFonts. poppins(
        fontSize: responsive.captionS,
        fontWeight: FontWeight. bold,
        color: Colors.red,
        ),
        ),
        ],
        ],
        ),
        ),
        );
      },
    );
  }

  Widget _buildRotatingRefreshButton(EmployeeResponsiveData responsive) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) => Transform.rotate(angle: _rotateAnimation.value, child: child),
      child: _buildIconButton(
        responsive,
        icon: Icons.refresh_rounded,
        onTap: _refreshData,
        color: _tabItems[_selectedIndex].color,
      ),
    );
  }

  Widget _buildNotificationButton(EmployeeResponsiveData responsive, int count) {
    final hasOverdue = _hasOverdueAlerts;
    final color = hasOverdue ?  Colors.red : _tabItems[_selectedIndex].color;

    return Stack(
      children: [
        _buildIconButton(
          responsive,
          icon: Icons.notifications_none_rounded,
          onTap: _showNotificationsPage,
          color: color,
        ),
        if (count > 0 && responsive.showBadges)
          Positioned(
            right: responsive.atomicPadding,
            top: responsive.atomicPadding,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(scale: value, child: child),
              child: Container(
                padding: EdgeInsets.all(responsive.atomicPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasOverdue ? [Colors.red, Colors. red.shade700] : [color, color.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: responsive.coloredShadow(hasOverdue ? Colors. red : color, opacity: 0.5),
                ),
                constraints: BoxConstraints(
                  minWidth: responsive.dimension(14),
                  minHeight: responsive.dimension(14),
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: GoogleFonts.poppins(
                      fontSize: responsive.captionXS,
                      fontWeight: FontWeight.bold,
                      color: Colors. white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconButton(
      EmployeeResponsiveData responsive, {
        required IconData icon,
        required VoidCallback onTap,
        required Color color,
      }) {
    return SizedBox(
      width: responsive.buttonHeightSmall,
      height: responsive.buttonHeightSmall,
      child: Material(
        color: color. withOpacity(0.08),
        borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
          child: Icon(icon, size: responsive.iconSize(18), color: color),
        ),
      ),
    );
  }

  Widget _buildDemoBadge(EmployeeResponsiveData responsive) {
    return Container(
      margin: EdgeInsets. only(right: responsive.nanoPadding),
      padding: EdgeInsets.symmetric(
        horizontal: responsive. nanoPadding,
        vertical: responsive.atomicPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.pillBorderRadius),
        border: Border. all(color: Colors.orange. withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_rounded, size: responsive. iconSize(12), color: Colors. orange),
          if (responsive.showIconLabels) ...[
            SizedBox(width: responsive.atomicPadding),
            Text(
              'Demo',
              style: GoogleFonts.poppins(
                fontSize: responsive.captionXS,
                fontWeight: FontWeight. w600,
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverdueBanner(EmployeeResponsiveData responsive) {
    return AnimatedBuilder(
      animation: _alertAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets. symmetric(
            horizontal: responsive. padding,
            vertical: responsive.microPadding,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors. red.shade600,
                Colors. red.shade400. withOpacity(0.85 + (_alertAnimation.value * 0.15)),
              ],
            ),
            boxShadow: responsive.coloredShadow(Colors.red, opacity: 0.4),
          ),
          child: Row(
            children: [
              if (responsive.showStatusIndicators)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1.15),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => Transform.scale(scale: value, child: child),
                  child: Container(
                    padding: EdgeInsets.all(responsive.nanoPadding),
                    decoration: BoxDecoration(
                      color: Colors. white.withOpacity(0.2),
                      borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: responsive.iconSize(16),
                    ),
                  ),
                ),
              SizedBox(width: responsive.microPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (responsive.showMinimalText)
                      Text(
                        responsive.adaptiveText(
                          'Overdue Alert! ',
                          nano: '! ',
                          ultraMicro: '!! ',
                          micro: 'Alert',
                          mini: 'Overdue! ',
                        ),
                        style: GoogleFonts. poppins(
                          fontSize: responsive.captionL,
                          fontWeight: FontWeight. bold,
                          color: Colors.white,
                        ),
                      ),
                    if (responsive.showSecondaryText)
                      Text(
                        '$_overdueCount task${_overdueCount > 1 ? 's' : ''} > 2 days',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.captionS,
                          color: Colors.white. withOpacity(0.95),
                        ),
                      ),
                  ],
                ),
              ),
              if (responsive.showAppBarActions)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _onTabSelected(1);
                    },
                    borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.microPadding,
                        vertical: responsive.nanoPadding,
                      ),
                      child: Text(
                        'View',
                        style: GoogleFonts. poppins(
                          fontSize: responsive.captionS,
                          fontWeight: FontWeight. bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileBottomNav(EmployeeResponsiveData responsive) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.largeBorderRadius)),
        boxShadow: responsive.elevatedShadow,
      ),
      child: Container(
        height: responsive.bottomNavHeight + bottomPadding,
        padding: EdgeInsets.only(
          left: responsive.nanoPadding,
          right: responsive. nanoPadding,
          top: responsive.nanoPadding,
          bottom: bottomPadding + responsive.nanoPadding,
        ),
        child: Row(
          children: _tabItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _selectedIndex == index;
            final hasAlert = index == 1 && _hasOverdueAlerts;

            return Expanded(
              child: _buildNavItem(responsive, item, index, isSelected, hasAlert),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      EmployeeResponsiveData responsive,
      _TabItem item,
      int index,
      bool isSelected,
      bool hasAlert,
      ) {
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: isSelected ? 0.9 : 1.0, end: 1.0),
        duration: responsive.animationDurationFast,
        curve: Curves.easeOut,
        builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
        child: AnimatedContainer(
          duration: responsive.animationDuration,
          curve: Curves.easeInOut,
          margin: EdgeInsets. symmetric(horizontal: responsive. atomicPadding),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.nanoPadding,
            vertical: responsive.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? item.color. withOpacity(0.12)
                : hasAlert
                ?  Colors.red.withOpacity(0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(responsive.borderRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment. center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wave indicator
              AnimatedContainer(
                duration: responsive.animationDuration,
                height: responsive.dimension(3),
                width: isSelected ? responsive.dimension(20) : 0,
                margin: EdgeInsets. only(bottom: responsive. nanoPadding),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(responsive.tinyBorderRadius),
                ),
              ),
              // Icon
              Stack(
                children: [
                  if (index == 5)
                    _buildProfileNavIcon(responsive, isSelected, item.color)
                  else
                    AnimatedSwitcher(
                      duration: responsive.animationDuration,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        key: ValueKey(isSelected),
                        size: responsive.iconSize(20),
                        color: hasAlert
                            ? Colors. red
                            : isSelected
                            ?  item.color
                            : Colors. grey[500],
                      ),
                    ),
                  if (hasAlert && responsive.showBadges)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: responsive.dimension(8),
                        height: responsive.dimension(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors. white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              // Label
              if (responsive.showIconLabels) ...[
                SizedBox(height: responsive.atomicPadding),
                AnimatedDefaultTextStyle(
                  duration: responsive. animationDuration,
                  style: GoogleFonts.poppins(
                    fontSize: responsive.captionXS,
                    fontWeight: isSelected ? FontWeight. w600 : FontWeight.w500,
                    color: hasAlert
                        ? Colors. red
                        : isSelected
                        ? item.color
                        : Colors. grey[500],
                  ),
                  child: Text(
                    responsive.adaptiveText(
                      item. shortLabel,
                      nano: item.shortLabel[0],
                      ultraMicro: item.shortLabel[0],
                      micro: item.shortLabel. substring(0, math.min(2, item.shortLabel.length)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavIcon(EmployeeResponsiveData responsive, bool isSelected, Color color) {
    final profileImage = _employeeData['profile_image'] ??  _employeeData['profileImage'];
    final name = _employeeData['name'] ?? 'E';
    final size = responsive.iconSize(20) + 4;

    return AnimatedContainer(
      duration: responsive.animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Colors.grey. withOpacity(0.4),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected ? responsive.coloredShadow(color, opacity: 0.4) : null,
      ),
      child: ClipOval(
        child: profileImage != null && profileImage.isNotEmpty
            ? Image.network(
          profileImage,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatarInitial(responsive, name, size, color),
        )
            : _buildAvatarInitial(responsive, name, size, color),
      ),
    );
  }

  Widget _buildAvatarInitial(EmployeeResponsiveData responsive, String name, double size, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name. isNotEmpty ? name[0]. toUpperCase() : 'E',
          style: GoogleFonts.poppins(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==================== TABLET LAYOUT ====================
  Widget _buildTabletLayout(EmployeeResponsiveData responsive) {
    return Row(
      children: [
        _buildCompactRailNav(responsive),
        Container(width: 1, color: Colors.grey.withOpacity(0.12)),
        Expanded(
          child: Column(
            children: [
              _buildDesktopAppBar(responsive),
              if (_hasOverdueAlerts) _buildOverdueBanner(responsive),
              Expanded(child: _buildContentArea(responsive)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactRailNav(EmployeeResponsiveData responsive) {
    final currentColor = _tabItems[_selectedIndex].color;

    return Container(
      width: responsive.sideNavCollapsedWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: responsive.cardShadow,
      ),
      child: Column(
          children: [
          _buildSideNavHeader(responsive, false),
      SizedBox(height: responsive.microPadding),
      Expanded(
        child: ListView(
            padding: EdgeInsets. symmetric(horizontal: responsive. nanoPadding, vertical: responsive.nanoPadding),
            children: [
            ..._tabItems.asMap().entries.map((entry) {
          final hasAlert = entry.key == 1 && _hasOverdueAlerts;
          return _buildSideNavItem(responsive, entry.value, entry.key, _selectedIndex == entry.key, false, hasAlert);
        }),
        SizedBox(height: responsive.padding),
        Divider(color: Colors.grey. withOpacity(0.12), height: 1),
        SizedBox(height: responsive.microPadding),
        _buildLogoutNavItem(responsive, false),
        ],
      ),
    ),
    ],
    ),
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout(EmployeeResponsiveData responsive) {
    final sideNavWidth = _isSideNavExpanded ? responsive.sideNavWidth : responsive.sideNavCollapsedWidth;

    return Row(
      children: [
        AnimatedContainer(
          duration: responsive.animationDuration,
          curve: Curves.easeInOut,
          width: sideNavWidth,
          child: _buildFullSideNav(responsive),
        ),
        Container(width: 1, color: Colors. grey.withOpacity(0.12)),
        Expanded(
          child: Column(
            children: [
              _buildDesktopAppBar(responsive),
              if (_hasOverdueAlerts) _buildOverdueBanner(responsive),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.all(responsive. padding),
                      child: _buildContentArea(responsive),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullSideNav(EmployeeResponsiveData responsive) {
    final isExpanded = _isSideNavExpanded;
    final currentColor = _tabItems[_selectedIndex]. color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: responsive.cardShadow,
      ),
      child: Column(
        children: [
          _buildSideNavHeader(responsive, isExpanded),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive. microPadding, vertical: responsive.nanoPadding),
              child: _buildCollapseButton(responsive),
            )
          else
            Padding(
              padding: EdgeInsets. symmetric(vertical: responsive.nanoPadding),
              child: _buildExpandButton(responsive),
            ),
          if (_isDemoMode && isExpanded)
            Padding(
              padding: EdgeInsets. symmetric(horizontal: responsive. microPadding, vertical: responsive.nanoPadding),
              child: _buildDemoBadgeFull(responsive),
            ),
          if (_hasOverdueAlerts && isExpanded) _buildSidebarOverdueAlert(responsive),
          SizedBox(height: responsive.microPadding),
          Divider(color: Colors.grey.withOpacity(0.12), height: 1),
          SizedBox(height: responsive.microPadding),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: responsive.microPadding, vertical: responsive.nanoPadding),
              children: [
                ..._tabItems. asMap().entries. map((entry) {
                  final hasAlert = entry.key == 1 && _hasOverdueAlerts;
                  return _buildSideNavItem(responsive, entry.value, entry.key, _selectedIndex == entry. key, isExpanded, hasAlert);
                }),
                SizedBox(height: responsive.padding),
                Divider(color: Colors.grey.withOpacity(0.12), height: 1),
                SizedBox(height: responsive.microPadding),
                _buildLogoutNavItem(responsive, isExpanded),
              ],
            ),
          ),
          if (isExpanded) _buildUserCard(responsive),
        ],
      ),
    );
  }

  Widget _buildSideNavHeader(EmployeeResponsiveData responsive, bool expanded) {
    final currentColor = _tabItems[_selectedIndex]. color;

    return Container(
      padding: EdgeInsets. all(expanded ? responsive.padding : responsive.microPadding),
      child: Row(
        mainAxisAlignment: expanded ? MainAxisAlignment. start : MainAxisAlignment. center,
        children: [
          GestureDetector(
            onTap: _onLogoTap,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) => Transform.scale(scale: _bounceAnimation.value, child: child),
              child: AnimatedContainer(
                duration: responsive.animationDuration,
                padding: EdgeInsets. all(responsive.microPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [currentColor, currentColor.withOpacity(0.7)],
                    begin: Alignment. topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius. circular(responsive.borderRadius),
                  boxShadow: responsive.coloredShadow(currentColor),
                ),
                child: Icon(Icons.eco_rounded, color: Colors.white, size: responsive.iconSize(20)),
              ),
            ),
          ),
          if (expanded) ...[
            SizedBox(width: responsive.microPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  Text(
                    'Neat Now',
                    style: GoogleFonts.poppins(
                      fontSize: responsive.headingXS,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                    overflow: TextOverflow. ellipsis,
                  ),
                  AnimatedDefaultTextStyle(
                    duration: responsive.animationDuration,
                    style: GoogleFonts.poppins(
                      fontSize: responsive.captionM,
                      color: currentColor,
                      fontWeight: FontWeight.w500,
                    ),
                    child: const Text('Employee Portal'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapseButton(EmployeeResponsiveData responsive) {
    return Material(
      color: Colors.grey.withOpacity(0.06),
      borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
      child: InkWell(
        onTap: _toggleSideNav,
        borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        child: Container(
          padding: EdgeInsets. symmetric(horizontal: responsive. microPadding, vertical: responsive.nanoPadding),
          child: Row(
            children: [
              Icon(Icons.menu_open_rounded, size: responsive. iconSize(18), color: Colors. grey[600]),
              SizedBox(width: responsive.microPadding),
              Expanded(
                child: Text(
                  'Collapse',
                  style: GoogleFonts.poppins(fontSize: responsive.captionL, color: Colors.grey[600]),
                ),
              ),
              Icon(Icons.chevron_left_rounded, size: responsive.iconSize(18), color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton(EmployeeResponsiveData responsive) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleSideNav,
        borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
        child: Container(
          width: responsive.buttonHeightSmall,
          height: responsive.buttonHeightSmall,
          alignment: Alignment.center,
          child: Icon(Icons. menu_rounded, size: responsive. iconSize(22), color: Colors. grey[700]),
        ),
      ),
    );
  }

  Widget _buildDemoBadgeFull(EmployeeResponsiveData responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets. symmetric(horizontal: responsive. microPadding, vertical: responsive.nanoPadding),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.science_rounded, size: responsive.iconSize(16), color: Colors. orange),
          SizedBox(width: responsive. microPadding),
          Expanded(
            child: Text(
              'Demo Mode',
              style: GoogleFonts. poppins(
                fontSize: responsive. captionL,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarOverdueAlert(EmployeeResponsiveData responsive) {
    return Container(
      margin: EdgeInsets. symmetric(horizontal: responsive. microPadding, vertical: responsive.nanoPadding),
      padding: EdgeInsets.all(responsive.microPadding),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border. all(color: Colors.red.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(scale: _pulseAnimation. value, child: child),
            child: Icon(Icons.warning_amber_rounded, size: responsive.iconSize(18), color: Colors.red),
          ),
          SizedBox(width: responsive.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overdue Tasks',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.captionL,
                    fontWeight: FontWeight. bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '$_overdueCount task${_overdueCount > 1 ?  's' : ''} > 2 days',
                  style: GoogleFonts. poppins(
                    fontSize: responsive.captionS,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavItem(
      EmployeeResponsiveData responsive,
      _TabItem item,
      int index,
      bool isSelected,
      bool expanded,
      bool hasAlert,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.nanoPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabSelected(index),
          borderRadius: BorderRadius. circular(responsive.borderRadius),
          child: AnimatedContainer(
            duration: responsive.animationDuration,
            padding: EdgeInsets. symmetric(
              horizontal: expanded ? responsive.microPadding : 0,
              vertical: responsive.microPadding,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [item.color.withOpacity(0.15), item.color. withOpacity(0.05)],
                begin: Alignment.centerLeft,
                end: Alignment. centerRight,
              )
                  : null,
              color: hasAlert && ! isSelected ?  Colors.red. withOpacity(0.06) : null,
              borderRadius: BorderRadius.circular(responsive.borderRadius),
              border: isSelected
                  ? Border. all(color: item.color.withOpacity(0.35))
                  : hasAlert
                  ? Border.all(color: Colors.red.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: expanded ? MainAxisAlignment. start : MainAxisAlignment. center,
              children: [
                Stack(
                  children: [
                    AnimatedContainer(
                      duration: responsive. animationDuration,
                      padding: EdgeInsets. all(responsive.nanoPadding),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item. color.withOpacity(0.15)
                            : hasAlert
                            ? Colors.red. withOpacity(0.1)
                            : Colors.grey. withOpacity(0.08),
                        borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: hasAlert ?  Colors.red : isSelected ?  item.color : Colors.grey[600],
                        size: responsive.iconSize(20),
                      ),
                    ),
                    if (hasAlert)
                      Positioned(
                        right: responsive.atomicPadding,
                        top: responsive.atomicPadding,
                        child: Container(
                          width: responsive.dimension(8),
                          height: responsive.dimension(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors. white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                if (expanded) ...[
                  SizedBox(width: responsive.microPadding),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.bodyS,
                        fontWeight: isSelected ?  FontWeight.w600 : FontWeight. w500,
                        color: hasAlert ?  Colors.red : isSelected ? item.color : Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasAlert)
                    Container(
                      padding: EdgeInsets. symmetric(horizontal: responsive. nanoPadding, vertical: responsive.atomicPadding),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius. circular(responsive.smallBorderRadius),
                      ),
                      child: Text(
                        '$_overdueCount',
                        style: GoogleFonts. poppins(
                          fontSize: responsive.captionS,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (isSelected)
                    Container(
                      width: responsive.dimension(8),
                      height: responsive.dimension(8),
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                        boxShadow: responsive.coloredShadow(item.color, opacity: 0.5),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutNavItem(EmployeeResponsiveData responsive, bool expanded) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleLogout,
        borderRadius: BorderRadius.circular(responsive. borderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: expanded ?  responsive.microPadding : 0,
            vertical: responsive.microPadding,
          ),
          child: Row(
            mainAxisAlignment: expanded ? MainAxisAlignment. start : MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets. all(responsive.nanoPadding),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
                ),
                child: Icon(Icons. logout_rounded, color: Colors.red, size: responsive. iconSize(20)),
              ),
              if (expanded) ...[
                SizedBox(width: responsive.microPadding),
                Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.bodyS,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(EmployeeResponsiveData responsive) {
    final profileImage = _employeeData['profile_image'] ?? _employeeData['profileImage'];
    final name = _employeeData['name'] ?? 'Employee';
    final email = _employeeData['email'] ?? '';
    final currentColor = _tabItems[_selectedIndex].color;

    return Container(
      margin: EdgeInsets. all(responsive.microPadding),
      padding: EdgeInsets. all(responsive.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey. shade50, Colors.grey.shade100. withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.avatarSize,
            height: responsive.avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: currentColor, width: 2.5),
              boxShadow: responsive.coloredShadow(currentColor, opacity: 0.3),
            ),
            child: ClipOval(
              child: profileImage != null && profileImage. isNotEmpty
                  ? Image.network(
                profileImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarInitial(responsive, name, responsive.avatarSize, currentColor),
              )
                  : _buildAvatarInitial(responsive, name, responsive. avatarSize, currentColor),
            ),
          ),
          SizedBox(width: responsive.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: responsive. captionL,
                    fontWeight: FontWeight. w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (responsive.showSecondaryText)
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: responsive.captionS,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            width: responsive.dimension(12),
            height: responsive.dimension(12),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border. all(color: Colors.white, width: 2),
              boxShadow: responsive.coloredShadow(Colors.green, opacity: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopAppBar(EmployeeResponsiveData responsive) {
    final notificationCount = _notificationProvider.totalBadgeCount + _overdueCount;
    final currentColor = _tabItems[_selectedIndex]. color;

    return Container(
      height: responsive.appBarHeight,
      padding: EdgeInsets.symmetric(horizontal: responsive. padding, vertical: responsive.microPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: responsive.cardShadow,
      ),
      child: Row(
        children: [
      Expanded(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: responsive.animationDuration,
            style: GoogleFonts.poppins(
              fontSize: responsive.headingS,
              fontWeight: FontWeight. bold,
              color: Colors.grey[900],
            ),
            child: Text(_getPageTitle()),
          ),
          if (responsive.showSecondaryText)
            AnimatedDefaultTextStyle(
              duration: responsive.animationDuration,
              style: GoogleFonts.poppins(
                fontSize: responsive.captionM,
                color: _hasOverdueAlerts && _selectedIndex == 1 ? Colors.red : currentColor,
                fontWeight: FontWeight.w500,
              ),
              child: Text(_getPageSubtitle()),
            ),
        ],
      ),
    ),
    if (responsive.showDetailedContent) _buildBreadcrumb(responsive, currentColor),
    Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    if (_hasOverdueAlerts && responsive.showTrends)
    _buildAppBarOverdueIndicator(responsive),
    if (_isDemoMode && responsive.showAbbreviatedText) ...[
    _buildDemoBadge(responsive),
    SizedBox(width: responsive.microPadding),
    ],
    if (responsive.showAppBarActions) ...[
    _buildIconButton(responsive, icon: Icons.search_rounded, onTap: () {}, color: currentColor),
    SizedBox(width: responsive.nanoPadding),
    ],
    _buildRotatingRefreshButton(responsive),
    SizedBox(width: responsive.nanoPadding),
    _buildNotificationButton(responsive, notificationCount),
    if (responsive.showDetailedContent) ...[
    SizedBox(width: responsive. nanoPadding),
    _buildIconButton(responsive, icon: Icons.settings_outlined, onTap: () => _onTabSelected(5), color: currentColor),
    ],
    ],
    ),
    ],
    ),
    );
  }

  Widget _buildBreadcrumb(EmployeeResponsiveData responsive, Color currentColor) {
    return Container(
      margin: EdgeInsets. only(right: responsive.padding),
      padding: EdgeInsets.symmetric(horizontal: responsive. microPadding, vertical: responsive.nanoPadding),
      decoration: BoxDecoration(
        color: currentColor. withOpacity(0.08),
        borderRadius: BorderRadius.circular(responsive.pillBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home_rounded, size: responsive.iconSize(14), color: Colors.grey[500]),
          SizedBox(width: responsive.nanoPadding),
          Text(
            'Dashboard',
            style: GoogleFonts. poppins(fontSize: responsive.captionM, color: Colors.grey[500]),
          ),
          Icon(Icons.chevron_right_rounded, size: responsive. iconSize(16), color: Colors. grey[400]),
          Text(
            _getPageTitle(),
            style: GoogleFonts. poppins(
              fontSize: responsive. captionM,
              fontWeight: FontWeight. w600,
              color: currentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarOverdueIndicator(EmployeeResponsiveData responsive) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets. only(right: responsive.microPadding),
          padding: EdgeInsets.symmetric(horizontal: responsive.microPadding, vertical: responsive.nanoPadding),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius. circular(responsive.pillBorderRadius),
            border: Border.all(color: Colors. red. withOpacity(0.35 + (_pulseAnimation.value - 1) * 2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, size: responsive.iconSize(16), color: Colors. red),
              SizedBox(width: responsive.nanoPadding),
              Text(
                '$_overdueCount overdue',
                style: GoogleFonts.poppins(
                  fontSize: responsive.captionM,
                  fontWeight: FontWeight. w600,
                  color: Colors. red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPageTitle() {
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

  String _getPageSubtitle() {
    switch (_selectedIndex) {
      case 0: return 'Welcome back!  Here\'s your overview';
      case 1: return _hasOverdueAlerts ? '$_overdueCount tasks overdue!' : 'Manage and track all reports';
      case 2: return 'View waste bins on the map';
      case 3: return 'Performance metrics and insights';
      case 4: return 'See top performers this month';
      case 5: return 'Manage your account settings';
      default: return '';
    }
  }

  // ==================== CONTENT AREA ====================
  Widget _buildContentArea(EmployeeResponsiveData responsive) {
    return AnimatedBuilder(
      animation: _pageTransitionController,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation. value, child: child);
      },
      child: IndexedStack(
        index: _selectedIndex,
        children: _buildTabContent(responsive),
      ),
    );
  }

  List<Widget> _buildTabContent(EmployeeResponsiveData responsive) {
    return [
      EmployeeDashboardTab(
        statsFuture: _statsFuture,
        acceptedReportsFuture: _acceptedReportsFuture,
        leaderboardFuture: _leaderboardFuture,
        onNavigateToTab: _onTabSelected,
        onRefresh: _refreshData,
        employeeData: _employeeData,
        isDemoMode: _isDemoMode,
        overdueCount: _overdueCount,
        responsive: responsive,
      ),
      EmployeeReportsTab(
        reportsFuture: _reportsFuture,
        onUpdateStatus: _updateReportStatus,
        onRefresh: _refreshData,
        overdueCount: _overdueCount,
        responsive: responsive,
      ),
      BinsMapTab(
        reportsFuture: _reportsFuture,
        onUpdateStatus: _updateReportStatus,
        onRefresh: _refreshData,
        responsive: responsive,
      ),
      EmployeeAnalyticsTab(
        analyticsFuture: _analyticsFuture,
        reportsFuture: _reportsFuture,
        onRefresh: _refreshData,
        responsive: responsive,
      ),
      LeaderboardPage(
        leaderboardFuture: _leaderboardFuture,
        currentUserId: _employeeData['id']?. toString() ?? '',
        onRefresh: _refreshData,
        responsive: responsive,
      ),
      EmployeeProfileTab(
        userData: _employeeData,
        employeeStats: _employeeStats,
        isDemoMode: _isDemoMode,
        onLogout: _handleLogout,
        onProfileUpdate: _loadEmployeeData,
        responsive: responsive,
      ),
    ];
  }

  // ==================== LOADING STATE ====================
  Widget _buildEnhancedLoadingState(EmployeeResponsiveData responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math. pi,
                child: Transform.scale(
                  scale: 0.8 + (math.sin(value * math.pi) * 0.2),
                  child: child,
                ),
              );
            },
            child: Container(
              width: responsive.avatarSizeLarge,
              height: responsive.avatarSizeLarge,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, Color(0xFF1FA896)],
                  begin: Alignment. topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius. circular(responsive.largeBorderRadius),
                boxShadow: responsive.coloredShadow(AppColors.primaryGreen),
              ),
              child: Icon(Icons.eco_rounded, color: Colors.white, size: responsive.iconSize(28)),
            ),
          ),
          SizedBox(height: responsive.padding),
          if (responsive.showMinimalText)
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                      end: Alignment(_shimmerAnimation.value, 0.0),
                      colors: [Colors.grey[400]!, Colors.grey[200]!, Colors.grey[400]!],
                    ). createShader(bounds);
                  },
                  child: Text(
                    responsive.adaptiveText(
                      'Loading your dashboard...',
                      nano: '.. .',
                      ultraMicro: '...',
                      micro: 'Loading',
                      mini: 'Loading.. .',
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: responsive. bodyS,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// ==================== SUPPORTING CLASSES ====================
class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String shortLabel;
  final Color color;

  const _TabItem(this.icon, this.activeIcon, this.label, this. shortLabel, this. color);
}

// ==================== OVERDUE ALERT DIALOG ====================
class _OverdueAlertDialog extends StatelessWidget {
  final int overdueCount;
  final VoidCallback onViewTasks;
  final VoidCallback onDismiss;

  const _OverdueAlertDialog({
    required this.overdueCount,
    required this.onViewTasks,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: math.min(responsive.dialogMaxWidth, responsive.effectiveWidth - responsive.padding * 2),
              constraints: BoxConstraints(maxHeight: responsive.dialogMaxHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(responsive. extraLargeBorderRadius),
                boxShadow: responsive. elevatedShadow,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets. all(responsive.padding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade600, Colors.red. shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(responsive. extraLargeBorderRadius)),
                      ),
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) => Transform.scale(scale: value, child: child),
                            child: Container(
                              padding: EdgeInsets. all(responsive.padding),
                              decoration: BoxDecoration(
                                color: Colors.white. withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: responsive.iconSize(40),
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.microPadding),
                          if (responsive.showMinimalText)
                            Text(
                              responsive.adaptiveText('Overdue Alert! ', nano: '! ', micro: 'Alert! ', mini: 'Overdue! '),
                              style: GoogleFonts.poppins(
                                fontSize: responsive.headingS,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets. all(responsive.padding),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets. all(responsive.padding),
                            decoration: BoxDecoration(
                              color: Colors.red. withOpacity(0.1),
                              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
                              border: Border.all(color: Colors. red.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment. center,
                              children: [
                                Text(
                                  '$overdueCount',
                                  style: GoogleFonts.poppins(
                                    fontSize: responsive.headingXL,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(width: responsive.microPadding),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Task${overdueCount > 1 ? 's' : ''}',
                                      style: GoogleFonts.poppins(
                                        fontSize: responsive.bodyM,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red. shade800,
                                      ),
                                    ),
                                    if (responsive.showSecondaryText)
                                      Text(
                                        'Overdue > 2 days',
                                        style: GoogleFonts. poppins(
                                          fontSize: responsive.captionM,
                                          color: Colors.red.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.microPadding),
                          if (responsive. showFullDescriptions)
                            Text(
                              'You have tasks pending for more than 2 days. Please complete them to maintain your performance rating.',
                              textAlign: TextAlign. center,
                              style: GoogleFonts.poppins(
                                fontSize: responsive.bodyS,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          SizedBox(height: responsive.padding),
                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: onDismiss,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors. grey[700],
                                    side: BorderSide(color: Colors.grey[400]! ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(responsive.borderRadius),
                                    ),
                                    padding: EdgeInsets. symmetric(vertical: responsive.microPadding),
                                  ),
                                  child: Text(
                                    responsive.adaptiveText('Later', nano: 'X', micro: 'X', mini: 'Later'),
                                    style: GoogleFonts.poppins(fontWeight: FontWeight. w600, fontSize: responsive.bodyS),
                                  ),
                                ),
                              ),
                              SizedBox(width: responsive.microPadding),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: onViewTasks,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors. white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(responsive. borderRadius),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: responsive.microPadding),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (responsive.showIcons)
                                        Icon(Icons. visibility_rounded, size: responsive.iconSize(18)),
                                      if (responsive.showIcons) SizedBox(width: responsive.nanoPadding),
                                      Text(
                                        responsive.adaptiveText('View Tasks', nano: '→', micro: 'View', mini: 'View'),
                                        style: GoogleFonts.poppins(fontWeight: FontWeight. w600, fontSize: responsive.bodyS),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== ENHANCED LOGOUT DIALOG ====================
class _EnhancedLogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: math.min(responsive.dialogMaxWidth * 0.9, responsive.effectiveWidth - responsive.padding * 2),
              padding: EdgeInsets. all(responsive.padding),
              decoration: BoxDecoration(
                color: Colors. white,
                borderRadius: BorderRadius. circular(responsive.extraLargeBorderRadius),
                boxShadow: responsive. elevatedShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets. all(responsive.microPadding),
                    decoration: BoxDecoration(
                      color: Colors. red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.logout_rounded, color: Colors.red, size: responsive. iconSize(32)),
                  ),
                  SizedBox(height: responsive.microPadding),
                  Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: responsive.headingS,
                      fontWeight: FontWeight. bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: responsive. microPadding),
                  if (responsive.showSecondaryText)
                    Text(
                      'Are you sure you want to logout?  You\'ll need to sign in again.',
                      textAlign: TextAlign. center,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.bodyS,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  SizedBox(height: responsive.padding),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator. pop(context, false),
                          style: OutlinedButton. styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(responsive.borderRadius),
                            ),
                            padding: EdgeInsets.symmetric(vertical: responsive. microPadding),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: responsive.bodyS),
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.microPadding),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(responsive.borderRadius),
                            ),
                            padding: EdgeInsets.symmetric(vertical: responsive. microPadding),
                            elevation: 0,
                          ),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: responsive. bodyS),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Add this extension for colored shadows
extension ResponsiveDataExtension on EmployeeResponsiveData {
  List<BoxShadow> coloredShadow(Color color, {double opacity = 0.3}) {
    if (! showLightShadows) return [];
    final blur = effectiveWidth < 200 ? 4.0 : effectiveWidth < 480 ? 8.0 : 12.0;
    final offset = effectiveWidth < 200 ? 1.0 : effectiveWidth < 480 ? 3.0 : 4.0;
    return [
    BoxShadow(
    color: color.withOpacity(opacity),
    blurRadius: blur,
    offset: Offset(0, offset),
    ),
    ];
  }
}