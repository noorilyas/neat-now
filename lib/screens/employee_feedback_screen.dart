import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

/// ==================== DESIGN SYSTEM ====================
class FeedbackDesign {
  // Primary Accent
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);

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

  // Rating Colors
  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF8DC);

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

  static LinearGradient get goldGradient => const LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment. topLeft,
    end: Alignment. bottomRight,
  );
}

/// ==================== FEEDBACK MODEL ====================
class FeedbackItem {
  final String id;
  final String userName;
  final String?  userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final String taskType;
  final String?  taskLocation;
  final bool isPositive;
  final List<String> tags;

  FeedbackItem({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this. rating,
    required this.comment,
    required this.date,
    required this.taskType,
    this.taskLocation,
    required this.isPositive,
    this.tags = const [],
  });
}

/// ==================== EMPLOYEE FEEDBACK PAGE ====================
class EmployeeFeedbackPage extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onBack;
  final List<FeedbackItem>? feedbackList;
  final double? overallRating;
  final int? totalFeedbacks;

  const EmployeeFeedbackPage({
    super.key,
    required this.responsive,
    required this. onBack,
    this.feedbackList,
    this.overallRating,
    this.totalFeedbacks,
  });

  @override
  State<EmployeeFeedbackPage> createState() => _EmployeeFeedbackPageState();
}

class _EmployeeFeedbackPageState extends State<EmployeeFeedbackPage>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _statsController;
  late AnimationController _shimmerController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _shimmerAnimation;

  // State
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  double _scrollOffset = 0;

  // Sample Data
  late List<FeedbackItem> _feedbackList;
  late double _overallRating;
  late int _totalFeedbacks;
  late int _positiveFeedbacks;
  late int _negativeFeedbacks;

  final List<_FilterOption> _filters = [
    _FilterOption('all', 'All', Icons.all_inbox_rounded, FeedbackDesign. textSecondary),
    _FilterOption('positive', 'Positive', Icons.thumb_up_rounded, FeedbackDesign.success),
    _FilterOption('negative', 'Negative', Icons.thumb_down_rounded, FeedbackDesign. error),
    _FilterOption('recent', 'Recent', Icons.schedule_rounded, FeedbackDesign.info),
  ];

  @override
  void initState() {
    super.initState();
    _initData();
    _initAnimations();
    _scrollController.addListener(_onScroll);
    _startAnimations();
  }

  void _initData() {
    _feedbackList = widget.feedbackList ??  _generateSampleFeedback();
    _overallRating = widget.overallRating ?? 4.7;
    _totalFeedbacks = widget.totalFeedbacks ?? _feedbackList.length;
    _positiveFeedbacks = _feedbackList. where((f) => f.isPositive).length;
    _negativeFeedbacks = _feedbackList.where((f) => ! f.isPositive).length;
  }

  List<FeedbackItem> _generateSampleFeedback() {
    return [
      FeedbackItem(
        id: '1',
        userName: 'Sarah Johnson',
        rating: 5.0,
        comment: 'Excellent work!  The area was spotlessly clean.  Very professional and quick service.  Highly recommend!',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        taskType: 'Plastic Waste',
        taskLocation: 'Main Street Park',
        isPositive: true,
        tags: ['Quick', 'Professional', 'Thorough'],
      ),
      FeedbackItem(
        id: '2',
        userName: 'Michael Chen',
        rating: 4.5,
        comment: 'Great job cleaning up the area.  Arrived on time and completed the task efficiently.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        taskType: 'Mixed Waste',
        taskLocation: 'Central Avenue',
        isPositive: true,
        tags: ['On Time', 'Efficient'],
      ),
      FeedbackItem(
        id: '3',
        userName: 'Emily Rodriguez',
        rating: 5.0,
        comment: 'Amazing service! Went above and beyond to ensure everything was properly cleaned and disposed.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        taskType: 'Organic Waste',
        taskLocation: 'Riverside Garden',
        isPositive: true,
        tags: ['Above & Beyond', 'Careful'],
      ),
      FeedbackItem(
        id: '4',
        userName: 'David Kim',
        rating: 3.5,
        comment: 'Good work overall but took a bit longer than expected.  The result was satisfactory.',
        date: DateTime. now().subtract(const Duration(days: 3)),
        taskType: 'Construction Debris',
        taskLocation: 'Oak Street',
        isPositive: true,
        tags: ['Satisfactory'],
      ),
      FeedbackItem(
        id: '5',
        userName: 'Lisa Thompson',
        rating: 5.0,
        comment: 'Fantastic!  The worker was very courteous and did an exceptional job. The neighborhood looks much better now.',
        date: DateTime.now().subtract(const Duration(days: 4)),
        taskType: 'Bulk Waste',
        taskLocation: 'Pine Avenue',
        isPositive: true,
        tags: ['Courteous', 'Exceptional'],
      ),
      FeedbackItem(
        id: '6',
        userName: 'James Wilson',
        rating: 2.5,
        comment: 'Task was completed but some debris was left behind. Could have been more thorough.',
        date: DateTime.now(). subtract(const Duration(days: 5)),
        taskType: 'Electronic Waste',
        taskLocation: 'Tech Park',
        isPositive: false,
        tags: ['Incomplete'],
      ),
      FeedbackItem(
        id: '7',
        userName: 'Amanda Foster',
        rating: 4.8,
        comment: 'Very impressed with the quality of work. Will definitely request this worker again! ',
        date: DateTime.now().subtract(const Duration(days: 6)),
        taskType: 'Glass Waste',
        taskLocation: 'Downtown Plaza',
        isPositive: true,
        tags: ['Quality', 'Impressive'],
      ),
    ];
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutQuart,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _statsController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    _listController.forward();
  }

  void _onScroll() {
    if (mounted) {
      setState(() => _scrollOffset = _scrollController.offset);
    }
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController. dispose();
    _statsController.dispose();
    _shimmerController.dispose();
    _scrollController.dispose();
    super. dispose();
  }

  List<FeedbackItem> _getFilteredFeedback() {
    switch (_selectedFilter) {
      case 'positive':
        return _feedbackList.where((f) => f.isPositive). toList();
      case 'negative':
        return _feedbackList.where((f) => !f.isPositive). toList();
      case 'recent':
        final recent = List<FeedbackItem>.from(_feedbackList);
        recent.sort((a, b) => b.date. compareTo(a. date));
        return recent.take(5).toList();
      default:
        return _feedbackList;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final filteredFeedback = _getFilteredFeedback();

    return Scaffold(
      backgroundColor: FeedbackDesign. surfaceLight,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar
          _buildSliverAppBar(r),

          // Overall Rating Card
          SliverToBoxAdapter(
            child: _buildOverallRatingCard(r),
          ),

          // Stats Row
          SliverToBoxAdapter(
            child: _buildStatsRow(r),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: _buildFilterChips(r),
          ),

          // Feedback List
          if (filteredFeedback.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyState(r),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildFeedbackCard(r, filteredFeedback[index], index);
                },
                childCount: filteredFeedback.length,
              ),
            ),

          // Bottom spacing
          SliverToBoxAdapter(
            child: SizedBox(height: r.safePaddingBottom + 100),
          ),
        ],
      ),
    );
  }

  // ==================== APP BAR ====================
  Widget _buildSliverAppBar(EmployeeResponsiveData r) {
    final showElevation = _scrollOffset > 10;

    return SliverAppBar(
      pinned: true,
      expandedHeight: r.dimension(120),
      backgroundColor: FeedbackDesign.surfacePure,
      elevation: showElevation ? 2 : 0,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: Padding(
        padding: EdgeInsets.all(r.microPadding),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onBack();
          },
          child: Container(
            decoration: BoxDecoration(
              color: FeedbackDesign.surfaceLight,
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              Icons. arrow_back_ios_new_rounded,
              color: FeedbackDesign. textPrimary,
              size: r.iconSize(18),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FeedbackDesign.gold. withOpacity(0.1),
                FeedbackDesign.surfacePure,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: FadeTransition(
          opacity: _headerFadeAnimation,
          child: Text(
            'My Feedback',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w700,
              color: FeedbackDesign.textPrimary,
            ),
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  // ==================== OVERALL RATING CARD ====================
  Widget _buildOverallRatingCard(EmployeeResponsiveData r) {
    return FadeTransition(
      opacity: _headerFadeAnimation,
      child: Padding(
        padding: EdgeInsets. all(r.padding),
        child: Container(
          padding: EdgeInsets. all(r.largePadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FeedbackDesign.gold.withOpacity(0.15),
                FeedbackDesign.gold.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
            border: Border.all(color: FeedbackDesign.gold.withOpacity(0.3)),
            boxShadow: FeedbackDesign.elevatedShadow,
          ),
          child: Row(
            children: [
              // Rating Circle
              _buildRatingCircle(r),

              SizedBox(width: r.largePadding),

              // Rating Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Rating',
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: FeedbackDesign.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: r. nanoPadding),

                    // Animated stars
                    _buildAnimatedStars(r, _overallRating),

                    SizedBox(height: r.microPadding),

                    Text(
                      'Based on $_totalFeedbacks reviews',
                      style: GoogleFonts.inter(
                        fontSize: r. captionS,
                        color: FeedbackDesign.textTertiary,
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

  Widget _buildRatingCircle(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        final animatedRating = _overallRating * _statsAnimation.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: r.dimension(90),
              height: r.dimension(90),
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                color: FeedbackDesign. gold.withOpacity(0.2),
              ),
            ),

            // Progress circle
            SizedBox(
              width: r.dimension(90),
              height: r.dimension(90),
              child: CircularProgressIndicator(
                value: animatedRating / 5.0,
                strokeWidth: 8,
                color: FeedbackDesign. gold,
                strokeCap: StrokeCap.round,
              ),
            ),

            // Rating value
            Column(
              mainAxisSize: MainAxisSize. min,
              children: [
                Text(
                  animatedRating.toStringAsFixed(1),
                  style: GoogleFonts.inter(
                    fontSize: r. headingM,
                    fontWeight: FontWeight.w800,
                    color: FeedbackDesign.textPrimary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons. star_rounded,
                      color: FeedbackDesign.gold,
                      size: r.iconSize(14),
                    ),
                    Text(
                      '/5',
                      style: GoogleFonts.inter(
                        fontSize: r.captionS,
                        color: FeedbackDesign.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedStars(EmployeeResponsiveData r, double rating) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: rating),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Row(
          children: List.generate(5, (index) {
            final starValue = (animValue - index). clamp(0.0, 1.0);
            return Padding(
              padding: EdgeInsets.only(right: r.atomicPadding),
              child: Icon(
                starValue >= 1
                    ? Icons. star_rounded
                    : (starValue > 0 ?  Icons.star_half_rounded : Icons. star_outline_rounded),
                color: FeedbackDesign.gold,
                size: r.iconSize(22),
              ),
            );
          }),
        );
      },
    );
  }

  // ==================== STATS ROW ====================
  Widget _buildStatsRow(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets. symmetric(horizontal: r.padding),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              r,
              icon: Icons.thumb_up_rounded,
              label: 'Positive',
              value: _positiveFeedbacks,
              color: FeedbackDesign. success,
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: _buildStatCard(
              r,
              icon: Icons.thumb_down_rounded,
              label: 'Negative',
              value: _negativeFeedbacks,
              color: FeedbackDesign.error,
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: _buildStatCard(
              r,
              icon: Icons.chat_bubble_rounded,
              label: 'Total',
              value: _totalFeedbacks,
              color: FeedbackDesign.info,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required int value,
        required Color color,
      }) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        final animatedValue = (value * _statsAnimation.value).round();

        return Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            color: FeedbackDesign. surfacePure,
            borderRadius: BorderRadius.circular(r. largeBorderRadius),
            boxShadow: FeedbackDesign. softShadow,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration: BoxDecoration(
                  color: color. withOpacity(0.1),
                  borderRadius: BorderRadius. circular(r.borderRadius),
                ),
                child: Icon(icon, color: color, size: r.iconSize(20)),
              ),
              SizedBox(height: r.nanoPadding),
              Text(
                '$animatedValue',
                style: GoogleFonts.inter(
                  fontSize: r.headingXS,
                  fontWeight: FontWeight. w800,
                  color: FeedbackDesign.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts. inter(
                  fontSize: r.captionXS,
                  color: FeedbackDesign.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==================== FILTER CHIPS ====================
  Widget _buildFilterChips(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: SizedBox(
        height: r.dimension(44),
        child: ListView.separated(
          scrollDirection: Axis. horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _filters. length,
          separatorBuilder: (_, __) => SizedBox(width: r.microPadding),
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = _selectedFilter == filter. value;

            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = filter.value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets. symmetric(
                  horizontal: r.microPadding,
                  vertical: r.nanoPadding,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ?  LinearGradient(colors: [filter.color, filter. color.withOpacity(0.85)])
                      : null,
                  color: isSelected ? null : FeedbackDesign. surfacePure,
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                  boxShadow: isSelected
                      ? FeedbackDesign. glowShadow(filter.color)
                      : FeedbackDesign. softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter. icon,
                      size: r.iconSize(16),
                      color: isSelected ? Colors.white : filter.color,
                    ),
                    SizedBox(width: r.nanoPadding),
                    Text(
                      filter.label,
                      style: GoogleFonts.inter(
                        fontSize: r. captionM,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : FeedbackDesign. textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== FEEDBACK CARD ====================
  Widget _buildFeedbackCard(EmployeeResponsiveData r, FeedbackItem feedback, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showFeedbackDetails(r, feedback),
        child: Container(
          margin: EdgeInsets. fromLTRB(r.padding, 0, r.padding, r.microPadding),
          padding: EdgeInsets. all(r.padding),
          decoration: BoxDecoration(
            color: FeedbackDesign.surfacePure,
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
            boxShadow: FeedbackDesign.softShadow,
            border: Border.all(
              color: feedback.isPositive
                  ? FeedbackDesign.success. withOpacity(0.1)
                  : FeedbackDesign.error. withOpacity(0.1),
            ),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment. start,
              children: [
              // Header row
              Row(
              children: [
              // Avatar
              _buildUserAvatar(r, feedback),

          SizedBox(width: r.microPadding),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback. userName,
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight. w700,
                    color: FeedbackDesign.textPrimary,
                  ),
                ),
                Text(
                  _formatDate(feedback. date),
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    color: FeedbackDesign.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Rating badge
          _buildRatingBadge(r, feedback. rating),
          ],
        ),

        SizedBox(height: r.microPadding),

        // Task info
        Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical: r.nanoPadding,
            ),
            decoration: BoxDecoration(
              color: FeedbackDesign. surfaceLight,
              borderRadius: BorderRadius.circular(r. borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Icon(
              Icons.delete_rounded,
              size: r.iconSize(14),
              color: FeedbackDesign.textTertiary,
            ),
            SizedBox(width: r.atomicPadding),
            Flexible(
              child: Text(
                feedback.taskType,
                style: GoogleFonts.inter(
                  fontSize: r. captionS,
                  color: FeedbackDesign. textSecondary,
                ),
                overflow: TextOverflow. ellipsis,
              ),
            ),
            if (feedback.taskLocation != null) ...[
        Container(
        width: 1,
        height: r.dimension(12),
        margin: EdgeInsets. symmetric(horizontal: r.nanoPadding),
        color: FeedbackDesign.textLight,
      ),
      Icon(
        Icons.location_on_rounded,
        size: r.iconSize(14),
        color: FeedbackDesign.textTertiary,
      ),
      SizedBox(width: r.atomicPadding),
      Flexible(
        child: Text(
          feedback.taskLocation! ,
          style: GoogleFonts. inter(
            fontSize: r.captionS,
            color: FeedbackDesign.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      ],
      ],
    ),
    ),

    SizedBox(height: r. microPadding),

    // Comment
    Text(
    feedback. comment,
    style: GoogleFonts.inter(
    fontSize: r. bodyS,
    color: FeedbackDesign.textPrimary,
    height: 1.5,
    ),
    maxLines: 3,
    overflow: TextOverflow.ellipsis,
    ),

    // Tags
    if (feedback.tags. isNotEmpty) ...[
    SizedBox(height: r.microPadding),
    _buildTags(r, feedback.tags, feedback.isPositive),
    ],
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildUserAvatar(EmployeeResponsiveData r, FeedbackItem feedback) {
    return Container(
      width: r.dimension(48),
      height: r.dimension(48),
      decoration: BoxDecoration(
        gradient: feedback.isPositive
            ? LinearGradient(
          colors: [FeedbackDesign. success, FeedbackDesign.success.withOpacity(0.7)],
        )
            : LinearGradient(
          colors: [FeedbackDesign. error, FeedbackDesign.error. withOpacity(0.7)],
        ),
        shape: BoxShape.circle,
        boxShadow: FeedbackDesign. glowShadow(
          feedback.isPositive ?  FeedbackDesign.success : FeedbackDesign.error,
        ),
      ),
      child: feedback.userAvatar != null
          ? ClipOval(
        child: Image.network(
          feedback. userAvatar!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatarInitial(r, feedback),
        ),
      )
          : _buildAvatarInitial(r, feedback),
    );
  }

  Widget _buildAvatarInitial(EmployeeResponsiveData r, FeedbackItem feedback) {
    return Center(
      child: Text(
        feedback.userName. isNotEmpty ?  feedback.userName[0]. toUpperCase() : '? ',
        style: GoogleFonts. inter(
          fontSize: r.bodyM,
          fontWeight: FontWeight. w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRatingBadge(EmployeeResponsiveData r, double rating) {
    final color = rating >= 4.0
    ? FeedbackDesign. success
        : (rating >= 3.0 ?  FeedbackDesign.warning : FeedbackDesign.error);

    return Container(
    padding: EdgeInsets. symmetric(
    horizontal: r.microPadding,
    vertical: r.nanoPadding,
    ),
    decoration: BoxDecoration(
    color: color. withOpacity(0.1),
    borderRadius: BorderRadius.circular(r. pillBorderRadius),
    border: Border.all(color: color. withOpacity(0.3)),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    Icons.star_rounded,
    size: r.iconSize(14),
    color: color,
    ),
    SizedBox(width: r.atomicPadding),
    Text(
    rating.toStringAsFixed(1),
    style: GoogleFonts.inter(
    fontSize: r. captionM,
    fontWeight: FontWeight.w700,
    color: color,
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildTags(EmployeeResponsiveData r, List<String> tags, bool isPositive) {
    final color = isPositive ?  FeedbackDesign.success : FeedbackDesign.error;

    return Wrap(
      spacing: r.nanoPadding,
      runSpacing: r. nanoPadding,
      children: tags.map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: r. microPadding,
            vertical: r.atomicPadding,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Text(
            tag,
            style: GoogleFonts. inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight. w600,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==================== FEEDBACK DETAILS SHEET ====================
  void _showFeedbackDetails(EmployeeResponsiveData r, FeedbackItem feedback) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FeedbackDetailsSheet(
        feedback: feedback,
        responsive: r,
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(EmployeeResponsiveData r) {
    return Padding(
        padding: EdgeInsets. all(r.largePadding),
        child: Column(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
        SizedBox(height: r.dimension(60)),
    Container(
    padding: EdgeInsets. all(r.largePadding),
    decoration: BoxDecoration(
    color: FeedbackDesign.surfaceOverlay,
    shape: BoxShape.circle,
    ),
    child: Icon(
    Icons.feedback_rounded,
    size: r.iconSize(56),
    color: FeedbackDesign.textTertiary,
    ),
    ),
    SizedBox(height: r.padding),
    Text(
    'No feedback found',
    style: GoogleFonts. inter(
    fontSize: r.bodyM,
    fontWeight: FontWeight.w600,
    color: FeedbackDesign.textPrimary,
    ),
    ),
    SizedBox(height: r.nanoPadding),
    Text(
    _selectedFilter == 'all'
    ? 'Complete tasks to receive feedback from citizens'
        : 'Try changing the filter to see more feedback',
    style: GoogleFonts.inter(
    fontSize: r.bodyS,
    color: FeedbackDesign.textSecondary,
    ),
    textAlign: TextAlign.center,
    ),
    if (_selectedFilter != 'all') ...[
    SizedBox(height: r.padding),
    GestureDetector(
    onTap: () => setState(() => _selectedFilter = 'all'),
    child: Container(
    padding: EdgeInsets.symmetric(
    horizontal: r.padding,
    vertical: r.microPadding,
    ),
    decoration: BoxDecoration(
    gradient: FeedbackDesign. primaryGradient,
    borderRadius: BorderRadius. circular(r.borderRadius),
    ),
    child: Text(
    'View All Feedback',
    style: GoogleFonts.inter(
    fontSize: r.bodyS,
    fontWeight: FontWeight. w600,
    color: Colors.white,
    ),
    ),
    ),
    ),
    ],
    ],
    ),
    );
  }

  // ==================== HELPERS ====================
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff. inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ==================== FILTER OPTION ====================
class _FilterOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  _FilterOption(this.value, this.label, this. icon, this.color);
}

// ==================== FEEDBACK DETAILS SHEET ====================
class _FeedbackDetailsSheet extends StatefulWidget {
  final FeedbackItem feedback;
  final EmployeeResponsiveData responsive;

  const _FeedbackDetailsSheet({
    required this.feedback,
    required this.responsive,
  });

  @override
  State<_FeedbackDetailsSheet> createState() => _FeedbackDetailsSheetState();
}

class _FeedbackDetailsSheetState extends State<_FeedbackDetailsSheet>
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
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final feedback = widget.feedback;
    final color = feedback.isPositive ?  FeedbackDesign.success : FeedbackDesign.error;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: FeedbackDesign. surfacePure,
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
            margin: EdgeInsets.symmetric(vertical: r.microPadding),
            decoration: BoxDecoration(
              color: FeedbackDesign. textLight,
              borderRadius: BorderRadius. circular(r.pillBorderRadius),
            ),
          ),

          Flexible(
              child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets. all(r.largePadding),
                  child: Column(
                    children: [
                    // Rating circle
                    ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: r.dimension(100),
                      height: r.dimension(100),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        shape: BoxShape. circle,
                        boxShadow: FeedbackDesign. glowShadow(color),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            feedback.isPositive
                                ? Icons.thumb_up_rounded
                                : Icons. thumb_down_rounded,
                            color: Colors.white,
                            size: r. iconSize(32),
                          ),
                          SizedBox(height: r.atomicPadding),
                          Text(
                            feedback. rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: r.headingXS,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: r.padding),

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment. center,
                    children: List.generate(5, (index) {
                      final starValue = (feedback.rating - index). clamp(0.0, 1.0);
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: r.atomicPadding),
                        child: Icon(
                          starValue >= 1
                              ? Icons.star_rounded
                              : (starValue > 0 ? Icons.star_half_rounded : Icons.star_outline_rounded),
                          color: FeedbackDesign.gold,
                          size: r.iconSize(28),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: r.largePadding),

                  // User info
                  Row(
                    children: [
                      Container(
                        width: r.dimension(50),
                        height: r.dimension(50),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            feedback.userName. isNotEmpty
                                ? feedback. userName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontSize: r.bodyM,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: r.microPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feedback.userName,
                              style: GoogleFonts. inter(
                                fontSize: r.bodyM,
                                fontWeight: FontWeight. w700,
                                color: FeedbackDesign. textPrimary,
                              ),
                            ),
                            Text(
                              _formatFullDate(feedback.date),
                              style: GoogleFonts.inter(
                                fontSize: r. captionM,
                                color: FeedbackDesign.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: r.padding),

                  // Task info card
                  Container(
                    padding: EdgeInsets.all(r.padding),
                    decoration: BoxDecoration(
                      color: FeedbackDesign.surfaceLight,
                      borderRadius: BorderRadius. circular(r.largeBorderRadius),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(r, Icons.delete_rounded, 'Task Type', feedback.taskType),
                        if (feedback.taskLocation != null) ...[
                          Divider(height: r.padding, color: FeedbackDesign.surfaceOverlay),
                          _buildDetailRow(r, Icons.location_on_rounded, 'Location', feedback.taskLocation!),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: r. padding),

                  // Comment
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets. all(r.padding),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius. circular(r.largeBorderRadius),
                      border: Border.all(color: color. withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              color: color,
                              size: r.iconSize(20),
                            ),
                            SizedBox(width: r.nanoPadding),
                            Text(
                              'Feedback',
                              style: GoogleFonts.inter(
                                fontSize: r.captionM,
                                fontWeight: FontWeight. w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: r.microPadding),
                        Text(
                          feedback.comment,
                          style: GoogleFonts.inter(
                            fontSize: r. bodyS,
                            color: FeedbackDesign.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tags
                  if (feedback.tags. isNotEmpty) ...[
              SizedBox(height: r.padding),
          Wrap(
            spacing: r.microPadding,
            runSpacing: r.microPadding,
            children: feedback.tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r. microPadding,
                  vertical: r.nanoPadding,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius. circular(r.pillBorderRadius),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts. inter(
                    fontSize: r.captionS,
                    fontWeight: FontWeight. w600,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        SizedBox(height: r.largePadding),

        // Close button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton. styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: EdgeInsets. symmetric(vertical: r.microPadding),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r. borderRadius),
              ),
              elevation: 0,
            ),
            child: Text(
              'Close',
              style: GoogleFonts.inter(fontWeight: FontWeight. w600),
            ),
          ),
        ),
        ],
      ),
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildDetailRow(EmployeeResponsiveData r, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: FeedbackDesign.textTertiary, size: r.iconSize(18)),
        SizedBox(width: r.microPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts. inter(
                fontSize: r.captionXS,
                color: FeedbackDesign.textTertiary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight. w600,
                color: FeedbackDesign.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatFullDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour. toString().padLeft(2, '0')}:${date. minute.toString().padLeft(2, '0')}';
  }
}