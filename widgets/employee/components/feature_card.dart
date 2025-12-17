import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// EmployeeFeatureCard - Quick action card for employee dashboard
class EmployeeFeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final EmployeeResponsiveData responsive;

  const EmployeeFeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this. color,
    required this.onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final compactTitle = responsive.adaptiveText(
      title,
      micro: title.split(' ').first,
      tiny: title.replaceAll('Management', 'Mgmt'). replaceAll('Gallery', 'Gal'),
      nano: title.split(' ').first,
    );

    return Card(
      elevation: responsive. showShadows ?  4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(responsive. borderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius. circular(responsive.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(responsive. microPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: (constraints.maxHeight * 0.35).clamp(16.0, 32.0),
                        color: Colors.white,
                      ),
                      SizedBox(height: responsive.microPadding),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          compactTitle,
                          style: GoogleFonts. poppins(
                            fontSize: responsive.fontSize(11),
                            fontWeight: FontWeight. w600,
                            color: Colors. white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}