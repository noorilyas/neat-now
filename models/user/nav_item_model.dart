import 'package:flutter/material.dart';

class NavItemModel {
  final String label;
  final IconData activeIcon;
  final IconData icon;
  final Color color;
  final bool isFab;

  const NavItemModel({
    required this.label,
    required this.activeIcon,
    required this.icon,
    required this.color,
    this.isFab = false,
  });
}