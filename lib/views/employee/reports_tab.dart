import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/reports_tab_viewmodel.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/reports_components/reports_header.dart';
import 'package:neat_now/views/employee/reports_components/reports_list.dart';
import 'package:neat_now/views/employee/reports_components/report_details_page.dart';
import 'package:neat_now/views/employee/reports_components/full_screen_image_page.dart';
import 'package:neat_now/views/employee/reports_components/resolve_sheet.dart';
import 'package:neat_now/views/employee/reports_components/ai_verification_dialog.dart';
import 'package:neat_now/views/employee/reports_components/success_animation_dialog.dart';
import 'dart:math' as math;

/// Employee Reports Tab (MVVM View)
class EmployeeReportsTab extends StatefulWidget {
  final Future<List<Report>> reportsFuture;
  final Function(int, String, {String? imagePath, double? latitude, double? longitude, String? locationAddress}) onUpdateStatus;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;
  final int overdueCount;

  const EmployeeReportsTab({
    super.key,
    required this.reportsFuture,
    required this.onUpdateStatus,
    required this.onRefresh,
    required this. responsive,
    this.overdueCount = 0,
  });

  @override
  State<EmployeeReportsTab> createState() => _EmployeeReportsTabState();
}

class _EmployeeReportsTabState extends State<EmployeeReportsTab>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;
  late AnimationController _refreshController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shimmerAnimation;

  // State
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  late ReportsTabViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ReportsTabViewModel();
    _initAnimations();
    _scrollController.addListener(_onScroll);
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
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve:  Curves.easeOutCubic,
    ));

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    ).. repeat();
    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // ✅ SAFE ANIMATION START
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  void _onScroll() {
    if (mounted) {
      setState(() => _scrollOffset = _scrollController. offset);
    }
  }

  void _handleRefresh() {
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    _refreshController.forward(from: 0);
    widget.onRefresh();
  }

  @override
  void dispose() {
    // ✅ STOP ALL ANIMATIONS FIRST
    _fadeController.stop();
    _slideController.stop();
    _shimmerController. stop();
    _refreshController. stop();

    // ✅ THEN DISPOSE
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    _refreshController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _viewModel.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return FutureBuilder<List<Report>>(
      future: widget.reportsFuture,
      builder:  (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(r);
        }
        if (snapshot.hasError) {
          return _buildErrorState(r, snapshot.error. toString());
        }
        if (! snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(r);
        }

        final allReports = snapshot.data!;
        final filteredReports = _viewModel.filterReports(allReports);

        return ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            return FadeTransition(
              opacity:  _fadeAnimation,
              child:  SlideTransition(
                position:  _slideAnimation,
                child:  Column(
                  children: [
                    ReportsHeader(
                      viewModel: _viewModel,
                      responsive: r,
                      allReports: allReports,
                      scrollOffset: _scrollOffset,
                      searchController: _searchController,
                      refreshAnimation: _refreshController,
                      onRefresh: _handleRefresh,
                      onSearchChanged: (query) {
                        _viewModel.setSearchQuery(query);
                      },
                      onSearchClear: () {
                        _searchController.clear();
                        _viewModel.setSearchQuery('');
                      },
                      onSearchToggle: () {
                        _viewModel. toggleSearchExpanded();
                      },
                      onFilterSelected: (filter) {
                        HapticFeedback.selectionClick();
                        _viewModel. setSelectedFilter(filter);
                      },
                    ),
                    Expanded(
                      child: filteredReports.isEmpty
                          ? _buildNoResultsState(r)
                          : ReportsList(
                        viewModel: _viewModel,
                        responsive: r,
                        reports: filteredReports,
                        scrollController: _scrollController,
                        shimmerAnimation: _shimmerAnimation,
                        onRefresh: _handleRefresh,
                        onReportTap: _showReportDetails,
                        onImageTap: _showFullScreenImage,
                        onNavigate: _openNavigation,
                        onUpdateStatus: widget.onUpdateStatus,
                        onShowResolveSheet: _showResolveSheet,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== NAVIGATION & DIALOGS ====================

  void _showReportDetails(Report report) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ReportDetailsPage(
          report: report,
          viewModel: _viewModel,
          responsive: widget.responsive,
          onUpdateStatus: widget.onUpdateStatus,
          onShowResolveDialog: () {
            Navigator.pop(context);
            _showResolveSheet(report);
          },
          onNavigate: _openNavigation,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity:  animation,
            child: SlideTransition(
              position:  Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds:  300),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:  (context, animation, secondaryAnimation) => FullScreenImagePage(
          imageUrl: imageUrl,
          responsive: widget.responsive,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _showResolveSheet(Report report) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ResolveSheet(
        report: report,
        responsive: widget.responsive,
        imagePicker: _imagePicker,
        onResolve: (imagePath, lat, lng, address, timestamp) {
          Navigator.pop(sheetContext);
          _showAIVerificationDialog(report, imagePath, lat, lng, address, timestamp);
        },
      ),
    );
  }

  void _showAIVerificationDialog(
      Report report,
      String imagePath,
      double lat,
      double lng,
      String address,
      DateTime timestamp,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black. withOpacity(0.5),
      builder: (dialogContext) => AIVerificationDialog(
        report:  report,
        responsive: widget.responsive,
        afterImagePath: imagePath,
        latitude: lat,
        longitude: lng,
        address: address,
        timestamp: timestamp,
        onSuccess: () {
          Navigator.pop(dialogContext);
          widget.onUpdateStatus(
            report. id,
            'resolved',
            imagePath:  imagePath,
            latitude: lat,
            longitude: lng,
            locationAddress: address,
          );
          _showSuccessAnimation();
        },
        onRetry: () {
          Navigator. pop(dialogContext);
          _showResolveSheet(report);
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white. withOpacity(0.97),
      builder: (dialogContext) => SuccessAnimationDialog(
        responsive: widget.responsive,
        onComplete: () {
          Navigator.pop(dialogContext);
          widget.onRefresh();
        },
      ),
    );
  }

  Future<void> _openNavigation(double lat, double lng) async {
    HapticFeedback.mediumImpact();
    // Navigation logic will be in a separate utility
    // For now, just import url_launcher in the component
  }

  // ==================== STATES ====================

  Widget _buildLoadingState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween:  Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: r.dimension(60),
              height: r.dimension(60),
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    ReportsDesign.primaryTeal,
                    ReportsDesign.primaryTeal.withOpacity(0.1),
                    ReportsDesign.primaryTeal,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: r. dimension(50),
                  height: r. dimension(50),
                  decoration: const BoxDecoration(
                    color: ReportsDesign.surfacePure,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.assignment_rounded,
                    size: r.iconSize(24),
                    color: ReportsDesign.primaryTeal,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: r.padding),
          if (r.showMinimalText)
            Text(
              'Loading tasks...',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: ReportsDesign.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(EmployeeResponsiveData r, String error) {
    return Center(
        child:  Padding(
          padding: EdgeInsets.all(r.largePadding),
          child: Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
          Container(
          padding: EdgeInsets.all(r.largePadding),
          decoration: const BoxDecoration(
            color:  ReportsDesign.errorLight,
            shape: BoxShape. circle,
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: r. iconSize(48),
            color: ReportsDesign.error,
          ),
        ),
        SizedBox(height: r.padding),
        Text(
          'Failed to load tasks',
          style: GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight.w700,
            color: ReportsDesign.textPrimary,
          ),
        ),
        if (r.showSecondaryText) ...[
    SizedBox(height: r.nanoPadding),
    Text(
    'Please check your connection',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: ReportsDesign.textSecondary,
    ),
    textAlign: TextAlign.center,
    ),
    ],
    SizedBox(height: r. padding),
    ElevatedButton. icon(
    onPressed: _handleRefresh,
    icon:  Icon(Icons.refresh_rounded, size: r.iconSize(18)),
    label: Text(
    'Try Again',
    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ),
    style: ElevatedButton.styleFrom(
    backgroundColor: ReportsDesign.primaryTeal,
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

  Widget _buildEmptyState(EmployeeResponsiveData r) {
    return Center(
      child:  Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: EdgeInsets.all(r.largePadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ReportsDesign.primaryTeal. withOpacity(0.15),
                      ReportsDesign.primaryTeal.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  size: r.iconSize(56),
                  color: ReportsDesign.primaryTeal,
                ),
              ),
            ),
            SizedBox(height:  r.padding),
            Text(
              'All caught up!',
              style: GoogleFonts.inter(
                fontSize: r.headingXS,
                fontWeight: FontWeight.w700,
                color: ReportsDesign.textPrimary,
              ),
            ),
            if (r.showSecondaryText) ...[
              SizedBox(height: r.nanoPadding),
              Text(
                'No tasks assigned yet.\nNew tasks will appear here.',
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  color: ReportsDesign.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(r.largePadding),
            decoration: const BoxDecoration(
              color:  ReportsDesign.surfaceLight,
              shape: BoxShape. circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: r.iconSize(48),
              color: ReportsDesign.textTertiary,
            ),
          ),
          SizedBox(height: r.padding),
          Text(
            'No matching tasks',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w600,
              color: ReportsDesign.textPrimary,
            ),
          ),
          if (r.showSecondaryText) ...[
            SizedBox(height: r.nanoPadding),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: ReportsDesign. textSecondary,
              ),
            ),
          ],
          SizedBox(height: r. padding),
          TextButton. icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _searchController.clear();
              _viewModel.clearFilters();
            },
            icon: Icon(Icons.clear_all_rounded, size: r.iconSize(18)),
            label: Text(
              'Clear filters',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor: ReportsDesign. primaryTeal,
            ),
          ),
        ],
      ),
    );
  }
}