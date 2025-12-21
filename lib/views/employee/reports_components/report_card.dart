import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/reports_tab_viewmodel.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class ReportCard extends StatelessWidget {
  final ReportCardData reportCardData;
  final ReportsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final int index;
  final Animation<double> shimmerAnimation;
  final bool isHovered;
  final VoidCallback onTap;
  final VoidCallback onImageTap;
  final VoidCallback onNavigate;
  final Function(String) onUpdateStatus;
  final VoidCallback onResolve;
  final Function(bool) onHover;

  const ReportCard({
    super.key,
    required this.reportCardData,
    required this.viewModel,
    required this.responsive,
    required this.index,
    required this.shimmerAnimation,
    required this.isHovered,
    required this.onTap,
    required this.onImageTap,
    required this. onNavigate,
    required this.onUpdateStatus,
    required this.onResolve,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final report = reportCardData.report;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child:  Opacity(opacity: value, child: child),
        );
      },
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child:  AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(bottom: r.padding),
            transform: isHovered
                ? (Matrix4.identity()..translate(0.0, -4.0))
                : Matrix4.identity(),
            decoration: BoxDecoration(
              color: ReportsDesign.surfacePure,
              borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
              boxShadow: isHovered
                  ? ReportsDesign. hoverShadow
                  : ReportsDesign. elevatedShadow,
              border: isHovered
                  ? Border. all(
                color: ReportsDesign.primaryTeal. withOpacity(0.3),
                width: 1.5,
              )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                  _buildImageSection(r),
                Padding(
                  padding: EdgeInsets.all(r.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(r),
                      SizedBox(height: r.microPadding),
                      _buildCardDetails(r),
                      SizedBox(height: r.padding),
                      _buildCardActions(r),
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

  Widget _buildImageSection(EmployeeResponsiveData r) {
    final report = reportCardData.report;
    final statusColor = reportCardData.statusColor;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(r.extraLargeBorderRadius),
      ),
      child: Stack(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors:  [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
              begin:  Alignment.topCenter,
              end: Alignment. bottomCenter,
            ).createShader(bounds),
            blendMode: BlendMode.darken,
            child: Image.network(
              report.imageUrl! ,
              height: r.reportImageHeight,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: r.reportImageHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ReportsDesign.surfaceLight,
                      ReportsDesign.surfaceOverlay,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: r. dimension(40),
                    color: ReportsDesign.textTertiary,
                  ),
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
                      height: r. dimension(32),
                      child: CircularProgressIndicator(
                        value: loadingProgress. expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            :  null,
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
            child: _buildStatusBadge(r, statusColor),
          ),
          // View button
          Positioned(
            top: r.microPadding,
            right: r.microPadding,
            child: _buildGlassButton(
              r,
              icon: Icons.fullscreen_rounded,
              onTap: onImageTap,
            ),
          ),
          // Navigation button
          if (reportCardData.hasLocation)
            Positioned(
              bottom: r.microPadding,
              left: r.microPadding,
              child: _buildGlassButton(
                r,
                icon: Icons.navigation_rounded,
                label: r.showShortLabels ? 'Navigate' : null,
                color: ReportsDesign.info,
                onTap: onNavigate,
              ),
            ),
          // AI badge
          Positioned(
            bottom: r. microPadding,
            right: r.microPadding,
            child: _buildAIBadge(r),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EmployeeResponsiveData r, Color color) {
    final report = reportCardData.report;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical: r. nanoPadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(r.pillBorderRadius),
        boxShadow: ReportsDesign.glowShadow(color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            viewModel.getStatusIcon(report.status),
            color: Colors.white,
            size: r.iconSize(12),
          ),
          SizedBox(width: r.nanoPadding),
          Text(
            r.adaptiveText(
              viewModel.getStatusText(report. status),
              nano: viewModel.getStatusText(report.status)[0],
              micro: viewModel.getStatusText(report.status).substring(0, 4),
            ),
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight.w700,
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
            padding: EdgeInsets.symmetric(
              horizontal: label != null ? r.microPadding : r.nanoPadding,
              vertical: r.nanoPadding,
            ),
            decoration: BoxDecoration(
              color: bgColor. withOpacity(0.65),
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
              border: Border.all(color: Colors.white. withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color:  bgColor.withOpacity(0.3),
                  blurRadius:  8,
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
    fontWeight:  FontWeight.w600,
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
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.microPadding,
            vertical: r.nanoPadding,
          ),
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ReportsDesign.purple,
                ReportsDesign. purple.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
            boxShadow: ReportsDesign.glowShadow(ReportsDesign.purple),
          ),
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: r.iconSize(12),
                  ),
                  SizedBox(width: r. nanoPadding),
                  Text(
                    r.adaptiveText('AI Verified', nano: 'AI', micro: 'AI', mini: 'AI'),
                    style: GoogleFonts. inter(
                      fontSize: r.captionXS,
                      fontWeight: FontWeight.w700,
                      color: Colors. white,
                    ),
                  ),
                ],
              ),
              Positioned. fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: ReportsDesign.shimmerGradient(
                      shimmerAnimation. value,
                    ),
                    borderRadius: BorderRadius.circular(r.pillBorderRadius),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardHeader(EmployeeResponsiveData r) {
    final report = reportCardData.report;
    final statusColor = reportCardData.statusColor;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor. withOpacity(0.15),
                statusColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(r.borderRadius),
          ),
          child: Icon(
            viewModel.getWasteIcon(report.type),
            color: statusColor,
            size: r. iconSize(22),
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
                  fontSize: r.bodyM,
                  fontWeight: FontWeight.w700,
                  color: ReportsDesign.textPrimary,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Task #${report.id}',
                style: GoogleFonts.inter(
                  fontSize: r. captionS,
                  color: ReportsDesign.textTertiary,
                ),
              ),
            ],
          ),
        ),
        _buildTimeBadge(r),
      ],
    );
  }

  Widget _buildTimeBadge(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical: r.nanoPadding,
      ),
      decoration: BoxDecoration(
        color: reportCardData.isRecent
            ? ReportsDesign.primaryTeal. withOpacity(0.1)
            : ReportsDesign.surfaceLight,
        borderRadius:  BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: r.iconSize(12),
            color: reportCardData.isRecent
                ? ReportsDesign.primaryTeal
                : ReportsDesign.textTertiary,
          ),
          SizedBox(width: r. atomicPadding),
          Text(
            reportCardData.timeAgo,
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              fontWeight: FontWeight.w600,
              color: reportCardData.isRecent
                  ? ReportsDesign.primaryTeal
                  : ReportsDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDetails(EmployeeResponsiveData r) {
    final report = reportCardData.report;

    return Column(
      children: [
      _buildDetailRow(
      r,
      Icons.location_on_rounded,
      report.location,
      ReportsDesign.error,
    ),
    SizedBox(height: r.nanoPadding),
    _buildDetailRow(
    r,
    Icons.person_rounded,
    'Reported by ${report.userName}',
    ReportsDesign.info,
    ),
    if (report.description != null && report.description!.isNotEmpty) ...[
    SizedBox(height: r.nanoPadding),
    _buildDetailRow(
    r,
    Icons.notes_rounded,
    report.description!,
    ReportsDesign.textSecondary,
    ),
    ],
    if (reportCardData.hasLocation) ...[
    SizedBox(height:  r.microPadding),
    _buildNavigationRow(r),
    ],
    ],
    );
  }

  Widget _buildDetailRow(
      EmployeeResponsiveData r,
      IconData icon,
      String text,
      Color iconColor,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: r.iconSize(14),
          color: iconColor. withOpacity(0.7),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: Text(
            text,
            style:  GoogleFonts.inter(
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

  Widget _buildNavigationRow(EmployeeResponsiveData r) {
    return GestureDetector(
      onTap: onNavigate,
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
              decoration:  BoxDecoration(
                color:  ReportsDesign.info,
                borderRadius: BorderRadius. circular(r.smallBorderRadius),
              ),
              child: Icon(
                Icons.navigation_rounded,
                size: r.iconSize(14),
                color: Colors.white,
              ),
            ),
            SizedBox(width: r.microPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigate to Location',
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight.w600,
                      color: ReportsDesign.info,
                    ),
                  ),
                  Text(
                    'Tap to open directions',
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      color: ReportsDesign.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: ReportsDesign.info,
              size: r.iconSize(20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardActions(EmployeeResponsiveData r) {
    final report = reportCardData.report;

    if (report.status == 'resolved') {
      return _buildCompletedSection(r);
    }
    if (report.status == 'in-progress') {
      return _buildInProgressActions(r);
    }
    return _buildPendingActions(r);
  }

  Widget _buildCompletedSection(EmployeeResponsiveData r) {
    final report = reportCardData.report;

    return Container(
      padding:  EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ReportsDesign.successLight,
            ReportsDesign. successLight.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: const BoxDecoration(
              color:  ReportsDesign.success,
              shape: BoxShape.circle,
            ),
            child: Icon(
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
                  'Task Completed',
                  style: GoogleFonts.inter(
                    fontSize: r.captionL,
                    fontWeight: FontWeight.w700,
                    color: ReportsDesign.success,
                  ),
                ),
                if (report.resolvedAt != null && r.showSecondaryText)
                  Text(
                    'Completed ${viewModel.formatDate(report.resolvedAt! )}',
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      color: ReportsDesign.success. withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: ReportsDesign. success,
              padding: EdgeInsets.symmetric(horizontal: r.microPadding),
              minimumSize: Size. zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'View',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressActions(EmployeeResponsiveData r) {
    return Row(
      children: [
        if (reportCardData.hasLocation)
          Expanded(
            child: _buildActionButton(
              r,
              icon: Icons.navigation_rounded,
              label: r.adaptiveText(
                'Navigate',
                nano: '→',
                micro: 'Nav',
                mini: 'Navigate',
              ),
              color:  ReportsDesign.info,
              isOutlined: true,
              onTap: onNavigate,
            ),
          ),
        if (reportCardData.hasLocation) SizedBox(width: r.microPadding),
        Expanded(
          flex: reportCardData.hasLocation ? 1 : 2,
          child: _buildActionButton(
            r,
            icon: Icons.camera_alt_rounded,
            label: r.adaptiveText(
              'Complete',
              nano: '✓',
              micro: 'Done',
              mini: 'Complete',
            ),
            color:  ReportsDesign.primaryTeal,
            onTap: onResolve,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingActions(EmployeeResponsiveData r) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            r,
            icon: Icons.play_arrow_rounded,
            label: r.adaptiveText(
              'Start',
              nano: '▶',
              micro: 'Start',
              mini: 'Start',
            ),
            color: ReportsDesign.info,
            onTap: () => onUpdateStatus('in-progress'),
          ),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: _buildActionButton(
            r,
            icon: Icons.check_circle_rounded,
            label: r.adaptiveText(
              'Resolve',
              nano: '✓',
              micro: 'Done',
              mini: 'Resolve',
            ),
            color: ReportsDesign.primaryTeal,
            onTap: onResolve,
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
      color: isOutlined ?  Colors.transparent : color,
      borderRadius: BorderRadius.circular(r.borderRadius),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(r.borderRadius),
        child: Container(
          height: r.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r.borderRadius),
            border: isOutlined ?  Border.all(color: color, width: 1.5) : null,
            boxShadow: isOutlined ?  null : ReportsDesign.glowShadow(color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: r.iconSize(18),
                color: isOutlined ? color : Colors.white,
              ),
              if (r.showIconLabels) ...[
                SizedBox(width: r.nanoPadding),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: r. captionM,
                      fontWeight: FontWeight.w600,
                      color: isOutlined ? color :  Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}