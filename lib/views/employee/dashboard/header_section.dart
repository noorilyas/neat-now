// Keep the same code, just move the file to this location
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/dashboard_tab_viewmodel.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/employee_dashboard_tab.dart';

// ...  rest of the code remains the same

Widget _buildModernSectionHeader(
    EmployeeResponsiveData r, {
      required String title,
      required IconData icon,
      required Color iconColor,
      Widget? trailing,
    }) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets. all(r.nanoPadding),
        decoration: BoxDecoration(
          color: iconColor. withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.smallBorderRadius),
        ),
        child: Icon(
          icon,
          size: r.iconSize(18),
          color: iconColor,
        ),
      ),
      SizedBox(width: r.microPadding),
      Expanded(
        child: Text(
          title,
          style: GoogleFonts. inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight. w700,
            color: DesignSystem.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      if (trailing != null) trailing,
    ],
  );
}

Widget _buildViewAllButton(EmployeeResponsiveData r, VoidCallback onTap) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius. circular(r.smallBorderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r. microPadding,
          vertical: r. nanoPadding,
        ),
        decoration: BoxDecoration(
          color: DesignSystem. primaryTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.smallBorderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              r.adaptiveText('View All', nano: '→', micro: 'All'),
              style: GoogleFonts. inter(
                fontSize: r.captionS,
                fontWeight: FontWeight. w600,
                color: DesignSystem.primaryTeal,
              ),
            ),
            SizedBox(width: r.atomicPadding),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: r.iconSize(10),
              color: DesignSystem. primaryTeal,
            ),
          ],
        ),
      ),
    ),
  );
}