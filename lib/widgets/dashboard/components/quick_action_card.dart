import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';

/// QuickActionCard - Reusable quick action button component
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final ResponsiveData responsive;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this. onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: responsive.dimension(60),
            height: responsive.dimension(60),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
              border: Border. all(color: color.withOpacity(0.2)),
              boxShadow: responsive.showShadows
                  ?  [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [],
            ),
            child: Center(
              child: responsive.isMicroScreen
                  ? Text(
                label. substring(0, 1),
                style: GoogleFonts.poppins(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              )
                  : Icon(
                icon,
                color: color,
                size: responsive. iconSize(28),
              ),
            ),
          ),
          SizedBox(height: responsive.microPadding),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              responsive.adaptiveText(
                label,
                micro: label. substring(0, 1),
                nano: label.substring(0, 3),
              ),
              style: GoogleFonts.poppins(
                fontSize: responsive.fontSize(12),
                fontWeight: FontWeight. w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}