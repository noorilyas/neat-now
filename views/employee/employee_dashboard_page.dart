import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:neat_now/viewmodels/employee/employee_dashboard_viewmodel.dart';
import 'package:neat_now/models/employee/tab_item_model.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'package:neat_now/widgets/employee/dashboard_tab.dart';
import 'package:neat_now/widgets/employee/reports_tab.dart';
import 'package:neat_now/widgets/employee/map_tab.dart';
import 'package:neat_now/widgets/employee/analytics_tab.dart';
import 'package:neat_now/widgets/employee/profile_tab.dart';
import 'package:neat_now/widgets/employee/leaderboard_page.dart';
import 'package:neat_now/widgets/employee/notifications_page.dart';
import 'package:neat_now/widgets/employee/notification_overlay.dart';
import 'package:neat_now/views/employee/components/employee_app_bar.dart';
import 'package:neat_now/views/employee/components/employee_side_nav.dart';
import 'package:neat_now/views/employee/components/employee_bottom_nav.dart';
import 'package:neat_now/views/employee/components/overdue_alert_dialog.dart';
import 'package:neat_now/views/employee/components/logout_dialog.dart';

class EmployeeDashboardPage extends StatefulWidget {
  const EmployeeDashboardPage({super.key});

  @override
  State<EmployeeDashboardPage> createState() => _EmployeeDashboardPageState();
}

class _EmployeeDashboardPageState extends State<EmployeeDashboardPage>
    with TickerProviderStateMixin {
  late EmployeeDashboardViewModel _viewModel;
  late PageController _pageController;
  late ScrollController _scrollController;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _pageTransitionController;
  late AnimationController _shimmerController;
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _fabController;
  late AnimationController _pulseController;
  late AnimationController _logoController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fabAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();

    _viewModel = EmployeeDashboardViewModel();
    _viewModel.addListener(_onViewModelChanged);

    _pageController = PageController();
    _scrollController = ScrollController();

    _initializeAnimations();
    _setupScrollListener();
    _checkForOverdueDialog();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent:  _fadeController,
      curve:  Curves.easeOutQuart,
    );
    _fadeController.forward();

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _pageTransitionController,
        curve:  Curves.easeOutCubic,
      ),
    );
    _scaleAnimation = Tween<double>(begin:  0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageTransitionController,
        curve:  Curves.easeOutCubic,
      ),
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve:  Curves.easeInOut,
      ),
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve:  Curves.elasticOut,
      ),
    );

    _rotateController = AnimationController(
      duration:  const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeInOut,
      ),
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: Curves.elasticOut,
      ),
    );

    _pulseController = AnimationController(
      duration:  const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve:  Curves.easeInOut,
      ),
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves. elasticOut,
      ),
    );
    _logoController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final shouldShowFAB = _scrollController.offset > 100;
      _viewModel.setFABVisibility(shouldShowFAB);

      if (shouldShowFAB) {
        _fabController.forward();
      } else {
        _fabController. reverse();
      }
    });
  }

  void _checkForOverdueDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewModel.hasOverdueAlerts && !_viewModel.hasShownOverdueDialog) {
        _viewModel. markOverdueDialogShown();
        _pulseController.repeat(reverse: true);
        _showOverdueDialog();
      }
    });
  }

  void _showOverdueDialog() {
    if (!mounted) return;

    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Overdue Alert',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds:  400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return OverdueAlertDialog(
          overdueCount: _viewModel.overdueCount,
          onViewTasks: () {
            Navigator.pop(context);
            _onTabSelected(1);
          },
          onDismiss: () => Navigator.pop(context),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent:  animation,
            curve: Curves. elasticOut,
          ),
          child: FadeTransition(
            opacity:  animation,
            child: child,
          ),
        );
      },
    );
  }

  void _onTabSelected(int index) {
    if (_viewModel.selectedIndex == index) return;

    HapticFeedback.selectionClick();
    _pageTransitionController.forward(from: 0.0);
    _viewModel.selectTab(index);

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves. easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    if (_viewModel.selectedIndex != index) {
      HapticFeedback.selectionClick();
      _pageTransitionController.forward(from: 0.0);
      _viewModel.selectTab(index);
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    _rotateController.forward(from: 0.0);
    await _viewModel.refresh();
    _showSnackBar('Data refreshed successfully', isSuccess: true);
  }

  Future<void> _handleLogout() async {
    HapticFeedback.heavyImpact();

    final confirm = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Logout',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const LogoutDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale:  CurvedAnimation(
            parent: animation,
            curve:  Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );

    if (confirm == true && mounted) {
      final success = await _viewModel.logout();
      if (success && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
              (route) => false,
        );
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds:  400),
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
                  color: Colors. white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess
            ? const Color(0xFF2AC2AB)
            : const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:  BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showNotificationsPage() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return EmployeeResponsiveHelper(
            builder: (context, responsive) => NotificationsPage(
              responsive: responsive,
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:  Tween<Offset>(
              begin: const Offset(1, 0),
              end:  Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: FadeTransition(
              opacity:  animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _scrollToTop() {
    HapticFeedback.lightImpact();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _pageTransitionController.dispose();
    _shimmerController.dispose();
    _bounceController.dispose();
    _rotateController.dispose();
    _fabController.dispose();
    _pulseController. dispose();
    _logoController. dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder:  (context, responsive) {
        return NotificationOverlay(
          responsive: responsive,
          child: AnimatedContainer(
            duration: responsive.animationDuration,
            decoration: BoxDecoration(
              color: _viewModel.currentBackgroundColor,
            ),
            child:  Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                bottom: false,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child:  _viewModel.isLoading
                      ? _buildLoadingState(responsive)
                      : _buildLayout(responsive),
                ),
              ),
              floatingActionButton: responsive.showFab && _viewModel.showFAB
                  ? _buildScrollToTopFAB(responsive)
                  :  null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(EmployeeResponsiveData responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math.pi,
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
                  colors: [Color(0xFF2AC2AB), Color(0xFF1FA896)],
                  begin:  Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:  BorderRadius.circular(responsive.largeBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2AC2AB).withOpacity(0.3),
                    blurRadius:  12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.eco_rounded,
                color: Colors.white,
                size: responsive.iconSize(28),
              ),
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
                      colors: [
                        Colors.grey[400]!,
                        Colors. grey[200]!,
                        Colors. grey[400]!,
                      ],
                    ).createShader(bounds);
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
                      fontSize: responsive.bodyS,
                      fontWeight:  FontWeight.w500,
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

  Widget _buildScrollToTopFAB(EmployeeResponsiveData responsive) {
    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton. small(
        onPressed: _scrollToTop,
        backgroundColor: _viewModel.currentColor,
        elevation: 8,
        child:  Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.white,
          size: responsive.iconSize(20),
        ),
      ),
    );
  }

  Widget _buildLayout(EmployeeResponsiveData responsive) {
    if (responsive.showSideNav) {
      return _buildDesktopLayout(responsive);
    } else if (responsive.showRailNav) {
      return _buildTabletLayout(responsive);
    } else {
      return _buildMobileLayout(responsive);
    }
  }

// Layout implementations will follow in next part...
}
// ==================== MOBILE LAYOUT ====================
Widget _buildMobileLayout(EmployeeResponsiveData responsive) {
  return Column(
    children: [
      EmployeeAppBar(
        viewModel: _viewModel,
        responsive: responsive,
        onLogoTap: () {
          HapticFeedback.lightImpact();
          _bounceController.forward(from: 0.0);
        },
        onRefresh: _handleRefresh,
        onNotificationsTap: _showNotificationsPage,
        bounceAnimation: _bounceAnimation,
        rotateAnimation: _rotateAnimation,
        pulseAnimation: _pulseAnimation,
        logoAnimation: _logoAnimation,
      ),
      if (_viewModel.hasOverdueAlerts)
        _buildOverdueBanner(responsive),
      Expanded(
        child: AnimatedBuilder(
          animation: _pageTransitionController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_slideAnimation.value * 50, 0),
              child:  Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
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
      if (responsive.showBottomNav)
        EmployeeBottomNav(
          viewModel: _viewModel,
          responsive: responsive,
          onTabSelected: _onTabSelected,
        ),
    ],
  );
}

// ==================== TABLET LAYOUT ====================
Widget _buildTabletLayout(EmployeeResponsiveData responsive) {
  return Row(
    children: [
      EmployeeSideNav(
        viewModel: _viewModel,
        responsive: responsive,
        isExpanded: false,
        onTabSelected: _onTabSelected,
        onToggle: () => _viewModel.toggleSideNav(),
        onLogout: _handleLogout,
        bounceAnimation: _bounceAnimation,
        pulseAnimation: _pulseAnimation,
        logoAnimation: _logoAnimation,
      ),
      Container(
        width: 1,
        color: Colors.grey. withOpacity(0.12),
      ),
      Expanded(
        child: Column(
          children: [
            EmployeeAppBar(
              viewModel: _viewModel,
              responsive: responsive,
              onLogoTap: () {
                HapticFeedback.lightImpact();
                _bounceController.forward(from: 0.0);
              },
              onRefresh:  _handleRefresh,
              onNotificationsTap: _showNotificationsPage,
              bounceAnimation: _bounceAnimation,
              rotateAnimation: _rotateAnimation,
              pulseAnimation:  _pulseAnimation,
              logoAnimation: _logoAnimation,
              showLogo: false,
            ),
            if (_viewModel.hasOverdueAlerts)
              _buildOverdueBanner(responsive),
            Expanded(
              child: _buildContentArea(responsive),
            ),
          ],
        ),
      ),
    ],
  );
}

// ==================== DESKTOP LAYOUT ====================
Widget _buildDesktopLayout(EmployeeResponsiveData responsive) {
  return Row(
    children: [
      EmployeeSideNav(
        viewModel: _viewModel,
        responsive: responsive,
        isExpanded: _viewModel.isSideNavExpanded,
        onTabSelected: _onTabSelected,
        onToggle: () => _viewModel.toggleSideNav(),
        onLogout: _handleLogout,
        bounceAnimation: _bounceAnimation,
        pulseAnimation: _pulseAnimation,
        logoAnimation: _logoAnimation,
      ),
      Container(
        width: 1,
        color: Colors.grey. withOpacity(0.12),
      ),
      Expanded(
        child: Column(
          children: [
            EmployeeAppBar(
              viewModel:  _viewModel,
              responsive:  responsive,
              onLogoTap: () {
                HapticFeedback.lightImpact();
                _bounceController.forward(from: 0.0);
              },
              onRefresh: _handleRefresh,
              onNotificationsTap: _showNotificationsPage,
              bounceAnimation: _bounceAnimation,
              rotateAnimation: _rotateAnimation,
              pulseAnimation: _pulseAnimation,
              logoAnimation: _logoAnimation,
              showLogo: false,
              isDesktop: true,
            ),
            if (_viewModel.hasOverdueAlerts)
              _buildOverdueBanner(responsive),
            Expanded(
              child:  Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.maxContentWidth,
                  ),
                  child:  Padding(
                    padding: EdgeInsets.all(responsive.padding),
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

// ==================== OVERDUE BANNER ====================
Widget _buildOverdueBanner(EmployeeResponsiveData responsive) {
  return AnimatedBuilder(
    animation: _pulseAnimation,
    builder: (context, child) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.padding,
          vertical: responsive.microPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red. shade600,
              Colors.red.shade400. withOpacity(
                0.85 + (_pulseAnimation.value - 1) * 2,
              ),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color:  Colors.red.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (responsive.showStatusIndicators)
              Container(
                padding: EdgeInsets.all(responsive.nanoPadding),
                decoration: BoxDecoration(
                  color: Colors.white. withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    responsive.smallBorderRadius,
                  ),
                ),
                child: Icon(
                  Icons. warning_amber_rounded,
                  color: Colors.white,
                  size: responsive. iconSize(16),
                ),
              ),
            SizedBox(width: responsive.microPadding),
            Expanded(
              child: Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
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
                      style: GoogleFonts.poppins(
                        fontSize:  responsive.captionL,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (responsive.showSecondaryText)
                    Text(
                      '${_viewModel.overdueCount} task${_viewModel.overdueCount > 1 ? 's' :  ''} > 2 days',
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
                color: Colors. white,
                borderRadius: BorderRadius.circular(
                  responsive.smallBorderRadius,
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _onTabSelected(1);
                  },
                  borderRadius: BorderRadius.circular(
                    responsive.smallBorderRadius,
                  ),
                  child:  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.microPadding,
                      vertical: responsive.nanoPadding,
                    ),
                    child: Text(
                      'View',
                      style: GoogleFonts.poppins(
                        fontSize: responsive.captionS,
                        fontWeight: FontWeight.bold,
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

// ==================== CONTENT AREA ====================
Widget _buildContentArea(EmployeeResponsiveData responsive) {
  return AnimatedBuilder(
    animation: _pageTransitionController,
    builder:  (context, child) {
      return Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      );
    },
    child: IndexedStack(
      index: _viewModel.selectedIndex,
      children: _buildTabContent(responsive),
    ),
  );
}

// ==================== TAB CONTENT ====================
List<Widget> _buildTabContent(EmployeeResponsiveData responsive) {
  return [
    // Dashboard Tab
    EmployeeDashboardTab(
      stats: _viewModel.stats,
      acceptedReports: _viewModel.acceptedReports,
      leaderboard: _viewModel.leaderboard,
      onNavigateToTab: _onTabSelected,
      onRefresh: _handleRefresh,
      user: _viewModel.user,
      isDemoMode: _viewModel.isDemoMode,
      overdueCount: _viewModel.overdueCount,
      responsive: responsive,
    ),

    // Reports Tab
    EmployeeReportsTab(
      reports: _viewModel.reports,
      onUpdateStatus: (reportId, status, {imagePath, latitude, longitude, locationAddress}) async {
        final success = await _viewModel.updateReportStatus(
          reportId,
          status,
          imagePath:  imagePath,
          latitude: latitude,
          longitude: longitude,
          locationAddress: locationAddress,
        );

        _showSnackBar(
          success
              ? (status == 'resolved' ? 'Report resolved!' : 'Status updated')
              : 'Failed to update',
          isSuccess: success,
        );
      },
      onRefresh: _handleRefresh,
      overdueCount: _viewModel.overdueCount,
      responsive: responsive,
    ),

    // Map Tab
    BinsMapTab(
      reports: _viewModel.reports,
      onUpdateStatus: (reportId, status, {imagePath, latitude, longitude, locationAddress}) async {
        final success = await _viewModel.updateReportStatus(
          reportId,
          status,
          imagePath: imagePath,
          latitude: latitude,
          longitude: longitude,
          locationAddress: locationAddress,
        );

        _showSnackBar(
          success ?  'Status updated' : 'Failed to update',
          isSuccess: success,
        );
      },
      onRefresh: _handleRefresh,
      responsive: responsive,
    ),

    // Analytics Tab
    EmployeeAnalyticsTab(
      analytics: _viewModel.analytics,
      reports: _viewModel.reports,
      onRefresh: _handleRefresh,
      responsive: responsive,
    ),

    // Leaderboard Tab
    LeaderboardPage(
      leaderboard: _viewModel.leaderboard,
      currentUserId: _viewModel.user?. id ??  '',
      onRefresh: _handleRefresh,
      responsive: responsive,
    ),

    // Profile Tab
    EmployeeProfileTab(
      user: _viewModel.user,
      stats: _viewModel.stats,
      isDemoMode: _viewModel.isDemoMode,
      onLogout: _handleLogout,
      onProfileUpdate: () async {
        await _viewModel.refresh();
      },
      responsive: responsive,
    ),
  ];
}
}