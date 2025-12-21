import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class WeeklyActivitySection extends StatefulWidget {
  final AnalyticsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Animation<double> chartAnimation;
  final Function(int, int) onBarTap;
  final VoidCallback onComparisonToggled;

  const WeeklyActivitySection({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.chartAnimation,
    required this.onBarTap,
    required this.onComparisonToggled,
  });

  @override
  State<WeeklyActivitySection> createState() => _WeeklyActivitySectionState();
}

class _WeeklyActivitySectionState extends State<WeeklyActivitySection> {
  int?  _selectedBarIndex;
  int? _hoveredBarIndex;

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final layoutMode = _getLayoutMode(r);

    return _buildCard(
      r,
      title: r.adaptiveText(
        'Weekly Activity',
        nano: 'Wk',
        ultraMicro: 'Week',
        micro: 'Weekly',
        mini: 'Weekly',
      ),
      icon: Icons.bar_chart_rounded,
      iconColor: AnalyticsDesign.info,
      headerActions: _buildComparisonToggle(r),
      child: Column(
        children: [
          SizedBox(height: r.padding),
          SizedBox(
            height: r.chartHeight * 0.8,
            child: _buildBarChart(r, layoutMode),
          ),
          SizedBox(height: r.microPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(r, 'This Week', AnalyticsDesign.info),
              if (widget.viewModel.showComparison) ...[
                SizedBox(width: r.largePadding),
                _buildLegendItem(r, 'Last Week', AnalyticsDesign.primaryTeal),
              ],
            ],
          ),
          if (r.showDetailedContent) ...[
            SizedBox(height: r.padding),
            _buildSummaryStats(r, layoutMode),
          ],
        ],
      ),
    );
  }

  _ChartLayoutMode _getLayoutMode(EmployeeResponsiveData r) {
    if (r.effectiveWidth < 100) return _ChartLayoutMode. ultraCompact;
    if (r. effectiveWidth < 160) return _ChartLayoutMode. compact;
    if (r. effectiveWidth < 280) return _ChartLayoutMode. small;
    if (r.effectiveWidth < 400) return _ChartLayoutMode.medium;
    if (r.effectiveWidth < 600) return _ChartLayoutMode. standard;
    if (r.effectiveWidth < 900) return _ChartLayoutMode.expanded;
    return _ChartLayoutMode.large;
  }

  Widget _buildBarChart(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    final data = widget.viewModel.weeklyData;
    final comparisonData = widget.viewModel.showComparison
        ? widget.viewModel.generateComparisonData(data)
        : null;
    final days = widget.viewModel. daysOfWeek;

    final maxValue = data.isNotEmpty ? data.reduce(math.max) : 1;
    final todayIndex = DateTime.now().weekday - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final currentValue = index < data.length ?  data[index] : 0;
        final compValue = comparisonData != null && index < comparisonData.length
            ? comparisonData[index]
            : 0;
        final currentHeight = maxValue > 0 ? (currentValue / maxValue) : 0.0;
        final compHeight = maxValue > 0 ? (compValue / maxValue) : 0.0;
        final maxHeight = r.chartHeight * 0.6;
        final isToday = index == todayIndex;
        final isSelected = _selectedBarIndex == index;
        final isHovered = _hoveredBarIndex == index;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin:  0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedBarIndex = _selectedBarIndex == index ? null :  index;
                });
                widget.onBarTap(index, currentValue);
              },
              onLongPress: () {
                HapticFeedback.mediumImpact();
                _showBarDetails(r, index, currentValue);
              },
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredBarIndex = index),
                onExit:  (_) => setState(() => _hoveredBarIndex = null),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Value label
                    if (layoutMode. showValueLabels && r.showMinimalText)
                      Text(
                        '${(currentValue * animValue).round()}',
                        style: GoogleFonts.inter(
                          fontSize: r.fontSize(layoutMode.valueFontSize),
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                          color: isToday
                              ? AnalyticsDesign.info
                              : AnalyticsDesign.textSecondary,
                        ),
                      ),
                    if (layoutMode.showValueLabels) SizedBox(height: r.atomicPadding),

                    // Bars
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Current week bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: r.dimension(widget.viewModel.showComparison ? 14 : 20),
                          height: (maxHeight * currentHeight * animValue)
                              .clamp(4.0, maxHeight),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AnalyticsDesign.info,
                                AnalyticsDesign.info.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(r. smallBorderRadius),
                            ),
                            boxShadow: (isToday || isSelected || isHovered)
                                ?  [
                              BoxShadow(
                                color: AnalyticsDesign. info.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                        ),
                        if (widget.viewModel.showComparison) ...[
                          SizedBox(width: r.atomicPadding),
                          // Comparison bar
                          Container(
                            width: r. dimension(14),
                            height: (maxHeight * compHeight * animValue)
                                .clamp(4.0, maxHeight),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AnalyticsDesign.primaryTeal,
                                  AnalyticsDesign.primaryTeal.withOpacity(0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(r.smallBorderRadius),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: r.nanoPadding),
                    Text(
                      days[index],
                      style:  GoogleFonts.inter(
                        fontSize: r.captionXS,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                        color: isToday
                            ? AnalyticsDesign.info
                            : AnalyticsDesign.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildComparisonToggle(EmployeeResponsiveData r) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (r.showSecondaryText)
          Text(
            'Compare',
            style: GoogleFonts.inter(
              fontSize: r.captionS,
              color: AnalyticsDesign. textSecondary,
            ),
          ),
        SizedBox(width: r.nanoPadding),
        Transform.scale(
          scale: r.responsive<double>(base: 0.8, small: 0.7, micro: 0.6),
          child: Switch(
            value: widget.viewModel.showComparison,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              // ✅ Call the parent callback to update ViewModel
              widget.onComparisonToggled();
            },
            activeColor: AnalyticsDesign.primaryTeal,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }



  Widget _buildSummaryStats(EmployeeResponsiveData r, _ChartLayoutMode layoutMode) {
    final data = widget. viewModel.weeklyData;
    final total = data.fold<int>(0, (sum, v) => sum + v);
    final average = data.isNotEmpty ? (total / data. length).round() : 0;
    final max = data.isNotEmpty ? data.reduce(math.max) : 0;

    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color:  AnalyticsDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:  [
          _buildStatItem(r, 'Total', '$total', Icons.summarize_rounded),
          _buildStatDivider(r),
          _buildStatItem(r, 'Avg', '$average/d', Icons.trending_flat_rounded),
          _buildStatDivider(r),
          _buildStatItem(r, 'Peak', '$max', Icons.trending_up_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      EmployeeResponsiveData r,
      String label,
      String value,
      IconData icon,
      ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: r.iconSize(16),
          color: AnalyticsDesign.textSecondary,
        ),
        SizedBox(width: r.nanoPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: r.captionL,
                fontWeight: FontWeight.w700,
                color: AnalyticsDesign.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts. inter(
                fontSize: r. captionXS,
                color: AnalyticsDesign.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatDivider(EmployeeResponsiveData r) {
    return Container(
      width: 1,
      height: r. dimension(30),
      color: AnalyticsDesign. textTertiary. withOpacity(0.3),
    );
  }

  void _showBarDetails(EmployeeResponsiveData r, int index, int value) {
    final dayDetails = widget.viewModel.getDayDetails(index, value);

    showModalBottomSheet(
      context:  context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:  (context) => _BarDetailSheet(
        dayDetails: dayDetails,
        responsive: r,
      ),
    );
  }

  Widget _buildLegendItem(EmployeeResponsiveData r, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: r.dimension(12),
          height: r.dimension(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(r.tinyBorderRadius),
          ),
        ),
        SizedBox(width: r.nanoPadding),
        Text(
          r.adaptiveText(
            label,
            nano: label[0],
            micro: label. substring(0, 4),
          ),
          style: GoogleFonts.inter(
            fontSize: r.captionS,
            color: AnalyticsDesign.textSecondary,
          ),
        ),
      ],
    );
  }

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
        color: AnalyticsDesign.surfaceWhite,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration:  BoxDecoration(
                  color: iconColor. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(icon, size: r.iconSize(20), color: iconColor),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts. inter(
                    fontSize: r.bodyM,
                    fontWeight: FontWeight.w700,
                    color: AnalyticsDesign.textPrimary,
                  ),
                ),
              ),
              if (headerActions != null) headerActions,
            ],
          ),
          child,
        ],
      ),
    );
  }
}

// Layout Mode Enum
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
  double get valueFontSize {
    switch (this) {
      case _ChartLayoutMode. ultraCompact:
        return 6;
      case _ChartLayoutMode.compact:
        return 7;
      case _ChartLayoutMode.small:
        return 8;
      case _ChartLayoutMode.medium:
        return 9;
      case _ChartLayoutMode.standard:
        return 10;
      case _ChartLayoutMode.expanded:
        return 11;
      case _ChartLayoutMode.large:
        return 12;
    }
  }

  bool get showValueLabels {
    switch (this) {
      case _ChartLayoutMode. ultraCompact:
      case _ChartLayoutMode.compact:
      case _ChartLayoutMode.small:
        return false;
      case _ChartLayoutMode.medium:
      case _ChartLayoutMode.standard:
      case _ChartLayoutMode.expanded:
      case _ChartLayoutMode.large:
        return true;
    }
  }
}

// Bar Detail Sheet
class _BarDetailSheet extends StatelessWidget {
  final DayDetailsData dayDetails;
  final EmployeeResponsiveData responsive;

  const _BarDetailSheet({
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
        color:  Colors.white,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
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
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
          ),
          SizedBox(height: r.padding),
          // Day header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration:  BoxDecoration(
                  color: AnalyticsDesign.info. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: r. iconSize(24),
                  color: AnalyticsDesign.info,
                ),
              ),
              SizedBox(width: r. microPadding),
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
                        color: AnalyticsDesign. textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: r.padding),
          // Stats
          _buildDetailItem(
            r,
            'Completed',
            '${dayDetails.tasksCompleted}',
            Icons.check_circle_rounded,
            AnalyticsDesign.success,
          ),
          _buildDetailItem(
            r,
            'Reported',
            '${dayDetails. tasksReported}',
            Icons.assignment_rounded,
            AnalyticsDesign.info,
          ),
          _buildDetailItem(
            r,
            'Efficiency',
            '${dayDetails. efficiency. toStringAsFixed(1)}%',
            Icons.speed_rounded,
            AnalyticsDesign.primaryTeal,
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
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r. smallBorderRadius),
            ),
            child: Icon(icon, size: r.iconSize(18), color: color),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: AnalyticsDesign. textSecondary,
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