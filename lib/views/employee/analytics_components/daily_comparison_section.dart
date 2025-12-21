import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class DailyComparisonSection extends StatelessWidget {
  final AnalyticsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Animation<double> chartAnimation;
  final VoidCallback onComparisonToggled;

  const DailyComparisonSection({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.chartAnimation,
    required this.onComparisonToggled,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return _buildCard(
      r,
      title: r.adaptiveText(
        'Daily Comparison',
        nano:  'Day',
        micro: 'Daily',
        mini: 'Daily',
      ),
      icon: Icons.compare_arrows_rounded,
      iconColor: AnalyticsDesign.purple,
      headerActions: _buildComparisonToggle(r),
      child: Column(
        children: [
          SizedBox(height: r.microPadding),
          SizedBox(
            height: r.chartHeight * 0.8,
            child: _buildDualBarChart(r),
          ),
          SizedBox(height: r.microPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(r, 'Resolved', AnalyticsDesign.success),
              SizedBox(width: r.largePadding),
              _buildLegendItem(r, 'Reported', AnalyticsDesign. warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDualBarChart(EmployeeResponsiveData r) {
    final resolved = viewModel.dailyResolved;
    final reported = viewModel.dailyReported;
    final days = viewModel. daysOfWeek;

    final maxValue = math.max(
      resolved.isNotEmpty ? resolved.reduce(math.max) : 1,
      reported.isNotEmpty ? reported.reduce(math.max) : 1,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
        Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
        // Resolved bar
        Container(
        width: barWidth,
        height: (maxHeight * resolvedHeight * animValue)
            .clamp(4.0, maxHeight),
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [
        AnalyticsDesign.success,
        AnalyticsDesign.success.withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(
        top: Radius.circular(r.smallBorderRadius),
        ),
        ),
        ),
        SizedBox(width: r.atomicPadding),
        // Reported bar
        Container(
        width: barWidth,
        height: (maxHeight * reportedHeight * animValue)
            .clamp(4.0, maxHeight),
        decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [
        AnalyticsDesign.warning,
        AnalyticsDesign.warning.withOpacity(0.7),
        ],
        begin:  Alignment.topCenter,
        end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(
        top: Radius. circular(r.smallBorderRadius),
        ),
        ),
        ),
        ],
        ),
        SizedBox(height: r. nanoPadding),
        Text(
        days[index],
        style:  GoogleFonts.inter(
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
      mainAxisSize: MainAxisSize.min,
      children: [
        if (r.showSecondaryText)
          Text(
            'Compare',
            style: GoogleFonts.inter(
              fontSize: r.captionS,
              color: AnalyticsDesign.textSecondary,
            ),
          ),
        SizedBox(width: r.nanoPadding),
        Transform.scale(
          scale: r.responsive<double>(base: 0.8, small: 0.7, micro: 0.6),
          child: Switch(
            value: viewModel.showComparison,
            onChanged:  (value) {
              HapticFeedback.selectionClick();
              onComparisonToggled();
            },
            activeColor: AnalyticsDesign.primaryTeal,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
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
            micro: label.substring(0, 3),
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
        borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
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
                  style: GoogleFonts.inter(
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