import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/models/user/user_report_model.dart';
import 'package:neat_now/viewmodels/user/user_reports_viewmodel.dart';

class ReportDetailSheet extends StatefulWidget {
  final UserReportModel report;
  final UserResponsiveData responsive;
  final UserReportsViewModel viewModel;
  final VoidCallback onRate;
  final VoidCallback onViewImages;

  const ReportDetailSheet({
    super.key,
    required this. report,
    required this.responsive,
    required this.viewModel,
    required this.onRate,
    required this.onViewImages,
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
      parent:  _animController,
      curve:  Curves.easeOutCubic,
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
    final vm = widget.viewModel;
    final color = vm.getStatusColor(report.status);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: UserDesign.surfacePure,
        borderRadius: BorderRadius.vertical(
          top: Radius. circular(r.extraLargeBorderRadius),
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
    padding: EdgeInsets.all(r.padding),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Header
    _buildHeader(r, report, color, vm),

    SizedBox(height: r.padding),

    // Before/After Images Section
    if (report.isResolved && report.hasAfterImage)
    _buildBeforeAfterSection(r, report)
    else if (report.beforeImageUrl != null)
    _buildBeforeImageSection(r, report),

    SizedBox(height: r.padding),

    // Status Timeline
    _buildStatusTimeline(r, report, vm),

    SizedBox(height: r.padding),

    // Details Cards
    _buildInfoCard(r, Icons.category_rounded, 'Waste Type',
    report.type, UserDesign.purple),
    _buildInfoCard(r, Icons.location_on_rounded, 'Location',
    report.location, UserDesign.error),
    if (report.description != null &&
    report.description!. isNotEmpty)
    _buildInfoCard(
    r,
    Icons.description_rounded,
    'Description',
    report.description!,
    UserDesign.info,
    isMultiLine: true),
    _buildInfoCard(
    r,
    Icons.schedule_rounded,
    'Submitted',
    vm.formatDateTime(report.submittedAt),
    UserDesign.warning),

    // Worker Info
    if (report.workerName != null)
    _buildWorkerCard(r, report),

    // Resolved Info
    if (report.isResolved && report.resolvedAt != null)
    _buildResolvedCard(r, report, vm),

    // Rating Section
    if (report.isResolved) ...[
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

  Widget _buildHeader(UserResponsiveData r, UserReportModel report, Color color,
      UserReportsViewModel vm) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration:  BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(r.borderRadius),
            boxShadow: UserDesign.glowShadow(color),
          ),
          child: Icon(
            vm.getWasteIcon(report.type),
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
                  color: UserDesign.textPrimary,
                ),
              ),
              Text(
                'Report #${report.id}',
                style: GoogleFonts.inter(
                  fontSize: r. captionS,
                  color: UserDesign.textTertiary,
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
            color: color. withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: r.atomicPadding),
              Text(
                vm.getStatusLabel(report.status),
                style: GoogleFonts.inter(
                  fontSize: r.captionS,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBeforeAfterSection(UserResponsiveData r, UserReportModel report) {
    return GestureDetector(
      onTap: widget.onViewImages,
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              UserDesign.success.withOpacity(0.08),
              UserDesign.success.withOpacity(0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(color: UserDesign.success. withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment:  CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.nanoPadding),
                  decoration: BoxDecoration(
                    color: UserDesign.success,
                    borderRadius: BorderRadius.circular(r.smallBorderRadius),
                  ),
                  child: Icon(
                    Icons.compare_rounded,
                    color: Colors.white,
                    size: r.iconSize(16),
                  ),
                ),
                SizedBox(width:  r.microPadding),
                Text(
                  'Before & After Cleanup',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w700,
                    color: UserDesign.success,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.zoom_in_rounded,
                  color:  UserDesign.success,
                  size: r.iconSize(20),
                ),
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
                          errorBuilder: (_, __, ___) =>
                              _buildImagePlaceholder(r, r.dimension(120)),
                        ),
                        Positioned(
                          top: r.nanoPadding,
                          left: r.nanoPadding,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: r. microPadding,
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
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.microPadding),
                  child: Container(
                    padding: EdgeInsets.all(r.nanoPadding),
                    decoration:  BoxDecoration(
                      color: UserDesign.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: r.iconSize(16),
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(r. borderRadius),
                    child:  Stack(
                      children: [
                        Image.network(
                          report.afterImageUrl ??  '',
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
                              vertical: r.atomicPadding,
                            ),
                            decoration: BoxDecoration(
                              color: UserDesign.success,
                              borderRadius:
                              BorderRadius.circular(r.smallBorderRadius),
                            ),
                            child: Text(
                              'AFTER',
                              style: GoogleFonts.inter(
                                fontSize: r. captionXS - 1,
                                fontWeight: FontWeight.w700,
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
            SizedBox(height: r. microPadding),
            Center(
              child: Text(
                'Tap to view full comparison',
                style: GoogleFonts.inter(
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

  Widget _buildBeforeImageSection(
      UserResponsiveData r, UserReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_camera_rounded,
              size: r.iconSize(16),
              color: UserDesign.warning,
            ),
            SizedBox(width: r.nanoPadding),
            Text(
              'Reported Image',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                fontWeight: FontWeight.w600,
                color: UserDesign.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: r.nanoPadding),
        ClipRRect(
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          child: Image.network(
            report.beforeImageUrl! ,
            height: r.dimension(180),
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _buildImagePlaceholder(r, r.dimension(180)),
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
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_rounded,
              size: r.iconSize(32),
              color: UserDesign. textTertiary,
            ),
            SizedBox(height: r. nanoPadding),
            Text(
              'Image unavailable',
              style: GoogleFonts.inter(
                fontSize: r.captionS,
                color: UserDesign.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(
      UserResponsiveData r, UserReportModel report, UserReportsViewModel vm) {
    final steps = vm.getTimelineSteps(report);

    return Container(
      padding:  EdgeInsets.all(r. padding),
      decoration: BoxDecoration(
        color: UserDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                size: r.iconSize(16),
                color: UserDesign.info,
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                'Status Timeline',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight.w600,
                  color: UserDesign. textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          ...steps.asMap().entries.map((entry) {
            final index = entry. key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: r.dimension(28),
                      height: r. dimension(28),
                      decoration: BoxDecoration(
                        gradient: step.isCompleted
                            ? UserDesign.successGradient
                            : null,
                        color: step.isCompleted
                            ?  null
                            : UserDesign. surfaceOverlay,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.icon,
                        size: r.iconSize(14),
                        color: step. isCompleted
                            ? Colors.white
                            : UserDesign.textTertiary,
                      ),
                    ),
                    if (! isLast)
                      Container(
                        width: 2,
                        height: r. dimension(24),
                        color: step.isCompleted
                            ?  UserDesign.success
                            : UserDesign. textLight,
                      ),
                  ],
                ),
                SizedBox(width: r.microPadding),
                Expanded(
                  child:  Padding(
                    padding:
                    EdgeInsets.only(bottom: isLast ? 0 : r.microPadding),
                    child: Column(
                      crossAxisAlignment:  CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: GoogleFonts.inter(
                            fontSize: r.captionM,
                            fontWeight: step.isCompleted
                                ?  FontWeight.w600
                                : FontWeight.w500,
                            color: step.isCompleted
                                ? UserDesign.textPrimary
                                : UserDesign.textTertiary,
                          ),
                        ),
                        if (step.timestamp != null && step.isCompleted)
                          Text(
                            vm.formatDateTime(step.timestamp! ),
                            style: GoogleFonts.inter(
                              fontSize: r.captionXS,
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

  Widget _buildInfoCard(UserResponsiveData r, IconData icon, String label,
      String value, Color color,
      {bool isMultiLine = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: r.microPadding),
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: UserDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Row(
        crossAxisAlignment:
        isMultiLine ? CrossAxisAlignment. start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius. circular(r.smallBorderRadius),
            ),
            child: Icon(icon, color: color, size: r.iconSize(16)),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:  GoogleFonts.inter(
                    fontSize: r.captionXS,
                    color: UserDesign.textTertiary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts. inter(
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w600,
                    color: UserDesign.textPrimary,
                  ),
                  maxLines: isMultiLine ? null : 2,
                  overflow: isMultiLine ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(UserResponsiveData r, UserReportModel report) {
    return Container(
      margin: EdgeInsets.only(bottom: r.microPadding),
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:  [
            UserDesign.info.withOpacity(0.08),
            UserDesign.info.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: UserDesign.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.engineering_rounded,
                size: r.iconSize(16),
                color:  UserDesign.info,
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                'Assigned Worker',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight.w600,
                  color: UserDesign.info,
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
                child: Center(
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
              SizedBox(width: r.microPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.workerName! ,
                      style: GoogleFonts.inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight.w600,
                        color: UserDesign.textPrimary,
                      ),
                    ),
                    if (report.workerPhone != null)
                      Text(
                        report.workerPhone!,
                        style: GoogleFonts. inter(
                          fontSize: r.captionS,
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
                    final url = Uri.parse('tel:${report.workerPhone}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(r.microPadding),
                    decoration: BoxDecoration(
                      color: UserDesign.success,
                      borderRadius: BorderRadius.circular(r.borderRadius),
                    ),
                    child: Icon(
                      Icons.phone_rounded,
                      color: Colors.white,
                      size: r.iconSize(18),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResolvedCard(
      UserResponsiveData r, UserReportModel report, UserReportsViewModel vm) {
    return Container(
      margin: EdgeInsets. only(bottom: r.microPadding),
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UserDesign.success.withOpacity(0.08),
            UserDesign.success.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border. all(color: UserDesign. success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              color: UserDesign.success,
              borderRadius: BorderRadius. circular(r.smallBorderRadius),
            ),
            child:  Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: r.iconSize(14),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cleanup Completed',
                  style:  GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w700,
                    color: UserDesign.success,
                  ),
                ),
                Text(
                  vm.formatDateTime(report.resolvedAt! ),
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
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r. nanoPadding,
              ),
              decoration: BoxDecoration(
                color: UserDesign. success. withOpacity(0.15),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_rounded,
                    size: r.iconSize(12),
                    color: UserDesign.success,
                  ),
                  SizedBox(width: r.atomicPadding),
                  Text(
                    vm.formatDuration(report.cleanupDuration!),
                    style:  GoogleFonts.inter(
                      fontSize: r.captionXS,
                      fontWeight: FontWeight.w600,
                      color: UserDesign.success,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(UserResponsiveData r, UserReportModel report) {
    if (report.rating != null) {
      return Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFD700).withOpacity(0.1),
              const Color(0xFFFFD700).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
        ),
        child: Column(
          children: [
        Row(
        children: [
        Icon(
        Icons.star_rounded,
          color: const Color(0xFFFFD700),
          size: r. iconSize(20),
        ),
        SizedBox(width: r.nanoPadding),
        Text(
          'Your Rating',
          style: GoogleFonts.inter(
            fontSize: r.bodyS,
            fontWeight:  FontWeight.w700,
            color: const Color(0xFFD97706),
          ),
        ),
        const Spacer(),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < report.rating!
                  ? Icons.star_rounded
                  : Icons.star_outline_rounded,
              color:  const Color(0xFFFFD700),
              size: r.iconSize(20),
            );
          }),
        ),
        ],
      ),
    if (report.feedback != null && report.feedback!.isNotEmpty) ...[
    SizedBox(height: r.microPadding),
    Container(
    width: double.infinity,
    padding: EdgeInsets.all(r.microPadding),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(r.borderRadius),
    ),
    child:  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Your Feedback',
    style:  GoogleFonts.inter(
    fontSize: r.captionXS,
    color: UserDesign.textTertiary,
    ),
    ),
    SizedBox(height: r.atomicPadding),
    Text(
    report.feedback!,
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: UserDesign.textSecondary,
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
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.star_rounded,
    color: Colors.white,
    size: r.iconSize(22),
    ),
    SizedBox(width: r.nanoPadding),
    Text(
    'Rate & Leave Feedback',
    style: GoogleFonts.inter(
    fontSize: r.bodyS,
    fontWeight: FontWeight. w700,
    color:  Colors.white,
    ),
    ),
    ],
    ),
    ),
    );
    }
  }
}