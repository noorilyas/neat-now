import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/views/user/user_home_tab_view.dart';
import 'package:neat_now/views/user/user_leaderboard_tab_view.dart';
import 'package:neat_now/views/user/user_profile_tab_view.dart';
import 'package:neat_now/views/user/user_report_waste_page_view.dart';
import 'package:neat_now/views/user/user_reports_tab_view.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';

// Import ViewModels
import 'package:neat_now/viewmodels/user/user_dashboard_viewmodel.dart';

// Import Design System
import 'package:neat_now/design/user/user_design_system.dart';

// Import all user pages
import 'package:neat_now/views/user/responsive_user_helper.dart';

// Import success dialog
import 'package:neat_now/views/user/report_success_dialog_view.dart';

/// ==================== USER DASHBOARD ====================
class UserDashboard extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onLogout;

  const UserDashboard({
    super.key,
    this.userData,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserDashboardViewModel(
        userData: userData,
        onLogout: onLogout,
      ),
      child: const _UserDashboardContent(),
    );
  }
}

class _UserDashboardContent extends StatefulWidget {
  const _UserDashboardContent();

  @override
  State<_UserDashboardContent> createState() => _UserDashboardContentState();
}

class _UserDashboardContentState extends State<_UserDashboardContent>
    with TickerProviderStateMixin {
  late PageController _pageController;

  // Animation Controllers
  late AnimationController _fabController;
  late AnimationController _fabPulseController;
  late AnimationController _navIndicatorController;

  // Animations
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;
  late Animation<double> _fabPulseAnimation;
  late Animation<double> _navIndicatorAnimation;

  // Scroll Controller for hiding nav
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initAnimations();
  }

  void _initAnimations() {
    // FAB Press Animation
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _fabController, curve:  Curves.easeInOut),
    );
    _fabRotationAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );

    // FAB Pulse Animation
    _fabPulseController = AnimationController(
      duration:  const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _fabPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _fabPulseController, curve: Curves.easeInOut),
    );

    // Nav Indicator Animation
    _navIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navIndicatorAnimation = CurvedAnimation(
      parent:  _navIndicatorController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    _fabPulseController.dispose();
    _navIndicatorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNavTap(int index, UserDashboardViewModel viewModel) {
    if (index == 2) {
      _openReportWastePage(viewModel);
      return;
    }

    if (index == viewModel.currentIndex) return;

    HapticFeedback.selectionClick();
    viewModel.onNavTap(index);
    _navIndicatorController.forward(from: 0);

    // Adjust index for pages (skip FAB placeholder)
    final pageIndex = viewModel.getPageIndex(index);

    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves. easeOutCubic,
    );
  }

  void _openReportWastePage(UserDashboardViewModel viewModel) {
    HapticFeedback.mediumImpact();
    _fabController.forward().then((_) => _fabController.reverse());

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserReportWastePage(
              userData: viewModel.userMap,
              onSubmit: (reportData) {
                Navigator.pop(context);
                _showReportSuccessAnimation(viewModel);
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:  Tween<Offset>(
              begin: const Offset(0, 1),
              end:  Offset.zero,
            ).animate(CurvedAnimation(
              parent:  animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity:  animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds:  450),
      ),
    );
  }

  void _showReportSuccessAnimation(UserDashboardViewModel viewModel) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white. withOpacity(0.95),
      transitionDuration: const Duration(milliseconds:  300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ReportSuccessDialogView(
          onComplete: () {
            Navigator.pop(context);
            viewModel.onReportSuccess();
            viewModel.navigateToReports();
            _pageController.animateToPage(
              viewModel.getPageIndex(1),
              duration: const Duration(milliseconds: 350),
              curve: Curves. easeOutCubic,
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity:  animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = UserResponsiveData.of(context);
    final viewModel = context.watch<UserDashboardViewModel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: UserDesign.surfacePure,
        systemNavigationBarIconBrightness:  Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: UserDesign.surfaceLight,
        extendBody: true,
        body: Stack(
          children: [
            // Page Content
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                UserHomeTab(
                  userData: viewModel.userMap,
                  responsive: responsive,
                  onViewReports: () => _onNavTap(1, viewModel),
                  onViewLeaderboard: () => _onNavTap(3, viewModel),
                  onReportWaste: () => _openReportWastePage(viewModel),
                ),
                UserReportsTab(
                  userData:  viewModel.userMap,
                  responsive: responsive,
                  onReportWaste: () => _openReportWastePage(viewModel),
                ),
                UserLeaderboardTab(
                  userData: viewModel.userMap,
                  responsive: responsive,
                ),
                UserProfileTab(
                  userData: viewModel.userMap,
                  responsive: responsive,
                  onLogout: viewModel.logout,
                  onProfileUpdate: viewModel.onProfileUpdate,
                ),
              ],
            ),

            // Modern Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right:  0,
              child: _buildModernBottomNavigation(responsive, viewModel),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MODERN BOTTOM NAVIGATION ====================
  Widget _buildModernBottomNavigation(
      UserResponsiveData r, UserDashboardViewModel viewModel) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        r.padding,
        0,
        r.padding,
        r.safePaddingBottom + r.microPadding,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r. extraLargeBorderRadius + 4),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX:  20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical:  r.microPadding,
            ),
            decoration: BoxDecoration(
              color: UserDesign.surfacePure. withOpacity(0.95),
              borderRadius: BorderRadius.circular(r.extraLargeBorderRadius + 4),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius:  32,
                  offset: const Offset(0, -8),
                  spreadRadius: -8,
                ),
                BoxShadow(
                  color: UserDesign.primaryTeal.withOpacity(0.05),
                  blurRadius:  20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:  List.generate(viewModel.navItems.length, (index) {
                if (index == 2) {
                  return _buildModernFAB(r, viewModel);
                }
                return _buildModernNavItem(r, index, viewModel);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(
      UserResponsiveData r, int index, UserDashboardViewModel viewModel) {
    final item = viewModel.navItems[index];
    final isSelected = viewModel.isSelected(index);

    return GestureDetector(
      onTap: () => _onNavTap(index, viewModel),
      behavior: HitTestBehavior. opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: r.microPadding + (isSelected ? 4 : 0),
          vertical: r.microPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? item.color. withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..scale(isSelected ? 1.1 : 1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect for selected
                  if (isSelected)
                    Container(
                      width: r.dimension(40),
                      height: r. dimension(40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius:  12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  Icon(
                    isSelected ?  item.activeIcon : item.icon,
                    color: isSelected ? item.color :  UserDesign.textTertiary,
                    size:  r.iconSize(24),
                  ),
                ],
              ),
            ),

            SizedBox(height: r.atomicPadding),

            // Label with animation
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: GoogleFonts.inter(
                fontSize: isSelected ? r.captionS : r.captionXS,
                fontWeight: isSelected ? FontWeight. w600 : FontWeight.w500,
                color: isSelected ? item.color : UserDesign.textTertiary,
              ),
              child: Text(item.label),
            ),

            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(top: r.atomicPadding),
              width: isSelected ? r.dimension(5) : 0,
              height: r.dimension(5),
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFAB(
      UserResponsiveData r, UserDashboardViewModel viewModel) {
    return GestureDetector(
      onTapDown: (_) => _fabController.forward(),
      onTapUp: (_) {
        _fabController.reverse();
        _openReportWastePage(viewModel);
      },
      onTapCancel: () => _fabController.reverse(),
      child: AnimatedBuilder(
        animation:  Listenable.merge([_fabController, _fabPulseController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation. value * _fabPulseAnimation.value,
            child: Transform.rotate(
              angle: _fabRotationAnimation.value * math.pi * 2,
              child: child,
            ),
          );
        },
        child: Container(
          width:  r.dimension(64),
          height: r.dimension(64),
          margin: EdgeInsets.symmetric(horizontal: r.nanoPadding),
          decoration:  BoxDecoration(
            gradient: UserDesign.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:  UserDesign.primaryTeal.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: UserDesign.primaryTealLight.withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 16),
                spreadRadius: -8,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shimmer effect
              ClipOval(
                child: AnimatedBuilder(
                  animation: _fabPulseController,
                  builder: (context, child) {
                    return Container(
                      width: r.dimension(64),
                      height: r.dimension(64),
                      decoration:  BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(
                            -1 + _fabPulseController.value * 2,
                            -1,
                          ),
                          end: Alignment(
                            _fabPulseController.value * 2,
                            1,
                          ),
                          colors: [
                            Colors. white.withOpacity(0),
                            Colors.white.withOpacity(0.2),
                            Colors.white. withOpacity(0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Icon
              Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: r.iconSize(32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}