import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/analytics_tab_viewmodel.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class TopLocationsSection extends StatelessWidget {
  final AnalyticsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;

  const TopLocationsSection({
    super.key,
    required this.viewModel,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return _buildCard(
      r,
      title: r.adaptiveText(
        'Top Locations',
        nano: 'L',
        micro: 'Loc',
        mini: 'Locations',
      ),
      icon: Icons.location_on_rounded,
      iconColor: AnalyticsDesign.error,
      child: Column(
        children: [
          SizedBox(height: r.microPadding),
          ...viewModel.topLocations.asMap().entries.map((entry) {
            return _buildLocationItem(r, entry.value, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
      EmployeeResponsiveData r,
      TopLocation location,
      int index,
      ) {
    final colors = AnalyticsDesign.chartColors;
    final color = colors[index % colors.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds:  400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child:  Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: r.microPadding),
        padding: EdgeInsets.all(r. microPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: Border.all(color: color. withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: r.dimension(28),
              height: r.dimension(28),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: r. captionM,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width:  r.microPadding),
            Expanded(
              child:  Text(
                r.adaptiveText(
                  location.name,
                  nano: location.name[0],
                  micro: location.name. substring(
                    0,
                    math.min(8, location.name.length),
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: r. bodyS,
                  fontWeight: FontWeight.w600,
                  color: AnalyticsDesign.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r. nanoPadding,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
              ),
              child: Text(
                '${location.reports}',
                style: GoogleFonts.inter(
                  fontSize: r.captionS,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
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