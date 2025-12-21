import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:neat_now/screens/user_dashboard.dart';
import 'package:neat_now/widgets/user/responsive_user_helper.dart';

/// ==================== USER PROFILE TAB (FR-U1, FR-U2) ====================
/// Modern, Professional Design with Glass Morphism and Micro-interactions
class UserProfileTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final UserResponsiveData responsive;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdate;

  const UserProfileTab({
    super.key,
    required this.userData,
    required this. responsive,
    required this.onLogout,
    required this.onProfileUpdate,
  });

  @override
  State<UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<UserProfileTab>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _statsController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _cardController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _cardScaleAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isEditMode = false;
  bool _showLogoutConfirm = false;
  double _scrollOffset = 0;

  // User data getters
  String get _name => widget.userData['name'] ?? 'User';
  String get _email => widget. userData['email'] ??  '';
  String get _phone => widget.userData['phone'] ?? '';
  String?  get _profileImage => widget.userData['profileImage'];
  int get _totalReports => widget.userData['totalReports'] ??  0;
  int get _verifiedReports => widget.userData['verifiedReports'] ?? 0;
  int get _pendingReports => widget.userData['pendingReports'] ?? 0;
  int get _rank => widget.userData['rank'] ?? 0;
  int get _points => widget.userData['points'] ?? 0;
  String?  get _badge => widget.userData['badge'];
  String get _memberSince => widget.userData['memberSince'] ?? 'Jan 2024';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _initAnimations() {
    // Header animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.0, 0.6, curve: Curves. easeOutQuart),
    );
    _headerSlideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves. easeOutQuart),
      ),
    );

    // Stats animations
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Pulse animation for badges
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Float animation
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Card scale animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _statsController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _cardController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController. dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _cardController. dispose();
    _scrollController.dispose();
    super. dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Stack(
      children: [
        // Background gradient
        _buildBackground(r),

        // Main content
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Animated Header with Avatar
            SliverToBoxAdapter(child: _buildAnimatedHeader(r)),

            // Quick Stats Cards
            SliverToBoxAdapter(child: _buildQuickStatsSection(r)),

            // Achievement Section
            SliverToBoxAdapter(child: _buildAchievementSection(r)),

            // Activity Summary
            SliverToBoxAdapter(child: _buildActivitySummary(r)),

            // Settings Menu
            SliverToBoxAdapter(child: _buildSettingsSection(r)),

            // App Info & Logout
            SliverToBoxAdapter(child: _buildFooterSection(r)),

            // Bottom padding
            SliverToBoxAdapter(
              child: SizedBox(height: r.safePaddingBottom + 120),
            ),
          ],
        ),

        // Edit Profile Sheet
        if (_isEditMode)
          _ModernEditProfileSheet(
            responsive: r,
            userData: widget.userData,
            onClose: () => setState(() => _isEditMode = false),
            onSave: (data) {
              setState(() => _isEditMode = false);
              widget. onProfileUpdate();
              _showSuccessSnackBar('Profile updated successfully!  ✨');
            },
          ),

        // Logout Confirmation
        if (_showLogoutConfirm)
          _ModernLogoutDialog(
            responsive: r,
            onConfirm: () {
              setState(() => _showLogoutConfirm = false);
              widget.onLogout();
            },
            onCancel: () => setState(() => _showLogoutConfirm = false),
          ),
      ],
    );
  }

  // ==================== BACKGROUND ====================
  Widget _buildBackground(UserResponsiveData r) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UserDesign.primaryTeal. withOpacity(0.08),
            UserDesign.surfaceLight,
            UserDesign.purple. withOpacity(0.03),
            UserDesign.surfaceLight,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  // ==================== ANIMATED HEADER ====================
  Widget _buildAnimatedHeader(UserResponsiveData r) {
    final parallaxOffset = _scrollOffset * 0.5;

    return AnimatedBuilder(
      animation: Listenable. merge([_headerFadeAnimation, _headerSlideAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _headerSlideAnimation.value - parallaxOffset),
          child: Opacity(
            opacity: _headerFadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets. fromLTRB(
          r. padding,
          r.safePaddingTop + r.padding,
          r.padding,
          r. largePadding + r.padding,
        ),
        child: Column(
          children: [
            // Profile Image with Effects
            _buildEnhancedProfileImage(r),

            SizedBox(height: r.padding),

            // Name with gradient
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  UserDesign.textPrimary,
                  UserDesign.primaryTeal. withOpacity(0.8),
                ],
              ). createShader(bounds),
              child: Text(
                _name,
                style: GoogleFonts.inter(
                  fontSize: r.headingM + 4,
                  fontWeight: FontWeight. w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            SizedBox(height: r.atomicPadding),

            // Email with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_rounded,
                  size: r.iconSize(14),
                  color: UserDesign. textTertiary,
                ),
                SizedBox(width: r.atomicPadding),
                Text(
                  _email,
                  style: GoogleFonts. inter(
                    fontSize: r.captionM,
                    color: UserDesign. textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),

            SizedBox(height: r.microPadding),

            // Member since badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r. microPadding,
                vertical: r.atomicPadding,
              ),
              decoration: BoxDecoration(
                color: UserDesign.surfacePure. withOpacity(0.8),
                borderRadius: BorderRadius.circular(r. pillBorderRadius),
                border: Border.all(
                  color: UserDesign.primaryTeal. withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize. min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: r. iconSize(12),
                    color: UserDesign. primaryTeal,
                  ),
                  SizedBox(width: r. atomicPadding),
                  Text(
                    'Member since $_memberSince',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: UserDesign. textSecondary,
                      fontWeight: FontWeight. w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: r.microPadding),

            // Rank Badge (if applicable)
            if (_rank > 0) _buildEnhancedRankBadge(r),
          ],
        ),
      ),
    );
  }

  // ==================== ENHANCED PROFILE IMAGE ====================
  Widget _buildEnhancedProfileImage(UserResponsiveData r) {
    final size = r.dimension(120);
    final isTopThree = _rank <= 3 && _rank > 0;

    Color primaryColor = UserDesign.primaryTeal;
    Color secondaryColor = UserDesign.primaryTealLight;
    List<Color> glowColors = [UserDesign.primaryTeal, UserDesign.primaryTealLight];

    if (_rank == 1) {
      primaryColor = UserDesign.platinum;
      secondaryColor = const Color(0xFFE8E8E8);
      glowColors = [UserDesign.platinum, const Color(0xFFE8E8E8)];
    } else if (_rank == 2) {
      primaryColor = const Color(0xFFFFD700);
      secondaryColor = const Color(0xFFFFA500);
      glowColors = [const Color(0xFFFFD700), const Color(0xFFFFA500)];
    } else if (_rank == 3) {
      primaryColor = UserDesign.silver;
      secondaryColor = const Color(0xFFB8B8B8);
      glowColors = [UserDesign.silver, const Color(0xFFB8B8B8)];
    }

    return AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _floatAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, isTopThree ? _floatAnimation.value * 0.3 : 0),
            child: Transform.scale(
              scale: isTopThree ? _pulseAnimation.value : 1.0,
              child: child,
            ),
          );
        },
        child: Stack(
            alignment: Alignment.center,
            children: [
            // Animated glow rings
            if (isTopThree) ...[
        _buildGlowRing(r, size + 50, glowColors, 0.15),
    _buildGlowRing(r, size + 35, glowColors, 0.25),
    _buildGlowRing(r, size + 20, glowColors, 0.35),
    ],

    // Main border ring
    Container(
    width: size + 10,
    height: size + 10,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
    ),
    boxShadow: [
    BoxShadow(
    color: primaryColor.withOpacity(0.4),
    blurRadius: 20,
    spreadRadius: 2,
    ),
    ],
    ),
    ),

    // White inner border
    Container(
    width: size + 4,
    height: size + 4,
    decoration: const BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    ),
    ),

    // Profile image
    Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: UserDesign.surfaceLight,
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: ClipOval(
    child: _profileImage != null
    ? Image.network(
    _profileImage!,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) =>
    _buildModernAvatarPlaceholder(r, size),
    loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return _buildAvatarShimmer(r, size);
    },
    )
        : _buildModernAvatarPlaceholder(r, size),
    ),
    ),

    // Edit button
    Positioned(
    bottom: 0,
    right: 0,
    child: _buildEditButton(r),
    ),

    // Rank indicator (for top 3)
    if (isTopThree)
    Positioned(
    top: 0,
    right: 0,
    child: _buildRankIndicator(r, primaryColor),
    ),
    ],
    ),
    );
  }

  Widget _buildGlowRing(
      UserResponsiveData r, double size, List<Color> colors, double opacity) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _shimmerAnimation. value * math.pi,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  colors[0]. withOpacity(0),
                  colors[0].withOpacity(opacity),
                  colors[1].withOpacity(opacity),
                  colors[1].withOpacity(0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernAvatarPlaceholder(UserResponsiveData r, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UserDesign.primaryTeal,
            UserDesign.primaryTealLight,
          ],
        ),
      ),
      child: Center(
        child: Text(
          _name. isNotEmpty ? _name[0].toUpperCase() : '? ',
          style: GoogleFonts. inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight. w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarShimmer(UserResponsiveData r, double size) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation. value, 0),
              colors: [
                UserDesign.surfaceLight,
                UserDesign.surfaceOverlay,
                UserDesign.surfaceLight,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditButton(UserResponsiveData r) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _isEditMode = true);
      },
      child: Container(
        padding: EdgeInsets. all(r.microPadding + 2),
        decoration: BoxDecoration(
          gradient: UserDesign.primaryGradient,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: UserDesign.primaryTeal.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons. edit_rounded,
          color: Colors.white,
          size: r.iconSize(16),
        ),
      ),
    );
  }

  Widget _buildRankIndicator(UserResponsiveData r, Color color) {
    IconData icon;
    if (_rank == 1) {
      icon = Icons.diamond_rounded;
    } else if (_rank == 2) {
      icon = Icons.workspace_premium_rounded;
    } else {
      icon = Icons.military_tech_rounded;
    }

    return Container(
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors. white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: Colors. white, size: r.iconSize(18)),
    );
  }

  Widget _buildEnhancedRankBadge(UserResponsiveData r) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeLabel;
    String badgeTitle;

    if (_rank == 1) {
      badgeColor = UserDesign.platinum;
      badgeIcon = Icons.diamond_rounded;
      badgeTitle = 'Platinum';
      badgeLabel = 'Top Reporter';
    } else if (_rank == 2) {
      badgeColor = const Color(0xFFFFD700);
      badgeIcon = Icons.workspace_premium_rounded;
      badgeTitle = 'Gold';
      badgeLabel = 'Elite Reporter';
    } else if (_rank == 3) {
      badgeColor = UserDesign.silver;
      badgeIcon = Icons.military_tech_rounded;
      badgeTitle = 'Silver';
      badgeLabel = 'Pro Reporter';
    } else {
      badgeColor = UserDesign.primaryTeal;
      badgeIcon = Icons.stars_rounded;
      badgeTitle = 'Rank #$_rank';
      badgeLabel = 'Active Reporter';
    }

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: r. padding,
            vertical: r.microPadding,
          ),
          decoration: BoxDecoration(
            gradient: _rank <= 3
                ? LinearGradient(
              colors: [
                badgeColor. withOpacity(0.9),
                badgeColor.withOpacity(0.7),
              ],
            )
                : null,
            color: _rank > 3 ? UserDesign.surfacePure : null,
            borderRadius: BorderRadius. circular(r.pillBorderRadius),
            border: Border. all(
              color: _rank <= 3
                  ? Colors.white. withOpacity(0.3)
                  : badgeColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: _rank <= 3
                ? [
              BoxShadow(
                color: badgeColor. withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ]
                : UserDesign.softShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                badgeIcon,
                size: r.iconSize(18),
                color: _rank <= 3 ? Colors.white : badgeColor,
              ),
              SizedBox(width: r.nanoPadding),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badgeTitle,
                    style: GoogleFonts. inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight. w700,
                      color: _rank <= 3 ? Colors.white : UserDesign.textPrimary,
                    ),
                  ),
                  Text(
                    badgeLabel,
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      color: _rank <= 3
                          ? Colors. white. withOpacity(0.8)
                          : UserDesign.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== QUICK STATS SECTION ====================
  Widget _buildQuickStatsSection(UserResponsiveData r) {
    return ScaleTransition(
      scale: _cardScaleAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: r. padding),
        child: Container(
          padding: EdgeInsets. all(r.padding),
          decoration: BoxDecoration(
            color: UserDesign.surfacePure,
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Points header
              _buildPointsHeader(r),

              SizedBox(height: r.padding),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildModernStatItem(
                      r,
                      'Total Reports',
                      _totalReports,
                      Icons.assignment_rounded,
                      UserDesign.info,
                    ),
                  ),
                  SizedBox(width: r. microPadding),
                  Expanded(
                    child: _buildModernStatItem(
                      r,
                      'Verified',
                      _verifiedReports,
                      Icons.verified_rounded,
                      UserDesign. success,
                    ),
                  ),
                  SizedBox(width: r.microPadding),
                  Expanded(
                    child: _buildModernStatItem(
                      r,
                      'Pending',
                      _pendingReports,
                      Icons. pending_rounded,
                      UserDesign. warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPointsHeader(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UserDesign.primaryTeal. withOpacity(0.1),
            UserDesign.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(r. largeBorderRadius),
        border: Border.all(
          color: UserDesign.primaryTeal.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets. all(r.microPadding),
            decoration: BoxDecoration(
              gradient: UserDesign.primaryGradient,
              borderRadius: BorderRadius. circular(r.borderRadius),
              boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
            ),
            child: Icon(
              Icons. stars_rounded,
              color: Colors.white,
              size: r.iconSize(24),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Points',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: UserDesign. textSecondary,
                  ),
                ),
                AnimatedBuilder(
                  animation: _statsAnimation,
                  builder: (context, child) {
                    final animatedValue =
                    (_points * _statsAnimation.value). round();
                    return Text(
                      '$animatedValue pts',
                      style: GoogleFonts.inter(
                        fontSize: r. headingS,
                        fontWeight: FontWeight. w800,
                        color: UserDesign. primaryTeal,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r. microPadding,
              vertical: r.atomicPadding,
            ),
            decoration: BoxDecoration(
              color: UserDesign. success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons. trending_up_rounded,
                  size: r.iconSize(14),
                  color: UserDesign. success,
                ),
                SizedBox(width: r.atomicPadding),
                Text(
                  '+${(_points * 0.12).round()} this week',
                  style: GoogleFonts.inter(
                    fontSize: r. captionXS,
                    fontWeight: FontWeight. w600,
                    color: UserDesign.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatItem(
      UserResponsiveData r,
      String label,
      int value,
      IconData icon,
      Color color,
      ) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        final animatedValue = (value * _statsAnimation.value).round();
        return Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            color: color. withOpacity(0.05),
            borderRadius: BorderRadius.circular(r.largeBorderRadius),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration: BoxDecoration(
                  color: color. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(icon, color: color, size: r.iconSize(20)),
              ),
              SizedBox(height: r.microPadding),
              Text(
                '$animatedValue',
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
                textAlign: TextAlign. center,
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== ACHIEVEMENT SECTION ====================
  Widget _buildAchievementSection(UserResponsiveData r) {
    if (_rank > 3) return const SizedBox.shrink();

    Color primaryColor;
    Color secondaryColor;
    String title;
    String description;
    IconData icon;

    if (_rank == 1) {
      primaryColor = UserDesign.platinum;
      secondaryColor = const Color(0xFFE8E8E8);
      title = '🏆 Champion Reporter! ';
      description = 'You\'re the #1 reporter!  Keep leading the way. ';
      icon = Icons.diamond_rounded;
    } else if (_rank == 2) {
      primaryColor = const Color(0xFFFFD700);
      secondaryColor = const Color(0xFFFFA500);
      title = '🥈 Elite Status Achieved!';
      description = 'Just one step away from the top! Keep pushing. ';
      icon = Icons.workspace_premium_rounded;
    } else {
      primaryColor = UserDesign.silver;
      secondaryColor = const Color(0xFFB8B8B8);
      title = '🥉 Rising Star!';
      description = 'You\'re in the Top 3! Amazing achievement.';
      icon = Icons.military_tech_rounded;
    }

    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.2),
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.all(r.padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.15),
                secondaryColor.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor. withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.microPadding + 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(r.largeBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: r.iconSize(28)),
              ),
              SizedBox(width: r.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: r.bodyM,
                        fontWeight: FontWeight. w700,
                        color: UserDesign.textPrimary,
                      ),
                    ),
                    SizedBox(height: r.atomicPadding),
                    Text(
                      description,
                      style: GoogleFonts. inter(
                        fontSize: r.captionM,
                        color: UserDesign.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ACTIVITY SUMMARY ====================
  Widget _buildActivitySummary(UserResponsiveData r) {
    return Padding(
      padding: EdgeInsets. symmetric(horizontal: r. padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: r.nanoPadding, bottom: r.microPadding),
            child: Text(
              'Activity Summary',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight. w700,
                color: UserDesign.textPrimary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(r.padding),
            decoration: BoxDecoration(
              color: UserDesign.surfacePure,
              borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
              boxShadow: UserDesign.softShadow,
            ),
            child: Column(
              children: [
                _buildActivityRow(
                  r,
                  'Reports This Month',
                  '${(_totalReports * 0.3).round()}',
                  Icons.calendar_month_rounded,
                  UserDesign. info,
                ),
                Divider(height: r.padding, color: UserDesign.surfaceOverlay),
                _buildActivityRow(
                  r,
                  'Verification Rate',
                  '${_totalReports > 0 ? ((_verifiedReports / _totalReports) * 100).round() : 0}%',
                  Icons.verified_rounded,
                  UserDesign. success,
                ),
                Divider(height: r. padding, color: UserDesign.surfaceOverlay),
                _buildActivityRow(
                  r,
                  'Average Response Time',
                  '2.5 hrs',
                  Icons.timer_rounded,
                  UserDesign. warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
      UserResponsiveData r,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.borderRadius),
          ),
          child: Icon(icon, color: color, size: r.iconSize(18)),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts. inter(
              fontSize: r.bodyS,
              color: UserDesign.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: r.bodyS,
            fontWeight: FontWeight. w700,
            color: UserDesign.textPrimary,
          ),
        ),
      ],
    );
  }

  // ==================== SETTINGS SECTION ====================
  Widget _buildSettingsSection(UserResponsiveData r) {
    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: r.nanoPadding, bottom: r.microPadding),
            child: Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: r. bodyM,
                fontWeight: FontWeight.w700,
                color: UserDesign.textPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: UserDesign.surfacePure,
              borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
              boxShadow: UserDesign.softShadow,
            ),
            child: Column(
              children: [
                _buildModernMenuItem(
                  r,
                  Icons.person_rounded,
                  'Edit Profile',
                  'Update your personal information',
                  UserDesign.primaryTeal,
                      () => setState(() => _isEditMode = true),
                ),
                _buildMenuDivider(r),
                _buildModernMenuItem(
                  r,
                  Icons.notifications_rounded,
                  'Notifications',
                  'Manage notification preferences',
                  UserDesign.info,
                      () {},
                ),
                _buildMenuDivider(r),
                _buildModernMenuItem(
                  r,
                  Icons.lock_rounded,
                  'Privacy & Security',
                  'Password and security settings',
                  UserDesign.warning,
                      () {},
                ),
                _buildMenuDivider(r),
                _buildModernMenuItem(
                  r,
                  Icons. language_rounded,
                  'Language',
                  'English (US)',
                  UserDesign.purple,
                      () {},
                  showValue: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuItem(
      UserResponsiveData r,
      IconData icon,
      String title,
      String subtitle,
      Color color,
      VoidCallback onTap, {
        bool showValue = false,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius. circular(r.borderRadius),
        child: Padding(
          padding: EdgeInsets. all(r.padding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.microPadding + 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color. withOpacity(0.2), color.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius. circular(r.borderRadius),
                ),
                child: Icon(icon, color: color, size: r.iconSize(22)),
              ),
              SizedBox(width: r.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: r. bodyS,
                        fontWeight: FontWeight. w600,
                        color: UserDesign. textPrimary,
                      ),
                    ),
                    SizedBox(height: r.atomicPadding),
                    Text(
                      subtitle,
                      style: GoogleFonts. inter(
                        fontSize: r.captionS,
                        color: UserDesign.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: UserDesign.textLight,
                size: r.iconSize(24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider(UserResponsiveData r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r. padding),
      child: Divider(height: 1, color: UserDesign.surfaceOverlay),
    );
  }

  // ==================== FOOTER SECTION ====================
  Widget _buildFooterSection(UserResponsiveData r) {
    return Padding(
      padding: EdgeInsets. symmetric(horizontal: r. padding),
      child: Column(
        children: [
          // Help & Support section
          Container(
            decoration: BoxDecoration(
              color: UserDesign.surfacePure,
              borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
              boxShadow: UserDesign.softShadow,
            ),
            child: Column(
              children: [
                _buildModernMenuItem(
                  r,
                  Icons.help_outline_rounded,
                  'Help & Support',
                  'Get help or contact us',
                  UserDesign.success,
                      () {},
                ),
                _buildMenuDivider(r),
                _buildModernMenuItem(
                  r,
                  Icons.info_outline_rounded,
                  'About NeatNow',
                  'Version 1.0. 0',
                  UserDesign.info,
                      () {},
                ),
              ],
            ),
          ),

          SizedBox(height: r.padding),

          // Logout Button
          _buildLogoutButton(r),

          SizedBox(height: r.padding),

          // App version
          Text(
            'NeatNow v1.0.0',
            style: GoogleFonts.inter(
              fontSize: r.captionS,
              color: UserDesign. textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(UserResponsiveData r) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _showLogoutConfirm = true);
      },
      child: Container(
        height: r.buttonHeight + 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              UserDesign.error.withOpacity(0.1),
              UserDesign.error.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius. circular(r.largeBorderRadius),
          border: Border.all(
            color: UserDesign.error.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            Icon(
              Icons. logout_rounded,
              color: UserDesign.error,
              size: r.iconSize(20),
            ),
            SizedBox(width: r.nanoPadding),
            Text(
              'Sign Out',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
                color: UserDesign.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context). showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white. withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight. w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: UserDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ==================== MODERN EDIT PROFILE SHEET ====================
class _ModernEditProfileSheet extends StatefulWidget {
  final UserResponsiveData responsive;
  final Map<String, dynamic> userData;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const _ModernEditProfileSheet({
    required this.responsive,
    required this.userData,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<_ModernEditProfileSheet> createState() => _ModernEditProfileSheetState();
}

class _ModernEditProfileSheetState extends State<_ModernEditProfileSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  File? _newImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _phoneController = TextEditingController(text: widget.userData['phone'] ?? '');
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1, end: 0). animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1). animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController. dispose();
    _animationController.dispose();
    super. dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 90,
    );
    if (image != null) {
      setState(() => _newImage = File(image.path));
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 1200));

    widget.onSave({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController. text.trim(),
    });
  }

  void _showError(String message) {
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: UserDesign.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _closeSheet() async {
    await _animationController. reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _closeSheet,
              child: Container(
                color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
              ),
            ),

            // Sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(
                  0,
                  MediaQuery.of(context).size.height * 0.85 * _slideAnimation.value,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: UserDesign.surfacePure,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(r.extraLargeBorderRadius + 8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        width: r.dimension(48),
                        height: r.dimension(5),
                        margin: EdgeInsets.symmetric(vertical: r.microPadding),
                        decoration: BoxDecoration(
                          color: UserDesign.textLight. withOpacity(0.5),
                          borderRadius: BorderRadius. circular(3),
                        ),
                      ),

                      // Header
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          r.padding,
                          r. microPadding,
                          r.padding,
                          r.padding,
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: _closeSheet,
                              child: Container(
                                padding: EdgeInsets. all(r.microPadding),
                                decoration: BoxDecoration(
                                  color: UserDesign.surfaceLight,
                                  borderRadius: BorderRadius.circular(r. borderRadius),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: UserDesign.textSecondary,
                                  size: r.iconSize(22),
                                ),
                              ),
                            ),
                            SizedBox(width: r.padding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment. start,
                                children: [
                                  Text(
                                    'Edit Profile',
                                    style: GoogleFonts.inter(
                                      fontSize: r.headingXS,
                                      fontWeight: FontWeight.w700,
                                      color: UserDesign.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Update your personal information',
                                    style: GoogleFonts. inter(
                                      fontSize: r. captionS,
                                      color: UserDesign.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets. symmetric(horizontal: r. padding),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              // Profile Image
                              _buildProfileImagePicker(r),

                              SizedBox(height: r.largePadding),

                              // Form Fields
                              _buildModernTextField(
                                r,
                                _nameController,
                                'Full Name',
                                'Enter your full name',
                                Icons.person_rounded,
                              ),
                              SizedBox(height: r.padding),

                              _buildModernTextField(
                                r,
                                _phoneController,
                                'Phone Number',
                                'Enter your phone number',
                                Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: r.padding),

                              _buildModernTextField(
                                r,
                                _bioController,
                                'Bio',
                                'Tell us about yourself.. .',
                                Icons.edit_note_rounded,
                                maxLines: 3,
                              ),

                              SizedBox(height: r. largePadding),
                            ],
                          ),
                        ),
                      ),

                      // Save Button
                      Container(
                        padding: EdgeInsets. fromLTRB(
                          r. padding,
                          r.microPadding,
                          r.padding,
                          r.safePaddingBottom + r.padding,
                        ),
                        decoration: BoxDecoration(
                          color: UserDesign.surfacePure,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: _isSaving ? null : _save,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: r.buttonHeight + 8,
                            decoration: BoxDecoration(
                              gradient: _isSaving ?  null : UserDesign.primaryGradient,
                              color: _isSaving ? UserDesign.textLight : null,
                              borderRadius: BorderRadius. circular(r.largeBorderRadius),
                              boxShadow: _isSaving
                                  ? null
                                  : UserDesign.glowShadow(UserDesign.primaryTeal),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment. center,
                              children: [
                                if (_isSaving)
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: UserDesign.textSecondary,
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: r.iconSize(22),
                                  ),
                                SizedBox(width: r.nanoPadding),
                                Text(
                                  _isSaving ? 'Saving...' : 'Save Changes',
                                  style: GoogleFonts.inter(
                                    fontSize: r.bodyS,
                                    fontWeight: FontWeight.w700,
                                    color: _isSaving
                                        ? UserDesign.textSecondary
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileImagePicker(UserResponsiveData r) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: r.dimension(110),
            height: r.dimension(110),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: UserDesign.primaryGradient,
              boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _newImage != null
                      ?  Image.file(_newImage!, fit: BoxFit.cover)
                      : widget.userData['profileImage'] != null
                      ? Image.network(
                    widget.userData['profileImage'],
                    fit: BoxFit. cover,
                    errorBuilder: (_, __, ___) =>
                        _buildPlaceholder(r),
                  )
                      : _buildPlaceholder(r),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets. all(r.microPadding + 2),
              decoration: BoxDecoration(
                gradient: UserDesign. primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: UserDesign.primaryTeal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: r.iconSize(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(UserResponsiveData r) {
    final name = widget.userData['name'] ?? 'U';
    return Container(
      color: UserDesign.surfaceLight,
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: GoogleFonts. inter(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            color: UserDesign.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(
      UserResponsiveData r,
      TextEditingController controller,
      String label,
      String hint,
      IconData icon, {
        TextInputType?  keyboardType,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      label,
      style: GoogleFonts. inter(
        fontSize: r.captionM,
        fontWeight: FontWeight.w600,
        color: UserDesign. textSecondary,
      ),
    ),
    SizedBox(height: r.nanoPadding),
    Container(
    decoration: BoxDecoration(
    color: UserDesign.surfaceLight,
    borderRadius: BorderRadius. circular(r.largeBorderRadius),
    border: Border.all(
    color: UserDesign.surfaceOverlay,
    width: 1.5,
    ),
    ),
    child: TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: GoogleFonts.inter(
    fontSize: r.bodyS,
    color: UserDesign. textPrimary,
    ),
    decoration: InputDecoration(
      prefixIcon: Padding(
        padding: EdgeInsets. only(left: r.microPadding, right: r. nanoPadding),
        child: Icon(
          icon,
          color: UserDesign. textTertiary,
          size: r. iconSize(20),
        ),
      ),
      prefixIconConstraints: BoxConstraints(
        minWidth: r.dimension(48),
      ),
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: r. bodyS,
        color: UserDesign. textLight,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        borderSide: BorderSide. none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        borderSide: BorderSide(
          color: UserDesign.primaryTeal,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: r. padding,
        vertical: r.padding,
      ),
    ),
    ),
    ),
      ],
    );
  }
}

// ==================== MODERN LOGOUT DIALOG ====================
class _ModernLogoutDialog extends StatefulWidget {
  final UserResponsiveData responsive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ModernLogoutDialog({
    required this.responsive,
    required this. onConfirm,
    required this. onCancel,
  });

  @override
  State<_ModernLogoutDialog> createState() => _ModernLogoutDialogState();
}

class _ModernLogoutDialogState extends State<_ModernLogoutDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super. initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0). animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1). animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController. forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _animationController. reverse();
    widget.onCancel();
  }

  Future<void> _confirm() async {
    setState(() => _isLoggingOut = true);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 800));
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _isLoggingOut ?  null : _close,
              child: Container(
                color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
              ),
            ),

            // Dialog
            Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    margin: EdgeInsets. all(r.largePadding),
                    padding: EdgeInsets. all(r.largePadding),
                    decoration: BoxDecoration(
                      color: UserDesign.surfacePure,
                      borderRadius: BorderRadius. circular(r.extraLargeBorderRadius + 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize. min,
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets. all(r.padding + 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment. bottomRight,
                              colors: [
                                UserDesign.error. withOpacity(0.15),
                                UserDesign.error.withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: EdgeInsets. all(r.padding),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  UserDesign. error,
                                  UserDesign.error. withOpacity(0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: UserDesign.error. withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons. logout_rounded,
                              color: Colors.white,
                              size: r. iconSize(32),
                            ),
                          ),
                        ),

                        SizedBox(height: r.padding),

                        // Title
                        Text(
                          'Sign Out? ',
                          style: GoogleFonts.inter(
                            fontSize: r. headingS,
                            fontWeight: FontWeight. w700,
                            color: UserDesign. textPrimary,
                          ),
                        ),

                        SizedBox(height: r. microPadding),

                        // Description
                        Text(
                          'Are you sure you want to sign out?\nYou\'ll need to sign in again to access your account.',
                          style: GoogleFonts.inter(
                            fontSize: r.bodyS,
                            color: UserDesign.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: r.largePadding),

                        // Buttons
                        Row(
                          children: [
                            // Cancel Button
                            Expanded(
                              child: GestureDetector(
                                onTap: _isLoggingOut ?  null : _close,
                                child: Container(
                                  height: r.buttonHeight + 4,
                                  decoration: BoxDecoration(
                                    color: UserDesign. surfaceLight,
                                    borderRadius: BorderRadius.circular(r.largeBorderRadius),
                                    border: Border.all(
                                      color: UserDesign.surfaceOverlay,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.inter(
                                        fontSize: r.bodyS,
                                        fontWeight: FontWeight.w600,
                                        color: UserDesign.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: r.microPadding),

                            // Sign Out Button
                            Expanded(
                              child: GestureDetector(
                                onTap: _isLoggingOut ? null : _confirm,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: r.buttonHeight + 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        UserDesign. error,
                                        UserDesign.error.withOpacity(0.85),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(r. largeBorderRadius),
                                    boxShadow: [
                                      BoxShadow(
                                        color: UserDesign.error.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _isLoggingOut
                                        ?  SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                        : Row(
                                      mainAxisAlignment: MainAxisAlignment. center,
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: r.iconSize(18),
                                        ),
                                        SizedBox(width: r.nanoPadding),
                                        Text(
                                          'Sign Out',
                                          style: GoogleFonts.inter(
                                            fontSize: r. bodyS,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
          ],
        );
      },
    );
  }
}