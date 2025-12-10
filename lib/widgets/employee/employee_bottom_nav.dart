import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// EmployeeBottomNavUpdated - Bottom navigation with 5 tabs
/// Tabs: Dashboard, Reports, Map, Analytics, Profile
class EmployeeBottomNavUpdated extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final EmployeeResponsiveData responsive;
  final String? profileImageUrl;
  final String userName;

  const EmployeeBottomNavUpdated({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this. responsive,
    this.profileImageUrl,
    required this. userName,
  });

  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.dashboard_rounded, 'activeIcon': Icons.dashboard, 'label': 'Home', 'micro': '🏠'},
    {'icon': Icons.assignment_outlined, 'activeIcon': Icons.assignment_rounded, 'label': 'Tasks', 'micro': '📋'},
    {'icon': Icons.map_outlined, 'activeIcon': Icons. map_rounded, 'label': 'Map', 'micro': '🗺️'},
    {'icon': Icons.analytics_outlined, 'activeIcon': Icons.analytics_rounded, 'label': 'Stats', 'micro': '📊'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: responsive.showShadows
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: responsive.bottomNavHeight,
          padding: EdgeInsets. symmetric(
            horizontal: responsive. microPadding,
            vertical: responsive. nanoPadding,
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
              ..._navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Expanded(
              child: _NavItem(
                icon: item['icon'] as IconData,
                activeIcon: item['activeIcon'] as IconData,
                label: item['label'] as String,
                microLabel: item['micro'] as String,
                isSelected: selectedIndex == index,
                onTap: () => onTabSelected(index),
                responsive: responsive,
              ),
            );
          }),
          // Profile tab
          Expanded(
            child: _ProfileNavItem(
              isSelected: selectedIndex == 4,
              onTap: () => onTabSelected(4),
              responsive: responsive,
              imageUrl: profileImageUrl,
              userName: userName,
            ),
          ),
          ],
        ),
      ),
    ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String microLabel;
  final bool isSelected;
  final VoidCallback onTap;
  final EmployeeResponsiveData responsive;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.microLabel,
    required this.isSelected,
    required this. onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets. symmetric(
          horizontal: responsive.nanoPadding,
          vertical: responsive. nanoPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2AC2AB). withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(responsive.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize. min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (responsive.isMicroScreen)
              Text(
                microLabel,
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  color: isSelected ? const Color(0xFF2AC2AB) : Colors.grey,
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets. all(isSelected ? responsive.nanoPadding : 0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2AC2AB).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: responsive.iconSize(isSelected ? 22 : 20),
                  color: isSelected ? const Color(0xFF2AC2AB) : Colors.grey[600],
                ),
              ),
            if (! responsive.isMicroScreen && !responsive.isTinyScreen) ...[
              SizedBox(height: responsive.nanoPadding),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: responsive.fontSize(10),
                    fontWeight: isSelected ? FontWeight. w600 : FontWeight.w500,
                    color: isSelected ?  const Color(0xFF2AC2AB) : Colors.grey[600],
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final EmployeeResponsiveData responsive;
  final String?  imageUrl;
  final String userName;

  const _ProfileNavItem({
    required this.isSelected,
    required this. onTap,
    required this.responsive,
    this.imageUrl,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = responsive. isMicroScreen
        ? 22.0
        : responsive.isTinyScreen
    ? 26.0
        : responsive.isVerySmallScreen
    ? 28.0
        : 32.0;

    return GestureDetector(
    onTap: () {
    HapticFeedback.selectionClick();
    onTap();
    },
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: EdgeInsets. symmetric(
    horizontal: responsive.nanoPadding,
    vertical: responsive.nanoPadding,
    ),
    decoration: BoxDecoration(
    color: isSelected ? const Color(0xFF2AC2AB).withOpacity(0.1) : Colors.transparent,
    borderRadius: BorderRadius.circular(responsive.borderRadius),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Container(
    width: avatarSize,
    height: avatarSize,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
    color: isSelected ? const Color(0xFF2AC2AB) : Colors.grey. withOpacity(0.4),
    width: isSelected ? 2.5 : 1.5,
    ),
    boxShadow: isSelected
    ? [BoxShadow(color: const Color(0xFF2AC2AB).withOpacity(0.3), blurRadius: 6)]
        : [],
    ),
    child: ClipOval(child: _buildImage(avatarSize)),
    ),
    if (! responsive.isMicroScreen && !responsive. isTinyScreen) ...[
    SizedBox(height: responsive.nanoPadding),
    FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
    'Profile',
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(10),
    fontWeight: isSelected ?  FontWeight.w600 : FontWeight. w500,
    color: isSelected ? const Color(0xFF2AC2AB) : Colors.grey[600],
    ),
    maxLines: 1,
    ),
    ),
    ],
    ],
    ),
    ),
    );
  }

  Widget _buildImage(double size) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit. cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(size),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2AC2AB)),
            ),
          );
        },
      );
    }
    return _buildDefaultAvatar(size);
  }

  Widget _buildDefaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF2AC2AB), Color(0xFF1FA896)]),
      ),
      child: Center(
        child: Text(
          userName. isNotEmpty ? userName[0]. toUpperCase() : 'E',
          style: GoogleFonts. poppins(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}