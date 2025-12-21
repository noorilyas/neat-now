import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import 'package:neat_now/screens//user_dashboard.dart';
import 'package:neat_now/widgets/user/user_reports_tab.dart';
import 'package:neat_now/widgets/user/responsive_user_helper.dart';

// ==================== REPORT DETAIL SHEET ====================
class _ReportDetailSheet extends StatefulWidget {
  final UserReport report;
  final UserResponsiveData responsive;
  final VoidCallback onRate;
  final VoidCallback onViewImages;

  const _ReportDetailSheet({
    required this.report,
    required this.responsive,
    required this. onRate,
    required this.onViewImages,
  });

  @override
  State<_ReportDetailSheet> createState() => _ReportDetailSheetState();
}

class _ReportDetailSheetState extends State<_ReportDetailSheet>
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
          mainAxisSize: MainAxisSize. min,
          children: [
      // Handle
      Container(
      width: r.dimension(40),
      height: r.dimension(4),
      margin: EdgeInsets.symmetric(vertical: r.microPadding),
      decoration: BoxDecoration(
        color: UserDesign.textLight,
        borderRadius: BorderRadius. circular(r.pillBorderRadius),
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
    _buildInfoCard(
    r,
    Icons.category_rounded,
    'Waste Type',
    report.type,
    UserDesign.purple,
    ),

    _buildInfoCard(
    r,
    Icons.location_on_rounded,
    'Location',
    report.location,
    UserDesign.error,
    ),

    if (report.description != null &&
    report. description!.isNotEmpty)
    _buildInfoCard(
    r,
    Icons. description_rounded,
    'Description',
    report. description!,
    UserDesign. info,
    isMultiLine: true,
    ),

    _buildInfoCard(
    r,
    Icons.schedule_rounded,
    'Submitted',
    _formatDateTime(report.submittedAt),
    UserDesign. warning,
    ),

    // Worker Info (if assigned)
    if (report.workerName != null)
    _buildWorkerCard(r, report),

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
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(r.borderRadius),
            boxShadow: UserDesign.glowShadow(color),
          ),
          child: Icon(
            _getWasteIcon(report.type),
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
                report.type,
                style: GoogleFonts.inter(
                  fontSize: r.headingXS,
                  fontWeight: FontWeight.w700,
                  color: UserDesign. textPrimary,
                ),
              ),
              Text(
                'Report #${report.id}',
                style: GoogleFonts. inter(
                  fontSize: r.captionS,
                  color: UserDesign. textTertiary,
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
            color: color. withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: r.atomicPadding),
              Text(
                _getStatusLabel(report. status),
                style: GoogleFonts.inter(
                  fontSize: r. captionS,
                  fontWeight: FontWeight. w600,
                  color: color,
                ),
              ),
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
          gradient: LinearGradient(
            colors: [
              UserDesign. success. withOpacity(0.08),
              UserDesign.success.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(color: UserDesign. success. withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets. all(r.nanoPadding),
                  decoration: BoxDecoration(
                    color: UserDesign.success,
                    borderRadius: BorderRadius. circular(r.smallBorderRadius),
                  ),
                  child: Icon(
                    Icons. compare_rounded,
                    color: Colors.white,
                    size: r.iconSize(16),
                  ),
                ),
                SizedBox(width: r.microPadding),
                Text(
                  'Before & After Cleanup',
                  style: GoogleFonts.inter(
                    fontSize: r. bodyS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign. success,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.zoom_in_rounded,
                  color: UserDesign.success,
                  size: r.iconSize(20),
                ),
              ],
            ),
            SizedBox(height: r. microPadding),
            Row(
              children: [
                // Before
                Expanded(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(r.borderRadius),
                        child: Stack(
                          children: [
                            Image. network(
                              report.beforeImageUrl ??  '',
                              height: r.dimension(120),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildImagePlaceholder(r, r.dimension(120)),
                            ),
                            Positioned(
                              top: r.nanoPadding,
                              left: r.nanoPadding,
                              child: Container(
                                padding: EdgeInsets. symmetric(
                                  horizontal: r.microPadding,
                                  vertical: r.atomicPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: UserDesign.error,
                                  borderRadius:
                                  BorderRadius.circular(r.smallBorderRadius),
                                ),
                                child: Text(
                                  'BEFORE',
                                  style: GoogleFonts.inter(
                                    fontSize: r.captionXS - 1,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets. symmetric(horizontal: r.microPadding),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets. all(r.nanoPadding),
                        decoration: BoxDecoration(
                          color: UserDesign.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: r. iconSize(16),
                        ),
                      ),
                    ],
                  ),
                ),
                // After
                Expanded(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(r. borderRadius),
                        child: Stack(
                          children: [
                            Image.network(
                              report.afterImageUrl ?? '',
                              height: r. dimension(120),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildImagePlaceholder(r, r.dimension(120)),
                            ),
                            Positioned(
                              top: r.nanoPadding,
                              left: r.nanoPadding,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: r.microPadding,
                                  vertical: r. atomicPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: UserDesign.success,
                                  borderRadius:
                                  BorderRadius. circular(r.smallBorderRadius),
                                ),
                                child: Text(
                                  'AFTER',
                                  style: GoogleFonts.inter(
                                    fontSize: r.captionXS - 1,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: r.microPadding),
            Center(
              child: Text(
                'Tap to view full comparison',
                style: GoogleFonts. inter(
                  fontSize: r.captionXS,
                  color: UserDesign.textSecondary,
                ),
              ),
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
          Icon(
            Icons. photo_camera_rounded,
            size: r.iconSize(16),
            color: UserDesign.warning,
          ),
          SizedBox(width: r.nanoPadding),
          Text(
            'Reported Image',
            style: GoogleFonts. inter(
              fontSize: r.captionM,
              fontWeight: FontWeight. w600,
              color: UserDesign.textSecondary,
            ),
          ),
        ],
        ),
          SizedBox(height: r. nanoPadding),
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
      decoration: BoxDecoration(
        color: UserDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: r.iconSize(32),
              color: UserDesign.textTertiary,
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              'Image unavailable',
              style: GoogleFonts.inter(
                fontSize: r.captionS,
                color: UserDesign. textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(UserResponsiveData r, UserReport report) {
    final steps = [
      _TimelineStep('Uploaded', report.submittedAt, true, Icons.cloud_upload_rounded),
      _TimelineStep('Pending', report.submittedAt, report.status != 'uploaded', Icons.schedule_rounded),
      _TimelineStep('Assigned', report.workerName != null ?  report.submittedAt : null,
          report.status == 'assigned' || report.status == 'resolved', Icons.person_add_rounded),
      _TimelineStep('Resolved', report.resolvedAt, report. status == 'resolved', Icons.check_circle_rounded),
    ];

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: UserDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: r.iconSize(16), color: UserDesign.info),
              SizedBox(width: r.nanoPadding),
              Text(
                'Status Timeline',
                style: GoogleFonts. inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight. w600,
                  color: UserDesign.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
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
                        gradient: step.isCompleted
                            ? UserDesign.successGradient
                            : null,
                        color: step.isCompleted ?  null : UserDesign. surfaceOverlay,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.icon,
                        size: r.iconSize(14),
                        color: step.isCompleted ? Colors.white : UserDesign.textTertiary,
                      ),
                    ),
                    if (!isLast)
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
                    padding: EdgeInsets. only(bottom: isLast ? 0 : r. microPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: GoogleFonts.inter(
                            fontSize: r. captionM,
                            fontWeight: step.isCompleted ?  FontWeight.w600 : FontWeight. w500,
                            color: step. isCompleted ? UserDesign.textPrimary : UserDesign.textTertiary,
                          ),
                        ),
                        if (step.timestamp != null && step.isCompleted)
                          Text(
                            _formatDateTime(step.timestamp! ),
                            style: GoogleFonts.inter(
                              fontSize: r. captionXS,
                              color: UserDesign.textTertiary,
                            ),
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

  Widget _buildInfoCard(
      UserResponsiveData r,
      IconData icon,
      String label,
      String value,
      Color color, {
        bool isMultiLine = false,
      }) {
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
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    color: UserDesign.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: r. bodyS,
                    fontWeight: FontWeight.w600,
                    color: UserDesign. textPrimary,
                  ),
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
      margin: EdgeInsets.only(bottom: r. microPadding),
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UserDesign. info.withOpacity(0.08),
            UserDesign.info.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: UserDesign.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Row(
            children: [
              Icon(Icons.engineering_rounded, size: r. iconSize(16), color: UserDesign.info),
              SizedBox(width: r.nanoPadding),
              Text(
                'Assigned Worker',
                style: GoogleFonts.inter(
                  fontSize: r. captionM,
                  fontWeight: FontWeight.w600,
                  color: UserDesign. info,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          Row(
            children: [
              Container(
                width: r.dimension(48),
                height: r.dimension(48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [UserDesign.info, UserDesign.info.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: report.workerImage != null
                    ?  ClipOval(
                  child: Image.network(
                    report.workerImage! ,
                    fit: BoxFit. cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        report.workerName![0]. toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: r.bodyM,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                    : Center(
                  child: Text(
                    report.workerName![0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: r. bodyM,
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
                      report. workerName! ,
                      style: GoogleFonts.inter(
                        fontSize: r. bodyS,
                        fontWeight: FontWeight. w600,
                        color: UserDesign.textPrimary,
                      ),
                    ),
                    if (report.workerPhone != null)
                      Text(
                        report.workerPhone! ,
                        style: GoogleFonts.inter(
                          fontSize: r. captionS,
                          color: UserDesign.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (report.workerPhone != null)
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final url = 'tel:${report.workerPhone}';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(r.microPadding),
                    decoration: BoxDecoration(
                      color: UserDesign.success,
                      borderRadius: BorderRadius. circular(r.borderRadius),
                    ),
                    child: Icon(Icons.phone_rounded, color: Colors.white, size: r.iconSize(18)),
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
        gradient: LinearGradient(
          colors: [
            UserDesign.success.withOpacity(0.08),
            UserDesign.success.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(r. largeBorderRadius),
        border: Border.all(color: UserDesign.success.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets. all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: UserDesign.success,
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(Icons.check_rounded, color: Colors.white, size: r.iconSize(14)),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cleanup Completed',
                      style: GoogleFonts.inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight. w700,
                        color: UserDesign.success,
                      ),
                    ),
                    Text(
                      _formatDateTime(report. resolvedAt!),
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        color: UserDesign.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (report.cleanupDuration != null)
                Container(
                  padding: EdgeInsets. symmetric(
                    horizontal: r.microPadding,
                    vertical: r. nanoPadding,
                  ),
                  decoration: BoxDecoration(
                    color: UserDesign.success. withOpacity(0.15),
                    borderRadius: BorderRadius. circular(r.pillBorderRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_rounded, size: r.iconSize(12), color: UserDesign.success),
                      SizedBox(width: r. atomicPadding),
                      Text(
                        _formatDuration(report.cleanupDuration!),
                        style: GoogleFonts.inter(
                          fontSize: r.captionXS,
                          fontWeight: FontWeight. w600,
                          color: UserDesign.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(UserResponsiveData r, UserReport report) {
    if (report.rating != null) {
      return Container(
        padding: EdgeInsets.all(r. padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700). withOpacity(0.1),
              const Color(0xFFFFD700). withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius. circular(r.largeBorderRadius),
          border: Border.all(color: const Color(0xFFFFD700). withOpacity(0.3)),
        ),
        child: Column(
            children: [
        Row(
        children: [
        Icon(Icons.star_rounded, color: const Color(0xFFFFD700), size: r.iconSize(20)),
        SizedBox(width: r.nanoPadding),
        Text(
          'Your Rating',
          style: GoogleFonts.inter(
            fontSize: r.bodyS,
            fontWeight: FontWeight. w700,
            color: const Color(0xFFD97706),
          ),
        ),
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
    Text(
    'Your Feedback',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    color: UserDesign.textTertiary,
    ),
    ),
    SizedBox(height: r.atomicPadding),
    Text(
    report. feedback!,
    style: GoogleFonts. inter(
    fontSize: r.captionM,
    color: UserDesign. textSecondary,
    fontStyle: FontStyle.italic,
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
    return GestureDetector(
    onTap: widget.onRate,
    child: Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: r.padding),
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    ),
    borderRadius: BorderRadius.circular(r.borderRadius),
    boxShadow: UserDesign.glowShadow(const Color(0xFFFFD700)),
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment. center,
    children: [
    Icon(Icons.star_rounded, color: Colors.white, size: r.iconSize(22)),
    SizedBox(width: r.nanoPadding),
    Text(
    'Rate & Leave Feedback',
    style: GoogleFonts.inter(
    fontSize: r. bodyS,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    ),
    ),
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
    if (t. contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('construction')) return Icons.construction_rounded;
    return Icons.delete_rounded;
  }

  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour. toString().padLeft(2, '0')}:${date. minute.toString().padLeft(2, '0')}';
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
class _BeforeAfterComparisonSheet extends StatefulWidget {
  final UserReport report;
  final UserResponsiveData responsive;

  const _BeforeAfterComparisonSheet({
    required this.report,
    required this.responsive,
  });

  @override
  State<_BeforeAfterComparisonSheet> createState() => _BeforeAfterComparisonSheetState();
}

class _BeforeAfterComparisonSheetState extends State<_BeforeAfterComparisonSheet>
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
        color: UserDesign.surfacePure,
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
              color: UserDesign. textLight,
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets. symmetric(horizontal: r. padding),
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
                SizedBox(width: r.microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Before & After',
                        style: GoogleFonts. inter(
                          fontSize: r.headingXS,
                          fontWeight: FontWeight.w700,
                          color: UserDesign. textPrimary,
                        ),
                      ),
                      Text(
                        report.type,
                        style: GoogleFonts. inter(
                          fontSize: r.captionS,
                          color: UserDesign. textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(r. microPadding),
                    decoration: BoxDecoration(
                      color: UserDesign.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons. close_rounded, color: UserDesign.textSecondary, size: r.iconSize(20)),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: r.microPadding),

          // View Toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r. padding),
            child: Container(
              padding: EdgeInsets.all(r.nanoPadding),
              decoration: BoxDecoration(
                color: UserDesign. surfaceLight,
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
              child: Row(
                children: [
                  _buildViewToggleButton(r, 'Slider', Icons.compare_arrows_rounded, _showSlider, () {
                    setState(() => _showSlider = true);
                  }),
                  _buildViewToggleButton(r, 'Side by Side', Icons.view_column_rounded, !_showSlider, () {
                    setState(() => _showSlider = false);
                  }),
                ],
              ),
            ),
          ),

          SizedBox(height: r. padding),

          // Image Comparison
          Expanded(
            child: Padding(
              padding: EdgeInsets. symmetric(horizontal: r.padding),
              child: _showSlider
                  ? _buildSliderComparison(r, report)
                  : _buildSideBySideComparison(r, report),
            ),
          ),

          // Info Section
          _buildComparisonInfo(r, report),

          SizedBox(height: r.safePaddingBottom + r.padding),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(
      UserResponsiveData r,
      String label,
      IconData icon,
      bool isActive,
      VoidCallback onTap,
      ) {
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
              Icon(
                icon,
                size: r.iconSize(16),
                color: isActive ? Colors. white : UserDesign.textSecondary,
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: r. captionM,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors. white : UserDesign.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderComparison(UserResponsiveData r, UserReport report) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(r.largeBorderRadius),
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
                    errorBuilder: (_, __, ___) => Container(color: UserDesign.surfaceLight),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                        ),
                      ],
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors. black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
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
                    decoration: BoxDecoration(
                      color: UserDesign.error,
                      borderRadius: BorderRadius. circular(r.smallBorderRadius),
                    ),
                    child: Text(
                      'BEFORE',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // After Label
                Positioned(
                  right: r. microPadding,
                  top: r.microPadding,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: r.microPadding, vertical: r.nanoPadding),
                    decoration: BoxDecoration(
                      color: UserDesign.success,
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Text(
                      'AFTER',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
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
                decoration: BoxDecoration(
                  color: UserDesign.error,
                  borderRadius: BorderRadius. circular(r.smallBorderRadius),
                ),
                child: Text(
                  'BEFORE',
                  style: GoogleFonts.inter(
                    fontSize: r. captionXS,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
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
                padding: EdgeInsets. symmetric(horizontal: r.microPadding, vertical: r. nanoPadding),
                decoration: BoxDecoration(
                  color: UserDesign.success,
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Text(
                  'AFTER',
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: r.nanoPadding),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r. borderRadius),
                  child: Image. network(
                    report.afterImageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double. infinity,
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
      margin: EdgeInsets. symmetric(horizontal: r.padding),
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
            decoration: BoxDecoration(
              color: UserDesign.success,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: r.iconSize(20)),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cleanup Verified',
                  style: GoogleFonts.inter(
                    fontSize: r. bodyS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign. success,
                  ),
                ),
                if (report.cleanupDuration != null)
                  Text(
                    'Cleaned in ${_formatDuration(report.cleanupDuration!)} by ${report.workerName}',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: UserDesign. textSecondary,
                    ),
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
    return Rect.fromLTWH(0, 0, clipWidth, size. height);
  }

  @override
  bool shouldReclip(covariant _ImageClipper oldClipper) {
    return oldClipper.clipWidth != clipWidth;
  }
}

// ==================== FEEDBACK DIALOG (FR-U7) ====================
class _FeedbackDialog extends StatefulWidget {
  final UserReport report;
  final UserResponsiveData responsive;
  final Function(int rating, String feedback) onSubmit;

  const _FeedbackDialog({
    required this.report,
    required this.responsive,
    required this.onSubmit,
  });

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final List<String> _quickFeedback = [
    'Excellent work!',
    'Very thorough cleanup',
    'Quick response time',
    'Area looks great now',
    'Professional service',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
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
        backgroundColor: UserDesign.surfacePure,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: r.dimension(400)),
          padding: EdgeInsets.all(r.largePadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize. min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets. all(r.padding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.15),
                        const Color(0xFFFFD700).withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: r.iconSize(40),
                    color: const Color(0xFFFFD700),
                  ),
                ),

                SizedBox(height: r.padding),

                Text(
                  'Rate the Cleanup',
                  style: GoogleFonts. inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign. textPrimary,
                  ),
                ),

                SizedBox(height: r.nanoPadding),

                Text(
                  'How was ${widget.report.workerName}\'s work?',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    color: UserDesign. textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.largePadding),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                          padding: EdgeInsets. symmetric(horizontal: r.nanoPadding),
                          child: Icon(
                            _selectedRating >= starIndex
                                ?  Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: _selectedRating >= starIndex
                                ?  const Color(0xFFFFD700)
                                : UserDesign.textLight,
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
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight. w600,
                      color: _getRatingColor(_selectedRating),
                    ),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: r.microPadding,
                          vertical: r.nanoPadding,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ?  UserDesign.primaryTeal. withOpacity(0.15)
                              : UserDesign.surfaceLight,
                          borderRadius: BorderRadius.circular(r.pillBorderRadius),
                          border: Border.all(
                            color: isSelected
                                ?  UserDesign.primaryTeal
                                : UserDesign.textLight,
                          ),
                        ),
                        child: Text(
                          text,
                          style: GoogleFonts.inter(
                            fontSize: r. captionS,
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
                  decoration: BoxDecoration(
                    color: UserDesign.surfaceLight,
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    maxLength: 300,
                    style: GoogleFonts.inter(fontSize: r.bodyS, color: UserDesign.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add your feedback (optional)...',
                      hintStyle: GoogleFonts.inter(fontSize: r.captionM, color: UserDesign. textTertiary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r.borderRadius),
                        borderSide: BorderSide. none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius. circular(r.borderRadius),
                        borderSide: const BorderSide(color: UserDesign. primaryTeal, width: 2),
                      ),
                      contentPadding: EdgeInsets.all(r.microPadding),
                      counterStyle: GoogleFonts.inter(fontSize: r.captionXS, color: UserDesign.textTertiary),
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
                            border: Border.all(color: UserDesign. textLight),
                            borderRadius: BorderRadius. circular(r.borderRadius),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                fontSize: r. bodyS,
                                fontWeight: FontWeight. w600,
                                color: UserDesign.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: r.microPadding),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _selectedRating > 0
                            ? () => widget.onSubmit(_selectedRating, _feedbackController. text. trim())
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: r.buttonHeight,
                          decoration: BoxDecoration(
                            gradient: _selectedRating > 0
                                ?  const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            )
                                : null,
                            color: _selectedRating > 0 ? null : UserDesign.textLight,
                            borderRadius: BorderRadius.circular(r. borderRadius),
                            boxShadow: _selectedRating > 0
                                ?  UserDesign.glowShadow(const Color(0xFFFFD700))
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons. send_rounded,
                                size: r.iconSize(18),
                                color: _selectedRating > 0 ?  Colors.white : UserDesign.textTertiary,
                              ),
                              SizedBox(width: r.nanoPadding),
                              Text(
                                'Submit Feedback',
                                style: GoogleFonts.inter(
                                  fontSize: r.bodyS,
                                  fontWeight: FontWeight. w600,
                                  color: _selectedRating > 0 ? Colors. white : UserDesign.textTertiary,
                                ),
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
      case 3: return UserDesign. info;
      case 4: return UserDesign.success;
      case 5: return const Color(0xFFFFD700);
      default: return UserDesign.textTertiary;
    }
  }
}