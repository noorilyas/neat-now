import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/dashboard_tab_viewmodel.dart';
import 'package:neat_now/models/employee/dashboard_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/employee_dashboard_tab.dart';
import 'dart:math' as math;

class DashboardStatsSection extends StatelessWidget {
  final List<StatCardData> statCards;
  final EmployeeResponsiveData responsive;
  final Animation<double> statsAnimation;

  const DashboardStatsSection({
    super.key,
    required this. statCards,
    required this. responsive,
    required this.statsAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(r),
        SizedBox(height: r.microPadding),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: r.statsGridColumns,
            crossAxisSpacing: r.gridSpacing,
            mainAxisSpacing: r.gridSpacing,
            childAspectRatio: r.statsCardAspectRatio,
          ),
          itemCount: statCards. length,
          itemBuilder: (context, index) {
            return _buildStatCard(r, statCards[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(EmployeeResponsiveData r) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.nanoPadding),
          decoration:  BoxDecoration(
            color:  DesignSystem.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Icon(
            Icons.insights_rounded,
            size: r.iconSize(18),
            color: DesignSystem.info,
          ),
        ),
        SizedBox(width: r. microPadding),
        Expanded(
          child: Text(
            r.adaptiveText(
              'Stats Overview',
              nano: 'Stats',
              micro: 'Stats',
            ),
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w700,
              color: DesignSystem.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      EmployeeResponsiveData r,
      StatCardData item,
      int index,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child:  Opacity(opacity: value, child: child),
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
          children:  [
            // Icon and trend row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon container
                Container(
                  padding: EdgeInsets.all(r.nanoPadding),
                  decoration: BoxDecoration(
                    color: item.color. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.smallBorderRadius),
                  ),
                  child: Icon(
                    item.icon,
                    size: r.iconSize(18),
                    color: item. color,
                  ),
                ),
                // Trend indicator
                if (item.trend != null && r.showTrends)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.nanoPadding,
                      vertical:  r.atomicPadding,
                    ),
                    decoration: BoxDecoration(
                      color: (item.trendUp
                          ? DesignSystem.success
                          : DesignSystem.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.trendUp
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: r.iconSize(10),
                          color: item. trendUp
                              ? DesignSystem.success
                              : DesignSystem. error,
                        ),
                        SizedBox(width: r.atomicPadding),
                        Text(
                          item.trend!,
                          style: GoogleFonts.inter(
                            fontSize: r.captionXS,
                            fontWeight: FontWeight.w600,
                            color: item. trendUp
                                ? DesignSystem.success
                                :  DesignSystem.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Animated value
            AnimatedBuilder(
              animation: statsAnimation,
              builder: (context, child) {
                final displayValue = (item.value * statsAnimation.value).round();
                return Text(
                  '$displayValue',
                  style:  GoogleFonts.inter(
                    fontSize: r.headingM,
                    fontWeight:  FontWeight.w800,
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
                micro: item. label. substring(
                  0,
                  math.min(4, item.label.length),
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: DesignSystem.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}