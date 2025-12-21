import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class EfficiencySection extends StatelessWidget {
  final AnalyticsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Animation<double> chartAnimation;

  const EfficiencySection({
    super.key,
    required this.viewModel,
    required this.responsive,
    required this.chartAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.all(r.largePadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AnalyticsDesign.gradientColors,
          begin:  Alignment.topLeft,
          end: Alignment. bottomRight,
        ),
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AnalyticsDesign.primaryTeal.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: r.effectiveWidth >= 400
          ? _buildHorizontal(r)
          : _buildVertical(r),
    );
  }

  Widget _buildHorizontal(EmployeeResponsiveData r) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child:  Center(child: _buildEfficiencyRing(r)),
        ),
        Expanded(
          flex:  3,
          child: _buildEfficiencyStats(r),
        ),
      ],
    );
  }

  Widget _buildVertical(EmployeeResponsiveData r) {
    return Column(
      children: [
        _buildEfficiencyRing(r),
        SizedBox(height: r.padding),
        _buildEfficiencyStats(r),
      ],
    );
  }

  Widget _buildEfficiencyRing(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: chartAnimation,
      builder: (context, child) {
        final progress = viewModel.efficiencyPercentage / 100 * chartAnimation.value;
        return SizedBox(
          width: r.circularProgressSize,
          height: r. circularProgressSize,
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
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
              SizedBox(
                width: r.circularProgressSize,
                height: r.circularProgressSize,
                child: CircularProgressIndicator(
                  value:  progress,
                  strokeWidth:  r.circularProgressStroke,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(viewModel.efficiencyPercentage * chartAnimation.value).round()}%',
                    style:  GoogleFonts.inter(
                      fontSize: r.headingM,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Efficiency',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: Colors.white. withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEfficiencyStats(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.adaptiveText(
            'Performance',
            nano: 'P',
            micro: 'Perf',
            mini: 'Perf',
          ),
          style: GoogleFonts.inter(
            fontSize: r.headingXS,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: r.microPadding),
        _buildStatItem(
          r,
          'Response',
          '${viewModel.avgResponseTime}m',
          Icons.timer_rounded,
        ),
        _buildStatItem(
          r,
          'Rate',
          '${viewModel. completionRate}%',
          Icons.check_circle_rounded,
        ),
        _buildStatItem(
          r,
          'Rating',
          '${viewModel. userRating.toStringAsFixed(1)}/5',
          Icons.star_rounded,
        ),
      ],
    );
  }

  Widget _buildStatItem(
      EmployeeResponsiveData r,
      String label,
      String value,
      IconData icon,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: r.nanoPadding),
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color:  Colors.white. withOpacity(0.15),
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: r.iconSize(18)),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Text(
              r.adaptiveText(
                label,
                nano: label[0],
                micro: label.substring(0, 3),
              ),
              style:  GoogleFonts.inter(
                fontSize: r.captionM,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: r.captionL,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}