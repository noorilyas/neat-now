import 'package:flutter/material.dart';

class TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String shortLabel;
  final Color color;

  const TabItem({
    required this. icon,
    required this.  activeIcon,
    required this. label,
    required this.shortLabel,
    required this.color,
  });

  static const List<TabItem> defaultTabs = [
    TabItem(
      icon: Icons.dashboard_outlined,
      activeIcon:  Icons.dashboard_rounded,
      label: 'Dashboard',
      shortLabel: 'Home',
      color: Color(0xFF2AC2AB),
    ),
    TabItem(
      icon: Icons.assignment_outlined,
      activeIcon:  Icons.assignment_rounded,
      label: 'Reports',
      shortLabel: 'Tasks',
      color: Color(0xFFFF6B6B),
    ),
    TabItem(
      icon: Icons.map_outlined,
      activeIcon:  Icons.map_rounded,
      label: 'Bins Map',
      shortLabel: 'Map',
      color: Color(0xFF4ECDC4),
    ),
    TabItem(
      icon:  Icons.analytics_outlined,
      activeIcon:  Icons.analytics_rounded,
      label: 'Analytics',
      shortLabel: 'Stats',
      color: Color(0xFF95E1D3),
    ),
    TabItem(
      icon: Icons.leaderboard_outlined,
      activeIcon: Icons.leaderboard_rounded,
      label: 'Leaderboard',
      shortLabel: 'Rank',
      color: Color(0xFFFFD93D),
    ),
    TabItem(
      icon: Icons. person_outline_rounded,
      activeIcon: Icons. person_rounded,
      label: 'Profile',
      shortLabel: 'Me',
      color: Color(0xFF6C5CE7),
    ),
  ];
}