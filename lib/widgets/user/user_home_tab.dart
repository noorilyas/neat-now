import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:neat_now/screens/user_dashboard.dart';
import 'package:neat_now/widgets/user/responsive_user_helper.dart';

/// ==================== USER HOME TAB ====================
class UserHomeTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final UserResponsiveData responsive;
  final VoidCallback onViewReports;
  final VoidCallback onViewLeaderboard;
  final VoidCallback onReportWaste;

  const UserHomeTab({
    super.key,
    required this.userData,
    required this. responsive,
    required this.onViewReports,
    required this.onViewLeaderboard,
    required this.onReportWaste,
  });

  @override
  State<UserHomeTab> createState() => _UserHomeTabState();
}

class _UserHomeTabState extends State<UserHomeTab> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;
  late AnimationController _shimmerController;

  late Animation<double> _headerFadeAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _shimmerAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  // Data getters
  String get _name => widget.userData['name'] ?? 'User';
  String get _firstName => _name.split(' ').first;
  int get _totalReports => widget.userData['totalReports'] ??  0;
  int get _verifiedReports => widget. userData['verifiedReports'] ?? 0;
  int get _rank => widget. userData['rank'] ??  0;
  String?  get _badge => widget.userData['badge'];
  String? get _profileImage => widget.userData['profileImage'];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
    _startAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFadeAnimation = CurvedAnimation(parent: _headerController, curve: Curves. easeOutQuart);

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: 0, end: 1). animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _statsController.forward();
  }

  void _onScroll() {
    if (mounted) setState(() => _scrollOffset = _scrollController. offset);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
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

        // Stats Cards
        SliverToBoxAdapter(child: _buildStatsSection(r)),

        // Quick Actions
        SliverToBoxAdapter(child: _buildQuickActions(r)),

        // Recent Activity
        SliverToBoxAdapter(child: _buildRecentActivity(r)),

        // Tips Section
        SliverToBoxAdapter(child: _buildTipsSection(r)),

        // Bottom padding for nav bar
        SliverToBoxAdapter(child: SizedBox(height: r.safePaddingBottom + 100)),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(UserResponsiveData r) {
    return FadeTransition(
      opacity: _headerFadeAnimation,
      child: Container(
        padding: EdgeInsets. fromLTRB(r.padding, r.safePaddingTop + r.padding, r.padding, r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              UserDesign. primaryTeal.withOpacity(0.1),
              UserDesign.primaryTealLight.withOpacity(0.05),
              UserDesign.surfaceLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                _buildAvatar(r),
                SizedBox(width: r.microPadding),

                // Greeting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: GoogleFonts. inter(
                          fontSize: r.captionM,
                          color: UserDesign. textSecondary,
                        ),
                      ),
                      Text(
                        _firstName,
                        style: GoogleFonts.inter(
                          fontSize: r.headingM,
                          fontWeight: FontWeight.w800,
                          color: UserDesign. textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rank Badge
                if (_rank > 0) _buildRankBadge(r),

                SizedBox(width: r.microPadding),

                // Notification Bell
                _buildNotificationButton(r),
              ],
            ),

            SizedBox(height: r.padding),

            // Welcome Card
            _buildWelcomeCard(r),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserResponsiveData r) {
    final size = r.dimension(56);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: UserDesign.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: _profileImage != null
              ? Image.network(
            _profileImage!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(r, size),
          )
              : _buildAvatarPlaceholder(r, size),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(UserResponsiveData r, double size) {
    return Container(
      color: UserDesign. surfaceLight,
      child: Center(
        child: Text(
          _name. isNotEmpty ? _name[0]. toUpperCase() : '? ',
          style: GoogleFonts. inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight. w700,
            color: UserDesign.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(UserResponsiveData r) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeLabel;

    if (_rank == 1) {
      badgeColor = UserDesign.platinum;
      badgeIcon = Icons.diamond_rounded;
      badgeLabel = '#1';
    } else if (_rank == 2) {
      badgeColor = UserDesign.gold;
      badgeIcon = Icons.workspace_premium_rounded;
      badgeLabel = '#2';
    } else if (_rank == 3) {
      badgeColor = UserDesign.silver;
      badgeIcon = Icons.military_tech_rounded;
      badgeLabel = '#3';
    } else {
      badgeColor = UserDesign. textTertiary;
      badgeIcon = Icons.tag_rounded;
      badgeLabel = '#$_rank';
    }

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
          decoration: BoxDecoration(
            gradient: _rank <= 3
                ? LinearGradient(colors: [badgeColor, badgeColor.withOpacity(0.7)])
                : null,
            color: _rank <= 3 ? null : UserDesign.surfaceLight,
            borderRadius: BorderRadius.circular(r. pillBorderRadius),
            boxShadow: _rank <= 3 ? UserDesign. glowShadow(badgeColor) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize. min,
            children: [
              Icon(badgeIcon, size: r.iconSize(16), color: _rank <= 3 ? Colors.white : badgeColor),
              SizedBox(width: r.atomicPadding),
              Text(
                badgeLabel,
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight. w700,
                  color: _rank <= 3 ? Colors. white : UserDesign.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton(UserResponsiveData r) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Open notifications
      },
      child: Container(
        padding: EdgeInsets. all(r.microPadding),
        decoration: BoxDecoration(
          color: UserDesign.surfacePure,
          borderRadius: BorderRadius.circular(r. borderRadius),
          boxShadow: UserDesign.softShadow,
        ),
        child: Stack(
          children: [
            Icon(Icons.notifications_rounded, color: UserDesign.textSecondary, size: r.iconSize(24)),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: r.dimension(8),
                height: r.dimension(8),
                decoration: BoxDecoration(
                  color: UserDesign.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: UserDesign.surfacePure, width: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(UserResponsiveData r) {
    return GestureDetector(
      onTap: widget.onReportWaste,
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: UserDesign. primaryGradient,
          borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
          boxShadow: UserDesign. glowShadow(UserDesign. primaryTeal),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep Your City Clean!  🌿',
                    style: GoogleFonts.inter(
                      fontSize: r. bodyM,
                      fontWeight: FontWeight. w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: r.nanoPadding),
                  Text(
                    'Spotted waste? Report it now and help us keep the environment clean.',
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      color: Colors.white. withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: r.microPadding),
                  Container(
                    padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
                    decoration: BoxDecoration(
                      color: Colors. white,
                      borderRadius: BorderRadius.circular(r. pillBorderRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_rounded, size: r. iconSize(16), color: UserDesign.primaryTeal),
                        SizedBox(width: r.nanoPadding),
                        Text(
                          'Report Waste',
                          style: GoogleFonts.inter(
                            fontSize: r.captionM,
                            fontWeight: FontWeight. w700,
                            color: UserDesign.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: r.microPadding),
            Container(
              padding: EdgeInsets.all(r.padding),
              decoration: BoxDecoration(
                color: Colors.white. withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_a_photo_rounded, size: r.iconSize(32), color: Colors. white),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now(). hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ==================== STATS SECTION ====================
  Widget _buildStatsSection(UserResponsiveData r) {
    return Padding(
      padding: EdgeInsets. symmetric(horizontal: r. padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets. all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: UserDesign.info. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(Icons.insights_rounded, color: UserDesign. info, size: r. iconSize(18)),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Your Impact',
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight. w700,
                  color: UserDesign.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          Row(
            children: [
              Expanded(child: _buildStatCard(r, 'Total Reports', _totalReports, Icons.assignment_rounded, UserDesign.info)),
              SizedBox(width: r.microPadding),
              Expanded(child: _buildStatCard(r, 'Verified', _verifiedReports, Icons.verified_rounded, UserDesign.success)),
              SizedBox(width: r.microPadding),
              Expanded(child: _buildStatCard(r, 'Rank', _rank, Icons. leaderboard_rounded, UserDesign.purple)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(UserResponsiveData r, String label, int value, IconData icon, Color color) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        final animatedValue = (value * _statsAnimation.value). round();
        return Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            color: UserDesign.surfacePure,
            borderRadius: BorderRadius.circular(r. largeBorderRadius),
            boxShadow: UserDesign. softShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: color. withOpacity(0.1),
                  borderRadius: BorderRadius. circular(r.smallBorderRadius),
                ),
                child: Icon(icon, color: color, size: r.iconSize(20)),
              ),
              SizedBox(height: r.nanoPadding),
              Text(
                label == 'Rank' ? '#$animatedValue' : '$animatedValue',
                style: GoogleFonts.inter(
                  fontSize: r.headingXS,
                  fontWeight: FontWeight. w800,
                  color: UserDesign.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: r.captionXS,
                  color: UserDesign.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== QUICK ACTIONS ====================
  Widget _buildQuickActions(UserResponsiveData r) {
    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: UserDesign. warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(Icons.flash_on_rounded, color: UserDesign.warning, size: r.iconSize(18)),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Quick Actions',
                style: GoogleFonts. inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w700,
                  color: UserDesign.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r. microPadding),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  r,
                  icon: Icons.camera_alt_rounded,
                  label: 'Report Waste',
                  color: UserDesign. primaryTeal,
                  onTap: widget.onReportWaste,
                ),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: _buildActionCard(
                  r,
                  icon: Icons.assignment_rounded,
                  label: 'My Reports',
                  color: UserDesign.info,
                  onTap: widget.onViewReports,
                ),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: _buildActionCard(
                  r,
                  icon: Icons.leaderboard_rounded,
                  label: 'Leaderboard',
                  color: UserDesign.purple,
                  onTap: widget.onViewLeaderboard,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      UserResponsiveData r, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback. lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          color: UserDesign.surfacePure,
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          boxShadow: UserDesign. softShadow,
          border: Border.all(color: color. withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                borderRadius: BorderRadius. circular(r.borderRadius),
                boxShadow: UserDesign.glowShadow(color),
              ),
              child: Icon(icon, color: Colors.white, size: r.iconSize(24)),
            ),
            SizedBox(height: r. nanoPadding),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: r.captionXS,
                fontWeight: FontWeight. w600,
                color: UserDesign.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RECENT ACTIVITY ====================
  Widget _buildRecentActivity(UserResponsiveData r) {
    final recentReports = [
      _RecentReport('Plastic Waste', 'Pending', DateTime.now().subtract(const Duration(hours: 2)), UserDesign.warning),
      _RecentReport('Organic Waste', 'Assigned', DateTime.now(). subtract(const Duration(days: 1)), UserDesign.info),
      _RecentReport('Mixed Waste', 'Resolved', DateTime.now(). subtract(const Duration(days: 3)), UserDesign.success),
    ];

    return Padding(
      padding: EdgeInsets. symmetric(horizontal: r. padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r. nanoPadding),
                decoration: BoxDecoration(
                  color: UserDesign.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(Icons.history_rounded, color: UserDesign.success, size: r. iconSize(18)),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Text(
                  'Recent Activity',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: widget.onViewReports,
                child: Text(
                  'View All',
                  style: GoogleFonts. inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight. w600,
                    color: UserDesign.primaryTeal,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          Container(
            decoration: BoxDecoration(
              color: UserDesign.surfacePure,
              borderRadius: BorderRadius.circular(r. largeBorderRadius),
              boxShadow: UserDesign.softShadow,
            ),
            child: Column(
              children: recentReports. asMap().entries.map((entry) {
                final report = entry.value;
                final isLast = entry.key == recentReports.length - 1;
                return Column(
                  children: [
                    _buildRecentReportItem(r, report),
                    if (! isLast) Divider(height: 1, color: UserDesign.surfaceOverlay, indent: r.padding, endIndent: r. padding),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportItem(UserResponsiveData r, _RecentReport report) {
    return Padding(
      padding: EdgeInsets. all(r.microPadding),
      child: Row(
        children: [
          Container(
            width: r.dimension(44),
            height: r.dimension(44),
            decoration: BoxDecoration(
              color: report.color. withOpacity(0.1),
              borderRadius: BorderRadius.circular(r. borderRadius),
            ),
            child: Icon(Icons.delete_rounded, color: report. color, size: r.iconSize(22)),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.type,
                  style: GoogleFonts. inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w600,
                    color: UserDesign.textPrimary,
                  ),
                ),
                Text(
                  _formatTimeAgo(report. date),
                  style: GoogleFonts.inter(
                    fontSize: r. captionXS,
                    color: UserDesign. textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.atomicPadding),
            decoration: BoxDecoration(
              color: report.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: r.dimension(6),
                  height: r.dimension(6),
                  decoration: BoxDecoration(color: report.color, shape: BoxShape.circle),
                ),
                SizedBox(width: r.atomicPadding),
                Text(
                  report.status,
                  style: GoogleFonts.inter(
                    fontSize: r. captionXS,
                    fontWeight: FontWeight. w600,
                    color: report.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TIPS SECTION ====================
  Widget _buildTipsSection(UserResponsiveData r) {
    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: UserDesign. purple. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(Icons.lightbulb_rounded, color: UserDesign. purple, size: r.iconSize(18)),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Eco Tips',
                style: GoogleFonts. inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w700,
                  color: UserDesign.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r. microPadding),
          Container(
            padding: EdgeInsets. all(r.padding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [UserDesign.purple. withOpacity(0.1), UserDesign.purple.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(r.largeBorderRadius),
              border: Border.all(color: UserDesign.purple.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets. all(r.microPadding),
                  decoration: BoxDecoration(
                    color: UserDesign.purple,
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                  child: Icon(Icons.eco_rounded, color: Colors.white, size: r.iconSize(24)),
                ),
                SizedBox(width: r.microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Did you know?',
                        style: GoogleFonts.inter(
                          fontSize: r.captionM,
                          fontWeight: FontWeight.w700,
                          color: UserDesign. purple,
                        ),
                      ),
                      Text(
                        'One plastic bottle can take up to 450 years to decompose.  Help by reporting plastic waste!',
                        style: GoogleFonts.inter(
                          fontSize: r.captionS,
                          color: UserDesign. textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now(). difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _RecentReport {
  final String type;
  final String status;
  final DateTime date;
  final Color color;

  _RecentReport(this.type, this.status, this. date, this.color);
}