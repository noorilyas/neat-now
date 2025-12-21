import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/design/leaderboard_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class LeaderboardHeader extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final Animation<double> rotateAnimation;
  final VoidCallback onRefresh;

  const LeaderboardHeader({
    super.key,
    required this.responsive,
    required this.rotateAnimation,
    required this. onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.adaptiveText('Leaderboard',
                    nano: 'LB', micro: 'Rank', mini: 'Leaders'),
                style: GoogleFonts.inter(
                  fontSize: r.headingM,
                  fontWeight: FontWeight.w800,
                  color: LeaderboardDesign.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (r.showSecondaryText)
                Text(
                  'Compete and climb the ranks',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    color: LeaderboardDesign.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        _LeaderboardIconButton(
          responsive: r,
          icon: Icons.refresh_rounded,
          onTap: onRefresh,
          rotateAnimation: rotateAnimation,
        ),
      ],
    );
  }
}

/// ==================== ICON BUTTON (Internal) ====================
class _LeaderboardIconButton extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final IconData icon;
  final VoidCallback onTap;
  final Animation<double>? rotateAnimation;

  const _LeaderboardIconButton({
    required this.responsive,
    required this.icon,
    required this.onTap,
    this.rotateAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    Widget button = Material(
      color: LeaderboardDesign.primaryTeal. withOpacity(0.1),
      borderRadius: BorderRadius.circular(r.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.borderRadius),
        child: Container(
          width: r.buttonHeightSmall,
          height: r. buttonHeightSmall,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: r.iconSize(20),
            color: LeaderboardDesign.primaryTeal,
          ),
        ),
      ),
    );

    if (rotateAnimation != null) {
      return AnimatedBuilder(
        animation:  rotateAnimation!,
        builder: (context, child) {
          return Transform.rotate(
            angle: rotateAnimation!.value * 2 * math.pi,
            child: child,
          );
        },
        child: button,
      );
    }

    return button;
  }
}