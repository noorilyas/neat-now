import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/reports_tab_viewmodel.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class ReportDetailsPage extends StatefulWidget {
  final Report report;
  final ReportsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Function(int, String, {String? imagePath, double? latitude, double? longitude, String? locationAddress}) onUpdateStatus;
  final VoidCallback onShowResolveDialog;
  final Function(double lat, double lng) onNavigate;

  const ReportDetailsPage({
    super.key,
    required this. report,
    required this.viewModel,
    required this.responsive,
    required this.onUpdateStatus,
    required this.onShowResolveDialog,
    required this.onNavigate,
  });

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds:  600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent:  _animController,
      curve:  Curves.easeOutCubic,
    );

    // ✅ SAFE ANIMATION START
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animController. forward();
      }
    });
  }

  @override
  void dispose() {
    _animController.stop();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final report = widget. report;
    final statusColor = widget.viewModel.getStatusColor(report.status);
    final hasLocation = report.latitude != null &&
        report.longitude != null &&
        report.latitude != 0.0 &&
        report.longitude != 0.0;

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
            leading:  Padding(
              padding: EdgeInsets.all(r.microPadding),
              child:  GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
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
              if (hasLocation)
                Padding(
                  padding: EdgeInsets.all(r.microPadding),
                  child:  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onNavigate(report.latitude!, report.longitude!);
                    },
                    child: Container(
                      padding: EdgeInsets.all(r.microPadding),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ReportsDesign.info,
                            ReportsDesign.info. withOpacity(0.9),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: ReportsDesign.glowShadow(ReportsDesign.info),
                      ),
                      child: Icon(
                        Icons.navigation_rounded,
                        color:  Colors.white,
                        size: r.iconSize(18),
                      ),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode. zoomBackground,
                StretchMode. fadeTitle,
              ],
              background:  _buildHeaderImage(r, report, statusColor),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child:  Padding(
                padding: EdgeInsets.all(r.padding),
                child: Column(
                  children: [
                    _buildHeaderCard(r, statusColor),
                    SizedBox(height: r.padding),
                    _buildAIClassificationCard(r),
                    SizedBox(height: r. padding),
                    _buildDetailsCard(r),
                    SizedBox(height: r.padding),
                    if (hasLocation) _buildNavigationCard(r),
                    if (hasLocation) SizedBox(height: r.padding),
                    _buildTimelineCard(r),
                    SizedBox(height: r.padding),
                    if (report.status != 'resolved')
                      _buildActionButtons(r, hasLocation),
                    SizedBox(height: r. dimension(100)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(
      EmployeeResponsiveData r,
      Report report,
      Color statusColor,
      ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (report.imageUrl != null && report.imageUrl! .isNotEmpty)
          Image.network(
            report.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: BoxDecoration(
                gradient: ReportsDesign.primaryGradient,
              ),
              child: Icon(
                Icons.broken_image_rounded,
                size: r.dimension(60),
                color: Colors.white. withOpacity(0.5),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: ReportsDesign.primaryGradient,
            ),
            child: Icon(
              Icons. image_not_supported_rounded,
              size: r. dimension(60),
              color:  Colors.white.withOpacity(0.5),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:  [
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
              begin: Alignment.topCenter,
              end: Alignment. bottomCenter,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          bottom: r.padding,
          left: r.padding,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical: r. nanoPadding,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:  [statusColor, statusColor.withOpacity(0.9)],
              ),
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
              boxShadow: ReportsDesign.glowShadow(statusColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.viewModel.getStatusIcon(report. status),
                  color: Colors.white,
                  size: r.iconSize(14),
                ),
                SizedBox(width: r.nanoPadding),
                Text(
                  widget.viewModel.getStatusText(report.status),
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w700,
                    color: Colors. white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(EmployeeResponsiveData r, Color statusColor) {
    final report = widget.report;

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        borderRadius:  BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: ReportsDesign.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor. withOpacity(0.2),
                  statusColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              widget.viewModel. getWasteIcon(report.type),
              color: statusColor,
              size: r. iconSize(32),
            ),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.type,
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: ReportsDesign.textPrimary,
                  ),
                ),
                Text(
                  'Task #${report.id}',
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
      {'name': 'Paper', 'percentage': 20, 'color': ReportsDesign.warning},
      {'name': 'Organic', 'percentage': 10, 'color': ReportsDesign.success},
      {'name': 'Other', 'percentage': 5, 'color': ReportsDesign.textTertiary},
    ];

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: ReportsDesign.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration:  BoxDecoration(
                  color: ReportsDesign.purpleLight,
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: ReportsDesign.purple,
                  size: r. iconSize(18),
                ),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'AI Classification',
                style: GoogleFonts.inter(
                  fontSize: r. bodyS,
                  fontWeight: FontWeight.w700,
                  color: ReportsDesign.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.microPadding,
                  vertical:  r.nanoPadding,
                ),
                decoration: BoxDecoration(
                  color: ReportsDesign.success. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: r.iconSize(12),
                      color: ReportsDesign.success,
                    ),
                    SizedBox(width: r.atomicPadding),
                    Text(
                      '94% confidence',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        fontWeight: FontWeight.w700,
                        color: ReportsDesign.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: r.padding),
          ...categories.map((cat) => _buildCategoryBar(r, cat)),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(EmployeeResponsiveData r, Map<String, dynamic> cat) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin:  0.0, end: (cat['percentage'] as int) / 100.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: r.microPadding),
          child: Row(
            children: [
              Container(
                width: r.dimension(10),
                height: r.dimension(10),
                decoration: BoxDecoration(
                  color:  cat['color'] as Color,
                  borderRadius:  BorderRadius.circular(r.tinyBorderRadius),
                ),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Text(
                  cat['name'] as String,
                  style:  GoogleFonts.inter(
                    fontSize: r.captionM,
                    color: ReportsDesign.textSecondary,
                  ),
                ),
              ),
              SizedBox(
                width: r.dimension(100),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                  child: LinearProgressIndicator(
                    value:  value,
                    backgroundColor: (cat['color'] as Color).withOpacity(0.15),
                    color: cat['color'] as Color,
                    minHeight: r.dimension(6),
                  ),
                ),
              ),
              SizedBox(width: r. microPadding),
              SizedBox(
                width: r.dimension(35),
                child: Text(
                  '${cat['percentage']}%',
                  style: GoogleFonts. inter(
                    fontSize: r.captionS,
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
    final report = widget.report;

    return Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: ReportsDesign.surfacePure,
          borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
          boxShadow: ReportsDesign.softShadow,
        ),
        child: Column(
          children:  [
          _buildDetailItem(
          r,
          Icons.location_on_rounded,
          'Location',
          report.location,
          ReportsDesign.error,
        ),
        Divider(height: r.padding * 2, color: ReportsDesign.surfaceLight),
        _buildDetailItem(
          r,
          Icons. person_rounded,
          'Reported By',
          report.userName,
          ReportsDesign. info,
        ),
        if (report.description != null && report.description!.isNotEmpty) ...[
    Divider(height: r.padding * 2, color: ReportsDesign.surfaceLight),
    _buildDetailItem(
    r,
    Icons.notes_rounded,
    'Description',
    report.description!,
    ReportsDesign.textSecondary,
    ),
    ],
    ],
    ),
    );
  }

  Widget _buildDetailItem(
      EmployeeResponsiveData r,
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(r.nanoPadding),
          decoration:  BoxDecoration(
            color:  color. withOpacity(0.1),
            borderRadius: BorderRadius. circular(r.smallBorderRadius),
          ),
          child: Icon(icon, size: r.iconSize(18), color: color),
        ),
        SizedBox(width: r.padding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
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

  Widget _buildNavigationCard(EmployeeResponsiveData r) {
    final report = widget.report;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onNavigate(report.latitude!, report.longitude!);
      },
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:  [
              ReportsDesign. info. withOpacity(0.1),
              ReportsDesign. info.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
          border: Border. all(color: ReportsDesign.info. withOpacity(0.2)),
          boxShadow: ReportsDesign.softShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:  [
                    ReportsDesign.info,
                    ReportsDesign. info.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius. circular(r.borderRadius),
                boxShadow: ReportsDesign.glowShadow(ReportsDesign.info),
              ),
              child: Icon(
                Icons.navigation_rounded,
                color: Colors.white,
                size: r.iconSize(24),
              ),
            ),
            SizedBox(width: r.padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigate to Location',
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w700,
                      color: ReportsDesign.info,
                    ),
                  ),
                  SizedBox(height: r.atomicPadding),
                  Text(
                    'Open directions in Maps',
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
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
                color: ReportsDesign. info,
                size: r.iconSize(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(EmployeeResponsiveData r) {
    final events = widget.viewModel.getTimelineEvents(widget.report);

    return Container(
      padding:  EdgeInsets.all(r. padding),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
        boxShadow: ReportsDesign.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration:  BoxDecoration(
                  color: ReportsDesign.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color:  ReportsDesign.primaryTeal,
                  size: r. iconSize(18),
                ),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Timeline',
                style: GoogleFonts.inter(
                  fontSize: r. bodyS,
                  fontWeight:  FontWeight.w700,
                  color: ReportsDesign. textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.padding),
          ...events.asMap().entries.map((entry) {
            final isLast = entry.key == events.length - 1;
            return _buildTimelineItem(r, entry.value, isLast, entry.key);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      EmployeeResponsiveData r,
      TimelineEvent event,
      bool isLast,
      int index,
      ) {
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
                      ? LinearGradient(
                    colors:  [event.color, event.color.withOpacity(0.8)],
                  )
                      : null,
                  color: event.isCompleted ?  null : event.color. withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: event.isCompleted
                      ?  ReportsDesign.glowShadow(event.color)
                      : null,
                ),
                child:  Icon(
                  event.icon,
                  size: r.iconSize(16),
                  color: event. isCompleted ? Colors.white :  event.color,
                ),
              ),
              if (! isLast)
                Container(
                  width: 2,
                  height: r. dimension(35),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        event.isCompleted
                            ? event.color.withOpacity(0.5)
                            : ReportsDesign.surfaceOverlay,
                        ReportsDesign.surfaceOverlay,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: r. padding),
          Expanded(
            child:  Padding(
              padding: EdgeInsets.only(top: r.nanoPadding),
              child:  Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w600,
                      color: event.isCompleted
                          ? ReportsDesign. textPrimary
                          :  ReportsDesign.textTertiary,
                    ),
                  ),
                  if (event.isCompleted)
                    Text(
                      widget.viewModel.formatDateTime(event.date),
                      style: GoogleFonts.inter(
                        fontSize: r. captionS,
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
    final report = widget.report;

    if (report.status == 'in-progress') {
      return Column(
        children: [
          if (hasLocation)
            _buildFullWidthButton(
              r,
              icon: Icons.navigation_rounded,
              label: 'Navigate to Location',
              color: ReportsDesign.info,
              isOutlined: true,
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onNavigate(report.latitude!, report.longitude!);
              },
            ),
          if (hasLocation) SizedBox(height: r. microPadding),
          _buildFullWidthButton(
            r,
            icon: Icons.camera_alt_rounded,
            label: 'Mark as Completed',
            color: ReportsDesign.primaryTeal,
            onTap: widget.onShowResolveDialog,
          ),
        ],
      );
    }

    // Pending status
    return Column(
      children: [
        _buildFullWidthButton(
          r,
          icon: Icons. play_arrow_rounded,
          label: 'Start Processing',
          color: ReportsDesign.info,
          onTap: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            widget.onUpdateStatus(report.id, 'in-progress');
          },
        ),
        SizedBox(height: r.microPadding),
        _buildFullWidthButton(
          r,
          icon: Icons.check_circle_rounded,
          label: 'Quick Resolve',
          color: ReportsDesign.primaryTeal,
          onTap: widget.onShowResolveDialog,
        ),
      ],
    );
  }

  Widget _buildFullWidthButton(
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
        bool isOutlined = false,
      }) {
    return Container(
      width: double.infinity,
      height: r.buttonHeight + 8,
      decoration: BoxDecoration(
        gradient: isOutlined ?  null : LinearGradient(colors: [color, color.withOpacity(0.9)]),
        border: isOutlined ? Border.all(color: color, width: 2) : null,
        borderRadius: BorderRadius. circular(r.largeBorderRadius),
        boxShadow: isOutlined ?  null : ReportsDesign.glowShadow(color),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:  onTap,
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isOutlined ? color : Colors.white,
                size: r.iconSize(22),
              ),
              SizedBox(width: r.microPadding),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  fontWeight:  FontWeight.w700,
                  color: isOutlined ? color : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}