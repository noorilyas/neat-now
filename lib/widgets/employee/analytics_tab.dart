import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'package:neat_now/widgets/employee/weekly_activity_chart.dart';
import 'dart:math' as math;

/// ==================== DESIGN CONSTANTS ====================
class AnalyticsDesign {
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
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color indigo = Color(0xFF6366F1);
  static const Color cyan = Color(0xFF06B6D4);

  static const List<Color> chartColors = [
    primaryTeal,
    info,
    warning,
    purple,
    pink,
    success,
    error,
    cyan,
  ];

  static const List<Color> gradientColors = [
    Color(0xFF2AC2AB),
    Color(0xFF4ECDC4),
  ];
}

/// ==================== COMMAND PATTERN ====================
abstract class AnalyticsCommand {
  void execute();
  void undo();
  String get description;
}

class ChangePeriodCommand implements AnalyticsCommand {
  final _EmployeeAnalyticsTabState state;
  final int newPeriod;
  final int previousPeriod;

  ChangePeriodCommand({
    required this.state,
    required this.newPeriod,
    required this.previousPeriod,
  });

  @override
  void execute() => state._setPeriod(newPeriod);

  @override
  void undo() => state._setPeriod(previousPeriod);

  @override
  String get description => 'Change period to ${_getPeriodName(newPeriod)}';

  String _getPeriodName(int period) {
    switch (period) {
      case 0: return 'Week';
      case 1: return 'Month';
      case 2: return 'Year';
      default: return 'Unknown';
    }
  }
}

class ChangeChartTypeCommand implements AnalyticsCommand {
  final _EmployeeAnalyticsTabState state;
  final ChartType newType;
  final ChartType previousType;

  ChangeChartTypeCommand({
    required this.state,
    required this. newType,
    required this.previousType,
  });

  @override
  void execute() => state._setChartType(newType);

  @override
  void undo() => state._setChartType(previousType);

  @override
  String get description => 'Change chart to ${newType.name}';
}

class ToggleMetricCommand implements AnalyticsCommand {
  final _EmployeeAnalyticsTabState state;
  final String metricKey;

  ToggleMetricCommand({
    required this.state,
    required this. metricKey,
  });

  @override
  void execute() => state._toggleMetric(metricKey);

  @override
  void undo() => state._toggleMetric(metricKey);

  @override
  String get description => 'Toggle $metricKey visibility';
}

class RefreshDataCommand implements AnalyticsCommand {
  final _EmployeeAnalyticsTabState state;
  final VoidCallback onRefresh;

  RefreshDataCommand({
    required this.state,
    required this. onRefresh,
  });

  @override
  void execute() => onRefresh();

  @override
  void undo() {}

  @override
  String get description => 'Refresh analytics data';
}

class ExportDataCommand implements AnalyticsCommand {
  final _EmployeeAnalyticsTabState state;
  final ExportFormat format;

  ExportDataCommand({
    required this.state,
    required this.format,
  });

  @override
  void execute() => state._exportData(format);

  @override
  void undo() {}

  @override
  String get description => 'Export data as ${format.name}';
}

class AnalyticsCommandInvoker {
  final List<AnalyticsCommand> _history = [];
  final List<AnalyticsCommand> _redoStack = [];
  int _historyIndex = -1;

  void executeCommand(AnalyticsCommand command) {
    command.execute();
    _history.add(command);
    _historyIndex = _history.length - 1;
    _redoStack.clear();
  }

  void undo() {
    if (canUndo) {
      final command = _history[_historyIndex];
      command. undo();
      _redoStack.add(command);
      _historyIndex--;
    }
  }

  void redo() {
    if (canRedo) {
      final command = _redoStack.removeLast();
      command.execute();
      _historyIndex++;
    }
  }

  bool get canUndo => _historyIndex >= 0;
  bool get canRedo => _redoStack.isNotEmpty;
}

enum ChartType { line, bar, area, pie }
enum ExportFormat { pdf, csv, excel, image }

/// ==================== ANALYTICS TAB ====================
class EmployeeAnalyticsTab extends StatefulWidget {
  final Future<AnalyticsData> analyticsFuture;
  final Future<List<Report>> reportsFuture;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;

  const EmployeeAnalyticsTab({
    super.key,
    required this.analyticsFuture,
    required this.reportsFuture,
    required this.onRefresh,
    required this.responsive,
  });

  @override
  State<EmployeeAnalyticsTab> createState() => _EmployeeAnalyticsTabState();
}

class _EmployeeAnalyticsTabState extends State<EmployeeAnalyticsTab>
    with TickerProviderStateMixin {

  final AnalyticsCommandInvoker _commandInvoker = AnalyticsCommandInvoker();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _chartController;
  late AnimationController _counterController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _rotateController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _counterAnimation;
  late Animation<double> _shimmerAnimation;

  // State
  int _selectedPeriod = 1;
  ChartType _selectedChartType = ChartType.line;
  final Map<String, bool> _visibleMetrics = {
    'tasks': true,
    'efficiency': true,
    'rating': true,
    'time': true,
  };
  bool _showComparison = true;
  bool _isExporting = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController.forward();
    _chartController. forward();
    _counterController.forward();
  }

  // Command execution methods
  void _executeChangePeriod(int newPeriod) {
    if (newPeriod == _selectedPeriod) return;
    HapticFeedback.selectionClick();
    _commandInvoker. executeCommand(
      ChangePeriodCommand(
        state: this,
        newPeriod: newPeriod,
        previousPeriod: _selectedPeriod,
      ),
    );
  }

  void _executeChangeChartType(ChartType newType) {
    if (newType == _selectedChartType) return;
    HapticFeedback.selectionClick();
    _commandInvoker.executeCommand(
      ChangeChartTypeCommand(
        state: this,
        newType: newType,
        previousType: _selectedChartType,
      ),
    );
  }

  void _executeToggleMetric(String metricKey) {
    HapticFeedback.lightImpact();
    _commandInvoker.executeCommand(
      ToggleMetricCommand(state: this, metricKey: metricKey),
    );
  }

  void _executeRefresh() {
    HapticFeedback. mediumImpact();
    _rotateController.forward(from: 0);
    _commandInvoker.executeCommand(
      RefreshDataCommand(state: this, onRefresh: widget.onRefresh),
    );
  }

  void _executeExport(ExportFormat format) {
    HapticFeedback.mediumImpact();
    _commandInvoker.executeCommand(
      ExportDataCommand(state: this, format: format),
    );
  }

  // State modification methods
  void _setPeriod(int period) {
    setState(() => _selectedPeriod = period);
    _chartController.forward(from: 0);
    _counterController.forward(from: 0);
  }

  void _setChartType(ChartType type) {
    setState(() => _selectedChartType = type);
    _chartController.forward(from: 0);
  }

  void _toggleMetric(String metricKey) {
    setState(() {
      _visibleMetrics[metricKey] = !(_visibleMetrics[metricKey] ??  true);
    });
  }

  void _exportData(ExportFormat format) async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isExporting = false);
    if (mounted) _showExportSuccessDialog(format);
  }

  void _showExportSuccessDialog(ExportFormat format) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Export Success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ExportSuccessDialog(format: format, responsive: widget.responsive);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _chartController.dispose();
    _counterController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _rotateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return FutureBuilder<AnalyticsData>(
      future: widget.analyticsFuture,
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
        return _buildContent(r, snapshot. data!);
      },
    );
  }

  Widget _buildContent(EmployeeResponsiveData r, AnalyticsData data) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => _executeRefresh(),
            color: AnalyticsDesign.primaryTeal,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(r.padding),
                    child: _buildHeader(r, data),
                  ),
                ),

                // Key Metrics
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets. symmetric(horizontal: r. padding),
                    child: _buildKeyMetrics(r, data),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Performance Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: _buildPerformanceChart(r, data),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // ==================== WEEKLY ACTIVITY CHART ====================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: _buildWeeklyActivitySection(r, data),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Task Distribution
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: _buildTaskDistribution(r, data),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Efficiency Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: _buildEfficiencySection(r, data),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Daily Comparison Chart
                if (r.showDetailedCharts)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.padding),
                      child: _buildDailyComparisonSection(r, data),
                    ),
                  ),

                if (r.showDetailedCharts)
                  SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

                // Top Locations
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: _buildTopLocations(r, data),
                  ),
                ),

                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: r.safePaddingBottom + 100),
                ),
              ],
            ),
          ),

          if (_isExporting) _buildExportingOverlay(r),
        ],
      ),
    );
  }

  // ==================== WEEKLY ACTIVITY SECTION ====================
  Widget _buildWeeklyActivitySection(EmployeeResponsiveData r, AnalyticsData data) {
    return WeeklyActivityChart(
      data: data.weeklyData,
      comparisonData: _showComparison ? _generateComparisonData(data. weeklyData) : null,
      responsive: r,
      onRefresh: _executeRefresh,
      showComparison: _showComparison,
      animated: true,
      title: r.adaptiveText(
        'Weekly Activity',
        nano: 'Wk',
        ultraMicro: 'Week',
        micro: 'Weekly',
        mini: 'Weekly',
      ),
      titleIcon: Icons.bar_chart_rounded,
      primaryColor: AnalyticsDesign.info,
      secondaryColor: AnalyticsDesign.primaryTeal,
      onBarTap: (dayIndex, value) {
        _showDayDetails(r, dayIndex, value, data);
      },
    );
  }

  List<int> _generateComparisonData(List<int> currentData) {
    return currentData.map((v) => (v * 0.85).round()). toList();
  }

  void _showDayDetails(EmployeeResponsiveData r, int dayIndex, int value, AnalyticsData data) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayName = dayIndex < days.length ?  days[dayIndex] : 'Day ${dayIndex + 1}';

    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DayDetailSheet(
        dayName: dayName,
        dayIndex: dayIndex,
        value: value,
        allData: data,
        responsive: r,
      ),
    );
  }

  // ==================== DAILY COMPARISON SECTION ====================
  Widget _buildDailyComparisonSection(EmployeeResponsiveData r, AnalyticsData data) {
    return _buildCard(
      r,
      title: r.adaptiveText('Daily Comparison', nano: 'Day', micro: 'Daily', mini: 'Daily'),
      icon: Icons.compare_arrows_rounded,
      iconColor: AnalyticsDesign.purple,
      headerActions: _buildComparisonToggle(r),
      child: Column(
        children: [
          SizedBox(height: r.microPadding),

          // Resolved vs Reported comparison
          SizedBox(
            height: r. chartHeight * 0.8,
            child: _buildDualBarChart(r, data),
          ),

          SizedBox(height: r.microPadding),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(r, 'Resolved', AnalyticsDesign.success),
              SizedBox(width: r.largePadding),
              _buildLegendItem(r, 'Reported', AnalyticsDesign.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDualBarChart(EmployeeResponsiveData r, AnalyticsData data) {
    final resolved = data.dailyResolved;
    final reported = data.dailyReported;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    final maxValue = math.max(
      resolved.isNotEmpty ? resolved. reduce(math.max) : 1,
      reported. isNotEmpty ? reported.reduce(math. max) : 1,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints. maxWidth;
        final groupWidth = availableWidth / 7;
        final barWidth = (groupWidth - r.gridSpacing * 2) / 2.5;

        return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
        final resolvedValue = index < resolved.length ?  resolved[index] : 0;
        final reportedValue = index < reported.length ? reported[index] : 0;
        final resolvedHeight = maxValue > 0 ? (resolvedValue / maxValue) : 0.0;
        final reportedHeight = maxValue > 0 ? (reportedValue / maxValue) : 0.0;
        final maxHeight = r.chartHeight * 0.6;

        return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600 + (index * 80)),
        curve: Curves.easeOutCubic,
        builder: (context, animValue, child) {
        return Column(
        mainAxisAlignment: MainAxisAlignment. end,
        children: [
        Row(
        mainAxisSize: MainAxisSize. min,
        crossAxisAlignment: CrossAxisAlignment. end,
        children: [
        // Resolved bar
        Container(
        width: barWidth,
        height: (maxHeight * resolvedHeight * animValue).clamp(4.0, maxHeight),
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [
        AnalyticsDesign.success,
        AnalyticsDesign. success. withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius. vertical(
        top: Radius.circular(r.smallBorderRadius),
        ),
        ),
        ),
        SizedBox(width: r.atomicPadding),
        // Reported bar
        Container(
        width: barWidth,
        height: (maxHeight * reportedHeight * animValue). clamp(4.0, maxHeight),
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [
        AnalyticsDesign. warning,
        AnalyticsDesign.warning.withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment. bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(
        top: Radius.circular(r. smallBorderRadius),
        ),
        ),
        ),
        ],
        ),
        SizedBox(height: r.nanoPadding),
        Text(
        days[index],
        style: GoogleFonts.inter(
        fontSize: r.captionXS,
        color: AnalyticsDesign.textSecondary,
        ),
        ),
        ],
        );
        },
        );
        }),
        );
      },
    );
  }

  Widget _buildComparisonToggle(EmployeeResponsiveData r) {
    return Row(
      mainAxisSize: MainAxisSize. min,
      children: [
        if (r.showSecondaryText)
          Text(
            'Compare',
            style: GoogleFonts. inter(
              fontSize: r.captionS,
              color: AnalyticsDesign.textSecondary,
            ),
          ),
        SizedBox(width: r.nanoPadding),
        Transform.scale(
          scale: r.responsive<double>(base: 0.8, small: 0.7, micro: 0.6),
          child: Switch(
            value: _showComparison,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() => _showComparison = value);
            },
            activeColor: AnalyticsDesign.primaryTeal,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(EmployeeResponsiveData r, AnalyticsData data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.adaptiveText('Analytics', nano: 'A', micro: 'Stats', mini: 'Analytics'),
                    style: GoogleFonts.inter(
                      fontSize: r. headingM,
                      fontWeight: FontWeight. w800,
                      color: AnalyticsDesign.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (r.showSecondaryText)
                    Text(
                      'Track your performance insights',
                      style: GoogleFonts.inter(
                        fontSize: r. captionM,
                        color: AnalyticsDesign.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                if (_commandInvoker.canUndo)
                  _buildIconButton(r, Icons.undo_rounded, () {
                    HapticFeedback.lightImpact();
                    _commandInvoker. undo();
                    setState(() {});
                  }),
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: _buildIconButton(r, Icons.refresh_rounded, _executeRefresh),
                ),
                SizedBox(width: r.nanoPadding),
                _buildExportButton(r),
              ],
            ),
          ],
        ),
        SizedBox(height: r.padding),
        _buildPeriodSelector(r),
      ],
    );
  }

  Widget _buildIconButton(EmployeeResponsiveData r, IconData icon, VoidCallback onTap) {
    return Material(
      color: AnalyticsDesign.primaryTeal. withOpacity(0.1),
      borderRadius: BorderRadius. circular(r.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius. circular(r.borderRadius),
        child: Container(
          width: r.buttonHeightSmall,
          height: r.buttonHeightSmall,
          alignment: Alignment.center,
          child: Icon(icon, size: r.iconSize(20), color: AnalyticsDesign. primaryTeal),
        ),
      ),
    );
  }

  Widget _buildExportButton(EmployeeResponsiveData r) {
    return PopupMenuButton<ExportFormat>(
      onSelected: _executeExport,
      offset: Offset(0, r.buttonHeightSmall),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(r.borderRadius)),
      itemBuilder: (context) => [
        _buildExportMenuItem(r, ExportFormat.pdf, Icons.picture_as_pdf_rounded, 'PDF'),
        _buildExportMenuItem(r, ExportFormat.csv, Icons.table_chart_rounded, 'CSV'),
        _buildExportMenuItem(r, ExportFormat.excel, Icons. grid_on_rounded, 'Excel'),
        _buildExportMenuItem(r, ExportFormat.image, Icons.image_rounded, 'Image'),
      ],
      child: Container(
        padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AnalyticsDesign.gradientColors),
          borderRadius: BorderRadius.circular(r.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AnalyticsDesign.primaryTeal.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_download_rounded, size: r. iconSize(18), color: Colors.white),
            if (r.showIconLabels) ...[
              SizedBox(width: r.nanoPadding),
              Text(
                'Export',
                style: GoogleFonts. inter(fontSize: r.captionM, fontWeight: FontWeight. w600, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ExportFormat> _buildExportMenuItem(
      EmployeeResponsiveData r, ExportFormat format, IconData icon, String label,
      ) {
    return PopupMenuItem<ExportFormat>(
      value: format,
      child: Row(
        children: [
          Icon(icon, size: r.iconSize(20), color: AnalyticsDesign.textSecondary),
          SizedBox(width: r.microPadding),
          Text(label, style: GoogleFonts.inter(fontSize: r.bodyS, color: AnalyticsDesign.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(EmployeeResponsiveData r) {
    final periods = ['This Week', 'This Month', 'This Year'];

    return Container(
      padding: EdgeInsets.all(r.nanoPadding),
      decoration: BoxDecoration(
        color: AnalyticsDesign.surfaceCard,
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final isSelected = _selectedPeriod == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => _executeChangePeriod(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets. symmetric(vertical: r.microPadding),
                decoration: BoxDecoration(
                  color: isSelected ?  Colors.white : Colors. transparent,
                  borderRadius: BorderRadius.circular(r. smallBorderRadius),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Text(
                  r.adaptiveText(
                    entry.value,
                    nano: entry.value.split(' ').last[0],
                    micro: entry.value.split(' '). last. substring(0, 1),
                    mini: entry.value. split(' ').last,
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: isSelected ? FontWeight. w700 : FontWeight. w500,
                    color: isSelected ? AnalyticsDesign.primaryTeal : AnalyticsDesign. textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== KEY METRICS ====================
  Widget _buildKeyMetrics(EmployeeResponsiveData r, AnalyticsData data) {
    final metrics = [
      _MetricData('tasks', 'Total', data.totalTasks, Icons.assignment_rounded, AnalyticsDesign.info, '+12%', true),
      _MetricData('efficiency', 'Done', data.completedTasks, Icons. check_circle_rounded, AnalyticsDesign. success, '+8%', true),
      _MetricData('rating', 'Rate', data.efficiency, Icons.speed_rounded, AnalyticsDesign.primaryTeal, '+5%', true, '%'),
      _MetricData('time', 'Time', data.avgResponseTime, Icons.timer_rounded, AnalyticsDesign. warning, '-3m', true, 'm'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.statsGridColumns,
        crossAxisSpacing: r.gridSpacing,
        mainAxisSpacing: r.gridSpacing,
        childAspectRatio: r.statsCardAspectRatio,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        final isVisible = _visibleMetrics[metric.key] ??  true;
        return _buildMetricCard(r, metric, index, isVisible);
      },
    );
  }

  Widget _buildMetricCard(EmployeeResponsiveData r, _MetricData metric, int index, bool isVisible) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: isVisible ? value : value * 0.4, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _executeToggleMetric(metric. key),
        child: Container(
          padding: EdgeInsets. all(r.microPadding),
          decoration: BoxDecoration(
            color: AnalyticsDesign.surfaceWhite,
            borderRadius: BorderRadius. circular(r.largeBorderRadius),
            boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
            border: Border.all(color: isVisible ? metric.color. withOpacity(0.15) : Colors.grey. withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment. spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets. all(r.nanoPadding),
                    decoration: BoxDecoration(
                      color: metric. color. withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Icon(metric.icon, size: r.iconSize(18), color: metric.color),
                  ),
                  if (metric.trend != null && r.showTrends)
                    Container(
                      padding: EdgeInsets. symmetric(horizontal: r. nanoPadding, vertical: r.atomicPadding),
                      decoration: BoxDecoration(
                        color: (metric.trendUp ? AnalyticsDesign.success : AnalyticsDesign.error).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(r.smallBorderRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize. min,
                        children: [
                          Icon(
                            metric.trendUp ? Icons. trending_up_rounded : Icons.trending_down_rounded,
                            size: r.iconSize(12),
                            color: metric.trendUp ? AnalyticsDesign.success : AnalyticsDesign.error,
                          ),
                          SizedBox(width: r. atomicPadding),
                          Text(
                            metric. trend! ,
                            style: GoogleFonts. inter(
                              fontSize: r.captionXS,
                              fontWeight: FontWeight.w700,
                              color: metric.trendUp ? AnalyticsDesign.success : AnalyticsDesign.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              AnimatedBuilder(
                animation: _counterAnimation,
                builder: (context, child) {
                  final displayValue = (metric.value * _counterAnimation.value). round();
                  return Text(
                    '$displayValue${metric.suffix}',
                    style: GoogleFonts.inter(
                      fontSize: r.headingM,
                      fontWeight: FontWeight.w800,
                      color: isVisible ? AnalyticsDesign.textPrimary : AnalyticsDesign.textTertiary,
                      letterSpacing: -1,
                    ),
                  );
                },
              ),
              Text(
                r.adaptiveText(metric.label, nano: metric. label[0], micro: metric.label.substring(0, math.min(4, metric.label. length))),
                style: GoogleFonts. inter(fontSize: r.captionM, color: AnalyticsDesign. textSecondary, fontWeight: FontWeight. w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PERFORMANCE CHART ====================
  Widget _buildPerformanceChart(EmployeeResponsiveData r, AnalyticsData data) {
    return _buildCard(
        r,
        title: r.adaptiveText('Performance', nano: 'P', micro: 'Perf', mini: 'Perf'),
        icon: Icons.show_chart_rounded,
        iconColor: AnalyticsDesign.primaryTeal,
        headerActions: _buildChartTypeSelector(r),
        child: Column(
            children: [
            SizedBox(height: r.padding),
        SizedBox(
          height: r. chartHeight,
          child: AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(double. infinity, r.chartHeight),
                painter: _PerformanceChartPainter(
                  progress: _chartAnimation.value,
                  data: data.weeklyData,
                  chartType: _selectedChartType,
                  color: AnalyticsDesign.primaryTeal,
                  secondaryColor: AnalyticsDesign. info,
                  showComparison: _showComparison,
                  responsive: r,
                ),
              );
            },
          ),
        ),
        SizedBox(height: r.microPadding),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            _buildLegendItem(r, 'Current', AnalyticsDesign.primaryTeal),
        if (_showComparison) ...[
    SizedBox(width: r.largePadding),
    _buildLegendItem(r, 'Previous', AnalyticsDesign.info),
    ],
    ],
    ),
    ],
    ),
    );
  }

  Widget _buildChartTypeSelector(EmployeeResponsiveData r) {
    final types = [
      (ChartType.line, Icons.show_chart_rounded),
      (ChartType.bar, Icons.bar_chart_rounded),
      (ChartType.area, Icons.area_chart_rounded),
    ];

    return Row(
      mainAxisSize: MainAxisSize. min,
      children: types.map((type) {
        final isSelected = _selectedChartType == type.$1;
        return Padding(
          padding: EdgeInsets.only(left: r.nanoPadding),
          child: Material(
            color: isSelected ? AnalyticsDesign.primaryTeal. withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius. circular(r.smallBorderRadius),
            child: InkWell(
              onTap: () => _executeChangeChartType(type.$1),
              borderRadius: BorderRadius.circular(r. smallBorderRadius),
              child: Container(
                padding: EdgeInsets.all(r.nanoPadding),
                child: Icon(
                  type.$2,
                  size: r.iconSize(18),
                  color: isSelected ? AnalyticsDesign.primaryTeal : AnalyticsDesign.textTertiary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(EmployeeResponsiveData r, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: r.dimension(12),
          height: r.dimension(12),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(r.tinyBorderRadius)),
        ),
        SizedBox(width: r.nanoPadding),
        Text(
          r.adaptiveText(label, nano: label[0], micro: label.substring(0, math.min(3, label.length))),
          style: GoogleFonts. inter(fontSize: r.captionS, color: AnalyticsDesign.textSecondary),
        ),
      ],
    );
  }

  // ==================== TASK DISTRIBUTION ====================
  Widget _buildTaskDistribution(EmployeeResponsiveData r, AnalyticsData data) {
    final items = [
      _DistributionItem('Plastic', data.plasticTasks, AnalyticsDesign.info),
      _DistributionItem('Organic', data.organicTasks, AnalyticsDesign. success),
      _DistributionItem('Electronic', data.electronicTasks, AnalyticsDesign. purple),
      _DistributionItem('Hazardous', data. hazardousTasks, AnalyticsDesign. error),
      _DistributionItem('Other', data.otherTasks, AnalyticsDesign. textSecondary),
    ];
    final total = items.fold<int>(0, (sum, item) => sum + item.count);

    return _buildCard(
      r,
      title: r.adaptiveText('Distribution', nano: 'D', micro: 'Dist', mini: 'Dist'),
      icon: Icons.pie_chart_rounded,
      iconColor: AnalyticsDesign.purple,
      child: Column(
        children: [
          SizedBox(height: r.padding),
          if (r.showCharts)
            SizedBox(
              height: r.pieChartSize,
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(r.pieChartSize, r.pieChartSize),
                    painter: _PieChartPainter(
                      progress: _chartAnimation.value,
                      items: items,
                      total: total,
                      responsive: r,
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: r. padding),
          ... items.asMap().entries.map((entry) {
            return _buildDistributionBar(r, entry.value, total, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(EmployeeResponsiveData r, _DistributionItem item, int total, int index) {
    final percentage = total > 0 ?  item.count / total : 0.0;

    return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 600 + (index * 100)),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
    return Container(
    margin: EdgeInsets. only(bottom: r.microPadding),
    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Row(
    children: [
    Container(
    width: r.dimension(10),
    height: r.dimension(10),
    decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
    ),
    SizedBox(width: r.nanoPadding),
    Text(
    r.adaptiveText(item.label, nano: item.label[0], micro: item. label.substring(0, math.min(3, item.label.length))),
    style: GoogleFonts.inter(fontSize: r. captionM, color: AnalyticsDesign.textPrimary, fontWeight: FontWeight.w500),
    ),
    ],
    ),
    Text(
    '${item.count} (${(percentage * 100). toStringAsFixed(1)}%)',
    style: GoogleFonts.inter(fontSize: r.captionS, fontWeight: FontWeight. w600, color: AnalyticsDesign.textSecondary),
    ),
    ],
    ),
    SizedBox(height: r.nanoPadding),
    ClipRRect(
    borderRadius: BorderRadius.circular(r.tinyBorderRadius),
    child: LinearProgressIndicator(
    value: percentage * value,
    backgroundColor: item.color. withOpacity(0.1),
    valueColor: AlwaysStoppedAnimation<Color>(item.color),
    minHeight: r.dimension(8),
    ),
    ),
    ],
    ),
    );
    },
    );
  }

  // ==================== EFFICIENCY SECTION ====================
  Widget _buildEfficiencySection(EmployeeResponsiveData r, AnalyticsData data) {
    return Container(
      padding: EdgeInsets.all(r.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AnalyticsDesign.gradientColors, begin: Alignment. topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: [BoxShadow(color: AnalyticsDesign.primaryTeal.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: r.effectiveWidth >= 400
          ? _buildEfficiencyHorizontal(r, data)
          : _buildEfficiencyVertical(r, data),
    );
  }

  Widget _buildEfficiencyHorizontal(EmployeeResponsiveData r, AnalyticsData data) {
    return Row(
      children: [
        Expanded(flex: 2, child: Center(child: _buildEfficiencyRing(r, data))),
        Expanded(flex: 3, child: _buildEfficiencyStats(r, data)),
      ],
    );
  }

  Widget _buildEfficiencyVertical(EmployeeResponsiveData r, AnalyticsData data) {
    return Column(
      children: [
        _buildEfficiencyRing(r, data),
        SizedBox(height: r.padding),
        _buildEfficiencyStats(r, data),
      ],
    );
  }

  Widget _buildEfficiencyRing(EmployeeResponsiveData r, AnalyticsData data) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        final progress = data.efficiency / 100 * _chartAnimation.value;
        return SizedBox(
          width: r.circularProgressSize,
          height: r.circularProgressSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: r.circularProgressSize,
                height: r.circularProgressSize,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: r.circularProgressStroke,
                  backgroundColor: Colors.white. withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white. withOpacity(0.3)),
                ),
              ),
              SizedBox(
                width: r.circularProgressSize,
                height: r. circularProgressSize,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: r. circularProgressStroke,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(data.efficiency * _chartAnimation.value). round()}%',
                    style: GoogleFonts.inter(fontSize: r.headingM, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  Text(
                    'Efficiency',
                    style: GoogleFonts.inter(fontSize: r.captionS, color: Colors.white. withOpacity(0.9)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEfficiencyStats(EmployeeResponsiveData r, AnalyticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.adaptiveText('Performance', nano: 'P', micro: 'Perf', mini: 'Perf'),
          style: GoogleFonts.inter(fontSize: r.headingXS, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        SizedBox(height: r.microPadding),
        _buildEfficiencyStatItem(r, 'Response', '${data.avgResponseTime}m', Icons.timer_rounded),
        _buildEfficiencyStatItem(r, 'Rate', '${data. completionRate.round()}%', Icons. check_circle_rounded),
        _buildEfficiencyStatItem(r, 'Rating', '${data. userRating.toStringAsFixed(1)}/5', Icons. star_rounded),
      ],
    );
  }

  Widget _buildEfficiencyStatItem(EmployeeResponsiveData r, String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets. only(bottom: r.nanoPadding),
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: r.iconSize(18)),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Text(
              r.adaptiveText(label, nano: label[0], micro: label.substring(0, math.min(3, label.length))),
              style: GoogleFonts.inter(fontSize: r.captionM, color: Colors. white. withOpacity(0.9)),
            ),
          ),
          Text(value, style: GoogleFonts.inter(fontSize: r.captionL, fontWeight: FontWeight. w700, color: Colors. white)),
        ],
      ),
    );
  }

  // ==================== TOP LOCATIONS ====================
  Widget _buildTopLocations(EmployeeResponsiveData r, AnalyticsData data) {
    return _buildCard(
      r,
      title: r.adaptiveText('Top Locations', nano: 'L', micro: 'Loc', mini: 'Locations'),
      icon: Icons.location_on_rounded,
      iconColor: AnalyticsDesign.error,
      child: Column(
        children: [
          SizedBox(height: r.microPadding),
          ... data.topLocations.asMap().entries.map((entry) {
            return _buildLocationItem(r, entry. value, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildLocationItem(EmployeeResponsiveData r, TopLocation location, int index) {
    final colors = [AnalyticsDesign.primaryTeal, AnalyticsDesign.info, AnalyticsDesign.warning, AnalyticsDesign.purple, AnalyticsDesign.pink];
    final color = colors[index % colors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves. easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets. only(bottom: r.microPadding),
        padding: EdgeInsets. all(r.microPadding),
        decoration: BoxDecoration(
          color: color. withOpacity(0.05),
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: Border.all(color: color. withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: r.dimension(28),
              height: r.dimension(28),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(r.smallBorderRadius)),
              child: Center(
                child: Text('${index + 1}', style: GoogleFonts.inter(fontSize: r.captionM, fontWeight: FontWeight. w700, color: Colors.white)),
              ),
            ),
            SizedBox(width: r.microPadding),
            Expanded(
              child: Text(
                r.adaptiveText(location.name, nano: location.name[0], micro: location.name.substring(0, math.min(8, location.name. length))),
                style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight. w600, color: AnalyticsDesign.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(r.smallBorderRadius)),
              child: Text(
                '${location.reports}',
                style: GoogleFonts. inter(fontSize: r.captionS, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildCard(
      EmployeeResponsiveData r, {
        required String title,
        required IconData icon,
        required Color iconColor,
        required Widget child,
        Widget? headerActions,
      }) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: AnalyticsDesign. surfaceWhite,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets. all(r.nanoPadding),
                decoration: BoxDecoration(color: iconColor. withOpacity(0.1), borderRadius: BorderRadius.circular(r.smallBorderRadius)),
                child: Icon(icon, size: r.iconSize(20), color: iconColor),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: r.bodyM, fontWeight: FontWeight.w700, color: AnalyticsDesign. textPrimary)),
              ),
              if (headerActions != null) headerActions,
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildExportingOverlay(EmployeeResponsiveData r) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(r.largePadding),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(r.extraLargeBorderRadius)),
          child: Column(
            mainAxisSize: MainAxisSize. min,
            children: [
              SizedBox(width: r.avatarSize, height: r.avatarSize, child: CircularProgressIndicator(color: AnalyticsDesign.primaryTeal, strokeWidth: 3)),
              SizedBox(height: r.padding),
              Text('Exporting... ', style: GoogleFonts.inter(fontSize: r.bodyM, fontWeight: FontWeight.w600, color: AnalyticsDesign.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LOADING/ERROR/EMPTY STATES ====================
  Widget _buildLoadingState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(angle: value * 2 * math.pi, child: child);
            },
            child: Container(
              width: r. avatarSize,
              height: r.avatarSize,
              decoration: BoxDecoration(
                gradient: SweepGradient(colors: [AnalyticsDesign.primaryTeal, AnalyticsDesign.primaryTeal.withOpacity(0.1), AnalyticsDesign.primaryTeal]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: r.avatarSize - 8,
                  height: r.avatarSize - 8,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.analytics_rounded, size: r. iconSize(24), color: AnalyticsDesign. primaryTeal),
                ),
              ),
            ),
          ),
          SizedBox(height: r.padding),
          Text('Loading analytics...', style: GoogleFonts.inter(fontSize: r. bodyS, color: AnalyticsDesign.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(EmployeeResponsiveData r, String error) {
    return Center(
        child: Padding(
          padding: EdgeInsets. all(r.largePadding),
          child: Column(
              mainAxisAlignment: MainAxisAlignment. center,
              children: [
          Container(
          padding: EdgeInsets. all(r.largePadding),
          decoration: BoxDecoration(color: AnalyticsDesign.error. withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.error_outline_rounded, size: r.iconSize(48), color: AnalyticsDesign. error),
        ),
        SizedBox(height: r. padding),
        Text('Failed to load', style: GoogleFonts.inter(fontSize: r.bodyM, fontWeight: FontWeight.w700, color: AnalyticsDesign. textPrimary)),
        SizedBox(height: r. microPadding),
        ElevatedButton. icon(
            onPressed: _executeRefresh,
            icon: Icon(Icons. refresh_rounded, size: r.iconSize(18)),
            label: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight. w600)),
            style: ElevatedButton.styleFrom(
                backgroundColor: AnalyticsDesign. primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets. symmetric(horizontal: r.largePadding, vertical: r.microPadding),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(r.borderRadius)),
              elevation: 0,
            ),
        ),
              ],
          ),
        ),
    );
  }

  Widget _buildEmptyState(EmployeeResponsiveData r) {
    return Center(
      child: Padding(
        padding: EdgeInsets. all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform. scale(scale: value, child: child);
              },
              child: Container(
                padding: EdgeInsets. all(r.largePadding),
                decoration: BoxDecoration(
                  color: AnalyticsDesign.primaryTeal. withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  size: r.iconSize(48),
                  color: AnalyticsDesign.primaryTeal,
                ),
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'No analytics data yet',
              style: GoogleFonts.inter(
                fontSize: r. bodyM,
                fontWeight: FontWeight.w700,
                color: AnalyticsDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              'Complete some tasks to see your insights',
              style: GoogleFonts. inter(
                fontSize: r.captionM,
                color: AnalyticsDesign.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CHART PAINTERS ====================

class _PerformanceChartPainter extends CustomPainter {
  final double progress;
  final List<int> data;
  final ChartType chartType;
  final Color color;
  final Color secondaryColor;
  final bool showComparison;
  final EmployeeResponsiveData responsive;

  _PerformanceChartPainter({
    required this.progress,
    required this.data,
    required this.chartType,
    required this.color,
    required this.secondaryColor,
    required this.showComparison,
    required this.responsive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final effectiveData = data.length > 7 ? data.sublist(0, 7) : data;
    final maxValue = effectiveData.isNotEmpty
        ? effectiveData.reduce(math.max). toDouble()
        : 1.0;

    switch (chartType) {
      case ChartType.line:
        _drawLineChart(canvas, size, effectiveData, maxValue);
        break;
      case ChartType.bar:
        _drawBarChart(canvas, size, effectiveData, maxValue);
        break;
      case ChartType.area:
        _drawAreaChart(canvas, size, effectiveData, maxValue);
        break;
      case ChartType. pie:
        break;
    }

    if (showComparison && chartType != ChartType.pie) {
      _drawComparisonLine(canvas, size, effectiveData, maxValue);
    }

    _drawGridLines(canvas, size);
  }

  void _drawLineChart(Canvas canvas, Size size, List<int> effectiveData, double maxValue) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color. withOpacity(0.3), color. withOpacity(0.05)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ). createShader(Rect. fromLTWH(0, 0, size.width, size.height));

    final stepX = size.width / (effectiveData.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < effectiveData. length; i++) {
      final x = i * stepX;
      final y = size.height - (effectiveData[i] / maxValue * size.height * 0.8 * progress);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (effectiveData[i - 1] / maxValue * size. height * 0.8 * progress);
        final cpX = (prevX + x) / 2;

        path.quadraticBezierTo(cpX, prevY, cpX, (prevY + y) / 2);
        path.quadraticBezierTo(cpX, y, x, y);

        fillPath.quadraticBezierTo(cpX, prevY, cpX, (prevY + y) / 2);
        fillPath.quadraticBezierTo(cpX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas. drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    _drawDataPoints(canvas, size, effectiveData, maxValue, color);
  }

  void _drawBarChart(Canvas canvas, Size size, List<int> effectiveData, double maxValue) {
    final barWidth = (size.width / effectiveData.length) * 0.6;
    final gap = (size.width / effectiveData.length) * 0.4;

    for (int i = 0; i < effectiveData.length; i++) {
    final x = i * (barWidth + gap) + gap / 2;
    final barHeight = (effectiveData[i] / maxValue * size. height * 0.8 * progress);
    final y = size.height - barHeight;

    final rect = RRect.fromRectAndRadius(
    Rect.fromLTWH(x, y, barWidth, barHeight),
    Radius.circular(responsive.smallBorderRadius),
    );

    final gradient = LinearGradient(
    colors: [color, color.withOpacity(0.6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    );

    final paint = Paint()
    ..shader = gradient. createShader(rect. outerRect);

    canvas.drawRRect(rect, paint);
    }
  }

  void _drawAreaChart(Canvas canvas, Size size, List<int> effectiveData, double maxValue) {
    final paint = Paint()
      ..color = color
      .. strokeWidth = 2
      ..style = PaintingStyle. stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.5), color.withOpacity(0.05)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ). createShader(Rect.fromLTWH(0, 0, size. width, size.height));

    final stepX = size.width / (effectiveData.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < effectiveData.length; i++) {
      final x = i * stepX;
      final y = size.height - (effectiveData[i] / maxValue * size.height * 0.8 * progress);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath. moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  void _drawComparisonLine(Canvas canvas, Size size, List<int> effectiveData, double maxValue) {
    final paint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final comparisonData = effectiveData. map((v) => (v * 0.85). round()).toList();
    final stepX = size.width / (comparisonData.length - 1);
    final path = Path();

    for (int i = 0; i < comparisonData.length; i++) {
      final x = i * stepX;
      final y = size.height - (comparisonData[i] / maxValue * size.height * 0.8 * progress);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final dashPath = Path();
    const dashWidth = 5.0;
    const dashSpace = 3.0;

    for (final metric in path.computeMetrics()) {
    double distance = 0;
    while (distance < metric. length) {
    final start = distance;
    final end = math.min(distance + dashWidth, metric. length);
    dashPath.addPath(metric.extractPath(start, end), Offset. zero);
    distance += dashWidth + dashSpace;
    }
    }

    canvas.drawPath(dashPath, paint);
    }

  void _drawDataPoints(Canvas canvas, Size size, List<int> effectiveData, double maxValue, Color pointColor) {
    final stepX = size.width / (effectiveData.length - 1);

    for (int i = 0; i < effectiveData. length; i++) {
      final x = i * stepX;
      final y = size.height - (effectiveData[i] / maxValue * size.height * 0.8 * progress);

      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()
          ..color = pointColor. withOpacity(0.3)
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = pointColor
          .. style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()
          ..color = Colors.white
          .. style = PaintingStyle.fill,
      );
    }
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      .. color = Colors.grey. withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PerformanceChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.chartType != chartType ||
        oldDelegate. showComparison != showComparison;
  }
}

class _PieChartPainter extends CustomPainter {
  final double progress;
  final List<_DistributionItem> items;
  final int total;
  final EmployeeResponsiveData responsive;

  _PieChartPainter({
    required this. progress,
    required this.items,
    required this.total,
    required this.responsive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty || total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size. width, size.height) / 2 - 10;
    final innerRadius = radius * 0.6;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final sweepAngle = (item.count / total) * 2 * math. pi * progress;

      final paint = Paint()
        ..color = item. color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    canvas.drawCircle(center, innerRadius, Paint().. color = Colors.white);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$total',
        style: GoogleFonts.inter(
          fontSize: responsive.headingS,
          fontWeight: FontWeight. w800,
          color: AnalyticsDesign.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center. dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ==================== DATA CLASSES ====================

class _MetricData {
  final String key;
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String?  trend;
  final bool trendUp;
  final String suffix;

  _MetricData(
      this.key,
      this. label,
      this.value,
      this.icon,
      this. color,
      this.trend,
      this.trendUp, [
        this.suffix = '',
      ]);
}

class _DistributionItem {
  final String label;
  final int count;
  final Color color;

  _DistributionItem(this.label, this.count, this. color);
}

// ==================== DIALOGS & SHEETS ====================

class _DayDetailSheet extends StatelessWidget {
  final String dayName;
  final int dayIndex;
  final int value;
  final AnalyticsData allData;
  final EmployeeResponsiveData responsive;

  const _DayDetailSheet({
    required this.dayName,
    required this.dayIndex,
    required this.value,
    required this.allData,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final weeklyData = allData.weeklyData;
    final total = weeklyData. fold<int>(0, (sum, v) => sum + v);
    final average = weeklyData.isNotEmpty ? total / weeklyData.length : 0.0;
    final isAboveAverage = value > average;
    final percentage = total > 0 ?  (value / total * 100) : 0.0;

    // Get rank
    final sorted = List<int>.from(weeklyData).. sort((a, b) => b. compareTo(a));
    final rank = sorted.indexOf(value) + 1;

    return Container(
    constraints: BoxConstraints(maxHeight: r.effectiveHeight * 0.7),
    padding: EdgeInsets.all(r.largePadding),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(r. extraLargeBorderRadius)),
    ),
    child: SingleChildScrollView(
    child: Column(
    mainAxisSize: MainAxisSize. min,
    children: [
    // Handle
    Container(
    width: r.dimension(40),
    height: r.dimension(4),
    decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(r.pillBorderRadius),
    ),
    ),
    SizedBox(height: r.padding),

    // Header
    Row(
    children: [
    Container(
    padding: EdgeInsets. all(r.microPadding),
    decoration: BoxDecoration(
    color: AnalyticsDesign.info.withOpacity(0.1),
    borderRadius: BorderRadius. circular(r.borderRadius),
    ),
    child: Icon(
    Icons.calendar_today_rounded,
    size: r.iconSize(28),
    color: AnalyticsDesign.info,
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    dayName,
    style: GoogleFonts.inter(
    fontSize: r. headingXS,
    fontWeight: FontWeight. w700,
    color: AnalyticsDesign.textPrimary,
    ),
    ),
    Row(
    children: [
    Icon(
    isAboveAverage
    ? Icons.trending_up_rounded
        : Icons.trending_down_rounded,
    size: r.iconSize(16),
    color: isAboveAverage
    ? AnalyticsDesign.success
        : AnalyticsDesign.warning,
    ),
    SizedBox(width: r.atomicPadding),
    Text(
    isAboveAverage ?  'Above average' : 'Below average',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: isAboveAverage
    ? AnalyticsDesign.success
        : AnalyticsDesign.warning,
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    Container(
    padding: EdgeInsets. symmetric(
    horizontal: r.microPadding,
    vertical: r.nanoPadding,
    ),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: AnalyticsDesign. gradientColors,
    ),
    borderRadius: BorderRadius. circular(r.borderRadius),
    ),
    child: Text(
    '$value tasks',
    style: GoogleFonts.inter(
    fontSize: r. bodyS,
    fontWeight: FontWeight. w700,
    color: Colors.white,
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: r.largePadding),

    // Stats grid
    GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    mainAxisSpacing: r.microPadding,
    crossAxisSpacing: r.microPadding,
    childAspectRatio: 2.0,
    children: [
    _buildDetailStatCard(
    r,
    'Week %',
    '${percentage.toStringAsFixed(1)}%',
    Icons.pie_chart_rounded,
    AnalyticsDesign.info,
    ),
    _buildDetailStatCard(
    r,
    'vs Average',
    '${(value - average).toStringAsFixed(1)}',
    isAboveAverage
    ? Icons.arrow_upward_rounded
        : Icons. arrow_downward_rounded,
    isAboveAverage
    ? AnalyticsDesign.success
        : AnalyticsDesign.warning,
    ),
    _buildDetailStatCard(
    r,
    'Day Rank',
    '#$rank of 7',
    Icons.leaderboard_rounded,
    AnalyticsDesign. purple,
    ),
    _buildDetailStatCard(
    r,
    'Week Total',
    '$total',
    Icons.summarize_rounded,
    AnalyticsDesign.primaryTeal,
    ),
    ],
    ),
    SizedBox(height: r.padding),

    // Comparison mini chart
    Container(
    padding: EdgeInsets. all(r.microPadding),
    decoration: BoxDecoration(
    color: AnalyticsDesign.surfaceLight,
    borderRadius: BorderRadius.circular(r.borderRadius),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment. start,
    children: [
    Text(
    'Week Overview',
    style: GoogleFonts.inter(
    fontSize: r. captionM,
    fontWeight: FontWeight. w600,
    color: AnalyticsDesign.textSecondary,
    ),
    ),
    SizedBox(height: r.microPadding),
    SizedBox(
    height: r.dimension(60),
    child: _buildMiniWeekChart(r, weeklyData, dayIndex),
    ),
    ],
    ),
    ),

    SizedBox(height: r.safePaddingBottom),
    ],
    ),
    ),
    );
  }

  Widget _buildDetailStatCard(
      EmployeeResponsiveData r,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: color. withOpacity(0.1),
        borderRadius: BorderRadius.circular(r. borderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Icon(icon, size: r. iconSize(18), color: color),
          ),
          SizedBox(width: r.nanoPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment. center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: r. bodyS,
                    fontWeight: FontWeight. w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: r. captionXS,
                    color: AnalyticsDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniWeekChart(EmployeeResponsiveData r, List<int> data, int selectedIndex) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final normalizedData = data. length >= 7 ? data.sublist(0, 7) : data;
    final maxValue = normalizedData.isNotEmpty ?  normalizedData.reduce(math.max) : 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment. spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(normalizedData.length, (index) {
        final value = normalizedData[index];
        final heightPercent = maxValue > 0 ? value / maxValue : 0.0;
        final isSelected = index == selectedIndex;
        final barHeight = 40 * heightPercent;

        return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
        Container(
        width: r.dimension(16),
        height: barHeight. clamp(4.0, 40.0),
        decoration: BoxDecoration(
        color: isSelected
        ? AnalyticsDesign.info
            : AnalyticsDesign.info.withOpacity(0.3),
        borderRadius: BorderRadius.vertical(
        top: Radius.circular(r.tinyBorderRadius),
        ),
        ),
        ),
        SizedBox(height: r.atomicPadding),
        Text(
        days[index],
        style: GoogleFonts.inter(
        fontSize: r. captionXS,
        fontWeight: isSelected ? FontWeight. w700 : FontWeight. w500,
        color: isSelected
        ? AnalyticsDesign.info
            : AnalyticsDesign.textTertiary,
        ),
        ),
        ],
        );
      }),
    );
  }
}

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
          width: math.min(r.dialogMaxWidth, r.effectiveWidth - r.padding * 2),
          padding: EdgeInsets.all(r. largePadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
            boxShadow: [
              BoxShadow(
                color: AnalyticsDesign.success.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Confetti particles
                    ... List.generate(12, (index) {
                      final angle = (index / 12) * 2 * math. pi;
                      final radius = r.dimension(50);
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 600 + (index * 50)),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(
                              math.cos(angle) * radius * value,
                              math.sin(angle) * radius * value - (value * 20),
                            ),
                            child: Opacity(
                              opacity: (1 - value). clamp(0.0, 1.0),
                              child: Container(
                                width: r.dimension(8),
                                height: r.dimension(8),
                                decoration: BoxDecoration(
                                  color: AnalyticsDesign.chartColors[index % AnalyticsDesign. chartColors.length],
                                  shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                                  borderRadius: index % 2 != 0 ? BorderRadius.circular(2) : null,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                    // Check icon
                    Container(
                      width: r.dimension(70),
                      height: r.dimension(70),
                      decoration: BoxDecoration(
                        color: AnalyticsDesign.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AnalyticsDesign. success.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: r.iconSize(36),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.padding),

              Text(
                'Export Successful!',
                style: GoogleFonts.inter(
                  fontSize: r.headingXS,
                  fontWeight: FontWeight.w700,
                  color: AnalyticsDesign.textPrimary,
                ),
              ),
              SizedBox(height: r. nanoPadding),

              Text(
                'Your analytics report has been exported as ${_getFormatName(format)}',
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  color: AnalyticsDesign.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: r.largePadding),

              // File info
              Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration: BoxDecoration(
                  color: AnalyticsDesign.surfaceLight,
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getFormatIcon(format),
                      size: r.iconSize(24),
                      color: AnalyticsDesign.primaryTeal,
                    ),
                    SizedBox(width: r.microPadding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'analytics_report. ${_getExtension(format)}',
                            style: GoogleFonts.inter(
                              fontSize: r.bodyS,
                              fontWeight: FontWeight.w600,
                              color: AnalyticsDesign.textPrimary,
                            ),
                          ),
                          Text(
                            'Saved to Downloads',
                            style: GoogleFonts.inter(
                              fontSize: r. captionS,
                              color: AnalyticsDesign.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.folder_rounded,
                      size: r.iconSize(20),
                      color: AnalyticsDesign.textTertiary,
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.padding),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AnalyticsDesign. textSecondary,
                        side: BorderSide(color: Colors.grey[300]! ),
                        padding: EdgeInsets. symmetric(vertical: r.microPadding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r. borderRadius),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.inter(fontWeight: FontWeight. w600),
                      ),
                    ),
                  ),
                  SizedBox(width: r.microPadding),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton. icon(
                      onPressed: () {
                        Navigator. pop(context);
                        // Open file logic
                      },
                      icon: Icon(Icons.open_in_new_rounded, size: r.iconSize(18)),
                      label: Text(
                        'Open File',
                        style: GoogleFonts.inter(fontWeight: FontWeight. w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AnalyticsDesign.primaryTeal,
                        foregroundColor: Colors. white,
                        padding: EdgeInsets. symmetric(vertical: r.microPadding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius. circular(r.borderRadius),
                        ),
                        elevation: 0,
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
  }

  String _getFormatName(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf: return 'PDF';
      case ExportFormat.csv: return 'CSV';
      case ExportFormat.excel: return 'Excel';
      case ExportFormat.image: return 'Image';
    }
  }

  String _getExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf: return 'pdf';
      case ExportFormat. csv: return 'csv';
      case ExportFormat.excel: return 'xlsx';
      case ExportFormat.image: return 'png';
    }
  }

  IconData _getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf: return Icons.picture_as_pdf_rounded;
      case ExportFormat.csv: return Icons.table_chart_rounded;
      case ExportFormat. excel: return Icons. grid_on_rounded;
      case ExportFormat.image: return Icons.image_rounded;
    }
  }
}