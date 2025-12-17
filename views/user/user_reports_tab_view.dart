import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/models/user/user_report_model.dart';
import 'package:neat_now/viewmodels/user/user_reports_viewmodel.dart';
import 'package:neat_now/views/user/components/report_detail_sheet.dart';
import 'package:neat_now/views/user/components/before_after_comparison_sheet.dart';
import 'package:neat_now/views/user/components/feedback_dialog.dart';

/// ==================== USER REPORTS TAB (FR-U5, FR-U7) ====================
class UserReportsTab extends StatefulWidget {
  final Map<String, dynamic> userData;
  final UserResponsiveData responsive;
  final VoidCallback onReportWaste;

  const UserReportsTab({
    super.key,
    required this. userData,
    required this.responsive,
    required this.onReportWaste,
  });

  @override
  State<UserReportsTab> createState() => _UserReportsTabState();
}

class _UserReportsTabState extends State<UserReportsTab>
    with TickerProviderStateMixin {
  late UserReportsViewModel _viewModel;
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerFadeAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();

    // Initialize ViewModel
    _viewModel = UserReportsViewModel(
      onReportWaste: widget.onReportWaste,
    );
    _viewModel.addListener(_onViewModelChanged);

    _initAnimations();
    _scrollController.addListener(_onScroll);
    _startAnimations();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds:  600),
      vsync: this,
    );
    _headerFadeAnimation = CurvedAnimation(
      parent:  _headerController,
      curve:  Curves.easeOutCubic,
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
    if (mounted) setState(() => _scrollOffset = _scrollController. offset);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _headerController.dispose();
    _listController.dispose();
    _scrollController.dispose();
    super.dispose();
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
          child: _viewModel.filteredReports. isEmpty
              ? _buildEmptyState(r)
              : ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              r.padding,
              r.microPadding,
              r. padding,
              r.safePaddingBottom + 100,
            ),
            itemCount: _viewModel.filteredReports.length,
            itemBuilder: (context, index) => _buildReportCard(
              r,
              _viewModel. filteredReports[index],
              index,
            ),
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
        padding: EdgeInsets.fromLTRB(
          r.padding,
          r.safePaddingTop + r.microPadding,
          r.padding,
          r. microPadding,
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
                  padding: EdgeInsets.all(r.microPadding),
                  decoration: BoxDecoration(
                    gradient: UserDesign.primaryGradient,
                    borderRadius: BorderRadius.circular(r.borderRadius),
                    boxShadow: UserDesign. glowShadow(UserDesign.primaryTeal),
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
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Reports',
                        style: GoogleFonts.inter(
                          fontSize: r.headingXS,
                          fontWeight: FontWeight.w800,
                          color: UserDesign.textPrimary,
                        ),
                      ),
                      Text(
                        '${_viewModel.totalReportsCount} total reports',
                        style: GoogleFonts.inter(
                          fontSize: r.captionS,
                          color: UserDesign.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onReportWaste,
                  child: Container(
                    padding:  EdgeInsets.all(r. microPadding),
                    decoration: BoxDecoration(
                      color: UserDesign.surfaceLight,
                      borderRadius: BorderRadius.circular(r.borderRadius),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: UserDesign.primaryTeal,
                      size:  r.iconSize(22),
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
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _viewModel.filterOptions.length,
        separatorBuilder: (_, __) => SizedBox(width: r.microPadding),
        itemBuilder: (context, index) {
          final filter = _viewModel.filterOptions[index];
          final isSelected = _viewModel.selectedFilter == filter. value;
          final count = _viewModel.getFilterCount(filter.value);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _viewModel. selectFilter(filter.value);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r. nanoPadding,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [filter.color, filter.color.withOpacity(0.85)],
                )
                    : null,
                color: isSelected ? null : UserDesign.surfaceLight,
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
                boxShadow: isSelected ?  UserDesign.glowShadow(filter.color) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter. icon,
                    size: r.iconSize(14),
                    color: isSelected ? Colors.white : filter.color,
                  ),
                  SizedBox(width:  r.nanoPadding),
                  Text(
                    '${filter.label} ($count)',
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight.w600,
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
  Widget _buildReportCard(UserResponsiveData r, UserReportModel report, int index) {
    final color = _viewModel.getStatusColor(report.status);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin:  0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child:  Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
          onTap: () => _showReportDetails(r, report),
          child: Container(
              margin: EdgeInsets.only(bottom: r.microPadding),
              decoration: BoxDecoration(
                color: UserDesign.surfacePure,
                borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
                boxShadow: UserDesign. softShadow,
                border: Border.all(
                  color: report.needsRating
                      ? const Color(0xFFFFD700).withOpacity(0.5)
                      : color. withOpacity(0.1),
                  width: report.needsRating ? 2 : 1,
                ),
              ),
              child: Column(
                  children: [
              Padding(
              padding: EdgeInsets.all(r.padding),
              child: Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
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
                      crossAxisAlignment:  CrossAxisAlignment.start,
                      children: [
                    Row(
                    children: [
                    Expanded(
                    child:  Text(
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
              SizedBox(height: r.nanoPadding),
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: r.iconSize(12),
                    color: UserDesign.textTertiary,
                  ),
                  SizedBox(width: r.atomicPadding),
                  Expanded(
                    child:  Text(
                      report. location,
                      style:  GoogleFonts.inter(
                        fontSize: r.captionS,
                        color: UserDesign.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height:  r.atomicPadding),
              Row(
                children: [
                Icon(
                Icons.access_time_rounded,
                size: r.iconSize(10),
                color: UserDesign.textLight,
              ),
              SizedBox(width:  r.atomicPadding),
              Text(
                _viewModel.formatDate(report.submittedAt),
                style: GoogleFonts.inter(
                  fontSize: r.captionXS,
                  color:  UserDesign.textTertiary,
                ),
              ),
              if (report.workerName != null) ...[
          SizedBox(width: r.microPadding),
      Icon(
        Icons. person_rounded,
        size: r.iconSize(10),
        color: UserDesign.textLight,
      ),
      SizedBox(width: r.atomicPadding),
      Expanded(
        child:  Text(
          report. workerName!,
          style: GoogleFonts. inter(
            fontSize:  r.captionXS,
            color:  UserDesign.info,
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
    if (report. isResolved && report.hasAfterImage) ...[
    SizedBox(height: r.microPadding),
    _buildBeforeAfterPreview(r, report),
    ],

    // Rating Section (for resolved reports)
    if (report.isResolved) ...[
    SizedBox(height: r.microPadding),
    _buildResolvedSection(r, report),
    ],
    ],
    ),
    ),

    // Progress Indicator (for non-resolved reports)
    if (! report.isResolved) _buildProgressIndicator(r, report. status),
    ],
    ),
    ),
    ),
    );
    }

  Widget _buildReportThumbnail(
      UserResponsiveData r, UserReportModel report, Color color) {
    final size = r.dimension(60);

    if (report.beforeImageUrl != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(r.borderRadius),
            child: Image.network(
              report.beforeImageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _buildIconThumbnail(r, report, color, size),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: size,
                  height:  size,
                  decoration: BoxDecoration(
                    color: UserDesign.surfaceLight,
                    borderRadius:  BorderRadius.circular(r.borderRadius),
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
          if (report.isResolved && report.hasAfterImage)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.nanoPadding,
                  vertical: r.atomicPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Row(
                  mainAxisSize:  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      size:  r.iconSize(10),
                      color: Colors. white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '2',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS - 1,
                        fontWeight: FontWeight.w600,
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
      UserReportModel report,
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
      child: Icon(
        _viewModel.getWasteIcon(report.type),
        color: color,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildStatusBadge(UserResponsiveData r, String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical:  r.atomicPadding,
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
            _viewModel.getStatusLabel(status),
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BEFORE/AFTER PREVIEW ====================
  Widget _buildBeforeAfterPreview(UserResponsiveData r, UserReportModel report) {
    return GestureDetector(
      onTap: () => _showBeforeAfterComparison(r, report),
      child: Container(
        padding: EdgeInsets.all(r.microPadding),
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
                borderRadius: BorderRadius.circular(r. smallBorderRadius),
                child:  Stack(
                  children: [
                    Image.network(
                      report.beforeImageUrl ??  '',
                      height: r.dimension(60),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: r. dimension(60),
                        color: UserDesign.surfaceLight,
                        child: Icon(
                          Icons. image_not_supported_rounded,
                          color: UserDesign.textTertiary,
                        ),
                      ),
                    ),
                    Positioned(
                      top: r.atomicPadding,
                      left: r.atomicPadding,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r. nanoPadding,
                          vertical: r.atomicPadding,
                        ),
                        decoration: BoxDecoration(
                          color: UserDesign. error,
                          borderRadius: BorderRadius.circular(r.smallBorderRadius),
                        ),
                        child: Text(
                          'Before',
                          style: GoogleFonts.inter(
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

            // Arrow
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.nanoPadding),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: UserDesign.success,
                size: r.iconSize(20),
              ),
            ),

            // After Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
                child: Stack(
                  children: [
                    Image.network(
                      report.afterImageUrl ?? '',
                      height: r.dimension(60),
                      width:  double.infinity,
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
                          horizontal: r. nanoPadding,
                          vertical: r.atomicPadding,
                        ),
                        decoration: BoxDecoration(
                          color: UserDesign. success,
                          borderRadius:  BorderRadius.circular(r.smallBorderRadius),
                        ),
                        child: Text(
                          'After',
                          style: GoogleFonts.inter(
                            fontSize: r. captionXS - 2,
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
  Widget _buildResolvedSection(UserResponsiveData r, UserReportModel report) {
    if (report.rating != null) {
      // Already rated
      return Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withOpacity(0.1),
              const Color(0xFFFFD700).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Row(
        children: [
        Container(
        padding: EdgeInsets.all(r.nanoPadding),
        decoration:  BoxDecoration(
          color: const Color(0xFFFFD700),
          borderRadius: BorderRadius.circular(r.smallBorderRadius),
        ),
        child: Icon(
          Icons.verified_rounded,
          color: Colors.white,
          size: r.iconSize(14),
        ),
      ),
    SizedBox(width:  r.microPadding),
    Expanded(
    child: Column(
    crossAxisAlignment:  CrossAxisAlignment.start,
    children: [
    Text(
    'Your Feedback',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    fontWeight: FontWeight.w600,
    color: UserDesign.textPrimary,
    ),
    ),
    if (report.cleanupDuration != null)
    Text(
    'Cleaned in ${_viewModel.formatDuration(report.cleanupDuration! )}',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    color: UserDesign.textSecondary,
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
    ? Icons.star_rounded
        : Icons.star_outline_rounded,
    color:  const Color(0xFFFFD700),
    size: r.iconSize(16),
    );
    }),
    ),
    ],
    ),
    if (report.feedback != null && report.feedback!.isNotEmpty) ...[
    SizedBox(height: r.microPadding),
    Container(
    padding: EdgeInsets.all(r.microPadding),
    decoration:  BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(r.smallBorderRadius),
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
    report.feedback! ,
    style: GoogleFonts.inter(
    fontSize: r.captionS,
    color: UserDesign.textSecondary,
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
    // Not rated yet
    return GestureDetector(
    onTap: () => _showFeedbackDialog(r, report),
    child: Container(
    padding: EdgeInsets. all(r.microPadding),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [
    const Color(0xFFFFD700).withOpacity(0.15),
    const Color(0xFFFFD700).withOpacity(0.08),
    ],
    ),
    borderRadius: BorderRadius.circular(r.borderRadius),
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
    child:  Icon(
    Icons.star_rounded,
    color: Colors. white,
    size: r.iconSize(16),
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Cleanup Complete!   🎉',
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
    vertical: r.nanoPadding,
    ),
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    ),
    borderRadius: BorderRadius.circular(r.pillBorderRadius),
    ),
    child: Text(
    'Rate Now',
    style: GoogleFonts.inter(
    fontSize: r.captionS,
    fontWeight: FontWeight.w600,
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
          bottom: Radius.circular(r. extraLargeBorderRadius),
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
                color: isCompleted ? UserDesign.success : UserDesign.textLight,
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
                  height: r. dimension(20),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? UserDesign.success
                        : (isCurrent ? UserDesign. warning : UserDesign.surfaceOverlay),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? Colors.transparent
                          : UserDesign. textLight,
                      width: 1,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                    Icons.check_rounded,
                    color: Colors. white,
                    size: r.iconSize(12),
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
                        : UserDesign.textTertiary,
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
      child:  Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(r.largePadding),
              decoration:  BoxDecoration(
                color:  UserDesign.surfaceOverlay,
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
              _viewModel.selectedFilter == 'all'
                  ?  'No reports yet'
                  : 'No ${_viewModel.selectedFilter} reports',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: UserDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              _viewModel.selectedFilter == 'all'
                  ? 'Start by reporting waste in your area'
                  : 'Try changing the filter to see more reports',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: UserDesign.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r. padding),
            if (_viewModel.selectedFilter == 'all')
              GestureDetector(
                onTap: widget.onReportWaste,
                child: Container(
                  padding: EdgeInsets. symmetric(
                    horizontal: r. padding,
                    vertical: r. microPadding,
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
                        Icons.add_a_photo_rounded,
                        color: Colors.white,
                        size: r.iconSize(18),
                      ),
                      SizedBox(width: r. nanoPadding),
                      Text(
                        'Report Waste',
                        style:  GoogleFonts.inter(
                          fontSize: r.bodyS,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () => _viewModel. selectFilter('all'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.padding,
                    vertical: r.microPadding,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: UserDesign.primaryTeal),
                    borderRadius: BorderRadius.circular(r. borderRadius),
                  ),
                  child: Text(
                    'Show All Reports',
                    style:  GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight:  FontWeight.w600,
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
  void _showReportDetails(UserResponsiveData r, UserReportModel report) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDetailSheet(
        report:  report,
        responsive: r,
        viewModel: _viewModel,
        onRate: () {
          Navigator.pop(context);
          _showFeedbackDialog(r, report);
        },
        onViewImages: () {
          Navigator.pop(context);
          _showBeforeAfterComparison(r, report);
        },
      ),
    );
  }

  void _showBeforeAfterComparison(UserResponsiveData r, UserReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:  Colors.transparent,
      builder: (context) => BeforeAfterComparisonSheet(
        report:  report,
        responsive: r,
        viewModel: _viewModel,
      ),
    );
  }

  void _showFeedbackDialog(UserResponsiveData r, UserReportModel report) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        report:  report,
        responsive: r,
        onSubmit: (rating, feedback) {
          Navigator.pop(context);
          _viewModel.updateReportRating(report.id, rating, feedback);
          _showSnackBar('Thank you for your feedback!  🎉');
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: GoogleFonts. inter(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: UserDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}