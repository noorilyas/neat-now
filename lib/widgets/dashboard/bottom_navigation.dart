import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';
import 'dart:math' as math;

/// DashboardBottomNav - Bottom navigation bar component
class DashboardBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final ResponsiveData responsive;

  const DashboardBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.responsive,
  });

  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Home', 'micro': '🏠'},
    {'icon': Icons.emoji_events_rounded, 'label': 'Awards', 'micro': '🏆'},
    {'icon': Icons.leaderboard_rounded, 'label': 'Board', 'micro': '📊'},
    {'icon': Icons.person_rounded, 'label': 'Me', 'micro': '👤'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: responsive.showShadows
            ? [
          BoxShadow(
            color: Colors.black. withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ]
            : [],
      ),
      child: SafeArea(
        child: Container(
            height: responsive.isMicroScreen
                ? 40.0
            : responsive.isNanoScreen
        ? 50.0
            : responsive.dimension(70),
        padding: EdgeInsets.symmetric(horizontal: responsive.microPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment. spaceAround,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(
              _navItems[index]['icon'] as IconData,
              _navItems[index]['label'] as String,
              index,
              _navItems[index]['micro'] as String,
            );
          }),
        ),
      ),
    ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, String microLabel) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTabSelected(index);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: responsive.microPadding),
            child: Column(
              mainAxisSize: MainAxisSize. min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (responsive.isMicroScreen)
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        microLabel,
                        style: TextStyle(
                          fontSize: responsive.fontSize(16),
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors. grey,
                        ),
                      ),
                    ),
                  )
                else
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets. all(isSelected ? responsive.microPadding : 0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4CAF50). withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius. circular(responsive.borderRadius),
                    ),
                    child: Icon(
                      icon,
                      size: responsive.iconSize(24),
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.grey,
                    ),
                  ),
                if (! responsive.isMicroScreen) ...[
                  SizedBox(height: responsive.nanoPadding),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit. scaleDown,
                      child: Text(
                        responsive.isNanoScreen
                            ? label.substring(0, math.min(3, label.length))
                            : label,
                        style: GoogleFonts.poppins(
                          fontSize: responsive. fontSize(12),
                          fontWeight: isSelected ?  FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors. grey,
                        ),
                        maxLines: 1,
                      ),
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
}