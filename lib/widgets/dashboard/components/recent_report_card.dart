import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';

/// RecentReportCard - Displays a recent report item
class RecentReportCard extends StatelessWidget {
  final String title;
  final String location;
  final String status;
  final String time;
  final ResponsiveData responsive;
  final VoidCallback? onTap;

  const RecentReportCard({
    super. key,
    required this.title,
    required this.location,
    required this.status,
    required this.time,
    required this. responsive,
    this.onTap,
  });

  Color get statusColor {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.blue;
    }
  }

  String get statusText {
    switch (status) {
      case 'resolved':
        return 'Resolved';
      case 'in_progress':
        return 'In Progress';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'pending':
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.borderRadius),
            border: Border. all(color: Colors.grey. withOpacity(0.15)),
            boxShadow: responsive. showShadows
                ? [
              BoxShadow(
                color: Colors.black. withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Padding(
            padding: EdgeInsets. all(responsive.padding),
            child: Row(
                children: [
            // Status indicator
            Container(
            width: responsive. dimension(40),
            height: responsive. dimension(40),
            decoration: BoxDecoration(
              color: statusColor. withOpacity(0.1),
              borderRadius: BorderRadius.circular(responsive.borderRadius),
            ),
            child: Center(
              child: Icon(
                statusIcon,
                color: statusColor,
                size: responsive.iconSize(20),
              ),
            ),
          ),
          SizedBox(width: responsive.padding),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment. centerLeft,
                  child: Text(
                    title,
                    style: GoogleFonts. poppins(
                      fontSize: responsive.fontSize(14),
                      fontWeight: FontWeight. w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (responsive. showSecondaryText) ...[
                  SizedBox(height: responsive.nanoPadding),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: responsive.iconSize(12),
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: responsive.nanoPadding),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.poppins(
                            fontSize: responsive. fontSize(11),
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow. ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Status badge and time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
          Container(
          padding: EdgeInsets. symmetric(
          horizontal: responsive.microPadding,
            vertical: responsive.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: statusColor. withOpacity(0.1),
            borderRadius: BorderRadius.circular(responsive.borderRadius),
          ),
          child: Text(
            responsive.adaptiveText(
              statusText,
              micro: statusText.substring(0, 1),
              nano: statusText.substring(0, 3),
            ),
            style: GoogleFonts.poppins(
              fontSize: responsive.fontSize(10),
              fontWeight: FontWeight. w600,
              color: statusColor,
            ),
          ),
        ),
        if (responsive.showSecondaryText) ...[
    SizedBox(height: responsive.nanoPadding),
    Text(
    time,
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(10),
    color: Colors.grey[500],
    ),
    ),
    ],
    ],
    ),
    ],
    ),
    ),
    ),
    );
    }
}