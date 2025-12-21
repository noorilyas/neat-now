import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/profile_viewmodel.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

import '../../../models/employee/profile_models.dart';

class ProfileHeaderBackground extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final Animation<double> waveAnimation;

  const ProfileHeaderBackground({
    super.key,
    required this. responsive,
    required this.waveAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return AnimatedBuilder(
      animation: waveAnimation,
      builder: (context, child) {
        return Container(
          height: r.dimension(180),
          decoration: BoxDecoration(
            gradient: ProfileDesign.headerGradient,
          ),
          child: CustomPaint(
            painter: _WaveBackgroundPainter(
              animation: waveAnimation. value,
              color: ProfileDesign.primaryTeal. withOpacity(0.1),
            ),
            size: Size(r.effectiveWidth, r.dimension(180)),
          ),
        );
      },
    );
  }
}

class _WaveBackgroundPainter extends CustomPainter {
  final double animation;
  final Color color;

  _WaveBackgroundPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.8 +
          math.sin((x / size.width * 2 * math.pi) + animation) * 15 +
          math.sin((x / size.width * 4 * math.pi) + animation * 1.5) * 8;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size. height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = color. withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.85 +
          math.sin((x / size.width * 2 * math.pi) + animation + math.pi) * 12 +
          math.sin((x / size.width * 3 * math.pi) + animation * 2) * 6;
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WaveBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class ProfileHeader extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final ProfileViewModel viewModel;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> pulseAnimation;
  final Animation<double> shimmerAnimation;

  const ProfileHeader({
    super.key,
    required this.responsive,
    required this.viewModel,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.slideAnimation,
    required this.pulseAnimation,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final tier = viewModel.tier;

    return Transform.translate(
      offset: Offset(0, -r.dimension(70)),
      child:  Padding(
        padding: EdgeInsets.symmetric(horizontal: r.padding),
        child: Column(
          children: [
            // Profile image
            FadeTransition(
              opacity:  fadeAnimation,
              child: ScaleTransition(
                scale:  scaleAnimation,
                child:  _buildProfileImage(r, tier),
              ),
            ),

            SizedBox(height: r.microPadding),

            // Name and badge
            SlideTransition(
              position:  slideAnimation,
              child: FadeTransition(
                opacity:  fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      viewModel.name,
                      style: GoogleFonts.inter(
                        fontSize: r.headingM,
                        fontWeight: FontWeight.w800,
                        color: ProfileDesign.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: r.atomicPadding),
                    Text(
                      'Employee ID: ${viewModel.employeeId}',
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: ProfileDesign.textSecondary,
                      ),
                    ),
                    SizedBox(height: r. microPadding),
                    _buildTierBadge(r, tier),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(EmployeeResponsiveData r, BadgeTier tier) {
    final size = r.dimension(110);

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: tier == BadgeTier.platinum || tier == BadgeTier.gold
              ? pulseAnimation.value
              : 1.0,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: size + 16,
            height: size + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:  tier. glowColor. withOpacity(0.4),
                  blurRadius:  25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Gradient border
          Container(
            width:  size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: tier.colors,
                begin: Alignment. topLeft,
                end: Alignment. bottomRight,
              ),
            ),
          ),

          // Profile image
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape. circle,
              color: ProfileDesign.surfacePure,
              border: Border.all(color: ProfileDesign.surfacePure, width: 3),
              boxShadow: ProfileDesign.elevatedShadow,
            ),
            child: ClipOval(
              child: viewModel.profileImage != null && viewModel.profileImage!.isNotEmpty
                  ? Image. network(
                viewModel. profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(r, size),
              )
                  : _buildAvatarPlaceholder(r, size),
            ),
          ),

          // Tier icon
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildTierIconBadge(r, tier),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(EmployeeResponsiveData r, double size) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        gradient: ProfileDesign.primaryGradient,
      ),
      child: Center(
        child: Text(
          viewModel.name.isNotEmpty ? viewModel.name[0]. toUpperCase() : '?',
          style: GoogleFonts.inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTierIconBadge(EmployeeResponsiveData r, BadgeTier tier) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: tier.colors),
            shape: BoxShape.circle,
            boxShadow: ProfileDesign.glowShadow(tier.glowColor),
          ),
          child: Stack(
            children: [
              Icon(
                tier.icon,
                size: r.iconSize(20),
                color: tier == BadgeTier.silver || tier == BadgeTier.platinum
                    ? ProfileDesign.textPrimary
                    : Colors.white,
              ),
              if (tier == BadgeTier. platinum || tier == BadgeTier. gold)
                Positioned. fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ProfileDesign.shimmerGradient(shimmerAnimation.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTierBadge(EmployeeResponsiveData r, BadgeTier tier) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.padding,
            vertical: r.microPadding,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: tier.colors),
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
            boxShadow: ProfileDesign.glowShadow(tier.glowColor),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tier.icon,
                    size: r.iconSize(16),
                    color: tier == BadgeTier. silver || tier == BadgeTier.platinum
                        ? ProfileDesign.textPrimary
                        : Colors.white,
                  ),
                  SizedBox(width: r.nanoPadding),
                  Text(
                    '${tier.name} Member',
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight.w700,
                      color: tier == BadgeTier.silver || tier == BadgeTier.platinum
                          ? ProfileDesign. textPrimary
                          :  Colors.white,
                    ),
                  ),
                ],
              ),
              if (tier == BadgeTier.platinum || tier == BadgeTier.gold)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ProfileDesign. shimmerGradient(shimmerAnimation.value),
                      borderRadius: BorderRadius.circular(r.pillBorderRadius),
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