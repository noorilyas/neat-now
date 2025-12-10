import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:neat_now/screens/user_dashboard.dart';
import 'package:neat_now/widgets/user/responsive_user_helper.dart';

/// ==================== USER LEADERBOARD TAB (FR-U8) ====================
class UserLeaderboardTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final UserResponsiveData responsive;

  const UserLeaderboardTab({
    super.key,
    required this.userData,
    required this. responsive,
  });

  @override
  State<UserLeaderboardTab> createState() => _UserLeaderboardTabState();
}

class _UserLeaderboardTabState extends State<UserLeaderboardTab> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _podiumController;
  late AnimationController _listController;
  late AnimationController _shimmerController;

  late Animation<double> _headerFadeAnimation;
  late Animation<double> _podiumAnimation;
  late Animation<double> _shimmerAnimation;

  bool _showFullLeaderboard = false;
  final ScrollController _scrollController = ScrollController();

  // Sample leaderboard data
  final List<_LeaderboardUser> _leaderboard = [
    _LeaderboardUser('1', 'Sarah Khan', 156, 1, 'platinum', null),
    _LeaderboardUser('2', 'Ahmad Ali', 142, 2, 'gold', null),
    _LeaderboardUser('3', 'Fatima Ahmed', 128, 3, 'silver', null),
    _LeaderboardUser('4', 'Omar Hassan', 115, 4, null, null),
    _LeaderboardUser('5', 'Zainab Malik', 98, 5, null, null),
    _LeaderboardUser('6', 'Bilal Khan', 87, 6, null, null),
    _LeaderboardUser('7', 'Aisha Noor', 76, 7, null, null),
    _LeaderboardUser('8', 'Hassan Ali', 65, 8, null, null),
    _LeaderboardUser('9', 'Maryam Shah', 54, 9, null, null),
    _LeaderboardUser('10', 'Usman Raza', 43, 10, null, null),
  ];

  String get _currentUserId => widget.userData['id']?. toString() ?? '5';
  int get _currentUserRank => widget.userData['rank'] ?? 5;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _headerFadeAnimation = CurvedAnimation(parent: _headerController, curve: Curves. easeOutCubic);

    _podiumController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _podiumAnimation = CurvedAnimation(parent: _podiumController, curve: Curves. elasticOut);

    _listController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

    _shimmerController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this).. repeat();
    _shimmerAnimation = Tween<double>(begin: 0, end: 1). animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _podiumController. forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _listController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _podiumController.dispose();
    _listController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildHeader(r)),

        // Podium (Top 3)
        SliverToBoxAdapter(child: _buildPodium(r)),

        // Your Rank Card
        SliverToBoxAdapter(child: _buildYourRankCard(r)),

        // Toggle Button
        SliverToBoxAdapter(child: _buildToggleButton(r)),

        // Leaderboard List
        if (_showFullLeaderboard)
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildLeaderboardItem(r, _leaderboard[index], index),
              childCount: _leaderboard.length,
            ),
          ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: r.safePaddingBottom + 100)),
      ],
    );
  }

  Widget _buildHeader(UserResponsiveData r) {
    return FadeTransition(
      opacity: _headerFadeAnimation,
      child: Container(
        padding: EdgeInsets.fromLTRB(r.padding, r.safePaddingTop + r.padding, r.padding, r. padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              UserDesign.purple. withOpacity(0.1),
            //  UserDesign.purpleLight.withOpacity(0.05),
              UserDesign.surfaceLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets. all(r.microPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [UserDesign.purple, UserDesign.purple.withOpacity(0.8)]),
                    borderRadius: BorderRadius.circular(r. borderRadius),
                    boxShadow: UserDesign.glowShadow(UserDesign.purple),
                  ),
                  child: Icon(Icons.leaderboard_rounded, color: Colors.white, size: r.iconSize(22)),
                ),
                SizedBox(width: r.microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment. start,
                    children: [
                      Text(
                        'Leaderboard',
                        style: GoogleFonts.inter(
                          fontSize: r.headingXS,
                          fontWeight: FontWeight. w800,
                          color: UserDesign. textPrimary,
                        ),
                      ),
                      Text(
                        'Top contributors this month',
                        style: GoogleFonts.inter(fontSize: r.captionS, color: UserDesign. textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: r.padding),

            // Info Banner
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: UserDesign. surfacePure,
                borderRadius: BorderRadius.circular(r. largeBorderRadius),
                boxShadow: UserDesign.softShadow,
              ),
              child: Row(
                children: [
                  _buildInfoItem(r, Icons.diamond_rounded, 'Platinum', '#1', UserDesign.platinum),
                  _buildDivider(r),
                  _buildInfoItem(r, Icons.workspace_premium_rounded, 'Gold', '#2', const Color(0xFFFFD700)),
                  _buildDivider(r),
                  _buildInfoItem(r, Icons.military_tech_rounded, 'Silver', '#3', UserDesign.silver),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(UserResponsiveData r, IconData icon, String label, String rank, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: r.iconSize(16)),
          ),
          SizedBox(height: r.atomicPadding),
          Text(label, style: GoogleFonts.inter(fontSize: r.captionXS, fontWeight: FontWeight. w600, color: UserDesign.textPrimary)),
          Text(rank, style: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign. textTertiary)),
        ],
      ),
    );
  }

  Widget _buildDivider(UserResponsiveData r) {
    return Container(width: 1, height: r.dimension(40), color: UserDesign.surfaceOverlay);
  }

  Widget _buildPodium(UserResponsiveData r) {
    final top3 = _leaderboard.take(3).toList();

    return ScaleTransition(
      scale: _podiumAnimation,
      child: Padding(
        padding: EdgeInsets. symmetric(horizontal: r. padding),
        child: SizedBox(
          height: r.dimension(260),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Podium base
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd Place
                  Expanded(child: _buildPodiumPlace(r, top3[1], 2, r.dimension(100))),
                  SizedBox(width: r.microPadding),
                  // 1st Place
                  Expanded(child: _buildPodiumPlace(r, top3[0], 1, r.dimension(130))),
                  SizedBox(width: r.microPadding),
                  // 3rd Place
                  Expanded(child: _buildPodiumPlace(r, top3[2], 3, r.dimension(80))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumPlace(UserResponsiveData r, _LeaderboardUser user, int place, double height) {
    Color badgeColor;
    IconData badgeIcon;

    switch (place) {
      case 1:
        badgeColor = UserDesign. platinum;
        badgeIcon = Icons.diamond_rounded;
        break;
      case 2:
        badgeColor = const Color(0xFFFFD700);
        badgeIcon = Icons.workspace_premium_rounded;
        break;
      default:
        badgeColor = UserDesign.silver;
        badgeIcon = Icons.military_tech_rounded;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment. end,
      children: [
        // Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  width: r.dimension(place == 1 ?  70 : 56),
                  height: r.dimension(place == 1 ? 70 : 56),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [badgeColor, badgeColor.withOpacity(0.7)]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: r.dimension(place == 1 ? 62 : 48),
                      height: r.dimension(place == 1 ? 62 : 48),
                      decoration: BoxDecoration(
                        color: UserDesign.surfacePure,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.name. isNotEmpty ? user. name[0]. toUpperCase() : '? ',
                          style: GoogleFonts.inter(
                            fontSize: place == 1 ?  r.headingS : r.bodyM,
                            fontWeight: FontWeight. w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Crown/Badge
            if (place == 1)
              Positioned(
                top: -r.dimension(12),
                left: 0,
                right: 0,
                child: Center(
                  child: Icon(Icons.star_rounded, color: const Color(0xFFFFD700), size: r.iconSize(24)),
                ),
              ),
          ],
        ),

        SizedBox(height: r.microPadding),

        // Name
        Text(
          user. name. split(' ').first,
          style: GoogleFonts. inter(
            fontSize: r.captionM,
            fontWeight: FontWeight.w700,
            color: UserDesign.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // Reports count
        Text(
          '${user.verifiedReports} reports',
          style: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign.textSecondary),
        ),

        SizedBox(height: r.nanoPadding),

        // Podium block
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [badgeColor. withOpacity(0.3), badgeColor. withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius. vertical(top: Radius.circular(r. borderRadius)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(badgeIcon, color: badgeColor, size: r.iconSize(28)),
                SizedBox(height: r.atomicPadding),
                Text(
                  '#$place',
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYourRankCard(UserResponsiveData r) {
    final isTopThree = _currentUserRank <= 3;

    return Padding(
        padding: EdgeInsets. all(r.padding),
        child: Container(
          padding: EdgeInsets. all(r.padding),
          decoration: BoxDecoration(
            gradient: isTopThree
                ? LinearGradient(colors: [UserDesign.primaryTeal. withOpacity(0.1), UserDesign.primaryTealLight.withOpacity(0.05)])
                : null,
            color: isTopThree ? null : UserDesign. surfacePure,
            borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
            border: Border.all(color: isTopThree ? UserDesign.primaryTeal. withOpacity(0.3) : UserDesign.surfaceOverlay),
            boxShadow: UserDesign.softShadow,
          ),
          child: Row(
              children: [
          Container(
          width: r.dimension(50),
          height: r.dimension(50),
          decoration: BoxDecoration(
            gradient: UserDesign.primaryGradient,
            shape: BoxShape. circle,
            boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
          ),
          child: Center(
            child: Text(
              widget.userData['name']?.toString(). isNotEmpty == true
                  ? widget. userData['name'][0].toUpperCase()
                  : 'U',
              style: GoogleFonts.inter(fontSize: r.bodyM, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
              'Your Ranking',
              style: GoogleFonts.inter(fontSize: r.captionS, color: UserDesign. textSecondary),
            ),
            Row(
              children: [
              Text(
              '#$_currentUserRank',
              style: GoogleFonts. inter(
                fontSize: r.headingXS,
                fontWeight: FontWeight. w800,
                color: UserDesign.primaryTeal,
              ),
            ),
            if (isTopThree) ...[
        SizedBox(width: r.nanoPadding),
    Icon(
    _currentUserRank == 1
    ? Icons. diamond_rounded
        : (_currentUserRank == 2 ? Icons.workspace_premium_rounded : Icons.military_tech_rounded),
    color: _currentUserRank == 1
    ? UserDesign.platinum
        : (_currentUserRank == 2 ? const Color(0xFFFFD700) : UserDesign.silver),
    size: r.iconSize(20),
    ),
    ],
    ],
    ),
    ],
    ),
    ),
    Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
    Text(
    '${widget.userData['verifiedReports'] ?? 0}',
    style: GoogleFonts.inter(fontSize: r.headingXS, fontWeight: FontWeight. w800, color: UserDesign.textPrimary),
    ),
    Text(
    'verified reports',
    style: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign.textSecondary),
    ),
    ],
    ),
    ],
    ),
    ),
    );
  }

  Widget _buildToggleButton(UserResponsiveData r) {
    return Padding(
        padding: EdgeInsets. symmetric(horizontal: r. padding),
        child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showFullLeaderboard = !_showFullLeaderboard);
            },
            child:        Container(
              padding: EdgeInsets.symmetric(vertical: r.microPadding),
              decoration: BoxDecoration(
                color: UserDesign.surfacePure,
                borderRadius: BorderRadius.circular(r.  borderRadius),
                border: Border.all(color: UserDesign.surfaceOverlay),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showFullLeaderboard ?  Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: UserDesign.primaryTeal,
                    size: r.iconSize(22),
                  ),
                  SizedBox(width: r.nanoPadding),
                  Text(
                    _showFullLeaderboard ? 'Hide Full Leaderboard' : 'View Full Leaderboard',
                    style: GoogleFonts. inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight. w600,
                      color: UserDesign.primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
        ),
    );
  }

  Widget _buildLeaderboardItem(UserResponsiveData r, _LeaderboardUser user, int index) {
    final isCurrentUser = user.id == _currentUserId;
    final isTopThree = user.rank <= 3;

    Color? badgeColor;
    IconData? badgeIcon;

    if (user.rank == 1) {
      badgeColor = UserDesign.platinum;
      badgeIcon = Icons.diamond_rounded;
    } else if (user. rank == 2) {
      badgeColor = const Color(0xFFFFD700);
      badgeIcon = Icons.workspace_premium_rounded;
    } else if (user.rank == 3) {
      badgeColor = UserDesign.silver;
      badgeIcon = Icons.military_tech_rounded;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets. fromLTRB(r.padding, 0, r.padding, r.microPadding),
        padding: EdgeInsets. all(r.microPadding),
        decoration: BoxDecoration(
          color: isCurrentUser ? UserDesign.primaryTeal. withOpacity(0.05) : UserDesign.surfacePure,
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border. all(
            color: isCurrentUser ? UserDesign.primaryTeal. withOpacity(0.3) : UserDesign.surfaceOverlay,
            width: isCurrentUser ? 2 : 1,
          ),
          boxShadow: UserDesign. softShadow,
        ),
        child: Row(
          children: [
            // Rank
            Container(
              width: r.dimension(36),
              height: r.dimension(36),
              decoration: BoxDecoration(
                gradient: isTopThree
                    ? LinearGradient(colors: [badgeColor!, badgeColor. withOpacity(0.7)])
                    : null,
                color: isTopThree ? null : UserDesign.surfaceLight,
                borderRadius: BorderRadius. circular(r.borderRadius),
              ),
              child: Center(
                child: isTopThree
                    ? Icon(badgeIcon, color: Colors.white, size: r.iconSize(18))
                    : Text(
                  '#${user.rank}',
                  style: GoogleFonts. inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight. w700,
                    color: UserDesign.textSecondary,
                  ),
                ),
              ),
            ),

            SizedBox(width: r.microPadding),

            // Avatar
            Container(
              width: r. dimension(40),
              height: r.dimension(40),
              decoration: BoxDecoration(
                gradient: isTopThree
                    ? LinearGradient(colors: [badgeColor!, badgeColor! .withOpacity(0.7)])
                    : UserDesign.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.name. isNotEmpty ?  user.name[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight. w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(width: r.microPadding),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: GoogleFonts. inter(
                            fontSize: r.bodyS,
                            fontWeight: FontWeight. w600,
                            color: UserDesign. textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        SizedBox(width: r. nanoPadding),
                        Container(
                          padding: EdgeInsets. symmetric(horizontal: r. nanoPadding, vertical: r.atomicPadding),
                          decoration: BoxDecoration(
                            color: UserDesign.primaryTeal,
                            borderRadius: BorderRadius.circular(r.smallBorderRadius),
                          ),
                          child: Text(
                            'You',
                            style: GoogleFonts.inter(fontSize: r.captionXS, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${user.verifiedReports} verified reports',
                    style: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign.textTertiary),
                  ),
                ],
              ),
            ),

            // Badge (if top 3)
            if (isTopThree)
              Container(
                padding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [badgeColor!, badgeColor. withOpacity(0.8)]),
                  borderRadius: BorderRadius. circular(r.pillBorderRadius),
                  boxShadow: UserDesign.glowShadow(badgeColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize. min,
                  children: [
                    Icon(badgeIcon, color: Colors.white, size: r.iconSize(12)),
                    SizedBox(width: r.atomicPadding),
                    Text(
                      user.rank == 1 ? 'Platinum' : (user.rank == 2 ? 'Gold' : 'Silver'),
                      style: GoogleFonts.inter(fontSize: r.captionXS, fontWeight: FontWeight.w600, color: Colors. white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardUser {
  final String id;
  final String name;
  final int verifiedReports;
  final int rank;
  final String?  badge;
  final String? avatarUrl;

  _LeaderboardUser(this.id, this. name, this.verifiedReports, this.rank, this. badge, this.avatarUrl);
}