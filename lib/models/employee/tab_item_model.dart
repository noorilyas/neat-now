import 'package:flutter/material.dart';

class TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String shortLabel;
  final Color color;
  final Color backgroundColor;

  const TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this. shortLabel,
    required this. color,
    required this.backgroundColor,
  });
}