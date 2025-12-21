import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:neat_now/models/employee/leaderboard_models.dart';
import 'package:neat_now/viewmodels/employee/leaderboard_viewmodel.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/leaderboard_components/leaderboard_header.dart';
import 'package:neat_now/views/employee/leaderboard_components/current_user_card.dart';
import 'package:neat_now/views/employee/leaderboard_components/podium_section.dart';
import 'package:neat_now/views/employee/leaderboard_components/tier_filter.dart';
import 'package:neat_now/views/employee/leaderboard_components/leaderboard_list.dart';
import 'package:neat_now/views/employee/leaderboard_components/tier_info_section.dart';

/// ==================== LEADERBOARD PAGE ====================
class LeaderboardPage extends StatefulWidget {
  final Future<List<LeaderboardEntry>> leaderboardFuture;
  final String currentUserId;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;

  const LeaderboardPage({
    super.key,
    required this.leaderboardFuture,
    required this.currentUserId,
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

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _podiumAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // ViewModel
  late LeaderboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initViewModel();
  }

  void _initAnimations() {
    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    // Slide Animation
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

    // Podium Animation
    _podiumController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _podiumAnimation = CurvedAnimation(
      parent: _podiumController,
      curve: Curves.easeOutBack,
    );

    // Shimmer Animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate Animation
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();
    _podiumController.forward();
  }

  void _initViewModel() {
    _viewModel = LeaderboardViewModel(
      currentUserId: widget.currentUserId,
      fetchLeaderboard: () => widget.leaderboardFuture,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _podiumController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    HapticFeedback.mediumImpact();
    _rotateController.forward(from: 0);
    _podiumController.forward(from: 0);
    _viewModel.refresh();
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return ChangeNotifierProvider<LeaderboardViewModel>.value(
      value: _viewModel,
      child: Consumer<LeaderboardViewModel>(
        builder: (context, vm, _) {
          // Handle different view states
          if (vm.isLoading) {
            return LoadingState(responsive: r);
          }
          if (vm.hasError) {
            return ErrorState(
              responsive: r,
              error: vm.errorMessage ?? 'Unknown error',
              onRetry: _handleRefresh,
            );
          }
          if (vm.isEmpty) {
            return EmptyState(responsive: r);
          }

          return _buildContent(r, vm);
        },
      ),
    );
  }

  Widget _buildContent(EmployeeResponsiveData r, LeaderboardViewModel vm) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          onRefresh: () async => _handleRefresh(),
          color: const Color(0xFF2AC2AB),
          backgroundColor: Colors.white,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ==================== HEADER ====================
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(r.padding),
                  child: LeaderboardHeader(
                    responsive: r,
                    rotateAnimation: _rotateController,
                    onRefresh: _handleRefresh,
                  ),
                ),
              ),

              // ==================== CURRENT USER CARD ====================
              if (vm.currentUserEntry != null)
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      // Safe promotion: Dart now knows entry is non-null
                      final entry = vm.currentUserEntry!;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: r.padding),
                        child: CurrentUserCard(
                          responsive: r,
                          entry: entry,
                          rank: vm.currentUserRank,
                          tier: vm.currentUserTier,
                          pulseAnimation: _pulseAnimation,
                          shimmerAnimation: _shimmerAnimation,
                        ),
                      );
                    },
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // ==================== TOP 3 PODIUM ====================
              if (vm.topThree.length >= 3)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: PodiumSection(
                      responsive: r,
                      topThree: vm.topThree,
                      podiumAnimation: _podiumAnimation,
                      shimmerAnimation: _shimmerAnimation,
                      pulseAnimation: _pulseAnimation,
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: r.sectionSpacing)),

              // ==================== TIER FILTER ====================
              SliverToBoxAdapter(
                child: TierFilterSection(
                  responsive: r,
                  viewModel: vm,
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: r.microPadding)),

              // ==================== SEARCH BAR ====================
              if (r.showDetailedContent)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: r.padding),
                    child: SearchBarWidget(
                      responsive: r,
                      controller: _searchController,
                      viewModel: vm,
                    ),
                  ),
                ),

              if (r.showDetailedContent)
                SliverToBoxAdapter(child: SizedBox(height: r.microPadding)),

              // ==================== LEADERBOARD LIST ====================
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.padding),
                  child: LeaderboardListSection(
                    responsive: r,
                    viewModel: vm,
                  ),
                ),
              ),

              // ==================== TIER INFO SECTION ====================
              if (r.showDetailedContent)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(r.padding),
                    child: TierInfoSection(responsive: r),
                  ),
                ),

              // ==================== BOTTOM PADDING ====================
              SliverToBoxAdapter(
                child: SizedBox(height: r.safePaddingBottom + 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder widgets in case they are not defined elsewhere in your project
// (Remove these if you already have them defined)

class LoadingState extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  const LoadingState({super.key, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: const Color(0xFF2AC2AB)),
    );
  }
}

class ErrorState extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final String error;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.responsive,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
          SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: Text('Retry')),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  const EmptyState({super.key, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('No leaderboard data available yet.'),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final TextEditingController controller;
  final LeaderboardViewModel viewModel;

  const SearchBarWidget({
    super.key,
    required this.responsive,
    required this.controller,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search employees...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      //onChanged: viewModel.search,
    );
  }
}