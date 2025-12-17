import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// ==================== DESIGN SYSTEM ====================
class ReportsDesign {
  // Primary Accent - Vibrant Teal
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color primaryTealGlow = Color(0xFF95E1D3);

  // Surfaces - Pure White & Light
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);
  static const Color surfaceOverlay = Color(0xFFF3F4F6);

  // Text - Dark Gray/Soft Black
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);

  // Status Colors
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

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors. black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black. withOpacity(0.06),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get hoverShadow => [
    BoxShadow(
      color: primaryTeal.withOpacity(0.15),
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
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

  static LinearGradient get successGradient => LinearGradient(
    colors: [success, success.withOpacity(0.85)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shimmerGradient(double value) => LinearGradient(
    colors: [
      Colors.white.withOpacity(0.0),
      Colors. white.withOpacity(0.3),
      Colors.white.withOpacity(0.0),
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment(-1.0 + value * 2, 0),
    end: Alignment(1.0 + value * 2, 0),
  );
}

/// ==================== EMPLOYEE REPORTS TAB ====================
class EmployeeReportsTab extends StatefulWidget {
  final Future<List<Report>> reportsFuture;
  final Function(int, String, {String?  imagePath, double? latitude, double?  longitude, String? locationAddress}) onUpdateStatus;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;
  final int overdueCount;

  const EmployeeReportsTab({
    super.key,
    required this.reportsFuture,
    required this.onUpdateStatus,
    required this.onRefresh,
    required this.responsive,
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
  String _selectedFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchExpanded = false;
  double _scrollOffset = 0;
  int?  _hoveredCardIndex;

  // Filter options
  final List<_FilterOption> _filters = [
    _FilterOption('all', 'All Tasks', 'All', 'A', ReportsDesign.textSecondary, Icons.all_inbox_rounded),
    _FilterOption('pending', 'Pending', 'New', 'N', ReportsDesign.warning, Icons.schedule_rounded),
    _FilterOption('in-progress', 'In Progress', 'Active', 'P', ReportsDesign.info, Icons.sync_rounded),
    _FilterOption('resolved', 'Completed', 'Done', 'D', ReportsDesign. success, Icons.check_circle_rounded),
  ];

  @override
  void initState() {
    super.initState();
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
      curve: Curves.easeOutCubic,
    ));

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    ).. repeat();
    _shimmerAnimation = Tween<double>(begin: 0, end: 1). animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController. forward();
    _slideController.forward();
  }

  void _onScroll() {
    if (mounted) {
      setState(() => _scrollOffset = _scrollController.offset);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _shimmerController. dispose();
    _refreshController.dispose();
    _searchController.dispose();
    _scrollController. dispose();
    super. dispose();
  }

  List<Report> _filterReports(List<Report> reports) {
    var filtered = reports;

    if (_selectedFilter != 'all') {
      filtered = filtered.where((r) => r.status == _selectedFilter). toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((r) =>
      r.type.toLowerCase().contains(query) ||
          r.location.toLowerCase().contains(query) ||
          r.userName.toLowerCase().contains(query) ||
          r. id.toString().contains(query)).toList();
    }

    filtered. sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  int _getCount(List<Report> reports, String filter) {
    if (filter == 'all') return reports. length;
    return reports.where((r) => r.status == filter).length;
  }

  void _handleRefresh() {
    HapticFeedback.mediumImpact();
    _refreshController.forward(from: 0);
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return FutureBuilder<List<Report>>(
      future: widget. reportsFuture,
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

        final allReports = snapshot. data!;
        final filteredReports = _filterReports(allReports);

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(r, allReports),
                Expanded(
                  child: filteredReports.isEmpty
                      ? _buildNoResultsState(r)
                      : _buildReportsList(r, filteredReports),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(EmployeeResponsiveData r, List<Report> allReports) {
    final showElevation = _scrollOffset > 10;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.fromLTRB(r.padding, r.padding, r. padding, r.microPadding),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        boxShadow: showElevation ? ReportsDesign.softShadow : null,
      ),
      child: Column(
        children: [
          _buildTitleRow(r),
          SizedBox(height: r.microPadding),
          _buildSearchBar(r),
          SizedBox(height: r.microPadding),
          _buildFilterChips(r, allReports),
        ],
      ),
    );
  }

  Widget _buildTitleRow(EmployeeResponsiveData r) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.adaptiveText('My Tasks', nano: 'T', micro: 'Tasks', mini: 'My Tasks'),
                style: GoogleFonts.inter(
                  fontSize: r.headingS,
                  fontWeight: FontWeight. w800,
                  color: ReportsDesign.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (r.showSecondaryText)
                Text(
                  'Manage your assigned reports',
                  style: GoogleFonts.inter(
                    fontSize: r. captionM,
                    color: ReportsDesign.textSecondary,
                  ),
                ),
            ],
          ),
        ),

        if (! _isSearchExpanded && r.effectiveWidth < 400)
          _buildHeaderIconButton(
            r,
            Icons.search_rounded,
                () => setState(() => _isSearchExpanded = true),
          ),

        SizedBox(width: r.nanoPadding),

        AnimatedBuilder(
          animation: _refreshController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _refreshController.value * 2 * math.pi,
              child: child,
            );
          },
          child: _buildHeaderIconButton(r, Icons.refresh_rounded, _handleRefresh),
        ),
      ],
    );
  }

  Widget _buildHeaderIconButton(EmployeeResponsiveData r, IconData icon, VoidCallback onTap) {
    return Material(
      color: ReportsDesign.surfaceLight,
      borderRadius: BorderRadius. circular(r.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r. borderRadius),
        child: Container(
          width: r.buttonHeightSmall,
          height: r.buttonHeightSmall,
          alignment: Alignment.center,
          child: Icon(icon, size: r.iconSize(20), color: ReportsDesign.textSecondary),
        ),
      ),
    );
  }

  Widget _buildSearchBar(EmployeeResponsiveData r) {
    final showSearch = _isSearchExpanded || r.effectiveWidth >= 400;

    if (!showSearch) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: r.buttonHeight,
      decoration: BoxDecoration(
        color: ReportsDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r. largeBorderRadius),
      ),
      child: Row(
        children: [
          SizedBox(width: r.microPadding),
          Icon(Icons.search_rounded, color: ReportsDesign.textTertiary, size: r.iconSize(20)),
          SizedBox(width: r.microPadding),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.inter(fontSize: r.bodyS, color: ReportsDesign.textPrimary),
              decoration: InputDecoration(
                hintText: r.adaptiveText(
                  'Search by type, location, or ID.. .',
                  nano: 'Search',
                  micro: 'Search.. .',
                  mini: 'Search tasks.. .',
                ),
                hintStyle: GoogleFonts.inter(fontSize: r.bodyS, color: ReportsDesign.textTertiary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: r.microPadding),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Padding(
                padding: EdgeInsets. all(r.microPadding),
                child: Icon(Icons.close_rounded, color: ReportsDesign. textTertiary, size: r.iconSize(18)),
              ),
            ),
          if (_isSearchExpanded && r.effectiveWidth < 400)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _isSearchExpanded = false;
                });
              },
              child: Padding(
                padding: EdgeInsets. all(r.microPadding),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    color: ReportsDesign. primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          SizedBox(width: r.microPadding),
        ],
      ),
    );
  }

  Widget _buildFilterChips(EmployeeResponsiveData r, List<Report> allReports) {
    return SizedBox(
      height: r.dimension(44),
      child: ListView.separated(
        scrollDirection: Axis. horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: r.microPadding),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final count = _getCount(allReports, filter. value);
          return _buildFilterChip(r, filter, count);
        },
      ),
    );
  }

  Widget _buildFilterChip(EmployeeResponsiveData r, _FilterOption filter, int count) {
    final isSelected = _selectedFilter == filter. value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = filter.value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets. symmetric(horizontal: r.microPadding, vertical: r. nanoPadding),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [filter.color, filter. color.withOpacity(0.85)])
              : null,
          color: isSelected ? null : ReportsDesign.surfaceLight,
          borderRadius: BorderRadius.circular(r.pillBorderRadius),
          boxShadow: isSelected ? ReportsDesign.glowShadow(filter.color) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(filter.icon, size: r.iconSize(16), color: isSelected ? Colors.white : filter.color),
            SizedBox(width: r.nanoPadding),
            Text(
              r.adaptiveText(filter.label, nano: filter.nano, micro: filter. shortLabel, mini: filter.shortLabel),
              style: GoogleFonts.inter(
                fontSize: r. captionM,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ReportsDesign.textSecondary,
              ),
            ),
            if (count > 0 && r.showBadges) ...[
              SizedBox(width: r.nanoPadding),
              Container(
                padding: EdgeInsets.symmetric(horizontal: r. nanoPadding, vertical: r.atomicPadding),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white. withOpacity(0.25) : filter.color.withOpacity(0.15),
                  borderRadius: BorderRadius. circular(r.smallBorderRadius),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : filter.color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== REPORTS LIST ====================
  Widget _buildReportsList(EmployeeResponsiveData r, List<Report> reports) {
    return RefreshIndicator(
      onRefresh: () async => _handleRefresh(),
      color: ReportsDesign.primaryTeal,
      backgroundColor: ReportsDesign.surfacePure,
      strokeWidth: 2.5,
      displacement: 60,
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets. all(r.padding),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return _buildReportCard(r, reports[index], index);
        },
      ),
    );
  }

  Widget _buildReportCard(EmployeeResponsiveData r, Report report, int index) {
    final statusColor = _getStatusColor(report.status);
    final hasLocation = report.latitude != null && report. longitude != null &&
        report.latitude != 0.0 && report. longitude != 0.0;
    final isHovered = _hoveredCardIndex == index;

    return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: Duration(milliseconds: 400 + (index * 60)),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
    return Transform.translate(
    offset: Offset(0, 30 * (1 - value)),
    child: Opacity(opacity: value, child: child),
    );
    },
    child: MouseRegion(
    onEnter: (_) => setState(() => _hoveredCardIndex = index),
    onExit: (_) => setState(() => _hoveredCardIndex = null),
    child: GestureDetector(
    onTap: () => _showReportDetails(report),
    child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    margin: EdgeInsets. only(bottom: r.padding),
    transform: isHovered
    ? (Matrix4.identity().. translate(0.0, -4.0))
        : Matrix4.identity(),
    decoration: BoxDecoration(
    color: ReportsDesign.surfacePure,
    borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
    boxShadow: isHovered ? ReportsDesign.hoverShadow : ReportsDesign.elevatedShadow,
    border: isHovered
    ? Border.all(color: ReportsDesign. primaryTeal. withOpacity(0.3), width: 1.5)
        : null,
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (report.imageUrl != null && report.imageUrl! .isNotEmpty)
    _buildImageSection(r, report, statusColor, hasLocation),
    Padding(
    padding: EdgeInsets. all(r.padding),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    _buildCardHeader(r, report, statusColor),
    SizedBox(height: r.microPadding),
    _buildCardDetails(r, report, hasLocation),
    SizedBox(height: r.padding),
    _buildCardActions(r, report, hasLocation),
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    );
  }

  Widget _buildImageSection(
      EmployeeResponsiveData r,
      Report report,
      Color statusColor,
      bool hasLocation,
      ) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(r.extraLargeBorderRadius)),
      child: Stack(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ). createShader(bounds),
            blendMode: BlendMode.darken,
            child: Image.network(
              report. imageUrl!,
              height: r.reportImageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: r.reportImageHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ReportsDesign.surfaceLight, ReportsDesign.surfaceOverlay],
                    begin: Alignment. topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.broken_image_rounded, size: r. dimension(40), color: ReportsDesign.textTertiary),
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: r.reportImageHeight,
                  color: ReportsDesign.surfaceLight,
                  child: Center(
                    child: SizedBox(
                      width: r.dimension(32),
                      height: r.dimension(32),
                      child: CircularProgressIndicator(
                        value: loadingProgress. expectedTotalBytes != null
                            ?  loadingProgress.cumulativeBytesLoaded / loadingProgress. expectedTotalBytes!
                            : null,
                        color: ReportsDesign.primaryTeal,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Status badge
          Positioned(
            top: r.microPadding,
            left: r.microPadding,
            child: _buildStatusBadge(r, report. status, statusColor),
          ),

          // View button
          Positioned(
            top: r.microPadding,
            right: r.microPadding,
            child: _buildGlassButton(
              r,
              icon: Icons.fullscreen_rounded,
              onTap: () => _showFullScreenImage(report. imageUrl!),
            ),
          ),

          // Navigation button
          if (hasLocation)
            Positioned(
              bottom: r.microPadding,
              left: r.microPadding,
              child: _buildGlassButton(
                r,
                icon: Icons.navigation_rounded,
                label: r.showShortLabels ? 'Navigate' : null,
                color: ReportsDesign.info,
                onTap: () => _openNavigation(report. latitude!, report.longitude!),
              ),
            ),

          // AI badge
          Positioned(
            bottom: r.microPadding,
            right: r.microPadding,
            child: _buildAIBadge(r),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EmployeeResponsiveData r, String status, Color color) {
    return Container(
      padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.9)]),
        borderRadius: BorderRadius. circular(r.pillBorderRadius),
        boxShadow: ReportsDesign.glowShadow(color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), color: Colors.white, size: r.iconSize(12)),
          SizedBox(width: r.nanoPadding),
          Text(
            r.adaptiveText(
              _getStatusText(status),
              nano: _getStatusText(status)[0],
              micro: _getStatusText(status). substring(0, math.min(4, _getStatusText(status).length)),
            ),
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight. w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton(
      EmployeeResponsiveData r, {
        required IconData icon,
        String? label,
        Color? color,
        required VoidCallback onTap,
      }) {
    final bgColor = color ?? Colors.black;

    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
            padding: EdgeInsets. symmetric(
              horizontal: label != null ? r. microPadding : r.nanoPadding,
              vertical: r. nanoPadding,
            ),
            decoration: BoxDecoration(
              color: bgColor. withOpacity(0.65),
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
              border: Border.all(color: Colors.white. withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                Icon(icon, color: Colors.white, size: r.iconSize(14)),
            if (label != null) ...[
        SizedBox(width: r.nanoPadding),
    Text(
    label,
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    ),
    ),
    ],
    ],
    ),
    ),
    );
  }

  Widget _buildAIBadge(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: r.microPadding, vertical: r.nanoPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [ReportsDesign.purple, ReportsDesign.purple.withOpacity(0.85)]),
            borderRadius: BorderRadius. circular(r.pillBorderRadius),
            boxShadow: ReportsDesign.glowShadow(ReportsDesign.purple),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Colors.white, size: r.iconSize(12)),
                  SizedBox(width: r.nanoPadding),
                  Text(
                    r.adaptiveText('AI Verified', nano: 'AI', micro: 'AI', mini: 'AI'),
                    style: GoogleFonts. inter(
                      fontSize: r.captionXS,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Positioned. fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: ReportsDesign.shimmerGradient(_shimmerAnimation. value),
                    borderRadius: BorderRadius. circular(r.pillBorderRadius),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardHeader(EmployeeResponsiveData r, Report report, Color statusColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [statusColor. withOpacity(0.15), statusColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(r.borderRadius),
          ),
          child: Icon(_getWasteIcon(report.type), color: statusColor, size: r. iconSize(22)),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.type,
                style: GoogleFonts.inter(
                  fontSize: r.bodyM,
                  fontWeight: FontWeight. w700,
                  color: ReportsDesign.textPrimary,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Task #${report.id}',
                style: GoogleFonts. inter(fontSize: r.captionS, color: ReportsDesign.textTertiary),
              ),
            ],
          ),
        ),
        _buildTimeBadge(r, report),
      ],
    );
  }

  Widget _buildTimeBadge(EmployeeResponsiveData r, Report report) {
    final timeAgo = _formatTimeAgo(report. date);
    final isRecent = DateTime.now().difference(report.date). inHours < 2;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.microPadding, vertical: r.nanoPadding),
      decoration: BoxDecoration(
        color: isRecent ? ReportsDesign.primaryTeal. withOpacity(0.1) : ReportsDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r. smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: r.iconSize(12),
            color: isRecent ? ReportsDesign.primaryTeal : ReportsDesign.textTertiary,
          ),
          SizedBox(width: r.atomicPadding),
          Text(
            timeAgo,
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight. w600,
              color: isRecent ? ReportsDesign.primaryTeal : ReportsDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails(EmployeeResponsiveData r, Report report, bool hasLocation) {
    return Column(
        children: [
        _buildDetailRow(r, Icons.location_on_rounded, report. location, ReportsDesign.error),
    SizedBox(height: r.nanoPadding),
    _buildDetailRow(r, Icons. person_rounded, 'Reported by ${report.userName}', ReportsDesign.info),
    if (report.description != null && report.description!. isNotEmpty) ...[
    SizedBox(height: r.nanoPadding),
    _buildDetailRow(r, Icons.notes_rounded, report. description!, ReportsDesign.textSecondary),
    ],
    // Show navigation row if has location
    if (hasLocation) ...[
    SizedBox(height: r. microPadding),
    _buildNavigationRow(r, report. latitude!, report.longitude!),
    ],
    ],
    );
  }

  Widget _buildDetailRow(EmployeeResponsiveData r, IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: r.iconSize(14), color: iconColor. withOpacity(0.7)),
        SizedBox(width: r.microPadding),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: r.captionM,
              color: ReportsDesign.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationRow(EmployeeResponsiveData r, double lat, double lng) {
    return GestureDetector(
      onTap: () => _openNavigation(lat, lng),
      child: Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          color: ReportsDesign.info. withOpacity(0.08),
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: Border.all(color: ReportsDesign.info.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.nanoPadding),
              decoration: BoxDecoration(
                color: ReportsDesign.info,
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
              ),
              child: Icon(Icons. navigation_rounded, size: r.iconSize(14), color: Colors.white),
            ),
            SizedBox(width: r.microPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigate to Location',
                    style: GoogleFonts.inter(
                      fontSize: r. captionM,
                      fontWeight: FontWeight.w600,
                      color: ReportsDesign.info,
                    ),
                  ),
                  Text(
                    'Tap to open directions',
                    style: GoogleFonts.inter(
                      fontSize: r. captionXS,
                      color: ReportsDesign.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: ReportsDesign.info, size: r.iconSize(20)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardActions(EmployeeResponsiveData r, Report report, bool hasLocation) {
    if (report.status == 'resolved') {
      return _buildCompletedSection(r, report);
    }
    if (report.status == 'in-progress') {
      return _buildInProgressActions(r, report, hasLocation);
    }
    return _buildPendingActions(r, report);
  }

  Widget _buildCompletedSection(EmployeeResponsiveData r, Report report) {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ReportsDesign.successLight, ReportsDesign.successLight.withOpacity(0.5)],
        ),
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: const BoxDecoration(color: ReportsDesign.success, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, color: Colors.white, size: r.iconSize(14)),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment. start,
              children: [
                Text(
                  'Task Completed',
                  style: GoogleFonts. inter(
                    fontSize: r.captionL,
                    fontWeight: FontWeight. w700,
                    color: ReportsDesign.success,
                  ),
                ),
                if (report.resolvedAt != null && r.showSecondaryText)
                  Text(
                    'Completed ${_formatDate(report.resolvedAt!)}',
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      color: ReportsDesign.success. withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showReportDetails(report),
            style: TextButton.styleFrom(
              foregroundColor: ReportsDesign.success,
              padding: EdgeInsets. symmetric(horizontal: r. microPadding),
              minimumSize: Size. zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('View', style: GoogleFonts.inter(fontSize: r.captionM, fontWeight: FontWeight. w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressActions(EmployeeResponsiveData r, Report report, bool hasLocation) {
    return Row(
      children: [
        if (hasLocation)
          Expanded(
            child: _buildActionButton(
              r,
              icon: Icons.navigation_rounded,
              label: r.adaptiveText('Navigate', nano: '→', micro: 'Nav', mini: 'Navigate'),
              color: ReportsDesign. info,
              isOutlined: true,
              onTap: () => _openNavigation(report.latitude!, report.longitude!),
            ),
          ),
        if (hasLocation) SizedBox(width: r.microPadding),
        Expanded(
          flex: hasLocation ? 1 : 2,
          child: _buildActionButton(
            r,
            icon: Icons. camera_alt_rounded,
            label: r.adaptiveText('Complete', nano: '✓', micro: 'Done', mini: 'Complete'),
            color: ReportsDesign.primaryTeal,
            onTap: () => _showResolveSheet(report),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActions(EmployeeResponsiveData r, Report report) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            r,
            icon: Icons.play_arrow_rounded,
            label: r.adaptiveText('Start', nano: '▶', micro: 'Start', mini: 'Start'),
            color: ReportsDesign.info,
            onTap: () {
              HapticFeedback.mediumImpact();
              widget. onUpdateStatus(report.id, 'in-progress');
            },
          ),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: _buildActionButton(
            r,
            icon: Icons.check_circle_rounded,
            label: r.adaptiveText('Resolve', nano: '✓', micro: 'Done', mini: 'Resolve'),
            color: ReportsDesign.primaryTeal,
            onTap: () => _showResolveSheet(report),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
        bool isOutlined = false,
      }) {
    return Material(
      color: isOutlined ? Colors. transparent : color,
      borderRadius: BorderRadius. circular(r.borderRadius),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius. circular(r.borderRadius),
        child: Container(
          height: r.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius. circular(r.borderRadius),
            border: isOutlined ? Border. all(color: color, width: 1.5) : null,
            boxShadow: isOutlined ?  null : ReportsDesign.glowShadow(color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              Icon(icon, size: r.iconSize(18), color: isOutlined ? color : Colors.white),
              if (r.showIconLabels) ...[
                SizedBox(width: r.nanoPadding),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight.w600,
                      color: isOutlined ? color : Colors.white,
                    ),
                    overflow: TextOverflow. ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==================== NAVIGATION FUNCTION ====================
  Future<void> _openNavigation(double lat, double lng) async {
    HapticFeedback.mediumImpact();

    // Try Google Maps first
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/? api=1&destination=$lat,$lng&travelmode=driving',
    );

    try {
      final canLaunchGoogle = await canLaunchUrl(googleMapsUrl);
      if (canLaunchGoogle) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (e) {
      debugPrint('Google Maps launch error: $e');
    }

    // Try Apple Maps for iOS
    final appleMapsUrl = Uri.parse('https://maps.apple.com/? daddr=$lat,$lng&dirflg=d');

    try {
      final canLaunchApple = await canLaunchUrl(appleMapsUrl);
      if (canLaunchApple) {
        await launchUrl(appleMapsUrl, mode: LaunchMode. externalApplication);
        return;
      }
    } catch (e) {
      debugPrint('Apple Maps launch error: $e');
    }

    // Fallback - show location on map
    final fallbackUrl = Uri. parse('https://www.google.com/maps/search/? api=1&query=$lat,$lng');

    try {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Could not open maps application', isSuccess: false);
      }
    }
  }

  // ==================== DIALOGS & SHEETS ====================
  void _showReportDetails(Report report) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _ReportDetailsPage(
          report: report,
          responsive: widget.responsive,
          onUpdateStatus: widget.onUpdateStatus,
          onShowResolveDialog: () {
            Navigator.pop(context);
            _showResolveSheet(report);
          },
          onNavigate: (lat, lng) => _openNavigation(lat, lng),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _FullScreenImagePage(
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
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ResolveSheet(
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
      builder: (dialogContext) => _AIVerificationDialog(
        report: report,
        responsive: widget.responsive,
        afterImagePath: imagePath,
        latitude: lat,
        longitude: lng,
        address: address,
        timestamp: timestamp,
        onSuccess: () {
          Navigator. pop(dialogContext);
          widget.onUpdateStatus(
            report.id,
            'resolved',
            imagePath: imagePath,
            latitude: lat,
            longitude: lng,
            locationAddress: address,
          );
          _showSuccessAnimation();
        },
        onRetry: () {
          Navigator.pop(dialogContext);
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
      builder: (dialogContext) => _SuccessAnimationDialog(
        responsive: widget.responsive,
        onComplete: () {
          Navigator.pop(dialogContext);
          widget.onRefresh();
        },
      ),
    );
  }

  // ==================== STATES ====================
  Widget _buildLoadingState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(angle: value * 2 * math.pi, child: child);
            },
            child: Container(
              width: r.avatarSize,
              height: r.avatarSize,
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    ReportsDesign.primaryTeal,
                    ReportsDesign.primaryTeal.withOpacity(0.1),
                    ReportsDesign. primaryTeal,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: r.avatarSize - 10,
                  height: r.avatarSize - 10,
                  decoration: const BoxDecoration(
                    color: ReportsDesign.surfacePure,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.assignment_rounded, size: r. iconSize(24), color: ReportsDesign.primaryTeal),
                ),
              ),
            ),
          ),
          SizedBox(height: r.padding),
          Text('Loading tasks...', style: GoogleFonts.inter(fontSize: r. bodyS, color: ReportsDesign.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorState(EmployeeResponsiveData r, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            Container(
              padding: EdgeInsets. all(r.largePadding),
              decoration: BoxDecoration(color: ReportsDesign.errorLight, shape: BoxShape.circle),
              child: Icon(Icons.error_outline_rounded, size: r. iconSize(48), color: ReportsDesign.error),
            ),
            SizedBox(height: r.padding),
            Text(
              'Failed to load tasks',
              style: GoogleFonts.inter(fontSize: r.bodyM, fontWeight: FontWeight.w700, color: ReportsDesign.textPrimary),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              'Please check your connection',
              style: GoogleFonts.inter(fontSize: r. captionM, color: ReportsDesign.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.padding),
            ElevatedButton. icon(
              onPressed: _handleRefresh,
              icon: Icon(Icons.refresh_rounded, size: r.iconSize(18)),
              label: Text('Try Again', style: GoogleFonts.inter(fontWeight: FontWeight. w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: ReportsDesign.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets. symmetric(horizontal: r.largePadding, vertical: r.microPadding),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.borderRadius)),
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
                return Transform. scale(scale: value, child: child);
              },
              child: Container(
                padding: EdgeInsets. all(r.largePadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ReportsDesign.primaryTeal. withOpacity(0.15), ReportsDesign.primaryTeal. withOpacity(0.05)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.task_alt_rounded, size: r.iconSize(56), color: ReportsDesign.primaryTeal),
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'All caught up!',
              style: GoogleFonts.inter(fontSize: r.headingXS, fontWeight: FontWeight. w700, color: ReportsDesign.textPrimary),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              'No tasks assigned yet.\nNew tasks will appear here.',
              style: GoogleFonts.inter(fontSize: r. bodyS, color: ReportsDesign.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
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
            decoration: BoxDecoration(color: ReportsDesign.surfaceLight, shape: BoxShape.circle),
            child: Icon(Icons.search_off_rounded, size: r.iconSize(48), color: ReportsDesign.textTertiary),
          ),
          SizedBox(height: r.padding),
          Text(
            'No matching tasks',
            style: GoogleFonts.inter(fontSize: r. bodyM, fontWeight: FontWeight.w600, color: ReportsDesign.textPrimary),
          ),
          SizedBox(height: r.nanoPadding),
          Text(
            'Try adjusting your search or filters',
            style: GoogleFonts.inter(fontSize: r.captionM, color: ReportsDesign.textSecondary),
          ),
          SizedBox(height: r.padding),
          TextButton. icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedFilter = 'all';
              });
            },
            icon: Icon(Icons.clear_all_rounded, size: r. iconSize(18)),
            label: Text('Clear filters', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: TextButton. styleFrom(foregroundColor: ReportsDesign.primaryTeal),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================
  Color _getStatusColor(String status) {
    switch (status. toLowerCase()) {
      case 'resolved': return ReportsDesign.success;
      case 'in-progress': return ReportsDesign.info;
      case 'pending': return ReportsDesign.warning;
      default: return ReportsDesign.textTertiary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return 'Completed';
      case 'in-progress': return 'In Progress';
      case 'pending': return 'Pending';
      default: return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return Icons.check_circle_rounded;
      case 'in-progress': return Icons. sync_rounded;
      case 'pending': return Icons.schedule_rounded;
      default: return Icons. help_rounded;
    }
  }

  IconData _getWasteIcon(String type) {
    final t = type.toLowerCase();
    if (t. contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('hazardous')) return Icons.warning_amber_rounded;
    if (t.contains('glass')) return Icons.wine_bar_rounded;
    if (t.contains('paper')) return Icons.description_rounded;
    if (t.contains('metal')) return Icons.recycling_rounded;
    if (t. contains('medical')) return Icons.medical_services_rounded;
    if (t.contains('construction')) return Icons.construction_rounded;
    return Icons.delete_rounded;
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now(). difference(date);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff. inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSnackBar(String msg, {bool isSuccess = true}) {
    if (! mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: isSuccess ? ReportsDesign.primaryTeal : ReportsDesign.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 8,
      ),
    );
  }
}

// ==================== FILTER OPTION MODEL ====================
class _FilterOption {
  final String value;
  final String label;
  final String shortLabel;
  final String nano;
  final Color color;
  final IconData icon;

  _FilterOption(this.value, this.label, this. shortLabel, this. nano, this.color, this.icon);
}// ==================== REPORT DETAILS PAGE ====================
class _ReportDetailsPage extends StatefulWidget {
  final Report report;
  final EmployeeResponsiveData responsive;
  final Function(int, String, {String?  imagePath, double? latitude, double?  longitude, String? locationAddress}) onUpdateStatus;
  final VoidCallback onShowResolveDialog;
  final Function(double lat, double lng) onNavigate;

  const _ReportDetailsPage({
    required this.report,
    required this.responsive,
    required this. onUpdateStatus,
    required this.onShowResolveDialog,
    required this.onNavigate,
  });

  @override
  State<_ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<_ReportDetailsPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves. easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController. dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final report = widget.report;
    final statusColor = _getStatusColor(report.status);
    final hasLocation = report.latitude != null && report.longitude != null &&
        report.latitude != 0.0 && report. longitude != 0.0;

    return Scaffold(
    backgroundColor: ReportsDesign.surfaceLight,
    body: CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
    // App Bar with Image
    SliverAppBar(
    expandedHeight: r.dimension(300),
    pinned: true,
    stretch: true,
    backgroundColor: ReportsDesign.surfacePure,
    elevation: 0,
    leading: Padding(
    padding: EdgeInsets.all(r.microPadding),
    child: GestureDetector(
    onTap: () => Navigator. pop(context),
    child: Container(
    decoration: BoxDecoration(
    color: Colors.black. withOpacity(0.4),
    shape: BoxShape.circle,
    ),
    child: Icon(
    Icons.arrow_back_ios_new_rounded,
    color: Colors.white,
    size: r.iconSize(18),
    ),
    ),
    ),
    ),
    actions: [
    // Navigation button in app bar if has location
    if (hasLocation)
    Padding(
    padding: EdgeInsets.all(r.microPadding),
    child: GestureDetector(
    onTap: () {
    HapticFeedback.mediumImpact();
    widget.onNavigate(report.latitude!, report.longitude!);
    },
    child: Container(
    padding: EdgeInsets. all(r.microPadding),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [ReportsDesign.info, ReportsDesign.info. withOpacity(0.9)],
    ),
    shape: BoxShape.circle,
    boxShadow: ReportsDesign.glowShadow(ReportsDesign.info),
    ),
    child: Icon(
    Icons.navigation_rounded,
    color: Colors.white,
    size: r.iconSize(18),
    ),
    ),
    ),
    ),
    ],
    flexibleSpace: FlexibleSpaceBar(
    stretchModes: const [StretchMode.zoomBackground, StretchMode. fadeTitle],
    background: Stack(
    fit: StackFit.expand,
    children: [
    // Image
    if (report.imageUrl != null && report.imageUrl! .isNotEmpty)
    Image. network(
    report.imageUrl!,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
    decoration: BoxDecoration(gradient: ReportsDesign.primaryGradient),
    child: Icon(
    Icons. broken_image_rounded,
    size: r.dimension(60),
    color: Colors.white. withOpacity(0.5),
    ),
    ),
    )
    else
    Container(
    decoration: BoxDecoration(gradient: ReportsDesign.primaryGradient),
    child: Icon(
    Icons.image_not_supported_rounded,
    size: r.dimension(60),
    color: Colors.white. withOpacity(0.5),
    ),
    ),

    // Gradient overlay
    Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [
    Colors.transparent,
    Colors.transparent,
    Colors.black.withOpacity(0.6),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: const [0.0, 0.5, 1.0],
    ),
    ),
    ),

    // Status badge
    Positioned(
    bottom: r.padding,
    left: r.padding,
    child: Container(
    padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
    decoration: BoxDecoration(
    gradient: LinearGradient(colors: [statusColor, statusColor.withOpacity(0.9)]),
    borderRadius: BorderRadius. circular(r.pillBorderRadius),
    boxShadow: ReportsDesign.glowShadow(statusColor),
    ),
    child: Row(
    mainAxisSize: MainAxisSize. min,
    children: [
    Icon(_getStatusIcon(report.status), color: Colors.white, size: r.iconSize(14)),
    SizedBox(width: r.nanoPadding),
    Text(
    _getStatusText(report.status),
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    fontWeight: FontWeight. w700,
    color: Colors.white,
    ),
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    ),
    ),

    // Content
    SliverToBoxAdapter(
    child: FadeTransition(
    opacity: _fadeAnimation,
    child: Padding(
    padding: EdgeInsets. all(r.padding),
    child: Column(
    children: [
    // Header card
    _buildHeaderCard(r, statusColor),
    SizedBox(height: r.padding),

    // AI Classification
    _buildAIClassificationCard(r),
    SizedBox(height: r.padding),

    // Details card
    _buildDetailsCard(r),
    SizedBox(height: r.padding),

    // Navigation Card (instead of coordinate copy)
    if (hasLocation)
    _buildNavigationCard(r),
    if (hasLocation)
    SizedBox(height: r.padding),

    // Timeline card
    _buildTimelineCard(r),
    SizedBox(height: r.padding),

    // Action buttons
    if (report.status != 'resolved')
    _buildActionButtons(r, hasLocation),

    SizedBox(height: r.dimension(100)),
    ],
    ),
    ),
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildHeaderCard(EmployeeResponsiveData r, Color statusColor) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
        boxShadow: ReportsDesign. softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor. withOpacity(0.2), statusColor.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              _getWasteIcon(widget.report.type),
              color: statusColor,
              size: r.iconSize(32),
            ),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.report.type,
                  style: GoogleFonts.inter(
                    fontSize: r. headingXS,
                    fontWeight: FontWeight. w700,
                    color: ReportsDesign.textPrimary,
                  ),
                ),
                Text(
                  'Task #${widget.report. id}',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    color: ReportsDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIClassificationCard(EmployeeResponsiveData r) {
    final categories = [
      {'name': 'Plastic', 'percentage': 65, 'color': ReportsDesign.info},
      {'name': 'Paper', 'percentage': 20, 'color': ReportsDesign. warning},
      {'name': 'Organic', 'percentage': 10, 'color': ReportsDesign. success},
      {'name': 'Other', 'percentage': 5, 'color': ReportsDesign.textTertiary},
    ];

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
        boxShadow: ReportsDesign.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: ReportsDesign.purpleLight,
                  borderRadius: BorderRadius. circular(r.smallBorderRadius),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: ReportsDesign.purple, size: r. iconSize(18)),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'AI Classification',
                style: GoogleFonts.inter(
                  fontSize: r. bodyS,
                  fontWeight: FontWeight. w700,
                  color: ReportsDesign.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
                decoration: BoxDecoration(
                  color: ReportsDesign.success. withOpacity(0.1),
                  borderRadius: BorderRadius. circular(r.pillBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, size: r.iconSize(12), color: ReportsDesign.success),
                    SizedBox(width: r.atomicPadding),
                    Text(
                      '94% confidence',
                      style: GoogleFonts.inter(
                        fontSize: r. captionXS,
                        fontWeight: FontWeight.w700,
                        color: ReportsDesign.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: r. padding),
          ... categories.map((cat) => _buildCategoryBar(r, cat)),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(EmployeeResponsiveData r, Map<String, dynamic> cat) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: (cat['percentage'] as int) / 100.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Padding(
          padding: EdgeInsets. only(bottom: r.microPadding),
          child: Row(
            children: [
              Container(
                width: r.dimension(10),
                height: r.dimension(10),
                decoration: BoxDecoration(
                  color: cat['color'] as Color,
                  borderRadius: BorderRadius.circular(r. tinyBorderRadius),
                ),
              ),
              SizedBox(width: r. microPadding),
              Expanded(
                child: Text(
                  cat['name'] as String,
                  style: GoogleFonts.inter(fontSize: r.captionM, color: ReportsDesign.textSecondary),
                ),
              ),
              SizedBox(
                width: r. dimension(100),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: (cat['color'] as Color).withOpacity(0.15),
                    color: cat['color'] as Color,
                    minHeight: r.dimension(6),
                  ),
                ),
              ),
              SizedBox(width: r.microPadding),
              SizedBox(
                width: r.dimension(35),
                child: Text(
                  '${cat['percentage']}%',
                  style: GoogleFonts.inter(
                    fontSize: r. captionS,
                    fontWeight: FontWeight.w600,
                    color: ReportsDesign.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsCard(EmployeeResponsiveData r) {
    return Container(
        padding: EdgeInsets.all(r. padding),
        decoration: BoxDecoration(
          color: ReportsDesign.surfacePure,
          borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
          boxShadow: ReportsDesign. softShadow,
        ),
        child: Column(
            children: [
            _buildDetailItem(r, Icons.location_on_rounded, 'Location', widget.report.location, ReportsDesign.error),
        Divider(height: r.padding * 2, color: ReportsDesign.surfaceLight),
        _buildDetailItem(r, Icons.person_rounded, 'Reported By', widget.report.userName, ReportsDesign.info),
        if (widget.report. description != null && widget.report.description!.isNotEmpty) ...[
    Divider(height: r.padding * 2, color: ReportsDesign.surfaceLight),
    _buildDetailItem(r, Icons.notes_rounded, 'Description', widget.report.description!, ReportsDesign.textSecondary),
    ],
    ],
    ),
    );
  }

  Widget _buildDetailItem(EmployeeResponsiveData r, IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(r. nanoPadding),
          decoration: BoxDecoration(
            color: color. withOpacity(0.1),
            borderRadius: BorderRadius.circular(r. smallBorderRadius),
          ),
          child: Icon(icon, size: r.iconSize(18), color: color),
        ),
        SizedBox(width: r. padding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts. inter(
                  fontSize: r.captionS,
                  color: ReportsDesign.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: r.atomicPadding),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  color: ReportsDesign.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== NAVIGATION CARD (Replaces Coordinate Copy) ====================
  Widget _buildNavigationCard(EmployeeResponsiveData r) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onNavigate(widget.report.latitude!, widget.report.longitude!);
      },
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ReportsDesign.info. withOpacity(0.1), ReportsDesign.info. withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
          border: Border.all(color: ReportsDesign.info.withOpacity(0.2)),
          boxShadow: ReportsDesign. softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [ReportsDesign.info, ReportsDesign. info.withOpacity(0.85)]),
                borderRadius: BorderRadius. circular(r.borderRadius),
                boxShadow: ReportsDesign.glowShadow(ReportsDesign. info),
              ),
              child: Icon(Icons.navigation_rounded, color: Colors.white, size: r.iconSize(24)),
            ),
            SizedBox(width: r.padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigate to Location',
                    style: GoogleFonts.inter(
                      fontSize: r. bodyS,
                      fontWeight: FontWeight. w700,
                      color: ReportsDesign.info,
                    ),
                  ),
                  SizedBox(height: r. atomicPadding),
                  Text(
                    'Open directions in Maps',
                    style: GoogleFonts.inter(
                      fontSize: r. captionM,
                      color: ReportsDesign.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: ReportsDesign.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Icon(
                Icons.open_in_new_rounded,
                color: ReportsDesign.info,
                size: r.iconSize(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(EmployeeResponsiveData r) {
    final events = [
      _TimelineEvent('Reported', widget.report.date, Icons.flag_rounded, ReportsDesign.warning, true),
      _TimelineEvent('Assigned', widget.report. assignedAt ??  widget.report.date, Icons.assignment_ind_rounded, ReportsDesign.info, true),
      if (widget.report. status == 'in-progress')
        _TimelineEvent('In Progress', DateTime.now(), Icons.sync_rounded, ReportsDesign.info, true),
      if (widget.report. status == 'resolved' && widget.report. resolvedAt != null)
        _TimelineEvent('Completed', widget.report. resolvedAt!, Icons.check_circle_rounded, ReportsDesign.success, true),
      if (widget.report. status != 'resolved')
        _TimelineEvent('Pending Completion', DateTime.now(), Icons. pending_rounded, ReportsDesign.textTertiary, false),
    ];

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign. surfacePure,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: ReportsDesign.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: ReportsDesign. primaryTeal. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(Icons.timeline_rounded, color: ReportsDesign.primaryTeal, size: r. iconSize(18)),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Timeline',
                style: GoogleFonts. inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w700,
                  color: ReportsDesign.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.padding),
          ... events.asMap().entries.map((entry) {
            final isLast = entry. key == events.length - 1;
            return _buildTimelineItem(r, entry.value, isLast, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(EmployeeResponsiveData r, _TimelineEvent event, bool isLast, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: r.dimension(32),
                height: r.dimension(32),
                decoration: BoxDecoration(
                  gradient: event.isCompleted
                      ?  LinearGradient(colors: [event.color, event.color.withOpacity(0.8)])
                      : null,
                  color: event.isCompleted ? null : event.color. withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: event.isCompleted ?  ReportsDesign. glowShadow(event.color) : null,
                ),
                child: Icon(
                  event.icon,
                  size: r.iconSize(16),
                  color: event.isCompleted ? Colors.white : event. color,
                ),
              ),
              if (! isLast)
                Container(
                  width: 2,
                  height: r.dimension(35),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        event.isCompleted ? event.color. withOpacity(0.5) : ReportsDesign.surfaceOverlay,
                        ReportsDesign.surfaceOverlay,
                      ],
                      begin: Alignment. topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Padding(
              padding: EdgeInsets. only(top: r.nanoPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts. inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w600,
                      color: event.isCompleted ?  ReportsDesign. textPrimary : ReportsDesign. textTertiary,
                    ),
                  ),
                  if (event.isCompleted)
                    Text(
                      _formatDateTime(event.date),
                      style: GoogleFonts. inter(
                        fontSize: r.captionS,
                        color: ReportsDesign.textSecondary,
                      ),
                    ),
                  SizedBox(height: r. microPadding),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EmployeeResponsiveData r, bool hasLocation) {
    if (widget.report.status == 'in-progress') {
      return Column(
        children: [
          // Navigate button
          if (hasLocation)
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onNavigate(widget.report. latitude!, widget.report.longitude!);
              },
              child: Container(
                width: double.infinity,
                height: r.buttonHeight + 8,
                margin: EdgeInsets. only(bottom: r.microPadding),
                decoration: BoxDecoration(
                  border: Border.all(color: ReportsDesign.info, width: 2),
                  borderRadius: BorderRadius.circular(r.largeBorderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment. center,
                  children: [
                    Icon(Icons. navigation_rounded, color: ReportsDesign.info, size: r.iconSize(22)),
                    SizedBox(width: r.microPadding),
                    Text(
                      'Navigate to Location',
                      style: GoogleFonts.inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight.w700,
                        color: ReportsDesign.info,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Complete button
          Container(
            width: double.infinity,
            height: r. buttonHeight + 12,
            decoration: BoxDecoration(
              gradient: ReportsDesign.primaryGradient,
              borderRadius: BorderRadius.circular(r. largeBorderRadius),
              boxShadow: ReportsDesign.glowShadow(ReportsDesign. primaryTeal),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onShowResolveDialog,
                borderRadius: BorderRadius. circular(r.largeBorderRadius),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, color: Colors.white, size: r.iconSize(22)),
                    SizedBox(width: r.microPadding),
                    Text(
                      'Mark as Completed',
                      style: GoogleFonts.inter(
                        fontSize: r. bodyS,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Pending status
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: r. buttonHeight + 8,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [ReportsDesign.info, ReportsDesign.info.withOpacity(0.9)]),
            borderRadius: BorderRadius. circular(r.largeBorderRadius),
            boxShadow: ReportsDesign. glowShadow(ReportsDesign.info),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback. mediumImpact();
                Navigator.pop(context);
                widget.onUpdateStatus(widget.report.id, 'in-progress');
              },
              borderRadius: BorderRadius.circular(r.largeBorderRadius),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: r.iconSize(22)),
                  SizedBox(width: r.microPadding),
                  Text(
                    'Start Processing',
                    style: GoogleFonts.inter(
                      fontSize: r. bodyS,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: r.microPadding),
        Container(
          width: double.infinity,
          height: r.buttonHeight + 8,
          decoration: BoxDecoration(
            gradient: ReportsDesign.primaryGradient,
            borderRadius: BorderRadius.circular(r.largeBorderRadius),
            boxShadow: ReportsDesign.glowShadow(ReportsDesign.primaryTeal),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onShowResolveDialog,
              borderRadius: BorderRadius.circular(r. largeBorderRadius),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons. check_circle_rounded, color: Colors. white, size: r.iconSize(22)),
                  SizedBox(width: r.microPadding),
                  Text(
                    'Quick Resolve',
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour. toString().padLeft(2, '0')}:${dt. minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status. toLowerCase()) {
      case 'resolved': return ReportsDesign.success;
      case 'in-progress': return ReportsDesign.info;
      case 'pending': return ReportsDesign.warning;
      default: return ReportsDesign.textTertiary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return 'Completed';
      case 'in-progress': return 'In Progress';
      case 'pending': return 'Pending';
      default: return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return Icons. check_circle_rounded;
      case 'in-progress': return Icons.sync_rounded;
      case 'pending': return Icons.schedule_rounded;
      default: return Icons. help_rounded;
    }
  }

  IconData _getWasteIcon(String type) {
    final t = type.toLowerCase();
    if (t. contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('hazardous')) return Icons.warning_amber_rounded;
    return Icons.delete_rounded;
  }
}

class _TimelineEvent {
  final String title;
  final DateTime date;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  _TimelineEvent(this.title, this.date, this. icon, this.color, this.isCompleted);
}

// ==================== FULL SCREEN IMAGE PAGE ====================
class _FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final EmployeeResponsiveData responsive;

  const _FullScreenImagePage({
    required this.imageUrl,
    required this. responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors. transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets. all(r.microPadding),
            decoration: BoxDecoration(
              color: Colors.black. withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close_rounded, color: Colors. white, size: r.iconSize(22)),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress. expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: ReportsDesign.primaryTeal,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_rounded, size: 80, color: Colors.white. withOpacity(0.5)),
                    SizedBox(height: r.padding),
                    Text(
                      'Failed to load image',
                      style: GoogleFonts.inter(color: Colors.white. withOpacity(0.7)),
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
}

// ==================== RESOLVE SHEET ====================
class _ResolveSheet extends StatefulWidget {
  final Report report;
  final EmployeeResponsiveData responsive;
  final ImagePicker imagePicker;
  final Function(String imagePath, double lat, double lng, String address, DateTime timestamp) onResolve;

  const _ResolveSheet({
    required this.report,
    required this.responsive,
    required this. imagePicker,
    required this.onResolve,
  });

  @override
  State<_ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends State<_ResolveSheet> with SingleTickerProviderStateMixin {
  File? _capturedImage;
  Position? _position;
  String? _address;
  bool _isLoadingLocation = false;
  bool _useManualLocation = false;
  String? _locationError;
  DateTime? _captureTime;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(parent: _animController, curve: Curves. easeOutCubic);
    _animController. forward();
    _captureLocation();
  }

  @override
  void dispose() {
    _animController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController. dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please enable GPS/Location services');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      String addr = 'Location captured';
      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos. longitude);
        if (placemarks. isNotEmpty) {
          final p = placemarks. first;
          addr = [p.street, p.subLocality, p.locality, p.administrativeArea]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _position = pos;
          _address = addr;
          _latController.text = pos.latitude.toStringAsFixed(6);
          _lngController.text = pos.longitude.toStringAsFixed(6);
          _addressController.text = addr;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString(). replaceAll('Exception: ', '');
          _isLoadingLocation = false;
          _useManualLocation = true;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticFeedback.lightImpact();
      final XFile?  img = await widget.imagePicker. pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (img != null && mounted) {
        setState(() {
          _capturedImage = File(img.path);
          _captureTime = DateTime.now();
        });

        if (_position == null && ! _useManualLocation) {
          _captureLocation();
        }
      }
    } catch (e) {
      _showError('Failed to capture image');
    }
  }

  void _showImageSourcePicker() {
    final r = widget.responsive;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: ReportsDesign.surfacePure,
          borderRadius: BorderRadius.vertical(top: Radius.circular(r.extraLargeBorderRadius)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: r.dimension(40),
                height: r.dimension(4),
                margin: EdgeInsets. only(bottom: r.padding),
                decoration: BoxDecoration(
                  color: ReportsDesign.textLight,
                  borderRadius: BorderRadius. circular(r.pillBorderRadius),
                ),
              ),
              Text(
                'Capture Cleanup Image',
                style: GoogleFonts. inter(
                  fontSize: r.headingXS,
                  fontWeight: FontWeight. w700,
                  color: ReportsDesign.textPrimary,
                ),
              ),
              SizedBox(height: r.padding),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceButton(
                      r,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: ReportsDesign.primaryTeal,
                      onTap: () {
                        Navigator. pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  SizedBox(width: r.padding),
                  Expanded(
                    child: _buildSourceButton(
                      r,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: ReportsDesign.info,
                      onTap: () {
                        Navigator. pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.padding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton(
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets. symmetric(vertical: r.padding),
        decoration: BoxDecoration(
          color: color. withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(color: color. withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets. all(r.microPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
                shape: BoxShape.circle,
                boxShadow: ReportsDesign.glowShadow(color),
              ),
              child: Icon(icon, size: r. iconSize(28), color: Colors.white),
            ),
            SizedBox(height: r.microPadding),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_capturedImage == null) {
      _showError('Please capture an after-cleanup image');
      return;
    }

    double?  lat;
    double? lng;
    String addr;

    if (_useManualLocation) {
      lat = double.tryParse(_latController.text. trim());
      lng = double.tryParse(_lngController. text.trim());

      if (lat == null || lng == null) {
        _showError('Please enter valid coordinates');
        return;
      }

      if (lat. abs() > 90 || lng.abs() > 180) {
        _showError('Invalid coordinate values');
        return;
      }

      addr = _addressController.text.trim(). isNotEmpty
          ? _addressController.text.trim()
          : 'Location: ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    } else {
      if (_position == null) {
        _showError('GPS location not captured.  Please try again or use manual entry.');
        return;
      }
      lat = _position!. latitude;
      lng = _position!. longitude;
      addr = _address ??  'Unknown location';
    }

    HapticFeedback.mediumImpact();
    widget.onResolve(
      _capturedImage!. path,
      lat,
      lng,
      addr,
      _captureTime ??  DateTime.now(),
    );
  }

  void _showError(String msg) {
    if (! mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors. white, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: GoogleFonts.inter(fontSize: 13))),
          ],
        ),
        backgroundColor: ReportsDesign.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  bool _canSubmit() {
    if (_capturedImage == null) return false;

    if (_useManualLocation) {
      final lat = double.tryParse(_latController. text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      return lat != null && lng != null;
    } else {
      return _position != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size. height;

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero). animate(_slideAnimation),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.9),
        decoration: BoxDecoration(
          color: ReportsDesign.surfacePure,
          borderRadius: BorderRadius.vertical(top: Radius.circular(r. extraLargeBorderRadius)),
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
                color: ReportsDesign.textLight,
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
            ),

            // Header
            _buildSheetHeader(r),

            Divider(height: r.padding * 2, color: ReportsDesign.surfaceLight),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets. symmetric(horizontal: r. padding),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment. start,
                  children: [
                    _buildImageComparison(r),
                    SizedBox(height: r. padding),
                    _buildLocationSection(r),
                    SizedBox(height: r. padding),
                    if (_captureTime != null) _buildTimestampSection(r),
                    SizedBox(height: r.padding),
                    _buildAIInfoBanner(r),
                    SizedBox(height: r.padding),
                  ],
                ),
              ),
            ),

            // Submit button
            _buildSubmitButton(r, bottomPad),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets. symmetric(horizontal: r. padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets. all(r.microPadding),
            decoration: BoxDecoration(
              gradient: ReportsDesign.successGradient,
              borderRadius: BorderRadius.circular(r.borderRadius),
              boxShadow: ReportsDesign.glowShadow(ReportsDesign. success),
            ),
            child: Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: r.iconSize(24)),
          ),
          SizedBox(width: r. padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Task',
                  style: GoogleFonts.inter(
                    fontSize: r. headingXS,
                    fontWeight: FontWeight.w700,
                    color: ReportsDesign.textPrimary,
                  ),
                ),
                Text(
                  widget.report.type,
                  style: GoogleFonts. inter(fontSize: r.captionM, color: ReportsDesign.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow. ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets. all(r.nanoPadding),
              decoration: BoxDecoration(
                color: ReportsDesign.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, color: ReportsDesign.textSecondary, size: r.iconSize(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageComparison(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.compare_rounded, size: r.iconSize(18), color: ReportsDesign.textSecondary),
            SizedBox(width: r.microPadding),
            Text(
              'Before & After Comparison',
              style: GoogleFonts. inter(fontSize: r.bodyS, fontWeight: FontWeight.w600, color: ReportsDesign.textPrimary),
            ),
          ],
        ),
        SizedBox(height: r.microPadding),
        Row(
          children: [
            Expanded(child: _buildImageCard(r, 'Before', widget.report.imageUrl, null, false)),
            SizedBox(width: r.microPadding),
            Expanded(child: _buildImageCard(r, 'After', null, _capturedImage, true)),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard(EmployeeResponsiveData r, String label, String?  url, File? file, bool isAfter) {
    final hasImage = url != null || file != null;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    Row(
    children: [
    Container(
    width: r.dimension(10),
    height: r.dimension(10),
    decoration: BoxDecoration(
    gradient: isAfter ? ReportsDesign.successGradient : LinearGradient(colors: [ReportsDesign.warning, ReportsDesign.warning.withOpacity(0.8)]),
    shape: BoxShape.circle,
    ),
    ),
    SizedBox(width: r.nanoPadding),
    Text(label, style: GoogleFonts.inter(fontSize: r.captionM, fontWeight: FontWeight. w600, color: ReportsDesign. textSecondary)),
    ],
    ),
    SizedBox(height: r.microPadding),
    GestureDetector(
    onTap: isAfter ? _showImageSourcePicker : null,
    child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    height: r.dimension(140),
    decoration: BoxDecoration(
    color: ReportsDesign.surfaceLight,
    borderRadius: BorderRadius. circular(r.largeBorderRadius),
    border: Border.all(
    color: isAfter ? (hasImage ? ReportsDesign.success : ReportsDesign.primaryTeal) : ReportsDesign.surfaceOverlay,
    width: isAfter && ! hasImage ? 2 : 1,
    ),
    image: hasImage
    ? DecorationImage(image: file != null ? FileImage(file) : NetworkImage(url!) as ImageProvider, fit: BoxFit.cover)
        : null,
    ),
    child: ! hasImage
    ? Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment. center,
    children: [
    Container(
    padding: EdgeInsets. all(r.microPadding),
    decoration: BoxDecoration(
    color: isAfter ? ReportsDesign.primaryTeal. withOpacity(0.1) : ReportsDesign.surfaceOverlay,
    shape: BoxShape.circle,
    ),
    child: Icon(
    isAfter ? Icons.add_a_photo_rounded : Icons.image_not_supported_rounded,
    size: r.iconSize(24),
    color: isAfter ? ReportsDesign.primaryTeal : ReportsDesign. textTertiary,
    ),
    ),
    SizedBox(height: r.nanoPadding),
    Text(
    isAfter ? 'Tap to capture' : 'No image',
    style: GoogleFonts.inter(fontSize: r.captionS, color: isAfter ? ReportsDesign.primaryTeal : ReportsDesign.textTertiary),
    ),
    ],
    ),
    )
        : isAfter
    ?  Align(
    alignment: Alignment.topRight,
    child: Container(
    margin: EdgeInsets. all(r.nanoPadding),
    padding: EdgeInsets. all(r.nanoPadding),
    decoration: BoxDecoration(color: ReportsDesign.success, borderRadius: BorderRadius. circular(r.nanoPadding)),
    child: Icon(Icons.check_rounded, size: r.iconSize(12), color: Colors.white),
    ),
    )
        : null,
    ),
    ),
    if (isAfter && _capturedImage != null) ...[
    SizedBox(height: r.nanoPadding),
    GestureDetector(
    onTap: _showImageSourcePicker,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.refresh_rounded, size: r.iconSize(14), color: ReportsDesign.textSecondary),
    SizedBox(width: r.atomicPadding),
    Text('Retake', style: GoogleFonts.inter(fontSize: r.captionS, color: ReportsDesign.textSecondary)),
    ],
    ),
    ),
    ],
    ],
    );
  }

  Widget _buildLocationSection(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: r. iconSize(18), color: ReportsDesign.textSecondary),
            SizedBox(width: r.microPadding),
            Text('Location Verification', style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight. w600, color: ReportsDesign. textPrimary)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _useManualLocation = ! _useManualLocation);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: r.microPadding, vertical: r.nanoPadding),
                decoration: BoxDecoration(
                  gradient: _useManualLocation
                      ? LinearGradient(colors: [ReportsDesign.warning, ReportsDesign.warning.withOpacity(0.8)])
                      : ReportsDesign. primaryGradient,
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize. min,
                  children: [
                    Icon(_useManualLocation ?  Icons.edit_rounded : Icons. gps_fixed_rounded, size: r. iconSize(12), color: Colors.white),
                    SizedBox(width: r.atomicPadding),
                    Text(_useManualLocation ?  'Manual' : 'GPS', style: GoogleFonts.inter(fontSize: r.captionXS, fontWeight: FontWeight. w700, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: r.microPadding),
        if (_useManualLocation) _buildManualLocationFields(r) else _buildGPSLocationCard(r),
      ],
    );
  }

  Widget _buildGPSLocationCard(EmployeeResponsiveData r) {
    final isSuccess = _position != null && _locationError == null;
    final isError = _locationError != null;
    final color = isError ? ReportsDesign.error : ReportsDesign.primaryTeal;

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: color. withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: color. withOpacity(0.2)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      Row(
      children: [
      Container(
      padding: EdgeInsets. all(r.nanoPadding),
      decoration: BoxDecoration(
        gradient: isError ?  null : ReportsDesign.primaryGradient,
        color: isError ? ReportsDesign.error : null,
        borderRadius: BorderRadius. circular(r.smallBorderRadius),
      ),
      child: Icon(Icons.gps_fixed_rounded, size: r. iconSize(16), color: Colors.white),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: Text('GPS Location (Auto)', style: GoogleFonts.inter(fontSize: r.captionL, fontWeight: FontWeight.w600, color: ReportsDesign.textPrimary)),
    ),
    if (_isLoadingLocation)
    SizedBox(width: r.iconSize(18), height: r. iconSize(18), child: CircularProgressIndicator(strokeWidth: 2, color: ReportsDesign.primaryTeal))
    else if (isSuccess)
    Container(
    padding: EdgeInsets.all(r.atomicPadding),
    decoration: BoxDecoration(color: ReportsDesign.success, shape: BoxShape.circle),
    child: Icon(Icons. check_rounded, size: r. iconSize(12), color: Colors.white),
    )
    else if (isError)
    GestureDetector(
    onTap: _captureLocation,
    child: Container(
    padding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
    decoration: BoxDecoration(color: ReportsDesign.error, borderRadius: BorderRadius. circular(r.smallBorderRadius)),
    child: Text('Retry', style: GoogleFonts.inter(fontSize: r.captionXS, fontWeight: FontWeight. w700, color: Colors.white)),
    ),
    ),
    ],
    ),
    SizedBox(height: r.microPadding),
    if (_isLoadingLocation)
    Text('Capturing your location...', style: GoogleFonts. inter(fontSize: r.captionM, color: ReportsDesign.textSecondary))
    else if (isError)
    Text(_locationError!, style: GoogleFonts.inter(fontSize: r.captionM, color: ReportsDesign.error))
    else if (isSuccess) ...[
    Container(
    padding: EdgeInsets.all(r.microPadding),
    decoration: BoxDecoration(color: ReportsDesign.surfacePure, borderRadius: BorderRadius.circular(r.borderRadius)),
    child: Row(
    children: [
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('Coordinates', style: GoogleFonts.inter(fontSize: r.captionXS, color: ReportsDesign.textTertiary)),
    Text(
    '${_position!. latitude.toStringAsFixed(6)}, ${_position! .longitude.toStringAsFixed(6)}',
    style: GoogleFonts.inter(fontSize: r.captionM, fontWeight: FontWeight. w600, color: ReportsDesign. textPrimary),
    ),
    ],
    ),
    ),
    Container(
    padding: EdgeInsets. symmetric(horizontal: r. microPadding, vertical: r.nanoPadding),
    decoration: BoxDecoration(color: ReportsDesign.success. withOpacity(0.1), borderRadius: BorderRadius.circular(r.smallBorderRadius)),
    child: Text('±${_position!.accuracy.toStringAsFixed(0)}m', style: GoogleFonts. inter(fontSize: r.captionXS, fontWeight: FontWeight. w700, color: ReportsDesign.success)),
    ),
    ],
    ),
    ),
    if (_address != null) ...[
    SizedBox(height: r.microPadding),
    Text('Address', style: GoogleFonts. inter(fontSize: r.captionXS, color: ReportsDesign.textTertiary)),
    Text(_address!, style: GoogleFonts.inter(fontSize: r.captionM, color: ReportsDesign.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
    ],
      ],
          ],
      ),
    );
  }

  Widget _buildManualLocationFields(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign.warning. withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: ReportsDesign.warning. withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [ReportsDesign.warning, ReportsDesign. warning.withOpacity(0.8)]),
                  borderRadius: BorderRadius. circular(r.smallBorderRadius),
                ),
                child: Icon(Icons.edit_location_alt_rounded, size: r.iconSize(16), color: Colors.white),
              ),
              SizedBox(width: r.microPadding),
              Text('Manual Location', style: GoogleFonts.inter(fontSize: r.captionL, fontWeight: FontWeight.w600, color: ReportsDesign.textPrimary)),
            ],
          ),
          SizedBox(height: r.microPadding),
          Row(
            children: [
              Expanded(child: _buildTextField(r, _latController, 'Latitude', 'e.g., 31.7167')),
              SizedBox(width: r.microPadding),
              Expanded(child: _buildTextField(r, _lngController, 'Longitude', 'e.g., 73.9850')),
            ],
          ),
          SizedBox(height: r.microPadding),
          _buildTextField(r, _addressController, 'Address (Optional)', 'Enter address or area name', isNumeric: false),
        ],
      ),
    );
  }

  Widget _buildTextField(
      EmployeeResponsiveData r,
      TextEditingController controller,
      String label,
      String hint, {
        bool isNumeric = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: r.captionXS, color: ReportsDesign.textSecondary)),
        SizedBox(height: r.atomicPadding),
        Container(
          decoration: BoxDecoration(
            color: ReportsDesign.surfacePure,
            borderRadius: BorderRadius.circular(r.borderRadius),
            boxShadow: ReportsDesign.softShadow,
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
            style: GoogleFonts.inter(fontSize: r.bodyS, color: ReportsDesign.textPrimary),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.inter(fontSize: r.captionM, color: ReportsDesign.textTertiary),
              contentPadding: EdgeInsets.symmetric(horizontal: r. microPadding, vertical: r.microPadding),
              border: OutlineInputBorder(borderRadius: BorderRadius. circular(r.borderRadius), borderSide: BorderSide. none),
              filled: true,
              fillColor: ReportsDesign.surfacePure,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampSection(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: ReportsDesign.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [ReportsDesign.info, ReportsDesign.info.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Icon(Icons.access_time_rounded, size: r.iconSize(16), color: Colors.white),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Completion Timestamp', style: GoogleFonts.inter(fontSize: r. captionL, fontWeight: FontWeight. w600, color: ReportsDesign. textPrimary)),
                Text(_formatTimestamp(_captureTime! ), style: GoogleFonts.inter(fontSize: r.captionM, color: ReportsDesign. textSecondary)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(r.atomicPadding),
            decoration: BoxDecoration(color: ReportsDesign.success, shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, size: r.iconSize(12), color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInfoBanner(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [ReportsDesign.purple. withOpacity(0.08), ReportsDesign.purple.withOpacity(0.03)]),
        borderRadius: BorderRadius. circular(r.largeBorderRadius),
        border: Border.all(color: ReportsDesign.purple. withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [ReportsDesign.purple, ReportsDesign. purple.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
              boxShadow: ReportsDesign.glowShadow(ReportsDesign.purple),
            ),
            child: Icon(Icons.auto_awesome_rounded, size: r. iconSize(18), color: Colors. white),
          ),
          SizedBox(width: r. microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Verification', style: GoogleFonts.inter(fontSize: r.captionL, fontWeight: FontWeight.w700, color: ReportsDesign.purple)),
                SizedBox(height: r.atomicPadding),
                Text(
                  'Your cleanup image will be analyzed by AI.  If remaining waste is detected, you\'ll be asked to complete the cleanup.',
                  style: GoogleFonts.inter(fontSize: r.captionS, color: ReportsDesign.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(EmployeeResponsiveData r, double bottomPad) {
    return Container(
      padding: EdgeInsets. fromLTRB(r.padding, r.microPadding, r.padding, bottomPad + r.microPadding),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: r.buttonHeight,
              decoration: BoxDecoration(
                border: Border.all(color: ReportsDesign.textLight),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius. circular(r.borderRadius),
                  child: Center(
                    child: Text('Cancel', style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight.w600, color: ReportsDesign.textSecondary)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: r.buttonHeight,
              decoration: BoxDecoration(
                gradient: _canSubmit()
                    ? ReportsDesign.successGradient
                    : LinearGradient(colors: [ReportsDesign.textLight, ReportsDesign.textLight]),
                borderRadius: BorderRadius.circular(r.borderRadius),
                boxShadow: _canSubmit() ?  ReportsDesign. glowShadow(ReportsDesign. success) : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _canSubmit() ? _submit : null,
                  borderRadius: BorderRadius.circular(r. borderRadius),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: r. iconSize(18), color: _canSubmit() ?  Colors.white : ReportsDesign.textTertiary),
                      SizedBox(width: r.nanoPadding),
                      Text(
                        r.adaptiveText('Submit for Verification', nano: 'Submit', micro: 'Submit', mini: 'Verify'),
                        style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight. w600, color: _canSubmit() ?  Colors.white : ReportsDesign.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour. toString().padLeft(2, '0')}:${dt. minute.toString().padLeft(2, '0')}';
  }
}

// ==================== AI VERIFICATION DIALOG ====================
class _AIVerificationDialog extends StatefulWidget {
  final Report report;
  final EmployeeResponsiveData responsive;
  final String afterImagePath;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final VoidCallback onSuccess;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const _AIVerificationDialog({
    required this.report,
    required this.responsive,
    required this. afterImagePath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this. timestamp,
    required this.onSuccess,
    required this. onRetry,
    required this.onCancel,
  });

  @override
  State<_AIVerificationDialog> createState() => _AIVerificationDialogState();
}

class _AIVerificationDialogState extends State<_AIVerificationDialog> with TickerProviderStateMixin {
  bool _isVerifying = true;
  bool?  _isVerified;
  int _cleanlinessScore = 0;
  final int _threshold = 85;
  List<String> _detectedIssues = [];
  int _currentStep = 0;

  late AnimationController _progressController;
  late AnimationController _resultController;
  late Animation<double> _resultAnimation;

  final List<_VerificationStep> _steps = [
    _VerificationStep('Uploading image', Icons.cloud_upload_rounded),
    _VerificationStep('Verifying GPS', Icons.gps_fixed_rounded),
    _VerificationStep('Analyzing before', Icons.image_rounded),
    _VerificationStep('Analyzing after', Icons. compare_rounded),
    _VerificationStep('Comparing cleanliness', Icons. auto_awesome_rounded),
    _VerificationStep('Generating report', Icons.description_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _resultController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _resultAnimation = CurvedAnimation(parent: _resultController, curve: Curves.elasticOut);
    _startVerification();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _startVerification() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _currentStep = i + 1);
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final isClean = random < 85;

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _isVerified = isClean;
        _cleanlinessScore = isClean ? 85 + (random % 15) : 40 + (random % 40);
        if (! isClean) {
          _detectedIssues = ['Remaining debris detected', 'Small waste particles visible', 'Cleanup incomplete in corner']. take(1 + random % 3). toList();
        }
      });
      _resultController.forward();
    }

    HapticFeedback.heavyImpact();

    if (isClean) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Dialog(
      backgroundColor: ReportsDesign.surfacePure,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(r.extraLargeBorderRadius)),
      child: Container(
        constraints: BoxConstraints(maxWidth: r.dimension(400)),
        padding: EdgeInsets. all(r.largePadding),
        child: _isVerifying ?  _buildVerifyingContent(r) : _buildResultContent(r),
      ),
    );
  }

  Widget _buildVerifyingContent(EmployeeResponsiveData r) {
    return Column(
      mainAxisSize: MainAxisSize. min,
      children: [
        // Animated loading
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1500),
          builder: (context, value, child) {
            return Transform.rotate(angle: value * 2 * math.pi, child: child);
          },
          child: Container(
            width: r.dimension(80),
            height: r.dimension(80),
            decoration: BoxDecoration(
              gradient: SweepGradient(colors: [ReportsDesign.purple, ReportsDesign.purple.withOpacity(0.1), ReportsDesign. purple]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: r.dimension(68),
                height: r.dimension(68),
                decoration: const BoxDecoration(color: ReportsDesign.surfacePure, shape: BoxShape. circle),
                child: Icon(Icons.auto_awesome_rounded, size: r.dimension(32), color: ReportsDesign.purple),
              ),
            ),
          ),
        ),
        SizedBox(height: r.largePadding),
        Text('AI Verification', style: GoogleFonts. inter(fontSize: r.headingXS, fontWeight: FontWeight.w700, color: ReportsDesign.textPrimary)),
        SizedBox(height: r.nanoPadding),
        Text('Analyzing your cleanup...', style: GoogleFonts.inter(fontSize: r. bodyS, color: ReportsDesign.textSecondary)),
        SizedBox(height: r.largePadding),

        // Steps
        ... List.generate(_steps.length, (index) {
          final step = _steps[index];
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep - 1 && _currentStep <= _steps.length;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: isCompleted || isCurrent ? 1.0 : 0.5),
            duration: const Duration(milliseconds: 300),
            builder: (context, opacity, child) => Opacity(opacity: opacity, child: child),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: r.nanoPadding),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: r.dimension(28),
                    height: r.dimension(28),
                    decoration: BoxDecoration(
                      gradient: isCompleted ?  ReportsDesign.successGradient : (isCurrent ? ReportsDesign.primaryGradient : null),
                      color: ! isCompleted && ! isCurrent ? ReportsDesign.surfaceLight : null,
                      shape: BoxShape.circle,
                      boxShadow: isCompleted || isCurrent ? ReportsDesign.glowShadow(isCompleted ? ReportsDesign.success : ReportsDesign. primaryTeal) : null,
                    ),
                    child: isCompleted
                        ? Icon(Icons.check_rounded, size: r. iconSize(14), color: Colors.white)
                        : isCurrent
                        ? SizedBox(width: r.iconSize(14), height: r.iconSize(14), child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(step.icon, size: r.iconSize(12), color: ReportsDesign.textTertiary),
                  ),
                  SizedBox(width: r.microPadding),
                  Expanded(
                    child: Text(
                      step.label,
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: isCompleted ?  ReportsDesign. success : (isCurrent ? ReportsDesign.primaryTeal : ReportsDesign.textTertiary),
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        SizedBox(height: r.padding),
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(foregroundColor: ReportsDesign.textSecondary),
          child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight. w600)),
        ),
      ],
    );
  }

  Widget _buildResultContent(EmployeeResponsiveData r) {
    if (_isVerified == true) {
      return ScaleTransition(
        scale: _resultAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: r.dimension(100),
              height: r.dimension(100),
              decoration: BoxDecoration(
                gradient: ReportsDesign.successGradient,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: ReportsDesign.success.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
              ),
              child: Icon(Icons.check_rounded, size: r.dimension(50), color: Colors.white),
            ),
            SizedBox(height: r.padding),
            Text('Cleanup Verified! ', style: GoogleFonts.inter(fontSize: r.headingXS, fontWeight: FontWeight. w700, color: ReportsDesign. success)),
            SizedBox(height: r.nanoPadding),
            Text('Great job!  The area is clean. ', style: GoogleFonts.inter(fontSize: r.bodyS, color: ReportsDesign.textSecondary)),
            SizedBox(height: r.padding),
            Container(
              padding: EdgeInsets. all(r.padding),
              decoration: BoxDecoration(color: ReportsDesign.surfaceLight, borderRadius: BorderRadius. circular(r.largeBorderRadius)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment. spaceEvenly,
                children: [
                  _buildScoreItem(r, 'Score', '$_cleanlinessScore%', ReportsDesign.success),
                  Container(width: 1, height: r.dimension(40), color: ReportsDesign.textLight),
                  _buildScoreItem(r, 'Threshold', '≥$_threshold%', ReportsDesign.info),
                ],
              ),
            ),
            SizedBox(height: r.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: r.dimension(16), height: r. dimension(16), child: CircularProgressIndicator(strokeWidth: 2, color: ReportsDesign.success)),
                SizedBox(width: r.microPadding),
                Text('Completing task...', style: GoogleFonts.inter(fontSize: r. captionM, color: ReportsDesign.textSecondary)),
              ],
            ),
          ],
        ),
      );
    } else {
      return ScaleTransition(
        scale: _resultAnimation,
        child: Column(
            mainAxisSize: MainAxisSize. min,
            children: [
        Container(
        width: r.dimension(100),
        height: r.dimension(100),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [ReportsDesign.warning, ReportsDesign.warning.withOpacity(0.8)]),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: ReportsDesign.warning. withOpacity(0.4), blurRadius: 30, spreadRadius: 5)],
        ),
        child: Icon(Icons.warning_rounded, size: r. dimension(50), color: Colors.white),
      ),
    SizedBox(height: r.padding),
    Text('Cleanup Incomplete', style: GoogleFonts. inter(fontSize: r.headingXS, fontWeight: FontWeight.w700, color: ReportsDesign.warning)),
    SizedBox(height: r.nanoPadding),
    Text('AI detected remaining waste. ', style: GoogleFonts.inter(fontSize: r.bodyS, color: ReportsDesign.textSecondary), textAlign: TextAlign. center),
    SizedBox(height: r.padding),

    // Score display
    Container(
    padding: EdgeInsets.all(r.padding),
    decoration: BoxDecoration(
    color: ReportsDesign.warning.withOpacity(0.05),
    borderRadius: BorderRadius.circular(r.largeBorderRadius),
    border: Border.all(color: ReportsDesign.warning. withOpacity(0.2)),
    ),
    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text('Score:', style: GoogleFonts.inter(fontSize: r.bodyS)),
    Text('$_cleanlinessScore%', style: GoogleFonts. inter(fontSize: r.bodyM, fontWeight: FontWeight. w700, color: ReportsDesign.warning)),
    ],
    ),
    SizedBox(height: r.nanoPadding),
    Row(
    mainAxisAlignment: MainAxisAlignment. spaceBetween,
    children: [
    Text('Required:', style: GoogleFonts.inter(fontSize: r.bodyS)),
    Text('≥$_threshold%', style: GoogleFonts.inter(fontSize: r.bodyM, fontWeight: FontWeight.w700, color: ReportsDesign.success)),
    ],
    ),
    if (_detectedIssues. isNotEmpty) ...[
    Divider(height: r.padding, color: ReportsDesign.warning.withOpacity(0.3)),
    ..._detectedIssues.map((issue) => Padding(
    padding: EdgeInsets.only(top: r.nanoPadding),
    child: Row(
    children: [
    Icon(Icons.fiber_manual_record, size: r.iconSize(8), color: ReportsDesign.warning),
    SizedBox(width: r.microPadding),
    Expanded(child: Text(issue, style: GoogleFonts.inter(fontSize: r.captionM, color: ReportsDesign. textSecondary))),
    ],
    ),
    )),
    ],
    ],
    ),
    ),
    SizedBox(height: r.largePadding),

    // Action buttons
    Row(
    children: [
    Expanded(
    child: Container(
    height: r.buttonHeight,
    decoration: BoxDecoration(border: Border.all(color: ReportsDesign.textLight), borderRadius: BorderRadius.circular(r. borderRadius)),
    child: Material(
    color: Colors.transparent,
    child: InkWell(
    onTap: widget.onCancel,
    borderRadius: BorderRadius.circular(r. borderRadius),
    child: Center(child: Text('Cancel', style: GoogleFonts. inter(fontSize: r.bodyS, fontWeight: FontWeight. w600, color: ReportsDesign. textSecondary))),
    ),
    ),
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    flex: 2,
    child: Container(
    height: r.buttonHeight,
    decoration: BoxDecoration(
    gradient: LinearGradient(colors: [ReportsDesign.warning, ReportsDesign.warning.withOpacity(0.9)]),
    borderRadius: BorderRadius.circular(r. borderRadius),
    boxShadow: ReportsDesign.glowShadow(ReportsDesign. warning),
    ),
    child: Material(
    color: Colors. transparent,
    child: InkWell(
    onTap: widget.onRetry,
    borderRadius: BorderRadius.circular(r.borderRadius),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.camera_alt_rounded, size: r. iconSize(18), color: Colors.white),
    SizedBox(width: r.nanoPadding),
    Text('Retake Photo', style: GoogleFonts.inter(fontSize: r.bodyS, fontWeight: FontWeight.w600, color: Colors.white)),
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
    );
    }
    }

  Widget _buildScoreItem(EmployeeResponsiveData r, String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: r.headingS, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts. inter(fontSize: r.captionS, color: ReportsDesign.textSecondary)),
      ],
    );
  }
}

class _VerificationStep {
  final String label;
  final IconData icon;

  _VerificationStep(this.label, this.icon);
}

// ==================== SUCCESS ANIMATION DIALOG ====================
class _SuccessAnimationDialog extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onComplete;

  const _SuccessAnimationDialog({
    required this. responsive,
    required this.onComplete,
  });

  @override
  State<_SuccessAnimationDialog> createState() => _SuccessAnimationDialogState();
}

class _SuccessAnimationDialogState extends State<_SuccessAnimationDialog> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _confettiController;
  late AnimationController _textController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _textAnimation;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateParticles();
    _startSequence();
  }

  void _initAnimations() {
    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    _checkController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack);

    _confettiController = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this);

    _textController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _textAnimation = CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic);
  }

  void _generateParticles() {
    final random = math.Random();
    final colors = [ReportsDesign.primaryTeal, ReportsDesign.primaryTealLight, Colors.white, ReportsDesign.success, ReportsDesign.info, ReportsDesign.warning];

    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        angle: random.nextDouble() * 2 * math.pi,
        velocity: 80 + random.nextDouble() * 250,
        rotationSpeed: random. nextDouble() * 12 - 6,
        size: 4 + random.nextDouble() * 10,
        color: colors[random.nextInt(colors.length)],
        shape: random.nextInt(3),
        delay: random.nextDouble() * 0.3,
      ));
    }
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
    _confettiController.forward();
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _confettiController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                  centerX: size.width / 2,
                  centerY: size.height / 2 - 50,
                ),
              );
            },
          ),

          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: r.dimension(140),
                  height: r.dimension(140),
                  decoration: BoxDecoration(
                    gradient: ReportsDesign.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: ReportsDesign.primaryTeal. withOpacity(0.5), blurRadius: 50, spreadRadius: 15)],
                  ),
                  child: ScaleTransition(
                    scale: _checkAnimation,
                    child: Icon(Icons.check_rounded, size: r.dimension(70), color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: r.largePadding),
              FadeTransition(
                opacity: _textAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero). animate(_textAnimation),
                  child: Column(
                    children: [
                      Text(
                        'Report Submitted',
                        style: GoogleFonts. inter(fontSize: r.headingM, fontWeight: FontWeight.w800, color: ReportsDesign.textPrimary, letterSpacing: -0.5),
                      ),
                      SizedBox(height: r.nanoPadding),
                      ShaderMask(
                        shaderCallback: (bounds) => ReportsDesign.primaryGradient.createShader(bounds),
                        child: Text('Thank You! ', style: GoogleFonts.inter(fontSize: r.headingS, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      SizedBox(height: r.padding),
                      Container(
                        padding: EdgeInsets. symmetric(horizontal: r.padding, vertical: r.microPadding),
                        decoration: BoxDecoration(color: ReportsDesign.surfaceLight, borderRadius: BorderRadius.circular(r. pillBorderRadius)),
                        child: Text('The citizen has been notified', style: GoogleFonts.inter(fontSize: r.bodyS, color: ReportsDesign.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== CONFETTI PAINTER ====================
class _ConfettiParticle {
  final double angle;
  final double velocity;
  final double rotationSpeed;
  final double size;
  final Color color;
  final int shape;
  final double delay;

  _ConfettiParticle({
    required this.angle,
    required this.velocity,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.shape,
    this.delay = 0,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final double centerX;
  final double centerY;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final adjustedProgress = ((progress - particle.delay) / (1 - particle.delay)). clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final distance = particle.velocity * adjustedProgress;
      final gravity = 300 * adjustedProgress * adjustedProgress;

      final x = centerX + math.cos(particle.angle) * distance;
      final y = centerY + math.sin(particle. angle) * distance + gravity;

      final opacity = (1 - adjustedProgress * 0.8).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color. withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas. translate(x, y);
      canvas. rotate(particle.rotationSpeed * adjustedProgress * math.pi * 2);

      switch (particle.shape) {
        case 0:
          canvas.drawCircle(Offset. zero, particle.size / 2, paint);
          break;
        case 1:
          canvas. drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: Offset. zero, width: particle.size, height: particle.size * 0.6), Radius.circular(particle.size * 0.1)),
            paint,
          );
          break;
        case 2:
          final path = Path()
            ..moveTo(0, -particle.size / 2)
            .. lineTo(particle. size / 2, particle.size / 2)
            ..lineTo(-particle.size / 2, particle.size / 2)
            ..close();
          canvas. drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}