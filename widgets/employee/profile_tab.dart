import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'package:neat_now/widgets/employee/employee_feedback_page.dart';

/// ==================== DESIGN SYSTEM ====================
class ProfileDesign {
  // Primary Accent - Oklch(0.696 0.17 162. 48) converted
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color primaryTealGlow = Color(0xFF95E1D3);

  // Surfaces
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);
  static const Color surfaceOverlay = Color(0xFFF3F4F6);

  // Text
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);

  // Badge Colors
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color. withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryTeal, primaryTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get headerGradient => LinearGradient(
    colors: [
      primaryTeal. withOpacity(0.15),
      primaryTealLight.withOpacity(0.05),
      surfacePure,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [0.0, 0.5, 1.0],
  );

  static LinearGradient shimmerGradient(double value) => LinearGradient(
    colors: [
      Colors.white.withOpacity(0.0),
      Colors. white.withOpacity(0.4),
      Colors. white.withOpacity(0.0),
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment(-1.0 + value * 3, 0),
    end: Alignment(value * 3, 0),
  );
}

/// ==================== BADGE TIER ====================
enum BadgeTier { platinum, gold, silver, bronze, none }

extension BadgeTierExtension on BadgeTier {
  String get name {
    switch (this) {
      case BadgeTier. platinum: return 'Platinum';
      case BadgeTier.gold: return 'Gold';
      case BadgeTier.silver: return 'Silver';
      case BadgeTier.bronze: return 'Bronze';
      case BadgeTier.none: return 'Member';
    }
  }

  IconData get icon {
    switch (this) {
      case BadgeTier.platinum: return Icons.diamond_rounded;
      case BadgeTier.gold: return Icons.workspace_premium_rounded;
      case BadgeTier.silver: return Icons.military_tech_rounded;
      case BadgeTier.bronze: return Icons.emoji_events_rounded;
      case BadgeTier.none: return Icons.person_rounded;
    }
  }

  List<Color> get colors {
    switch (this) {
      case BadgeTier. platinum:
        return [const Color(0xFFE8E8E8), const Color(0xFFB8B8B8), const Color(0xFFE8E8E8)];
      case BadgeTier.gold:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500), const Color(0xFFFFD700)];
      case BadgeTier.silver:
        return [const Color(0xFFE8E8E8), const Color(0xFFC0C0C0), const Color(0xFFE8E8E8)];
      case BadgeTier. bronze:
        return [const Color(0xFFDDA15E), const Color(0xFFCD7F32), const Color(0xFFDDA15E)];
      case BadgeTier. none:
        return [ProfileDesign.textTertiary, ProfileDesign.textSecondary, ProfileDesign.textTertiary];
    }
  }

  Color get glowColor {
    switch (this) {
      case BadgeTier. platinum: return const Color(0xFFE8E8E8);
      case BadgeTier. gold: return const Color(0xFFFFD700);
      case BadgeTier.silver: return const Color(0xFFC0C0C0);
      case BadgeTier. bronze: return const Color(0xFFCD7F32);
      case BadgeTier.none: return ProfileDesign.textTertiary;
    }
  }

  static BadgeTier fromRating(double rating) {
    if (rating >= 4.8) return BadgeTier.platinum;
    if (rating >= 4.5) return BadgeTier.gold;
    if (rating >= 4.0) return BadgeTier.silver;
    if (rating >= 3.5) return BadgeTier. bronze;
    return BadgeTier. none;
  }
}

/// ==================== EMPLOYEE PROFILE TAB ====================
class EmployeeProfileTab extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? employeeStats;
  final bool isDemoMode;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdate;
  final EmployeeResponsiveData responsive;

  const EmployeeProfileTab({
    super.key,
    required this.userData,
    required this.employeeStats,
    required this.isDemoMode,
    required this.onLogout,
    required this.onProfileUpdate,
    required this. responsive,
  });

  @override
  State<EmployeeProfileTab> createState() => _EmployeeProfileTabState();
}

class _EmployeeProfileTabState extends State<EmployeeProfileTab>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _statsController;
  late AnimationController _badgesController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _headerScaleAnimation;
  late Animation<Offset> _nameSlideAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _badgesAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  // State
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _isEditMode = false;
  bool _showLogoutConfirm = false;
  bool _showFeedbackPage = false;
  bool _showTaskHistoryPage = false;

  // Data
  String get _name => widget.userData? ['name'] ?? widget.userData?['fullName'] ?? 'Employee';
  String get _email => widget. userData?['email'] ?? '';
  String get _phone => widget.userData?['phone'] ??  '';
  String get _employeeId => widget. userData?['employeeId'] ?? widget.userData?['id']?.toString() ?? 'N/A';
  String?  get _profileImage => widget.userData? ['profileImage'] ?? widget.userData?['avatar'];
  double get _rating => (widget.employeeStats?['rating'] ?? widget.employeeStats?['averageRating'] ??  4.5). toDouble();
  int get _completedTasks => widget.employeeStats? ['completedTasks'] ?? widget.employeeStats? ['completed'] ?? 0;
  int get _pendingTasks => widget.employeeStats? ['pendingTasks'] ?? widget.employeeStats?['pending'] ?? 0;
  int get _totalPoints => widget.employeeStats?['totalPoints'] ?? widget.employeeStats?['points'] ?? 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Header animations
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutQuart,
    );
    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves. elasticOut),
    );
    _nameSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.3, 1.0, curve: Curves. easeOutCubic),
    ));

    // Stats animations
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );

    // Badges animations
    _badgesController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _badgesAnimation = CurvedAnimation(
      parent: _badgesController,
      curve: Curves.easeOutBack,
    );

    // Shimmer (continuous)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: 0, end: 1). animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Pulse (continuous)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave (continuous)
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi). animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _statsController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _badgesController.forward();
  }

  void _onScroll() {
    if (mounted) {
      setState(() => _scrollOffset = _scrollController.offset);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController. dispose();
    _badgesController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    super. dispose();
  }

  // ==================== NAVIGATION METHODS ====================
  void _navigateToFeedback() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EmployeeFeedbackPage(
          responsive: widget.responsive,
          onBack: () => Navigator.pop(context),
          overallRating: _rating,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToTaskHistory() {
    HapticFeedback. lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EmployeeTaskHistoryPage(
          responsive: widget.responsive,
          onBack: () => Navigator.pop(context),
          completedTasks: _completedTasks,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSettings() {
    HapticFeedback.lightImpact();
    Navigator. push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EmployeeSettingsPage(
          responsive: widget.responsive,
          onBack: () => Navigator.pop(context),
          isDemoMode: widget. isDemoMode,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToHelp() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EmployeeHelpPage(
          responsive: widget.responsive,
          onBack: () => Navigator.pop(context),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final tier = BadgeTierExtension.fromRating(_rating);

    return Stack(
      children: [
        // Main content
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header background with wave
            SliverToBoxAdapter(child: _buildHeaderBackground(r)),

            // Profile header
            SliverToBoxAdapter(child: _buildProfileHeader(r, tier)),

            // Stats section
            SliverToBoxAdapter(child: _buildStatsSection(r)),

            // Badges section
            SliverToBoxAdapter(child: _buildBadgesSection(r)),

            // Menu items
            SliverToBoxAdapter(child: _buildMenuSection(r)),

            // Demo mode banner
            if (widget.isDemoMode)
              SliverToBoxAdapter(child: _buildDemoModeBanner(r)),

            // Logout button
            SliverToBoxAdapter(child: _buildLogoutButton(r)),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: r.safePaddingBottom + 100),
            ),
          ],
        ),

        // Edit profile sheet
        if (_isEditMode)
          _EditProfileSheet(
            responsive: r,
            name: _name,
            email: _email,
            phone: _phone,
            profileImage: _profileImage,
            onClose: () => setState(() => _isEditMode = false),
            onSave: (data) {
              setState(() => _isEditMode = false);
              widget.onProfileUpdate();
              _showSuccessSnackBar('Profile updated successfully');
            },
          ),

        // Logout confirmation
        if (_showLogoutConfirm)
          _LogoutConfirmDialog(
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.inter(fontWeight: FontWeight. w500)),
          ],
        ),
        backgroundColor: ProfileDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ==================== HEADER BACKGROUND ====================
  Widget _buildHeaderBackground(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return Container(
          height: r.dimension(180),
          decoration: BoxDecoration(
            gradient: ProfileDesign. headerGradient,
          ),
          child: CustomPaint(
            painter: _WaveBackgroundPainter(
              animation: _waveAnimation. value,
              color: ProfileDesign. primaryTeal. withOpacity(0.1),
            ),
            size: Size(r.effectiveWidth, r. dimension(180)),
          ),
        );
      },
    );
  }

  // ==================== PROFILE HEADER ====================
  Widget _buildProfileHeader(EmployeeResponsiveData r, BadgeTier tier) {
    return Transform. translate(
      offset: Offset(0, -r.dimension(70)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: r.padding),
        child: Column(
          children: [
            // Profile image
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: ScaleTransition(
                scale: _headerScaleAnimation,
                child: _buildProfileImage(r, tier),
              ),
            ),

            SizedBox(height: r.microPadding),

            // Name and badge
            SlideTransition(
              position: _nameSlideAnimation,
              child: FadeTransition(
                opacity: _headerFadeAnimation,
                child: Column(
                  children: [
                    Text(
                      _name,
                      style: GoogleFonts.inter(
                        fontSize: r.headingM,
                        fontWeight: FontWeight. w800,
                        color: ProfileDesign.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: r.atomicPadding),
                    Text(
                      'Employee ID: $_employeeId',
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: ProfileDesign.textSecondary,
                      ),
                    ),
                    SizedBox(height: r.microPadding),
                    _buildTierBadge(r, tier),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(EmployeeResponsiveData r, BadgeTier tier) {
    final size = r.dimension(110);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: tier == BadgeTier. platinum || tier == BadgeTier.gold
              ? _pulseAnimation.value
              : 1.0,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          Container(
            width: size + 16,
            height: size + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tier. glowColor. withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Gradient border
          Container(
            width: size + 6,
            height: size + 6,
            decoration: BoxDecoration(
              shape: BoxShape. circle,
              gradient: LinearGradient(
                colors: tier.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Profile image
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ProfileDesign. surfacePure,
              border: Border.all(color: ProfileDesign. surfacePure, width: 3),
              boxShadow: ProfileDesign.elevatedShadow,
            ),
            child: ClipOval(
              child: _profileImage != null && _profileImage! .isNotEmpty
                  ? Image.network(
                _profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(r, size),
              )
                  : _buildAvatarPlaceholder(r, size),
            ),
          ),

          // Tier icon
          Positioned(
            bottom: 0,
            right: 0,
            child: _buildTierIconBadge(r, tier),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(EmployeeResponsiveData r, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: ProfileDesign. primaryGradient,
      ),
      child: Center(
        child: Text(
          _name. isNotEmpty ?  _name[0]. toUpperCase() : '? ',
          style: GoogleFonts. inter(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTierIconBadge(EmployeeResponsiveData r, BadgeTier tier) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets. all(r.microPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: tier.colors),
            shape: BoxShape.circle,
            boxShadow: ProfileDesign.glowShadow(tier.glowColor),
          ),
          child: Stack(
            children: [
              Icon(
                tier. icon,
                size: r.iconSize(20),
                color: tier == BadgeTier. silver || tier == BadgeTier.platinum
                    ? ProfileDesign.textPrimary
                    : Colors.white,
              ),
              if (tier == BadgeTier.platinum || tier == BadgeTier.gold)
                Positioned. fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ProfileDesign.shimmerGradient(_shimmerAnimation.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTierBadge(EmployeeResponsiveData r, BadgeTier tier) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets. symmetric(
            horizontal: r. padding,
            vertical: r.microPadding,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: tier.colors),
            borderRadius: BorderRadius. circular(r.pillBorderRadius),
            boxShadow: ProfileDesign.glowShadow(tier.glowColor),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize. min,
                children: [
                  Icon(
                    tier.icon,
                    size: r.iconSize(16),
                    color: tier == BadgeTier.silver || tier == BadgeTier.platinum
                        ? ProfileDesign.textPrimary
                        : Colors.white,
                  ),
                  SizedBox(width: r.nanoPadding),
                  Text(
                    '${tier.name} Member',
                    style: GoogleFonts.inter(
                      fontSize: r. captionM,
                      fontWeight: FontWeight. w700,
                      color: tier == BadgeTier.silver || tier == BadgeTier. platinum
                          ?  ProfileDesign.textPrimary
                          : Colors.white,
                    ),
                  ),
                ],
              ),
              if (tier == BadgeTier.platinum || tier == BadgeTier.gold)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ProfileDesign.shimmerGradient(_shimmerAnimation.value),
                      borderRadius: BorderRadius.circular(r.pillBorderRadius),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==================== STATS SECTION ====================
  Widget _buildStatsSection(EmployeeResponsiveData r) {
    return Transform.translate(
      offset: Offset(0, -r. dimension(40)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: r.padding),
        child: Container(
          padding: EdgeInsets. all(r.padding),
          decoration: BoxDecoration(
            color: ProfileDesign.surfacePure,
            borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
            boxShadow: ProfileDesign.elevatedShadow,
          ),
          child: Column(
            children: [
              // Section title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets. all(r.nanoPadding),
                    decoration: BoxDecoration(
                      color: ProfileDesign.primaryTeal. withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: ProfileDesign. primaryTeal,
                      size: r.iconSize(18),
                    ),
                  ),
                  SizedBox(width: r.microPadding),
                  Text(
                    'Performance Stats',
                    style: GoogleFonts.inter(
                      fontSize: r. bodyS,
                      fontWeight: FontWeight. w700,
                      color: ProfileDesign. textPrimary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.padding),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      r,
                      'Completed',
                      _completedTasks,
                      Icons.check_circle_rounded,
                      ProfileDesign.success,
                    ),
                  ),
                  _buildStatDivider(r),
                  Expanded(
                    child: _buildStatItem(
                      r,
                      'Pending',
                      _pendingTasks,
                      Icons.schedule_rounded,
                      ProfileDesign. warning,
                    ),
                  ),
                  _buildStatDivider(r),
                  Expanded(
                    child: _buildRatingStatItem(r),
                  ),
                ],
              ),

              SizedBox(height: r.padding),

              // Progress bar
              _buildCompletionProgress(r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      EmployeeResponsiveData r,
      String label,
      int value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            color: color. withOpacity(0.1),
            borderRadius: BorderRadius.circular(r. borderRadius),
          ),
          child: Icon(icon, color: color, size: r.iconSize(22)),
        ),
        SizedBox(height: r.microPadding),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Text(
              '$animValue',
              style: GoogleFonts.inter(
                fontSize: r.headingS,
                fontWeight: FontWeight.w800,
                color: ProfileDesign.textPrimary,
              ),
            );
          },
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: r.captionS,
            color: ProfileDesign. textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStatItem(EmployeeResponsiveData r) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ProfileDesign.gold. withOpacity(0.2), ProfileDesign. gold. withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(r.borderRadius),
          ),
          child: Icon(Icons.star_rounded, color: ProfileDesign.gold, size: r.iconSize(22)),
        ),
        SizedBox(height: r.microPadding),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _rating),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Text(
              animValue.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: r.headingS,
                fontWeight: FontWeight.w800,
                color: ProfileDesign.textPrimary,
              ),
            );
          },
        ),
        _buildAnimatedStars(r),
      ],
    );
  }

  Widget _buildAnimatedStars(EmployeeResponsiveData r) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _rating),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = (animValue - index). clamp(0.0, 1.0);
            return Icon(
              starValue >= 1
                  ? Icons. star_rounded
                  : (starValue > 0 ?  Icons.star_half_rounded : Icons. star_outline_rounded),
              color: ProfileDesign.gold,
              size: r.iconSize(12),
            );
          }),
        );
      },
    );
  }

  Widget _buildStatDivider(EmployeeResponsiveData r) {
    return Container(
      width: 1,
      height: r.dimension(60),
      color: ProfileDesign. surfaceOverlay,
    );
  }

  Widget _buildCompletionProgress(EmployeeResponsiveData r) {
    final total = _completedTasks + _pendingTasks;
    final progress = total > 0 ?  _completedTasks / total : 0.0;

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Task Completion Rate',
    style: GoogleFonts.inter(
    fontSize: r. captionM,
    color: ProfileDesign. textSecondary,
    ),
    ),
    TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: progress * 100),
    duration: const Duration(milliseconds: 1500),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
    return Text(
    '${value.round()}%',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    fontWeight: FontWeight. w700,
    color: ProfileDesign.primaryTeal,
    ),
    );
    },
    ),
    ],
    ),
    SizedBox(height: r.nanoPadding),
    TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: progress),
    duration: const Duration(milliseconds: 1500),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
    return Stack(
    children: [
    Container(
    height: r.dimension(8),
    decoration: BoxDecoration(
    color: ProfileDesign.surfaceOverlay,
    borderRadius: BorderRadius.circular(r.pillBorderRadius),
    ),
    ),
    FractionallySizedBox(
    widthFactor: value,
    child: Container(
    height: r. dimension(8),
    decoration: BoxDecoration(
    gradient: ProfileDesign.primaryGradient,
    borderRadius: BorderRadius.circular(r. pillBorderRadius),
    boxShadow: ProfileDesign.glowShadow(ProfileDesign.primaryTeal),
    ),
    ),
    ),
    ],
    );
    },
    ),
    ],
    );
  }

  // ==================== BADGES SECTION ====================
  Widget _buildBadgesSection(EmployeeResponsiveData r) {
    final badges = _getEarnedBadges();

    return Transform.translate(
      offset: Offset(0, -r.dimension(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r. padding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets. all(r.nanoPadding),
                  decoration: BoxDecoration(
                    color: ProfileDesign.purple. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.smallBorderRadius),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: ProfileDesign. purple,
                    size: r.iconSize(18),
                  ),
                ),
                SizedBox(width: r.microPadding),
                Text(
                  'Earned Badges',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w700,
                    color: ProfileDesign.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${badges.length} badges',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: ProfileDesign. textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: r.microPadding),

          SizedBox(
            height: r.dimension(110),
            child: ListView.builder(
              scrollDirection: Axis. horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets. symmetric(horizontal: r. padding),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                return ScaleTransition(
                  scale: _badgesAnimation,
                  child: _buildBadgeItem(r, badges[index], index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_BadgeInfo> _getEarnedBadges() {
    return [
      _BadgeInfo('Speed Star', Icons.bolt_rounded, ProfileDesign.warning, '50 tasks in a month'),
      _BadgeInfo('Top Rated', Icons.star_rounded, ProfileDesign.gold, '5. 0 average rating'),
      _BadgeInfo('Early Bird', Icons.wb_sunny_rounded, ProfileDesign.success, '20 early completions'),
      _BadgeInfo('Team Player', Icons.group_rounded, ProfileDesign.info, 'Helped colleagues'),
      _BadgeInfo('Marathon', Icons.directions_run_rounded, ProfileDesign.purple, '100 tasks total'),
    ];
  }

  Widget _buildBadgeItem(EmployeeResponsiveData r, _BadgeInfo badge, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBadgeDetails(r, badge);
      },
      child: Container(
        width: r.dimension(90),
        margin: EdgeInsets.only(right: r. microPadding),
        padding: EdgeInsets. all(r.microPadding),
        decoration: BoxDecoration(
          color: ProfileDesign.surfacePure,
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          boxShadow: ProfileDesign. softShadow,
          border: Border.all(color: badge.color. withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            Container(
              padding: EdgeInsets. all(r.microPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [badge.color. withOpacity(0.2), badge. color.withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(badge.icon, color: badge.color, size: r.iconSize(24)),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              badge.name,
              style: GoogleFonts. inter(
                fontSize: r.captionXS,
                fontWeight: FontWeight. w600,
                color: ProfileDesign.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(EmployeeResponsiveData r, _BadgeInfo badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BadgeDetailsSheet(badge: badge, responsive: r),
    );
  }

  // ==================== MENU SECTION ====================
  Widget _buildMenuSection(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets. symmetric(horizontal: r.padding),
      child: Container(
        decoration: BoxDecoration(
          color: ProfileDesign.surfacePure,
          borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
          boxShadow: ProfileDesign.softShadow,
        ),
        child: Column(
          children: [
            _buildMenuItem(
              r,
              icon: Icons.edit_rounded,
              label: 'Edit Profile',
              color: ProfileDesign. primaryTeal,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isEditMode = true);
              },
            ),
            _buildMenuDivider(r),
            _buildMenuItem(
              r,
              icon: Icons.history_rounded,
              label: 'Task History',
              color: ProfileDesign. purple,
              onTap: _navigateToTaskHistory,
            ),
            _buildMenuDivider(r),
            _buildMenuItem(
              r,
              icon: Icons. feedback_rounded,
              label: 'View Feedback',
              color: ProfileDesign.info,
              onTap: _navigateToFeedback,
            ),
            _buildMenuDivider(r),
            _buildMenuItem(
              r,
              icon: Icons. settings_rounded,
              label: 'Settings',
              color: ProfileDesign. textSecondary,
              onTap: _navigateToSettings,
            ),
            _buildMenuDivider(r),
            _buildMenuItem(
              r,
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              color: ProfileDesign. success,
              onTap: _navigateToHelp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius. circular(r.borderRadius),
        child: Padding(
          padding: EdgeInsets. all(r.padding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets. all(r.microPadding),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r. borderRadius),
                ),
                child: Icon(icon, color: color, size: r.iconSize(20)),
              ),
              SizedBox(width: r.padding),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight. w500,
                    color: ProfileDesign. textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: ProfileDesign.textTertiary,
                size: r.iconSize(22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r. padding),
      child: Divider(height: 1, color: ProfileDesign. surfaceOverlay),
    );
  }

  // ==================== DEMO MODE BANNER ====================
  Widget _buildDemoModeBanner(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: Container(
        padding: EdgeInsets. all(r.padding),
        decoration: BoxDecoration(
          color: ProfileDesign.warning. withOpacity(0.1),
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          border: Border.all(color: ProfileDesign.warning.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: ProfileDesign.warning,
                borderRadius: BorderRadius. circular(r.borderRadius),
              ),
              child: Icon(Icons.science_rounded, color: Colors.white, size: r.iconSize(20)),
            ),
            SizedBox(width: r.padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Mode Active',
                    style: GoogleFonts.inter(
                      fontSize: r. bodyS,
                      fontWeight: FontWeight.w700,
                      color: ProfileDesign.warning,
                    ),
                  ),
                  Text(
                    'You\'re viewing sample data',
                    style: GoogleFonts. inter(
                      fontSize: r.captionS,
                      color: ProfileDesign.textSecondary,
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

  // ==================== LOGOUT BUTTON ====================
  Widget _buildLogoutButton(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: _AnimatedButton(
        icon: Icons.logout_rounded,
        label: 'Sign Out',
        color: ProfileDesign. error,
        responsive: r,
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() => _showLogoutConfirm = true);
        },
      ),
    );
  }
}

// ==================== ANIMATED BUTTON ====================
class _AnimatedButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final EmployeeResponsiveData responsive;
  final VoidCallback onTap;

  const _AnimatedButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.responsive,
    required this. onTap,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller. dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: r.buttonHeight,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.borderRadius),
            border: Border.all(color: widget.color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              Icon(widget.icon, color: widget.color, size: r. iconSize(20)),
              SizedBox(width: r. nanoPadding),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== BADGE INFO ====================
class _BadgeInfo {
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  _BadgeInfo(this.name, this.icon, this. color, this.description);
}

// ==================== BADGE DETAILS SHEET ====================
class _BadgeDetailsSheet extends StatefulWidget {
  final _BadgeInfo badge;
  final EmployeeResponsiveData responsive;

  const _BadgeDetailsSheet({required this.badge, required this.responsive});

  @override
  State<_BadgeDetailsSheet> createState() => _BadgeDetailsSheetState();
}

class _BadgeDetailsSheetState extends State<_BadgeDetailsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget. responsive;
    final badge = widget.badge;

    return Container(
      padding: EdgeInsets.all(r.largePadding),
      decoration: BoxDecoration(
        color: ProfileDesign.surfacePure,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.extraLargeBorderRadius)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize. min,
          children: [
            Container(
              width: r.dimension(40),
              height: r.dimension(4),
              decoration: BoxDecoration(
                color: ProfileDesign.textLight,
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
            ),
            SizedBox(height: r. largePadding),

            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: EdgeInsets. all(r.largePadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [badge.color.withOpacity(0.2), badge.color. withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: ProfileDesign.glowShadow(badge.color),
                ),
                child: Icon(badge.icon, color: badge.color, size: r.iconSize(48)),
              ),
            ),

            SizedBox(height: r.padding),
            Text(
              badge.name,
              style: GoogleFonts.inter(
                fontSize: r.headingXS,
                fontWeight: FontWeight. w700,
                color: ProfileDesign.textPrimary,
              ),
            ),
            SizedBox(height: r. nanoPadding),

            Container(
              padding: EdgeInsets. symmetric(horizontal: r. padding, vertical: r.microPadding),
              decoration: BoxDecoration(
                color: badge.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
              child: Text(
                badge. description,
                style: GoogleFonts.inter(fontSize: r.bodyS, color: badge.color),
              ),
            ),

            SizedBox(height: r.largePadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton. styleFrom(
                  backgroundColor: badge.color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets. symmetric(vertical: r.microPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r. borderRadius),
                  ),
                  elevation: 0,
                ),
                child: Text('Awesome! ', style: GoogleFonts.inter(fontWeight: FontWeight. w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== WAVE BACKGROUND PAINTER ====================
class _WaveBackgroundPainter extends CustomPainter {
  final double animation;
  final Color color;

  _WaveBackgroundPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * 0.8 +
          math.sin((x / size.width * 2 * math. pi) + animation) * 15 +
          math. sin((x / size.width * 4 * math.pi) + animation * 1.5) * 8;
      path. lineTo(x, y);
    }

    path.lineTo(size.width, size. height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = color. withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);

    for (double x = 0; x <= size. width; x++) {
      final y = size.height * 0.85 +
          math.sin((x / size. width * 2 * math.pi) + animation + math.pi) * 12 +
          math.sin((x / size.width * 3 * math.pi) + animation * 2) * 6;
      path2. lineTo(x, y);
    }

    path2. lineTo(size. width, size.height);
    path2.lineTo(0, size.height);
    path2. close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _WaveBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// ==================== EDIT PROFILE SHEET ====================
class _EditProfileSheet extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final String name;
  final String email;
  final String phone;
  final String?  profileImage;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const _EditProfileSheet({
    required this. responsive,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _newImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves. easeOutCubic));
    _animController.forward();

    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super. dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _newImage = File(image.path));
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 1000));

    widget.onSave({
      'name': _nameController.text. trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return GestureDetector(
        onTap: widget.onClose,
        child: Container(
            color: Colors.black.withOpacity(0.5),
            child: GestureDetector(
                onTap: () {},
                child: SlideTransition(
                    position: _slideAnimation,
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.85,
                          ),
                          decoration: BoxDecoration(
                            color: ProfileDesign.surfacePure,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(r.extraLargeBorderRadius),
                            ),
                          ),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                          // Handle
                          Container(
                          width: r.dimension(40),
                          height: r.dimension(4),
                          margin: EdgeInsets. symmetric(vertical: r.microPadding),
                          decoration: BoxDecoration(
                            color: ProfileDesign.textLight,
                            borderRadius: BorderRadius.circular(r.pillBorderRadius),
                          ),
                        ),

                        // Header
                        Padding(
                            padding: EdgeInsets. symmetric(horizontal: r.padding),
                            child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: widget.onClose,
                                    child: Container(
                                      padding: EdgeInsets. all(r.microPadding),
                                      decoration: BoxDecoration(
                                        color: ProfileDesign.surfaceLight,
                                        borderRadius: BorderRadius. circular(r.borderRadius),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: ProfileDesign. textSecondary,
                                        size: r.iconSize(20),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: r.padding),
                                  Text(
                                    'Edit Profile',
                                    style: GoogleFonts.inter(
                                      fontSize: r.headingXS,
                                      fontWeight: FontWeight. w700,
                                      color: ProfileDesign.textPrimary,
                                    ),
                                  ),
                                ],
                            ),
                        ),

                                SizedBox(height: r.padding),

                                // Content
                                Flexible(
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets. symmetric(horizontal: r. padding),
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        // Profile image
                                        GestureDetector(
                                          onTap: _pickImage,
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: r.dimension(100),
                                                height: r.dimension(100),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  gradient: ProfileDesign.primaryGradient,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(3),
                                                  child: ClipOval(
                                                    child: _newImage != null
                                                        ? Image.file(_newImage!, fit: BoxFit.cover)
                                                        : widget.profileImage != null
                                                        ? Image.network(
                                                      widget.profileImage!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => _buildInitial(r),
                                                    )
                                                        : _buildInitial(r),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  padding: EdgeInsets. all(r.microPadding),
                                                  decoration: BoxDecoration(
                                                    gradient: ProfileDesign. primaryGradient,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: ProfileDesign.surfacePure,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.camera_alt_rounded,
                                                    color: Colors.white,
                                                    size: r.iconSize(16),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: r.largePadding),

                                        // Form fields
                                        _buildTextField(r, _nameController, 'Full Name', Icons.person_rounded),
                                        SizedBox(height: r.microPadding),
                                        _buildTextField(r, _emailController, 'Email', Icons.email_rounded,
                                            keyboardType: TextInputType.emailAddress),
                                        SizedBox(height: r.microPadding),
                                        _buildTextField(r, _phoneController, 'Phone', Icons. phone_rounded,
                                            keyboardType: TextInputType. phone),

                                        SizedBox(height: r.largePadding),
                                      ],
                                    ),
                                  ),
                                ),

                                // Save button
                                Padding(
                                  padding: EdgeInsets. fromLTRB(
                                    r.padding,
                                    r. microPadding,
                                    r.padding,
                                    r.safePaddingBottom + r.microPadding,
                                  ),
                                  child: GestureDetector(
                                    onTap: _isSaving ? null : _save,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: double.infinity,
                                      height: r. buttonHeight + 4,
                                      decoration: BoxDecoration(
                                        gradient: ProfileDesign. primaryGradient,
                                        borderRadius: BorderRadius. circular(r.borderRadius),
                                        boxShadow: ProfileDesign.glowShadow(ProfileDesign.primaryTeal),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment. center,
                                        children: [
                                          if (_isSaving)
                                            SizedBox(
                                              width: r.iconSize(20),
                                              height: r.iconSize(20),
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          else
                                            Icon(
                                              Icons.save_rounded,
                                              color: Colors.white,
                                              size: r.iconSize(20),
                                            ),
                                          SizedBox(width: r.nanoPadding),
                                          Text(
                                            _isSaving ?  'Saving.. .' : 'Save Changes',
                                            style: GoogleFonts.inter(
                                              fontSize: r.bodyS,
                                              fontWeight: FontWeight. w700,
                                              color: Colors.white,
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
            ),
        ),
    );
  }

  Widget _buildInitial(EmployeeResponsiveData r) {
    return Container(
      color: ProfileDesign.surfaceLight,
      child: Center(
        child: Text(
          widget.name. isNotEmpty ? widget.name[0].toUpperCase() : '? ',
          style: GoogleFonts. inter(
            fontSize: r.dimension(40),
            fontWeight: FontWeight.w700,
            color: ProfileDesign.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      EmployeeResponsiveData r,
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: r.captionM,
            fontWeight: FontWeight.w600,
            color: ProfileDesign. textSecondary,
          ),
        ),
        SizedBox(height: r.nanoPadding),
        Container(
          decoration: BoxDecoration(
            color: ProfileDesign.surfaceLight,
            borderRadius: BorderRadius. circular(r.borderRadius),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: ProfileDesign. textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: ProfileDesign.textTertiary,
                size: r.iconSize(20),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r.borderRadius),
                borderSide: BorderSide. none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r.borderRadius),
                borderSide: const BorderSide(color: ProfileDesign. primaryTeal, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: r. microPadding,
                vertical: r. microPadding,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== LOGOUT CONFIRM DIALOG ====================
class _LogoutConfirmDialog extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _LogoutConfirmDialog({
    required this.responsive,
    required this. onConfirm,
    required this. onCancel,
  });

  @override
  State<_LogoutConfirmDialog> createState() => _LogoutConfirmDialogState();
}

class _LogoutConfirmDialogState extends State<_LogoutConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0). animate(
      CurvedAnimation(parent: _animController, curve: Curves. easeOutBack),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController. forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return GestureDetector(
      onTap: widget.onCancel,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.black. withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  margin: EdgeInsets. all(r.largePadding),
                  padding: EdgeInsets. all(r.largePadding),
                  decoration: BoxDecoration(
                    color: ProfileDesign.surfacePure,
                    borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
                    boxShadow: ProfileDesign.elevatedShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets. all(r.padding),
                        decoration: BoxDecoration(
                          color: ProfileDesign.error. withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: ProfileDesign. error,
                          size: r.iconSize(40),
                        ),
                      ),

                      SizedBox(height: r.padding),

                      Text(
                        'Sign Out? ',
                        style: GoogleFonts.inter(
                          fontSize: r. headingXS,
                          fontWeight: FontWeight.w700,
                          color: ProfileDesign.textPrimary,
                        ),
                      ),

                      SizedBox(height: r. nanoPadding),

                      Text(
                        'Are you sure you want to sign out of your account?',
                        style: GoogleFonts.inter(
                          fontSize: r.bodyS,
                          color: ProfileDesign. textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: r.largePadding),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onCancel,
                              child: Container(
                                height: r.buttonHeight,
                                decoration: BoxDecoration(
                                  color: ProfileDesign. surfaceLight,
                                  borderRadius: BorderRadius.circular(r.borderRadius),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.inter(
                                      fontSize: r.bodyS,
                                      fontWeight: FontWeight. w600,
                                      color: ProfileDesign.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: r.microPadding),
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onConfirm,
                              child: Container(
                                height: r. buttonHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ProfileDesign.error,
                                      ProfileDesign.error.withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(r. borderRadius),
                                  boxShadow: ProfileDesign.glowShadow(ProfileDesign.error),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign Out',
                                    style: GoogleFonts.inter(
                                      fontSize: r.bodyS,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
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
        ),
      ),
    );
  }
}

// ==================== TASK HISTORY PAGE ====================
class EmployeeTaskHistoryPage extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onBack;
  final int completedTasks;

  const EmployeeTaskHistoryPage({
    super.key,
    required this.responsive,
    required this. onBack,
    this.completedTasks = 0,
  });

  @override
  State<EmployeeTaskHistoryPage> createState() => _EmployeeTaskHistoryPageState();
}

class _EmployeeTaskHistoryPageState extends State<EmployeeTaskHistoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final List<_TaskHistoryItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves. easeOutCubic);
    _animController.forward();
    _generateSampleTasks();
  }

  void _generateSampleTasks() {
    _tasks.addAll([
      _TaskHistoryItem(
        id: '1',
        type: 'Plastic Waste',
        location: 'Main Street Park',
        completedAt: DateTime. now().subtract(const Duration(hours: 3)),
        rating: 5.0,
        imageUrl: null,
      ),
      _TaskHistoryItem(
        id: '2',
        type: 'Organic Waste',
        location: 'Central Avenue',
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        rating: 4.5,
        imageUrl: null,
      ),
      _TaskHistoryItem(
        id: '3',
        type: 'Mixed Waste',
        location: 'Riverside Garden',
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        rating: 5.0,
        imageUrl: null,
      ),
      _TaskHistoryItem(
        id: '4',
        type: 'Electronic Waste',
        location: 'Tech Park',
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        rating: 4.8,
        imageUrl: null,
      ),
      _TaskHistoryItem(
        id: '5',
        type: 'Construction Debris',
        location: 'Oak Street',
        completedAt: DateTime. now().subtract(const Duration(days: 5)),
        rating: 4.2,
        imageUrl: null,
      ),
    ]);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Scaffold(
      backgroundColor: ProfileDesign. surfaceLight,
      appBar: AppBar(
        backgroundColor: ProfileDesign. surfacePure,
        elevation: 0,
        leading: GestureDetector(
          onTap: widget.onBack,
          child: Container(
            margin: EdgeInsets. all(r.microPadding),
            decoration: BoxDecoration(
              color: ProfileDesign. surfaceLight,
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ProfileDesign.textPrimary,
              size: r.iconSize(18),
            ),
          ),
        ),
        title: Text(
          'Task History',
          style: GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight.w700,
            color: ProfileDesign. textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _tasks.isEmpty
            ? _buildEmptyState(r)
            : ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets. all(r.padding),
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            return _buildTaskCard(r, _tasks[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets. all(r.largePadding),
            decoration: BoxDecoration(
              color: ProfileDesign. purple. withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: ProfileDesign.purple,
              size: r.iconSize(48),
            ),
          ),
          SizedBox(height: r.padding),
          Text(
            'No task history',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w600,
              color: ProfileDesign. textPrimary,
            ),
          ),
          SizedBox(height: r.nanoPadding),
          Text(
            'Completed tasks will appear here',
            style: GoogleFonts.inter(
              fontSize: r. bodyS,
              color: ProfileDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(EmployeeResponsiveData r, _TaskHistoryItem task, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets. only(bottom: r.microPadding),
        padding: EdgeInsets. all(r.padding),
        decoration: BoxDecoration(
          color: ProfileDesign.surfacePure,
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          boxShadow: ProfileDesign. softShadow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: ProfileDesign.success.withOpacity(0.1),
                borderRadius: BorderRadius. circular(r.borderRadius),
              ),
              child: Icon(
                Icons. check_circle_rounded,
                color: ProfileDesign.success,
                size: r.iconSize(24),
              ),
            ),

            SizedBox(width: r.microPadding),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.type,
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w700,
                      color: ProfileDesign. textPrimary,
                    ),
                  ),
                  SizedBox(height: r.atomicPadding),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: r.iconSize(12),
                        color: ProfileDesign. textTertiary,
                      ),
                      SizedBox(width: r. atomicPadding),
                      Expanded(
                        child: Text(
                          task.location,
                          style: GoogleFonts.inter(
                            fontSize: r. captionS,
                            color: ProfileDesign. textSecondary,
                          ),
                          overflow: TextOverflow. ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.atomicPadding),
                  Text(
                    _formatDate(task.completedAt),
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      color: ProfileDesign.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Rating
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r. microPadding,
                vertical: r.nanoPadding,
              ),
              decoration: BoxDecoration(
                color: ProfileDesign.gold. withOpacity(0.1),
                borderRadius: BorderRadius.circular(r. pillBorderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize. min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: r.iconSize(14),
                    color: ProfileDesign. gold,
                  ),
                  SizedBox(width: r.atomicPadding),
                  Text(
                    task.rating.toStringAsFixed(1),
                    style: GoogleFonts. inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight. w700,
                      color: ProfileDesign. gold,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff. inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _TaskHistoryItem {
  final String id;
  final String type;
  final String location;
  final DateTime completedAt;
  final double rating;
  final String?  imageUrl;

  _TaskHistoryItem({
    required this.id,
    required this.type,
    required this. location,
    required this.completedAt,
    required this.rating,
    this.imageUrl,
  });
}

// ==================== SETTINGS PAGE ====================
class EmployeeSettingsPage extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onBack;
  final bool isDemoMode;

  const EmployeeSettingsPage({
    super.key,
    required this.responsive,
    required this. onBack,
    this.isDemoMode = false,
  });

  @override
  State<EmployeeSettingsPage> createState() => _EmployeeSettingsPageState();
}

class _EmployeeSettingsPageState extends State<EmployeeSettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Scaffold(
      backgroundColor: ProfileDesign. surfaceLight,
      appBar: AppBar(
        backgroundColor: ProfileDesign. surfacePure,
        elevation: 0,
        leading: GestureDetector(
          onTap: widget. onBack,
          child: Container(
            margin: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: ProfileDesign. surfaceLight,
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ProfileDesign. textPrimary,
              size: r.iconSize(18),
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts. inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight. w700,
            color: ProfileDesign.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(r.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications section
            _buildSectionTitle(r, 'Notifications'),
            SizedBox(height: r.microPadding),
            _buildSettingsCard(r, [
              _buildSwitchItem(
                r,
                icon: Icons.notifications_rounded,
                label: 'Push Notifications',
                subtitle: 'Receive task updates',
                color: ProfileDesign. info,
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),
              _buildSwitchItem(
                r,
                icon: Icons.volume_up_rounded,
                label: 'Sound',
                subtitle: 'Play notification sounds',
                color: ProfileDesign. purple,
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
            ]),

            SizedBox(height: r.padding),

            // Privacy section
            _buildSectionTitle(r, 'Privacy'),
            SizedBox(height: r. microPadding),
            _buildSettingsCard(r, [
              _buildSwitchItem(
                r,
                icon: Icons. location_on_rounded,
                label: 'Location Services',
                subtitle: 'Allow location access',
                color: ProfileDesign.success,
                value: _locationEnabled,
                onChanged: (v) => setState(() => _locationEnabled = v),
              ),
            ]),

            SizedBox(height: r.padding),

            // Appearance section
            _buildSectionTitle(r, 'Appearance'),
            SizedBox(height: r.microPadding),
            _buildSettingsCard(r, [
              _buildSwitchItem(
                r,
                icon: Icons.dark_mode_rounded,
                label: 'Dark Mode',
                subtitle: 'Use dark theme',
                color: ProfileDesign.textSecondary,
                value: _darkModeEnabled,
                onChanged: (v) => setState(() => _darkModeEnabled = v),
              ),
            ]),

            SizedBox(height: r.padding),

            // About section
            _buildSectionTitle(r, 'About'),
            SizedBox(height: r. microPadding),
            _buildSettingsCard(r, [
              _buildInfoItem(r, 'App Version', '1.0.0'),
              _buildInfoItem(r, 'Build', '2024.12.05'),
            ]),

            SizedBox(height: r.safePaddingBottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(EmployeeResponsiveData r, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: r.captionM,
        fontWeight: FontWeight.w600,
        color: ProfileDesign.textSecondary,
      ),
    );
  }

  Widget _buildSettingsCard(EmployeeResponsiveData r, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: ProfileDesign.surfacePure,
        borderRadius: BorderRadius.circular(r. largeBorderRadius),
        boxShadow: ProfileDesign.softShadow,
      ),
      child: Column(
        children: children. asMap().entries.map((entry) {
          final isLast = entry.key == children.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Padding(
                  padding: EdgeInsets. symmetric(horizontal: r.padding),
                  child: Divider(height: 1, color: ProfileDesign.surfaceOverlay),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchItem(
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required String subtitle,
        required Color color,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets. all(r.microPadding),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius.circular(r. borderRadius),
            ),
            child: Icon(icon, color: color, size: r. iconSize(20)),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w600,
                    color: ProfileDesign.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: r. captionS,
                    color: ProfileDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeColor: ProfileDesign.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(EmployeeResponsiveData r, String label, String value) {
    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment. spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: r. bodyS,
              color: ProfileDesign. textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              fontWeight: FontWeight. w600,
              color: ProfileDesign.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HELP PAGE ====================
class EmployeeHelpPage extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onBack;

  const EmployeeHelpPage({
    super.key,
    required this. responsive,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    final faqs = [
      _FAQItem('How do I complete a task?', 'Navigate to the task, tap "Complete", take a photo of the cleaned area, and submit. '),
      _FAQItem('How is my rating calculated?', 'Your rating is based on citizen feedback after each completed task.'),
      _FAQItem('What are badges? ', 'Badges are achievements you earn for milestones like completing tasks quickly or maintaining high ratings.'),
      _FAQItem('How do I update my profile?', 'Go to Profile > Edit Profile to update your name, email, phone, and photo.'),
      _FAQItem('Who do I contact for support? ', 'Reach out to your supervisor or email support@neatnow.com for assistance. '),
    ];

    return Scaffold(
      backgroundColor: ProfileDesign.surfaceLight,
      appBar: AppBar(
        backgroundColor: ProfileDesign.surfacePure,
        elevation: 0,
        leading: GestureDetector(
          onTap: onBack,
          child: Container(
            margin: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: ProfileDesign.surfaceLight,
              borderRadius: BorderRadius. circular(r.borderRadius),
            ),
            child: Icon(
              Icons. arrow_back_ios_new_rounded,
              color: ProfileDesign.textPrimary,
              size: r.iconSize(18),
            ),
          ),
        ),
        title: Text(
          'Help & Support',
          style: GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight. w700,
            color: ProfileDesign.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(r.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(r.padding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ProfileDesign.primaryTeal. withOpacity(0.1),
                    ProfileDesign.primaryTealLight.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(r.largeBorderRadius),
                border: Border.all(color: ProfileDesign.primaryTeal. withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets. all(r.microPadding),
                    decoration: BoxDecoration(
                      gradient: ProfileDesign.primaryGradient,
                      borderRadius: BorderRadius.circular(r.borderRadius),
                    ),
                    child: Icon(Icons.support_agent_rounded, color: Colors.white, size: r.iconSize(24)),
                  ),
                  SizedBox(width: r.padding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: GoogleFonts.inter(
                            fontSize: r.bodyS,
                            fontWeight: FontWeight. w700,
                            color: ProfileDesign. primaryTeal,
                          ),
                        ),
                        Text(
                          'We\'re here to assist you',
                          style: GoogleFonts. inter(
                            fontSize: r.captionS,
                            color: ProfileDesign.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: r.padding),

            // FAQs
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w700,
                color: ProfileDesign.textPrimary,
              ),
            ),
            SizedBox(height: r. microPadding),

            ... faqs.asMap().entries.map((entry) => _buildFAQCard(r, entry. value, entry.key)),

            SizedBox(height: r.padding),

            // Contact
            Text(
              'Contact Us',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w700,
                color: ProfileDesign.textPrimary,
              ),
            ),
            SizedBox(height: r. microPadding),

            _buildContactCard(r, Icons.email_rounded, 'Email', 'support@neatnow.com', ProfileDesign.info),
            SizedBox(height: r.microPadding),
            _buildContactCard(r, Icons. phone_rounded, 'Phone', '+1 (555) 123-4567', ProfileDesign. success),

            SizedBox(height: r.safePaddingBottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(EmployeeResponsiveData r, _FAQItem faq, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: r.microPadding),
        decoration: BoxDecoration(
          color: ProfileDesign.surfacePure,
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          boxShadow: ProfileDesign. softShadow,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: r. padding, vertical: r.nanoPadding),
          childrenPadding: EdgeInsets.fromLTRB(r.padding, 0, r.padding, r.padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.largeBorderRadius),
          ),
          title: Text(
            faq.question,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              fontWeight: FontWeight.w600,
              color: ProfileDesign. textPrimary,
            ),
          ),
          iconColor: ProfileDesign.primaryTeal,
          collapsedIconColor: ProfileDesign.textTertiary,
          children: [
            Text(
              faq.answer,
              style: GoogleFonts.inter(
                fontSize: r. captionM,
                color: ProfileDesign. textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(EmployeeResponsiveData r, IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        color: ProfileDesign.surfacePure,
        borderRadius: BorderRadius.circular(r. largeBorderRadius),
        boxShadow: ProfileDesign. softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(icon, color: color, size: r.iconSize(20)),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment. start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: r. captionS,
                    color: ProfileDesign.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w600,
                    color: ProfileDesign.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: ProfileDesign.textTertiary, size: r.iconSize(22)),
        ],
      ),
    );
  }
}

class _FAQItem {
  final String question;
  final String answer;

  _FAQItem(this.question, this.answer);
}