import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';

// Import all user pages
import 'package:neat_now/widgets/user/user_home_tab.dart';
import 'package:neat_now/widgets/user/user_reports_tab.dart';
import 'package:neat_now/widgets/user/user_leaderboard_tab.dart';
import 'package:neat_now/widgets/user/user_profile_tab.dart';
import 'package:neat_now/widgets/user/user_report_waste_page.dart';
import 'package:neat_now/widgets/user/responsive_user_helper.dart';

/// ==================== USER DESIGN SYSTEM ====================
class UserDesign {
  // Primary Colors - Modern Teal Palette
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color primaryTealGlow = Color(0xFF95E1D3);
  static const Color primaryTealSoft = Color(0xFFE8FAF7);

  // Surfaces - Clean & Minimal
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);
  static const Color surfaceOverlay = Color(0xFFF3F4F6);
  static const Color surfaceGlass = Color(0xFFFFFFFE);

  // Text - Clear Hierarchy
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);
  static const Color textMuted = Color(0xFFE5E7EB);

  // Status Colors - Vibrant & Clear
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningSoft = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorSoft = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoSoft = Color(0xFFEFF6FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purpleSoft = Color(0xFFF5F3FF);

  // Badge & Rank Colors
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color platinumShine = Color(0xFFF5F5F5);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldShine = Color(0xFFFFF4CC);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color silverShine = Color(0xFFE8E8E8);
  static const Color bronze = Color(0xFFCD7F32);

  // Shadows - Soft & Layered
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: Colors.black. withOpacity(0.1),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color. withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: color.withOpacity(0.2),
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> subtleGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  // Gradients - Smooth & Modern
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryTeal, primaryTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get primaryGradientVertical => const LinearGradient(
    colors: [primaryTeal, primaryTealLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient get successGradient => const LinearGradient(
    colors: [success, Color(0xFF34D399)],
    begin: Alignment. topLeft,
    end: Alignment. bottomRight,
  );

  static LinearGradient get errorGradient => const LinearGradient(
    colors: [error, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get purpleGradient => const LinearGradient(
    colors: [purple, Color(0xFFA78BFA)],
    begin: Alignment. topLeft,
    end: Alignment. bottomRight,
  );

  static LinearGradient get glassGradient => LinearGradient(
    colors: [
      Colors.white. withOpacity(0.9),
      Colors. white.withOpacity(0.7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shimmerGradient(double value) => LinearGradient(
    colors: [
      Colors.white. withOpacity(0.0),
      Colors. white.withOpacity(0.5),
      Colors. white.withOpacity(0.0),
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment(-1.0 + value * 3, 0),
    end: Alignment(value * 3, 0),
  );

  // Border Radius Constants
  static const double radiusXS = 6;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusFull = 100;
}

/// ==================== USER DASHBOARD ====================
class UserDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onLogout;

  const UserDashboard({
    super.key,
    this.userData,
    required this.onLogout,
  });

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  late PageController _pageController;

  // Animation Controllers
  late AnimationController _fabController;
  late AnimationController _fabPulseController;
  late AnimationController _navIndicatorController;
  late AnimationController _pageTransitionController;

  // Animations
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;
  late Animation<double> _fabPulseAnimation;
  late Animation<double> _navIndicatorAnimation;

  // Scroll Controller for hiding nav
  final ScrollController _scrollController = ScrollController();
  bool _isNavVisible = true;
  double _lastScrollOffset = 0;

  // User Data
  Map<String, dynamic> get _user => widget.userData ??  _defaultUser;

  static const Map<String, dynamic> _defaultUser = {
    'id': '1',
    'name': 'Demo User',
    'email': 'demo@neatnow.com',
    'phone': '+1234567890',
    'profileImage': null,
    'totalReports': 15,
    'verifiedReports': 12,
    'pendingReports': 3,
    'rank': 5,
    'points': 1250,
    'badge': null,
    'memberSince': 'Jan 2024',
    'joinedDate': '2024-01-15',
  };

  final List<_NavItem> _navItems = [
    _NavItem(
      label: 'Home',
      activeIcon: Icons.home_rounded,
      icon: Icons.home_outlined,
      color: UserDesign. primaryTeal,
    ),
    _NavItem(
      label: 'Reports',
      activeIcon: Icons.assignment_rounded,
      icon: Icons.assignment_outlined,
      color: UserDesign.info,
    ),
    _NavItem(
      label: 'Add',
      activeIcon: Icons.add_rounded,
      icon: Icons.add_rounded,
      color: UserDesign.primaryTeal,
      isFab: true,
    ),
    _NavItem(
      label: 'Ranks',
      activeIcon: Icons.leaderboard_rounded,
      icon: Icons.leaderboard_outlined,
      color: UserDesign. warning,
    ),
    _NavItem(
      label: 'Profile',
      activeIcon: Icons. person_rounded,
      icon: Icons. person_outlined,
      color: UserDesign.purple,
    ),
  ];

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
      CurvedAnimation(parent: _fabController, curve: Curves. easeInOut),
    );
    _fabRotationAnimation = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );

    // FAB Pulse Animation
    _fabPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    ).. repeat(reverse: true);
    _fabPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _fabPulseController, curve: Curves.easeInOut),
    );

    // Nav Indicator Animation
    _navIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navIndicatorAnimation = CurvedAnimation(
      parent: _navIndicatorController,
      curve: Curves.easeOutCubic,
    );

    // Page Transition
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    _fabPulseController. dispose();
    _navIndicatorController. dispose();
    _pageTransitionController. dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 2) {
      _openReportWastePage();
      return;
    }

    if (index == _currentIndex) return;

    HapticFeedback.selectionClick();

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    _navIndicatorController.forward(from: 0);

    // Adjust index for pages (skip FAB placeholder)
    final pageIndex = index > 2 ? index - 1 : index;

    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _openReportWastePage() {
    HapticFeedback.mediumImpact();
    _fabController.forward(). then((_) => _fabController.reverse());

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UserReportWastePage(
              userData: _user,
              onSubmit: (reportData) {
                Navigator.pop(context);
                _showReportSuccessAnimation();
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ). animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  void _showReportSuccessAnimation() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white. withOpacity(0.95),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ModernReportSuccessDialog(
          onComplete: () {
            Navigator.pop(context);
            _onNavTap(1);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = UserResponsiveData.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: UserDesign.surfacePure,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: UserDesign. surfaceLight,
        extendBody: true,
        body: Stack(
          children: [
            // Page Content
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                UserHomeTab(
                  userData: _user,
                  responsive: responsive,
                  onViewReports: () => _onNavTap(1),
                  onViewLeaderboard: () => _onNavTap(3),
                  onReportWaste: _openReportWastePage,
                ),
                UserReportsTab(
                  userData: _user,
                  responsive: responsive,
                  onReportWaste: _openReportWastePage,
                ),
                UserLeaderboardTab(
                  userData: _user,
                  responsive: responsive,
                ),
                UserProfileTab(
                  userData: _user,
                  responsive: responsive,
                  onLogout: widget.onLogout,
                  onProfileUpdate: () => setState(() {}),
                ),
              ],
            ),

            // Modern Bottom Navigation
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildModernBottomNavigation(responsive),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MODERN BOTTOM NAVIGATION ====================
  Widget _buildModernBottomNavigation(UserResponsiveData r) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        r.padding,
        0,
        r. padding,
        r.safePaddingBottom + r.microPadding,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius + 4),
        child: BackdropFilter(
          filter: ImageFilter. blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets. symmetric(
              horizontal: r.microPadding,
              vertical: r. microPadding,
            ),
            decoration: BoxDecoration(
              color: UserDesign. surfacePure. withOpacity(0.95),
              borderRadius: BorderRadius.circular(r.extraLargeBorderRadius + 4),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, -8),
                  spreadRadius: -8,
                ),
                BoxShadow(
                  color: UserDesign.primaryTeal.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_navItems.length, (index) {
                if (index == 2) {
                  return _buildModernFAB(r);
                }
                return _buildModernNavItem(r, index);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernNavItem(UserResponsiveData r, int index) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets. symmetric(
          horizontal: r.microPadding + (isSelected ? 4 : 0),
          vertical: r.microPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? item.color.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize. min,
          children: [
            // Icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                .. scale(isSelected ? 1.1 : 1.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect for selected
                  if (isSelected)
                    Container(
                      width: r.dimension(40),
                      height: r.dimension(40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? item.color : UserDesign.textTertiary,
                    size: r. iconSize(24),
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
                fontWeight: isSelected ?  FontWeight.w600 : FontWeight.w500,
                color: isSelected ?  item.color : UserDesign.textTertiary,
              ),
              child: Text(item.label),
            ),

            // Active indicator dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets. only(top: r. atomicPadding),
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

  Widget _buildModernFAB(UserResponsiveData r) {
    return GestureDetector(
      onTapDown: (_) => _fabController.forward(),
      onTapUp: (_) {
        _fabController.reverse();
        _openReportWastePage();
      },
      onTapCancel: () => _fabController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_fabController, _fabPulseController]),
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
          width: r.dimension(64),
          height: r.dimension(64),
          margin: EdgeInsets. symmetric(horizontal: r.nanoPadding),
          decoration: BoxDecoration(
            gradient: UserDesign.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: UserDesign.primaryTeal.withOpacity(0.4),
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
                      decoration: BoxDecoration(
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
                            Colors.white.withOpacity(0),
                            Colors. white.withOpacity(0.2),
                            Colors.white.withOpacity(0),
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

// ==================== NAV ITEM MODEL ====================
class _NavItem {
  final String label;
  final IconData activeIcon;
  final IconData icon;
  final Color color;
  final bool isFab;

  _NavItem({
    required this. label,
    required this.activeIcon,
    required this. icon,
    required this.color,
    this.isFab = false,
  });
}

// ==================== MODERN REPORT SUCCESS DIALOG ====================
class _ModernReportSuccessDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const _ModernReportSuccessDialog({required this.onComplete});

  @override
  State<_ModernReportSuccessDialog> createState() =>
      _ModernReportSuccessDialogState();
}

class _ModernReportSuccessDialogState extends State<_ModernReportSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _checkController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _pulseAnimation;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateParticles();
    _startSequence();
  }

  void _initAnimations() {
    // Scale animation for container
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves. elasticOut,
    );

    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves. easeOutBack,
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Pulse animation for glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _generateParticles() {
    final random = math.Random();
    final colors = [
      UserDesign.primaryTeal,
      UserDesign.primaryTealLight,
      UserDesign.success,
      UserDesign.info,
      UserDesign.purple,
      UserDesign.warning,
      Colors.white,
    ];

    for (int i = 0; i < 80; i++) {
      _particles.add(_ConfettiParticle(
        angle: random.nextDouble() * 2 * math.pi,
        velocity: 100 + random.nextDouble() * 250,
        size: 4 + random.nextDouble() * 10,
        color: colors[random.nextInt(colors.length)],
        delay: random.nextDouble() * 0.3,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
        shape: random.nextInt(3), // 0: circle, 1: square, 2: star
      ));
    }
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));

    HapticFeedback.heavyImpact();
    _scaleController.forward();
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _checkController. forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController. dispose();
    _confettiController. dispose();
    _checkController.dispose();
    _textController.dispose();
    _pulseController. dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti Layer
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _ModernConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                  centerX: size.width / 2,
                  centerY: size.height / 2 - 80,
                ),
              );
            },
          ),

          // Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              // Success Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: UserDesign.success.withOpacity(
                              0.3 * _pulseAnimation.value,
                            ),
                            blurRadius: 60 * _pulseAnimation. value,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: UserDesign. successGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: UserDesign. success.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ScaleTransition(
                      scale: _checkAnimation,
                      child: const Icon(
                        Icons.check_rounded,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Text Content
              FadeTransition(
                opacity: _textAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_textAnimation),
                  child: Column(
                    children: [
                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            UserDesign.textPrimary,
                            UserDesign. primaryTeal,
                          ],
                        ). createShader(bounds),
                        child: Text(
                          'Report Submitted!  🎉',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Thank you for helping keep our environment clean!',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: UserDesign.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Processing indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: UserDesign.primaryTealSoft,
                          borderRadius: BorderRadius. circular(50),
                          border: Border.all(
                            color: UserDesign.primaryTeal. withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  UserDesign. primaryTeal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'AI is verifying your report...',
                              style: GoogleFonts. inter(
                                fontSize: 14,
                                fontWeight: FontWeight. w500,
                                color: UserDesign.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== CONFETTI MODELS & PAINTER ====================
class _ConfettiParticle {
  final double angle;
  final double velocity;
  final double size;
  final Color color;
  final double delay;
  final double rotationSpeed;
  final int shape;

  _ConfettiParticle({
    required this.angle,
    required this.velocity,
    required this.size,
    required this. color,
    required this.delay,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ModernConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final double centerX;
  final double centerY;

  _ModernConfettiPainter({
    required this.particles,
    required this.progress,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final adjusted = ((progress - p.delay) / (1 - p.delay)). clamp(0.0, 1.0);
      if (adjusted <= 0) continue;

      final distance = p.velocity * adjusted;
      final gravity = 400 * adjusted * adjusted;
      final x = centerX + math.cos(p.angle) * distance;
      final y = centerY + math.sin(p. angle) * distance * 0.6 + gravity;

      // Fade out
      final opacity = (1 - adjusted * 0.7).clamp(0.0, 1.0);

      // Scale down
      final scale = (1 - adjusted * 0.5). clamp(0.3, 1.0);
      final currentSize = p.size * scale;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * adjusted * math.pi);

      final paint = Paint()
        ..color = p.color. withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Draw different shapes
      switch (p.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset. zero, currentSize / 2, paint);
          break;
        case 1: // Square
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset. zero,
                width: currentSize,
                height: currentSize,
              ),
              Radius.circular(currentSize * 0.2),
            ),
            paint,
          );
          break;
        case 2: // Star shape (simplified as diamond)
          final path = Path();
          path.moveTo(0, -currentSize / 2);
          path.lineTo(currentSize / 2, 0);
          path.lineTo(0, currentSize / 2);
          path.lineTo(-currentSize / 2, 0);
          path.close();
          canvas. drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ModernConfettiPainter old) =>
      old.progress != progress;
}