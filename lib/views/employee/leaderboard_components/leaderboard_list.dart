import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/leaderboard_models.dart';
import 'package:neat_now/viewmodels/employee/leaderboard_viewmodel.dart';
import 'package:neat_now/design/leaderboard_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/leaderboard_components/user_detail_sheet.dart';

class LeaderboardListSection extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final LeaderboardViewModel viewModel;

  const LeaderboardListSection({
    super.key,
    required this.responsive,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: LeaderboardDesign.surfaceWhite,
        borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                size: r.iconSize(20),
                color: LeaderboardDesign.primaryTeal,
              ),
              SizedBox(width: r. microPadding),
              Text(
                r.adaptiveText('All Rankings',
                    nano: 'All', micro: 'Ranks', mini: 'Rankings'),
                style: GoogleFonts.inter(
                  fontSize: r.bodyM,
                  fontWeight: FontWeight.w700,
                  color: LeaderboardDesign.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${viewModel.filteredEntries.length} workers',
                style: GoogleFonts.inter(
                  fontSize: r.captionS,
                  color: LeaderboardDesign.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height:  r.microPadding),
          ...viewModel.filteredEntries.asMap().entries.map((entry) {
            final globalRank = viewModel.getRankForEntry(entry.value);
            return _LeaderboardItem(
              responsive: r,
              viewModel: viewModel,
              entry: entry.value,
              rank: globalRank,
              index: entry.key,
            );
          }),
          if (viewModel.filteredEntries.isEmpty)
            _NoResultsMessage(responsive: r),
        ],
      ),
    );
  }
}

/// ==================== LEADERBOARD ITEM (Internal) ====================
class _LeaderboardItem extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final LeaderboardViewModel viewModel;
  final LeaderboardEntry entry;
  final int rank;
  final int index;

  const _LeaderboardItem({
    required this.responsive,
    required this.viewModel,
    required this.entry,
    required this.rank,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final tier = viewModel.getTierForEntry(entry);
    final isCurrentUser = viewModel.isCurrentUser(entry);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder:  (context) => UserDetailSheet(
              entry: entry,
              rank: rank,
              tier: tier,
              responsive: r,
              isCurrentUser: isCurrentUser,
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: r.microPadding),
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            gradient: isCurrentUser
                ? LinearGradient(
              colors: [
                tier.primaryColor. withOpacity(0.15),
                tier.primaryColor.withOpacity(0.05),
              ],
            )
                : null,
            color: isCurrentUser ?  null : LeaderboardDesign. surfaceLight,
            borderRadius: BorderRadius.circular(r.borderRadius),
            border: Border. all(
              color: isCurrentUser
                  ? tier.primaryColor.withOpacity(0.3)
                  :  Colors.transparent,
              width: isCurrentUser ? 2 : 0,
            ),
          ),
          child: Row(
            children: [
              // Rank Badge
              Container(
                width: r.dimension(32),
                height: r.dimension(32),
                decoration: BoxDecoration(
                  gradient: rank <= 3
                      ? LinearGradient(colors: tier.gradientColors)
                      : null,
                  color:  rank > 3 ? LeaderboardDesign.surfaceCard : null,
                  borderRadius: BorderRadius.circular(r. smallBorderRadius),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight.w700,
                      color: rank <= 3
                          ? (tier == LeaderboardTier. silver
                          ? LeaderboardDesign.textPrimary
                          : Colors.white)
                          : LeaderboardDesign.textSecondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width:  r.microPadding),
              _UserAvatar(
                entry: entry,
                tier: tier,
                responsive: r,
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.name,
                            style: GoogleFonts.inter(
                              fontSize: r.bodyS,
                              fontWeight:
                              isCurrentUser ? FontWeight.w700 : FontWeight.w600,
                              color: LeaderboardDesign.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          SizedBox(width: r.nanoPadding),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.nanoPadding,
                              vertical: r.atomicPadding,
                            ),
                            decoration: BoxDecoration(
                              color: tier.primaryColor,
                              borderRadius: BorderRadius.circular(r.tinyBorderRadius),
                            ),
                            child: Text(
                              'YOU',
                              style: GoogleFonts.inter(
                                fontSize: r.captionXS,
                                fontWeight: FontWeight.w700,
                                color: tier == LeaderboardTier.silver
                                    ? LeaderboardDesign.textPrimary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height:  r.atomicPadding),
                    Row(
                      children: [
                        _TierBadge(tier: tier, responsive: r),
                        SizedBox(width:  r.nanoPadding),
                        if (r.showSecondaryText)
                          Text(
                            '${entry.tasksCompleted} tasks',
                            style: GoogleFonts. inter(
                              fontSize: r.captionXS,
                              color: LeaderboardDesign.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size:  r.iconSize(14),
                        color: LeaderboardDesign.goldPrimary,
                      ),
                      SizedBox(width: r.atomicPadding),
                      Text(
                        '${entry.points}',
                        style: GoogleFonts.inter(
                          fontSize: r.bodyS,
                          fontWeight:  FontWeight.w700,
                          color: LeaderboardDesign.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (r.showSecondaryText)
                    Text(
                      '★ ${entry.rating. toStringAsFixed(1)}',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        color: tier. primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              SizedBox(width: r.nanoPadding),
              Icon(
                Icons.chevron_right_rounded,
                size: r.iconSize(20),
                color: LeaderboardDesign.textTertiary,
              ),
            ],
          ),
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

  const _UserAvatar({
    required this.entry,
    required this.tier,
    required this. responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final size = r.avatarSize;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color:  Colors.black.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: entry.profileImage != null
                ? Image.network(
              entry.profileImage! ,
              fit: BoxFit.cover,
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
              size: r.iconSize(10),
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
            LeaderboardDesign. primaryTealLight,
          ],
        ),
      ),
      child: Center(
        child: Text(
          name. isNotEmpty ? name[0].toUpperCase() : '?',
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

  const _TierBadge({
    required this.tier,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding:  EdgeInsets.symmetric(
        horizontal: r.nanoPadding,
        vertical: r. atomicPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tier.gradientColors),
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
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
                : Colors. white,
          ),
          SizedBox(width: r.atomicPadding),
          Text(
            tier.shortName,
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight.w700,
              color: tier == LeaderboardTier.silver
                  ?  LeaderboardDesign.textPrimary
                  : Colors. white,
            ),
          ),
        ],
      ),
    );
  }
}

/// ==================== NO RESULTS MESSAGE (Internal) ====================
class _NoResultsMessage extends StatelessWidget {
  final EmployeeResponsiveData responsive;

  const _NoResultsMessage({required this. responsive});

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding:  EdgeInsets.all(r. largePadding),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: r.iconSize(48),
            color: LeaderboardDesign.textTertiary,
          ),
          SizedBox(height: r. microPadding),
          Text(
            'No workers found',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w600,
              color: LeaderboardDesign.textSecondary,
            ),
          ),
          if (r.showSecondaryText)
            Text(
              'Try adjusting your filters',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: LeaderboardDesign.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

/// ==================== STATE COMPONENTS (Bonus - Internal) ====================
class LoadingState extends StatelessWidget {
  final EmployeeResponsiveData responsive;

  const LoadingState({super.key, required this.responsive});

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(LeaderboardDesign.goldPrimary),
          ),
          SizedBox(height: r.padding),
          Text(
            'Loading leaderboard...',
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: LeaderboardDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final String error;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.responsive,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Center(
      child:  Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(r.largePadding),
              decoration: BoxDecoration(
                color: LeaderboardDesign.error. withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: r.iconSize(48),
                color:  LeaderboardDesign.error,
              ),
            ),
            SizedBox(height: r. padding),
            Text(
              'Failed to load leaderboard',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: LeaderboardDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.microPadding),
            ElevatedButton. icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh_rounded, size: r.iconSize(18)),
              label: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: LeaderboardDesign.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: r.largePadding,
                  vertical: r.microPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final EmployeeResponsiveData responsive;

  const EmptyState({super. key, required this.responsive});

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets. all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(r.largePadding),
              decoration: BoxDecoration(
                color: LeaderboardDesign.goldPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_outlined,
                size: r.iconSize(48),
                color:  LeaderboardDesign.goldPrimary,
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'No rankings yet',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: LeaderboardDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              'Complete tasks to appear on the leaderboard',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: LeaderboardDesign.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}