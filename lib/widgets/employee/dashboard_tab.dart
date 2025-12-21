import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

/// ==================== DESIGN CONSTANTS ====================
class DesignSystem {
  // Primary Colors (Oklch inspired)
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);

  // Surfaces
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color. withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
}

/// ==================== EMPLOYEE DASHBOARD TAB ====================
/// Layout Order:
/// 1.  Welcome/Position Header (TOP)
/// 2. Stats Overview
/// 3. Quick Actions
/// 4. Reports Section
/// 5.  Top 3 Leaderboard (END)
class EmployeeDashboardTab extends StatefulWidget {
  final Future<EmployeeStats> statsFuture;
  final Future<List<Report>>? acceptedReportsFuture;
  final Future<List<LeaderboardEntry>>?  leaderboardFuture;
  final Function(int) onNavigateToTab;
  final VoidCallback onRefresh;
  final Map<String, dynamic> employeeData;
  final bool isDemoMode;
  final int overdueCount;
  final EmployeeResponsiveData responsive;

  const EmployeeDashboardTab({
    super.key,
    required this.statsFuture,
    this.acceptedReportsFuture,
    this.leaderboardFuture,
    required this.onNavigateToTab,
    required this.onRefresh,
    required this.employeeData,
    required this.isDemoMode,
    this.overdueCount = 0,
    required this.responsive,
  });

  @override
  State<EmployeeDashboardTab> createState() => _EmployeeDashboardTabState();
}

class _EmployeeDashboardTabState extends State<EmployeeDashboardTab>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _statsController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _confettiController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _initAnimations() {
    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    // Slide animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Stats counter animation
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutExpo,
    );

    // Pulse animation for alerts
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2). animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    _slideController. forward();
    _statsController.forward();

    if (widget.overdueCount > 0) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _statsController. dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _confettiController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EmployeeStats>(
      future: widget. statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildModernLoadingState();
        }
        if (snapshot.hasError) {
          return _buildModernErrorState(snapshot.error. toString());
        }
        if (! snapshot.hasData) {
          return _buildModernEmptyState();
        }
        return _buildDashboardContent(snapshot.data!);
      },
    );
  }

  Widget _buildDashboardContent(EmployeeStats stats) {
    final r = widget.responsive;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            widget.onRefresh();
          },
          color: DesignSystem.primaryTeal,
          backgroundColor: Colors.white,
          strokeWidth: 2.5,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Spacer for top padding
              SliverToBoxAdapter(
                child: SizedBox(height: r.padding),
              ),

              // 1.  POSITION/WELCOME HEADER (TOP)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.padding),
                  child: _buildPositionHeader(r),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // Overdue Alert (if any)
              if (widget.overdueCount > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: _buildModernOverdueAlert(r),
                  ),
                ),

              if (widget.overdueCount > 0)
                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // 2. STATS OVERVIEW
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.padding),
                  child: _buildModernStatsSection(r, stats),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // 3. QUICK ACTIONS
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.padding),
                  child: _buildModernQuickActions(r),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // 4. REPORTS SECTION
              if (widget.acceptedReportsFuture != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r. padding),
                    child: _buildModernReportsSection(r),
                  ),
                ),

              if (widget.acceptedReportsFuture != null)
                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // 5.  TOP 3 LEADERBOARD (END)
              if (widget.leaderboardFuture != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: _buildModernLeaderboard(r),
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: r.safePaddingBottom + 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 1. POSITION/WELCOME HEADER ====================
  Widget _buildPositionHeader(EmployeeResponsiveData r) {
    final name = widget.employeeData['name'] ??  'Employee';
    final firstName = name.split(' '). first;
    final profileImage = widget.employeeData['profile_image'] ??
        widget.employeeData['profileImage'];
    final position = widget.employeeData['position'] ??  'Waste Collection Worker';
    final rank = widget.employeeData['rank'] ??  5;

    return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + (value * 0.1),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          padding: EdgeInsets. all(r.largePadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DesignSystem.primaryTeal,
                DesignSystem.primaryTealLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
            boxShadow: DesignSystem.glowShadow(DesignSystem.primaryTeal),
          ),
          child: Column(
              children: [
              Row(
              children: [
              // Avatar with status ring
              _buildAnimatedAvatar(r, profileImage, firstName),
          SizedBox(width: r.padding),

          // User info
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Greeting
                  if (r.showSecondaryText)
              Text(
              _getSmartGreeting(),
          style: GoogleFonts.inter(
            fontSize: r.captionM,
            color: Colors.white. withOpacity(0.85),
            fontWeight: FontWeight. w500,
          ),
        ),
        SizedBox(height: r.atomicPadding),

        // Name
        Text(
          r.adaptiveText(
            'Hello, $firstName! ',
            nano: firstName[0],
            micro: firstName.length >= 4
                ? firstName.substring(0, 4)
                : firstName,

            mini: 'Hi, $firstName',
          ),
          style: GoogleFonts.inter(
            fontSize: r.headingS,
            fontWeight: FontWeight. w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Position badge
        if (r.showDetailedContent) ...[
    SizedBox(height: r.microPadding),
    Container(
    padding: EdgeInsets. symmetric(
    horizontal: r.microPadding,
    vertical: r.nanoPadding,
    ),
    decoration: BoxDecoration(
    color: Colors.white. withOpacity(0.2),
    borderRadius: BorderRadius. circular(r.pillBorderRadius),
    border: Border.all(
    color: Colors. white.withOpacity(0.3),
    width: 1,
    ),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    Icons. work_outline_rounded,
    size: r.iconSize(12),
    color: Colors.white,
    ),
    SizedBox(width: r. nanoPadding),
    Flexible(
    child: Text(
    position,
    style: GoogleFonts. inter(
    fontSize: r. captionS,
    color: Colors.white,
    fontWeight: FontWeight. w500,
    ),
    maxLines: 1,
    overflow: TextOverflow. ellipsis,
    ),
    ),
    ],
    ),
    ),
    ],
    ],
    ),
    ),

    // Rank badge
    if (r.showTrends)
    _buildRankBadge(r, rank),
    ],
    ),

    // Performance bar
    if (r.showDetailedContent) ...[
    SizedBox(height: r.padding),
    _buildPerformanceBar(r),
    ],
    ],
    ),
    ),
    );
  }

  Widget _buildAnimatedAvatar(EmployeeResponsiveData r, String?  profileImage, String name) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets. all(r.dimension(3)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black. withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          width: r.welcomeAvatarSize,
          height: r.welcomeAvatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignSystem.primaryTealDark,
          ),
          child: ClipOval(
            child: profileImage != null && profileImage. isNotEmpty
                ? Image.network(
              profileImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildAvatarInitial(r, name),
            )
                : _buildAvatarInitial(r, name),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInitial(EmployeeResponsiveData r, String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignSystem.primaryTealDark,
            DesignSystem.primaryTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name. isNotEmpty ?  name[0]. toUpperCase() : '? ',
          style: GoogleFonts. inter(
            fontSize: r.welcomeAvatarSize * 0.4,
            fontWeight: FontWeight. w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(EmployeeResponsiveData r, int rank) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform. scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          color: Colors.white. withOpacity(0.2),
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          border: Border. all(
            color: Colors.white. withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons. leaderboard_rounded,
              color: Colors.white,
              size: r.iconSize(20),
            ),
            SizedBox(height: r.atomicPadding),
            Text(
              '#$rank',
              style: GoogleFonts.inter(
                fontSize: r. bodyM,
                fontWeight: FontWeight. w800,
                color: Colors.white,
              ),
            ),
            if (r.showSecondaryText)
              Text(
                'Rank',
                style: GoogleFonts.inter(
                  fontSize: r.captionXS,
                  color: Colors.white. withOpacity(0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBar(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors.white. withOpacity(0.15),
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week\'s Progress',
                style: GoogleFonts. inter(
                  fontSize: r.captionM,
                  color: Colors. white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '78%',
                style: GoogleFonts.inter(
                  fontSize: r. captionM,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: r.nanoPadding),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 0.78),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Container(
                height: r.dimension(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius. circular(r.pillBorderRadius),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(r.pillBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors. white.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getSmartGreeting() {
    final hour = DateTime.now(). hour;
    if (hour < 5) return '🌙 Working late? ';
    if (hour < 12) return '☀️ Good Morning';
    if (hour < 17) return '🌤️ Good Afternoon';
    if (hour < 21) return '🌅 Good Evening';
    return '🌙 Good Night';
  }

  // ==================== OVERDUE ALERT ====================
  Widget _buildModernOverdueAlert(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DesignSystem.error,
              DesignSystem.error. withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius. circular(r.largeBorderRadius),
          boxShadow: DesignSystem.glowShadow(DesignSystem.error),
        ),
        child: Row(
          children: [
            // Animated warning icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform. rotate(
                  angle: (1 - value) * 0.5,
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration: BoxDecoration(
                  color: Colors.white. withOpacity(0.2),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: r.iconSize(24),
                ),
              ),
            ),
            SizedBox(width: r. microPadding),

            // Alert text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r. adaptiveText(
                      'Action Required! ',
                      nano: '! ',
                      micro: 'Alert! ',
                      mini: 'Action! ',
                    ),
                    style: GoogleFonts. inter(
                      fontSize: r.bodyM,
                      fontWeight: FontWeight. w700,
                      color: Colors.white,
                    ),
                  ),
                  if (r.showSecondaryText)
                    Text(
                      '${widget.overdueCount} task${widget.overdueCount > 1 ? 's' : ''} overdue',
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: Colors.white. withOpacity(0.9),
                      ),
                    ),
                ],
              ),
            ),

            // View button
            _buildGlassButton(
              r,
              label: r.adaptiveText('View', nano: '→', micro: '→'),
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onNavigateToTab(1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton(
      EmployeeResponsiveData r, {
        required String label,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius. circular(r.borderRadius),
        child: Container(
          padding: EdgeInsets. symmetric(
            horizontal: r. microPadding,
            vertical: r.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black. withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: r.captionL,
              fontWeight: FontWeight.w700,
              color: DesignSystem.error,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 2.  STATS OVERVIEW ====================
  Widget _buildModernStatsSection(EmployeeResponsiveData r, EmployeeStats stats) {
    final statItems = [
      _ModernStatItem(
        label: 'Total',
        value: stats.totalReports,
        icon: Icons.assignment_rounded,
        color: DesignSystem.info,
        trend: '+5',
        trendUp: true,
      ),
      _ModernStatItem(
        label: 'Completed',
        value: stats.resolvedReports,
        icon: Icons. check_circle_rounded,
        color: DesignSystem.success,
        trend: '+3',
        trendUp: true,
      ),
      _ModernStatItem(
        label: 'In Progress',
        value: stats.inProgressReports,
        icon: Icons.sync_rounded,
        color: DesignSystem.warning,
        trend: null,
        trendUp: true,
      ),
      _ModernStatItem(
        label: 'Pending',
        value: stats.pendingReports,
        icon: Icons.pending_rounded,
        color: DesignSystem. textSecondary,
        trend: '-2',
        trendUp: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernSectionHeader(
          r,
          title: 'Stats Overview',
          icon: Icons.insights_rounded,
          iconColor: DesignSystem.info,
        ),
        SizedBox(height: r.microPadding),

        // Stats grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: r.statsGridColumns,
            crossAxisSpacing: r.gridSpacing,
            mainAxisSpacing: r.gridSpacing,
            childAspectRatio: r.statsCardAspectRatio,
          ),
          itemCount: statItems.length,
          itemBuilder: (context, index) {
            return _buildModernStatCard(r, statItems[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildModernStatCard(EmployeeResponsiveData r, _ModernStatItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          color: DesignSystem.surfaceWhite,
          borderRadius: BorderRadius. circular(r.largeBorderRadius),
          boxShadow: DesignSystem.softShadow,
          border: Border.all(
            color: item.color. withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon and trend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets. all(r.nanoPadding),
                  decoration: BoxDecoration(
                    color: item.color. withOpacity(0.1),
                    borderRadius: BorderRadius. circular(r.smallBorderRadius),
                  ),
                  child: Icon(
                    item. icon,
                    size: r.iconSize(18),
                    color: item.color,
                  ),
                ),
                if (item.trend != null && r.showTrends)
                  Container(
                    padding: EdgeInsets. symmetric(
                      horizontal: r.nanoPadding,
                      vertical: r.atomicPadding,
                    ),
                    decoration: BoxDecoration(
                      color: (item.trendUp ?  DesignSystem. success : DesignSystem.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r. smallBorderRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize. min,
                      children: [
                        Icon(
                          item.trendUp
                              ? Icons.trending_up_rounded
                              : Icons. trending_down_rounded,
                          size: r.iconSize(10),
                          color: item.trendUp ? DesignSystem.success : DesignSystem.error,
                        ),
                        SizedBox(width: r.atomicPadding),
                        Text(
                          item.trend! ,
                          style: GoogleFonts.inter(
                            fontSize: r. captionXS,
                            fontWeight: FontWeight. w600,
                            color: item.trendUp ? DesignSystem.success : DesignSystem. error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Value
            AnimatedBuilder(
              animation: _statsAnimation,
              builder: (context, child) {
                final displayValue = (item.value * _statsAnimation.value). round();
                return Text(
                  '$displayValue',
                  style: GoogleFonts.inter(
                    fontSize: r.headingM,
                    fontWeight: FontWeight. w800,
                    color: DesignSystem.textPrimary,
                    letterSpacing: -1,
                  ),
                );
              },
            ),

            // Label
            Text(
              r.adaptiveText(
                item.label,
                nano: item.label[0],
                micro: item.label. substring(0, math.min(4, item.label. length)),
              ),
              style: GoogleFonts. inter(
                fontSize: r.captionM,
                color: DesignSystem. textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 3.  QUICK ACTIONS ====================
  Widget _buildModernQuickActions(EmployeeResponsiveData r) {
    final actions = [
      _ModernQuickAction(
        label: 'New Task',
        icon: Icons.add_task_rounded,
        color: DesignSystem.primaryTeal,
        onTap: () => widget.onNavigateToTab(1),
      ),
      _ModernQuickAction(
        label: 'View Map',
        icon: Icons.map_rounded,
        color: DesignSystem. success,
        onTap: () => widget.onNavigateToTab(2),
      ),
      _ModernQuickAction(
        label: 'Analytics',
        icon: Icons.analytics_rounded,
        color: DesignSystem. info,
        onTap: () => widget.onNavigateToTab(3),
      ),
      _ModernQuickAction(
        label: 'Rankings',
        icon: Icons.emoji_events_rounded,
        color: DesignSystem.warning,
        onTap: () => widget.onNavigateToTab(4),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernSectionHeader(
          r,
          title: 'Quick Actions',
          icon: Icons.bolt_rounded,
          iconColor: DesignSystem.warning,
        ),
        SizedBox(height: r.microPadding),

        // Horizontal scrollable actions
        SizedBox(
          height: r.dimension(100),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions. length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets. only(
                  right: index < actions.length - 1 ? r. microPadding : 0,
                ),
                child: _buildModernActionCard(r, actions[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionCard(EmployeeResponsiveData r, _ModernQuickAction action, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform. translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            action.onTap();
          },
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          child: Container(
            width: r.dimension(90),
            padding: EdgeInsets. all(r.microPadding),
            decoration: BoxDecoration(
              color: DesignSystem. surfaceWhite,
              borderRadius: BorderRadius.circular(r.largeBorderRadius),
              boxShadow: DesignSystem.softShadow,
              border: Border.all(
                color: action.color.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets. all(r.microPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.color,
                        action.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius. circular(r.borderRadius),
                    boxShadow: DesignSystem.glowShadow(action.color),
                  ),
                  child: Icon(
                    action.icon,
                    size: r.iconSize(22),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: r. nanoPadding),
                Text(
                  r.adaptiveText(
                    action. label,
                    nano: action.label[0],
                    micro: action. label.substring(0, math.min(4, action.label.length)),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight. w600,
                    color: DesignSystem.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 4. REPORTS SECTION ====================
  Widget _buildModernReportsSection(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernSectionHeader(
          r,
          title: 'Active Reports',
          icon: Icons.assignment_turned_in_rounded,
          iconColor: widget.overdueCount > 0 ? DesignSystem.error : DesignSystem.primaryTeal,
          trailing: _buildViewAllButton(r, () => widget.onNavigateToTab(1)),
        ),
        SizedBox(height: r.microPadding),

        FutureBuilder<List<Report>>(
          future: widget.acceptedReportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerReportCards(r);
            }
            if (! snapshot.hasData || snapshot.data!. isEmpty) {
              return _buildNoReportsCard(r);
            }

            final activeReports = snapshot. data!
                .where((r) => r.isActive)
                . toList()
              ..sort((a, b) {
                if (a.isOverdue && ! b.isOverdue) return -1;
                if (!a.isOverdue && b.isOverdue) return 1;
                return b.acceptanceDate.compareTo(a.acceptanceDate);
              });

            if (activeReports. isEmpty) {
              return _buildNoReportsCard(r);
            }

            final maxToShow = r.responsive<int>(
              base: 3,
              nano: 1,
              micro: 2,
              mini: 2,
              tiny: 3,
            );
            final displayReports = activeReports.take(maxToShow).toList();

            return Column(
              children: [
                ... displayReports.asMap().entries.map((entry) {
                  return _buildModernReportCard(r, entry.value, entry.key);
                }),
                if (activeReports.length > maxToShow)
                  _buildShowMoreButton(r, activeReports.length - maxToShow),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildModernReportCard(EmployeeResponsiveData r, Report report, int index) {
    final isOverdue = report.isOverdue;
    final daysSinceAccepted = report. daysSinceAccepted;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves. easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onNavigateToTab(1);
          },
          child: Container(
              margin: EdgeInsets. only(bottom: r.microPadding),
              padding: EdgeInsets. all(r.padding),
              decoration: BoxDecoration(
                color: isOverdue
                    ? DesignSystem.error. withOpacity(0.05)
                    : DesignSystem.surfaceWhite,
                borderRadius: BorderRadius.circular(r.largeBorderRadius),
                boxShadow: isOverdue
                    ? DesignSystem.glowShadow(DesignSystem. error. withOpacity(0.3))
                    : DesignSystem.softShadow,
                border: Border. all(
                  color: isOverdue
                      ? DesignSystem.error.withOpacity(0.3)
                      : Colors.grey. withOpacity(0.1),
                  width: isOverdue ? 2 : 1,
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Header row
                  Row(
                  children: [
                  // Status indicator with pulse
                  _buildStatusIndicator(r, report, isOverdue),
              SizedBox(width: r.microPadding),

              // Title and type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment. start,
                  children: [
                    Text(
                      report.displayTitle,
                      style: GoogleFonts.inter(
                        fontSize: r. bodyS,
                        fontWeight: FontWeight. w700,
                        color: isOverdue
                            ? DesignSystem.error
                            : DesignSystem.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (r.showSecondaryText)
                      Row(
                        children: [
                          _buildWasteTypeChip(r, report.type),
                          SizedBox(width: r.nanoPadding),
                          Icon(
                            Icons.location_on_outlined,
                            size: r.iconSize(12),
                            color: DesignSystem.textTertiary,
                          ),
                          SizedBox(width: r.atomicPadding),
                          Expanded(
                            child: Text(
                              report. location,
                              style: GoogleFonts.inter(
                                fontSize: r.captionS,
                                color: DesignSystem.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Overdue badge or arrow
              if (isOverdue)
          _buildOverdueBadge(r, daysSinceAccepted)
      else
      Icon(
      Icons.chevron_right_rounded,
      size: r.iconSize(20),
      color: DesignSystem.textTertiary,
    ),
    ],
    ),

    // Footer with time and status
    if (r.showDetailedContent) ...[
    SizedBox(height: r.microPadding),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    // Time info
    Row(
    children: [
    Icon(
    Icons.schedule_rounded,
    size: r. iconSize(14),
    color: isOverdue
    ? DesignSystem.error
        : DesignSystem.textTertiary,
    ),
    SizedBox(width: r.atomicPadding),
    Text(
    isOverdue
    ? 'Overdue by $daysSinceAccepted days'
        : daysSinceAccepted > 0
    ? 'Accepted ${daysSinceAccepted}d ago'
        : 'Accepted today',
    style: GoogleFonts.inter(
    fontSize: r. captionS,
    fontWeight: isOverdue ?  FontWeight.w600 : FontWeight.w500,
    color: isOverdue
    ? DesignSystem.error
        : DesignSystem.textSecondary,
    ),
    ),
    ],
    ),

    // Status chip
    _buildStatusChip(r, report.status),
    ],
    ),
    ],
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildStatusIndicator(EmployeeResponsiveData r, Report report, bool isOverdue) {
    if (isOverdue) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: r.dimension(12),
            height: r.dimension(12),
            decoration: BoxDecoration(
              color: DesignSystem.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.error.withOpacity(0.4 * _pulseAnimation.value),
                  blurRadius: 8 * _pulseAnimation. value,
                  spreadRadius: 2 * (_pulseAnimation.value - 1),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      width: r.dimension(10),
      height: r.dimension(10),
      decoration: BoxDecoration(
        color: report.statusColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildWasteTypeChip(EmployeeResponsiveData r, String type) {
    final color = _getWasteTypeColor(type);

    return Container(
      padding: EdgeInsets. symmetric(
        horizontal: r. nanoPadding,
        vertical: r. atomicPadding,
      ),
      decoration: BoxDecoration(
        color: color. withOpacity(0.1),
        borderRadius: BorderRadius. circular(r.smallBorderRadius),
      ),
      child: Text(
        type,
        style: GoogleFonts.inter(
          fontSize: r.captionXS,
          fontWeight: FontWeight. w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOverdueBadge(EmployeeResponsiveData r, int days) {
    return Container(
      padding: EdgeInsets. symmetric(
        horizontal: r.microPadding,
        vertical: r. nanoPadding,
      ),
      decoration: BoxDecoration(
        color: DesignSystem. error,
        borderRadius: BorderRadius. circular(r.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            size: r.iconSize(12),
            color: Colors.white,
          ),
          SizedBox(width: r.atomicPadding),
          Text(
            '${days}d',
            style: GoogleFonts.inter(
              fontSize: r.captionS,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(EmployeeResponsiveData r, String status) {
    final color = _getStatusColor(status);
    final label = _formatStatus(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.nanoPadding,
        vertical: r. atomicPadding,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Text(
        label,
        style: GoogleFonts. inter(
          fontSize: r.captionXS,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildShimmerReportCards(EmployeeResponsiveData r) {
    return Column(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets. only(bottom: r.microPadding),
              height: r.listTileHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius. circular(r.largeBorderRadius),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _shimmerAnimation.value, 0),
                  end: Alignment(_shimmerAnimation.value, 0),
                  colors: [
                    Colors. grey[200]!,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildNoReportsCard(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.largePadding),
      decoration: BoxDecoration(
        color: DesignSystem.surfaceLight,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(r.padding),
            decoration: BoxDecoration(
              color: DesignSystem.primaryTeal. withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: r.iconSize(40),
              color: DesignSystem.primaryTeal,
            ),
          ),
          SizedBox(height: r.microPadding),
          Text(
            'All caught up!',
            style: GoogleFonts.inter(
              fontSize: r. bodyM,
              fontWeight: FontWeight.w700,
              color: DesignSystem. textPrimary,
            ),
          ),
          if (r.showSecondaryText) ...[
            SizedBox(height: r.nanoPadding),
            Text(
              'No active tasks at the moment',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(EmployeeResponsiveData r, int count) {
    return Padding(
      padding: EdgeInsets. only(top: r.microPadding),
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          widget. onNavigateToTab(1);
        },
        style: TextButton.styleFrom(
          foregroundColor: DesignSystem.primaryTeal,
          padding: EdgeInsets. symmetric(
            horizontal: r.padding,
            vertical: r.microPadding,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            Text(
              'View $count more tasks',
              style: GoogleFonts. inter(
                fontSize: r.captionL,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: r.nanoPadding),
            Icon(Icons.arrow_forward_rounded, size: r. iconSize(16)),
          ],
        ),
      ),
    );
  }

  // ==================== 5. LEADERBOARD ====================
  Widget _buildModernLeaderboard(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModernSectionHeader(
          r,
          title: 'Top Performers',
          icon: Icons.emoji_events_rounded,
          iconColor: DesignSystem. warning,
          trailing: _buildViewAllButton(r, () => widget.onNavigateToTab(4)),
        ),
        SizedBox(height: r.microPadding),

        FutureBuilder<List<LeaderboardEntry>>(
          future: widget.leaderboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLeaderboard(r);
            }
            if (! snapshot.hasData || snapshot.data!. isEmpty) {
              return _buildNoLeaderboardCard(r);
            }

            final topThree = snapshot.data!. take(3).toList();
            return _buildModernPodium(r, topThree);
          },
        ),
      ],
    );
  }

  Widget _buildModernPodium(EmployeeResponsiveData r, List<LeaderboardEntry> topThree) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    final heights = [r.dimension(120), r.dimension(100), r.dimension(80)];
    final displayOrder = [1, 0, 2]; // Silver, Gold, Bronze

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFBEB),
            const Color(0xFFFEF3C7),
          ],
          begin: Alignment. topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
        boxShadow: DesignSystem.softShadow,
      ),
      child: Column(
          children: [
      // Trophy animation
      TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform. scale(
          scale: value,
          child: Transform.rotate(
            angle: (1 - value) * 0.3,
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets. all(r.microPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors[0], colors[0].withOpacity(0.7)],
            begin: Alignment. topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: DesignSystem.glowShadow(colors[0]),
        ),
        child: Icon(
          Icons.emoji_events_rounded,
          size: r.iconSize(32),
          color: Colors.white,
        ),
      ),
    ),
    SizedBox(height: r.padding),

    // Podium
    Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: displayOrder.map((rankIndex) {
    if (rankIndex >= topThree.length) return const SizedBox.shrink();

    final person = topThree[rankIndex];
    final color = colors[rankIndex];
    final height = heights[rankIndex];
    final isFirst = rankIndex == 0;

    return Expanded(
    child: TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 800 + (rankIndex * 200)),
    curve: Curves.easeOutBack,
    builder: (context, value, child) {
    return Transform.translate(
    offset: Offset(0, 50 * (1 - value)),
    child: Opacity(opacity: value, child: child),
    );
    },
    child: Padding(
    padding: EdgeInsets. symmetric(horizontal: r.nanoPadding),
    child: Column(
    mainAxisSize: MainAxisSize. min,
    children: [
    // Crown for first place
    if (isFirst)
    TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 1200),
    curve: Curves.elasticOut,
    builder: (context, value, child) {
    return Transform.scale(
    scale: value,
    child: child,
    );
    },
    child: Icon(
    Icons.workspace_premium_rounded,
    size: r.iconSize(28),
    color: color,
    ),
    ),
    if (isFirst) SizedBox(height: r.nanoPadding),

    // Avatar
    Container(
    width: isFirst ? r.avatarSize : r. avatarSizeSmall,
    height: isFirst ?  r.avatarSize : r.avatarSizeSmall,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: color, width: 3),
    boxShadow: DesignSystem.glowShadow(color),
    ),
    child: ClipOval(
    child: person.profileImage != null
    ?  Image.network(
    person.profileImage! ,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
    _buildAvatarInitial(r, person. name),
    )
        : _buildAvatarInitial(r, person.name),
    ),
    ),
    SizedBox(height: r.nanoPadding),

    // Name
    Text(
    person.name. split(' ').first,
    style: GoogleFonts.inter(
    fontSize: isFirst ? r.captionL : r.captionM,
    fontWeight: FontWeight.w700,
    color: DesignSystem.textPrimary,
    ),
    maxLines: 1,
    overflow: TextOverflow. ellipsis,
    ),

    // Podium block
    SizedBox(height: r.nanoPadding),
    Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [color, color.withOpacity(0.7)],
    begin: Alignment. topCenter,
    end: Alignment.bottomCenter,
    ),
    borderRadius: BorderRadius. vertical(
    top: Radius.circular(r.borderRadius),
    ),
    boxShadow: DesignSystem.glowShadow(color),
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment. center,
    children: [
    Text(
    '${rankIndex + 1}',
    style: GoogleFonts. inter(
    fontSize: isFirst ? r.headingM : r.headingS,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    ),
    ),
    Container(
    padding: EdgeInsets. symmetric(
    horizontal: r.nanoPadding,
    vertical: r. atomicPadding,
    ),
    decoration: BoxDecoration(
    color: Colors.white. withOpacity(0.2),
    borderRadius: BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Text(
      '${person.points} pts',
      style: GoogleFonts.inter(
      fontSize: r.captionS,
      fontWeight: FontWeight. w700,
      color: Colors.white,
      ),
      ),
      ),
      if (r.showSecondaryText) ...[
      SizedBox(height: r.atomicPadding),
      Row(
      mainAxisAlignment: MainAxisAlignment. center,
      children: [
      Icon(
      Icons.star_rounded,
      size: r.iconSize(12),
      color: Colors.white. withOpacity(0.9),
      ),
      SizedBox(width: r.atomicPadding),
      Text(
      person.rating.toStringAsFixed(1),
      style: GoogleFonts.inter(
      fontSize: r.captionXS,
      color: Colors.white. withOpacity(0.9),
      ),
      ),
      ],
      ),
      ],
      ],
      ),
      ),
      ],
      ),
      ),
      ),
      );
    }). toList(),
    ),
          ],
      ),
    );
  }

  Widget _buildShimmerLeaderboard(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          height: r.dimension(200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _shimmerAnimation.value, 0),
              end: Alignment(_shimmerAnimation.value, 0),
              colors: [
                Colors.grey[200]!,
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoLeaderboardCard(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets. all(r.largePadding),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
      ),
      child: Column(
        children: [
          Icon(
            Icons. emoji_events_outlined,
            size: r.iconSize(40),
            color: DesignSystem.warning. withOpacity(0.5),
          ),
          SizedBox(height: r.microPadding),
          Text(
            'No rankings yet',
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: DesignSystem. textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildModernSectionHeader(
      EmployeeResponsiveData r, {
        required String title,
        required IconData icon,
        required Color iconColor,
        Widget? trailing,
      }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets. all(r.nanoPadding),
          decoration: BoxDecoration(
            color: iconColor. withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Icon(
            icon,
            size: r.iconSize(18),
            color: iconColor,
          ),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts. inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight. w700,
              color: DesignSystem.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildViewAllButton(EmployeeResponsiveData r, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius. circular(r.smallBorderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: r. microPadding,
            vertical: r. nanoPadding,
          ),
          decoration: BoxDecoration(
            color: DesignSystem. primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r.adaptiveText('View All', nano: '→', micro: 'All'),
                style: GoogleFonts. inter(
                  fontSize: r.captionS,
                  fontWeight: FontWeight. w600,
                  color: DesignSystem.primaryTeal,
                ),
              ),
              SizedBox(width: r.atomicPadding),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: r.iconSize(10),
                color: DesignSystem. primaryTeal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LOADING/ERROR/EMPTY STATES ====================
  Widget _buildModernLoadingState() {
    final r = widget.responsive;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loader
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math.pi,
                child: Container(
                  width: r.avatarSize,
                  height: r. avatarSize,
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      colors: [
                        DesignSystem.primaryTeal,
                        DesignSystem.primaryTeal.withOpacity(0.1),
                        DesignSystem. primaryTeal,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: r.avatarSize - 8,
                      height: r.avatarSize - 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        size: r.iconSize(24),
                        color: DesignSystem.primaryTeal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: r.padding),
          Text(
            'Loading your dashboard...',
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernErrorState(String error) {
    final r = widget.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets. all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            Container(
              padding: EdgeInsets.all(r.padding),
              decoration: BoxDecoration(
                color: DesignSystem.error. withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: r.iconSize(48),
                color: DesignSystem. error,
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight. w700,
                color: DesignSystem. textPrimary,
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              'Please try again',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: DesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.padding),
            ElevatedButton. icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onRefresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets. symmetric(
                  horizontal: r.largePadding,
                  vertical: r.microPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r. borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernEmptyState() {
    final r = widget. responsive;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment. center,
        children: [
          Container(
            padding: EdgeInsets.all(r.padding),
            decoration: BoxDecoration(
              color: DesignSystem.primaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dashboard_outlined,
              size: r.iconSize(48),
              color: DesignSystem.primaryTeal,
            ),
          ),
          SizedBox(height: r.padding),
          Text(
            'No data available',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight. w600,
              color: DesignSystem. textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  Color _getWasteTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('plastic')) return DesignSystem.info;
    if (t.contains('organic')) return DesignSystem.success;
    if (t.contains('hazardous')) return DesignSystem.error;
    if (t.contains('electronic')) return const Color(0xFF8B5CF6);
    if (t.contains('glass')) return const Color(0xFF06B6D4);
    if (t.contains('metal')) return const Color(0xFF6B7280);
    if (t.contains('paper')) return const Color(0xFFA16207);
    if (t.contains('mixed')) return DesignSystem.warning;
    return DesignSystem.textSecondary;
  }

  Color _getStatusColor(String status) {
    switch (status. toLowerCase()) {
      case 'pending':
        return DesignSystem.textSecondary;
      case 'accepted':
        return DesignSystem.info;
      case 'in_progress':
      case 'in-progress':
        return DesignSystem. warning;
      case 'resolved':
        return DesignSystem.success;
      default:
        return DesignSystem.textSecondary;
    }
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'in-progress':
        return 'IN PROGRESS';
      case 'accepted':
        return 'ACCEPTED';
      case 'resolved':
        return 'RESOLVED';
      case 'pending':
        return 'PENDING';
      default:
        return status. toUpperCase();
    }
  }
}

// ==================== DATA CLASSES ====================
class _ModernStatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String?  trend;
  final bool trendUp;

  _ModernStatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp = true,
  });
}

class _ModernQuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ModernQuickAction({
    required this.label,
    required this.icon,
    required this. color,
    required this.onTap,
  });
}