import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';

/// StatCard - Reusable statistics card component
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ResponsiveData responsive;
  final VoidCallback?  onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this. icon,
    required this.color,
    required this.responsive,
    this. onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(responsive. borderRadius),
          border: Border.all(color: color. withOpacity(0.2), width: 1),
          boxShadow: responsive.showShadows
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets. all(responsive.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              if (responsive.showIcons)
                Container(
                  padding: EdgeInsets. all(responsive.microPadding),
                  decoration: BoxDecoration(
                    color: color. withOpacity(0.1),
                    borderRadius: BorderRadius. circular(responsive.borderRadius),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: responsive. iconSize(20),
                  ),
                ),
              if (responsive.showIcons) SizedBox(height: responsive.microPadding),

              // Value
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight. bold,
                    color: color,
                  ),
                ),
              ),

              SizedBox(height: responsive.nanoPadding),

              // Label
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  responsive.adaptiveText(
                    label,
                    micro: label.substring(0, 1),
                    nano: label.substring(0, 3),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: responsive.fontSize(11),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign. center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}