import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class KeyMetricsSection extends StatelessWidget {
  final AnalyticsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Animation<double> counterAnimation;
  final Function(String) onMetricTap;

  const KeyMetricsSection({
    super. key,
    required this.viewModel,
    required this.responsive,
    required this.counterAnimation,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: r.statsGridColumns,
        crossAxisSpacing: r.gridSpacing,
        mainAxisSpacing: r.gridSpacing,
        childAspectRatio: r.statsCardAspectRatio,
      ),
      itemCount: viewModel.metricCards.length,
      itemBuilder: (context, index) {
        final metric = viewModel.metricCards[index];
        final isVisible = viewModel.isMetricVisible(metric.key);
        return _buildMetricCard(r, metric, index, isVisible);
      },
    );
  }

  Widget _buildMetricCard(
      EmployeeResponsiveData r,
      MetricCardData metric,
      int index,
      bool isVisible,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: isVisible ?  value : value * 0.4,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => onMetricTap(metric. key),
        child: Container(
          padding: EdgeInsets. all(r.microPadding),
          decoration:  BoxDecoration(
            color:  AnalyticsDesign.surfaceWhite,
            borderRadius: BorderRadius.circular(r.largeBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isVisible
                  ? metric.color. withOpacity(0.15)
                  : Colors.grey. withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  Container(
                    padding: EdgeInsets.all(r.nanoPadding),
                    decoration: BoxDecoration(
                      color: metric.color. withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Icon(
                      metric.icon,
                      size: r.iconSize(18),
                      color: metric.color,
                    ),
                  ),
                  if (metric.trend != null && r.showTrends)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r. nanoPadding,
                        vertical: r.atomicPadding,
                      ),
                      decoration: BoxDecoration(
                        color: (metric.trendUp
                            ? AnalyticsDesign. success
                            : AnalyticsDesign.error)
                            .withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(r.smallBorderRadius),
                      ),
                      child:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            metric.trendUp
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: r.iconSize(12),
                            color: metric.trendUp
                                ?  AnalyticsDesign.success
                                : AnalyticsDesign.error,
                          ),
                          SizedBox(width: r.atomicPadding),
                          Text(
                            metric.trend! ,
                            style: GoogleFonts.inter(
                              fontSize: r.captionXS,
                              fontWeight: FontWeight.w700,
                              color: metric. trendUp
                                  ?  AnalyticsDesign.success
                                  : AnalyticsDesign.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              AnimatedBuilder(
                animation: counterAnimation,
                builder: (context, child) {
                  final displayValue =
                  (metric.value * counterAnimation.value).round();
                  return Text(
                    '$displayValue${metric.suffix}',
                    style: GoogleFonts.inter(
                      fontSize: r.headingM,
                      fontWeight: FontWeight.w800,
                      color: isVisible
                          ? AnalyticsDesign.textPrimary
                          : AnalyticsDesign.textTertiary,
                      letterSpacing: -1,
                    ),
                  );
                },
              ),
              Text(
                r.adaptiveText(
                  metric.label,
                  nano: metric.label[0],
                  micro: metric.label.substring(
                    0,
                    math.min(4, metric.label.length),
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: AnalyticsDesign. textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}