import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/dashboard_tab_viewmodel.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/dashboard_components/position_header.dart';
import 'package:neat_now/views/employee/dashboard_components/overdue_alert_card.dart';
import 'package:neat_now/views/employee/dashboard_components/stats_section.dart';
import 'package:neat_now/views/employee/dashboard_components/quick_actions_section.dart';
import 'package:neat_now/views/employee/dashboard_components/reports_section.dart';
import 'package:neat_now/views/employee/dashboard_components/leaderboard_section.dart';
import 'dart:math' as math;

import '../../models/employee/leaderboard_models.dart';

/// Design System Constants
class DesignSystem {
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
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
      color: color.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
}

/// Employee Dashboard Tab (MVVM View)
class EmployeeDashboardTab extends StatefulWidget {
  final Future<EmployeeStats> statsFuture;
  final Future<List<Report>>? acceptedReportsFuture;
  final Future<List<LeaderboardEntry>>? leaderboardFuture;
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

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAnimationSequence();
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutQuart);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statsAnimation =
        CurvedAnimation(parent: _statsController, curve: Curves.easeOutExpo);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // FIXED: Changed shimmer animation range from -2,2 to 0.0,1.0 to prevent opacity assertion error
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startAnimationSequence() async {
    if (!mounted) return;
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _statsController.forward();
    if (widget.overdueCount > 0 && mounted) _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(EmployeeDashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.overdueCount > 0 && oldWidget.overdueCount == 0) {
      if (mounted && !_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else if (widget.overdueCount == 0 && oldWidget.overdueCount > 0) {
      if (mounted && _pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.stop();
    _slideController.stop();
    _statsController.stop();
    _pulseController.stop();
    _shimmerController.stop();

    _fadeController.dispose();
    _slideController.dispose();
    _statsController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EmployeeStats>(
      future: widget.statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildLoadingState();
        if (snapshot.hasError) return _buildErrorState(snapshot.error.toString());
        if (!snapshot.hasData) return _buildEmptyState();
        return _buildDashboard(snapshot.data!);
      },
    );
  }

  Widget _buildDashboard(EmployeeStats stats) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        widget.acceptedReportsFuture ?? Future.value(<Report>[]),
        widget.leaderboardFuture ?? Future.value(<LeaderboardEntry>[]),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildLoadingState();

        final activeReports = (snapshot.data?[0] as List<Report>? ?? [])
            .where((r) => r.isActive)
            .toList()
          ..sort((a, b) {
            if (a.isOverdue && !b.isOverdue) return -1;
            if (!a.isOverdue && b.isOverdue) return 1;
            return b.acceptanceDate.compareTo(a.acceptanceDate);
          });

        final topThree = (snapshot.data?[1] as List<LeaderboardEntry>? ?? [])
            .take(3)
            .toList();

        final viewModel = DashboardTabViewModel(
          employeeData: widget.employeeData,
          stats: stats,
          activeReports: activeReports,
          topThree: topThree,
          overdueCount: widget.overdueCount,
          isDemoMode: widget.isDemoMode,
        );

        return _buildDashboardContent(viewModel);
      },
    );
  }

  Widget _buildDashboardContent(DashboardTabViewModel viewModel) {
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
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: r.padding)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.padding),
                  child: PositionHeader(viewModel: viewModel, responsive: r),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),
              if (viewModel.overdueCount > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: OverdueAlertCard(
                      overdueCount: viewModel.overdueCount,
                      responsive: r,
                      pulseAnimation: _pulseAnimation,
                      onViewTap: () {
                        HapticFeedback.mediumImpact();
                        widget.onNavigateToTab(1);
                      },
                    ),
                  ),
                ),
              if (viewModel.overdueCount > 0)
                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.padding),
                  child: DashboardStatsSection(
                    statCards: viewModel.statCards,
                    responsive: r,
                    statsAnimation: _statsAnimation,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.padding),
                  child: DashboardQuickActionsSection(
                    actions: viewModel.quickActions,
                    responsive: r,
                    onActionTap: widget.onNavigateToTab,
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),
              if (widget.acceptedReportsFuture != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: DashboardReportsSection(
                      viewModel: viewModel,
                      responsive: r,
                      shimmerAnimation: _shimmerAnimation,
                      pulseAnimation: _pulseAnimation,
                      onNavigateToTab: widget.onNavigateToTab,
                    ),
                  ),
                ),
              if (widget.acceptedReportsFuture != null)
                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),
              if (widget.leaderboardFuture != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: DashboardLeaderboardSection(
                      viewModel: viewModel,
                      responsive: r,
                      shimmerAnimation: _shimmerAnimation,
                      onNavigateToTab: widget.onNavigateToTab,
                    ),
                  ),
                ),
              SliverToBoxAdapter(child: SizedBox(height: r.safePaddingBottom + 100)),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState() {
    final r = widget.responsive;

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
                child: Container(
                  width: r.dimension(60),
                  height: r.dimension(60),
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      colors: [
                        DesignSystem.primaryTeal,
                        DesignSystem.primaryTeal.withOpacity(0.1),
                        DesignSystem.primaryTeal,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: r.dimension(52),
                      height: r.dimension(52),
                      decoration: const BoxDecoration(
                        color: DesignSystem.surfaceWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.eco_rounded,
                        size: r.iconSize(28),
                        color: DesignSystem.primaryTeal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: r.padding),
          if (r.showMinimalText)
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

  // ==================== ERROR STATE ====================
  Widget _buildErrorState(String error) {
    final r = widget.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(r.padding),
              decoration: BoxDecoration(
                color: DesignSystem.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: r.iconSize(48),
                color: DesignSystem.error,
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'Something went wrong',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: DesignSystem.textPrimary,
              ),
            ),
            if (r.showSecondaryText) ...[
              SizedBox(height: r.microPadding),
              Text(
                'Please try again',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: DesignSystem.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            SizedBox(height: r.padding),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onRefresh();
              },
              icon: Icon(Icons.refresh_rounded, size: r.iconSize(18)),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: r.largePadding,
                  vertical: r.microPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    final r = widget.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                fontWeight: FontWeight.w700,
                color: DesignSystem.textPrimary,
              ),
            ),
            if (r.showSecondaryText) ...[
              SizedBox(height: r.microPadding),
              Text(
                'Pull down to refresh',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}