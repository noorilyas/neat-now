import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/analytics_components/chart_painters.dart';

class PerformanceChartSection extends StatelessWidget {
  final AnalyticsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Animation<double> chartAnimation;
  final Function(ChartType) onChartTypeChanged;
  final VoidCallback onComparisonToggled;

  const PerformanceChartSection({
    super. key,
    required this.viewModel,
    required this.responsive,
    required this.chartAnimation,
    required this.onChartTypeChanged,
    required this.onComparisonToggled,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return _buildCard(
      r,
      title: r.adaptiveText(
        'Performance',
        nano: 'P',
        micro: 'Perf',
        mini: 'Perf',
      ),
      icon: Icons.show_chart_rounded,
      iconColor: AnalyticsDesign. primaryTeal,
      headerActions: _buildChartTypeSelector(r),
      child: Column(
        children: [
          SizedBox(height: r.padding),
          SizedBox(
            height: r.chartHeight,
            child: AnimatedBuilder(
              animation: chartAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(double.infinity, r.chartHeight),
                  painter: PerformanceChartPainter(
                    progress: chartAnimation.value,
                    data: viewModel.weeklyData,
                    chartType: viewModel.selectedChartType,
                    color: AnalyticsDesign. primaryTeal,
                    secondaryColor: AnalyticsDesign.info,
                    showComparison: viewModel.showComparison,
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
              if (viewModel.showComparison) ...[
                SizedBox(width: r.largePadding),
                _buildLegendItem(r, 'Previous', AnalyticsDesign. info),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeSelector(EmployeeResponsiveData r) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: viewModel.chartTypeOptions.map((option) {
        final isSelected = viewModel. selectedChartType == option. type;
        return Padding(
          padding: EdgeInsets.only(left: r.nanoPadding),
          child: Material(
            color: isSelected
                ? AnalyticsDesign.primaryTeal. withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onChartTypeChanged(option.type);
              },
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
              child: Container(
                padding:  EdgeInsets.all(r.nanoPadding),
                child: Icon(
                  option.icon,
                  size: r.iconSize(18),
                  color: isSelected
                      ? AnalyticsDesign.primaryTeal
                      : AnalyticsDesign. textTertiary,
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
          decoration: BoxDecoration(
            color: color,
            borderRadius:  BorderRadius.circular(r.tinyBorderRadius),
          ),
        ),
        SizedBox(width: r.nanoPadding),
        Text(
          r.adaptiveText(
            label,
            nano: label[0],
            micro: label. substring(0, 3),
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
                decoration: BoxDecoration(
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