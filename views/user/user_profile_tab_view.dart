import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neat_now/views/user/user_notifications_page.dart';
import 'dart:io';
import 'dart:math' as math;
// Add this import at the top
import 'package:neat_now/views/user/user_notifications_page.dart';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/models/user/user_model.dart';
import 'package:neat_now/viewmodels/user/user_profile_viewmodel.dart';
import 'package:neat_now/views/user/components/modern_edit_profile_sheet.dart';
import 'package:neat_now/views/user/components/modern_logout_dialog.dart';

/// ==================== USER PROFILE TAB (FR-U1, FR-U2) ====================
class UserProfileTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final UserResponsiveData responsive;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdate;

  const UserProfileTab({
    super.key,
    required this. userData,
    required this.responsive,
    required this.onLogout,
    required this.onProfileUpdate,
  });

  @override
  State<UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<UserProfileTab>
    with TickerProviderStateMixin {
  late UserProfileViewModel _viewModel;

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
  double _scrollOffset = 0;

  @override
  // Update the initState to set navigation callbacks

  @override
  @override
  void initState() {
    super.initState();

    // Initialize ViewModel
    _viewModel = UserProfileViewModel(
      user: UserModel. fromMap(widget.userData),
      onLogout: widget.onLogout,
      onProfileUpdate: widget.onProfileUpdate,
    );

    _viewModel.addListener(_onViewModelChanged);

    _initAnimations();
    _startAnimations();
    _scrollController. addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set context after the widget is built
    _viewModel. setContext(context);
  }

// Add navigation methods
  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserNotificationsPage(),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    // TODO: Navigate to settings page
  //  _showSnackBar('Settings page coming soon!  🚧');
  }

  void _navigateToPrivacy(BuildContext context) {
    // TODO: Navigate to privacy page
  //  _showSnackBar('Privacy settings coming soon! 🚧');
  }

  void _navigateToHelp(BuildContext context) {
    // TODO: Navigate to help page
  //  _showSnackBar('Help center coming soon! 🚧');
  }

  void _navigateToAbout(BuildContext context) {
    // TODO: Navigate to about page
   // _showSnackBar('About page coming soon! 🚧');
  }

// Update _buildSettingsSection to pass context
  Widget _buildSettingsSection(UserResponsiveData r) {
    final menuItems = _viewModel.getSettingsMenuItems(context);

    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: r.nanoPadding, bottom: r.microPadding),
            child: Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: UserDesign.textPrimary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: UserDesign.surfacePure,
              borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
              boxShadow: UserDesign.softShadow,
            ),
            child: Column(
              children: menuItems. asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == menuItems.length - 1;
                return Column(
                  children: [
                    _buildModernMenuItem(r, item),
                    if (!isLast) _buildMenuDivider(r),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

// Update _buildFooterSection to pass context
  Widget _buildFooterSection(UserResponsiveData r) {
    final helpItems = _viewModel.getHelpMenuItems(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.padding),
      child: Column(
        children: [
          // Help & Support section
          Container(
            decoration: BoxDecoration(
              color: UserDesign.surfacePure,
              borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
              boxShadow:  UserDesign.softShadow,
            ),
            child: Column(
              children: helpItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == helpItems.length - 1;
                return Column(
                  children: [
                    _buildModernMenuItem(r, item),
                    if (!isLast) _buildMenuDivider(r),
                  ],
                );
              }).toList(),
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
              color: UserDesign.textLight,
            ),
          ),
        ],
      ),
    );
  }
  void _onViewModelChanged() {
    setState(() {});
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
      parent:  _headerController,
      curve:  const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
    );
    _headerSlideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    // Stats animations
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve:  Curves.easeOutCubic,
    );

    // Shimmer effect
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve:  Curves.easeInOut),
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
      CurvedAnimation(parent: _floatController, curve:  Curves.easeInOut),
    );

    // Card scale animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardScaleAnimation = Tween<double>(begin:  0.9, end: 1.0).animate(
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
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _headerController.dispose();
    _statsController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _cardController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        if (_viewModel.isEditMode)
          ModernEditProfileSheet(
            responsive: r,
            userData: widget.userData,
            onClose: _viewModel.closeEditMode,
            onSave: (data) {
              _viewModel. handleProfileUpdate(data);
              _showSuccessSnackBar('Profile updated successfully!  ✨');
            },
          ),

        // Logout Confirmation
        if (_viewModel.showLogoutConfirm)
          ModernLogoutDialog(
            responsive:  r,
            onConfirm: _viewModel.confirmLogout,
            onCancel: _viewModel.hideLogoutConfirmation,
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
            UserDesign.purple.withOpacity(0.03),
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
      animation:  Listenable. merge([_headerFadeAnimation, _headerSlideAnimation]),
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
        padding:  EdgeInsets.fromLTRB(
          r. padding,
          r.safePaddingTop + r.padding,
          r.padding,
          r.largePadding + r.padding,
        ),
        child: Column(
          children: [
            // Profile Image with Effects
            _buildEnhancedProfileImage(r),

            SizedBox(height: r.padding),

            // Name with gradient
            ShaderMask(
              shaderCallback:  (bounds) => LinearGradient(
                colors:  [
                  UserDesign. textPrimary,
                  UserDesign.primaryTeal. withOpacity(0.8),
                ],
              ).createShader(bounds),
              child: Text(
                _viewModel.name,
                style: GoogleFonts.inter(
                  fontSize: r.headingM + 4,
                  fontWeight: FontWeight.w800,
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
                  size: r. iconSize(14),
                  color: UserDesign.textTertiary,
                ),
                SizedBox(width: r. atomicPadding),
                Text(
                  _viewModel.email,
                  style: GoogleFonts.inter(
                    fontSize: r. captionM,
                    color: UserDesign.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),

            SizedBox(height: r. microPadding),

            // Member since badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical:  r.atomicPadding,
              ),
              decoration: BoxDecoration(
                color: UserDesign.surfacePure. withOpacity(0.8),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
                border: Border.all(
                  color: UserDesign. primaryTeal.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: r.iconSize(12),
                    color: UserDesign.primaryTeal,
                  ),
                  SizedBox(width: r.atomicPadding),
                  Text(
                    'Member since ${_viewModel.memberSince}',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: UserDesign.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: r.microPadding),

            // Rank Badge (if applicable)
            if (_viewModel.rank > 0) _buildEnhancedRankBadge(r),
          ],
        ),
      ),
    );
  }

  // ==================== ENHANCED PROFILE IMAGE ====================
  Widget _buildEnhancedProfileImage(UserResponsiveData r) {
    final size = r.dimension(120);
    final colors = _viewModel.getProfileColors();

    return AnimatedBuilder(
        animation:  Listenable.merge([_pulseAnimation, _floatAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _viewModel.isTopThree ? _floatAnimation.value * 0.3 : 0),
            child: Transform.scale(
              scale: _viewModel.isTopThree ?  _pulseAnimation.value :  1.0,
              child: child,
            ),
          );
        },
        child: Stack(
            alignment: Alignment.center,
            children: [
            // Animated glow rings
            if (_viewModel.isTopThree) ...[
        _buildGlowRing(r, size + 50, colors.glowColors, 0.15),
    _buildGlowRing(r, size + 35, colors.glowColors, 0.25),
    _buildGlowRing(r, size + 20, colors.glowColors, 0.35),
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
    colors: [colors.primary, colors.secondary],
    ),
    boxShadow: [
    BoxShadow(
    color: colors.primary.withOpacity(0.4),
    blurRadius:  20,
    spreadRadius: 2,
    ),
    ],
    ),
    ),

    // White inner border
    Container(
    width:  size + 4,
    height: size + 4,
    decoration: const BoxDecoration(
    color:  Colors.white,
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
    blurRadius:  10,
    offset: const Offset(0, 4),
    ),
    ],
    ),
    child: ClipOval(
    child: _viewModel.profileImage != null
    ? Image.network(
    _viewModel. profileImage! ,
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
    if (_viewModel.isTopThree)
    Positioned(
    top: 0,
    right:  0,
    child: _buildRankIndicator(r, colors.primary),
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
          angle: _shimmerAnimation.value * math.pi,
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
          _viewModel.avatarInitial,
          style: GoogleFonts.inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarShimmer(UserResponsiveData r, double size) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder:  (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end:  Alignment(_shimmerAnimation.value, 0),
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
        _viewModel.openEditMode();
      },
      child: Container(
        padding: EdgeInsets.all(r.microPadding + 2),
        decoration: BoxDecoration(
          gradient: UserDesign.primaryGradient,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color:  UserDesign.primaryTeal.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.edit_rounded,
          color: Colors.white,
          size: r.iconSize(16),
        ),
      ),
    );
  }

  Widget _buildRankIndicator(UserResponsiveData r, Color color) {
    final icon = _viewModel.getRankIndicatorIcon();

    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        shape: BoxShape. circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: r.iconSize(18)),
    );
  }

  Widget _buildEnhancedRankBadge(UserResponsiveData r) {
    final badgeData = _viewModel.getRankBadgeData();

    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.padding,
            vertical: r.microPadding,
          ),
          decoration: BoxDecoration(
            gradient: _viewModel.isTopThree
                ? LinearGradient(
              colors: [
                badgeData.color. withOpacity(0.9),
                badgeData. color.withOpacity(0.7),
              ],
            )
                : null,
            color: _viewModel.isTopThree ?  null : UserDesign.surfacePure,
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
            border: Border.all(
              color: _viewModel.isTopThree
                  ? Colors.white. withOpacity(0.3)
                  : badgeData.color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: _viewModel.isTopThree
                ? [
              BoxShadow(
                color:  badgeData.color.withOpacity(0.4),
                blurRadius:  15,
                spreadRadius: 2,
              ),
            ]
                : UserDesign.softShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                badgeData.icon,
                size: r.iconSize(18),
                color: _viewModel.isTopThree ?  Colors.white : badgeData. color,
              ),
              SizedBox(width: r.nanoPadding),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badgeData.title,
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight.w700,
                      color: _viewModel.isTopThree
                          ? Colors.white
                          : UserDesign.textPrimary,
                    ),
                  ),
                  Text(
                    badgeData. label,
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      color: _viewModel.isTopThree
                          ? Colors.white. withOpacity(0.8)
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
      child:  Padding(
        padding: EdgeInsets.symmetric(horizontal: r. padding),
        child: Container(
          padding: EdgeInsets.all(r.padding),
          decoration: BoxDecoration(
            color: UserDesign.surfacePure,
            borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
            boxShadow: [
              BoxShadow(
                color:  Colors.black.withOpacity(0.06),
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
                      _viewModel. totalReports,
                      Icons.assignment_rounded,
                      UserDesign.info,
                    ),
                  ),
                  SizedBox(width: r.microPadding),
                  Expanded(
                    child: _buildModernStatItem(
                      r,
                      'Verified',
                      _viewModel.verifiedReports,
                      Icons.verified_rounded,
                      UserDesign.success,
                    ),
                  ),
                  SizedBox(width: r.microPadding),
                  Expanded(
                    child: _buildModernStatItem(
                      r,
                      'Pending',
                      _viewModel.pendingReports,
                      Icons.pending_rounded,
                      UserDesign.warning,
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
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            UserDesign.primaryTeal. withOpacity(0.1),
            UserDesign.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(
          color: UserDesign.primaryTeal.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration:  BoxDecoration(
              gradient: UserDesign.primaryGradient,
              borderRadius: BorderRadius.circular(r.borderRadius),
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
                    color: UserDesign.textSecondary,
                  ),
                ),
                AnimatedBuilder(
                  animation:  _statsAnimation,
                  builder: (context, child) {
                    final animatedValue =
                    (_viewModel.points * _statsAnimation.value).round();
                    return Text(
                      '$animatedValue pts',
                      style: GoogleFonts.inter(
                        fontSize: r.headingS,
                        fontWeight: FontWeight.w800,
                        color: UserDesign.primaryTeal,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical: r. atomicPadding,
            ),
            decoration: BoxDecoration(
              color: UserDesign.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: r.iconSize(14),
                  color: UserDesign.success,
                ),
                SizedBox(width: r.atomicPadding),
                Text(
                  '+${_viewModel.weeklyPointsGrowth} this week',
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    fontWeight: FontWeight.w600,
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
          padding:  EdgeInsets.all(r.microPadding),
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
                  fontWeight: FontWeight.w800,
                  color: UserDesign.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: r.captionXS,
                  color: UserDesign.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== ACHIEVEMENT SECTION ====================
  Widget _buildAchievementSection(UserResponsiveData r) {
    if (!_viewModel.isTopThree) return const SizedBox.shrink();

    final badgeData = _viewModel.getRankBadgeData();

    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: AnimatedBuilder(
        animation: _floatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.2),
            child: child,
          );
        },
        child: Container(
          padding:  EdgeInsets.all(r. padding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin:  Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                badgeData.color.withOpacity(0.15),
                badgeData.color.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
            border: Border.all(
              color: badgeData.color. withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: badgeData.color.withOpacity(0.2),
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
                    colors: [badgeData.color, badgeData.color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(r.largeBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: badgeData.color. withOpacity(0.4),
                      blurRadius:  12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(badgeData.icon, color: Colors.white, size: r.iconSize(28)),
              ),
              SizedBox(width: r.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${badgeData.title == 'Platinum' ? '🏆' : badgeData.title == 'Gold' ? '🥈' : '🥉'} ${badgeData.label}! ',
                      style: GoogleFonts.inter(
                        fontSize: r.bodyM,
                        fontWeight: FontWeight.w700,
                        color: UserDesign.textPrimary,
                      ),
                    ),
                    SizedBox(height: r.atomicPadding),
                    Text(
                      badgeData.description,
                      style: GoogleFonts.inter(
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
    final activities = _viewModel.getActivityItems();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: r.nanoPadding, bottom: r.microPadding),
            child:  Text(
              'Activity Summary',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: UserDesign.textPrimary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(r.padding),
            decoration: BoxDecoration(
              color: UserDesign.surfacePure,
              borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
              boxShadow: UserDesign.softShadow,
            ),
            child: Column(
              children: activities.asMap().entries.map((entry) {
                final index = entry.key;
                final activity = entry.value;
                final isLast = index == activities.length - 1;
                return Column(
                  children: [
                    _buildActivityRow(r, activity),
                    if (!isLast)
                      Divider(height: r.padding, color: UserDesign.surfaceOverlay),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(UserResponsiveData r, dynamic activity) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            color: activity.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.borderRadius),
          ),
          child: Icon(activity.icon, color: activity.color, size: r.iconSize(18)),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: Text(
            activity.label,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: UserDesign.textSecondary,
            ),
          ),
        ),
        Text(
          activity.value,
          style: GoogleFonts.inter(
            fontSize: r.bodyS,
            fontWeight: FontWeight.w700,
            color: UserDesign.textPrimary,
          ),
        ),
      ],
    );
  }

  // ==================== SETTINGS SECTION ====================


  Widget _buildModernMenuItem(UserResponsiveData r, dynamic item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          item.onTap();
        },
        borderRadius: BorderRadius.circular(r.borderRadius),
        child: Padding(
          padding: EdgeInsets.all(r.padding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.microPadding + 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color.withOpacity(0.2),
                      item.color. withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(item.icon, color: item.color, size: r.iconSize(22)),
              ),
              SizedBox(width: r.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight.w600,
                        color: UserDesign.textPrimary,
                      ),
                    ),
                    SizedBox(height: r.atomicPadding),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.inter(
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
      padding: EdgeInsets.symmetric(horizontal: r.padding),
      child:  Divider(height: 1, color: UserDesign. surfaceOverlay),
    );
  }

  // ==================== FOOTER SECTION ====================


  Widget _buildLogoutButton(UserResponsiveData r) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _viewModel.showLogoutConfirmation();
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
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(
            color: UserDesign.error.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
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
    ScaffoldMessenger.of(context).showSnackBar(
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
                style:  GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight. w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: UserDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}