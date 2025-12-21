import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';
import 'package:neat_now/widgets/dashboard/components/section_header.dart';

/// AwardsTab - Displays user achievements and badges
/// Implements FR-U6: Gamification features
class AwardsTab extends StatelessWidget {
  final Map<String, dynamic> userStats;
  final ResponsiveData responsive;

  const AwardsTab({
    super.key,
    required this.userStats,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets. all(responsive.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPointsCard(),
                SizedBox(height: responsive.largePadding),
                _buildBadgesSection(),
                SizedBox(height: responsive.largePadding),
                _buildAchievementsSection(),
                SizedBox(height: responsive.dimension(80)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
        expandedHeight: responsive.isMicroScreen
            ? 60.0
            : responsive. isNanoScreen
            ? 80.0
        : responsive.dimension(120) + responsive.safePaddingTop,
    pinned: true,
    backgroundColor: const Color(0xFFFF9800),
    automaticallyImplyLeading: false,
    flexibleSpace: FlexibleSpaceBar(
    background: Container(
    decoration: const BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    Color(0xFFE65100),
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
    ],
    ),
    ),
    child: SafeArea(
    child: Padding(
    padding: EdgeInsets.all(responsive.padding),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
    responsive.adaptiveText(
    'Awards & Badges',
    micro: '🏆',
    nano: 'Awards',
    mini: 'Awards',
    ),
    style: GoogleFonts. poppins(
    fontSize: responsive.fontSize(24),
    fontWeight: FontWeight. bold,
    color: Colors.white,
    ),
    ),
    ),
    if (responsive. showSecondaryText) ...[
    SizedBox(height: responsive.microPadding),
    FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment. centerLeft,
    child: Text(
    'Your achievements and recognition',
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(12),
    color: Colors.white. withOpacity(0.9),
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

  Widget _buildPointsCard() {
    return Container(
      padding: EdgeInsets.all(responsive.largePadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius. circular(responsive.largeBorderRadius),
        boxShadow: responsive.showShadows
            ?  [
          BoxShadow(
            color: const Color(0xFFFF9800).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPointsItem(
            icon: Icons.stars_rounded,
            value: userStats['points']. toString(),
            label: 'Total Points',
          ),
          Container(
            width: 1,
            height: responsive.dimension(50),
            color: Colors.white.withOpacity(0.3),
          ),
          _buildPointsItem(
            icon: Icons. trending_up_rounded,
            value: '#${userStats['rank']}',
            label: 'Your Rank',
          ),
          Container(
            width: 1,
            height: responsive. dimension(50),
            color: Colors. white.withOpacity(0.3),
          ),
          _buildPointsItem(
            icon: Icons.military_tech_rounded,
            value: userStats['level'],
            label: 'Level',
          ),
        ],
      ),
    );
  }

  Widget _buildPointsItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        if (responsive.showIcons)
          Icon(
            icon,
            color: Colors.white,
            size: responsive.iconSize(24),
          ),
        if (responsive.showIcons) SizedBox(height: responsive.microPadding),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts. poppins(
              fontSize: responsive. fontSize(18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        if (responsive.showSecondaryText)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts. poppins(
                fontSize: responsive. fontSize(10),
                color: Colors.white. withOpacity(0.9),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {'icon': Icons.eco_rounded, 'name': 'Eco Starter', 'earned': true, 'color': Colors.green},
      {'icon': Icons.flash_on_rounded, 'name': 'Quick Reporter', 'earned': true, 'color': Colors.amber},
      {'icon': Icons.location_city_rounded, 'name': 'City Hero', 'earned': true, 'color': Colors.blue},
      {'icon': Icons.whatshot_rounded, 'name': 'On Fire', 'earned': false, 'color': Colors.red},
      {'icon': Icons.verified_rounded, 'name': 'Verified', 'earned': false, 'color': Colors.purple},
      {'icon': Icons. diamond_rounded, 'name': 'Diamond', 'earned': false, 'color': Colors.cyan},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Badges',
          micro: '🎖️',
          nano: 'Badge',
          responsive: responsive,
        ),
        SizedBox(height: responsive.padding),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsive.gridColumns,
            crossAxisSpacing: responsive.microPadding,
            mainAxisSpacing: responsive.microPadding,
            childAspectRatio: 0.9,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return _buildBadgeCard(
              icon: badge['icon'] as IconData,
              name: badge['name'] as String,
              earned: badge['earned'] as bool,
              color: badge['color'] as Color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required IconData icon,
    required String name,
    required bool earned,
    required Color color,
  }) {
    return Container(
        decoration: BoxDecoration(
          color: earned ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(responsive.borderRadius),
          border: Border.all(
            color: earned ?  color. withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: responsive.showShadows && earned
              ? [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets. all(responsive.microPadding),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
          Container(
          padding: EdgeInsets. all(responsive.microPadding),
          decoration: BoxDecoration(
            color: earned ? color. withOpacity(0.1) : Colors.grey. withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: earned ? color : Colors.grey,
            size: responsive.iconSize(28),
          ),
        ),
        SizedBox(height: responsive.microPadding),
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
                responsive. adaptiveText(
              name,
              micro: name.substring(0, 1),
              nano: name.split(' ')[0],
            ),
          style: GoogleFonts.poppins(
            fontSize: responsive.fontSize(11),
            fontWeight: FontWeight.w600,
            color: earned ? Colors.black87 : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
    ),
    if (! earned && responsive.showSecondaryText) ...[
    SizedBox(height: responsive.nanoPadding),
    Icon(
    Icons. lock_rounded,
    size: responsive.iconSize(12),
    color: Colors.grey,
    ),
    ],
    ],
    ),
    ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
    {
      'title': 'First Report',
    'description': 'Submit your first waste report',
    'progress': 1.0,
    'reward': '+50 pts',
    'completed': true,
    },
    {
    'title': '10 Reports',
    'description': 'Submit 10 waste reports',
    'progress': 0.8,
    'reward': '+200 pts',
    'completed': false,
    },
    {
    'title': 'Community Helper',
    'description': 'Get 5 reports resolved',
    'progress': 0.6,
    'reward': '+150 pts',
    'completed': false,
    },
    {
    'title': 'Weekly Warrior',
    'description': 'Report every day for a week',
    'progress': 0.4,
    'reward': '+300 pts',
    'completed': false,
    },
    ];

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    SectionHeader(
    title: 'Achievements',
    micro: '🎯',
    nano: 'Achieve',
    responsive: responsive,
    ),
    SizedBox(height: responsive. padding),
    ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: achievements.length,
    separatorBuilder: (context, index) => SizedBox(height: responsive.microPadding),
    itemBuilder: (context, index) {
    final achievement = achievements[index];
    return _buildAchievementCard(
    title: achievement['title'] as String,
    description: achievement['description'] as String,
    progress: achievement['progress'] as double,
    reward: achievement['reward'] as String,
    completed: achievement['completed'] as bool,
    );
    },
    ),
    ],
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String description,
    required double progress,
    required String reward,
    required bool completed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive. borderRadius),
        border: Border.all(
          color: completed
              ? const Color(0xFF4CAF50). withOpacity(0.3)
              : Colors.grey. withOpacity(0.15),
        ),
        boxShadow: responsive.showShadows
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
        padding: EdgeInsets.all(responsive.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets. all(responsive.microPadding),
                  decoration: BoxDecoration(
                    color: completed
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius. circular(responsive.borderRadius),
                  ),
                  child: Icon(
                    completed ?  Icons.check_circle_rounded : Icons.emoji_events_rounded,
                    color: completed ?  const Color(0xFF4CAF50) : Colors.grey,
                    size: responsive.iconSize(20),
                  ),
                ),
                SizedBox(width: responsive.padding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment. start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: responsive. fontSize(14),
                            fontWeight: FontWeight. w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (responsive.showSecondaryText)
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: responsive.fontSize(11),
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow. ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets. symmetric(
                    horizontal: responsive.microPadding,
                    vertical: responsive.nanoPadding,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800). withOpacity(0.1),
                    borderRadius: BorderRadius. circular(responsive.borderRadius),
                  ),
                  child: Text(
                    reward,
                    style: GoogleFonts.poppins(
                      fontSize: responsive.fontSize(10),
                      fontWeight: FontWeight. w600,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                ),
              ],
            ),
            if (! completed) ...[
              SizedBox(height: responsive.padding),
              ClipRRect(
                borderRadius: BorderRadius.circular(responsive.borderRadius),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey. withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  minHeight: responsive.dimension(6),
                ),
              ),
              SizedBox(height: responsive.nanoPadding),
              Text(
                '${(progress * 100). toInt()}% Complete',
                style: GoogleFonts.poppins(
                  fontSize: responsive.fontSize(10),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}