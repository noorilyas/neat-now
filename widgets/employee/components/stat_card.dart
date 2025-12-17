import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// EmployeeStatCard - Statistics card for employee dashboard
class EmployeeStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final EmployeeResponsiveData responsive;
  final VoidCallback?  onTap;

  const EmployeeStatCard({
    super.key,
    required this.title,
    required this. value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.responsive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final compactTitle = responsive.isMicroScreen
        ? title.split(' ').first
        : title;

    return Card(
      elevation: responsive. showShadows ?  4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius. circular(responsive.borderRadius),
        child: Padding(
          padding: EdgeInsets.all(responsive.padding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon and trend row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets. all(responsive.microPadding),
                          decoration: BoxDecoration(
                            color: color. withOpacity(0.1),
                            borderRadius: BorderRadius.circular(responsive.borderRadius),
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: responsive. iconSize(24),
                          ),
                        ),
                      ),
                      if (responsive.showTrends)
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.microPadding,
                              vertical: responsive.nanoPadding,
                            ),
                            decoration: BoxDecoration(
                              color: trend.startsWith('+')
                                  ?  Colors.green. withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize. min,
                              children: [
                                Icon(
                                  trend.startsWith('+')
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  color: trend.startsWith('+')
                                      ? Colors.green
                                      : Colors.red,
                                  size: responsive.iconSize(12),
                                ),
                                SizedBox(width: responsive.nanoPadding),
                                Text(
                                  trend,
                                  style: GoogleFonts.poppins(
                                    fontSize: responsive.fontSize(10),
                                    fontWeight: FontWeight.w600,
                                    color: trend.startsWith('+')
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: responsive.microPadding),

                  // Value
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment. centerLeft,
                    child: Text(
                      value,
                      style: GoogleFonts. poppins(
                        fontSize: responsive.fontSize(22),
                        fontWeight: FontWeight. bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: responsive.nanoPadding),

                  // Title
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment. centerLeft,
                    child: Text(
                      compactTitle,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.fontSize(11),
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}