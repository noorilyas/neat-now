import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/employee_dashboard_tab.dart';

class OverdueAlertCard extends StatelessWidget {
  final int overdueCount;
  final EmployeeResponsiveData responsive;
  final Animation<double> pulseAnimation;
  final VoidCallback onViewTap;

  const OverdueAlertCard({
    super.key,
    required this. overdueCount,
    required this.responsive,
    required this. pulseAnimation,
    required this. onViewTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: child,
        );
      },
      child: Container(
        padding:  EdgeInsets.all(r. padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DesignSystem.error,
              DesignSystem.error.withOpacity(0.85),
            ],
            begin:  Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:  BorderRadius.circular(r.largeBorderRadius),
          boxShadow: DesignSystem.glowShadow(DesignSystem.error),
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin:  0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: (1 - value) * 0.5,
                  child: Transform.scale(scale: value, child: child),
                );
              },
              child: Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration:  BoxDecoration(
                  color: Colors.white. withOpacity(0.2),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: r.iconSize(24),
                ),
              ),
            ),
            SizedBox(width: r.microPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.adaptiveText(
                      'Action Required! ',
                      nano: '! ',
                      micro: 'Alert! ',
                      mini: 'Action! ',
                    ),
                    style: GoogleFonts.inter(
                      fontSize: r. bodyM,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (r.showSecondaryText)
                    Text(
                      '$overdueCount task${overdueCount > 1 ? 's' :  ''} overdue',
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: Colors. white.withOpacity(0.9),
                      ),
                    ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:  onViewTap,
                borderRadius: BorderRadius.circular(r.borderRadius),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.microPadding,
                    vertical: r.nanoPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors. white,
                    borderRadius: BorderRadius.circular(r.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius:  8,
                      ),
                    ],
                  ),
                  child: Text(
                    r.adaptiveText('View', nano: '→', micro: '→'),
                    style: GoogleFonts.inter(
                      fontSize: r.captionL,
                      fontWeight: FontWeight.w700,
                      color: DesignSystem.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}