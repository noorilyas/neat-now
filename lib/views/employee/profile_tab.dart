import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:neat_now/viewmodels/employee/profile_viewmodel.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/profile_components/profile_header.dart';
import 'package:neat_now/views/employee/profile_components/profile_stats.dart';
import 'package:neat_now/views/employee/profile_components/profile_badges.dart';
import 'package:neat_now/views/employee/profile_components/profile_menu.dart';
import 'package:neat_now/views/employee/profile_components/logout_dialog.dart';
import 'package:neat_now/views/employee/profile_components/edit_profile_sheet.dart';
import 'package:neat_now/views/employee/profile_components/task_history_page.dart';
import 'package:neat_now/views/employee/profile_components/settings_page.dart';
import 'package:neat_now/views/employee/profile_components/help_page.dart';
import 'package:neat_now/views/employee/employee_feedback_page.dart';
import 'dart:math' as math;

/// ==================== EMPLOYEE PROFILE TAB (MVVM) ====================
class EmployeeProfileTab extends StatelessWidget {
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
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:  (_) => ProfileViewModel(
        userData: userData,
        employeeStats: employeeStats,
        isDemoMode: isDemoMode,
      ),
      child: _ProfileTabContent(
        responsive: responsive,
        onLogout: onLogout,
        onProfileUpdate: onProfileUpdate,
      ),
    );
  }
}

/// ==================== PROFILE TAB CONTENT ====================
class _ProfileTabContent extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdate;

  const _ProfileTabContent({
    required this.responsive,
    required this.onLogout,
    required this.onProfileUpdate,
  });

  @override
  State<_ProfileTabContent> createState() => _ProfileTabContentState();
}

class _ProfileTabContentState extends State<_ProfileTabContent>
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

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

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
      parent:  _headerController,
      curve:  Curves.easeOutQuart,
    );
    _headerScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve:  Curves.elasticOut),
    );
    _nameSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset. zero,
    ).animate(CurvedAnimation(
      parent:  _headerController,
      curve:  const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    // Stats animations
    _statsController = AnimationController(
      duration: const Duration(milliseconds:  1500),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent:  _statsController,
      curve:  Curves.easeOutCubic,
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
    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve:  Curves.easeInOut),
    );

    // Pulse (continuous)
    _pulseController = AnimationController(
      duration:  const Duration(milliseconds: 2000),
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
    _waveAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent:  _waveController, curve:  Curves.linear),
    );
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _statsController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _badgesController. forward();
  }

  void _onScroll() {
    if (mounted) {
      setState(() => _scrollOffset = _scrollController. offset);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    _badgesController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==================== NAVIGATION METHODS ====================
  void _navigateToFeedback(BuildContext context, ProfileViewModel vm) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EmployeeFeedbackPage(
          responsive: widget.responsive,
          onBack: () => Navigator.pop(context),
          overallRating: vm.rating,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:  Tween<Offset>(
              begin: const Offset(1, 0),
              end:  Offset.zero,
            ).animate(CurvedAnimation(
              parent:  animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToTaskHistory(BuildContext context, ProfileViewModel vm) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TaskHistoryPage(
          responsive: widget.responsive,
          viewModel: vm,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:  Tween<Offset>(
              begin: const Offset(1, 0),
              end:  Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve:  Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSettings(BuildContext context, ProfileViewModel vm) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SettingsPage(
          responsive: widget.responsive,
          viewModel: vm,
        ),
        transitionsBuilder:  (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:  Tween<Offset>(
              begin: const Offset(1, 0),
              end:  Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds:  300),
      ),
    );
  }

  void _navigateToHelp(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HelpPage(
          responsive: widget.responsive,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:  Tween<Offset>(
              begin: const Offset(1, 0),
              end:  Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve:  Curves.easeOutCubic,
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

    return Consumer<ProfileViewModel>(
      builder:  (context, vm, _) {
        if (vm.isLoading) {
          return _buildLoadingState(r);
        }

        if (vm.hasError) {
          return _buildErrorState(r, vm);
        }

        return Stack(
          children: [
            // Main content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header background with wave
                SliverToBoxAdapter(
                  child:  ProfileHeaderBackground(
                    responsive: r,
                    waveAnimation: _waveAnimation,
                  ),
                ),

                // Profile header
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    responsive: r,
                    viewModel: vm,
                    fadeAnimation: _headerFadeAnimation,
                    scaleAnimation: _headerScaleAnimation,
                    slideAnimation: _nameSlideAnimation,
                    pulseAnimation: _pulseAnimation,
                    shimmerAnimation: _shimmerAnimation,
                  ),
                ),

                // Stats section
                SliverToBoxAdapter(
                  child: ProfileStats(
                    responsive: r,
                    viewModel: vm,
                    statsAnimation: _statsAnimation,
                  ),
                ),

                // Badges section
                SliverToBoxAdapter(
                  child: ProfileBadges(
                    responsive: r,
                    viewModel: vm,
                    badgesAnimation: _badgesAnimation,
                  ),
                ),

                // Menu items
                SliverToBoxAdapter(
                  child: ProfileMenu(
                    responsive: r,
                    viewModel: vm,
                    onEditProfile: () => vm.setEditMode(true),
                    onTaskHistory: () => _navigateToTaskHistory(context, vm),
                    onFeedback: () => _navigateToFeedback(context, vm),
                    onSettings: () => _navigateToSettings(context, vm),
                    onHelp: () => _navigateToHelp(context),
                  ),
                ),

                // Demo mode banner
                if (vm.isDemoMode)
                  SliverToBoxAdapter(
                    child: _buildDemoModeBanner(r),
                  ),

                // Logout button
                SliverToBoxAdapter(
                  child: _buildLogoutButton(r, vm),
                ),

                // Bottom spacing
                SliverToBoxAdapter(
                  child: SizedBox(height: r.safePaddingBottom + 100),
                ),
              ],
            ),

            // Edit profile sheet
            if (vm. isEditMode)
              EditProfileSheet(
                responsive: r,
                viewModel: vm,
                onSuccess: () {
                  vm.setEditMode(false);
                  widget.onProfileUpdate();
                  _showSuccessSnackBar(context, 'Profile updated successfully');
                },
              ),

            // Logout confirmation
            if (vm.showLogoutConfirm)
              LogoutConfirmDialog(
                responsive: r,
                onConfirm: () {
                  vm.setLogoutConfirm(false);
                  widget. onLogout();
                },
                onCancel: () => vm.setLogoutConfirm(false),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ProfileDesign.primaryTeal),
          ),
          SizedBox(height: r.padding),
          Text(
            'Loading profile...',
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: ProfileDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(EmployeeResponsiveData r, ProfileViewModel vm) {
    return Center(
      child:  Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(r.largePadding),
              decoration:  BoxDecoration(
                color:  ProfileDesign.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: r.iconSize(48),
                color: ProfileDesign.error,
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'Failed to load profile',
              style:  GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: ProfileDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              vm.errorMessage ?? 'Unknown error',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: ProfileDesign.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.padding),
            ElevatedButton. icon(
              onPressed: () => vm.refresh(),
              icon: Icon(Icons.refresh_rounded, size: r.iconSize(18)),
              label: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileDesign.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: r.largePadding,
                  vertical: r.microPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoModeBanner(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: ProfileDesign.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(color: ProfileDesign.warning. withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: ProfileDesign.warning,
                borderRadius: BorderRadius.circular(r.borderRadius),
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
                      fontSize: r.bodyS,
                      fontWeight: FontWeight. w700,
                      color: ProfileDesign.warning,
                    ),
                  ),
                  Text(
                    'You\'re viewing sample data',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color:  ProfileDesign.textSecondary,
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

  Widget _buildLogoutButton(EmployeeResponsiveData r, ProfileViewModel vm) {
    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          vm.setLogoutConfirm(true);
        },
        child: Container(
          height: r.buttonHeight,
          decoration: BoxDecoration(
            color: ProfileDesign.error. withOpacity(0.1),
            borderRadius: BorderRadius. circular(r.borderRadius),
            border: Border.all(color: ProfileDesign.error.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: ProfileDesign.error, size: r.iconSize(20)),
              SizedBox(width:  r.nanoPadding),
              Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w600,
                  color: ProfileDesign.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: ProfileDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}