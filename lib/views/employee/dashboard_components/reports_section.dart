import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/dashboard_tab_viewmodel.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/employee_dashboard_tab.dart';

class DashboardReportsSection extends StatelessWidget {
  final DashboardTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Animation<double> shimmerAnimation;
  final Animation<double> pulseAnimation;
  final Function(int) onNavigateToTab;

  const DashboardReportsSection({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.shimmerAnimation,
    required this. pulseAnimation,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(r),
        SizedBox(height: r.microPadding),
        _buildReportsContent(r),
      ],
    );
  }

  Widget _buildSectionHeader(EmployeeResponsiveData r) {
    final iconColor = viewModel.overdueCount > 0
        ? DesignSystem.error
        : DesignSystem. primaryTeal;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.nanoPadding),
          decoration:  BoxDecoration(
            color:  iconColor. withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Icon(
            Icons.assignment_turned_in_rounded,
            size: r.iconSize(18),
            color: iconColor,
          ),
        ),
        SizedBox(width: r. microPadding),
        Expanded(
          child: Text(
            'Active Reports',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w700,
              color: DesignSystem.textPrimary,
            ),
          ),
        ),
        _buildViewAllButton(r),
      ],
    );
  }

  Widget _buildViewAllButton(EmployeeResponsiveData r) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:  () {
          HapticFeedback.lightImpact();
          onNavigateToTab(1);
        },
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.microPadding,
            vertical:  r.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: DesignSystem.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r.adaptiveText('View All', nano: '→', micro: 'All'),
                style: GoogleFonts.inter(
                  fontSize: r.captionS,
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.primaryTeal,
                ),
              ),
              SizedBox(width: r.atomicPadding),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: r.iconSize(10),
                color: DesignSystem.primaryTeal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsContent(EmployeeResponsiveData r) {
    if (viewModel.activeReports.isEmpty) {
      return _buildNoReportsCard(r);
    }

    final maxToShow = r.responsive<int>(
      base: 3,
      nano: 1,
      micro: 2,
      mini: 2,
      tiny: 3,
    );

    final displayReports = viewModel.getDisplayReports(maxToShow);
    final remainingCount = viewModel.getRemainingReportsCount(maxToShow);

    return Column(
      children: [
        ... displayReports.asMap().entries.map((entry) {
          return _buildReportCard(r, entry.value, entry.key);
        }),
        if (remainingCount > 0) _buildShowMoreButton(r, remainingCount),
      ],
    );
  }

  Widget _buildReportCard(EmployeeResponsiveData r, Report report, int index) {
    final isOverdue = report.isOverdue;
    final daysSinceAccepted = report.daysSinceAccepted;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin:  0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onNavigateToTab(1);
          },
          child:  Container(
              margin: EdgeInsets.only(bottom: r.microPadding),
              padding: EdgeInsets.all(r.padding),
              decoration: BoxDecoration(
                color: isOverdue
                    ? DesignSystem.error. withOpacity(0.05)
                    : DesignSystem.surfaceWhite,
                borderRadius: BorderRadius. circular(r.largeBorderRadius),
                boxShadow: isOverdue
                    ? DesignSystem.glowShadow(
                  DesignSystem.error. withOpacity(0.3),
                )
                    : DesignSystem.softShadow,
                border: Border.all(
                  color: isOverdue
                      ? DesignSystem.error. withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  width: isOverdue ? 2 : 1,
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment. start,
                  children: [
                  // Header row
                  Row(
                  children: [
                  _buildStatusIndicator(r, report, isOverdue),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.displayTitle,
                      style: GoogleFonts.inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight.w700,
                        color: isOverdue
                            ? DesignSystem. error
                            : DesignSystem.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (r.showSecondaryText)
                      Row(
                        children: [
                          _buildWasteTypeChip(r, report. type),
                          SizedBox(width: r.nanoPadding),
                          Icon(
                            Icons.location_on_outlined,
                            size: r.iconSize(12),
                            color: DesignSystem.textTertiary,
                          ),
                          SizedBox(width: r. atomicPadding),
                          Expanded(
                            child: Text(
                              report.location,
                              style: GoogleFonts.inter(
                                fontSize: r.captionS,
                                color: DesignSystem.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow. ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (isOverdue)
          _buildOverdueBadge(r, daysSinceAccepted)
      else
      Icon(
      Icons.chevron_right_rounded,
      size: r.iconSize(20),
      color: DesignSystem.textTertiary,
    ),
    ],
    ),
    // Footer with time and status
    if (r.showDetailedContent) ...[
    SizedBox(height: r.microPadding),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Row(
    children: [
    Icon(
    Icons.schedule_rounded,
    size:  r.iconSize(14),
    color: isOverdue
    ? DesignSystem.error
        :  DesignSystem.textTertiary,
    ),
    SizedBox(width:  r.atomicPadding),
    Text(
    isOverdue
    ? 'Overdue by $daysSinceAccepted days'
        : daysSinceAccepted > 0
    ? 'Accepted ${daysSinceAccepted}d ago'
        :  'Accepted today',
    style: GoogleFonts.inter(
    fontSize: r.captionS,
    fontWeight: isOverdue
    ? FontWeight.w600
        : FontWeight. w500,
    color:  isOverdue
    ? DesignSystem.error
        :  DesignSystem.textSecondary,
    ),
    ),
    ],
    ),
    _buildStatusChip(r, report.status),
    ],
    ),
    ],
    ],
    ),
    ),
    ),
    );
  }

  Widget _buildStatusIndicator(
      EmployeeResponsiveData r,
      Report report,
      bool isOverdue,
      ) {
    if (isOverdue) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Container(
            width: r.dimension(12),
            height: r.dimension(12),
            decoration: BoxDecoration(
              color: DesignSystem.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.error
                      .withOpacity(0.4 * pulseAnimation.value),
                  blurRadius: 8 * pulseAnimation.value,
                  spreadRadius: 2 * (pulseAnimation.value - 1),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      width: r. dimension(10),
      height: r.dimension(10),
      decoration: BoxDecoration(
        color: report.statusColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildWasteTypeChip(EmployeeResponsiveData r, String type) {
    final color = viewModel.getWasteTypeColor(type);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.nanoPadding,
        vertical:  r.atomicPadding,
      ),
      decoration: BoxDecoration(
        color: color. withOpacity(0.1),
        borderRadius: BorderRadius. circular(r.smallBorderRadius),
      ),
      child: Text(
        type,
        style: GoogleFonts.inter(
          fontSize: r.captionXS,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOverdueBadge(EmployeeResponsiveData r, int days) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical:  r.nanoPadding,
      ),
      decoration: BoxDecoration(
        color: DesignSystem.error,
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            size: r.iconSize(12),
            color: Colors.white,
          ),
          SizedBox(width: r. atomicPadding),
          Text(
            '${days}d',
            style: GoogleFonts.inter(
              fontSize: r.captionS,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(EmployeeResponsiveData r, String status) {
    final color = viewModel. getStatusColor(status);
    final label = viewModel.formatStatus(status);

    return Container(
      padding: EdgeInsets. symmetric(
        horizontal: r. nanoPadding,
        vertical:  r.atomicPadding,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Text(
        label,
        style: GoogleFonts. inter(
          fontSize: r. captionXS,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildShimmerReportCards(EmployeeResponsiveData r) {
    return Column(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: shimmerAnimation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: r. microPadding),
              height: r.listTileHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius. circular(r.largeBorderRadius),
                gradient: LinearGradient(
                  begin:  Alignment(-1.0 + shimmerAnimation.value, 0),
                  end: Alignment(shimmerAnimation.value, 0),
                  colors: [
                    Colors.grey[200]! ,
                    Colors.grey[100]!,
                    Colors.grey[200]!,
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildNoReportsCard(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.largePadding),
      decoration: BoxDecoration(
        color:  DesignSystem.surfaceLight,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border. all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(r.padding),
            decoration: BoxDecoration(
              color: DesignSystem.primaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: r.iconSize(40),
              color: DesignSystem.primaryTeal,
            ),
          ),
          SizedBox(height: r.microPadding),
          Text(
            'All caught up!',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w700,
              color: DesignSystem.textPrimary,
            ),
          ),
          if (r.showSecondaryText) ...[
            SizedBox(height: r.nanoPadding),
            Text(
              'No active tasks at the moment',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShowMoreButton(EmployeeResponsiveData r, int count) {
    return Padding(
      padding: EdgeInsets.only(top: r.microPadding),
      child: TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onNavigateToTab(1);
        },
        style: TextButton.styleFrom(
          foregroundColor: DesignSystem.primaryTeal,
          padding: EdgeInsets.symmetric(
            horizontal: r.padding,
            vertical: r.microPadding,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View $count more tasks',
              style: GoogleFonts.inter(
                fontSize: r.captionL,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: r.nanoPadding),
            Icon(Icons.arrow_forward_rounded, size: r.iconSize(16)),
          ],
        ),
      ),
    );
  }
}