import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/employee_main_dashboard_viewmodel.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class DesktopSideNav extends StatelessWidget {
  final EmployeeMainDashboardViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final bool isExpanded;
  final Function(int) onTabSelected;
  final VoidCallback onToggle;
  final VoidCallback onLogout;
  final Animation<double> bounceAnimation;
  final Animation<double> pulseAnimation;
  final Animation<double> logoAnimation;

  const DesktopSideNav({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.isExpanded,
    required this. onTabSelected,
    required this.onToggle,
    required this.onLogout,
    required this.bounceAnimation,
    required this.pulseAnimation,
    required this.logoAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final sideNavWidth = isExpanded
        ? r.sideNavWidth
        : r. sideNavCollapsedWidth;

    return AnimatedContainer(
      duration: r.animationDuration,
      curve: Curves.easeInOut,
      width: sideNavWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: r.cardShadow,
      ),
      child: Column(
        children: [
          _buildHeader(r),
          if (isExpanded)
            _buildCollapseButton(r)
          else
            _buildExpandButton(r),
          if (viewModel.isDemoMode && isExpanded) _buildDemoBadge(r),
          if (viewModel.hasOverdueAlerts && isExpanded) _buildOverdueAlert(r),
          SizedBox(height: r.microPadding),
          Divider(color: Colors.grey. withOpacity(0.12), height: 1),
          SizedBox(height: r.microPadding),
          Expanded(child: _buildNavItems(r)),
          if (isExpanded) _buildUserCard(r),
        ],
      ),
    );
  }

  Widget _buildHeader(EmployeeResponsiveData r) {
    final currentColor = viewModel.currentColor;

    return Container(
      padding: EdgeInsets.all(isExpanded ? r.padding : r.microPadding),
      child: Row(
        mainAxisAlignment:
        isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
            },
            child: AnimatedBuilder(
              animation: bounceAnimation,
              builder: (context, child) => Transform.scale(
                scale: bounceAnimation.value,
                child: child,
              ),
              child: AnimatedContainer(
                duration: r.animationDuration,
                padding: EdgeInsets.all(r.microPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [currentColor, currentColor.withOpacity(0.7)],
                    begin:  Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: currentColor.withOpacity(0.3),
                      blurRadius:  8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:  Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: r.iconSize(20),
                ),
              ),
            ),
          ),
          if (isExpanded) ...[
            SizedBox(width: r.microPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Neat Now',
                    style: GoogleFonts.poppins(
                      fontSize: r.headingXS,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  AnimatedDefaultTextStyle(
                    duration:  r.animationDuration,
                    style: GoogleFonts.poppins(
                      fontSize: r.captionM,
                      color: currentColor,
                      fontWeight: FontWeight.w500,
                    ),
                    child: const Text('Employee Portal'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapseButton(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical: r. nanoPadding,
      ),
      child: Material(
        color: Colors.grey. withOpacity(0.06),
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onToggle();
          },
          borderRadius: BorderRadius.circular(r.smallBorderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical:  r.nanoPadding,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_open_rounded,
                  size: r.iconSize(18),
                  color: Colors. grey[600],
                ),
                SizedBox(width: r. microPadding),
                Expanded(
                  child: Text(
                    'Collapse',
                    style: GoogleFonts.poppins(
                      fontSize: r.captionL,
                      color: Colors. grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  size: r. iconSize(18),
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.nanoPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:  () {
            HapticFeedback.mediumImpact();
            onToggle();
          },
          borderRadius: BorderRadius.circular(r.smallBorderRadius),
          child: Container(
            width: r.buttonHeightSmall,
            height: r. buttonHeightSmall,
            alignment: Alignment.center,
            child: Icon(
              Icons. menu_rounded,
              size: r.iconSize(22),
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoBadge(EmployeeResponsiveData r) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical: r. nanoPadding,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical: r. nanoPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.orange. withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.orange. withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.science_rounded,
            size: r.iconSize(16),
            color: Colors.orange,
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Text(
              'Demo Mode',
              style: GoogleFonts.poppins(
                fontSize: r.captionL,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverdueAlert(EmployeeResponsiveData r) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical: r.nanoPadding,
      ),
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.red.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: pulseAnimation.value,
              child: child,
            ),
            child: Icon(
              Icons. warning_amber_rounded,
              size: r.iconSize(18),
              color: Colors.red,
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overdue Tasks',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionL,
                    fontWeight: FontWeight.bold,
                    color: Colors. red,
                  ),
                ),
                Text(
                  '${viewModel.overdueCount} task${viewModel.overdueCount > 1 ? 's' :  ''} > 2 days',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionS,
                    color: Colors. red. shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItems(EmployeeResponsiveData r) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical: r. nanoPadding,
      ),
      children: [
        ... viewModel.tabItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = viewModel.selectedIndex == index;
          final hasAlert = viewModel.hasTabAlert(index);

          return _buildNavItem(r, item, index, isSelected, hasAlert);
        }),
        SizedBox(height: r.padding),
        Divider(color: Colors. grey.withOpacity(0.12), height: 1),
        SizedBox(height: r.microPadding),
        _buildLogoutItem(r),
      ],
    );
  }

  Widget _buildNavItem(
      EmployeeResponsiveData r,
      dynamic item,
      int index,
      bool isSelected,
      bool hasAlert,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.nanoPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTabSelected(index);
          },
          borderRadius: BorderRadius.circular(r. borderRadius),
          child: AnimatedContainer(
            duration: r.animationDuration,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? r.microPadding : 0,
              vertical: r.microPadding,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                colors: [
                  item.color. withOpacity(0.15),
                  item.color. withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end:  Alignment.centerRight,
              )
                  : null,
              color: hasAlert && ! isSelected
                  ?  Colors.red. withOpacity(0.06)
                  : null,
              borderRadius: BorderRadius.circular(r.borderRadius),
              border: isSelected
                  ? Border.all(color: item.color.withOpacity(0.35))
                  : hasAlert
                  ? Border.all(color: Colors.red.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment. center,
              children: [
                Stack(
                  children: [
                    AnimatedContainer(
                      duration: r. animationDuration,
                      padding: EdgeInsets.all(r.nanoPadding),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color. withOpacity(0.15)
                            : hasAlert
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                          r.smallBorderRadius,
                        ),
                      ),
                      child: Icon(
                        isSelected ?  item.activeIcon : item.icon,
                        color: hasAlert
                            ? Colors.red
                            : isSelected
                            ? item.color
                            :  Colors.grey[600],
                        size: r. iconSize(20),
                      ),
                    ),
                    if (hasAlert)
                      Positioned(
                        right: r.atomicPadding,
                        top: r.atomicPadding,
                        child: Container(
                          width: r. dimension(8),
                          height: r.dimension(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape. circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(width: r.microPadding),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: r.bodyS,
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: hasAlert
                            ? Colors.red
                            : isSelected
                            ? item.color
                            : Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasAlert)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.nanoPadding,
                        vertical: r.atomicPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          r.smallBorderRadius,
                        ),
                      ),
                      child: Text(
                        '${viewModel.overdueCount}',
                        style: GoogleFonts.poppins(
                          fontSize: r.captionS,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (isSelected)
                    Container(
                      width: r.dimension(8),
                      height: r.dimension(8),
                      decoration: BoxDecoration(
                        color:  item.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.5),
                            blurRadius:  4,
                            offset:  const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutItem(EmployeeResponsiveData r) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:  () {
          HapticFeedback.mediumImpact();
          onLogout();
        },
        borderRadius: BorderRadius.circular(r.borderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? r.microPadding : 0,
            vertical: r.microPadding,
          ),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: r. iconSize(20),
                ),
              ),
              if (isExpanded) ...[
                SizedBox(width: r.microPadding),
                Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(EmployeeResponsiveData r) {
    final currentColor = viewModel.currentColor;

    return Container(
      margin: EdgeInsets.all(r.microPadding),
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey. shade50,
            Colors.grey.shade100.withOpacity(0.5),
          ],
          begin:  Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:  BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: r.avatarSize,
            height: r.avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: currentColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: currentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child:  viewModel.userProfileImage != null &&
                  viewModel.userProfileImage!. isNotEmpty
                  ?  Image.network(
                viewModel.userProfileImage!,
                fit: BoxFit. cover,
                errorBuilder:  (_, __, ___) => _buildAvatarInitial(r),
              )
                  :  _buildAvatarInitial(r),
            ),
          ),
          SizedBox(width:  r.microPadding),
          Expanded(
            child:  Column(
              crossAxisAlignment:  CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.userName,
                  style: GoogleFonts.poppins(
                    fontSize: r.captionL,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (r.showSecondaryText)
                  Text(
                    viewModel.userEmail,
                    style: GoogleFonts.poppins(
                      fontSize: r.captionS,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            width: r.dimension(12),
            height: r.dimension(12),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius:  4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitial(EmployeeResponsiveData r) {
    final currentColor = viewModel.currentColor;

    return Container(
      decoration:  BoxDecoration(
        gradient: LinearGradient(
          colors: [currentColor, currentColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          viewModel.userAvatarInitial,
          style: GoogleFonts.poppins(
            fontSize: r. avatarSize * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}