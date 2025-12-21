import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/leaderboard_models.dart';
import 'package:neat_now/design/leaderboard_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class UserDetailSheet extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final LeaderboardTier tier;
  final EmployeeResponsiveData responsive;
  final bool isCurrentUser;

  const UserDetailSheet({
    super.key,
    required this.entry,
    required this.rank,
    required this.tier,
    required this.responsive,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      constraints: BoxConstraints(maxHeight: r.effectiveHeight * 0.85),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(r.extraLargeBorderRadius),
        ),
      ),
      child: SingleChildScrollView(
        child:  Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: r.microPadding),
              width: r.dimension(40),
              height: r.dimension(4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
            ),

            // Header with gradient
            _buildHeader(r),

            // Stats section
            Padding(
              padding: EdgeInsets.all(r.padding),
              child: Column(
                children: [
                  // Rank and rating row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          responsive: r,
                          label: 'Rank',
                          value: '#$rank',
                          icon: Icons.leaderboard_rounded,
                          color: LeaderboardDesign. primaryTeal,
                        ),
                      ),
                      SizedBox(width: r.microPadding),
                      Expanded(
                        child: _StatCard(
                          responsive: r,
                          label: 'Rating',
                          value: entry.rating.toStringAsFixed(2),
                          icon: Icons. star_rounded,
                          color: LeaderboardDesign.goldPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.microPadding),

                  // Points and tasks row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          responsive: r,
                          label: 'Points',
                          value: '${entry.points}',
                          icon: Icons.emoji_events_rounded,
                          color: LeaderboardDesign.purple,
                        ),
                      ),
                      SizedBox(width: r.microPadding),
                      Expanded(
                        child: _StatCard(
                          responsive: r,
                          label: 'Tasks',
                          value: '${entry.tasksCompleted}',
                          icon: Icons.check_circle_rounded,
                          color:  LeaderboardDesign.success,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.padding),

                  // Rating breakdown
                  _RatingBreakdown(responsive: r),
                  SizedBox(height: r. padding),

                  // Achievements section
                  _AchievementsSection(responsive: r),
                  SizedBox(height:  r.padding),

                  // Close button
                  SizedBox(
                    width:  double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tier.primaryColor,
                        foregroundColor:  tier == LeaderboardTier.silver
                            ? LeaderboardDesign.textPrimary
                            : Colors.white,
                        padding: EdgeInsets.symmetric(vertical: r.microPadding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r. borderRadius),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts. inter(
                          fontWeight: FontWeight.w600,
                          fontSize: r.bodyM,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: r.safePaddingBottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(EmployeeResponsiveData r) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: tier.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Avatar with effects
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: r.welcomeAvatarSize + 30,
                height: r.welcomeAvatarSize + 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tier.glowColor.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Container(
                width: r.welcomeAvatarSize,
                height: r.welcomeAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius:  15,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: entry.profileImage != null
                      ? Image.network(
                    entry. profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildAvatarPlaceholder(r),
                  )
                      :  _buildAvatarPlaceholder(r),
                ),
              ),
              // Tier badge
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(r.nanoPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: tier.glowColor. withOpacity(0.5),
                        blurRadius:  10,
                      ),
                    ],
                  ),
                  child: Icon(
                    tier.icon,
                    size: r.iconSize(24),
                    color: tier. primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),

          // Name
          Text(
            entry.name,
            style: GoogleFonts.inter(
              fontSize: r.headingS,
              fontWeight:  FontWeight.w700,
              color: tier == LeaderboardTier.silver
                  ? LeaderboardDesign.textPrimary
                  : Colors.white,
            ),
          ),
          SizedBox(height: r.nanoPadding),

          // Tier badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical:  r.nanoPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white. withOpacity(0.2),
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
              border: Border. all(color: Colors.white. withOpacity(0.4)),
            ),
            child:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  tier.icon,
                  size: r.iconSize(18),
                  color: tier == LeaderboardTier.silver
                      ? LeaderboardDesign.textPrimary
                      : Colors.white,
                ),
                SizedBox(width:  r.nanoPadding),
                Text(
                  '${tier.name} Tier',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w600,
                    color: tier == LeaderboardTier.silver
                        ? LeaderboardDesign.textPrimary
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(EmployeeResponsiveData r) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LeaderboardDesign.primaryTeal,
            LeaderboardDesign. primaryTealLight,
          ],
        ),
      ),
      child: Center(
        child: Text(
          entry.name. isNotEmpty ? entry.name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            fontSize: r.welcomeAvatarSize * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ==================== STAT CARD (Internal) ====================
class _StatCard extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.responsive,
    required this.label,
    required this. value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: color. withOpacity(0.1),
        borderRadius: BorderRadius. circular(r.borderRadius),
        border: Border. all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: r.iconSize(24), color: color),
          SizedBox(height: r. nanoPadding),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: r.headingXS,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: r.captionS,
              color: LeaderboardDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ==================== RATING BREAKDOWN (Internal) ====================
class _RatingBreakdown extends StatelessWidget {
  final EmployeeResponsiveData responsive;

  const _RatingBreakdown({required this.responsive});

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color:  LeaderboardDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Breakdown',
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              fontWeight: FontWeight.w700,
              color: LeaderboardDesign.textPrimary,
            ),
          ),
          SizedBox(height: r. microPadding),
          _RatingBar(
            responsive: r,
            label: 'Speed',
            value: 0.85,
            color: LeaderboardDesign.success,
          ),
          _RatingBar(
            responsive:  r,
            label: 'Quality',
            value: 0.92,
            color: LeaderboardDesign.info,
          ),
          _RatingBar(
            responsive: r,
            label: 'Reliability',
            value: 0.78,
            color: LeaderboardDesign.warning,
          ),
          _RatingBar(
            responsive: r,
            label: 'Communication',
            value: 0.88,
            color: LeaderboardDesign.purple,
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final String label;
  final double value;
  final Color color;

  const _RatingBar({
    required this.responsive,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Padding(
      padding: EdgeInsets.only(bottom: r. microPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: LeaderboardDesign.textSecondary,
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height:  r.atomicPadding),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration:  const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
                child: LinearProgressIndicator(
                  value: animValue,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: r.dimension(8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ==================== ACHIEVEMENTS SECTION (Internal) ====================
class _AchievementsSection extends StatelessWidget {
  final EmployeeResponsiveData responsive;

  const _AchievementsSection({required this.responsive});

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    final achievements = [
      Achievement(
        name: 'Speed Demon',
        icon: Icons.bolt_rounded,
        color: LeaderboardDesign.warning,
      ),
      Achievement(
        name: 'Perfect Score',
        icon: Icons.star_rounded,
        color: LeaderboardDesign.goldPrimary,
      ),
      Achievement(
        name: 'Team Player',
        icon: Icons.group_rounded,
        color: LeaderboardDesign.info,
      ),
      Achievement(
        name: 'Early Bird',
        icon: Icons.wb_sunny_rounded,
        color: LeaderboardDesign.success,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style:  GoogleFonts.inter(
            fontSize: r.bodyS,
            fontWeight: FontWeight. w700,
            color: LeaderboardDesign.textPrimary,
          ),
        ),
        SizedBox(height:  r.microPadding),
        Wrap(
          spacing:  r.microPadding,
          runSpacing: r.microPadding,
          children: achievements. map((achievement) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r. nanoPadding,
              ),
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
                border:  Border.all(color: achievement. color.withOpacity(0.3)),
              ),
              child:  Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    achievement.icon,
                    size: r.iconSize(16),
                    color: achievement. color,
                  ),
                  SizedBox(width: r.nanoPadding),
                  Text(
                    achievement. name,
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      fontWeight: FontWeight.w600,
                      color: achievement.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}