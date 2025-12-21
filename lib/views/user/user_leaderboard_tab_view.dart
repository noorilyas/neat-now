import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/models/user/user_model.dart';
import 'package:neat_now/models/user/leaderboard_user_model.dart';
import 'package:neat_now/viewmodels/user/user_leaderboard_viewmodel.dart';

/// ==================== USER LEADERBOARD TAB (FR-U8) ====================
class UserLeaderboardTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final UserResponsiveData responsive;

  const UserLeaderboardTab({
    super.key,
    required this. userData,
    required this.responsive,
  });

  @override
  State<UserLeaderboardTab> createState() => _UserLeaderboardTabState();
}

class _UserLeaderboardTabState extends State<UserLeaderboardTab>
    with TickerProviderStateMixin {
  late UserLeaderboardViewModel _viewModel;

  late AnimationController _headerController;
  late AnimationController _podiumController;
  late AnimationController _listController;
  late AnimationController _shimmerController;

  late Animation<double> _headerFadeAnimation;
  late Animation<double> _podiumAnimation;
  late Animation<double> _shimmerAnimation;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initialize ViewModel
    _viewModel = UserLeaderboardViewModel(
      user: UserModel.fromMap(widget.userData),
    );
    _viewModel.addListener(_onViewModelChanged);

    _initAnimations();
    _startAnimations();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds:  600),
      vsync: this,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent:  _headerController,
      curve:  Curves.easeOutCubic,
    );

    _podiumController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _podiumAnimation = CurvedAnimation(
      parent: _podiumController,
      curve: Curves. elasticOut,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve:  Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _podiumController. forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _listController. forward();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
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
        if (_viewModel.showFullLeaderboard)
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final leaderboard = _viewModel.getLeaderboardData();
                return _buildLeaderboardItem(r, leaderboard[index], index);
              },
              childCount: _viewModel.getLeaderboardData().length,
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
        padding: EdgeInsets.fromLTRB(
          r. padding,
          r.safePaddingTop + r.padding,
          r.padding,
          r.padding,
        ),
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            colors: [
              UserDesign.purple. withOpacity(0.1),
              UserDesign.surfaceLight,
            ],
            begin:  Alignment.topCenter,
            end: Alignment. bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.microPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        UserDesign.purple,
                        UserDesign.purple.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(r.borderRadius),
                    boxShadow: UserDesign.glowShadow(UserDesign.purple),
                  ),
                  child: Icon(
                    Icons.leaderboard_rounded,
                    color: Colors.white,
                    size: r.iconSize(22),
                  ),
                ),
                SizedBox(width:  r.microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leaderboard',
                        style: GoogleFonts.inter(
                          fontSize: r. headingXS,
                          fontWeight: FontWeight.w800,
                          color: UserDesign.textPrimary,
                        ),
                      ),
                      Text(
                        'Top contributors this month',
                        style: GoogleFonts.inter(
                          fontSize: r.captionS,
                          color: UserDesign.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: r.padding),

            // Info Banner
            Container(
              padding:  EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: UserDesign.surfacePure,
                borderRadius: BorderRadius.circular(r.largeBorderRadius),
                boxShadow: UserDesign.softShadow,
              ),
              child: Row(
                children: _viewModel
                    .getPodiumInfoItems()
                    .asMap()
                    .entries
                    .map((entry) {
                  final item = entry. value;
                  final isLast =
                      entry.key == _viewModel.getPodiumInfoItems().length - 1;
                  return [
                    _buildInfoItem(r, item),
                    if (!isLast) _buildDivider(r),
                  ];
                }).expand((widget) => widget).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(UserResponsiveData r, dynamic item) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration:  BoxDecoration(
              gradient: LinearGradient(
                colors: [item.color, item.color.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: Colors.white, size: r.iconSize(16)),
          ),
          SizedBox(height: r.atomicPadding),
          Text(
            item.label,
            style: GoogleFonts. inter(
              fontSize: r. captionXS,
              fontWeight: FontWeight.w600,
              color: UserDesign.textPrimary,
            ),
          ),
          Text(
            item.rank,
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              color: UserDesign.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(UserResponsiveData r) {
    return Container(
      width: 1,
      height: r. dimension(40),
      color: UserDesign.surfaceOverlay,
    );
  }

  Widget _buildPodium(UserResponsiveData r) {
    final top3 = _viewModel.getTopThree();

    return ScaleTransition(
      scale: _podiumAnimation,
      child:  Padding(
        padding: EdgeInsets.symmetric(horizontal: r.padding),
        child: SizedBox(
          height: r. dimension(260),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Podium base
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd Place
                  Expanded(
                    child: _buildPodiumPlace(r, top3[1], 2, r.dimension(100)),
                  ),
                  SizedBox(width: r.microPadding),
                  // 1st Place
                  Expanded(
                    child: _buildPodiumPlace(r, top3[0], 1, r. dimension(130)),
                  ),
                  SizedBox(width: r. microPadding),
                  // 3rd Place
                  Expanded(
                    child: _buildPodiumPlace(r, top3[2], 3, r.dimension(80)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumPlace(
      UserResponsiveData r,
      LeaderboardUserModel user,
      int place,
      double height,
      ) {
    final badgeData = _viewModel.getBadgeData(place);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _shimmerAnimation,
              builder:  (context, child) {
                return Container(
                  width:  r.dimension(place == 1 ? 70 : 56),
                  height: r. dimension(place == 1 ?  70 : 56),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        badgeData.color,
                        badgeData.color.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeData.color.withOpacity(0.5),
                        blurRadius:  15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: r. dimension(place == 1 ?  62 : 48),
                      height: r. dimension(place == 1 ?  62 : 48),
                      decoration: const BoxDecoration(
                        color: UserDesign.surfacePure,
                        shape:  BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.avatarInitial,
                          style: GoogleFonts.inter(
                            fontSize: place == 1 ? r.headingS : r.bodyM,
                            fontWeight: FontWeight.w700,
                            color: badgeData.color,
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
                  child: Icon(
                    Icons.star_rounded,
                    color:  const Color(0xFFFFD700),
                    size: r.iconSize(24),
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: r.microPadding),

        // Name
        Text(
          user. firstName,
          style: GoogleFonts.inter(
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
          style: GoogleFonts.inter(
            fontSize: r.captionXS,
            color: UserDesign.textSecondary,
          ),
        ),

        SizedBox(height: r.nanoPadding),

        // Podium block
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                badgeData.color. withOpacity(0.3),
                badgeData.color.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(r.borderRadius),
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  badgeData. icon,
                  color: badgeData.color,
                  size: r.iconSize(28),
                ),
                SizedBox(height: r.atomicPadding),
                Text(
                  '#$place',
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w800,
                    color: badgeData.color,
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
    final isTopThree = _viewModel.isCurrentUserTopThree;
    final badgeData = _viewModel.getCurrentUserBadgeData();

    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: isTopThree
              ? LinearGradient(
            colors: [
              UserDesign.primaryTeal.withOpacity(0.1),
              UserDesign. primaryTealLight.withOpacity(0.05),
            ],
          )
              : null,
          color: isTopThree ?  null : UserDesign.surfacePure,
          borderRadius:  BorderRadius.circular(r.extraLargeBorderRadius),
          border: Border.all(
            color: isTopThree
                ? UserDesign.primaryTeal.withOpacity(0.3)
                : UserDesign. surfaceOverlay,
          ),
          boxShadow: UserDesign.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: r.dimension(50),
              height: r.dimension(50),
              decoration: BoxDecoration(
                gradient: UserDesign.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: UserDesign. glowShadow(UserDesign.primaryTeal),
              ),
              child: Center(
                child:  Text(
                  _viewModel.currentUserName. isNotEmpty
                      ? _viewModel.currentUserName[0].toUpperCase()
                      : 'U',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyM,
                    fontWeight:  FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width:  r.microPadding),
            Expanded(
              child:  Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Ranking',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color:  UserDesign.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '#${_viewModel.currentUserRank}',
                        style: GoogleFonts.inter(
                          fontSize: r.headingXS,
                          fontWeight: FontWeight.w800,
                          color: UserDesign.primaryTeal,
                        ),
                      ),
                      if (isTopThree) ...[
                        SizedBox(width: r.nanoPadding),
                        Icon(
                          badgeData.icon,
                          color: badgeData.color,
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
                  '${_viewModel.currentUserVerifiedReports}',
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w800,
                    color: UserDesign.textPrimary,
                  ),
                ),
                Text(
                  'verified reports',
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    color: UserDesign.textSecondary,
                  ),
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
      padding: EdgeInsets.symmetric(horizontal: r.padding),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _viewModel.toggleFullLeaderboard();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: r.microPadding),
          decoration:  BoxDecoration(
            color: UserDesign.surfacePure,
            borderRadius:  BorderRadius.circular(r.borderRadius),
            border: Border.all(color: UserDesign.surfaceOverlay),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _viewModel.showFullLeaderboard
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: UserDesign.primaryTeal,
                size: r.iconSize(22),
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                _viewModel.showFullLeaderboard
                    ? 'Hide Full Leaderboard'
                    : 'View Full Leaderboard',
                style: GoogleFonts.inter(
                  fontSize: r. bodyS,
                  fontWeight: FontWeight.w600,
                  color: UserDesign.primaryTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
      UserResponsiveData r,
      LeaderboardUserModel user,
      int index,
      ) {
    final isCurrentUser = _viewModel.isCurrentUser(user.id);
    final badgeData = _viewModel.getBadgeData(user.rank);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin:  0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child:  Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(r.padding, 0, r.padding, r.microPadding),
        padding: EdgeInsets.all(r.microPadding),
        decoration:  BoxDecoration(
          color:  isCurrentUser
              ? UserDesign.primaryTeal.withOpacity(0.05)
              : UserDesign. surfacePure,
          borderRadius:  BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(
            color: isCurrentUser
                ? UserDesign.primaryTeal.withOpacity(0.3)
                : UserDesign.surfaceOverlay,
            width: isCurrentUser ? 2 : 1,
          ),
          boxShadow: UserDesign.softShadow,
        ),
        child: Row(
          children: [
            // Rank
            Container(
              width: r.dimension(36),
              height: r.dimension(36),
              decoration: BoxDecoration(
                gradient: user.isTopThree
                    ? LinearGradient(
                  colors: [
                    badgeData.color,
                    badgeData.color.withOpacity(0.7),
                  ],
                )
                    : null,
                color: user.isTopThree ?  null : UserDesign.surfaceLight,
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Center(
                child: user.isTopThree
                    ? Icon(
                  badgeData.icon,
                  color: Colors.white,
                  size: r.iconSize(18),
                )
                    : Text(
                  '#${user.rank}',
                  style: GoogleFonts. inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w700,
                    color: UserDesign.textSecondary,
                  ),
                ),
              ),
            ),

            SizedBox(width: r.microPadding),

            // Avatar
            Container(
              width:  r.dimension(40),
              height: r.dimension(40),
              decoration: BoxDecoration(
                gradient: user.isTopThree
                    ? LinearGradient(
                  colors: [
                    badgeData.color,
                    badgeData.color.withOpacity(0.7),
                  ],
                )
                    : UserDesign.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.avatarInitial,
                  style:  GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(width:  r.microPadding),

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
                          style: GoogleFonts.inter(
                            fontSize: r.bodyS,
                            fontWeight: FontWeight.w600,
                            color: UserDesign.textPrimary,
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
                            color: UserDesign.primaryTeal,
                            borderRadius:
                            BorderRadius.circular(r.smallBorderRadius),
                          ),
                          child: Text(
                            'You',
                            style: GoogleFonts.inter(
                              fontSize: r.captionXS,
                              fontWeight:  FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${user.verifiedReports} verified reports',
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      color: UserDesign.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Badge (if top 3)
            if (user. isTopThree)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.microPadding,
                  vertical: r.nanoPadding,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      badgeData.color,
                      badgeData.color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                  boxShadow: UserDesign.glowShadow(badgeData.color),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badgeData.icon,
                      color: Colors.white,
                      size: r.iconSize(12),
                    ),
                    SizedBox(width: r. atomicPadding),
                    Text(
                      badgeData.label,
                      style: GoogleFonts.inter(
                        fontSize: r. captionXS,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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