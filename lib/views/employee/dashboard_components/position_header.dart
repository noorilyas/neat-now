import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/dashboard_tab_viewmodel.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/employee_dashboard_tab.dart';

class PositionHeader extends StatelessWidget {
  final DashboardTabViewModel viewModel;
  final EmployeeResponsiveData responsive;

  const PositionHeader({
    super.key,
    required this. viewModel,
    required this. responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return TweenAnimationBuilder<double>(
        tween: Tween(begin:  0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.9 + (value * 0.1),
            child:  Opacity(opacity: value, child: child),
          );
        },
        child: Container(
            padding:  EdgeInsets.all(r.largePadding),
            decoration:  BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  DesignSystem.primaryTeal,
                  DesignSystem.primaryTealLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
              boxShadow: DesignSystem.glowShadow(DesignSystem.primaryTeal),
            ),
            child: Column(
                children: [
                Row(
                children: [
                _buildAnimatedAvatar(r),
            SizedBox(width: r.padding),
            Expanded(child: _buildUserInfo(r)),
            if (r.showTrends) _buildRankBadge(r),
    ],
    ),
    if (r.showDetailedContent) ...[
    SizedBox(height: r.padding),
    _buildPerformanceBar(r),
    ],
    ],
    ),
    ),
    );
  }

  Widget _buildAnimatedAvatar(EmployeeResponsiveData r) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.all(r.dimension(3)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors:  [
              Colors.white,
              Colors.white.withOpacity(0.7),
            ],
            begin:  Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          width: r.welcomeAvatarSize,
          height: r.welcomeAvatarSize,
          decoration: const BoxDecoration(
            shape:  BoxShape.circle,
            color: DesignSystem.primaryTealDark,
          ),
          child: ClipOval(
            child: viewModel.profileImage != null &&
                viewModel.profileImage!.isNotEmpty
                ? Image.network(
              viewModel.profileImage!,
              fit:  BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildAvatarInitial(r),
            )
                : _buildAvatarInitial(r),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarInitial(EmployeeResponsiveData r) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignSystem.primaryTealDark,
            DesignSystem.primaryTeal,
          ],
          begin:  Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          viewModel.avatarInitial,
          style: GoogleFonts.inter(
            fontSize: r.welcomeAvatarSize * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.showSecondaryText)
          Text(
            viewModel.greeting,
            style: GoogleFonts.inter(
              fontSize: r.captionM,
              color: Colors.white. withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        SizedBox(height: r.atomicPadding),
        Text(
          r.adaptiveText(
            'Hello, ${viewModel.firstName}! ',
            nano: viewModel.firstName[0],
            micro: viewModel.firstName.length >= 4
                ? viewModel.firstName.substring(0, 4)
                : viewModel.firstName,
            mini: 'Hi, ${viewModel.firstName}',
          ),
          style: GoogleFonts.inter(
            fontSize: r.headingS,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (r.showDetailedContent) ...[
          SizedBox(height: r.microPadding),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical:  r.nanoPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white. withOpacity(0.2),
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: r. iconSize(12),
                  color: Colors. white,
                ),
                SizedBox(width: r.nanoPadding),
                Flexible(
                  child: Text(
                    viewModel.position,
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: Colors. white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRankBadge(EmployeeResponsiveData r) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves. elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets. all(r.microPadding),
        decoration:  BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.leaderboard_rounded,
              color: Colors.white,
              size: r.iconSize(20),
            ),
            SizedBox(height: r.atomicPadding),
            Text(
              '#${viewModel.rank}',
              style: GoogleFonts. inter(
                fontSize: r. bodyM,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            if (r.showSecondaryText)
              Text(
                'Rank',
                style: GoogleFonts.inter(
                  fontSize: r.captionXS,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceBar(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors. white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Text(
                viewModel.performanceData. weekLabel,
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: Colors. white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                viewModel. weeklyProgressText,
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: Colors. white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: r.nanoPadding),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: viewModel.weeklyProgress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves. easeOutCubic,
            builder: (context, value, child) {
              return Container(
                height: r.dimension(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(r.pillBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius:  8,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}