import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class OverdueBanner extends StatelessWidget {
  final int overdueCount;
  final EmployeeResponsiveData responsive;
  final Animation<double> alertAnimation;
  final VoidCallback onViewTasks;

  const OverdueBanner({
    super.key,
    required this.overdueCount,
    required this.responsive,
    required this.alertAnimation,
    required this.onViewTasks,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return AnimatedBuilder(
      animation: alertAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: r.padding,
            vertical: r.microPadding,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade600,
                Colors.red.shade400.withOpacity(
                  0.85 + (alertAnimation.value * 0.15),
                ),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color:  Colors.red.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (r.showStatusIndicators)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin:  0.9, end: 1.15),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: child,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(r.nanoPadding),
                    decoration: BoxDecoration(
                      color: Colors.white. withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        r.smallBorderRadius,
                      ),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: r.iconSize(16),
                    ),
                  ),
                ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.showMinimalText)
                      Text(
                        r.adaptiveText(
                          'Overdue Alert! ',
                          nano: '! ',
                          ultraMicro: '!! ',
                          micro: 'Alert',
                          mini: 'Overdue! ',
                        ),
                        style: GoogleFonts.poppins(
                          fontSize:  r.captionL,
                          fontWeight: FontWeight.bold,
                          color: Colors. white,
                        ),
                      ),
                    if (r.showSecondaryText)
                      Text(
                        '$overdueCount task${overdueCount > 1 ? 's' : ''} > 2 days',
                        style: GoogleFonts.poppins(
                          fontSize: r.captionS,
                          color: Colors.white. withOpacity(0.95),
                        ),
                      ),
                  ],
                ),
              ),
              if (r.showAppBarActions)
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onViewTasks();
                    },
                    borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    child:  Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.microPadding,
                        vertical: r. nanoPadding,
                      ),
                      child: Text(
                        'View',
                        style: GoogleFonts.poppins(
                          fontSize: r.captionS,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}