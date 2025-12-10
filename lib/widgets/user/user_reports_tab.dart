import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:neat_now/screens/user_dashboard.dart';
import 'package:neat_now/widgets/user/responsive_user_helper.dart';

/// ==================== USER REPORTS TAB (FR-U5, FR-U7) ====================
/// Features:
/// - View all submitted reports with real-time status
/// - Status tracking: Uploaded → Pending → Assigned → Resolved
/// - Before and after cleanup images as proof (FR-U5)
/// - Rate worker performance after resolution (FR-U7)
/// - Detailed report view with all information
class UserReportsTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final UserResponsiveData responsive;
  final VoidCallback onReportWaste;

  const UserReportsTab({
    super.key,
    required this.userData,
    required this. responsive,
    required this.onReportWaste,
  });

  @override
  State<UserReportsTab> createState() => _UserReportsTabState();
}

class _UserReportsTabState extends State<UserReportsTab> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;

  late Animation<double> _headerFadeAnimation;

  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';
  double _scrollOffset = 0;

  // Sample data - Replace with actual API data
  final List<UserReport> _reports = [
    UserReport(
      id: '1',
      type: 'Plastic Waste',
      location: 'Main Street Park, Block A',
      status: 'pending',
      beforeImageUrl: 'https://images.unsplash. com/photo-1604187351574-c75ca79f5807?w=400',
      description: 'Large pile of plastic bottles near the park bench.  Needs immediate attention.',
      submittedAt: DateTime. now(). subtract(const Duration(hours: 2)),
      workerName: null,
      workerPhone: null,
      workerImage: null,
      afterImageUrl: null,
      resolvedAt: null,
      latitude: 31.7167,
      longitude: 73.9850,
    ),
    UserReport(
      id: '2',
      type: 'Organic Waste',
      location: 'Central Avenue, Near Metro Station',
      status: 'assigned',
      beforeImageUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400',
      description: 'Food waste dumped on the sidewalk causing bad smell.',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      workerName: 'Ahmed Khan',
      workerPhone: '+92 300 1234567',
      workerImage: null,
      afterImageUrl: null,
      resolvedAt: null,
      latitude: 31.7200,
      longitude: 73.9900,
    ),
    UserReport(
      id: '3',
      type: 'Mixed Waste',
      location: 'Riverside Garden, East Wing',
      status: 'resolved',
      beforeImageUrl: 'https://images.unsplash.com/photo-1605600659908-0ef719419d41?w=400',
      description: 'Various trash items scattered around the garden area.',
      submittedAt: DateTime. now().subtract(const Duration(days: 3)),
      workerName: 'Ali Hassan',
      workerPhone: '+92 301 9876543',
      workerImage: null,
      afterImageUrl: 'https://images. unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
      cleanupDuration: const Duration(minutes: 45),
      latitude: 31.7100,
      longitude: 73.9800,
      rating: null,
      feedback: null,
    ),
    UserReport(
      id: '4',
      type: 'Electronic Waste',
      location: 'Tech Park, Building C',
      status: 'resolved',
      beforeImageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=400',
      description: 'Old computer parts and cables dumped near the parking.',
      submittedAt: DateTime.now().subtract(const Duration(days: 5)),
      workerName: 'Omar Ali',
      workerPhone: '+92 302 5555555',
      workerImage: null,
      afterImageUrl: 'https://images. unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      resolvedAt: DateTime.now(). subtract(const Duration(days: 4)),
      cleanupDuration: const Duration(hours: 1, minutes: 15),
      latitude: 31.7050,
      longitude: 73.9750,
      rating: 5,
      feedback: 'Excellent work! Very thorough cleanup.',
    ),
    UserReport(
      id: '5',
      type: 'Construction Debris',
      location: 'New Housing Society, Plot 45',
      status: 'resolved',
      beforeImageUrl: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
      description: 'Bricks and concrete waste left after construction.',
      submittedAt: DateTime.now().subtract(const Duration(days: 7)),
      workerName: 'Bilal Ahmed',
      workerPhone: '+92 303 1111111',
      workerImage: null,
      afterImageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      resolvedAt: DateTime. now().subtract(const Duration(days: 6)),
      cleanupDuration: const Duration(hours: 2),
      latitude: 31.7000,
      longitude: 73.9700,
      rating: 4,
      feedback: 'Good job, area is clean now.',
    ),
  ];

  final List<_FilterOption> _filters = [
    _FilterOption('all', 'All', Icons.all_inbox_rounded, UserDesign.textSecondary),
    _FilterOption('pending', 'Pending', Icons.schedule_rounded, UserDesign.warning),
    _FilterOption('assigned', 'Assigned', Icons.person_add_rounded, UserDesign. info),
    _FilterOption('resolved', 'Resolved', Icons.check_circle_rounded, UserDesign.success),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scrollController.addListener(_onScroll);
    _startAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    _listController.forward();
  }

  void _onScroll() {
    if (mounted) setState(() => _scrollOffset = _scrollController.offset);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<UserReport> get _filteredReports {
    if (_selectedFilter == 'all') return _reports;
    return _reports.where((r) => r.status == _selectedFilter). toList();
  }

  int _getCount(String filter) {
    if (filter == 'all') return _reports.length;
    return _reports.where((r) => r.status == filter). length;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Column(
      children: [
        // Header
        _buildHeader(r),

        // Content
        Expanded(
          child: _filteredReports.isEmpty
              ? _buildEmptyState(r)
              : ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              r.padding,
              r. microPadding,
              r.padding,
              r.safePaddingBottom + 100,
            ),
            itemCount: _filteredReports.length,
            itemBuilder: (context, index) =>
                _buildReportCard(r, _filteredReports[index], index),
          ),
        ),
      ],
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(UserResponsiveData r) {
    return FadeTransition(
      opacity: _headerFadeAnimation,
      child: Container(
        padding: EdgeInsets. fromLTRB(
          r. padding,
          r.safePaddingTop + r.microPadding,
          r. padding,
          r.microPadding,
        ),
        decoration: BoxDecoration(
          color: UserDesign.surfacePure. withOpacity(_scrollOffset > 10 ? 0.98 : 1),
          boxShadow: _scrollOffset > 10 ? UserDesign.softShadow : null,
        ),
        child: Column(
          children: [
            // Title Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets. all(r.microPadding),
                  decoration: BoxDecoration(
                    gradient: UserDesign.primaryGradient,
                    borderRadius: BorderRadius. circular(r.borderRadius),
                    boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    color: Colors.white,
                    size: r.iconSize(22),
                  ),
                ),
                SizedBox(width: r.microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Reports',
                        style: GoogleFonts.inter(
                          fontSize: r.headingXS,
                          fontWeight: FontWeight. w800,
                          color: UserDesign.textPrimary,
                        ),
                      ),
                      Text(
                        '${_reports.length} total reports',
                        style: GoogleFonts.inter(
                          fontSize: r. captionS,
                          color: UserDesign. textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onReportWaste,
                  child: Container(
                    padding: EdgeInsets. all(r.microPadding),
                    decoration: BoxDecoration(
                      color: UserDesign.surfaceLight,
                      borderRadius: BorderRadius.circular(r.borderRadius),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: UserDesign.primaryTeal,
                      size: r. iconSize(22),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: r.microPadding),

            // Filters
            _buildFilterChips(r),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(UserResponsiveData r) {
    return SizedBox(
      height: r.dimension(40),
      child: ListView.separated(
        scrollDirection: Axis. horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters. length,
        separatorBuilder: (_, __) => SizedBox(width: r.microPadding),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter.value;
          final count = _getCount(filter.value);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilter = filter.value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets. symmetric(
                horizontal: r. microPadding,
                vertical: r.nanoPadding,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ?  LinearGradient(
                  colors: [filter.color, filter.color.withOpacity(0.85)],
                )
                    : null,
                color: isSelected ? null : UserDesign. surfaceLight,
                borderRadius: BorderRadius. circular(r.pillBorderRadius),
                boxShadow: isSelected ?  UserDesign.glowShadow(filter.color) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize. min,
                children: [
                  Icon(
                    filter.icon,
                    size: r.iconSize(14),
                    color: isSelected ? Colors.white : filter. color,
                  ),
                  SizedBox(width: r.nanoPadding),
                  Text(
                    '${filter.label} ($count)',
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight. w600,
                      color: isSelected ? Colors.white : UserDesign.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== REPORT CARD ====================

  Widget _buildReportCard(UserResponsiveData r, UserReport report, int index) {
    final color = _getStatusColor(report.status);
    final isResolved = report.status == 'resolved';
    final needsRating = isResolved && report.rating == null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
          onTap: () => _showReportDetails(r, report),
          child: Container(
              margin: EdgeInsets. only(bottom: r.microPadding),
              decoration: BoxDecoration(
                color: UserDesign.surfacePure,
                borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
                boxShadow: UserDesign. softShadow,
                border: Border.all(
                  color: needsRating
                      ? const Color(0xFFFFD700). withOpacity(0.5)
                      : color. withOpacity(0.1),
                  width: needsRating ? 2 : 1,
                ),
              ),
              child: Column(
                  children: [
              Padding(
              padding: EdgeInsets.all(r.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header Row with Image
                Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Before Image Thumbnail
                  _buildReportThumbnail(r, report, color),
                  SizedBox(width: r.microPadding),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment. start,
                      children: [
                    Row(
                    children: [
                    Expanded(
                    child: Text(
                      report. type,
                      style: GoogleFonts.inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight.w700,
                        color: UserDesign.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(r, report. status, color),
                ],
              ),
              SizedBox(height: r. nanoPadding),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: r.iconSize(12),
                    color: UserDesign.textTertiary,
                  ),
                  SizedBox(width: r. atomicPadding),
                  Expanded(
                    child: Text(
                      report.location,
                      style: GoogleFonts.inter(
                        fontSize: r.captionS,
                        color: UserDesign.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.atomicPadding),
              Row(
                children: [
                Icon(
                Icons.access_time_rounded,
                size: r.iconSize(10),
                color: UserDesign.textLight,
              ),
              SizedBox(width: r.atomicPadding),
              Text(
                _formatDate(report. submittedAt),
                style: GoogleFonts.inter(
                  fontSize: r.captionXS,
                  color: UserDesign.textTertiary,
                ),
              ),
              if (report.workerName != null) ...[
          SizedBox(width: r.microPadding),
      Icon(
        Icons.person_rounded,
        size: r.iconSize(10),
        color: UserDesign.textLight,
      ),
      SizedBox(width: r.atomicPadding),
      Expanded(
        child: Text(
          report.workerName! ,
          style: GoogleFonts.inter(
            fontSize: r.captionXS,
            color: UserDesign.info,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      ],
      ],
    ),
    ],
    ),
    ),
    ],
    ),

    // Before/After Images Preview (for resolved reports)
    if (isResolved && report.afterImageUrl != null) ...[
    SizedBox(height: r.microPadding),
    _buildBeforeAfterPreview(r, report),
    ],

    // Rating Section (for resolved reports)
    if (isResolved) ...[
    SizedBox(height: r.microPadding),
    _buildResolvedSection(r, report),
    ],
    ],
    ),
    ),

    // Progress Indicator (for non-resolved reports)
    if (! isResolved) _buildProgressIndicator(r, report. status),
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildReportThumbnail(UserResponsiveData r, UserReport report, Color color) {
    final size = r.dimension(60);

    if (report.beforeImageUrl != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(r.borderRadius),
            child: Image.network(
              report. beforeImageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildIconThumbnail(r, report, color, size),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: UserDesign.surfaceLight,
                    borderRadius: BorderRadius.circular(r. borderRadius),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Image count badge
          if (report.status == 'resolved' && report.afterImageUrl != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets. symmetric(
                  horizontal: r.nanoPadding,
                  vertical: r.atomicPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons. photo_library_rounded,
                      size: r. iconSize(10),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '2',
                      style: GoogleFonts.inter(
                        fontSize: r. captionXS - 1,
                        fontWeight: FontWeight. w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    return _buildIconThumbnail(r, report, color, size);
  }

  Widget _buildIconThumbnail(
      UserResponsiveData r,
      UserReport report,
      Color color,
      double size,
      ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color. withOpacity(0.15), color.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Icon(_getWasteIcon(report. type), color: color, size: size * 0.5),
    );
  }

  Widget _buildStatusBadge(UserResponsiveData r, String status, Color color) {
    return Container(
      padding: EdgeInsets. symmetric(
        horizontal: r. microPadding,
        vertical: r. atomicPadding,
      ),
      decoration: BoxDecoration(
        color: color. withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.pillBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: r.dimension(6),
            height: r.dimension(6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: r.atomicPadding),
          Text(
            _getStatusLabel(status),
            style: GoogleFonts.inter(
              fontSize: r. captionXS,
              fontWeight: FontWeight. w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BEFORE/AFTER PREVIEW ====================

  Widget _buildBeforeAfterPreview(UserResponsiveData r, UserReport report) {
    return GestureDetector(
      onTap: () => _showBeforeAfterComparison(r, report),
      child: Container(
        padding: EdgeInsets.all(r. microPadding),
        decoration: BoxDecoration(
          color: UserDesign.success. withOpacity(0.05),
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: Border.all(color: UserDesign.success. withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Before Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
                child: Stack(
                  children: [
                    Image.network(
                      report.beforeImageUrl ??  '',
                      height: r.dimension(60),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: r.dimension(60),
                        color: UserDesign. surfaceLight,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: UserDesign.textTertiary,
                        ),
                      ),
                    ),
                    Positioned(
                      top: r.atomicPadding,
                      left: r.atomicPadding,
                      child: Container(
                        padding: EdgeInsets. symmetric(
                          horizontal: r.nanoPadding,
                          vertical: r. atomicPadding,
                        ),
                        decoration: BoxDecoration(
                          color: UserDesign.error,
                          borderRadius: BorderRadius.circular(r.smallBorderRadius),
                        ),
                        child: Text(
                          'Before',
                          style: GoogleFonts.inter(
                            fontSize: r. captionXS - 2,
                            fontWeight: FontWeight. w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r. nanoPadding),
              child: Icon(
                Icons. arrow_forward_rounded,
                color: UserDesign.success,
                size: r.iconSize(20),
              ),
            ),

            // After Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(r. smallBorderRadius),
                child: Stack(
                  children: [
                    Image.network(
                      report.afterImageUrl ?? '',
                      height: r.dimension(60),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: r.dimension(60),
                        color: UserDesign.surfaceLight,
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          color: UserDesign.textTertiary,
                        ),
                      ),
                    ),
                    Positioned(
                      top: r.atomicPadding,
                      left: r.atomicPadding,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.nanoPadding,
                          vertical: r. atomicPadding,
                        ),
                        decoration: BoxDecoration(
                          color: UserDesign.success,
                          borderRadius: BorderRadius.circular(r.smallBorderRadius),
                        ),
                        child: Text(
                          'After',
                          style: GoogleFonts. inter(
                            fontSize: r.captionXS - 2,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RESOLVED SECTION ====================

  Widget _buildResolvedSection(UserResponsiveData r, UserReport report) {
    if (report.rating != null) {
      // Already rated - show rating and feedback
      return Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withOpacity(0.1),
              const Color(0xFFFFD700). withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: Border.all(color: const Color(0xFFFFD700). withOpacity(0.3)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Row(
        children: [
        Container(
        padding: EdgeInsets. all(r.nanoPadding),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700),
          borderRadius: BorderRadius.circular(r.smallBorderRadius),
        ),
        child: Icon(
          Icons. verified_rounded,
          color: Colors.white,
          size: r. iconSize(14),
        ),
      ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment. start,
    children: [
    Text(
    'Your Feedback',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    fontWeight: FontWeight. w600,
    color: UserDesign.textPrimary,
    ),
    ),
    if (report.cleanupDuration != null)
    Text(
    'Cleaned in ${_formatDuration(report.cleanupDuration! )}',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    color: UserDesign. textSecondary,
    ),
    ),
    ],
    ),
    ),
    // Stars
    Row(
    children: List.generate(5, (index) {
    return Icon(
    index < report.rating!
    ? Icons. star_rounded
        : Icons.star_outline_rounded,
    color: const Color(0xFFFFD700),
    size: r.iconSize(16),
    );
    }),
    ),
    ],
    ),
    if (report.feedback != null && report.feedback!. isNotEmpty) ...[
    SizedBox(height: r.microPadding),
    Container(
    padding: EdgeInsets.all(r.microPadding),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius. circular(r.smallBorderRadius),
    ),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Icon(
    Icons.format_quote_rounded,
    size: r.iconSize(14),
    color: UserDesign.textTertiary,
    ),
    SizedBox(width: r.nanoPadding),
    Expanded(
    child: Text(
    report.feedback!,
    style: GoogleFonts. inter(
    fontSize: r.captionS,
    color: UserDesign. textSecondary,
    fontStyle: FontStyle.italic,
    ),
    ),
    ),
    ],
    ),
    ),
    ],
    ],
    ),
    );
    } else {
    // Not rated yet - show rate button
    return GestureDetector(
    onTap: () => _showFeedbackDialog(r, report),
    child: Container(
    padding: EdgeInsets.all(r.microPadding),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [
    const Color(0xFFFFD700).withOpacity(0.15),
    const Color(0xFFFFD700).withOpacity(0.08),
    ],
    ),
    borderRadius: BorderRadius. circular(r.borderRadius),
    border: Border.all(
    color: const Color(0xFFFFD700).withOpacity(0.4),
    width: 1.5,
    ),
    ),
    child: Row(
    children: [
    Container(
    padding: EdgeInsets.all(r.nanoPadding),
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    ),
    borderRadius: BorderRadius. circular(r.smallBorderRadius),
    boxShadow: UserDesign.glowShadow(const Color(0xFFFFD700)),
    ),
    child: Icon(
    Icons.star_rounded,
    color: Colors.white,
    size: r.iconSize(16),
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Cleanup Complete!  🎉',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    fontWeight: FontWeight.w700,
    color: const Color(0xFFD97706),
    ),
    ),
    Text(
    'Tap to rate and leave feedback',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    color: UserDesign.textSecondary,
    ),
    ),
    ],
    ),
    ),
    Container(
    padding: EdgeInsets.symmetric(
    horizontal: r.microPadding,
    vertical: r. nanoPadding,
    ),
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    ),
    borderRadius: BorderRadius.circular(r. pillBorderRadius),
    ),
    child: Text(
    'Rate Now',
    style: GoogleFonts.inter(
    fontSize: r. captionS,
    fontWeight: FontWeight. w600,
    color: Colors.white,
    ),
    ),
    ),
    ],
    ),
    ),
    );
    }
  }

  // ==================== PROGRESS INDICATOR ====================

  Widget _buildProgressIndicator(UserResponsiveData r, String status) {
    final steps = ['Uploaded', 'Pending', 'Assigned', 'Resolved'];
    int currentStep = 0;

    switch (status) {
      case 'pending':
        currentStep = 1;
        break;
      case 'assigned':
        currentStep = 2;
        break;
      case 'resolved':
        currentStep = 3;
        break;
    }

    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: UserDesign.surfaceLight,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(r.extraLargeBorderRadius),
        ),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index. isOdd) {
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted ?  UserDesign.success : UserDesign. textLight,
              ),
            );
          } else {
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            final isCurrent = stepIndex == currentStep;

            return Column(
              children: [
                Container(
                  width: r.dimension(20),
                  height: r.dimension(20),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? UserDesign.success
                        : (isCurrent ? UserDesign.warning : UserDesign. surfaceOverlay),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? Colors.transparent
                          : UserDesign.textLight,
                      width: 1,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                    Icons. check_rounded,
                    color: Colors.white,
                    size: r. iconSize(12),
                  )
                      : isCurrent
                      ? Icon(
                    Icons.fiber_manual_record,
                    color: Colors.white,
                    size: r. iconSize(8),
                  )
                      : null,
                ),
                SizedBox(height: r.atomicPadding),
                Text(
                  steps[stepIndex],
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS - 1,
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                    color: isCompleted || isCurrent
                        ? UserDesign.textPrimary
                        : UserDesign. textTertiary,
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  // ==================== EMPTY STATE ====================

  Widget _buildEmptyState(UserResponsiveData r) {
    return Center(
      child: Padding(
        padding: EdgeInsets. all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            Container(
              padding: EdgeInsets. all(r.largePadding),
              decoration: BoxDecoration(
                color: UserDesign. surfaceOverlay,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: r.iconSize(56),
                color: UserDesign.textTertiary,
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              _selectedFilter == 'all' ? 'No reports yet' : 'No $_selectedFilter reports',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: UserDesign. textPrimary,
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              _selectedFilter == 'all'
                  ? 'Start by reporting waste in your area'
                  : 'Try changing the filter to see more reports',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: UserDesign. textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.padding),
            if (_selectedFilter == 'all')
              GestureDetector(
                onTap: widget.onReportWaste,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.padding,
                    vertical: r.microPadding,
                  ),
                  decoration: BoxDecoration(
                    gradient: UserDesign.primaryGradient,
                    borderRadius: BorderRadius.circular(r.borderRadius),
                    boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons. add_a_photo_rounded,
                        color: Colors.white,
                        size: r. iconSize(18),
                      ),
                      SizedBox(width: r.nanoPadding),
                      Text(
                        'Report Waste',
                        style: GoogleFonts.inter(
                          fontSize: r.bodyS,
                          fontWeight: FontWeight. w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () => setState(() => _selectedFilter = 'all'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.padding,
                    vertical: r.microPadding,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: UserDesign. primaryTeal),
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                  child: Text(
                    'Show All Reports',
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w600,
                      color: UserDesign.primaryTeal,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== DIALOGS & SHEETS ====================

  void _showReportDetails(UserResponsiveData r, UserReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDetailSheet(
        report: report,
        responsive: r,
        onRate: () {
          Navigator. pop(context);
          _showFeedbackDialog(r, report);
        },
        onViewImages: () {
          Navigator.pop(context);
          _showBeforeAfterComparison(r, report);
        },
      ),
    );
  }

  void _showBeforeAfterComparison(UserResponsiveData r, UserReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BeforeAfterComparisonSheet(
        report: report,
        responsive: r,
      ),
    );
  }

  void _showFeedbackDialog(UserResponsiveData r, UserReport report) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        report: report,
        responsive: r,
        onSubmit: (rating, feedback) {
          Navigator.pop(context);
          setState(() {
            final index = _reports.indexWhere((r) => r.id == report.id);
            if (index != -1) {
              _reports[index] = report. copyWith(
                rating: rating,
                feedback: feedback,
              );
            }
          });
          _showSnackBar('Thank you for your feedback!  🎉');
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context). showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors. white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 13))),
          ],
        ),
        backgroundColor: UserDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ==================== HELPERS ====================

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return UserDesign.warning;
      case 'assigned':
        return UserDesign. info;
      case 'resolved':
        return UserDesign. success;
      default:
        return UserDesign.textTertiary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  IconData _getWasteIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('glass')) return Icons.wine_bar_rounded;
    if (t.contains('paper')) return Icons.description_rounded;
    if (t.contains('construction')) return Icons.construction_rounded;
    if (t.contains('metal')) return Icons.recycling_rounded;
    return Icons.delete_rounded;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration. inMinutes}m';
  }
}

// ==================== MODELS ====================

class UserReport {
  final String id;
  final String type;
  final String location;
  final String status;
  final String?  beforeImageUrl;
  final String? afterImageUrl;
  final String? description;
  final DateTime submittedAt;
  final String? workerName;
  final String? workerPhone;
  final String? workerImage;
  final DateTime? resolvedAt;
  final Duration?  cleanupDuration;
  final double? latitude;
  final double? longitude;
  final int? rating;
  final String? feedback;

  UserReport({
    required this.id,
    required this.type,
    required this.location,
    required this. status,
    this.beforeImageUrl,
    this.afterImageUrl,
    this.description,
    required this.submittedAt,
    this.workerName,
    this.workerPhone,
    this.workerImage,
    this. resolvedAt,
    this.cleanupDuration,
    this.latitude,
    this.longitude,
    this.rating,
    this. feedback,
  });

  UserReport copyWith({
    String? id,
    String? type,
    String?  location,
    String? status,
    String? beforeImageUrl,
    String?  afterImageUrl,
    String? description,
    DateTime? submittedAt,
    String? workerName,
    String? workerPhone,
    String? workerImage,
    DateTime? resolvedAt,
    Duration?  cleanupDuration,
    double? latitude,
    double?  longitude,
    int? rating,
    String? feedback,
  }) {
    return UserReport(
      id: id ??  this.id,
      type: type ??  this.type,
      location: location ??  this.location,
      status: status ??  this.status,
      beforeImageUrl: beforeImageUrl ?? this.beforeImageUrl,
      afterImageUrl: afterImageUrl ??  this.afterImageUrl,
      description: description ?? this.description,
      submittedAt: submittedAt ?? this. submittedAt,
      workerName: workerName ??  this.workerName,
      workerPhone: workerPhone ?? this.workerPhone,
      workerImage: workerImage ?? this.workerImage,
      resolvedAt: resolvedAt ?? this. resolvedAt,
      cleanupDuration: cleanupDuration ?? this.cleanupDuration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
    );
  }
}

class _FilterOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  _FilterOption(this.value, this.label, this. icon, this.color);
}

// ==================== REPORT DETAIL SHEET ====================

class ReportDetailSheet extends StatefulWidget {
  final UserReport report;
  final UserResponsiveData responsive;
  final VoidCallback onRate;
  final VoidCallback onViewImages;

  const ReportDetailSheet({
    super.key,
    required this.report,
    required this. responsive,
    required this.onRate,
    required this. onViewImages,
  });

  @override
  State<ReportDetailSheet> createState() => _ReportDetailSheetState();
}

class _ReportDetailSheetState extends State<ReportDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final report = widget.report;
    final color = _getStatusColor(report.status);
    final isResolved = report.status == 'resolved';
    final hasAfterImage = report. afterImageUrl != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: UserDesign.surfacePure,
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
        color: UserDesign.textLight,
        borderRadius: BorderRadius.circular(r.pillBorderRadius),
      ),
    ),

    // Content
    Flexible(
    child: FadeTransition(
    opacity: _fadeAnimation,
    child: SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: EdgeInsets. all(r.padding),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Header
    _buildHeader(r, report, color),

    SizedBox(height: r.padding),

    // Before/After Images Section
    if (isResolved && hasAfterImage)
    _buildBeforeAfterSection(r, report)
    else if (report.beforeImageUrl != null)
    _buildBeforeImageSection(r, report),

    SizedBox(height: r.padding),

    // Status Timeline
    _buildStatusTimeline(r, report),

    SizedBox(height: r.padding),

    // Details Cards
    _buildInfoCard(r, Icons.category_rounded, 'Waste Type', report.type, UserDesign.purple),
    _buildInfoCard(r, Icons.location_on_rounded, 'Location', report.location, UserDesign.error),
    if (report.description != null && report.description!. isNotEmpty)
    _buildInfoCard(r, Icons.description_rounded, 'Description', report.description!, UserDesign.info, isMultiLine: true),
    _buildInfoCard(r, Icons. schedule_rounded, 'Submitted', _formatDateTime(report.submittedAt), UserDesign.warning),

    // Worker Info
    if (report.workerName != null) _buildWorkerCard(r, report),

    // Resolved Info
    if (isResolved && report.resolvedAt != null)
    _buildResolvedCard(r, report),

    // Rating Section
    if (isResolved) ...[
    SizedBox(height: r.padding),
    _buildRatingSection(r, report),
    ],

    SizedBox(height: r.safePaddingBottom + r.padding),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    );
    }

  Widget _buildHeader(UserResponsiveData r, UserReport report, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets. all(r.microPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
            borderRadius: BorderRadius. circular(r.borderRadius),
            boxShadow: UserDesign.glowShadow(color),
          ),
          child: Icon(_getWasteIcon(report.type), color: Colors.white, size: r.iconSize(24)),
        ),
        SizedBox(width: r. microPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.type,
                style: GoogleFonts.inter(fontSize: r.headingXS, fontWeight: FontWeight.w700, color: UserDesign.textPrimary),
              ),
              Text(
                'Report #${report.id}',
                style: GoogleFonts. inter(fontSize: r.captionS, color: UserDesign. textTertiary),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
          decoration: BoxDecoration(
            color: color. withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape. circle)),
              SizedBox(width: r.atomicPadding),
              Text(_getStatusLabel(report.status), style: GoogleFonts. inter(fontSize: r.captionS, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBeforeAfterSection(UserResponsiveData r, UserReport report) {
    return GestureDetector(
      onTap: widget.onViewImages,
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [UserDesign.success. withOpacity(0.08), UserDesign. success.withOpacity(0.03)]),
          borderRadius: BorderRadius. circular(r.largeBorderRadius),
          border: Border.all(color: UserDesign.success. withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets. all(r.nanoPadding),
                  decoration: BoxDecoration(color: UserDesign. success, borderRadius: BorderRadius. circular(r.smallBorderRadius)),
                  child: Icon(Icons.compare_rounded, color: Colors.white, size: r.iconSize(16)),
                ),
                SizedBox(width: r.microPadding),
                Text('Before & After Cleanup', style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight.w700, color: UserDesign.success)),
                const Spacer(),
                Icon(Icons.zoom_in_rounded, color: UserDesign.success, size: r.iconSize(20)),
              ],
            ),
            SizedBox(height: r.microPadding),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(r.borderRadius),
                    child: Stack(
                      children: [
                        Image. network(
                          report.beforeImageUrl ??  '',
                          height: r.dimension(120),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(r, r.dimension(120)),
                        ),
                        Positioned(
                          top: r.nanoPadding,
                          left: r.nanoPadding,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.atomicPadding),
                            decoration: BoxDecoration(color: UserDesign. error, borderRadius: BorderRadius.circular(r.smallBorderRadius)),
                            child: Text('BEFORE', style: GoogleFonts.inter(fontSize: r. captionXS - 1, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets. symmetric(horizontal: r. microPadding),
                  child: Container(
                    padding: EdgeInsets. all(r.nanoPadding),
                    decoration: BoxDecoration(color: UserDesign.success, shape: BoxShape.circle),
                    child: Icon(Icons. arrow_forward_rounded, color: Colors.white, size: r.iconSize(16)),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius. circular(r.borderRadius),
                    child: Stack(
                      children: [
                        Image. network(
                          report.afterImageUrl ?? '',
                          height: r.dimension(120),
                          width: double. infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(r, r.dimension(120)),
                        ),
                        Positioned(
                          top: r.nanoPadding,
                          left: r.nanoPadding,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: r.microPadding, vertical: r.atomicPadding),
                            decoration: BoxDecoration(color: UserDesign.success, borderRadius: BorderRadius.circular(r.smallBorderRadius)),
                            child: Text('AFTER', style: GoogleFonts.inter(fontSize: r.captionXS - 1, fontWeight: FontWeight.w700, color: Colors. white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: r.microPadding),
            Center(
              child: Text('Tap to view full comparison', style: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeforeImageSection(UserResponsiveData r, UserReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_camera_rounded, size: r.iconSize(16), color: UserDesign.warning),
            SizedBox(width: r.nanoPadding),
            Text('Reported Image', style: GoogleFonts.inter(fontSize: r.captionM, fontWeight: FontWeight.w600, color: UserDesign.textSecondary)),
          ],
        ),
        SizedBox(height: r.nanoPadding),
        ClipRRect(
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          child: Image.network(
            report.beforeImageUrl! ,
            height: r.dimension(180),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildImagePlaceholder(r, r.dimension(180)),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(UserResponsiveData r, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: UserDesign. surfaceLight, borderRadius: BorderRadius.circular(r.largeBorderRadius)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_rounded, size: r.iconSize(32), color: UserDesign.textTertiary),
            SizedBox(height: r.nanoPadding),
            Text('Image unavailable', style: GoogleFonts.inter(fontSize: r. captionS, color: UserDesign.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(UserResponsiveData r, UserReport report) {
    final steps = [
      _TimelineStep('Uploaded', report.submittedAt, true, Icons.cloud_upload_rounded),
      _TimelineStep('Pending', report.submittedAt, report.status != 'uploaded', Icons.schedule_rounded),
      _TimelineStep('Assigned', report. workerName != null ?  report.submittedAt : null, report.status == 'assigned' || report.status == 'resolved', Icons. person_add_rounded),
      _TimelineStep('Resolved', report. resolvedAt, report. status == 'resolved', Icons.check_circle_rounded),
    ];

    return Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(color: UserDesign. surfaceLight, borderRadius: BorderRadius.circular(r.largeBorderRadius)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment. start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline_rounded, size: r.iconSize(16), color: UserDesign.info),
                SizedBox(width: r.nanoPadding),
                Text('Status Timeline', style: GoogleFonts.inter(fontSize: r. captionM, fontWeight: FontWeight. w600, color: UserDesign.textSecondary)),
              ],
            ),
            SizedBox(height: r. microPadding),
            ... steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: r.dimension(28),
                        height: r.dimension(28),
                        decoration: BoxDecoration(
                          gradient: step.isCompleted ? UserDesign.successGradient : null,
                          color: step.isCompleted ?  null : UserDesign. surfaceOverlay,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(step.icon, size: r. iconSize(14), color: step. isCompleted ? Colors.white : UserDesign.textTertiary),
                      ),
                      if (! isLast)
                        Container(
                          width: 2,
                          height: r.dimension(24),
                          color: step.isCompleted ?  UserDesign.success : UserDesign. textLight,
                        ),
                    ],
                  ),
                  SizedBox(width: r.microPadding),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : r. microPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step. label,
                            style: GoogleFonts.inter(
                              fontSize: r.captionM,
                              fontWeight: step.isCompleted ?  FontWeight.w600 : FontWeight. w500,
                              color: step. isCompleted ? UserDesign.textPrimary : UserDesign.textTertiary,
                            ),
                          ),
                          if (step.timestamp != null && step.isCompleted)
                            Text(
                              _formatDateTime(step.timestamp! ),
                              style: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign.textTertiary),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
    );
  }

  Widget _buildInfoCard(UserResponsiveData r, IconData icon, String label, String value, Color color, {bool isMultiLine = false}) {
    return Container(
      margin: EdgeInsets. only(bottom: r.microPadding),
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: UserDesign.surfaceLight,
        borderRadius: BorderRadius. circular(r.borderRadius),
      ),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets. all(r.nanoPadding),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Icon(icon, color: color, size: r.iconSize(16)),
          ),
          SizedBox(width: r. microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign.textTertiary)),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight.w600, color: UserDesign.textPrimary),
                  maxLines: isMultiLine ? null : 2,
                  overflow: isMultiLine ? null : TextOverflow. ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(UserResponsiveData r, UserReport report) {
    return Container(
      margin: EdgeInsets. only(bottom: r.microPadding),
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [UserDesign.info. withOpacity(0.08), UserDesign. info.withOpacity(0.03)]),
        borderRadius: BorderRadius. circular(r.largeBorderRadius),
        border: Border.all(color: UserDesign.info. withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.engineering_rounded, size: r.iconSize(16), color: UserDesign.info),
              SizedBox(width: r. nanoPadding),
              Text('Assigned Worker', style: GoogleFonts.inter(fontSize: r. captionM, fontWeight: FontWeight. w600, color: UserDesign.info)),
            ],
          ),
          SizedBox(height: r.microPadding),
          Row(
            children: [
              Container(
                width: r.dimension(48),
                height: r.dimension(48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [UserDesign.info, UserDesign.info.withOpacity(0.8)]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    report.workerName![0]. toUpperCase(),
                    style: GoogleFonts.inter(fontSize: r.bodyM, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.workerName!, style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight. w600, color: UserDesign.textPrimary)),
                    if (report.workerPhone != null)
                      Text(report.workerPhone!, style: GoogleFonts.inter(fontSize: r.captionS, color: UserDesign.textSecondary)),
                  ],
                ),
              ),
              if (report.workerPhone != null)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final url = Uri.parse('tel:${report.workerPhone}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(r.microPadding),
                    decoration: BoxDecoration(
                      color: UserDesign.success,
                      borderRadius: BorderRadius. circular(r.borderRadius),
                    ),
                    child: Icon(Icons. phone_rounded, color: Colors.white, size: r.iconSize(18)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResolvedCard(UserResponsiveData r, UserReport report) {
    return Container(
      margin: EdgeInsets.only(bottom: r.microPadding),
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [UserDesign.success. withOpacity(0.08), UserDesign. success.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: UserDesign.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets. all(r.nanoPadding),
            decoration: BoxDecoration(color: UserDesign.success, borderRadius: BorderRadius.circular(r. smallBorderRadius)),
            child: Icon(Icons.check_rounded, color: Colors.white, size: r.iconSize(14)),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment. start,
              children: [
                Text('Cleanup Completed', style: GoogleFonts.inter(fontSize: r. bodyS, fontWeight: FontWeight. w700, color: UserDesign.success)),
                Text(_formatDateTime(report. resolvedAt! ), style: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign. textSecondary)),
              ],
            ),
          ),
          if (report.cleanupDuration != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
              decoration: BoxDecoration(
                color: UserDesign.success. withOpacity(0.15),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize. min,
                children: [
                  Icon(Icons.timer_rounded, size: r.iconSize(12), color: UserDesign.success),
                  SizedBox(width: r. atomicPadding),
                  Text(_formatDuration(report.cleanupDuration!), style: GoogleFonts.inter(fontSize: r. captionXS, fontWeight: FontWeight. w600, color: UserDesign.success)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(UserResponsiveData r, UserReport report) {
    if (report.rating != null) {
      return Container(
        padding: EdgeInsets. all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color(0xFFFFD700). withOpacity(0.1), const Color(0xFFFFD700).withOpacity(0.05)]),
          borderRadius: BorderRadius. circular(r.largeBorderRadius),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(03)),
        ),
        child: Column(
            children: [
        Row(
        children: [
        Icon(Icons.star_rounded, color: const Color(0xFFFFD700), size: r.iconSize(20)),
        SizedBox(width: r.nanoPadding),
        Text('Your Rating', style: GoogleFonts.inter(fontSize: r. bodyS, fontWeight: FontWeight.w700, color: const Color(0xFFD97706))),
        const Spacer(),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < report.rating!  ? Icons.star_rounded : Icons.star_outline_rounded,
              color: const Color(0xFFFFD700),
              size: r.iconSize(20),
            );
          }),
        ),
        ],
      ),
    if (report.feedback != null && report.feedback!. isNotEmpty) ...[
    SizedBox(height: r.microPadding),
    Container(
    width: double.infinity,
    padding: EdgeInsets. all(r.microPadding),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius. circular(r.borderRadius),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('Your Feedback', style: GoogleFonts. inter(fontSize: r.captionXS, color: UserDesign.textTertiary)),
    SizedBox(height: r.atomicPadding),
    Text(report.feedback!, style: GoogleFonts.inter(fontSize: r.captionM, color: UserDesign.textSecondary, fontStyle: FontStyle.italic)),
    ],
    ),
    ),
    ],
    ],
    ),
    );
    } else {
    return GestureDetector(
    onTap: widget.onRate,
    child: Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: r.padding),
    decoration: BoxDecoration(
    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
    borderRadius: BorderRadius.circular(r. borderRadius),
    boxShadow: UserDesign.glowShadow(const Color(0xFFFFD700)),
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment. center,
    children: [
    Icon(Icons.star_rounded, color: Colors.white, size: r.iconSize(22)),
    SizedBox(width: r.nanoPadding),
    Text('Rate & Leave Feedback', style: GoogleFonts.inter(fontSize: r. bodyS, fontWeight: FontWeight.w700, color: Colors. white)),
    ],
    ),
    ),
    );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return UserDesign. warning;
      case 'assigned': return UserDesign.info;
      case 'resolved': return UserDesign.success;
      default: return UserDesign.textTertiary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'assigned': return 'Assigned';
      case 'resolved': return 'Resolved';
      default: return status;
    }
  }

  IconData _getWasteIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('construction')) return Icons.construction_rounded;
    return Icons.delete_rounded;
  }

  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _TimelineStep {
  final String label;
  final DateTime?  timestamp;
  final bool isCompleted;
  final IconData icon;

  _TimelineStep(this.label, this.timestamp, this. isCompleted, this.icon);
}

// ==================== BEFORE/AFTER COMPARISON SHEET ====================

class BeforeAfterComparisonSheet extends StatefulWidget {
  final UserReport report;
  final UserResponsiveData responsive;

  const BeforeAfterComparisonSheet({
    super.key,
    required this.report,
    required this. responsive,
  });

  @override
  State<BeforeAfterComparisonSheet> createState() => _BeforeAfterComparisonSheetState();
}

class _BeforeAfterComparisonSheetState extends State<BeforeAfterComparisonSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSlider = true;
  double _sliderPosition = 0.5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final report = widget.report;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: UserDesign. surfacePure,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r. extraLargeBorderRadius)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: r.dimension(40),
            height: r.dimension(4),
            margin: EdgeInsets. symmetric(vertical: r.microPadding),
            decoration: BoxDecoration(
              color: UserDesign.textLight,
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r. padding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets. all(r.microPadding),
                  decoration: BoxDecoration(
                    gradient: UserDesign.successGradient,
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                  child: Icon(Icons.compare_rounded, color: Colors.white, size: r.iconSize(20)),
                ),
                SizedBox(width: r. microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Before & After', style: GoogleFonts.inter(fontSize: r.headingXS, fontWeight: FontWeight.w700, color: UserDesign.textPrimary)),
                      Text(report.type, style: GoogleFonts.inter(fontSize: r.captionS, color: UserDesign. textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(r. microPadding),
                    decoration: BoxDecoration(color: UserDesign. surfaceLight, shape: BoxShape.circle),
                    child: Icon(Icons. close_rounded, color: UserDesign.textSecondary, size: r.iconSize(20)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: r.microPadding),

          // View Toggle
          Padding(
            padding: EdgeInsets. symmetric(horizontal: r.padding),
            child: Container(
              padding: EdgeInsets.all(r.nanoPadding),
              decoration: BoxDecoration(
                color: UserDesign. surfaceLight,
                borderRadius: BorderRadius. circular(r.pillBorderRadius),
              ),
              child: Row(
                children: [
                  _buildViewToggleButton(r, 'Slider', Icons.compare_arrows_rounded, _showSlider, () {
                    setState(() => _showSlider = true);
                  }),
                  _buildViewToggleButton(r, 'Side by Side', Icons.view_column_rounded, ! _showSlider, () {
                    setState(() => _showSlider = false);
                  }),
                ],
              ),
            ),
          ),

          SizedBox(height: r.padding),

          // Image Comparison
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: r.padding),
              child: _showSlider ?  _buildSliderComparison(r, report) : _buildSideBySideComparison(r, report),
            ),
          ),

          // Info Section
          _buildComparisonInfo(r, report),

          SizedBox(height: r.safePaddingBottom + r.padding),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(UserResponsiveData r, String label, IconData icon, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets. symmetric(vertical: r.microPadding),
          decoration: BoxDecoration(
            color: isActive ? UserDesign.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: r.iconSize(16), color: isActive ? Colors.white : UserDesign. textSecondary),
              SizedBox(width: r.nanoPadding),
              Text(label, style: GoogleFonts.inter(fontSize: r.captionM, fontWeight: FontWeight.w600, color: isActive ?  Colors.white : UserDesign.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderComparison(UserResponsiveData r, UserReport report) {
    return ClipRRect(
      borderRadius: BorderRadius. circular(r.largeBorderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _sliderPosition = (_sliderPosition + details.delta.dx / width). clamp(0.0, 1.0);
              });
            },
            child: Stack(
              children: [
                // After Image (Full)
                Positioned. fill(
                  child: Image.network(
                    report.afterImageUrl ??  '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: UserDesign. surfaceLight),
                  ),
                ),

                // Before Image (Clipped)
                Positioned.fill(
                  child: ClipRect(
                    clipper: _ImageClipper(_sliderPosition * width),
                    child: Image.network(
                      report. beforeImageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: UserDesign.surfaceLight),
                    ),
                  ),
                ),

                // Slider Line
                Positioned(
                  left: _sliderPosition * width - 2,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                    ),
                  ),
                ),

                // Slider Handle
                Positioned(
                  left: _sliderPosition * width - 20,
                  top: height / 2 - 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors. white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors. black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chevron_left_rounded, size: 16, color: UserDesign.textSecondary),
                        Icon(Icons.chevron_right_rounded, size: 16, color: UserDesign.textSecondary),
                      ],
                    ),
                  ),
                ),

                // Before Label
                Positioned(
                  left: r.microPadding,
                  top: r.microPadding,
                  child: Container(
                    padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
                    decoration: BoxDecoration(color: UserDesign. error, borderRadius: BorderRadius.circular(r.smallBorderRadius)),
                    child: Text('BEFORE', style: GoogleFonts.inter(fontSize: r. captionXS, fontWeight: FontWeight. w700, color: Colors.white)),
                  ),
                ),

                // After Label
                Positioned(
                  right: r.microPadding,
                  top: r.microPadding,
                  child: Container(
                    padding: EdgeInsets. symmetric(horizontal: r.microPadding, vertical: r. nanoPadding),
                    decoration: BoxDecoration(color: UserDesign. success, borderRadius: BorderRadius.circular(r.smallBorderRadius)),
                    child: Text('AFTER', style: GoogleFonts.inter(fontSize: r. captionXS, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSideBySideComparison(UserResponsiveData r, UserReport report) {
    return Row(
      children: [
        // Before
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
                decoration: BoxDecoration(color: UserDesign. error, borderRadius: BorderRadius.circular(r.smallBorderRadius)),
                child: Text('BEFORE', style: GoogleFonts.inter(fontSize: r.captionXS, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              SizedBox(height: r.nanoPadding),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  child: Image.network(
                    report.beforeImageUrl ??  '',
                    fit: BoxFit. cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(color: UserDesign.surfaceLight),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: r.microPadding),
        // After
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
                decoration: BoxDecoration(color: UserDesign.success, borderRadius: BorderRadius.circular(r. smallBorderRadius)),
                child: Text('AFTER', style: GoogleFonts.inter(fontSize: r.captionXS, fontWeight: FontWeight.w700, color: Colors. white)),
              ),
              SizedBox(height: r. nanoPadding),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  child: Image.network(
                    report.afterImageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(color: UserDesign.surfaceLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonInfo(UserResponsiveData r, UserReport report) {
    return Container(
      margin: EdgeInsets. symmetric(horizontal: r. padding),
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        color: UserDesign.success. withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: UserDesign.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(color: UserDesign. success, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: Colors.white, size: r.iconSize(20)),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cleanup Verified', style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight.w700, color: UserDesign.success)),
                if (report.cleanupDuration != null)
                  Text(
                    'Cleaned in ${_formatDuration(report.cleanupDuration!)} by ${report.workerName}',
                    style: GoogleFonts.inter(fontSize: r.captionS, color: UserDesign.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration. inHours > 0) {
      return '${duration. inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}

class _ImageClipper extends CustomClipper<Rect> {
  final double clipWidth;

  _ImageClipper(this.clipWidth);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipWidth, size.height);
  }

  @override
  bool shouldReclip(covariant _ImageClipper oldClipper) {
    return oldClipper.clipWidth != clipWidth;
  }
}

// ==================== FEEDBACK DIALOG (FR-U7) ====================

class FeedbackDialog extends StatefulWidget {
  final UserReport report;
  final UserResponsiveData responsive;
  final Function(int rating, String feedback) onSubmit;

  const FeedbackDialog({
    super.key,
    required this.report,
    required this.responsive,
    required this.onSubmit,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final List<String> _quickFeedback = [
    'Excellent work! ',
    'Very thorough cleanup',
    'Quick response time',
    'Area looks great now',
    'Professional service',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves. easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: UserDesign. surfacePure,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(r.extraLargeBorderRadius)),
        child: Container(
          constraints: BoxConstraints(maxWidth: r.dimension(400)),
          padding: EdgeInsets.all(r. largePadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize. min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(r.padding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [const Color(0xFFFFD700). withOpacity(0.15), const Color(0xFFFFD700).withOpacity(0.05)]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star_rounded, size: r.iconSize(40), color: const Color(0xFFFFD700)),
                ),

                SizedBox(height: r.padding),

                Text('Rate the Cleanup', style: GoogleFonts.inter(fontSize: r.headingXS, fontWeight: FontWeight. w700, color: UserDesign.textPrimary)),

                SizedBox(height: r.nanoPadding),

                Text(
                  'How was ${widget.report.workerName}\'s work?',
                  style: GoogleFonts.inter(fontSize: r.bodyS, color: UserDesign. textSecondary),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.largePadding),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment. center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedRating = starIndex);
                      },
                      child: AnimatedScale(
                        scale: _selectedRating >= starIndex ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: r. nanoPadding),
                          child: Icon(
                            _selectedRating >= starIndex ? Icons.star_rounded : Icons. star_outline_rounded,
                            color: _selectedRating >= starIndex ? const Color(0xFFFFD700) : UserDesign.textLight,
                            size: r.iconSize(40),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: r.microPadding),

                // Rating Label
                AnimatedOpacity(
                  opacity: _selectedRating > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getRatingLabel(_selectedRating),
                    style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight.w600, color: _getRatingColor(_selectedRating)),
                  ),
                ),

                SizedBox(height: r.largePadding),

                // Quick Feedback Chips
                Wrap(
                  spacing: r.nanoPadding,
                  runSpacing: r. nanoPadding,
                  children: _quickFeedback.map((text) {
                    final isSelected = _feedbackController.text. contains(text);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (isSelected) {
                          _feedbackController.text = _feedbackController.text. replaceAll(text, ''). trim();
                        } else {
                          if (_feedbackController. text.isNotEmpty) {
                            _feedbackController. text += ' $text';
                          } else {
                            _feedbackController.text = text;
                          }
                        }
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
                        decoration: BoxDecoration(
                          color: isSelected ? UserDesign. primaryTeal. withOpacity(0.15) : UserDesign.surfaceLight,
                          borderRadius: BorderRadius.circular(r.pillBorderRadius),
                          border: Border.all(color: isSelected ? UserDesign.primaryTeal : UserDesign.textLight),
                        ),
                        child: Text(
                          text,
                          style: GoogleFonts.inter(
                            fontSize: r.captionS,
                            fontWeight: isSelected ?  FontWeight.w600 : FontWeight. w500,
                            color: isSelected ? UserDesign. primaryTeal : UserDesign.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: r.padding),

                // Feedback Text Field
                Container(
                  decoration: BoxDecoration(color: UserDesign. surfaceLight, borderRadius: BorderRadius. circular(r.borderRadius)),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    maxLength: 300,
                    style: GoogleFonts. inter(fontSize: r.bodyS, color: UserDesign.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add your feedback (optional)...',
                      hintStyle: GoogleFonts.inter(fontSize: r.captionM, color: UserDesign. textTertiary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(r. borderRadius), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r.borderRadius), borderSide: const BorderSide(color: UserDesign. primaryTeal, width: 2)),
                      contentPadding: EdgeInsets.all(r.microPadding),
                      counterStyle: GoogleFonts.inter(fontSize: r. captionXS, color: UserDesign.textTertiary),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                SizedBox(height: r.largePadding),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: r.buttonHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: UserDesign.textLight),
                            borderRadius: BorderRadius.circular(r. borderRadius),
                          ),
                          child: Center(
                            child: Text('Cancel', style: GoogleFonts.inter(fontSize: r. bodyS, fontWeight: FontWeight.w600, color: UserDesign.textSecondary)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: r.microPadding),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _selectedRating > 0 ? () => widget.onSubmit(_selectedRating, _feedbackController. text. trim()) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: r.buttonHeight,
                          decoration: BoxDecoration(
                            gradient: _selectedRating > 0 ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]) : null,
                            color: _selectedRating > 0 ?  null : UserDesign. textLight,
                            borderRadius: BorderRadius.circular(r. borderRadius),
                            boxShadow: _selectedRating > 0 ? UserDesign.glowShadow(const Color(0xFFFFD700)) : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment. center,
                            children: [
                              Icon(Icons. send_rounded, size: r. iconSize(18), color: _selectedRating > 0 ? Colors.white : UserDesign.textTertiary),
                              SizedBox(width: r.nanoPadding),
                              Text(
                                'Submit Feedback',
                                style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight.w600, color: _selectedRating > 0 ? Colors. white : UserDesign.textTertiary),
                              ),
                            ],
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
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1: return 'Poor 😞';
      case 2: return 'Fair 😐';
      case 3: return 'Good 🙂';
      case 4: return 'Very Good 😊';
      case 5: return 'Excellent!  🤩';
      default: return '';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1: return UserDesign.error;
      case 2: return UserDesign.warning;
      case 3: return UserDesign.info;
      case 4: return UserDesign.success;
      case 5: return const Color(0xFFFFD700);
      default: return UserDesign.textTertiary;
    }
  }
}