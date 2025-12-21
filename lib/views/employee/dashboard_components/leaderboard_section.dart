import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/dashboard_tab_viewmodel.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/dashboard_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/employee_dashboard_tab.dart';

import '../../../models/employee/leaderboard_models.dart';

class DashboardLeaderboardSection extends StatelessWidget {
  final DashboardTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Animation<double> shimmerAnimation;
  final Function(int) onNavigateToTab;

  const DashboardLeaderboardSection({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.shimmerAnimation,
    required this. onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(r),
        SizedBox(height: r.microPadding),
        viewModel.hasLeaderboard
            ? _buildModernPodium(r)
            : _buildNoLeaderboardCard(r),
      ],
    );
  }

  Widget _buildSectionHeader(EmployeeResponsiveData r) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.nanoPadding),
          decoration:  BoxDecoration(
            color:  DesignSystem.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Icon(
            Icons.emoji_events_rounded,
            size: r.iconSize(18),
            color: DesignSystem.warning,
          ),
        ),
        SizedBox(width: r. microPadding),
        Expanded(
          child: Text(
            'Top Performers',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w700,
              color: DesignSystem.textPrimary,
            ),
          ),
        ),
        _buildViewAllButton(r),
      ],
    );
  }

  Widget _buildViewAllButton(EmployeeResponsiveData r) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:  () {
          HapticFeedback.lightImpact();
          onNavigateToTab(4);
        },
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
        child: Container(
          padding:  EdgeInsets.symmetric(
            horizontal: r.microPadding,
            vertical:  r.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: DesignSystem.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r.adaptiveText('View All', nano: '→', micro: 'All'),
                style: GoogleFonts.inter(
                  fontSize: r.captionS,
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.primaryTeal,
                ),
              ),
              SizedBox(width: r.atomicPadding),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: r.iconSize(10),
                color: DesignSystem.primaryTeal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernPodium(EmployeeResponsiveData r) {
    final topThree = viewModel.topThree;
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    final heights = [r.dimension(120), r.dimension(100), r.dimension(80)];
    final displayOrder = [1, 0, 2]; // Silver, Gold, Bronze

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFBEB),
            Color(0xFFFEF3C7),
          ],
          begin: Alignment. topCenter,
          end: Alignment. bottomCenter,
        ),
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: DesignSystem.softShadow,
      ),
      child: Column(
        children: [
          // Trophy animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: (1 - value) * 0.3,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors[0], colors[0].withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: DesignSystem.glowShadow(colors[0]),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                size: r.iconSize(32),
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: r.padding),

          // Podium
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: displayOrder.map((rankIndex) {
              if (rankIndex >= topThree.length) return const SizedBox.shrink();

              final person = topThree[rankIndex];
              final color = colors[rankIndex];
              final height = heights[rankIndex];
              final isFirst = rankIndex == 0;

              return Expanded(
                child: _buildPodiumPosition(
                  r,
                  person,
                  rankIndex,
                  color,
                  height,
                  isFirst,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(
      EmployeeResponsiveData r,
      LeaderboardEntry person,
      int rankIndex,
      Color color,
      double height,
      bool isFirst,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (rankIndex * 200)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child:  Opacity(opacity: value, child: child),
        );
      },
      child:  Padding(
        padding: EdgeInsets.symmetric(horizontal: r.nanoPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crown for first place
            if (isFirst)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves. elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size:  r.iconSize(28),
                  color: color,
                ),
              ),
            if (isFirst) SizedBox(height: r.nanoPadding),

            // Avatar
            Container(
              width: isFirst ? r.avatarSize : r.avatarSizeSmall,
              height: isFirst ? r.avatarSize : r.avatarSizeSmall,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: DesignSystem.glowShadow(color),
              ),
              child:  ClipOval(
                child: person.profileImage != null && person.profileImage! .isNotEmpty
                    ?  Image.network(
                  person.profileImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _buildAvatarInitial(r, person. name, color),
                )
                    : _buildAvatarInitial(r, person.name, color),
              ),
            ),
            SizedBox(height: r.nanoPadding),

            // Name
            Text(
              person.name. split(' ').first,
              style: GoogleFonts.inter(
                fontSize: isFirst ? r.captionL : r.captionM,
                fontWeight: FontWeight.w700,
                color: DesignSystem.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Podium block
            SizedBox(height: r.nanoPadding),
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color. withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(r.borderRadius),
                ),
                boxShadow: DesignSystem.glowShadow(color),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${rankIndex + 1}',
                    style: GoogleFonts.inter(
                      fontSize: isFirst ? r.headingM :  r.headingS,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r. nanoPadding,
                      vertical: r.atomicPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Text(
                      '${person.points} pts',
                      style: GoogleFonts.inter(
                        fontSize: r.captionS,
                        fontWeight: FontWeight. w700,
                        color:  Colors.white,
                      ),
                    ),
                  ),
                  if (r.showSecondaryText) ...[
                    SizedBox(height:  r.atomicPadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment. center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: r.iconSize(12),
                          color: Colors.white.withOpacity(0.9),
                        ),
                        SizedBox(width:  r.atomicPadding),
                        Text(
                          person.rating.toStringAsFixed(1),
                          style:  GoogleFonts.inter(
                            fontSize: r.captionXS,
                            color:  Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarInitial(EmployeeResponsiveData r, String name, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment. bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name. isNotEmpty ? name[0]. toUpperCase() : '? ',
          style: GoogleFonts.inter(
            fontSize: r.avatarSize * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLeaderboard(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          height: r. dimension(200),
          decoration:  BoxDecoration(
            borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + shimmerAnimation.value, 0),
              end: Alignment(shimmerAnimation.value, 0),
              colors: [
                Colors.grey[200]!,
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoLeaderboardCard(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.largePadding),
      decoration: BoxDecoration(
        color:  const Color(0xFFFFFBEB),
        borderRadius:  BorderRadius.circular(r.largeBorderRadius),
      ),
      child: Column(
        children: [
          Icon(
            Icons. emoji_events_outlined,
            size: r.iconSize(40),
            color:  DesignSystem.warning.withOpacity(0.5),
          ),
          SizedBox(height: r.microPadding),
          Text(
            'No rankings yet',
            style:  GoogleFonts.inter(
              fontSize: r.bodyS,
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}