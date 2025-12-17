import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

/// ==================== DESIGN CONSTANTS ====================
class WeeklyChartDesign {
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF3F4F6);
}

/// ==================== WEEKLY ACTIVITY WIDGET ====================
class WeeklyActivityChart extends StatefulWidget {
  final List<int> data;
  final List<int>? comparisonData;
  final VoidCallback?  onRefresh;
  final Function(int dayIndex, int value)? onBarTap;
  final EmployeeResponsiveData responsive;
  final bool showComparison;
  final bool animated;
  final String? title;
  final IconData? titleIcon;
  final Color? primaryColor;
  final Color? secondaryColor;

  const WeeklyActivityChart({
    super.key,
    required this.data,
    this.comparisonData,
    this.onRefresh,
    this.onBarTap,
    required this.responsive,
    this.showComparison = false,
    this.animated = true,
    this. title,
    this.titleIcon,
    this.primaryColor,
    this. secondaryColor,
  });

  @override
  State<WeeklyActivityChart> createState() => _WeeklyActivityChartState();
}

class _WeeklyActivityChartState extends State<WeeklyActivityChart>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _animation;
  int?  _selectedBarIndex;
  int? _hoveredBarIndex;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.animated ? 1200 : 0),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves. easeOutCubic,
    );

    if (widget.animated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(WeeklyActivityChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Get responsive day labels based on screen size
  List<String> _getDayLabels() {
    final r = widget.responsive;

    if (r. isNanoScreen) {
      // Single character for nano screens
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    } else if (r.isUltraMicroScreen || r.isMicroScreen) {
      // Single character
      return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    } else if (r.isMiniScreen || r.isTinyScreen) {
      // Two characters
      return ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    } else if (r.isVerySmallScreen) {
      // Three characters
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else {
      // Full names for larger screens
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    }
  }

  // Get chart layout mode based on screen size
  _ChartLayoutMode _getLayoutMode() {
    final r = widget.responsive;

    if (r.effectiveWidth < 100) {
      return _ChartLayoutMode.ultraCompact;
    } else if (r. effectiveWidth < 160) {
      return _ChartLayoutMode.compact;
    } else if (r.effectiveWidth < 280) {
      return _ChartLayoutMode.small;
    } else if (r.effectiveWidth < 400) {
      return _ChartLayoutMode.medium;
    } else if (r.effectiveWidth < 600) {
      return _ChartLayoutMode.standard;
    } else if (r.effectiveWidth < 900) {
      return _ChartLayoutMode. expanded;
    } else {
      return _ChartLayoutMode. large;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final layoutMode = _getLayoutMode();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildChartContainer(r, layoutMode);
      },
    );
  }

  Widget _buildChartContainer(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    // Determine if we should show the card wrapper
    final showCardWrapper = r.effectiveWidth >= 120;

    Widget chartContent = _buildChartContent(r, layoutMode);

    if (showCardWrapper) {
      return Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: WeeklyChartDesign.surfaceWhite,
          borderRadius: BorderRadius. circular(r.largeBorderRadius),
          boxShadow: r.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            if (r.showMinimalText) _buildHeader(r, layoutMode),
            if (r.showMinimalText) SizedBox(height: r.microPadding),

            // Chart
            chartContent,

            // Legend
            if (widget.showComparison && r.showSecondaryText)
              _buildLegend(r, layoutMode),

            // Summary stats
            if (r.showDetailedContent)
              _buildSummaryStats(r, layoutMode),
          ],
        ),
      );
    } else {
      // Ultra compact - just the chart
      return chartContent;
    }
  }

  Widget _buildHeader(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    final primaryColor = widget.primaryColor ?? WeeklyChartDesign. info;

    return Row(
      children: [
        if (r.showIcons)
          Container(
            padding: EdgeInsets. all(r.nanoPadding),
            decoration: BoxDecoration(
              color: primaryColor. withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Icon(
              widget.titleIcon ?? Icons.bar_chart_rounded,
              size: r.iconSize(layoutMode. iconSize),
              color: primaryColor,
            ),
          ),
        if (r.showIcons) SizedBox(width: r.microPadding),
        Expanded(
          child: Text(
            r.adaptiveText(
              widget. title ?? 'Weekly Activity',
              nano: 'W',
              ultraMicro: 'Wk',
              micro: 'Week',
              mini: 'Weekly',
              tiny: 'Weekly',
            ),
            style: GoogleFonts.inter(
              fontSize: r.fontSize(layoutMode.titleFontSize),
              fontWeight: FontWeight.w700,
              color: WeeklyChartDesign.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.onRefresh != null && r.showAppBarActions)
          _buildRefreshButton(r, layoutMode),
      ],
    );
  }

  Widget _buildRefreshButton(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onRefresh?. call();
          _animationController. forward(from: 0);
        },
        borderRadius: BorderRadius. circular(r.smallBorderRadius),
        child: Container(
          padding: EdgeInsets. all(r.nanoPadding),
          child: Icon(
            Icons.refresh_rounded,
            size: r.iconSize(layoutMode.iconSize),
            color: WeeklyChartDesign.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildChartContent(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    final days = _getDayLabels();
    final values = _normalizeData(widget.data);
    final maxValue = values.isNotEmpty ? values. reduce(math.max) : 1;
    final todayIndex = DateTime.now().weekday - 1;

    // Calculate chart dimensions based on layout mode
    final chartHeight = _getChartHeight(r, layoutMode);
    final barSpacing = _getBarSpacing(r, layoutMode);

    return SizedBox(
      height: chartHeight + _getLabelHeight(r, layoutMode),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final barWidth = _calculateBarWidth(availableWidth, barSpacing, layoutMode);

          return Column(
            children: [
              // Chart area
              Expanded(
                child: _buildBarsArea(
                  r,
                  layoutMode,
                  days,
                  values,
                  maxValue,
                  todayIndex,
                  barWidth,
                  barSpacing,
                ),
              ),

              // Day labels
              if (r.showMinimalText)
                _buildDayLabels(r, layoutMode, days, todayIndex, barWidth, barSpacing),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarsArea(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      List<String> days,
      List<int> values,
      int maxValue,
      int todayIndex,
      double barWidth,
      double barSpacing,
      ) {
    final primaryColor = widget. primaryColor ?? WeeklyChartDesign.info;
    final secondaryColor = widget.secondaryColor ?? WeeklyChartDesign.primaryTeal;

    return Stack(
      children: [
        // Grid lines (only on larger screens)
        if (r.showCharts && layoutMode.showGridLines)
          _buildGridLines(r, layoutMode),

        // Bars
        Row(
          mainAxisAlignment: _getMainAxisAlignment(layoutMode),
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(values.length, (index) {
            final value = values[index];
            final heightPercent = maxValue > 0 ? value / maxValue : 0.0;
            final isToday = index == todayIndex;
            final isSelected = _selectedBarIndex == index;
            final isHovered = _hoveredBarIndex == index;

            return _buildBar(
            r,
            layoutMode,
            index,
            value,
            heightPercent,
            isToday,
            isSelected,
            isHovered,
            barWidth,
            barSpacing,
            primaryColor,
            secondaryColor,
            );
          }),
        ),

        // Value tooltip
        if (_selectedBarIndex != null && r.showSecondaryText)
          _buildTooltip(r, layoutMode, values[_selectedBarIndex! ], days[_selectedBarIndex! ]),
      ],
    );
  }

  Widget _buildBar(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      int index,
      int value,
      double heightPercent,
      bool isToday,
      bool isSelected,
      bool isHovered,
      double barWidth,
      double barSpacing,
      Color primaryColor,
      Color secondaryColor,
      ) {
    final animatedHeight = heightPercent * _animation.value;
    final minBarHeight = r.dimension(layoutMode.minBarHeight);
    final maxBarHeight = _getMaxBarHeight(r, layoutMode);
    final actualHeight = (maxBarHeight * animatedHeight).clamp(minBarHeight, maxBarHeight);

    // Determine bar color
    Color barColor;
    List<Color> gradientColors;

    if (isToday) {
      barColor = primaryColor;
      gradientColors = [primaryColor, primaryColor.withOpacity(0.7)];
    } else {
      barColor = secondaryColor;
      gradientColors = [secondaryColor, secondaryColor.withOpacity(0.6)];
    }

    if (isSelected || isHovered) {
      gradientColors = gradientColors.map((c) => c.withOpacity(1.0)).toList();
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Padding(
          padding: EdgeInsets. symmetric(horizontal: barSpacing / 2),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedBarIndex = _selectedBarIndex == index ?  null : index;
              });
              widget.onBarTap?.call(index, value);
            },
            onLongPress: () {
              HapticFeedback. mediumImpact();
              _showBarDetails(r, index, value);
            },
            child: MouseRegion(
              onEnter: (_) => setState(() => _hoveredBarIndex = index),
              onExit: (_) => setState(() => _hoveredBarIndex = null),
              child: Column(
                mainAxisAlignment: MainAxisAlignment. end,
                children: [
                  // Value label (on top of bar)
                  if (layoutMode.showValueLabels && r.showMinimalText)
                    _buildValueLabel(r, layoutMode, value, isToday, animValue),

                  if (layoutMode.showValueLabels)
                    SizedBox(height: r.atomicPadding),

                  // Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: barWidth,
                    height: actualHeight * animValue,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius. vertical(
                        top: Radius.circular(_getBarBorderRadius(r, layoutMode)),
                      ),
                      boxShadow: (isToday || isSelected || isHovered)
                          ? [
                        BoxShadow(
                          color: barColor.withOpacity(0.4),
                          blurRadius: r.dimension(8),
                          offset: Offset(0, r.dimension(2)),
                        ),
                      ]
                          : null,
                    ),
                    // Inner highlight for 3D effect on larger screens
                    child: layoutMode.show3DEffect
                        ? _build3DBarEffect(r, barWidth)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildValueLabel(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      int value,
      bool isToday,
      double animValue,
      ) {
    final displayValue = (value * animValue).round();

    return Text(
      '$displayValue',
      style: GoogleFonts.inter(
        fontSize: r.fontSize(layoutMode.valueFontSize),
        fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
        color: isToday
            ? (widget.primaryColor ?? WeeklyChartDesign.info)
            : WeeklyChartDesign.textSecondary,
      ),
    );
  }

  Widget _build3DBarEffect(EmployeeResponsiveData r, double barWidth) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: barWidth * 0.3,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white. withOpacity(0.3),
              Colors. white.withOpacity(0.0),
            ],
            begin: Alignment. centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(r.smallBorderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildDayLabels(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      List<String> days,
      int todayIndex,
      double barWidth,
      double barSpacing,
      ) {
    return SizedBox(
      height: _getLabelHeight(r, layoutMode),
      child: Row(
        mainAxisAlignment: _getMainAxisAlignment(layoutMode),
        children: List.generate(days. length, (index) {
          final isToday = index == todayIndex;

          return Container(
            width: barWidth + barSpacing,
            alignment: Alignment.center,
            child: Text(
              days[index],
              style: GoogleFonts.inter(
                fontSize: r. fontSize(layoutMode. labelFontSize),
                fontWeight: isToday ? FontWeight.w700 : FontWeight. w500,
                color: isToday
                    ? (widget.primaryColor ?? WeeklyChartDesign.info)
                    : WeeklyChartDesign.textSecondary,
              ),
              textAlign: TextAlign. center,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridLines(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    return Positioned. fill(
      child: Column(
        children: List.generate(layoutMode.gridLineCount, (index) {
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: WeeklyChartDesign.surfaceLight,
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTooltip(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      int value,
      String day,
      ) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, animValue, child) {
            return Transform.scale(
              scale: animValue,
              child: Opacity(
                opacity: animValue,
                child: Container(
                  padding: EdgeInsets. symmetric(
                    horizontal: r.microPadding,
                    vertical: r.nanoPadding,
                  ),
                  decoration: BoxDecoration(
                    color: WeeklyChartDesign.textPrimary,
                    borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors. black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$day: $value tasks',
                    style: GoogleFonts.inter(
                      fontSize: r. fontSize(layoutMode. tooltipFontSize),
                      fontWeight: FontWeight. w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    final primaryColor = widget.primaryColor ?? WeeklyChartDesign. info;
    final secondaryColor = widget.secondaryColor ??  WeeklyChartDesign.primaryTeal;

    return Padding(
      padding: EdgeInsets.only(top: r. microPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(r, layoutMode, 'This Week', primaryColor),
          SizedBox(width: r.padding),
          _buildLegendItem(r, layoutMode, 'Last Week', secondaryColor),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      String label,
      Color color,
      ) {
    return Row(
      mainAxisSize: MainAxisSize. min,
      children: [
        Container(
          width: r.dimension(layoutMode.legendDotSize),
          height: r.dimension(layoutMode.legendDotSize),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius. circular(r.tinyBorderRadius),
          ),
        ),
        SizedBox(width: r.nanoPadding),
        Text(
          r.adaptiveText(
            label,
            nano: label[0],
            micro: label. split(' '). last. substring(0, 2),
            mini: label.split(' ').last,
          ),
          style: GoogleFonts. inter(
            fontSize: r.fontSize(layoutMode.legendFontSize),
            color: WeeklyChartDesign.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    final values = _normalizeData(widget.data);
    final total = values.fold<int>(0, (sum, v) => sum + v);
    final average = values.isNotEmpty ? (total / values.length).round() : 0;
    final max = values.isNotEmpty ? values. reduce(math.max) : 0;

    return Padding(
      padding: EdgeInsets. only(top: r.microPadding),
      child: Container(
        padding: EdgeInsets. all(r.microPadding),
        decoration: BoxDecoration(
          color: WeeklyChartDesign.surfaceLight,
          borderRadius: BorderRadius.circular(r. smallBorderRadius),
        ),
        child: r.effectiveWidth >= 400
            ? _buildHorizontalStats(r, layoutMode, total, average, max)
            : _buildVerticalStats(r, layoutMode, total, average, max),
      ),
    );
  }

  Widget _buildHorizontalStats(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      int total,
      int average,
      int max,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment. spaceEvenly,
      children: [
        _buildStatItem(r, layoutMode, 'Total', '$total', Icons.summarize_rounded),
        _buildStatDivider(r),
        _buildStatItem(r, layoutMode, 'Average', '$average/day', Icons.trending_flat_rounded),
        _buildStatDivider(r),
        _buildStatItem(r, layoutMode, 'Peak', '$max', Icons.trending_up_rounded),
      ],
    );
  }

  Widget _buildVerticalStats(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      int total,
      int average,
      int max,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactStatItem(r, layoutMode, 'Tot', '$total'),
        _buildCompactStatItem(r, layoutMode, 'Avg', '$average'),
        _buildCompactStatItem(r, layoutMode, 'Max', '$max'),
      ],
    );
  }

  Widget _buildStatItem(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      String label,
      String value,
      IconData icon,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: r.iconSize(layoutMode. statIconSize),
          color: WeeklyChartDesign.textSecondary,
        ),
        SizedBox(width: r. nanoPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts. inter(
                fontSize: r.fontSize(layoutMode.statValueFontSize),
                fontWeight: FontWeight.w700,
                color: WeeklyChartDesign. textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: r.fontSize(layoutMode.statLabelFontSize),
                color: WeeklyChartDesign.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactStatItem(
      EmployeeResponsiveData r,
      _ChartLayoutMode layoutMode,
      String label,
      String value,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: r.fontSize(layoutMode.statValueFontSize),
            fontWeight: FontWeight.w700,
            color: WeeklyChartDesign. textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: r.fontSize(layoutMode.statLabelFontSize),
            color: WeeklyChartDesign.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(EmployeeResponsiveData r) {
    return Container(
      width: 1,
      height: r.dimension(30),
      color: WeeklyChartDesign.textTertiary. withOpacity(0.3),
    );
  }

  void _showBarDetails(EmployeeResponsiveData r, int index, int value) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final day = index < days.length ?  days[index] : 'Day ${index + 1}';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BarDetailSheet(
        day: day,
        value: value,
        index: index,
        allValues: _normalizeData(widget.data),
        responsive: r,
        primaryColor: widget.primaryColor ?? WeeklyChartDesign. info,
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  List<int> _normalizeData(List<int> data) {
    if (data.length >= 7) return data. sublist(0, 7);
    return List.generate(7, (i) => i < data.length ? data[i] : 0);
  }

  double _getChartHeight(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    return r.dimension(layoutMode.chartHeight);
  }

  double _getLabelHeight(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    if (! r.showMinimalText) return 0;
    return r. dimension(layoutMode. labelHeight);
  }

  double _getBarSpacing(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    return r. dimension(layoutMode. barSpacing);
  }

  double _calculateBarWidth(double availableWidth, double spacing, _ChartLayoutMode layoutMode) {
    final totalSpacing = spacing * 8; // 7 bars + padding
    final availableForBars = availableWidth - totalSpacing;
    final calculatedWidth = availableForBars / 7;
    return calculatedWidth. clamp(layoutMode.minBarWidth, layoutMode.maxBarWidth);
  }

  double _getMaxBarHeight(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    return r.dimension(layoutMode.maxBarHeight);
  }

  double _getBarBorderRadius(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    return r.dimension(layoutMode.barBorderRadius);
  }

  MainAxisAlignment _getMainAxisAlignment(_ChartLayoutMode layoutMode) {
    return layoutMode.centerBars
        ? MainAxisAlignment.center
        : MainAxisAlignment.spaceEvenly;
  }
}

// ==================== LAYOUT MODE CONFIGURATION ====================

enum _ChartLayoutMode {
  ultraCompact,
  compact,
  small,
  medium,
  standard,
  expanded,
  large,
}

extension _ChartLayoutModeExtension on _ChartLayoutMode {
  // Chart dimensions
  double get chartHeight {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 40;
      case _ChartLayoutMode.compact: return 60;
      case _ChartLayoutMode. small: return 80;
      case _ChartLayoutMode. medium: return 100;
      case _ChartLayoutMode. standard: return 130;
      case _ChartLayoutMode. expanded: return 160;
      case _ChartLayoutMode. large: return 200;
    }
  }

  double get maxBarHeight {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 30;
      case _ChartLayoutMode. compact: return 45;
      case _ChartLayoutMode. small: return 60;
      case _ChartLayoutMode. medium: return 80;
      case _ChartLayoutMode. standard: return 100;
      case _ChartLayoutMode. expanded: return 130;
      case _ChartLayoutMode. large: return 160;
    }
  }

  double get minBarHeight {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 4;
      case _ChartLayoutMode. compact: return 6;
      case _ChartLayoutMode. small: return 8;
      case _ChartLayoutMode. medium: return 10;
      case _ChartLayoutMode. standard: return 12;
      case _ChartLayoutMode. expanded: return 14;
      case _ChartLayoutMode. large: return 16;
    }
  }

  double get minBarWidth {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 4;
      case _ChartLayoutMode. compact: return 6;
      case _ChartLayoutMode. small: return 10;
      case _ChartLayoutMode. medium: return 16;
      case _ChartLayoutMode. standard: return 24;
      case _ChartLayoutMode. expanded: return 32;
      case _ChartLayoutMode. large: return 40;
    }
  }

  double get maxBarWidth {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 8;
      case _ChartLayoutMode.compact: return 12;
      case _ChartLayoutMode.small: return 20;
      case _ChartLayoutMode. medium: return 32;
      case _ChartLayoutMode. standard: return 48;
      case _ChartLayoutMode. expanded: return 64;
      case _ChartLayoutMode. large: return 80;
    }
  }

  double get barSpacing {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 2;
      case _ChartLayoutMode. compact: return 3;
      case _ChartLayoutMode. small: return 4;
      case _ChartLayoutMode. medium: return 6;
      case _ChartLayoutMode. standard: return 8;
      case _ChartLayoutMode. expanded: return 12;
      case _ChartLayoutMode. large: return 16;
    }
  }

  double get barBorderRadius {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 2;
      case _ChartLayoutMode. compact: return 3;
      case _ChartLayoutMode. small: return 4;
      case _ChartLayoutMode. medium: return 5;
      case _ChartLayoutMode. standard: return 6;
      case _ChartLayoutMode. expanded: return 8;
      case _ChartLayoutMode. large: return 10;
    }
  }

  double get labelHeight {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 12;
      case _ChartLayoutMode. compact: return 14;
      case _ChartLayoutMode. small: return 16;
      case _ChartLayoutMode. medium: return 18;
      case _ChartLayoutMode. standard: return 20;
      case _ChartLayoutMode. expanded: return 24;
      case _ChartLayoutMode. large: return 28;
    }
  }

  // Font sizes
  double get titleFontSize {
    switch (this) {
      case _ChartLayoutMode. ultraCompact: return 8;
      case _ChartLayoutMode. compact: return 10;
      case _ChartLayoutMode. small: return 11;
      case _ChartLayoutMode. medium: return 12;
      case _ChartLayoutMode. standard: return 14;
      case _ChartLayoutMode. expanded: return 16;
      case _ChartLayoutMode. large: return 18;
    }
  }

  double get labelFontSize {
    switch (this) {
      case _ChartLayoutMode. ultraCompact: return 6;
      case _ChartLayoutMode. compact: return 7;
      case _ChartLayoutMode. small: return 8;
      case _ChartLayoutMode. medium: return 9;
      case _ChartLayoutMode. standard: return 10;
      case _ChartLayoutMode. expanded: return 11;
      case _ChartLayoutMode. large: return 12;
    }
  }

  double get valueFontSize {
    switch (this) {
      case _ChartLayoutMode. ultraCompact: return 6;
      case _ChartLayoutMode. compact: return 7;
      case _ChartLayoutMode. small: return 8;
      case _ChartLayoutMode. medium: return 9;
      case _ChartLayoutMode. standard: return 10;
      case _ChartLayoutMode. expanded: return 11;
      case _ChartLayoutMode. large: return 12;
    }
  }

  double get tooltipFontSize {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 8;
      case _ChartLayoutMode. compact: return 9;
      case _ChartLayoutMode. small: return 10;
      case _ChartLayoutMode. medium: return 11;
      case _ChartLayoutMode. standard: return 12;
      case _ChartLayoutMode. expanded: return 13;
      case _ChartLayoutMode. large: return 14;
    }
  }

  double get legendFontSize {
    switch (this) {
      case _ChartLayoutMode. ultraCompact: return 7;
      case _ChartLayoutMode. compact: return 8;
      case _ChartLayoutMode. small: return 9;
      case _ChartLayoutMode. medium: return 10;
      case _ChartLayoutMode. standard: return 11;
      case _ChartLayoutMode. expanded: return 12;
      case _ChartLayoutMode. large: return 13;
    }
  }

  double get legendDotSize {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 6;
      case _ChartLayoutMode. compact: return 8;
      case _ChartLayoutMode. small: return 10;
      case _ChartLayoutMode. medium: return 10;
      case _ChartLayoutMode. standard: return 12;
      case _ChartLayoutMode. expanded: return 12;
      case _ChartLayoutMode. large: return 14;
    }
  }

  double get statValueFontSize {
    switch (this) {
      case _ChartLayoutMode. ultraCompact: return 10;
      case _ChartLayoutMode. compact: return 11;
      case _ChartLayoutMode. small: return 12;
      case _ChartLayoutMode. medium: return 13;
      case _ChartLayoutMode. standard: return 14;
      case _ChartLayoutMode. expanded: return 15;
      case _ChartLayoutMode. large: return 16;
    }
  }

  double get statLabelFontSize {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 8;
      case _ChartLayoutMode. compact: return 9;
      case _ChartLayoutMode. small: return 9;
      case _ChartLayoutMode. medium: return 10;
      case _ChartLayoutMode. standard: return 11;
      case _ChartLayoutMode. expanded: return 12;
      case _ChartLayoutMode. large: return 13;
    }
  }

  double get statIconSize {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 12;
      case _ChartLayoutMode. compact: return 14;
      case _ChartLayoutMode. small: return 16;
      case _ChartLayoutMode. medium: return 18;
      case _ChartLayoutMode. standard: return 20;
      case _ChartLayoutMode. expanded: return 22;
      case _ChartLayoutMode. large: return 24;
    }
  }

  double get iconSize {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 12;
      case _ChartLayoutMode. compact: return 14;
      case _ChartLayoutMode. small: return 16;
      case _ChartLayoutMode. medium: return 18;
      case _ChartLayoutMode. standard: return 20;
      case _ChartLayoutMode. expanded: return 22;
      case _ChartLayoutMode. large: return 24;
    }
  }

  // Feature flags
  bool get showValueLabels {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return false;
      case _ChartLayoutMode. compact: return false;
      case _ChartLayoutMode. small: return false;
      case _ChartLayoutMode. medium: return true;
      case _ChartLayoutMode.standard: return true;
      case _ChartLayoutMode.expanded: return true;
      case _ChartLayoutMode.large: return true;
    }
  }

  bool get showGridLines {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return false;
      case _ChartLayoutMode.compact: return false;
      case _ChartLayoutMode.small: return false;
      case _ChartLayoutMode.medium: return false;
      case _ChartLayoutMode. standard: return true;
      case _ChartLayoutMode.expanded: return true;
      case _ChartLayoutMode.large: return true;
    }
  }

  bool get show3DEffect {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return false;
      case _ChartLayoutMode.compact: return false;
      case _ChartLayoutMode.small: return false;
      case _ChartLayoutMode.medium: return false;
      case _ChartLayoutMode. standard: return true;
      case _ChartLayoutMode.expanded: return true;
      case _ChartLayoutMode.large: return true;
    }
  }

  bool get centerBars {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return true;
      case _ChartLayoutMode. compact: return true;
      case _ChartLayoutMode.small: return false;
      case _ChartLayoutMode. medium: return false;
      case _ChartLayoutMode. standard: return false;
      case _ChartLayoutMode. expanded: return false;
      case _ChartLayoutMode. large: return false;
    }
  }

  int get gridLineCount {
    switch (this) {
      case _ChartLayoutMode.ultraCompact: return 2;
      case _ChartLayoutMode. compact: return 3;
      case _ChartLayoutMode. small: return 3;
      case _ChartLayoutMode. medium: return 4;
      case _ChartLayoutMode. standard: return 4;
      case _ChartLayoutMode. expanded: return 5;
      case _ChartLayoutMode. large: return 5;
    }
  }
}

// ==================== BAR DETAIL SHEET ====================

class _BarDetailSheet extends StatelessWidget {
  final String day;
  final int value;
  final int index;
  final List<int> allValues;
  final EmployeeResponsiveData responsive;
  final Color primaryColor;

  const _BarDetailSheet({
    required this.day,
    required this.value,
    required this.index,
    required this.allValues,
    required this.responsive,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final total = allValues.fold<int>(0, (sum, v) => sum + v);
    final percentage = total > 0 ?  (value / total * 100) : 0.0;
    final average = allValues.isNotEmpty ? total / allValues.length : 0.0;
    final isAboveAverage = value > average;

    return Container(
    padding: EdgeInsets.all(r.largePadding),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(
    top: Radius.circular(r.extraLargeBorderRadius),
    ),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    // Handle
    Container(
    width: r.dimension(40),
    height: r.dimension(4),
    decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(r. pillBorderRadius),
    ),
    ),
    SizedBox(height: r.padding),

    // Day header
    Row(
    children: [
    Container(
    padding: EdgeInsets. all(r.microPadding),
    decoration: BoxDecoration(
    color: primaryColor. withOpacity(0.1),
    borderRadius: BorderRadius. circular(r.borderRadius),
    ),
    child: Icon(
    Icons.calendar_today_rounded,
    size: r.iconSize(24),
    color: primaryColor,
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    day,
    style: GoogleFonts. inter(
    fontSize: r.headingXS,
    fontWeight: FontWeight. w700,
    color: WeeklyChartDesign.textPrimary,
    ),
    ),
    Text(
    isAboveAverage ?  'Above average' : 'Below average',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: isAboveAverage
    ? WeeklyChartDesign.success
        : WeeklyChartDesign.warning,
    ),
    ),
    ],
    ),
    ),
    Container(
    padding: EdgeInsets.symmetric(
    horizontal: r.microPadding,
    vertical: r.nanoPadding,
    ),
    decoration: BoxDecoration(
    color: primaryColor,
    borderRadius: BorderRadius.circular(r.borderRadius),
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
    Row(
    children: [
    Expanded(
    child: _buildStatCard(
    r,
    'Percentage',
    '${percentage.toStringAsFixed(1)}%',
    Icons.pie_chart_rounded,
    WeeklyChartDesign.info,
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: _buildStatCard(
    r,
    'vs Average',
    '${(value - average).toStringAsFixed(1)}',
    isAboveAverage
    ? Icons. trending_up_rounded
        : Icons.trending_down_rounded,
    isAboveAverage
    ? WeeklyChartDesign.success
        : WeeklyChartDesign.warning,
    ),
    ),
    ],
    ),
    SizedBox(height: r.microPadding),

    Row(
    children: [
    Expanded(
    child: _buildStatCard(
    r,
    'Week Total',
    '$total',
    Icons.summarize_rounded,
    WeeklyChartDesign.primaryTeal,
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: _buildStatCard(
    r,
    'Rank',
    '#${_getRank()}',
    Icons.leaderboard_rounded,
    WeeklyChartDesign.warning,
    ),
    ),
    ],
    ),

    SizedBox(height: r.safePaddingBottom),
    ],
    ),
    );
  }

  Widget _buildStatCard(
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
          Icon(icon, size: r. iconSize(20), color: color),
          SizedBox(width: r. nanoPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: r. bodyM,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: r. captionXS,
                    color: WeeklyChartDesign. textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getRank() {
    final sorted = List<int>.from(allValues).. sort((a, b) => b. compareTo(a));
    return sorted.indexOf(value) + 1;
  }
}