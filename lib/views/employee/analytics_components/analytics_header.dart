import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class AnalyticsHeader extends StatelessWidget {
  final AnalyticsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final AnimationController rotateAnimation;
  final VoidCallback onRefresh;
  final Function(AnalyticsPeriod) onPeriodChanged;
  final Function(ExportFormat) onExport;

  const AnalyticsHeader({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.rotateAnimation,
    required this. onRefresh,
    required this.onPeriodChanged,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Column(
      children:  [
        Row(
          children: [
            Expanded(child: _buildTitle(r)),
            Row(
              children: [
                AnimatedBuilder(
                  animation:  rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: rotateAnimation.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: _buildIconButton(
                    r,
                    Icons.refresh_rounded,
                    onRefresh,
                  ),
                ),
                SizedBox(width: r. nanoPadding),
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

  Widget _buildTitle(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.adaptiveText(
            'Analytics',
            nano: 'A',
            micro: 'Stats',
            mini: 'Analytics',
          ),
          style: GoogleFonts.inter(
            fontSize: r.headingM,
            fontWeight: FontWeight.w800,
            color: AnalyticsDesign.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        if (r.showSecondaryText)
          Text(
            'Track your performance insights',
            style: GoogleFonts.inter(
              fontSize: r.captionM,
              color: AnalyticsDesign.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _buildIconButton(
      EmployeeResponsiveData r,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Material(
      color: AnalyticsDesign. primaryTeal. withOpacity(0.1),
      borderRadius: BorderRadius.circular(r.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.borderRadius),
        child: Container(
          width: r.buttonHeightSmall,
          height: r. buttonHeightSmall,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: r.iconSize(20),
            color: AnalyticsDesign.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildExportButton(EmployeeResponsiveData r) {
    return PopupMenuButton<ExportFormat>(
      onSelected: (format) {
        HapticFeedback.mediumImpact();
        onExport(format);
      },
      offset:  Offset(0, r.buttonHeightSmall),
      shape: RoundedRectangleBorder(
        borderRadius:  BorderRadius.circular(r.borderRadius),
      ),
      itemBuilder: (context) => viewModel.exportOptions.map((option) {
        return PopupMenuItem<ExportFormat>(
          value:  option. format,
          child: Row(
            children: [
              Icon(
                option.icon,
                size: r.iconSize(20),
                color: AnalyticsDesign.textSecondary,
              ),
              SizedBox(width: r. microPadding),
              Text(
                option.label,
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  color: AnalyticsDesign.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.microPadding,
          vertical:  r.nanoPadding,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AnalyticsDesign.gradientColors,
          ),
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
            Icon(
              Icons.file_download_rounded,
              size: r.iconSize(18),
              color: Colors.white,
            ),
            if (r.showIconLabels) ...[
              SizedBox(width: r.nanoPadding),
              Text(
                'Export',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.nanoPadding),
      decoration: BoxDecoration(
        color: AnalyticsDesign.surfaceCard,
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Row(
        children: AnalyticsPeriod.values. map((period) {
          final isSelected = viewModel.selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (! isSelected) {
                  HapticFeedback.selectionClick();
                  onPeriodChanged(period);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(vertical: r.microPadding),
                decoration:  BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius:  8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child:  Text(
                  r.adaptiveText(
                    period.displayName,
                    nano: period.displayName. split(' ').last[0],
                    micro: period.displayName.split(' ').last. substring(0, 1),
                    mini: period.displayName.split(' ').last,
                  ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AnalyticsDesign.primaryTeal
                        : AnalyticsDesign.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}