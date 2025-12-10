import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';
import 'package:neat_now/widgets/dashboard/components/stat_card.dart';
import 'package:neat_now/widgets/dashboard/components/quick_action_card.dart';
import 'package:neat_now/widgets/dashboard/components/recent_report_card.dart';
import 'package:neat_now/widgets/dashboard/components/section_header.dart';

/// HomeTab - Main home screen content
/// Implements FR-U3: Report waste using camera
class HomeTab extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> userStats;
  final bool isDemoMode;
  final VoidCallback onNavigateToCamera;
  final VoidCallback onRefresh;
  final ResponsiveData responsive;

  const HomeTab({
    super. key,
    required this.userData,
    required this.userStats,
    required this.isDemoMode,
    required this.onNavigateToCamera,
    required this.onRefresh,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: const Color(0xFF4CAF50),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(responsive.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  // Demo mode indicator
                  if (isDemoMode) _buildDemoModeIndicator(),

                  // Welcome section
                  _buildWelcomeSection(),
                  SizedBox(height: responsive.padding),

                  // Stats overview
                  _buildStatsSection(),
                  SizedBox(height: responsive.largePadding),

                  // Quick actions
                  _buildQuickActionsSection(context),
                  SizedBox(height: responsive.largePadding),

                  // Recent reports
                  _buildRecentReportsSection(),

                  // Bottom padding for FAB
                  SizedBox(height: responsive.dimension(80)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
        expandedHeight: responsive.isMicroScreen
            ? 60.0
        : responsive.isNanoScreen
    ? 80.0
        : responsive.dimension(140) + responsive.safePaddingTop,
    pinned: true,
    backgroundColor: const Color(0xFF1B5E20),
    automaticallyImplyLeading: false,
    flexibleSpace: FlexibleSpaceBar(
    background: Container(
    decoration: const BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    Color(0xFF0A3D2C),
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    ],
    ),
    ),
    child: SafeArea(
    child: Padding(
    padding: EdgeInsets. all(responsive.padding),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Text(
    responsive.adaptiveText(
    'Hello, ${userStats['userName']. toString(). split(' ')[0]}!  👋',
    micro: '👋',
    nano: 'Hi! ',
    mini: 'Hello!',
    ),
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(24),
    fontWeight: FontWeight. bold,
    color: Colors.white,
    ),
    ),
    ),
    if (responsive.showSecondaryText) ...[
    SizedBox(height: responsive.microPadding),
    FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment. centerLeft,
    child: Text(
    'Let\'s make our city cleaner today!',
    style: GoogleFonts.poppins(
    fontSize: responsive. fontSize(14),
    color: Colors.white. withOpacity(0.9),
    ),
    ),
    ),
    ],
    ],
    ),
    ),
    // Notification icon
    if (responsive.showIcons)
    Container(
    padding: EdgeInsets. all(responsive.microPadding),
    decoration: BoxDecoration(
    color: Colors. white. withOpacity(0.15),
    borderRadius: BorderRadius. circular(responsive.borderRadius),
    ),
    child: Icon(
    Icons. notifications_rounded,
    color: Colors.white,
    size: responsive.iconSize(24),
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    );
  }

  Widget _buildDemoModeIndicator() {
    return Container(
      margin: EdgeInsets. only(bottom: responsive.padding),
      padding: EdgeInsets.symmetric(
        horizontal: responsive. padding,
        vertical: responsive.microPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.orange. withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive. borderRadius),
        border: Border.all(color: Colors. orange. withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons. info_outline_rounded,
            color: Colors.orange,
            size: responsive.iconSize(18),
          ),
          SizedBox(width: responsive.microPadding),
          Expanded(
            child: Text(
              responsive.adaptiveText(
                '🔧 Demo Mode - Data is stored locally',
                micro: '🔧',
                nano: 'Demo',
                mini: 'Demo Mode',
              ),
              style: GoogleFonts.poppins(
                fontSize: responsive.fontSize(12),
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
        padding: EdgeInsets.all(responsive.padding),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          boxShadow: responsive.showShadows
              ? [
            BoxShadow(
              color: const Color(0xFF4CAF50). withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
        Expanded(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment. centerLeft,
          child: Text(
            responsive.adaptiveText(
              'Report Waste Now',
              micro: '📷',
              nano: 'Report',
              mini: 'Report Now',
            ),
            style: GoogleFonts. poppins(
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight. bold,
              color: Colors.white,
            ),
          ),
        ),
        if (responsive.showSecondaryText) ...[
    SizedBox(height: responsive.microPadding),
    Text(
    'Take a photo of waste in your area',
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(12),
    color: Colors.white. withOpacity(0.9),
    ),
    ),
    ],
    SizedBox(height: responsive.padding),
    GestureDetector(
    onTap: onNavigateToCamera,
    child: Container(
    padding: EdgeInsets. symmetric(
    horizontal: responsive.padding,
    vertical: responsive.microPadding,
    ),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(responsive.borderRadius),
    ),
    child: Row(
    mainAxisSize: MainAxisSize. min,
    children: [
    Icon(
    Icons.camera_alt_rounded,
    color: const Color(0xFF2E7D32),
    size: responsive.iconSize(18),
    ),
    if (responsive.showSecondaryText) ...[
    SizedBox(width: responsive.microPadding),
    Text(
    'Open Camera',
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(13),
    fontWeight: FontWeight. w600,
    color: const Color(0xFF2E7D32),
    ),
    ),
    ],
    ],
    ),
    ),
    ),
    ],
    ),
    ),
    if (responsive.showDetailedContent)
    Icon(
    Icons. eco_rounded,
    color: Colors.white. withOpacity(0.3),
    size: responsive.dimension(60),
    ),
    ],
    ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your Impact',
          micro: '📊',
          nano: 'Stats',
          mini: 'Impact',
          responsive: responsive,
        ),
        SizedBox(height: responsive.padding),
        GridView.count(
          crossAxisCount: responsive.isMicroScreen ? 2 : 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: responsive.cardAspectRatio,
          crossAxisSpacing: responsive.microPadding,
          mainAxisSpacing: responsive.microPadding,
          children: [
            StatCard(
              label: 'Reports',
              value: userStats['totalReports']. toString(),
              icon: Icons.assignment_rounded,
              color: Colors.blue,
              responsive: responsive,
            ),
            StatCard(
              label: 'Resolved',
              value: userStats['resolved'].toString(),
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              responsive: responsive,
            ),
            StatCard(
              label: 'Points',
              value: userStats['points'].toString(),
              icon: Icons.stars_rounded,
              color: Colors.amber,
              responsive: responsive,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final actions = [
      {
        'icon': Icons.camera_alt_rounded,
        'label': 'Report',
        'color': const Color(0xFF4CAF50),
        'onTap': onNavigateToCamera,
      },
      {
        'icon': Icons.history_rounded,
        'label': 'History',
        'color': Colors.blue,
        'onTap': () => _showComingSoon(context, 'History'),
      },
      {
        'icon': Icons.map_rounded,
        'label': 'Map',
        'color': Colors.orange,
        'onTap': () => _showComingSoon(context, 'Map'),
      },
      {
        'icon': Icons.help_rounded,
        'label': 'Help',
        'color': Colors.purple,
        'onTap': () => _showComingSoon(context, 'Help'),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Quick Actions',
          micro: '⚡',
          nano: 'Quick',
          mini: 'Actions',
          responsive: responsive,
        ),
        SizedBox(height: responsive.padding),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: actions.map((action) {
            return QuickActionCard(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
              responsive: responsive,
            );
          }). toList(),
        ),
      ],
    );
  }

  Widget _buildRecentReportsSection() {
    // Demo recent reports
    final recentReports = [
      {
        'title': 'Street Waste',
        'location': 'Main Street',
        'status': 'pending',
        'time': '2 hours ago',
      },
      {
        'title': 'Park Debris',
        'location': 'Central Park',
        'status': 'resolved',
        'time': '1 day ago',
      },
      {
        'title': 'Plastic Waste',
        'location': 'Beach Area',
        'status': 'in_progress',
        'time': '2 days ago',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment. start,
      children: [
        SectionHeader(
          title: 'Recent Reports',
          micro: '📋',
          nano: 'Recent',
          mini: 'Reports',
          responsive: responsive,
          showViewAll: true,
          onViewAll: () {},
        ),
        SizedBox(height: responsive.padding),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentReports.length,
          separatorBuilder: (context, index) => SizedBox(height: responsive.microPadding),
          itemBuilder: (context, index) {
            final report = recentReports[index];
            return RecentReportCard(
              title: report['title'] as String,
              location: report['location'] as String,
              status: report['status'] as String,
              time: report['time'] as String,
              responsive: responsive,
            );
          },
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadius),
        ),
      ),
    );
  }
}