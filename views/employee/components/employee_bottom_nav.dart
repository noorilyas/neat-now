import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:neat_now/viewmodels/employee/employee_dashboard_viewmodel.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

import '../../../models/employee/tab_item_model.dart';

class EmployeeBottomNav extends StatelessWidget {
  final EmployeeDashboardViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Function(int) onTabSelected;

  const EmployeeBottomNav({
    super.key,
    required this.viewModel,
    required this.responsive,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.largeBorderRadius),
        ),
        boxShadow: responsive.elevatedShadow,
      ),
      child: Container(
        height: responsive.bottomNavHeight + bottomPadding,
        padding: EdgeInsets.only(
          left: responsive.nanoPadding,
          right:  responsive.nanoPadding,
          top: responsive.nanoPadding,
          bottom: bottomPadding + responsive.nanoPadding,
        ),
        child: Row(
          children: EmployeeDashboardViewModel.tabItems
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = viewModel.selectedIndex == index;
            final hasAlert = viewModel.hasTabAlert(index);

            return Expanded(
              child: _buildNavItem(
                item:  item,
                index: index,
                isSelected: isSelected,
                hasAlert: hasAlert,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required TabItem item,
    required int index,
    required bool isSelected,
    required bool hasAlert,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTabSelected(index);
      },
      behavior: HitTestBehavior. opaque,
      child: TweenAnimationBuilder<double>(
          tween: Tween(begin:  isSelected ? 0.9 : 1.0, end: 1.0),
          duration: responsive.animationDurationFast,
          curve: Curves.easeOut,
          builder: (context, scale, child) => Transform.scale(
            scale: scale,
            child: child,
          ),
          child: AnimatedContainer(
              duration: responsive.animationDuration,
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: responsive.atomicPadding),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.nanoPadding,
                vertical:  responsive.nanoPadding,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.color.withOpacity(0.12)
                    : hasAlert
                    ? Colors.red.withOpacity(0.06)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(responsive.borderRadius),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Wave indicator
                AnimatedContainer(
                duration: responsive.animationDuration,
                height: responsive.dimension(3),
                width: isSelected ? responsive.dimension(20) : 0,
                margin: EdgeInsets.only(bottom: responsive.nanoPadding),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(
                    responsive.tinyBorderRadius,
                  ),
                ),
              ),
              // Icon
              Stack(
                children: [
                  if (index == 5)
                    _buildProfileIcon(item.color, isSelected)
                  else
                    AnimatedSwitcher(
                      duration: responsive.animationDuration,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child:  child,
                        );
                      },
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        key: ValueKey(isSelected),
                        size: responsive.iconSize(20),
                        color: hasAlert
                            ? Colors.red
                            : isSelected
                            ? item.color
                            : Colors.grey[500],
                      ),
                    ),
                  if (hasAlert && responsive.showBadges)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: responsive.dimension(8),
                        height:  responsive.dimension(8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape. circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              // Label
              if (responsive.showIconLabels) ...[
          SizedBox(height: responsive.atomicPadding),
      AnimatedDefaultTextStyle(
        duration: responsive.animationDuration,
        style: GoogleFonts.poppins(
          fontSize: responsive.captionXS,
          fontWeight:
          isSelected ? FontWeight.w600 : FontWeight. w500,
          color:  hasAlert
              ? Colors. red
              : isSelected
              ? item.color
              : Colors.grey[500],
        ),
        child: Text(
          responsive.adaptiveText(
            item.shortLabel,
            nano: item.shortLabel[0],
            ultraMicro: item.shortLabel[0],
            micro: item. shortLabel. substring(
              0,
              math.min(2, item.shortLabel.length),
            ),
          ),
          maxLines: 1,
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

  Widget _buildProfileIcon(Color color, bool isSelected) {
    final size = responsive.iconSize(20) + 4;

    return AnimatedContainer(
      duration: responsive.animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Colors.grey. withOpacity(0.4),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius:  4,
            offset: const Offset(0, 2),
          ),
        ]
            :  null,
      ),
      child: ClipOval(
        child:  viewModel.userProfileImage != null &&
            viewModel.userProfileImage!.isNotEmpty
            ? Image.network(
          viewModel.userProfileImage!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildAvatarInitial(size, color),
        )
            : _buildAvatarInitial(size, color),
      ),
    );
  }

  Widget _buildAvatarInitial(double size, Color color) {
    return Container(
      decoration:  BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child:  Text(
          viewModel.userAvatarInitial,
          style: GoogleFonts.poppins(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}