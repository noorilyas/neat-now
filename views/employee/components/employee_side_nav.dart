import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neat_now/viewmodels/employee/employee_dashboard_viewmodel.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

import '../../../models/employee/tab_item_model.dart';

class EmployeeSideNav extends StatelessWidget {
  final EmployeeDashboardViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final bool isExpanded;
  final Function(int) onTabSelected;
  final VoidCallback onToggle;
  final VoidCallback onLogout;
  final Animation<double> bounceAnimation;
  final Animation<double> pulseAnimation;
  final Animation<double> logoAnimation;

  const EmployeeSideNav({
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
    final sideNavWidth = isExpanded
        ? responsive.sideNavWidth
        : responsive.sideNavCollapsedWidth;

    return AnimatedContainer(
      duration: responsive.animationDuration,
      curve:  Curves.easeInOut,
      width: sideNavWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: responsive.cardShadow,
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (isExpanded)
            _buildCollapseButton()
          else
            _buildExpandButton(),
          if (viewModel.isDemoMode && isExpanded)
            _buildDemoBadge(),
          if (viewModel.hasOverdueAlerts && isExpanded)
            _buildOverdueAlert(),
          SizedBox(height: responsive.microPadding),
          Divider(color: Colors.grey. withOpacity(0.12), height: 1),
          SizedBox(height: responsive.microPadding),
          Expanded(
            child: _buildNavItems(),
          ),
          if (isExpanded) _buildUserCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final currentColor = viewModel.currentColor;

    return Container(
      padding: EdgeInsets.all(
        isExpanded ? responsive.padding : responsive.microPadding,
      ),
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
          duration: responsive.animationDuration,
          padding: EdgeInsets.all(responsive.microPadding),
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              colors: [
                currentColor,
                currentColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment. bottomRight,
            ),
            borderRadius: BorderRadius.circular(responsive.borderRadius),
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
            size: responsive.iconSize(20),
          ),
        ),
      ),
    ),
    if (isExpanded) ...[
    SizedBox(width: responsive.microPadding),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Neat Now',
    style: GoogleFonts.poppins(
    fontSize: responsive.headingXS,
    fontWeight: FontWeight.bold,
    color: Colors.grey[900],
    ),
    overflow: TextOverflow.ellipsis,
    ),
    AnimatedDefaultTextStyle(
    duration: responsive.animationDuration,
    style: GoogleFonts.poppins(
    fontSize: responsive.captionM,
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

  Widget _buildCollapseButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.microPadding,
        vertical: responsive. nanoPadding,
      ),
      child: Material(
        color: Colors.grey. withOpacity(0.06),
        borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onToggle();
          },
          borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.microPadding,
              vertical:  responsive.nanoPadding,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.menu_open_rounded,
                  size: responsive. iconSize(18),
                  color: Colors. grey[600],
                ),
                SizedBox(width: responsive.microPadding),
                Expanded(
                  child: Text(
                    'Collapse',
                    style: GoogleFonts.poppins(
                      fontSize: responsive.captionL,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  size: responsive. iconSize(18),
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return Padding(
      padding: EdgeInsets. symmetric(vertical: responsive.nanoPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:  () {
            HapticFeedback.mediumImpact();
            onToggle();
          },
          borderRadius: BorderRadius.circular(responsive.smallBorderRadius),
          child: Container(
            width: responsive.buttonHeightSmall,
            height: responsive.buttonHeightSmall,
            alignment: Alignment.center,
            child: Icon(
              Icons. menu_rounded,
              size: responsive.iconSize(22),
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoBadge() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.microPadding,
        vertical: responsive. nanoPadding,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.microPadding,
        vertical:  responsive.nanoPadding,
      ),
      decoration: BoxDecoration(
        color: Colors. orange. withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border.all(color: Colors.orange. withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.science_rounded,
            size: responsive.iconSize(16),
            color: Colors.orange,
          ),
          SizedBox(width: responsive.microPadding),
          Expanded(
            child: Text(
              'Demo Mode',
              style: GoogleFonts.poppins(
                fontSize: responsive.captionL,
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

  Widget _buildOverdueAlert() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.microPadding,
        vertical: responsive. nanoPadding,
      ),
      padding: EdgeInsets. all(responsive.microPadding),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
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
              size: responsive.iconSize(18),
              color: Colors.red,
            ),
          ),
          SizedBox(width: responsive.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overdue Tasks',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.captionL,
                    fontWeight: FontWeight.bold,
                    color: Colors. red,
                  ),
                ),
                Text(
                  '${viewModel.overdueCount} task${viewModel.overdueCount > 1 ? 's' :  ''} > 2 days',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.captionS,
                    color: Colors.red. shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItems() {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.microPadding,
        vertical: responsive. nanoPadding,
      ),
      children: [
        ... EmployeeDashboardViewModel.tabItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = viewModel.selectedIndex == index;
          final hasAlert = viewModel.hasTabAlert(index);

          return _buildNavItem(
            item:  item,
            index: index,
            isSelected:  isSelected,
            hasAlert: hasAlert,
          );
        }),
        SizedBox(height: responsive.padding),
        Divider(color: Colors.grey.withOpacity(0.12), height: 1),
        SizedBox(height: responsive. microPadding),
        _buildLogoutItem(),
      ],
    );
  }

  Widget _buildNavItem({
    required TabItem item,
    required int index,
    required bool isSelected,
    required bool hasAlert,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: responsive.nanoPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTabSelected(index);
          },
          borderRadius: BorderRadius.circular(responsive. borderRadius),
          child: AnimatedContainer(
            duration: responsive.animationDuration,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? responsive.microPadding : 0,
              vertical: responsive.microPadding,
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
                  ? Colors. red.withOpacity(0.06)
                  : null,
              borderRadius: BorderRadius.circular(responsive.borderRadius),
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
                      duration: responsive. animationDuration,
                      padding: EdgeInsets.all(responsive.nanoPadding),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color.withOpacity(0.15)
                            : hasAlert
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey. withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                          responsive.smallBorderRadius,
                        ),
                      ),
                      child: Icon(
                        isSelected ?  item.activeIcon : item.icon,
                        color: hasAlert
                            ? Colors.red
                            : isSelected
                            ? item.color
                            : Colors.grey[600],
                        size: responsive.iconSize(20),
                      ),
                    ),
                    if (hasAlert)
                      Positioned(
                        right: responsive.atomicPadding,
                        top: responsive.atomicPadding,
                        child: Container(
                          width: responsive.dimension(8),
                          height: responsive.dimension(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(width: responsive.microPadding),
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.bodyS,
                        fontWeight:
                        isSelected ? FontWeight. w600 : FontWeight.w500,
                        color: hasAlert
                            ? Colors.red
                            : isSelected
                            ?  item.color
                            : Colors. grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasAlert)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive. nanoPadding,
                        vertical: responsive.atomicPadding,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                          responsive.smallBorderRadius,
                        ),
                      ),
                      child: Text(
                        '${viewModel.overdueCount}',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.captionS,
                          fontWeight: FontWeight.bold,
                          color: Colors. white,
                        ),
                      ),
                    )
                  else if (isSelected)
                    Container(
                      width: responsive.dimension(8),
                      height: responsive.dimension(8),
                      decoration: BoxDecoration(
                        color:  item.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.5),
                            blurRadius:  4,
                            offset: const Offset(0, 2),
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

  Widget _buildLogoutItem() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:  () {
          HapticFeedback.mediumImpact();
          onLogout();
        },
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? responsive.microPadding : 0,
            vertical: responsive.microPadding,
          ),
          child: Row(
            mainAxisAlignment: isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(responsive.nanoPadding),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius. circular(
                    responsive.smallBorderRadius,
                  ),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: responsive. iconSize(20),
                ),
              ),
              if (isExpanded) ...[
                SizedBox(width: responsive.microPadding),
                Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.bodyS,
                    fontWeight: FontWeight.w500,
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

  Widget _buildUserCard() {
    final currentColor = viewModel.currentColor;

    return Container(
      margin: EdgeInsets.all(responsive.microPadding),
      padding: EdgeInsets.all(responsive.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey. shade50,
            Colors.grey.shade100.withOpacity(0.5),
          ],
          begin:  Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:  BorderRadius.circular(responsive.borderRadius),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.avatarSize,
            height: responsive.avatarSize,
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
                  viewModel.userProfileImage! .isNotEmpty
                  ? Image. network(
                viewModel.userProfileImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildAvatarInitial(),
              )
                  : _buildAvatarInitial(),
            ),
          ),
          SizedBox(width: responsive.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.userName,
                  style: GoogleFonts.poppins(
                    fontSize: responsive.captionL,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (responsive.showSecondaryText)
                  Text(
                    viewModel.userEmail,
                    style: GoogleFonts.poppins(
                      fontSize:  responsive.captionS,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            width: responsive.dimension(12),
            height: responsive.dimension(12),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius:  4,
                  offset:  const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitial() {
    final currentColor = viewModel.currentColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            currentColor,
            currentColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          viewModel.userAvatarInitial,
          style: GoogleFonts.poppins(
            fontSize: responsive.avatarSize * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}