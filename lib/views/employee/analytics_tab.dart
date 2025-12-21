import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/analytics_components/analytics_header.dart';
import 'package:neat_now/views/employee/analytics_components/key_metrics_section.dart';
import 'package:neat_now/views/employee/analytics_components/performance_chart_section.dart';
import 'package:neat_now/views/employee/analytics_components/weekly_activity_section.dart';
import 'package:neat_now/views/employee/analytics_components/task_distribution_section.dart';
import 'package:neat_now/views/employee/analytics_components/efficiency_section.dart';
import 'package:neat_now/views/employee/analytics_components/daily_comparison_section.dart';
import 'package:neat_now/views/employee/analytics_components/top_locations_section.dart';
import 'dart:math' as math;

/// Employee Analytics Tab (MVVM View)
class EmployeeAnalyticsTab extends StatefulWidget {
  final Future<AnalyticsData> analyticsFuture;
  final Future<List<Report>> reportsFuture;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;

  const EmployeeAnalyticsTab({
    super.key,
    required this. analyticsFuture,
    required this.reportsFuture,
    required this.onRefresh,
    required this.responsive,
  });

  @override
  State<EmployeeAnalyticsTab> createState() => _EmployeeAnalyticsTabState();
}

class _EmployeeAnalyticsTabState extends State<EmployeeAnalyticsTab>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _chartController;
  late AnimationController _counterController;
  late AnimationController _shimmerController;
  late AnimationController _rotateController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _counterAnimation;
  late Animation<double> _shimmerAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // ✅ SAFE ANIMATION START
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAnimations();
      }
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );

    _counterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _counterAnimation = CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOutExpo,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _startAnimations() async {
    // ✅ CHECK MOUNTED BEFORE EACH ANIMATION
    if (!mounted) return;

    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    _chartController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    _counterController.forward();
  }

  void _handleRefresh() {
    if (! mounted) return;
    HapticFeedback.mediumImpact();
    _rotateController.forward(from: 0);
    widget.onRefresh();
  }

  @override
  void dispose() {
    // ✅ STOP ALL ANIMATIONS FIRST
    _fadeController.stop();
    _chartController.stop();
    _counterController.stop();
    _shimmerController.stop();
    _rotateController. stop();

    // ✅ THEN DISPOSE
    _fadeController.dispose();
    _chartController.dispose();
    _counterController.dispose();
    _shimmerController.dispose();
    _rotateController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return FutureBuilder<AnalyticsData>(
      future: widget. analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(r);
        }
        if (snapshot.hasError) {
          return _buildErrorState(r, snapshot.error. toString());
        }
        if (! snapshot.hasData) {
          return _buildEmptyState(r);
        }
        return _buildContent(r, snapshot.data!);
      },
    );
  }

  Widget _buildContent(EmployeeResponsiveData r, AnalyticsData data) {
    final viewModel = AnalyticsTabViewModel(analyticsData: data);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => _handleRefresh(),
            color: AnalyticsDesign.primaryTeal,
            backgroundColor: Colors.white,
            strokeWidth: 2.5,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child:  Padding(
                    padding: EdgeInsets.all(r.padding),
                    child: AnalyticsHeader(
                      viewModel: viewModel,
                      responsive: r,
                      rotateAnimation: _rotateController,
                      onRefresh: _handleRefresh,
                      onPeriodChanged: (period) {
                        viewModel.setPeriod(period);
                        _restartAnimations();
                      },
                      onExport: (format) async {
                        await viewModel. exportData(format);
                        if (mounted) {
                          _showExportSuccessDialog(r, format);
                        }
                      },
                    ),
                  ),
                ),

                // Key Metrics
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: KeyMetricsSection(
                      viewModel:  viewModel,
                      responsive:  r,
                      counterAnimation: _counterAnimation,
                      onMetricTap: (key) {
                        HapticFeedback.lightImpact();
                        viewModel.toggleMetric(key);
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Performance Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: PerformanceChartSection(
                      viewModel: viewModel,
                      responsive: r,
                      chartAnimation: _chartAnimation,
                      onChartTypeChanged: (type) {
                        viewModel.setChartType(type);
                        _restartChartAnimation();
                      },
                      onComparisonToggled: () {
                        viewModel.toggleComparison();
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(child:  SizedBox(height: r. sectionSpacing)),

                // Weekly Activity
                // In _buildContent method where WeeklyActivitySection is created:

// Weekly Activity
                SliverToBoxAdapter(
                  child:  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: WeeklyActivitySection(
                      viewModel: viewModel,
                      responsive: r,
                      chartAnimation: _chartAnimation,
                      onBarTap: (dayIndex, value) {
                        _showDayDetails(r, viewModel, dayIndex, value);
                      },
                      onComparisonToggled: () {
                        // ✅ THIS IS THE FIX - Toggle in ViewModel
                        viewModel.toggleComparison();
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Task Distribution
                SliverToBoxAdapter(
                  child:  Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: TaskDistributionSection(
                      viewModel: viewModel,
                      responsive: r,
                      chartAnimation: _chartAnimation,
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Efficiency Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r. padding),
                    child: EfficiencySection(
                      viewModel: viewModel,
                      responsive: r,
                      chartAnimation: _chartAnimation,
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Daily Comparison
                if (r.showDetailedCharts)
                  SliverToBoxAdapter(
                    child:  Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.padding),
                      child: DailyComparisonSection(
                        viewModel: viewModel,
                        responsive: r,
                        chartAnimation: _chartAnimation,
                        onComparisonToggled: () {
                          viewModel.toggleComparison();
                        },
                      ),
                    ),
                  ),

                if (r.showDetailedCharts)
                  SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Top Locations
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: TopLocationsSection(
                      viewModel: viewModel,
                      responsive: r,
                    ),
                  ),
                ),

                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: r.safePaddingBottom + 100),
                ),
              ],
            ),
          ),

          // Exporting Overlay
          if (viewModel.isExporting) _buildExportingOverlay(r),
        ],
      ),
    );
  }

  void _restartAnimations() {
    if (! mounted) return;
    _chartController.forward(from: 0);
    _counterController.forward(from: 0);
  }

  void _restartChartAnimation() {
    if (!mounted) return;
    _chartController.forward(from: 0);
  }

  void _showDayDetails(
      EmployeeResponsiveData r,
      AnalyticsTabViewModel viewModel,
      int dayIndex,
      int value,
      ) {
    HapticFeedback.mediumImpact();
    final dayDetails = viewModel.getDayDetails(dayIndex, value);

    showModalBottomSheet(
      context:  context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DayDetailSheet(
        dayDetails: dayDetails,
        responsive: r,
      ),
    );
  }

  void _showExportSuccessDialog(EmployeeResponsiveData r, ExportFormat format) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Export Success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ExportSuccessDialog(
          format: format,
          responsive: r,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale:  CurvedAnimation(
            parent:  animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity:  animation,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildExportingOverlay(EmployeeResponsiveData r) {
    return Container(
      color: Colors.black. withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(r.largePadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: r.avatarSize,
                height: r.avatarSize,
                child: CircularProgressIndicator(
                  color:  AnalyticsDesign.primaryTeal,
                  strokeWidth:  3,
                ),
              ),
              SizedBox(height: r.padding),
              Text(
                'Exporting...',
                style: GoogleFonts.inter(
                  fontSize: r.bodyM,
                  fontWeight: FontWeight.w600,
                  color: AnalyticsDesign.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin:  0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math.pi,
                child: Container(
                  width: r.dimension(60),
                  height: r. dimension(60),
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      colors: [
                        AnalyticsDesign.primaryTeal,
                        AnalyticsDesign.primaryTeal. withOpacity(0.1),
                        AnalyticsDesign.primaryTeal,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: r. dimension(52),
                      height: r. dimension(52),
                      decoration: const BoxDecoration(
                        color: AnalyticsDesign.surfaceWhite,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.analytics_rounded,
                        size: r.iconSize(28),
                        color: AnalyticsDesign.primaryTeal,
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
              'Loading analytics...',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: AnalyticsDesign. textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState(EmployeeResponsiveData r, String error) {
    return Center(
        child:  Padding(
          padding: EdgeInsets.all(r.largePadding),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          Container(
          padding: EdgeInsets.all(r.largePadding),
          decoration: BoxDecoration(
            color: AnalyticsDesign.error. withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: r.iconSize(48),
            color: AnalyticsDesign.error,
          ),
        ),
        SizedBox(height: r.padding),
        Text(
          'Failed to load',
          style: GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight.w700,
            color: AnalyticsDesign.textPrimary,
          ),
        ),
        if (r.showSecondaryText) ...[
    SizedBox(height: r.microPadding),
    Text(
    'Please try again',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color:  AnalyticsDesign.textSecondary,
    ),
    textAlign: TextAlign.center,
    ),
    ],
    SizedBox(height: r.padding),
    ElevatedButton. icon(
    onPressed: _handleRefresh,
    icon: Icon(Icons.refresh_rounded, size: r.iconSize(18)),
    label: Text(
    'Retry',
    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor: AnalyticsDesign.primaryTeal,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(
    horizontal: r.largePadding,
    vertical: r.microPadding,
    ),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(r.borderRadius),
    ),
    elevation: 0,
    ),
    ),
    ],
    ),
    ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(EmployeeResponsiveData r) {
    return Center(
      child:  Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: EdgeInsets.all(r.largePadding),
                decoration: BoxDecoration(
                  color: AnalyticsDesign.primaryTeal. withOpacity(0.1),
                  shape: BoxShape. circle,
                ),
                child: Icon(
                  Icons. analytics_outlined,
                  size: r. iconSize(48),
                  color: AnalyticsDesign.primaryTeal,
                ),
              ),
            ),
            SizedBox(height: r. padding),
            Text(
              'No analytics data yet',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: AnalyticsDesign.textPrimary,
              ),
            ),
            if (r.showSecondaryText) ...[
              SizedBox(height: r. nanoPadding),
              Text(
                'Complete some tasks to see your insights',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: AnalyticsDesign.textSecondary,
                ),
                textAlign:  TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== DAY DETAIL SHEET ====================
class _DayDetailSheet extends StatelessWidget {
  final DayDetailsData dayDetails;
  final EmployeeResponsiveData responsive;

  const _DayDetailSheet({
    required this.dayDetails,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      margin: EdgeInsets.all(r.padding),
      padding: EdgeInsets.all(r.largePadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: AnalyticsDesign.elevatedShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration:  BoxDecoration(
                  color: AnalyticsDesign. primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(
                  Icons. calendar_today_rounded,
                  size: r. iconSize(24),
                  color: AnalyticsDesign.primaryTeal,
                ),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayDetails.dayName,
                      style: GoogleFonts.inter(
                        fontSize: r.headingS,
                        fontWeight: FontWeight.w800,
                        color: AnalyticsDesign.textPrimary,
                      ),
                    ),
                    Text(
                      '${dayDetails.value} tasks',
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: AnalyticsDesign.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close_rounded,
                  size: r.iconSize(24),
                ),
              ),
            ],
          ),
          SizedBox(height: r.padding),
          _buildDetailItem(
            r,
            'Tasks Completed',
            '${dayDetails.tasksCompleted}',
            Icons.check_circle_rounded,
            AnalyticsDesign.success,
          ),
          _buildDetailItem(
            r,
            'Tasks Reported',
            '${dayDetails. tasksReported}',
            Icons.assignment_rounded,
            AnalyticsDesign.info,
          ),
          _buildDetailItem(
            r,
            'Efficiency',
            '${dayDetails.efficiency. toStringAsFixed(1)}%',
            Icons.speed_rounded,
            AnalyticsDesign.primaryTeal,
          ),
          _buildDetailItem(
            r,
            'Top Location',
            dayDetails.topLocation,
            Icons.location_on_rounded,
            AnalyticsDesign.error,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      EmployeeResponsiveData r,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: r.microPadding),
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: color. withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: color. withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration:  BoxDecoration(
              color:  color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Icon(icon, size: r.iconSize(18), color: color),
          ),
          SizedBox(width:  r.microPadding),
          Expanded(
            child:  Text(
              label,
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: AnalyticsDesign.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              fontWeight: FontWeight.w700,
              color: AnalyticsDesign.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== EXPORT SUCCESS DIALOG ====================
class _ExportSuccessDialog extends StatelessWidget {
  final ExportFormat format;
  final EmployeeResponsiveData responsive;

  const _ExportSuccessDialog({
    required this.format,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(r.padding),
          padding: EdgeInsets.all(r.largePadding),
          constraints: BoxConstraints(maxWidth: r.dialogMaxWidth),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
            boxShadow: AnalyticsDesign.elevatedShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  padding: EdgeInsets.all(r.padding),
                  decoration: BoxDecoration(
                    color: AnalyticsDesign.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: r.iconSize(48),
                    color: AnalyticsDesign.success,
                  ),
                ),
              ),
              SizedBox(height: r.padding),
              Text(
                'Export Successful!',
                style: GoogleFonts.inter(
                  fontSize: r.headingS,
                  fontWeight: FontWeight.w700,
                  color: AnalyticsDesign.textPrimary,
                ),
              ),
              SizedBox(height: r.microPadding),
              Text(
                'Your analytics have been exported as ${format.name. toUpperCase()}',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: AnalyticsDesign.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.padding),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AnalyticsDesign.primaryTeal,
                  foregroundColor:  Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: r.largePadding,
                    vertical:  r.microPadding,
                  ),
                  shape:  RoundedRectangleBorder(
                    borderRadius:  BorderRadius.circular(r.borderRadius),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ELEVATED SHADOW ====================
extension on AnalyticsDesign {
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color:  Colors.black.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];


}