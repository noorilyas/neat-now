import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/leaderboard_models.dart';
import 'package:neat_now/design/leaderboard_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class PodiumSection extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final List<LeaderboardEntry> topThree;
  final Animation<double> podiumAnimation;
  final Animation<double> shimmerAnimation;
  final Animation<double> pulseAnimation;

  const PodiumSection({
    super.key,
    required this. responsive,
    required this.topThree,
    required this. podiumAnimation,
    required this.shimmerAnimation,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFBEB),
            const Color(0xFFFEF3C7),
          ],
          begin: Alignment.topCenter,
          end: Alignment. bottomCenter,
        ),
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: LeaderboardDesign.goldPrimary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: r.iconSize(24),
                color: LeaderboardDesign.goldPrimary,
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                r.adaptiveText('Top Performers',
                    nano: 'Top', micro: 'Top 3', mini: 'Top 3'),
                style: GoogleFonts. inter(
                  fontSize: r.bodyM,
                  fontWeight: FontWeight.w700,
                  color: LeaderboardDesign. textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height:  r.padding),
          _PodiumDisplay(
            responsive: r,
            topThree: topThree,
            podiumAnimation: podiumAnimation,
            shimmerAnimation: shimmerAnimation,
            pulseAnimation: pulseAnimation,
          ),
        ],
      ),
    );
  }
}

/// ==================== PODIUM DISPLAY (Internal) ====================
class _PodiumDisplay extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final List<LeaderboardEntry> topThree;
  final Animation<double> podiumAnimation;
  final Animation<double> shimmerAnimation;
  final Animation<double> pulseAnimation;

  const _PodiumDisplay({
    required this.responsive,
    required this.topThree,
    required this.podiumAnimation,
    required this.shimmerAnimation,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final displayOrder = [1, 0, 2]; // Silver, Gold, Bronze
    final heights = [r.dimension(100), r.dimension(130), r.dimension(80)];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: displayOrder.map((rankIndex) {
        if (rankIndex >= topThree.length) return const SizedBox.shrink();

        final entry = topThree[rankIndex];
        final tier = LeaderboardTierExtension.fromRating(entry.rating);
        final height = heights[rankIndex];
        final isFirst = rankIndex == 0;

        return Expanded(
          child: AnimatedBuilder(
            animation: podiumAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - podiumAnimation. value)),
                child:  Opacity(
                  opacity: podiumAnimation.value,
                  child: child,
                ),
              );
            },
            child:  Padding(
              padding: EdgeInsets.symmetric(horizontal: r.nanoPadding),
              child:  Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFirst)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.elasticOut,
                      builder:  (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: _AnimatedCrown(
                        responsive: r,
                        shimmerAnimation: shimmerAnimation,
                      ),
                    ),
                  if (isFirst) SizedBox(height: r.nanoPadding),
                  _PodiumAvatar(
                    responsive: r,
                    entry: entry,
                    tier:  tier,
                    isFirst: isFirst,
                    pulseAnimation: pulseAnimation,
                  ),
                  SizedBox(height: r.nanoPadding),
                  Text(
                    r.adaptiveText(
                      entry.name. split(' ').first,
                      nano: entry.name[0],
                      micro: entry.name
                          .split(' ')
                          .first
                          .substring(0, math.min(4, entry.name.split(' ').first.length)),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: isFirst ? r.captionL : r.captionM,
                      fontWeight: FontWeight.w700,
                      color: LeaderboardDesign.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (r.showBadges)
                    Padding(
                      padding: EdgeInsets.only(top: r. atomicPadding),
                      child: _SmallTierBadge(tier: tier, responsive: r),
                    ),
                  SizedBox(height: r.nanoPadding),
                  _PodiumBlock(
                    responsive: r,
                    entry: entry,
                    rankIndex: rankIndex,
                    height: height,
                    tier: tier,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// ==================== ANIMATED CROWN (Internal) ====================
class _AnimatedCrown extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final Animation<double> shimmerAnimation;

  const _AnimatedCrown({
    required this.responsive,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors:  [
                LeaderboardDesign.goldPrimary,
                LeaderboardDesign. goldGlow,
                LeaderboardDesign.goldPrimary,
              ],
              begin: Alignment(-1 + shimmerAnimation.value, 0),
              end: Alignment(shimmerAnimation.value, 0),
            ).createShader(bounds);
          },
          child: Icon(
            Icons.auto_awesome_rounded,
            size: r.iconSize(28),
            color: Colors.white,
          ),
        );
      },
    );
  }
}

/// ==================== PODIUM AVATAR (Internal) ====================
class _PodiumAvatar extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final LeaderboardEntry entry;
  final LeaderboardTier tier;
  final bool isFirst;
  final Animation<double> pulseAnimation;

  const _PodiumAvatar({
    required this.responsive,
    required this.entry,
    required this.tier,
    required this.isFirst,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final size = isFirst ? r.avatarSize * 1.3 : r.avatarSize;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isFirst)
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Container(
                width: size + 20,
                height: size + 20,
                decoration:  BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tier.glowColor.withOpacity(0.3 * pulseAnimation.value),
                      blurRadius: 20 * pulseAnimation.value,
                      spreadRadius: 5 * (pulseAnimation.value - 1),
                    ),
                  ],
                ),
              );
            },
          ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape. circle,
            border: Border.all(
              color: tier.primaryColor,
              width: isFirst ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color:  tier.glowColor.withOpacity(0.5),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipOval(
            child: entry.profileImage != null
                ? Image.network(
              entry.profileImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _AvatarPlaceholder(
                name: entry.name,
                size: size,
                responsive: r,
              ),
            )
                : _AvatarPlaceholder(
              name: entry.name,
              size: size,
              responsive: r,
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
          name.isNotEmpty ? name[0]. toUpperCase() : '?',
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

/// ==================== SMALL TIER BADGE (Internal) ====================
class _SmallTierBadge extends StatelessWidget {
  final LeaderboardTier tier;
  final EmployeeResponsiveData responsive;

  const _SmallTierBadge({
    required this.tier,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.nanoPadding,
        vertical: r. atomicPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tier.gradientColors),
        borderRadius:  BorderRadius.circular(r.smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: tier.glowColor.withOpacity(0.4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tier.icon,
            size: r.iconSize(10),
            color: tier == LeaderboardTier.silver
                ? LeaderboardDesign.textPrimary
                : Colors.white,
          ),
          SizedBox(width: r.atomicPadding),
          Text(
            tier.shortName,
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight. w700,
              color: tier == LeaderboardTier.silver
                  ? LeaderboardDesign.textPrimary
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// ==================== PODIUM BLOCK (Internal) ====================
class _PodiumBlock extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final LeaderboardEntry entry;
  final int rankIndex;
  final double height;
  final LeaderboardTier tier;

  const _PodiumBlock({
    required this.responsive,
    required this.entry,
    required this.rankIndex,
    required this.height,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final colors = [
      LeaderboardDesign. goldPrimary,
      LeaderboardDesign.silverPrimary,
      LeaderboardDesign.bronzePrimary,
    ];
    final color = colors[rankIndex];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (rankIndex * 200)),
      curve: Curves. easeOutBack,
      builder: (context, value, child) {
        return Container(
          height: height * value,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(r.borderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${rankIndex + 1}',
                style: GoogleFonts.inter(
                  fontSize: rankIndex == 0 ? r. headingM : r.headingS,
                  fontWeight: FontWeight.w900,
                  color: rankIndex == 1
                      ? LeaderboardDesign.textPrimary
                      : Colors.white,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: r.nanoPadding),
                padding: EdgeInsets.symmetric(
                  horizontal: r.nanoPadding,
                  vertical:  r.atomicPadding,
                ),
                decoration: BoxDecoration(
                  color: (rankIndex == 1
                      ? LeaderboardDesign.textPrimary
                      : Colors.white)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Text(
                  '${entry.points}',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w700,
                    color: rankIndex == 1
                        ?  LeaderboardDesign.textPrimary
                        : Colors. white,
                  ),
                ),
              ),
              if (r.showSecondaryText)
                Padding(
                  padding: EdgeInsets.only(top: r.atomicPadding),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: r. iconSize(12),
                        color: (rankIndex == 1
                            ? LeaderboardDesign.textPrimary
                            : Colors.white)
                            .withOpacity(0.9),
                      ),
                      SizedBox(width: r. atomicPadding),
                      Text(
                        entry.rating.toStringAsFixed(1),
                        style: GoogleFonts. inter(
                          fontSize: r.captionXS,
                          color: (rankIndex == 1
                              ? LeaderboardDesign.textPrimary
                              : Colors.white)
                              .withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}