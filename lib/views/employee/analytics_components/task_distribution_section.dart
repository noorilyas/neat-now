import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/analytics_components/chart_painters.dart';
import 'dart:math' as math;

class TaskDistributionSection extends StatelessWidget {
  final AnalyticsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Animation<double> chartAnimation;

  const TaskDistributionSection({
    super.key,
    required this.viewModel,
    required this.responsive,
    required this.chartAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final items = viewModel.distributionItems;
    final total = viewModel.totalDistributionCount;

    return _buildCard(
      r,
      title:  r.adaptiveText(
        'Distribution',
        nano: 'D',
        micro: 'Dist',
        mini: 'Dist',
      ),
      icon: Icons.pie_chart_rounded,
      iconColor: AnalyticsDesign.purple,
      child: Column(
        children: [
          SizedBox(height: r.padding),
          if (r.showCharts)
            SizedBox(
              height: r.pieChartSize,
              child: AnimatedBuilder(
                animation: chartAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(r.pieChartSize, r.pieChartSize),
                    painter: PieChartPainter(
                      progress: chartAnimation.value,
                      items: items,
                      total:  total,
                      responsive: r,
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: r.padding),
          ...items.asMap().entries.map((entry) {
            return _buildDistributionBar(r, entry.value, total, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildDistributionBar(
      EmployeeResponsiveData r,
      DistributionItem item,
      int total,
      int index,
      ) {
    final percentage = item.getPercentage(total);

    return TweenAnimationBuilder<double>(
      tween:  Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves. easeOutCubic,
      builder: (context, value, child) {
        return Container(
          margin: EdgeInsets.only(bottom: r.microPadding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Row(
                    children: [
                      Container(
                        width: r.dimension(10),
                        height: r. dimension(10),
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: r.nanoPadding),
                      Text(
                        r.adaptiveText(
                          item.label,
                          nano: item.label[0],
                          micro: item.label. substring(
                            0,
                            math.min(3, item.label.length),
                          ),
                        ),
                        style:  GoogleFonts.inter(
                          fontSize: r.captionM,
                          color: AnalyticsDesign.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${item.count} (${(percentage * 100).toStringAsFixed(1)}%)',
                    style:  GoogleFonts.inter(
                      fontSize: r.captionS,
                      fontWeight: FontWeight.w600,
                      color: AnalyticsDesign.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.nanoPadding),
              ClipRRect(
                borderRadius: BorderRadius.circular(r. tinyBorderRadius),
                child: LinearProgressIndicator(
                  value:  percentage * value,
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

  Widget _buildCard(
      EmployeeResponsiveData r, {
        required String title,
        required IconData icon,
        required Color iconColor,
        required Widget child,
      }) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: AnalyticsDesign. surfaceWhite,
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
                decoration: BoxDecoration(
                  color:  iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r. smallBorderRadius),
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
            ],
          ),
          child,
        ],
      ),
    );
  }
}