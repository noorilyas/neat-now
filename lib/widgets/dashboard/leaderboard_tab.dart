import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';
import 'package:neat_now/widgets/dashboard/components/section_header.dart';

/// LeaderboardTab - Displays user rankings
/// Implements FR-U6: Gamification - Leaderboard
class LeaderboardTab extends StatefulWidget {
  final Map<String, dynamic> userStats;
  final ResponsiveData responsive;

  const LeaderboardTab({
    super.key,
    required this.userStats,
    required this.responsive,
  });

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _weeklyLeaders = [
    {'rank': 1, 'name': 'Sarah J.', 'points': 2450, 'reports': 42, 'avatar': 'S'},
    {'rank': 2, 'name': 'Mike R.', 'points': 2180, 'reports': 38, 'avatar': 'M'},
    {'rank': 3, 'name': 'Emily K.', 'points': 1920, 'reports': 35, 'avatar': 'E'},
    {'rank': 4, 'name': 'John D.', 'points': 1750, 'reports': 31, 'avatar': 'J'},
    {'rank': 5, 'name': 'Lisa M.', 'points': 1580, 'reports': 28, 'avatar': 'L'},
    {'rank': 6, 'name': 'Tom W.', 'points': 1420, 'reports': 25, 'avatar': 'T'},
    {'rank': 7, 'name': 'Anna P.', 'points': 1350, 'reports': 24, 'avatar': 'A'},
    {'rank': 8, 'name': 'Chris B.', 'points': 1280, 'reports': 22, 'avatar': 'C'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets. all(widget.responsive.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildYourRankCard(),
                SizedBox(height: widget.responsive.largePadding),
                _buildTabBar(),
                SizedBox(height: widget.responsive.padding),
                _buildTopThree(),
                SizedBox(height: widget.responsive.padding),
                _buildLeadersList(),
                SizedBox(height: widget.responsive.dimension(80)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
        expandedHeight: widget.responsive.isMicroScreen
            ? 60.0
        : widget.responsive.isNanoScreen
    ? 80.0
        : widget.responsive.dimension(120) + widget.responsive.safePaddingTop,
    pinned: true,
    backgroundColor: const Color(0xFF2196F3),
    automaticallyImplyLeading: false,
    flexibleSpace: FlexibleSpaceBar(
    background: Container(
    decoration: const BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    Color(0xFF1565C0),
    Color(0xFF2196F3),
    Color(0xFF42A5F5),
    ],
    ),
    ),
    child: SafeArea(
    child: Padding(
    padding: EdgeInsets. all(widget.responsive.padding),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
    widget.responsive.adaptiveText(
    'Leaderboard',
    micro: '📊',
    nano: 'Board',
    mini: 'Leaders',
    ),
    style: GoogleFonts.poppins(
    fontSize: widget.responsive. fontSize(24),
    fontWeight: FontWeight. bold,
    color: Colors.white,
    ),
    ),
    ),
    if (widget.responsive. showSecondaryText) ...[
    SizedBox(height: widget.responsive. microPadding),
    FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment. centerLeft,
    child: Text(
    'See how you rank against others',
    style: GoogleFonts.poppins(
    fontSize: widget.responsive.fontSize(12),
    color: Colors. white. withOpacity(0.9),
    ),
    ),
    ),
    ],
    ],
    ),
    ),
    ),
    ),
    ),
    );
  }

  Widget _buildYourRankCard() {
    return Container(
      padding: EdgeInsets. all(widget.responsive.padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF2196F3)],
        ),
        borderRadius: BorderRadius.circular(widget.responsive. largeBorderRadius),
        boxShadow: widget.responsive.showShadows
            ?  [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: widget.responsive. dimension(60),
            height: widget.responsive.dimension(60),
            decoration: BoxDecoration(
              color: Colors.white. withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                widget.userStats['userName']. toString(). isNotEmpty
                    ? widget.userStats['userName']. toString()[0].toUpperCase()
                    : 'U',
                style: GoogleFonts. poppins(
                  fontSize: widget.responsive.fontSize(24),
                  fontWeight: FontWeight. bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: widget.responsive. padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment. centerLeft,
                  child: Text(
                    'Your Rank',
                    style: GoogleFonts.poppins(
                      fontSize: widget.responsive.fontSize(12),
                      color: Colors.white. withOpacity(0.9),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment. centerLeft,
                  child: Text(
                    '#${widget.userStats['rank']}',
                    style: GoogleFonts. poppins(
                      fontSize: widget.responsive.fontSize(28),
                      fontWeight: FontWeight. bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.responsive. microPadding,
                  vertical: widget.responsive.nanoPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.white. withOpacity(0.2),
                  borderRadius: BorderRadius.circular(widget.responsive.borderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize. min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: Colors.amber,
                      size: widget.responsive. iconSize(14),
                    ),
                    SizedBox(width: widget.responsive.nanoPadding),
                    Text(
                      '${widget.userStats['points']} pts',
                      style: GoogleFonts.poppins(
                        fontSize: widget.responsive.fontSize(12),
                        fontWeight: FontWeight. w600,
                        color: Colors. white,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.responsive. showSecondaryText) ...[
                SizedBox(height: widget.responsive.microPadding),
                Text(
                  '${widget.userStats['totalReports']} reports',
                  style: GoogleFonts.poppins(
                    fontSize: widget.responsive.fontSize(11),
                    color: Colors.white. withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey. withOpacity(0.1),
        borderRadius: BorderRadius.circular(widget.responsive. borderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius. circular(widget.responsive.borderRadius),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(
          fontSize: widget.responsive.fontSize(12),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: widget.responsive. fontSize(12),
          fontWeight: FontWeight. w500,
        ),
        tabs: [
          Tab(text: widget.responsive.adaptiveText('Weekly', micro: 'W', nano: 'Week')),
          Tab(text: widget. responsive.adaptiveText('Monthly', micro: 'M', nano: 'Month')),
          Tab(text: widget.responsive.adaptiveText('All Time', micro: 'A', nano: 'All')),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    if (_weeklyLeaders. length < 3) return const SizedBox. shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place
        _buildTopThreeItem(_weeklyLeaders[1], 2, Colors.grey[400]! ),
        // 1st place
        _buildTopThreeItem(_weeklyLeaders[0], 1, const Color(0xFFFFD700)),
        // 3rd place
        _buildTopThreeItem(_weeklyLeaders[2], 3, const Color(0xFFCD7F32)),
      ],
    );
  }

  Widget _buildTopThreeItem(Map<String, dynamic> user, int rank, Color color) {
    final isFirst = rank == 1;
    final size = isFirst
        ? widget.responsive.dimension(80)
        : widget.responsive.dimension(65);
    final podiumHeight = isFirst
        ? widget.responsive.dimension(60)
        : rank == 2
        ? widget. responsive.dimension(45)
        : widget.responsive.dimension(35);

    return Column(
      mainAxisSize: MainAxisSize. min,
      children: [
        // Crown for first place
        if (isFirst && widget.responsive.showIcons)
          Icon(
            Icons. emoji_events_rounded,
            color: const Color(0xFFFFD700),
            size: widget.responsive.iconSize(28),
          ),
        SizedBox(height: widget.responsive.nanoPadding),

        // Avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color. withOpacity(0.8), color],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
            boxShadow: widget.responsive.showShadows
                ? [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Center(
            child: Text(
              user['avatar'],
              style: GoogleFonts.poppins(
                fontSize: widget.responsive.fontSize(isFirst ? 28 : 22),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: widget. responsive.microPadding),

        // Name
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            widget.responsive.adaptiveText(
              user['name'],
              micro: user['avatar'],
              nano: user['name']. toString().split(' ')[0],
            ),
            style: GoogleFonts.poppins(
              fontSize: widget.responsive.fontSize(12),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        // Points
        if (widget.responsive. showSecondaryText)
          Text(
            '${user['points']} pts',
            style: GoogleFonts.poppins(
              fontSize: widget.responsive.fontSize(10),
              color: Colors.grey[600],
            ),
          ),

        SizedBox(height: widget.responsive.microPadding),

        // Podium
        Container(
          width: widget.responsive.dimension(60),
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color],
            ),
            borderRadius: BorderRadius. vertical(
              top: Radius.circular(widget. responsive.borderRadius),
            ),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.poppins(
                fontSize: widget.responsive.fontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Rankings',
          micro: '#',
          nano: 'Rank',
          responsive: widget.responsive,
        ),
        SizedBox(height: widget.responsive.padding),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _weeklyLeaders. length,
          separatorBuilder: (context, index) => SizedBox(height: widget.responsive.microPadding),
          itemBuilder: (context, index) {
            final user = _weeklyLeaders[index];
            return _buildLeaderListItem(user);
          },
        ),
      ],
    );
  }

  Widget _buildLeaderListItem(Map<String, dynamic> user) {
    final isTopThree = user['rank'] <= 3;
    final rankColor = user['rank'] == 1
        ? const Color(0xFFFFD700)
        : user['rank'] == 2
        ? Colors.grey[400]!
        : user['rank'] == 3
        ? const Color(0xFFCD7F32)
        : Colors.grey[600]!;

    return Container(
      decoration: BoxDecoration(
        color: isTopThree ? rankColor. withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(widget.responsive. borderRadius),
        border: Border.all(
          color: isTopThree ? rankColor.withOpacity(0.3) : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: widget. responsive.showShadows
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.responsive.padding),
        child: Row(
          children: [
            // Rank
            Container(
              width: widget.responsive.dimension(35),
              height: widget.responsive.dimension(35),
              decoration: BoxDecoration(
                color: rankColor. withOpacity(0.15),
                borderRadius: BorderRadius.circular(widget.responsive. borderRadius),
              ),
              child: Center(
                child: Text(
                  '#${user['rank']}',
                  style: GoogleFonts.poppins(
                    fontSize: widget.responsive. fontSize(12),
                    fontWeight: FontWeight. bold,
                    color: rankColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: widget. responsive.padding),

            // Avatar
            Container(
              width: widget. responsive.dimension(40),
              height: widget.responsive.dimension(40),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user['avatar'],
                  style: GoogleFonts.poppins(
                    fontSize: widget.responsive.fontSize(16),
                    fontWeight: FontWeight. bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: widget.responsive.padding),

            // Name and reports
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment. centerLeft,
                    child: Text(
                      user['name'],
                      style: GoogleFonts.poppins(
                        fontSize: widget.responsive. fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (widget. responsive.showSecondaryText)
                    Text(
                      '${user['reports']} reports',
                      style: GoogleFonts.poppins(
                        fontSize: widget. responsive.fontSize(11),
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

            // Points
            Container(
              padding: EdgeInsets. symmetric(
                horizontal: widget.responsive. microPadding,
                vertical: widget.responsive.nanoPadding,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800). withOpacity(0.1),
                borderRadius: BorderRadius.circular(widget. responsive.borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.responsive. showIcons)
                    Icon(
                      Icons.stars_rounded,
                      color: const Color(0xFFFF9800),
                      size: widget.responsive.iconSize(14),
                    ),
                  if (widget.responsive. showIcons) SizedBox(width: widget.responsive.nanoPadding),
                  Text(
                    '${user['points']}',
                    style: GoogleFonts.poppins(
                      fontSize: widget.responsive.fontSize(12),
                      fontWeight: FontWeight. w600,
                      color: const Color(0xFFFF9800),
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