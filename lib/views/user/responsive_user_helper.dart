import 'package:flutter/material.dart';

/// ==================== USER RESPONSIVE HELPER ====================
class UserResponsiveData {
  final double screenWidth;
  final double screenHeight;
  final double safePaddingTop;
  final double safePaddingBottom;

  UserResponsiveData({
    required this. screenWidth,
    required this.screenHeight,
    required this.safePaddingTop,
    required this.safePaddingBottom,
  });

  factory UserResponsiveData.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    return UserResponsiveData(
      screenWidth: size.width,
      screenHeight: size.height,
      safePaddingTop: padding.top,
      safePaddingBottom: padding.bottom,
    );
  }

  // Scale factor based on width
  double get _scale {
    if (screenWidth < 360) return 0.85;
    if (screenWidth < 400) return 0.92;
    if (screenWidth < 600) return 1.0;
    if (screenWidth < 900) return 1.1;
    return 1.2;
  }

  // Dimensions
  double dimension(double base) => base * _scale;
  double get effectiveWidth => screenWidth;

  // Paddings
  double get atomicPadding => 2 * _scale;
  double get nanoPadding => 4 * _scale;
  double get microPadding => 8 * _scale;
  double get smallPadding => 12 * _scale;
  double get padding => 16 * _scale;
  double get largePadding => 24 * _scale;
  double get extraLargePadding => 32 * _scale;

  // Border Radius
  double get smallBorderRadius => 4 * _scale;
  double get borderRadius => 8 * _scale;
  double get largeBorderRadius => 12 * _scale;
  double get extraLargeBorderRadius => 20 * _scale;
  double get pillBorderRadius => 50 * _scale;

  // Font Sizes
  double get captionXS => 10 * _scale;
  double get captionS => 11 * _scale;
  double get captionM => 12 * _scale;
  double get bodyS => 14 * _scale;
  double get bodyM => 16 * _scale;
  double get headingXS => 18 * _scale;
  double get headingS => 20 * _scale;
  double get headingM => 24 * _scale;
  double get headingL => 28 * _scale;
  double get headingXL => 32 * _scale;

  // Icon Sizes
  double iconSize(double base) => base * _scale;

  // Button Height
  double get buttonHeight => 48 * _scale;
}