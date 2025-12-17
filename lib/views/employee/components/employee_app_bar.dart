import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neat_now/viewmodels/employee/employee_dashboard_viewmodel.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

class EmployeeAppBar extends StatelessWidget {
  final EmployeeDashboardViewModel viewModel;
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

  const EmployeeAppBar({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.onLogoTap,
    required this.onRefresh,
    required this.onNotificationsTap,
    required this.bounceAnimation,
    required this.rotateAnimation,
    required this. pulseAnimation,
    required this.logoAnimation,
    this.showLogo = true,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = viewModel.currentColor;
    final notificationCount = viewModel.notificationCount;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.horizontalPadding,
        vertical: responsive.verticalPadding,
      ),
      decoration: BoxDecoration(
        color:  Colors.white,
        boxShadow: responsive.cardShadow,
      ),
      child: isDesktop
          ? _buildDesktopAppBar(currentColor, notificationCount)
          : _buildMobileAppBar(currentColor, notificationCount),
    );
  }

  Widget _buildMobileAppBar(Color currentColor, int notificationCount) {
    return Row(
      children: [
        // Logo
        if (showLogo && responsive.showAnyIcons)
          GestureDetector(
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
                  width: responsive. avatarSize,
                  height: responsive. avatarSize,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        currentColor,
                        currentColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment. bottomRight,
                    ),
                    borderRadius: BorderRadius. circular(
                      responsive.smallBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: currentColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: responsive.iconSize(16),
                  ),
                ),
              ),
            ),
          ),
        SizedBox(width: responsive.microPadding),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (responsive.showMinimalText)
                Text(
                  responsive.adaptiveText(
                    'Neat Now',
                    nano: 'N',
                    ultraMicro: 'NN',
                    micro: 'NN',
                    mini: 'Neat',
                  ),
                  style: GoogleFonts. poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.headingXS,
                    color: Colors. grey[900],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              if (responsive.showSecondaryText)
                AnimatedDefaultTextStyle(
                  duration: responsive.animationDuration,
                  style: GoogleFonts.poppins(
                    fontSize: responsive.captionM,
                    color: currentColor,
                    fontWeight: FontWeight.w500,
                  ),
                  child: Text(viewModel.currentTab. label),
                ),
            ],
          ),
        ),

        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (viewModel.hasOverdueAlerts && responsive.showBadges)
              _buildPulsingOverdueIndicator(),
            if (viewModel.isDemoMode && responsive.showAbbreviatedText)
              _buildDemoBadge(),
            if (responsive.showAppBarActions)
              _buildRotatingRefreshButton(currentColor),
            _buildNotificationButton(currentColor, notificationCount),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopAppBar(Color currentColor, int notificationCount) {
    return Row(
      children:  [
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedDefaultTextStyle(
          duration: responsive.animationDuration,
          style: GoogleFonts.poppins(
            fontSize:  responsive.headingS,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
          child: Text(viewModel.getPageTitle()),
        ),
        if (responsive.showSecondaryText)
          AnimatedDefaultTextStyle(
            duration: responsive.animationDuration,
            style:  GoogleFonts.poppins(
              fontSize: responsive. captionM,
              color: viewModel.hasOverdueAlerts &&
                  viewModel.selectedIndex == 1
                  ? Colors.red
                  : currentColor,
              fontWeight: FontWeight.w500,
            ),
            child: Text(viewModel.getPageSubtitle()),
          ),
      ],
    ),
    ),

    // Actions
    Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    if (viewModel.hasOverdueAlerts && responsive.showTrends)
    _buildAppBarOverdueIndicator(),
    if (viewModel.isDemoMode && responsive.showAbbreviatedText) ...[
    _buildDemoBadge(),
    SizedBox(width: responsive.microPadding),
    ],
    _buildRotatingRefreshButton(currentColor),
    SizedBox(width: responsive.nanoPadding),
    _buildNotificationButton(currentColor, notificationCount),
    ],
    ),
    ],
    );
  }

  Widget _buildPulsingOverdueIndicator() {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
            scale: pulseAnimation.value,
            child: Container(
                margin: EdgeInsets.only(right: responsive.nanoPadding),
                padding: EdgeInsets.all(responsive.nanoPadding),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    responsive.smallBorderRadius,
                  ),
                  border: Border.all(
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
                  size: responsive.iconSize(14),
                  color: Colors. red,
                ),
                if (responsive.showShortLabels) ...[
            SizedBox(width: responsive.atomicPadding),
        Text(
        '${viewModel.overdueCount}',
        style: GoogleFonts.poppins(
        fontSize: responsive.captionS,
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

  Widget _buildAppBarOverdueIndicator() {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.only(right: responsive.microPadding),
          padding:  EdgeInsets.symmetric(
            horizontal: responsive.microPadding,
            vertical:  responsive.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: Colors. red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(
              responsive. pillBorderRadius,
            ),
            border: Border.all(
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
                size: responsive.iconSize(16),
                color: Colors.red,
              ),
              SizedBox(width: responsive.nanoPadding),
              Text(
                '${viewModel.overdueCount} overdue',
                style: GoogleFonts.poppins(
                  fontSize: responsive.captionM,
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

  Widget _buildDemoBadge() {
    return Container(
      margin: EdgeInsets.only(right: responsive.nanoPadding),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.nanoPadding,
        vertical:  responsive.atomicPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.pillBorderRadius),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.science_rounded,
            size: responsive.iconSize(12),
            color: Colors.orange,
          ),
          if (responsive.showIconLabels) ...[
            SizedBox(width: responsive.atomicPadding),
            Text(
              'Demo',
              style: GoogleFonts.poppins(
                fontSize: responsive.captionXS,
                fontWeight: FontWeight.w600,
                color: Colors. orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRotatingRefreshButton(Color color) {
    return AnimatedBuilder(
      animation: rotateAnimation,
      builder: (context, child) => Transform.rotate(
        angle: rotateAnimation.value,
        child: child,
      ),
      child: _buildIconButton(
        icon: Icons. refresh_rounded,
        onTap: onRefresh,
        color: color,
      ),
    );
  }

  Widget _buildNotificationButton(Color color, int count) {
    final hasOverdue = viewModel.hasOverdueAlerts;
    final badgeColor = hasOverdue ?  Colors.red : color;

    return Stack(
      children: [
        _buildIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
          color: badgeColor,
        ),
        if (count > 0 && responsive.showBadges)
          Positioned(
            right: responsive.atomicPadding,
            top: responsive.atomicPadding,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: child,
              ),
              child: Container(
                padding: EdgeInsets.all(responsive.atomicPadding),
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
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  minWidth: responsive.dimension(14),
                  minHeight: responsive.dimension(14),
                ),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: GoogleFonts.poppins(
                      fontSize: responsive.captionXS,
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return SizedBox(
      width: responsive.buttonHeightSmall,
      height: responsive. buttonHeightSmall,
      child: Material(
        color: color. withOpacity(0.08),
        borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
          child: Icon(
            icon,
            size: responsive.iconSize(18),
            color: color,
          ),
        ),
      ),
    );
  }
}