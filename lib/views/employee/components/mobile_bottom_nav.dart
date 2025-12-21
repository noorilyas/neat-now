import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/employee_main_dashboard_viewmodel.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class MobileBottomNav extends StatelessWidget {
  final EmployeeMainDashboardViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Function(int) onTabSelected;

  const MobileBottomNav({
    super.key,
    required this.viewModel,
    required this.responsive,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(r.largeBorderRadius),
        ),
        boxShadow: r.elevatedShadow,
      ),
      child: Container(
        height: r.bottomNavHeight + bottomPadding,
        padding: EdgeInsets.only(
          left: r.nanoPadding,
          right:  r.nanoPadding,
          top: r.nanoPadding,
          bottom: bottomPadding + r.nanoPadding,
        ),
        child: Row(
          children: viewModel.tabItems.asMap().entries.map((entry) {
            final index = entry. key;
            final item = entry.value;
            final isSelected = viewModel.selectedIndex == index;
            final hasAlert = viewModel.hasTabAlert(index);

            return Expanded(
              child: _buildNavItem(r, item, index, isSelected, hasAlert),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      EmployeeResponsiveData r,
      dynamic item,
      int index,
      bool isSelected,
      bool hasAlert,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTabSelected(index);
      },
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: isSelected ? 0.9 : 1.0, end: 1.0),
        duration: r.animationDurationFast,
        curve: Curves.easeOut,
        builder: (context, scale, child) => Transform.scale(
          scale: scale,
          child: child,
        ),
        child: AnimatedContainer(
          duration: r.animationDuration,
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: r.atomicPadding),
          padding: EdgeInsets.symmetric(
            horizontal: r.nanoPadding,
            vertical:  r.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? item.color. withOpacity(0.12)
                : hasAlert
                ? Colors.red.withOpacity(0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(r.borderRadius),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Wave indicator
              AnimatedContainer(
                duration: r.animationDuration,
                height: r.dimension(3),
                width: isSelected ? r.dimension(20) : 0,
                margin: EdgeInsets.only(bottom: r.nanoPadding),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(r.tinyBorderRadius),
                ),
              ),
              // Icon
              Stack(
                children: [
                  if (index == 5)
                    _buildProfileIcon(r, isSelected, item.color)
                  else
                    AnimatedSwitcher(
                      duration: r.animationDuration,
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child:  child,
                        );
                      },
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        key: ValueKey(isSelected),
                        size: r.iconSize(20),
                        color: hasAlert
                            ? Colors.red
                            : isSelected
                            ? item.color
                            : Colors.grey[500],
                      ),
                    ),
                  if (hasAlert && r.showBadges)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: r.dimension(8),
                        height: r.dimension(8),
                        decoration: BoxDecoration(
                          color:  Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              // Label
              if (r.showIconLabels) ...[
                SizedBox(height: r.atomicPadding),
                AnimatedDefaultTextStyle(
                  duration: r.animationDuration,
                  style: GoogleFonts.poppins(
                    fontSize: r.captionXS,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: hasAlert
                        ? Colors.red
                        : isSelected
                        ? item.color
                        : Colors.grey[500],
                  ),
                  child: Text(
                    r.adaptiveText(
                      item.shortLabel,
                      nano: item.shortLabel[0],
                      ultraMicro: item.shortLabel[0],
                      micro: item.shortLabel.substring(
                        0, min<int>(2, item.shortLabel.length)

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

  Widget _buildProfileIcon(
      EmployeeResponsiveData r,
      bool isSelected,
      Color color,
      ) {
    final size = r.iconSize(20) + 4;

    return AnimatedContainer(
      duration: r.animationDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Colors.grey. withOpacity(0.4),
          width: isSelected ?  2.5 : 1.5,
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
        child: viewModel.userProfileImage != null &&
            viewModel.userProfileImage!.isNotEmpty
            ?  Image.network(
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
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