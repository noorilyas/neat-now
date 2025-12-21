import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/employee_main_dashboard_viewmodel.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class MobileAppBar extends StatelessWidget {
  final EmployeeMainDashboardViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final VoidCallback onLogoTap;
  final VoidCallback onRefresh;
  final VoidCallback onNotificationsTap;
  final Animation<double> bounceAnimation;
  final Animation<double> rotateAnimation;
  final Animation<double> pulseAnimation;
  final Animation<double> logoAnimation;
  final bool showLogo;
  final bool isDesktop;

  const MobileAppBar({
    super.key,
    required this.viewModel,
    required this.responsive,
    required this.onLogoTap,
    required this.onRefresh,
    required this.onNotificationsTap,
    required this. bounceAnimation,
    required this.rotateAnimation,
    required this.pulseAnimation,
    required this.logoAnimation,
    this.showLogo = true,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final currentColor = viewModel.currentColor;
    final notificationCount = viewModel.notificationCount;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.horizontalPadding,
        vertical: r.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: r.cardShadow,
      ),
      child: isDesktop
          ? _buildDesktopAppBar(r, currentColor, notificationCount)
          : _buildMobileAppBar(r, currentColor, notificationCount),
    );
  }

  Widget _buildMobileAppBar(
      EmployeeResponsiveData r,
      Color currentColor,
      int notificationCount,
      ) {
    return Row(
      children: [
        // Logo
        if (showLogo && r.showAnyIcons) _buildLogo(r, currentColor),
        if (showLogo && r.showAnyIcons) SizedBox(width: r.microPadding),

        // Title
        Expanded(child: _buildTitle(r, currentColor)),

        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (viewModel.hasOverdueAlerts && r.showBadges)
              _buildOverdueIndicator(r),
            if (viewModel.isDemoMode && r.showAbbreviatedText)
              _buildDemoBadge(r),
            if (r.showAppBarActions) _buildRefreshButton(r, currentColor),
            _buildNotificationButton(r, currentColor, notificationCount),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar(
      EmployeeResponsiveData r,
      Color currentColor,
      int notificationCount,
      ) {
    return Row(
      children: [
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _getPageTitle(),
          style: GoogleFonts.poppins(
            fontSize: r.headingS,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        if (r.showSecondaryText)
          Text(
            _getPageSubtitle(),
            style: GoogleFonts.poppins(
              fontSize: r.captionM,
              color: viewModel.hasOverdueAlerts &&
                  viewModel.selectedIndex == 1
                  ? Colors.red
                  : currentColor,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    ),
    ),
    Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    if (viewModel.hasOverdueAlerts && r.showTrends)
    _buildDesktopOverdueIndicator(r),
    if (viewModel.isDemoMode && r.showAbbreviatedText) ...[
    _buildDemoBadge(r),
    SizedBox(width: r.microPadding),
    ],
    _buildRefreshButton(r, currentColor),
    SizedBox(width: r.nanoPadding),
    _buildNotificationButton(r, currentColor, notificationCount),
    ],
    ),
    ],
    );
  }

  Widget _buildLogo(EmployeeResponsiveData r, Color currentColor) {
    return GestureDetector(
      onTap: onLogoTap,
      child: AnimatedBuilder(
        animation: bounceAnimation,
        builder: (context, child) => Transform.scale(
          scale: bounceAnimation.value,
          child: child,
        ),
        child: ScaleTransition(
          scale:  logoAnimation,
          child: Container(
            width: r.avatarSize,
            height: r.avatarSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:  [currentColor, currentColor. withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: currentColor.withOpacity(0.3),
                  blurRadius:  8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.eco_rounded,
              color: Colors.white,
              size: r.iconSize(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(EmployeeResponsiveData r, Color currentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (r.showMinimalText)
          Text(
            r.adaptiveText(
              'Neat Now',
              nano: 'N',
              ultraMicro: 'NN',
              micro: 'NN',
              mini: 'Neat',
            ),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: r.headingXS,
              color: Colors.grey[900],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        if (r.showSecondaryText)
          AnimatedDefaultTextStyle(
            duration: r.animationDuration,
            style: GoogleFonts.poppins(
              fontSize: r.captionM,
              color: currentColor,
              fontWeight: FontWeight.w500,
            ),
            child: Text(viewModel.currentTab. label),
          ),
      ],
    );
  }

  Widget _buildOverdueIndicator(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: pulseAnimation.value,
          child: Container(
            margin: EdgeInsets.only(right: r.nanoPadding),
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              color: Colors.red. withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
              border: Border. all(
                color: Colors.red.withOpacity(
                  0.3 + (pulseAnimation.value - 1) * 2,
                ),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: r.iconSize(14),
                  color: Colors. red,
                ),
                if (r.showShortLabels) ...[
                  SizedBox(width: r.atomicPadding),
                  Text(
                    '${viewModel.overdueCount}',
                    style: GoogleFonts.poppins(
                      fontSize: r.captionS,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopOverdueIndicator(EmployeeResponsiveData r) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(right: r.microPadding),
          padding:  EdgeInsets.symmetric(
            horizontal: r.microPadding,
            vertical:  r.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: Colors. red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
            border:  Border.all(
              color: Colors.red.withOpacity(
                0.35 + (pulseAnimation.value - 1) * 2,
              ),
            ),
          ),
          child: Row(
            mainAxisSize:  MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: r.iconSize(16),
                color: Colors.red,
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                '${viewModel.overdueCount} overdue',
                style: GoogleFonts.poppins(
                  fontSize: r.captionM,
                  fontWeight: FontWeight.w600,
                  color: Colors. red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDemoBadge(EmployeeResponsiveData r) {
    return Container(
      margin: EdgeInsets.only(right: r.nanoPadding),
      padding: EdgeInsets.symmetric(
        horizontal: r.nanoPadding,
        vertical: r.atomicPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.pillBorderRadius),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_rounded,
            size: r.iconSize(12),
            color: Colors.orange,
          ),
          if (r.showIconLabels) ...[
            SizedBox(width: r.atomicPadding),
            Text(
              'Demo',
              style: GoogleFonts.poppins(
                fontSize: r.captionXS,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefreshButton(EmployeeResponsiveData r, Color color) {
    return AnimatedBuilder(
      animation: rotateAnimation,
      builder: (context, child) => Transform.rotate(
        angle: rotateAnimation.value,
        child: child,
      ),
      child: _buildIconButton(
        r,
        icon: Icons.refresh_rounded,
        onTap: onRefresh,
        color: color,
      ),
    );
  }

  Widget _buildNotificationButton(
      EmployeeResponsiveData r,
      Color color,
      int count,
      ) {
    final hasOverdue = viewModel.hasOverdueAlerts;
    final badgeColor = hasOverdue ? Colors.red : color;

    return Stack(
      children: [
        _buildIconButton(
          r,
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
          color: badgeColor,
        ),
        if (count > 0 && r.showBadges)
          Positioned(
            right: r.atomicPadding,
            top: r.atomicPadding,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin:  0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                padding: EdgeInsets.all(r.atomicPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasOverdue
                        ? [Colors.red, Colors.red.shade700]
                        : [badgeColor, badgeColor.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withOpacity(0.5),
                      blurRadius:  4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  minWidth: r.dimension(14),
                  minHeight: r.dimension(14),
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: GoogleFonts.poppins(
                      fontSize: r.captionXS,
                      fontWeight:  FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconButton(
      EmployeeResponsiveData r, {
        required IconData icon,
        required VoidCallback onTap,
        required Color color,
      }) {
    return SizedBox(
      width: r.buttonHeightSmall,
      height: r. buttonHeightSmall,
      child: Material(
        color: color. withOpacity(0.08),
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(r.smallBorderRadius),
          child: Icon(
            icon,
            size: r.iconSize(18),
            color: color,
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (viewModel.selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Reports';
      case 2:
        return 'Bins Map';
      case 3:
        return 'Analytics';
      case 4:
        return 'Leaderboard';
      case 5:
        return 'Profile';
      default:
        return 'Dashboard';
    }
  }

  String _getPageSubtitle() {
    switch (viewModel.selectedIndex) {
      case 0:
        return 'Welcome back!  Here\'s your overview';
      case 1:
        return viewModel.hasOverdueAlerts
            ?  '${viewModel.overdueCount} tasks overdue!'
            : 'Manage and track all reports';
      case 2:
        return 'View waste bins on the map';
      case 3:
        return 'Performance metrics and insights';
      case 4:
        return 'See top performers this month';
      case 5:
        return 'Manage your account settings';
      default:
        return '';
    }
  }
}