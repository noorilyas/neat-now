import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';

/// SectionHeader - Reusable section header component
class SectionHeader extends StatelessWidget {
  final String title;
  final String?  micro;
  final String? nano;
  final String? mini;
  final ResponsiveData responsive;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.micro,
    this. nano,
    this.mini,
    required this.responsive,
    this.showViewAll = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            responsive.adaptiveText(title, micro: micro, nano: nano, mini: mini),
            style: GoogleFonts.poppins(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (showViewAll && responsive.showSecondaryText)
          GestureDetector(
            onTap: onViewAll,
            child: Row(
              children: [
                Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.fontSize(12),
                    fontWeight: FontWeight. w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: responsive.iconSize(18),
                  color: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
      ],
    );
  }
}