import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/leaderboard_models.dart';
import 'package:neat_now/design/leaderboard_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class CurrentUserCard extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final LeaderboardEntry entry;
  final int rank;
  final LeaderboardTier tier;
  final Animation<double> pulseAnimation;
  final Animation<double> shimmerAnimation;

  const CurrentUserCard({
    super.key,
    required this.responsive,
    required this.entry,
    required this.rank,
    required this.tier,
    required this.pulseAnimation,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform. scale(
          scale: rank <= 3 ? pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: tier.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: tier.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _UserAvatar(
                  entry: entry,
                  tier: tier,
                  responsive: r,
                  isLarge: true,
                ),
                SizedBox(width: r.microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (r.showMinimalText)
                            Text(
                              r.adaptiveText('Your Ranking',
                                  nano: '#', micro: 'Rank', mini: 'Your Rank'),
                              style: GoogleFonts.inter(
                                fontSize: r.captionS,
                                color: Colors.white. withOpacity(0.9),
                              ),
                            ),
                          const Spacer(),
                          _TierBadge(
                            tier:  tier,
                            responsive: r,
                            isSmall: false,
                            shimmerAnimation: shimmerAnimation,
                          ),
                        ],
                      ),
                      SizedBox(height: r.atomicPadding),
                      Text(
                        entry.name,
                        style: GoogleFonts.inter(
                          fontSize: r.headingXS,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _RankDisplay(
                  rank: rank,
                  tier: tier,
                  responsive: r,
                ),
              ],
            ),
            SizedBox(height: r. microPadding),
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration:  BoxDecoration(
                color:  Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:  [
                  _StatItem(
                    value: '${entry.points}',
                    label: 'Points',
                    icon: Icons.star_rounded,
                    responsive: r,
                  ),
                  _VerticalDivider(responsive: r),
                  _StatItem(
                    value: entry.rating.toStringAsFixed(1),
                    label: 'Rating',
                    icon: Icons. thumb_up_rounded,
                    responsive: r,
                  ),
                  _VerticalDivider(responsive: r),
                  _StatItem(
                    value: '${entry.tasksCompleted}',
                    label: 'Tasks',
                    icon: Icons.check_circle_rounded,
                    responsive:  r,
                  ),
                ],
              ),
            ),
            if (r.showDetailedContent && tier != LeaderboardTier.diamond)
              _TierProgress(
                currentRating: entry.rating,
                currentTier: tier,
                responsive: r,
              ),
          ],
        ),
      ),
    );
  }
}

/// ==================== USER AVATAR (Internal) ====================
class _UserAvatar extends StatelessWidget {
  final LeaderboardEntry entry;
  final LeaderboardTier tier;
  final EmployeeResponsiveData responsive;
  final bool isLarge;

  const _UserAvatar({
    required this.entry,
    required this.tier,
    required this.responsive,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final size = isLarge ? r.welcomeAvatarSize : r. avatarSize;

    return Stack(
      children: [
        Container(
          width: size,
          height:  size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isLarge ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color:  Colors.black.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child:  entry.profileImage != null
                ? Image. network(
              entry.profileImage!,
              fit:  BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _AvatarPlaceholder(name: entry.name, size: size, responsive: r),
            )
                : _AvatarPlaceholder(name: entry.name, size: size, responsive: r),
          ),
        ),
        Positioned(
          right: 0,
          bottom:  0,
          child: Container(
            padding: EdgeInsets.all(r.atomicPadding),
            decoration: BoxDecoration(
              color: tier.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: tier.glowColor. withOpacity(0.5),
                  blurRadius:  8,
                ),
              ],
            ),
            child:  Icon(
              tier.icon,
              size: r.iconSize(isLarge ? 14 : 10),
              color: tier == LeaderboardTier.silver
                  ? LeaderboardDesign.textPrimary
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final String name;
  final double size;
  final EmployeeResponsiveData responsive;

  const _AvatarPlaceholder({
    required this.name,
    required this.size,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LeaderboardDesign.primaryTeal,
            LeaderboardDesign.primaryTealLight,
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ==================== TIER BADGE (Internal) ====================
class _TierBadge extends StatelessWidget {
  final LeaderboardTier tier;
  final EmployeeResponsiveData responsive;
  final bool isSmall;
  final Animation<double>? shimmerAnimation;

  const _TierBadge({
    required this.tier,
    required this.responsive,
    this.isSmall = true,
    this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    if (shimmerAnimation != null) {
      return AnimatedBuilder(
        animation: shimmerAnimation!,
        builder: (context, child) => _buildBadge(r),
      );
    }

    return _buildBadge(r);
  }

  Widget _buildBadge(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? r.nanoPadding : r.microPadding,
        vertical: r.atomicPadding,
      ),
      decoration: BoxDecoration(
        gradient: shimmerAnimation != null
            ? LinearGradient(
          colors:  [
            Colors.white.withOpacity(0.3),
            Colors.white. withOpacity(
                0.1 + (shimmerAnimation!.value. abs() * 0.1)),
            Colors.white.withOpacity(0.3),
          ],
          begin: Alignment(-1 + shimmerAnimation!.value, 0),
          end:  Alignment(shimmerAnimation!.value, 0),
        )
            : LinearGradient(colors: tier.gradientColors),
        borderRadius: BorderRadius.circular(r.pillBorderRadius),
        border: shimmerAnimation != null
            ? Border.all(color: Colors.white. withOpacity(0.4), width: 1)
            : null,
        boxShadow: shimmerAnimation == null
            ? [
          BoxShadow(
            color: tier.glowColor.withOpacity(0.4),
            blurRadius:  6,
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tier.icon,
            size: r.iconSize(isSmall ? 12 : 16),
            color: shimmerAnimation != null
                ? Colors.white
                : (tier == LeaderboardTier. silver
                ? LeaderboardDesign.textPrimary
                : Colors.white),
          ),
          if (! isSmall || r.showShortLabels) ...[
            SizedBox(width: r.atomicPadding),
            Text(
              r.adaptiveText(tier.name,
                  nano: tier.shortName[0], micro: tier.shortName),
              style: GoogleFonts.inter(
                fontSize: r.fontSize(isSmall ? 10 : 12),
                fontWeight: FontWeight.w700,
                color: shimmerAnimation != null
                    ? Colors. white
                    : (tier == LeaderboardTier.silver
                    ? LeaderboardDesign.textPrimary
                    : Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ==================== RANK DISPLAY (Internal) ====================
class _RankDisplay extends StatelessWidget {
  final int rank;
  final LeaderboardTier tier;
  final EmployeeResponsiveData responsive;

  const _RankDisplay({
    required this.rank,
    required this.tier,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color:  Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Column(
        children: [
          Text(
            '#$rank',
            style: GoogleFonts.inter(
              fontSize: r.headingM,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          if (r.showMinimalText)
            Text(
              'Rank',
              style: GoogleFonts.inter(
                fontSize: r.captionXS,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
        ],
      ),
    );
  }
}

/// ==================== STAT ITEM (Internal) ====================
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final EmployeeResponsiveData responsive;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (r.showIcons)
              Icon(icon, size: r.iconSize(14), color: Colors.white. withOpacity(0.9)),
            if (r.showIcons) SizedBox(width: r.atomicPadding),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (r.showMinimalText)
          Text(
            r.adaptiveText(label,
                nano: label[0],
                micro: label.substring(0, math.min(3, label.length))),
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              color: Colors. white.withOpacity(0.8),
            ),
          ),
      ],
    );
  }
}

/// ==================== VERTICAL DIVIDER (Internal) ====================
class _VerticalDivider extends StatelessWidget {
  final EmployeeResponsiveData responsive;

  const _VerticalDivider({required this.responsive});

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      width: 1,
      height: r. dimension(30),
      color: Colors.white.withOpacity(0.3),
    );
  }
}

/// ==================== TIER PROGRESS (Internal) ====================
class _TierProgress extends StatelessWidget {
  final double currentRating;
  final LeaderboardTier currentTier;
  final EmployeeResponsiveData responsive;

  const _TierProgress({
    required this.currentRating,
    required this. currentTier,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    LeaderboardTier nextTier;
    switch (currentTier) {
      case LeaderboardTier.bronze:
        nextTier = LeaderboardTier.silver;
        break;
      case LeaderboardTier.silver:
        nextTier = LeaderboardTier.gold;
        break;
      case LeaderboardTier.gold:
        nextTier = LeaderboardTier.diamond;
        break;
      default:
        return const SizedBox. shrink();
    }

    final progress = (currentRating - currentTier.minRating) /
        (nextTier.minRating - currentTier.minRating);
    final ratingNeeded =
    (nextTier.minRating - currentRating).toStringAsFixed(2);

    return Padding(
      padding: EdgeInsets.only(top: r.microPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Text(
                'Progress to ${nextTier.name}',
                style: GoogleFonts. inter(
                  fontSize: r.captionS,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                '+$ratingNeeded rating needed',
                style: GoogleFonts.inter(
                  fontSize: r.captionXS,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: r.nanoPadding),
          ClipRRect(
            borderRadius: BorderRadius.circular(r. pillBorderRadius),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress. clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor:  Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(nextTier.primaryColor),
                  minHeight: r.dimension(8),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}