import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

/// ==================== DESIGN SYSTEM ====================
class LeaderboardDesign {
  // Primary Colors
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);

  // Tier Colors
  static const Color diamondPrimary = Color(0xFF00D9FF);
  static const Color diamondSecondary = Color(0xFF00B4D8);
  static const Color diamondGlow = Color(0xFF48CAE4);

  static const Color goldPrimary = Color(0xFFFFD700);
  static const Color goldSecondary = Color(0xFFFFA500);
  static const Color goldGlow = Color(0xFFFFE55C);

  static const Color silverPrimary = Color(0xFFC0C0C0);
  static const Color silverSecondary = Color(0xFFA8A8A8);
  static const Color silverGlow = Color(0xFFE8E8E8);

  static const Color bronzePrimary = Color(0xFFCD7F32);
  static const Color bronzeSecondary = Color(0xFFB87333);
  static const Color bronzeGlow = Color(0xFFDDA15E);

  // Surfaces
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);
}

/// ==================== TIER ENUM ====================
enum LeaderboardTier {
  diamond,  // 4. 5 - 5.0 rating
  gold,     // 4.0 - 4. 49 rating
  silver,   // 3.5 - 3. 99 rating
  bronze,   // 3.0 - 3.49 rating
  unranked, // Below 3.0 rating
}

extension LeaderboardTierExtension on LeaderboardTier {
  String get name {
    switch (this) {
      case LeaderboardTier.diamond: return 'Diamond';
      case LeaderboardTier.gold: return 'Gold';
      case LeaderboardTier. silver: return 'Silver';
      case LeaderboardTier.bronze: return 'Bronze';
      case LeaderboardTier.unranked: return 'Unranked';
    }
  }

  String get shortName {
    switch (this) {
      case LeaderboardTier.diamond: return 'DIA';
      case LeaderboardTier. gold: return 'GLD';
      case LeaderboardTier. silver: return 'SLV';
      case LeaderboardTier.bronze: return 'BRZ';
      case LeaderboardTier. unranked: return 'URK';
    }
  }

  IconData get icon {
    switch (this) {
      case LeaderboardTier. diamond: return Icons. diamond_rounded;
      case LeaderboardTier.gold: return Icons.workspace_premium_rounded;
      case LeaderboardTier.silver: return Icons.military_tech_rounded;
      case LeaderboardTier.bronze: return Icons.emoji_events_rounded;
      case LeaderboardTier.unranked: return Icons.star_border_rounded;
    }
  }

  Color get primaryColor {
    switch (this) {
      case LeaderboardTier.diamond: return LeaderboardDesign.diamondPrimary;
      case LeaderboardTier.gold: return LeaderboardDesign.goldPrimary;
      case LeaderboardTier. silver: return LeaderboardDesign.silverPrimary;
      case LeaderboardTier.bronze: return LeaderboardDesign.bronzePrimary;
      case LeaderboardTier.unranked: return LeaderboardDesign.textTertiary;
    }
  }

  Color get secondaryColor {
    switch (this) {
      case LeaderboardTier.diamond: return LeaderboardDesign.diamondSecondary;
      case LeaderboardTier.gold: return LeaderboardDesign.goldSecondary;
      case LeaderboardTier. silver: return LeaderboardDesign.silverSecondary;
      case LeaderboardTier.bronze: return LeaderboardDesign.bronzeSecondary;
      case LeaderboardTier.unranked: return LeaderboardDesign.textTertiary;
    }
  }

  Color get glowColor {
    switch (this) {
      case LeaderboardTier.diamond: return LeaderboardDesign.diamondGlow;
      case LeaderboardTier.gold: return LeaderboardDesign.goldGlow;
      case LeaderboardTier.silver: return LeaderboardDesign.silverGlow;
      case LeaderboardTier.bronze: return LeaderboardDesign. bronzeGlow;
      case LeaderboardTier.unranked: return LeaderboardDesign. textTertiary;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case LeaderboardTier.diamond:
        return [
          const Color(0xFF00D9FF),
          const Color(0xFF00B4D8),
          const Color(0xFF0077B6),
        ];
      case LeaderboardTier. gold:
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          const Color(0xFFFF8C00),
        ];
      case LeaderboardTier.silver:
        return [
          const Color(0xFFE8E8E8),
          const Color(0xFFC0C0C0),
          const Color(0xFFA8A8A8),
        ];
      case LeaderboardTier.bronze:
        return [
          const Color(0xFFDDA15E),
          const Color(0xFFCD7F32),
          const Color(0xFFB87333),
        ];
      case LeaderboardTier.unranked:
        return [
          LeaderboardDesign. textTertiary,
          LeaderboardDesign.textSecondary,
        ];
    }
  }

  double get minRating {
    switch (this) {
    case LeaderboardTier.diamond: return 4.5;
    case LeaderboardTier.gold: return 4.0;
    case LeaderboardTier. silver: return 3.5;
    case LeaderboardTier.bronze: return 3.0;
    case LeaderboardTier.unranked: return 0.0;
    }
  }

  double get maxRating {
    switch (this) {
    case LeaderboardTier.diamond: return 5.0;
    case LeaderboardTier.gold: return 4.49;
    case LeaderboardTier.silver: return 3.99;
    case LeaderboardTier.bronze: return 3.49;
    case LeaderboardTier.unranked: return 2.99;
    }
  }

  static LeaderboardTier fromRating(double rating) {
    if (rating >= 4.5) return LeaderboardTier. diamond;
    if (rating >= 4.0) return LeaderboardTier. gold;
    if (rating >= 3.5) return LeaderboardTier. silver;
    if (rating >= 3.0) return LeaderboardTier. bronze;
    return LeaderboardTier.unranked;
  }
}

/// ==================== LEADERBOARD PAGE ====================
class LeaderboardPage extends StatefulWidget {
  final Future<List<LeaderboardEntry>> leaderboardFuture;
  final String currentUserId;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;

  const LeaderboardPage({
    super.key,
    required this.leaderboardFuture,
    required this. currentUserId,
    required this.onRefresh,
    required this.responsive,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _podiumController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _confettiController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _podiumAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  // State
  LeaderboardTier?  _selectedTierFilter;
  String _searchQuery = '';
  bool _showOnlyCurrentUser = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _podiumController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _podiumAnimation = CurvedAnimation(
      parent: _podiumController,
      curve: Curves. easeOutBack,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _podiumController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController. dispose();
    _podiumController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _confettiController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    HapticFeedback.mediumImpact();
    _rotateController.forward(from: 0);
    _podiumController.forward(from: 0);
    widget.onRefresh();
  }

  void _filterByTier(LeaderboardTier? tier) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTierFilter = tier == _selectedTierFilter ?  null : tier;
    });
  }

  List<LeaderboardEntry> _filterEntries(List<LeaderboardEntry> entries) {
    var filtered = entries;

    // Filter by tier
    if (_selectedTierFilter != null) {
      filtered = filtered.where((e) {
        final tier = LeaderboardTierExtension.fromRating(e.rating);
        return tier == _selectedTierFilter;
      }).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) {
        return e.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by current user
    if (_showOnlyCurrentUser) {
      filtered = filtered.where((e) {
        return e.id. toString() == widget. currentUserId;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return FutureBuilder<List<LeaderboardEntry>>(
      future: widget.leaderboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(r);
        }
        if (snapshot.hasError) {
          return _buildErrorState(r, snapshot.error. toString());
        }
        if (! snapshot.hasData || snapshot.data!. isEmpty) {
          return _buildEmptyState(r);
        }

        return _buildContent(r, snapshot.data! );
      },
    );
  }

  Widget _buildContent(EmployeeResponsiveData r, List<LeaderboardEntry> entries) {
    final filteredEntries = _filterEntries(entries);
    final topThree = entries.take(3).toList();
    final currentUserEntry = entries.firstWhere(
          (e) => e.id. toString() == widget. currentUserId,
      orElse: () => entries.first,
    );
    final currentUserRank = entries.indexOf(currentUserEntry) + 1;
    final currentUserTier = LeaderboardTierExtension. fromRating(currentUserEntry.rating);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () async => _handleRefresh(),
          color: LeaderboardDesign.primaryTeal,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(r.padding),
                  child: _buildHeader(r),
                ),
              ),

              // Current User Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets. symmetric(horizontal: r. padding),
                  child: _buildCurrentUserCard(r, currentUserEntry, currentUserRank, currentUserTier),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // Top 3 Podium
              if (topThree. length >= 3)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r. padding),
                    child: _buildPodiumSection(r, topThree),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // Tier Filter
              SliverToBoxAdapter(
                child: _buildTierFilter(r, entries),
              ),

              SliverToBoxAdapter(child: SizedBox(height: r.microPadding)),

              // Search Bar (for larger screens)
              if (r.showDetailedContent)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: _buildSearchBar(r),
                  ),
                ),

              if (r.showDetailedContent)
                SliverToBoxAdapter(child: SizedBox(height: r.microPadding)),

              // Leaderboard List
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets. symmetric(horizontal: r.padding),
                  child: _buildLeaderboardSection(r, filteredEntries, entries),
                ),
              ),

              // Tier Info Cards
              if (r.showDetailedContent)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(r.padding),
                    child: _buildTierInfoSection(r),
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: r.safePaddingBottom + 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(EmployeeResponsiveData r) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r. adaptiveText('Leaderboard', nano: 'LB', micro: 'Rank', mini: 'Leaders'),
                style: GoogleFonts.inter(
                  fontSize: r.headingM,
                  fontWeight: FontWeight. w800,
                  color: LeaderboardDesign.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (r.showSecondaryText)
                Text(
                  'Compete and climb the ranks',
                  style: GoogleFonts.inter(
                    fontSize: r. captionM,
                    color: LeaderboardDesign.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: _rotateController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateController.value * 2 * math.pi,
              child: child,
            );
          },
          child: _buildIconButton(r, Icons.refresh_rounded, _handleRefresh),
        ),
      ],
    );
  }

  Widget _buildIconButton(EmployeeResponsiveData r, IconData icon, VoidCallback onTap) {
    return Material(
      color: LeaderboardDesign.primaryTeal. withOpacity(0.1),
      borderRadius: BorderRadius. circular(r.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius. circular(r.borderRadius),
        child: Container(
          width: r.buttonHeightSmall,
          height: r.buttonHeightSmall,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: r.iconSize(20),
            color: LeaderboardDesign.primaryTeal,
          ),
        ),
      ),
    );
  }

  // ==================== CURRENT USER CARD ====================
  Widget _buildCurrentUserCard(
      EmployeeResponsiveData r,
      LeaderboardEntry entry,
      int rank,
      LeaderboardTier tier,
      ) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: rank <= 3 ? _pulseAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets. all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: tier. gradientColors,
            begin: Alignment. topLeft,
            end: Alignment. bottomRight,
          ),
          borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: tier.primaryColor. withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with tier badge
                _buildUserAvatar(r, entry, tier, isLarge: true),
                SizedBox(width: r.microPadding),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (r.showMinimalText)
                            Text(
                              r.adaptiveText('Your Ranking', nano: '#', micro: 'Rank', mini: 'Your Rank'),
                              style: GoogleFonts.inter(
                                fontSize: r.captionS,
                                color: Colors.white. withOpacity(0.9),
                              ),
                            ),
                          const Spacer(),
                          _buildTierBadge(r, tier, isSmall: false),
                        ],
                      ),
                      SizedBox(height: r.atomicPadding),
                      Text(
                        entry.name,
                        style: GoogleFonts.inter(
                          fontSize: r.headingXS,
                          fontWeight: FontWeight. w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow. ellipsis,
                      ),
                    ],
                  ),
                ),

                // Rank display
                _buildRankDisplay(r, rank, tier),
              ],
            ),

            SizedBox(height: r.microPadding),

            // Stats row
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: Colors.white. withOpacity(0.15),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(r, '${entry.points}', 'Points', Icons.star_rounded),
                  _buildVerticalDivider(r),
                  _buildStatItem(r, entry.rating.toStringAsFixed(1), 'Rating', Icons.thumb_up_rounded),
                  _buildVerticalDivider(r),
                  _buildStatItem(r, '${entry.tasksCompleted}', 'Tasks', Icons.check_circle_rounded),
                ],
              ),
            ),

            // Progress to next tier
            if (r.showDetailedContent && tier != LeaderboardTier.diamond)
              _buildTierProgress(r, entry. rating, tier),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(
      EmployeeResponsiveData r,
      LeaderboardEntry entry,
      LeaderboardTier tier, {
        bool isLarge = false,
      }) {
    final size = isLarge ? r. welcomeAvatarSize : r.avatarSize;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isLarge ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: entry.profileImage != null
                ? Image.network(
              entry.profileImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(r, entry.name, size),
            )
                : _buildAvatarPlaceholder(r, entry.name, size),
          ),
        ),
        // Tier icon badge
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets. all(r.atomicPadding),
            decoration: BoxDecoration(
              color: tier.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: tier.glowColor. withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              tier. icon,
              size: r.iconSize(isLarge ? 14 : 10),
              color: tier == LeaderboardTier.silver ? LeaderboardDesign. textPrimary : Colors. white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder(EmployeeResponsiveData r, String name, double size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LeaderboardDesign. primaryTeal,
            LeaderboardDesign.primaryTealLight,
          ],
        ),
      ),
      child: Center(
        child: Text(
          name. isNotEmpty ? name[0].toUpperCase() : '? ',
          style: GoogleFonts. inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight. w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTierBadge(EmployeeResponsiveData r, LeaderboardTier tier, {bool isSmall = true}) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
            padding: EdgeInsets. symmetric(
              horizontal: isSmall ? r. nanoPadding : r.microPadding,
              vertical: r.atomicPadding,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors. white.withOpacity(0.1 + (_shimmerAnimation.value. abs() * 0.1)),
                  Colors.white.withOpacity(0.3),
                ],
                begin: Alignment(-1 + _shimmerAnimation.value, 0),
                end: Alignment(_shimmerAnimation.value, 0),
              ),
              borderRadius: BorderRadius. circular(r.pillBorderRadius),
              border: Border.all(
                color: Colors.white. withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize. min,
              children: [
              Icon(
              tier. icon,
              size: r.iconSize(isSmall ?  12 : 16),
              color: Colors.white,
            ),
            if (! isSmall || r.showShortLabels) ...[
        SizedBox(width: r.atomicPadding),
        Text(
        r.adaptiveText(tier.name, nano: tier.shortName[0], micro: tier.shortName),
        style: GoogleFonts. inter(
        fontSize: r.fontSize(isSmall ?  10 : 12),
        fontWeight: FontWeight. w700,
        color: Colors.white,
        ),
        ),
        ],
        ],
        ),
        );
      },
    );
  }

  Widget _buildRankDisplay(EmployeeResponsiveData r, int rank, LeaderboardTier tier) {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Column(
        children: [
          Text(
            '#$rank',
            style: GoogleFonts.inter(
              fontSize: r. headingM,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          if (r.showMinimalText)
            Text(
              'Rank',
              style: GoogleFonts.inter(
                fontSize: r. captionXS,
                color: Colors.white. withOpacity(0.9),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(EmployeeResponsiveData r, String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize. min,
          children: [
            if (r.showIcons)
              Icon(icon, size: r. iconSize(14), color: Colors. white. withOpacity(0.9)),
            if (r.showIcons) SizedBox(width: r.atomicPadding),
            Text(
              value,
              style: GoogleFonts. inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight. w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        if (r.showMinimalText)
          Text(
            r.adaptiveText(label, nano: label[0], micro: label. substring(0, math.min(3, label.length))),
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              color: Colors.white. withOpacity(0.8),
            ),
          ),
      ],
    );
  }

  Widget _buildVerticalDivider(EmployeeResponsiveData r) {
    return Container(
      width: 1,
      height: r.dimension(30),
      color: Colors.white. withOpacity(0.3),
    );
  }

  Widget _buildTierProgress(EmployeeResponsiveData r, double currentRating, LeaderboardTier currentTier) {
    LeaderboardTier nextTier;
    switch (currentTier) {
      case LeaderboardTier. bronze:
        nextTier = LeaderboardTier.silver;
        break;
      case LeaderboardTier.silver:
        nextTier = LeaderboardTier.gold;
        break;
      case LeaderboardTier.gold:
        nextTier = LeaderboardTier.diamond;
        break;
      default:
        return const SizedBox.shrink();
    }

    final progress = (currentRating - currentTier.minRating) / (nextTier.minRating - currentTier.minRating);
    final ratingNeeded = (nextTier.minRating - currentRating). toStringAsFixed(2);

    return Padding(
      padding: EdgeInsets. only(top: r.microPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress to ${nextTier.name}',
                style: GoogleFonts.inter(
                  fontSize: r.captionS,
                  color: Colors.white. withOpacity(0.9),
                ),
              ),
              Text(
                '+$ratingNeeded rating needed',
                style: GoogleFonts. inter(
                  fontSize: r.captionXS,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: r.nanoPadding),
          ClipRRect(
            borderRadius: BorderRadius. circular(r.pillBorderRadius),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress. clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white. withOpacity(0.3),
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

  // ==================== PODIUM SECTION ====================
  Widget _buildPodiumSection(EmployeeResponsiveData r, List<LeaderboardEntry> topThree) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFBEB),
            const Color(0xFFFEF3C7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: LeaderboardDesign. goldPrimary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section title
          Row(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: r.iconSize(24),
                color: LeaderboardDesign. goldPrimary,
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                r.adaptiveText('Top Performers', nano: 'Top', micro: 'Top 3', mini: 'Top 3'),
                style: GoogleFonts. inter(
                  fontSize: r.bodyM,
                  fontWeight: FontWeight.w700,
                  color: LeaderboardDesign. textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.padding),

          // Podium
          _buildPodium(r, topThree),
        ],
      ),
    );
  }

  Widget _buildPodium(EmployeeResponsiveData r, List<LeaderboardEntry> topThree) {
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
            animation: _podiumAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _podiumAnimation.value)),
                child: Opacity(
                  opacity: _podiumAnimation.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets. symmetric(horizontal: r.nanoPadding),
              child: Column(
                mainAxisSize: MainAxisSize. min,
                children: [
                  // Crown for first place
                  if (isFirst)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: _buildAnimatedCrown(r),
                    ),
                  if (isFirst) SizedBox(height: r.nanoPadding),

                  // Avatar
                  _buildPodiumAvatar(r, entry, tier, isFirst),
                  SizedBox(height: r. nanoPadding),

                  // Name
                  Text(
                    r.adaptiveText(
                      entry. name. split(' ').first,
                      nano: entry.name[0],
                      micro: entry.name.split(' ').first.substring(0, math.min(4, entry.name. split(' ').first.length)),
                    ),
                    style: GoogleFonts.inter(
                      fontSize: isFirst ? r.captionL : r.captionM,
                      fontWeight: FontWeight. w700,
                      color: LeaderboardDesign.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow. ellipsis,
                  ),

                  // Tier badge
                  if (r.showBadges)
                    Padding(
                      padding: EdgeInsets. only(top: r. atomicPadding),
                      child: _buildSmallTierBadge(r, tier),
                    ),

                  SizedBox(height: r.nanoPadding),

                  // Podium block
                  _buildPodiumBlock(r, entry, rankIndex, height, tier),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnimatedCrown(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                LeaderboardDesign. goldPrimary,
                LeaderboardDesign.goldGlow,
                LeaderboardDesign.goldPrimary,
              ],
              begin: Alignment(-1 + _shimmerAnimation.value, 0),
              end: Alignment(_shimmerAnimation.value, 0),
            ). createShader(bounds);
          },
          child: Icon(
            Icons. auto_awesome_rounded,
            size: r.iconSize(28),
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildPodiumAvatar(
      EmployeeResponsiveData r,
      LeaderboardEntry entry,
      LeaderboardTier tier,
      bool isFirst,
      ) {
    final size = isFirst ?  r.avatarSize * 1.3 : r.avatarSize;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        if (isFirst)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: size + 20,
                height: size + 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: tier. glowColor.withOpacity(0.3 * _pulseAnimation. value),
                      blurRadius: 20 * _pulseAnimation. value,
                      spreadRadius: 5 * (_pulseAnimation.value - 1),
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
            shape: BoxShape.circle,
            border: Border.all(
              color: tier.primaryColor,
              width: isFirst ? 4 : 3,
            ),
            boxShadow: [
              BoxShadow(
                color: tier. glowColor.withOpacity(0.5),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipOval(
            child: entry.profileImage != null
                ? Image.network(
              entry. profileImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(r, entry.name, size),
            )
                : _buildAvatarPlaceholder(r, entry.name, size),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallTierBadge(EmployeeResponsiveData r, LeaderboardTier tier) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r. nanoPadding,
        vertical: r.atomicPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tier.gradientColors),
        borderRadius: BorderRadius. circular(r.smallBorderRadius),
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
            color: tier == LeaderboardTier.silver ? LeaderboardDesign. textPrimary : Colors.white,
          ),
          SizedBox(width: r.atomicPadding),
          Text(
            tier.shortName,
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight. w700,
              color: tier == LeaderboardTier.silver ?  LeaderboardDesign. textPrimary : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumBlock(
      EmployeeResponsiveData r,
      LeaderboardEntry entry,
      int rankIndex,
      double height,
      LeaderboardTier tier,
      ) {
    final colors = [
      LeaderboardDesign.goldPrimary,
      LeaderboardDesign.silverPrimary,
      LeaderboardDesign.bronzePrimary,
    ];
    final color = colors[rankIndex];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + (rankIndex * 200)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Container(
          height: height * value,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color. withOpacity(0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(r. borderRadius),
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
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              // Rank number
              Text(
                '${rankIndex + 1}',
                style: GoogleFonts.inter(
                  fontSize: rankIndex == 0 ? r.headingM : r.headingS,
                  fontWeight: FontWeight. w900,
                  color: rankIndex == 1 ? LeaderboardDesign.textPrimary : Colors. white,
                ),
              ),
              // Points
              Container(
                margin: EdgeInsets. only(top: r.nanoPadding),
                padding: EdgeInsets. symmetric(
                  horizontal: r.nanoPadding,
                  vertical: r.atomicPadding,
                ),
                decoration: BoxDecoration(
                  color: (rankIndex == 1 ?  LeaderboardDesign.textPrimary : Colors.white).withOpacity(0.2),
                  borderRadius: BorderRadius. circular(r.smallBorderRadius),
                ),
                child: Text(
                  '${entry.points}',
                  style: GoogleFonts.inter(
                    fontSize: r. captionM,
                    fontWeight: FontWeight. w700,
                    color: rankIndex == 1 ? LeaderboardDesign.textPrimary : Colors.white,
                  ),
                ),
              ),
              // Rating
              if (r.showSecondaryText)
                Padding(
                  padding: EdgeInsets. only(top: r.atomicPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: r.iconSize(12),
                        color: (rankIndex == 1 ? LeaderboardDesign.textPrimary : Colors. white).withOpacity(0.9),
                      ),
                      SizedBox(width: r.atomicPadding),
                      Text(
                        entry.rating.toStringAsFixed(1),
                        style: GoogleFonts. inter(
                          fontSize: r.captionXS,
                          color: (rankIndex == 1 ? LeaderboardDesign. textPrimary : Colors.white).withOpacity(0.9),
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

  // ==================== TIER FILTER ====================
  Widget _buildTierFilter(EmployeeResponsiveData r, List<LeaderboardEntry> entries) {
    final tierCounts = <LeaderboardTier, int>{};
    for (final entry in entries) {
      final tier = LeaderboardTierExtension. fromRating(entry.rating);
      tierCounts[tier] = (tierCounts[tier] ?? 0) + 1;
    }

    return SizedBox(
      height: r.dimension(50),
      child: ListView(
        scrollDirection: Axis. horizontal,
        padding: EdgeInsets. symmetric(horizontal: r. padding),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildTierFilterChip(r, null, entries. length, 'All'),
          ... LeaderboardTier.values.where((t) => t != LeaderboardTier.unranked).map((tier) {
            return _buildTierFilterChip(r, tier, tierCounts[tier] ?? 0, tier.name);
          }),
        ],
      ),
    );
  }

  Widget _buildTierFilterChip(
      EmployeeResponsiveData r,
      LeaderboardTier? tier,
      int count,
      String label,
      ) {
    final isSelected = _selectedTierFilter == tier;
    final color = tier?. primaryColor ?? LeaderboardDesign.primaryTeal;

    return Padding(
        padding: EdgeInsets. only(right: r.microPadding),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap: () => _filterByTier(tier),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets. symmetric(
                    horizontal: r. microPadding,
                    vertical: r. nanoPadding,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: tier?.gradientColors ??  [color, color. withOpacity(0.7)])
                        : null,
                    color: isSelected ? null : LeaderboardDesign. surfaceWhite,
                    borderRadius: BorderRadius. circular(r.pillBorderRadius),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : color. withOpacity(0.3),
                    ),
                    boxShadow: isSelected
                        ?  [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                      mainAxisSize: MainAxisSize. min,
                      children: [
                      if (tier != null)
                  Icon(
                  tier.icon,
                  size: r.iconSize(16),
                  color: isSelected
                      ? (tier == LeaderboardTier.silver ? LeaderboardDesign.textPrimary : Colors.white)
                      : color,
                ),
                if (tier != null) SizedBox(width: r.nanoPadding),
        Text(
          r.adaptiveText(label, nano: label[0], micro: label.substring(0, math.min(3, label.length))),
          style: GoogleFonts.inter(
            fontSize: r. captionM,
            fontWeight: FontWeight. w600,
            color: isSelected
                ? (tier == LeaderboardTier.silver ?  LeaderboardDesign.textPrimary : Colors.white)
                : LeaderboardDesign. textSecondary,
          ),
        ),
        if (count > 0 && r.showBadges) ...[
    SizedBox(width: r.nanoPadding),
    Container(
    padding: EdgeInsets. symmetric(
    horizontal: r.nanoPadding,
    vertical: r.atomicPadding,
    ),
    decoration: BoxDecoration(
    color: isSelected
    ?  Colors.white.withOpacity(0.2)
        : color.withOpacity(0.1),
    borderRadius: BorderRadius. circular(r.smallBorderRadius),
    ),
    child: Text(
    '$count',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    fontWeight: FontWeight. w700,
    color: isSelected
    ? (tier == LeaderboardTier.silver ? LeaderboardDesign.textPrimary : Colors.white)
        : color,
    ),
    ),
    ),
    ],
    ],
    ),
    ),
    ),
    ),
    );
    }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r. microPadding),
      decoration: BoxDecoration(
        color: LeaderboardDesign. surfaceWhite,
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.grey. withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons. search_rounded,
            size: r.iconSize(20),
            color: LeaderboardDesign.textSecondary,
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: LeaderboardDesign.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search workers...',
                hintStyle: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  color: LeaderboardDesign.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: r.microPadding),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Icon(
                Icons.close_rounded,
                size: r.iconSize(18),
                color: LeaderboardDesign.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  // ==================== LEADERBOARD LIST ====================
  Widget _buildLeaderboardSection(
      EmployeeResponsiveData r,
      List<LeaderboardEntry> filteredEntries,
      List<LeaderboardEntry> allEntries,
      ) {
    return Container(
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        color: LeaderboardDesign.surfaceWhite,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                Icons. format_list_numbered_rounded,
                size: r.iconSize(20),
                color: LeaderboardDesign.primaryTeal,
              ),
              SizedBox(width: r.microPadding),
              Text(
                r.adaptiveText('All Rankings', nano: 'All', micro: 'Ranks', mini: 'Rankings'),
                style: GoogleFonts. inter(
                  fontSize: r.bodyM,
                  fontWeight: FontWeight.w700,
                  color: LeaderboardDesign. textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${filteredEntries.length} workers',
                style: GoogleFonts. inter(
                  fontSize: r.captionS,
                  color: LeaderboardDesign.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),

          // List
          ... filteredEntries. asMap().entries.map((entry) {
            final globalRank = allEntries.indexOf(entry.value) + 1;
            return _buildLeaderboardItem(r, entry. value, globalRank, entry.key);
          }),

          if (filteredEntries.isEmpty)
            _buildNoResultsMessage(r),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
      EmployeeResponsiveData r,
      LeaderboardEntry entry,
      int rank,
      int index,
      ) {
    final tier = LeaderboardTierExtension.fromRating(entry. rating);
    final isCurrentUser = entry.id. toString() == widget.currentUserId;

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
            onTap: () => _showUserDetails(r, entry, rank, tier),
            child: Container(
              margin: EdgeInsets. only(bottom: r.microPadding),
              padding: EdgeInsets. all(r.microPadding),
              decoration: BoxDecoration(
                gradient: isCurrentUser
                    ?  LinearGradient(
                  colors: [
                    tier.primaryColor.withOpacity(0.15),
                    tier.primaryColor.withOpacity(0.05),
                  ],
                )
                    : null,
                color: isCurrentUser ? null : LeaderboardDesign.surfaceLight,
                borderRadius: BorderRadius.circular(r.borderRadius),
                border: Border.all(
                  color: isCurrentUser
                      ? tier.primaryColor.withOpacity(0.3)
                      : Colors.transparent,
                  width: isCurrentUser ? 2 : 0,
                ),
              ),
              child: Row(
                  children: [
              // Rank
              Container(
              width: r. dimension(32),
              height: r.dimension(32),
              decoration: BoxDecoration(
                gradient: rank <= 3
                    ? LinearGradient(colors: tier.gradientColors)
                    : null,
                color: rank > 3 ? LeaderboardDesign. surfaceCard : null,
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w700,
                    color: rank <= 3
                        ? (tier == LeaderboardTier.silver ? LeaderboardDesign.textPrimary : Colors.white)
                        : LeaderboardDesign.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(width: r.microPadding),

            // Avatar
            _buildUserAvatar(r, entry, tier, isLarge: false),
            SizedBox(width: r.microPadding),

            // Name and tier
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
              children: [
              Flexible(
              child: Text(
                entry.name,
                style: GoogleFonts. inter(
                  fontSize: r.bodyS,
                  fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight. w600,
                  color: LeaderboardDesign. textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser)...[
        SizedBox(width: r.nanoPadding),
    Container(
    padding: EdgeInsets. symmetric(
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
    fontSize: r. captionXS,
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
    SizedBox(height: r.atomicPadding),
    Row(
    children: [
    _buildSmallTierBadge(r, tier),
    SizedBox(width: r.nanoPadding),
    if (r.showSecondaryText)
    Text(
    '${entry.tasksCompleted} tasks',
    style: GoogleFonts.inter(
    fontSize: r. captionXS,
    color: LeaderboardDesign. textSecondary,
    ),
    ),
    ],
    ),
    ],
    ),
    ),

    // Points and rating
    Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
    Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    Icons.star_rounded,
    size: r.iconSize(14),
    color: LeaderboardDesign. goldPrimary,
    ),
    SizedBox(width: r.atomicPadding),
    Text(
    '${entry.points}',
    style: GoogleFonts. inter(
    fontSize: r.bodyS,
    fontWeight: FontWeight. w700,
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
    Icons. chevron_right_rounded,
    size: r.iconSize(20),
    color: LeaderboardDesign.textTertiary,
    ),
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildNoResultsMessage(EmployeeResponsiveData r) {    return Container(
    padding: EdgeInsets.  all(r.largePadding),
    child: Column(
      children: [
        Icon(
          Icons. search_off_rounded,
          size: r.iconSize(48),
          color: LeaderboardDesign.textTertiary,
        ),
        SizedBox(height: r.microPadding),
        Text(
          'No workers found',
          style: GoogleFonts.inter(
            fontSize: r.  bodyM,
            fontWeight: FontWeight.  w600,
            color: LeaderboardDesign.textSecondary,
          ),
        ),
        if (r.showSecondaryText)
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.inter(
              fontSize: r.captionM,
              color: LeaderboardDesign.  textTertiary,
            ),
          ),
      ],
    ),
  );
  }

  void _showUserDetails(
      EmployeeResponsiveData r,
      LeaderboardEntry entry,
      int rank,
      LeaderboardTier tier,
      ) {
    HapticFeedback. mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _UserDetailSheet(
        entry: entry,
        rank: rank,
        tier: tier,
        responsive: r,
        isCurrentUser: entry.id. toString() == widget.currentUserId,
      ),
    );
  }

  // ==================== TIER INFO SECTION ====================
  Widget _buildTierInfoSection(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        color: LeaderboardDesign.  surfaceWhite,
        borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                Icons.  info_outline_rounded,
                size: r.iconSize(20),
                color: LeaderboardDesign.info,
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Tier System',
                style: GoogleFonts. inter(
                  fontSize: r.  bodyM,
                  fontWeight: FontWeight.w700,
                  color: LeaderboardDesign.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),

          // Tier cards
          ...  LeaderboardTier.values.where((t) => t != LeaderboardTier. unranked).  map((tier) {
            return _buildTierInfoCard(r, tier);
          }),
        ],
      ),
    );
  }

  Widget _buildTierInfoCard(EmployeeResponsiveData r, LeaderboardTier tier) {
    return Container(
      margin: EdgeInsets. only(bottom: r.microPadding),
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tier.  primaryColor. withOpacity(0.15),
            tier. primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: tier.primaryColor.  withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Tier icon
          Container(
            padding: EdgeInsets.  all(r.microPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: tier.gradientColors),
              borderRadius: BorderRadius.circular(r. smallBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: tier.glowColor. withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              tier.icon,
              size: r.iconSize(24),
              color: tier == LeaderboardTier.silver
                  ? LeaderboardDesign. textPrimary
                  : Colors.white,
            ),
          ),
          SizedBox(width: r.microPadding),

          // Tier info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.name,
                  style: GoogleFonts.inter(
                    fontSize: r. bodyS,
                    fontWeight: FontWeight. w700,
                    color: LeaderboardDesign. textPrimary,
                  ),
                ),
                Text(
                  'Rating: ${tier.minRating. toStringAsFixed(1)} - ${tier.maxRating.toStringAsFixed(1)}',
                  style: GoogleFonts. inter(
                    fontSize: r.captionS,
                    color: LeaderboardDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Benefits
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r. microPadding,
              vertical: r.nanoPadding,
            ),
            decoration: BoxDecoration(
              color: tier.primaryColor. withOpacity(0.2),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: r.iconSize(14),
                  color: tier.primaryColor,
                ),
                SizedBox(width: r.atomicPadding),
                Text(
                  _getTierBonus(tier),
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    fontWeight: FontWeight. w600,
                    color: tier. primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTierBonus(LeaderboardTier tier) {
    switch (tier) {
      case LeaderboardTier. diamond: return '+50% bonus';
      case LeaderboardTier.gold: return '+30% bonus';
      case LeaderboardTier.silver: return '+15% bonus';
      case LeaderboardTier.bronze: return '+5% bonus';
      case LeaderboardTier.unranked: return 'No bonus';
    }
  }

  // ==================== LOADING/ERROR/EMPTY STATES ====================
  Widget _buildLoadingState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math. pi,
                child: child,
              );
            },
            child: Container(
              width: r.avatarSize,
              height: r.avatarSize,
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    LeaderboardDesign. goldPrimary,
                    LeaderboardDesign.goldPrimary.withOpacity(0.1),
                    LeaderboardDesign.goldPrimary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: r.avatarSize - 8,
                  height: r.avatarSize - 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: r.iconSize(24),
                    color: LeaderboardDesign. goldPrimary,
                  ),
                ),
              ),
            ),
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

  Widget _buildErrorState(EmployeeResponsiveData r, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets. all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            Container(
              padding: EdgeInsets. all(r.largePadding),
              decoration: BoxDecoration(
                color: LeaderboardDesign.error. withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: r.iconSize(48),
                color: LeaderboardDesign.error,
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'Failed to load leaderboard',
              style: GoogleFonts. inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight. w700,
                color: LeaderboardDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.microPadding),
            ElevatedButton. icon(
              onPressed: _handleRefresh,
              icon: Icon(Icons.refresh_rounded, size: r.iconSize(18)),
              label: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight. w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: LeaderboardDesign.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets. symmetric(horizontal: r.largePadding, vertical: r.microPadding),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(r.borderRadius)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(EmployeeResponsiveData r) {
    return Center(
      child: Padding(
        padding: EdgeInsets. all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: EdgeInsets. all(r.largePadding),
                decoration: BoxDecoration(
                  color: LeaderboardDesign.goldPrimary. withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  size: r.iconSize(48),
                  color: LeaderboardDesign.goldPrimary,
                ),
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'No rankings yet',
              style: GoogleFonts. inter(
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

// ==================== USER DETAIL SHEET ====================
class _UserDetailSheet extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final LeaderboardTier tier;
  final EmployeeResponsiveData responsive;
  final bool isCurrentUser;

  const _UserDetailSheet({
    required this. entry,
    required this.rank,
    required this.tier,
    required this.responsive,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      constraints: BoxConstraints(maxHeight: r.effectiveHeight * 0.85),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r. extraLargeBorderRadius)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets. only(top: r.microPadding),
              width: r.dimension(40),
              height: r.dimension(4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius. circular(r.pillBorderRadius),
              ),
            ),

            // Header with gradient
            Container(
              width: double.infinity,
              padding: EdgeInsets. all(r.largePadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: tier.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Avatar with effects
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect
                      Container(
                        width: r.welcomeAvatarSize + 30,
                        height: r.welcomeAvatarSize + 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: tier.glowColor. withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: r.welcomeAvatarSize,
                        height: r.welcomeAvatarSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: entry.profileImage != null
                              ?  Image.network(
                            entry.profileImage! ,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(r),
                          )
                              : _buildAvatarPlaceholder(r),
                        ),
                      ),
                      // Tier badge
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets. all(r.nanoPadding),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: tier. glowColor.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            tier.icon,
                            size: r.iconSize(24),
                            color: tier. primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.microPadding),

                  // Name
                  Text(
                    entry.name,
                    style: GoogleFonts.inter(
                      fontSize: r. headingS,
                      fontWeight: FontWeight.w700,
                      color: tier == LeaderboardTier.silver
                          ? LeaderboardDesign. textPrimary
                          : Colors.white,
                    ),
                  ),
                  SizedBox(height: r.nanoPadding),

                  // Tier badge
                  Container(
                    padding: EdgeInsets. symmetric(
                      horizontal: r.microPadding,
                      vertical: r.nanoPadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white. withOpacity(0.2),
                      borderRadius: BorderRadius. circular(r.pillBorderRadius),
                      border: Border.all(color: Colors.white. withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize. min,
                      children: [
                        Icon(
                          tier.icon,
                          size: r.iconSize(18),
                          color: tier == LeaderboardTier.silver
                              ?  LeaderboardDesign.textPrimary
                              : Colors.white,
                        ),
                        SizedBox(width: r.nanoPadding),
                        Text(
                          '${tier.name} Tier',
                          style: GoogleFonts.inter(
                            fontSize: r.bodyS,
                            fontWeight: FontWeight.w600,
                            color: tier == LeaderboardTier.silver
                                ? LeaderboardDesign.textPrimary
                                : Colors. white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats section
            Padding(
              padding: EdgeInsets.all(r.padding),
              child: Column(
                children: [
                  // Rank and rating row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          r,
                          'Rank',
                          '#$rank',
                          Icons.leaderboard_rounded,
                          LeaderboardDesign.primaryTeal,
                        ),
                      ),
                      SizedBox(width: r.microPadding),
                      Expanded(
                        child: _buildStatCard(
                          r,
                          'Rating',
                          entry.rating.toStringAsFixed(2),
                          Icons.star_rounded,
                          LeaderboardDesign.goldPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.microPadding),

                  // Points and tasks row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          r,
                          'Points',
                          '${entry.points}',
                          Icons.emoji_events_rounded,
                          LeaderboardDesign.purple,
                        ),
                      ),
                      SizedBox(width: r. microPadding),
                      Expanded(
                        child: _buildStatCard(
                          r,
                          'Tasks',
                          '${entry.tasksCompleted}',
                          Icons. check_circle_rounded,
                          LeaderboardDesign.success,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.padding),

                  // Rating breakdown
                  _buildRatingBreakdown(r),
                  SizedBox(height: r.padding),

                  // Achievements section
                  _buildAchievementsSection(r),
                  SizedBox(height: r.padding),

                  // Close button
                  SizedBox(
                    width: double. infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tier. primaryColor,
                        foregroundColor: tier == LeaderboardTier.silver
                            ? LeaderboardDesign. textPrimary
                            : Colors.white,
                        padding: EdgeInsets. symmetric(vertical: r.microPadding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(r.borderRadius),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts. inter(fontWeight: FontWeight. w600),
                      ),
                    ),
                  ),

                  SizedBox(height: r.safePaddingBottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(EmployeeResponsiveData r) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LeaderboardDesign. primaryTeal,
            LeaderboardDesign.primaryTealLight,
          ],
        ),
      ),
      child: Center(
        child: Text(
          entry.name. isNotEmpty ?  entry.name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            fontSize: r.welcomeAvatarSize * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      EmployeeResponsiveData r,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: color. withOpacity(0.1),
        borderRadius: BorderRadius. circular(r.borderRadius),
        border: Border.all(color: color. withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: r. iconSize(24), color: color),
          SizedBox(height: r. nanoPadding),
          Text(
            value,
            style: GoogleFonts. inter(
              fontSize: r.headingXS,
              fontWeight: FontWeight. w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: r.captionS,
              color: LeaderboardDesign. textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: LeaderboardDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Text(
            'Rating Breakdown',
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              fontWeight: FontWeight.w700,
              color: LeaderboardDesign.textPrimary,
            ),
          ),
          SizedBox(height: r.microPadding),
          _buildRatingBar(r, 'Speed', 0.85, LeaderboardDesign.success),
          _buildRatingBar(r, 'Quality', 0.92, LeaderboardDesign.info),
          _buildRatingBar(r, 'Reliability', 0.78, LeaderboardDesign.warning),
          _buildRatingBar(r, 'Communication', 0.88, LeaderboardDesign.purple),
        ],
      ),
    );
  }

  Widget _buildRatingBar(EmployeeResponsiveData r, String label, double value, Color color) {
    return Padding(
      padding: EdgeInsets. only(bottom: r.microPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: LeaderboardDesign. textSecondary,
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight. w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: r. atomicPadding),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return ClipRRect(
                borderRadius: BorderRadius. circular(r.pillBorderRadius),
                child: LinearProgressIndicator(
                  value: animValue,
                  backgroundColor: color. withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: r.dimension(8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(EmployeeResponsiveData r) {
    final achievements = [
      _Achievement('Speed Demon', Icons.bolt_rounded, LeaderboardDesign.warning),
      _Achievement('Perfect Score', Icons.star_rounded, LeaderboardDesign.goldPrimary),
      _Achievement('Team Player', Icons.group_rounded, LeaderboardDesign.info),
      _Achievement('Early Bird', Icons.wb_sunny_rounded, LeaderboardDesign.success),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: GoogleFonts.inter(
            fontSize: r. bodyS,
            fontWeight: FontWeight.w700,
            color: LeaderboardDesign.textPrimary,
          ),
        ),
        SizedBox(height: r.microPadding),
        Wrap(
          spacing: r.microPadding,
          runSpacing: r. microPadding,
          children: achievements.map((achievement) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r.nanoPadding,
              ),
              decoration: BoxDecoration(
                color: achievement. color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
                border: Border.all(color: achievement. color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    achievement.icon,
                    size: r. iconSize(16),
                    color: achievement.color,
                  ),
                  SizedBox(width: r. nanoPadding),
                  Text(
                    achievement. name,
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      fontWeight: FontWeight. w600,
                      color: achievement. color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Achievement {
  final String name;
  final IconData icon;
  final Color color;

  _Achievement(this.name, this.icon, this.color);
}