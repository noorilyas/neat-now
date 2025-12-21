import 'package:flutter/material.dart';

/// ResponsiveData - Contains all responsive calculations
class ResponsiveData {
  final double screenWidth;
  final double screenHeight;
  final double safePaddingTop;
  final double safePaddingBottom;

  ResponsiveData({
    required this.screenWidth,
    required this.screenHeight,
    required this. safePaddingTop,
    required this.safePaddingBottom,
  });

  // Screen size checks
  bool get isMicroScreen => screenWidth < 280;
  bool get isNanoScreen => screenWidth >= 280 && screenWidth < 320;
  bool get isMiniScreen => screenWidth >= 320 && screenWidth < 375;
  bool get isSmallScreen => screenWidth >= 375 && screenWidth < 414;
  bool get isMediumScreen => screenWidth >= 414 && screenWidth < 768;
  bool get isLargeScreen => screenWidth >= 768;
  bool get isTablet => screenWidth >= 768 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
  bool get isLandscape => screenWidth > screenHeight;

  // Content visibility helpers
  bool get showSecondaryText => ! isMicroScreen && !isNanoScreen;
  bool get showDetailedContent => !isMicroScreen;
  bool get showIcons => !isMicroScreen;
  bool get showShadows => !isMicroScreen && !isNanoScreen;

  // Padding values
  double get padding {
    if (isMicroScreen) return 4.0;
    if (isNanoScreen) return 6.0;
    if (isMiniScreen) return 10.0;
    if (isSmallScreen) return 14.0;
    if (isMediumScreen) return 16.0;
    if (isLargeScreen) return 20.0;
    return 16.0;
  }

  double get microPadding => padding * 0.5;
  double get nanoPadding => padding * 0.25;
  double get largePadding => padding * 1.5;

  // Font size calculator
  double fontSize(double baseSize) {
    if (isMicroScreen) return baseSize * 0.55;
    if (isNanoScreen) return baseSize * 0.65;
    if (isMiniScreen) return baseSize * 0.75;
    if (isSmallScreen) return baseSize * 0.85;
    if (isMediumScreen) return baseSize * 0.95;
    return baseSize;
  }

  // Dimension calculator
  double dimension(double baseSize) {
    if (isMicroScreen) return baseSize * 0.4;
    if (isNanoScreen) return baseSize * 0.55;
    if (isMiniScreen) return baseSize * 0.7;
    if (isSmallScreen) return baseSize * 0.85;
    if (isMediumScreen) return baseSize * 0.95;
    return baseSize;
  }

  // Icon size calculator
  double iconSize(double baseSize) {
    if (isMicroScreen) return baseSize * 0.6;
    if (isNanoScreen) return baseSize * 0.7;
    if (isMiniScreen) return baseSize * 0.8;
    return baseSize;
  }

  // Adaptive text helper
  String adaptiveText(String full, {String? micro, String? nano, String? mini}) {
    if (isMicroScreen && micro != null) return micro;
    if (isNanoScreen && nano != null) return nano;
    if (isMiniScreen && mini != null) return mini;
    return full;
  }

  // Border radius
  double get borderRadius {
    if (isMicroScreen) return 6.0;
    if (isNanoScreen) return 8.0;
    if (isMiniScreen) return 10.0;
    return 12.0;
  }

  double get largeBorderRadius => borderRadius * 1.5;

  // Grid columns
  int get gridColumns {
    if (isMicroScreen || isNanoScreen) return 2;
    if (isMiniScreen || isSmallScreen) return 2;
    if (isMediumScreen) return 3;
    if (isTablet) return 4;
    return 4;
  }

  // Card aspect ratio
  double get cardAspectRatio {
    if (isMicroScreen) return 1.0;
    if (isNanoScreen) return 1.1;
    return 1.2;
  }

  // Max content width (for tablets/desktop)
  double get maxContentWidth {
    if (isDesktop) return 1200;
    if (isTablet) return 900;
    return screenWidth;
  }
}

/// ResponsiveHelper Widget - Provides responsive data to children
class ResponsiveHelper extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveData responsive) builder;

  const ResponsiveHelper({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery. of(context);

    final responsive = ResponsiveData(
      screenWidth: mediaQuery.size.width,
      screenHeight: mediaQuery.size.height,
      safePaddingTop: mediaQuery.padding.top,
      safePaddingBottom: mediaQuery.padding.bottom,
    );

    return builder(context, responsive);
  }
}

/// Extension for easy access in widgets
extension ResponsiveContext on BuildContext {
  ResponsiveData get responsive {
    final mediaQuery = MediaQuery.of(this);
    return ResponsiveData(
      screenWidth: mediaQuery.size.width,
      screenHeight: mediaQuery.size. height,
      safePaddingTop: mediaQuery.padding. top,
      safePaddingBottom: mediaQuery.padding. bottom,
    );
  }
}