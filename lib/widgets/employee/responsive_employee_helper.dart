import 'package:flutter/material.dart';
import 'dart:math' as math;

/// EmployeeResponsiveData - Ultra-comprehensive responsive calculations
/// Supports: Smartwatches (52px+), Phones, Foldables, Tablets, Laptops, Desktops, TVs
/// Minimum supported width: 52 pixels
class EmployeeResponsiveData {
  final double screenWidth;
  final double screenHeight;
  final double safePaddingTop;
  final double safePaddingBottom;
  final double safePaddingLeft;
  final double safePaddingRight;
  final Orientation orientation;
  final double devicePixelRatio;
  final double textScaleFactor;
  final Brightness platformBrightness;

  /// Minimum supported screen width
  static const double minSupportedWidth = 52.0;

  EmployeeResponsiveData({
    required this.screenWidth,
    required this. screenHeight,
    required this.safePaddingTop,
    required this.safePaddingBottom,
    required this. safePaddingLeft,
    required this.safePaddingRight,
    required this.orientation,
    required this.devicePixelRatio,
    required this. textScaleFactor,
    required this.platformBrightness,
  });

  /// Effective width (never below minimum)
  double get effectiveWidth => math.max(screenWidth, minSupportedWidth);

  /// Effective height
  double get effectiveHeight => math.max(screenHeight, minSupportedWidth);

  // ==================== SCREEN SIZE CATEGORIES (from 52px) ====================

  /// Nano: Extreme micro displays (52-79px) - Tiny widgets, minimal UI
  bool get isNanoScreen => effectiveWidth >= 52 && effectiveWidth < 80;

  /// Ultra Micro: Smartwatches small (80-119px)
  bool get isUltraMicroScreen => effectiveWidth >= 80 && effectiveWidth < 120;

  /// Micro: Smartwatches standard (120-159px)
  bool get isMicroScreen => effectiveWidth >= 120 && effectiveWidth < 160;

  /// Mini: Large wearables (160-199px)
  bool get isMiniScreen => effectiveWidth >= 160 && effectiveWidth < 200;

  /// Tiny: Small wearables, widgets (200-279px)
  bool get isTinyScreen => effectiveWidth >= 200 && effectiveWidth < 280;

  /// Very Small: Old phones, small devices (280-359px)
  bool get isVerySmallScreen => effectiveWidth >= 280 && effectiveWidth < 360;

  /// Small: Standard phones (360-479px)
  bool get isSmallScreen => effectiveWidth >= 360 && effectiveWidth < 480;

  /// Compact: Large phones (480-599px)
  bool get isCompactScreen => effectiveWidth >= 480 && effectiveWidth < 600;

  /// Medium: Small tablets, foldables (600-839px)
  bool get isMediumScreen => effectiveWidth >= 600 && effectiveWidth < 840;

  /// Large: Tablets, laptops (840-1023px)
  bool get isLargeScreen => effectiveWidth >= 840 && effectiveWidth < 1024;

  /// Extra Large: Laptops, small desktops (1024-1279px)
  bool get isExtraLargeScreen => effectiveWidth >= 1024 && effectiveWidth < 1280;

  /// Wide: Desktops (1280-1535px)
  bool get isWideScreen => effectiveWidth >= 1280 && effectiveWidth < 1536;

  /// Ultra Wide: Large desktops (1536-1919px)
  bool get isUltraWideScreen => effectiveWidth >= 1536 && effectiveWidth < 1920;

  /// Massive: 4K, TVs (>= 1920px)
  bool get isMassiveScreen => effectiveWidth >= 1920;

  /// Quick check for extremely small screens (< 120px)
  bool get isExtremelySmall => effectiveWidth < 120;

  /// Quick check for very constrained screens (< 200px)
  bool get isVeryConstrained => effectiveWidth < 200;

  /// Orientation checks
  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  /// Device type detection
  bool get isWatch => effectiveWidth < 200;
  bool get isPhone => effectiveWidth >= 280 && effectiveWidth < 600;
  bool get isFoldable => effectiveWidth >= 600 && effectiveWidth < 840 && screenHeight >= 800;
  bool get isTablet => effectiveWidth >= 600 && effectiveWidth < 1024;
  bool get isDesktop => effectiveWidth >= 1024;
  bool get isTV => effectiveWidth >= 1920 && devicePixelRatio <= 2;

  /// Aspect ratio checks
  double get aspectRatio => effectiveWidth / effectiveHeight;
  bool get isSquarish => aspectRatio >= 0.9 && aspectRatio <= 1.1;
  bool get isTall => aspectRatio < 0.6;
  bool get isWide => aspectRatio > 1.5;
  bool get isUltraWide => aspectRatio > 2.0;

  /// Available content area
  double get availableWidth => math.max(0, effectiveWidth - safePaddingLeft - safePaddingRight);
  double get availableHeight => math.max(0, effectiveHeight - safePaddingTop - safePaddingBottom);

  // ==================== SCREEN SIZE MULTIPLIER ====================

  /// Returns a multiplier based on screen width (0.0 to 1. 0+ range)
  double get _sizeMultiplier {
    if (effectiveWidth < 80) return 0.15;
    if (effectiveWidth < 120) return 0.25;
    if (effectiveWidth < 160) return 0.35;
    if (effectiveWidth < 200) return 0.45;
    if (effectiveWidth < 280) return 0.55;
    if (effectiveWidth < 360) return 0.70;
    if (effectiveWidth < 480) return 0.85;
    if (effectiveWidth < 600) return 0.95;
    if (effectiveWidth < 840) return 1.0;
    if (effectiveWidth < 1024) return 1.08;
    if (effectiveWidth < 1280) return 1.15;
    if (effectiveWidth < 1536) return 1.22;
    if (effectiveWidth < 1920) return 1.30;
    return 1.40;
  }

  // ==================== CONTENT VISIBILITY ====================

  /// Show any text at all
  bool get showAnyText => effectiveWidth >= 60;

  /// Show minimal text (single chars/numbers)
  bool get showMinimalText => effectiveWidth >= 70;

  /// Show short labels (1-3 chars)
  bool get showShortLabels => effectiveWidth >= 100;

  /// Show abbreviated text
  bool get showAbbreviatedText => effectiveWidth >= 140;

  /// Show secondary/helper text
  bool get showSecondaryText => effectiveWidth >= 200;

  /// Show detailed content
  bool get showDetailedContent => effectiveWidth >= 320;

  /// Show full descriptions
  bool get showFullDescriptions => effectiveWidth >= 480;

  /// Show icons at all
  bool get showAnyIcons => effectiveWidth >= 52;

  /// Show standard icons
  bool get showIcons => effectiveWidth >= 80;

  /// Show icon labels
  bool get showIconLabels => effectiveWidth >= 160;

  /// Show shadows (performance consideration)
  bool get showShadows => effectiveWidth >= 200 && devicePixelRatio <= 3;

  /// Show light shadows for small screens
  bool get showLightShadows => effectiveWidth >= 120;

  /// Show trends/indicators
  bool get showTrends => effectiveWidth >= 280;

  /// Show compact trends (just icons)
  bool get showCompactTrends => effectiveWidth >= 180;

  /// Show animations
  bool get showAnimations => effectiveWidth >= 120;

  /// Show complex animations
  bool get showComplexAnimations => effectiveWidth >= 400 && devicePixelRatio <= 3;

  /// Show charts
  bool get showCharts => effectiveWidth >= 200;

  /// Show detailed charts
  bool get showDetailedCharts => effectiveWidth >= 400;

  /// Show sidebar navigation
  bool get showSideNav => effectiveWidth >= 840;

  /// Show compact rail navigation
  bool get showRailNav => effectiveWidth >= 600;

  /// Show bottom navigation
  bool get showBottomNav => effectiveWidth < 840;

  /// Show floating action button
  bool get showFab => effectiveWidth >= 200;

  /// Show mini FAB
  bool get showMiniFab => effectiveWidth >= 100;

  /// Show app bar actions
  bool get showAppBarActions => effectiveWidth >= 200;

  /// Show profile images
  bool get showProfileImages => effectiveWidth >= 120;

  /// Show report images
  bool get showReportImages => effectiveWidth >= 200;

  /// Show map markers
  bool get showMapMarkers => effectiveWidth >= 200;

  /// Show borders
  bool get showBorders => effectiveWidth >= 80;

  /// Show dividers
  bool get showDividers => effectiveWidth >= 100;

  /// Show badges
  bool get showBadges => effectiveWidth >= 100;

  /// Show status indicators
  bool get showStatusIndicators => effectiveWidth >= 60;

  // ==================== PADDING VALUES ====================

  double get _basePadding {
    if (effectiveWidth < 60) return 1.0;
    if (effectiveWidth < 80) return 1.5;
    if (effectiveWidth < 100) return 2.0;
    if (effectiveWidth < 120) return 2.5;
    if (effectiveWidth < 160) return 3.0;
    if (effectiveWidth < 200) return 4.0;
    if (effectiveWidth < 280) return 6.0;
    if (effectiveWidth < 360) return 8.0;
    if (effectiveWidth < 480) return 12.0;
    if (effectiveWidth < 600) return 14.0;
    if (effectiveWidth < 840) return 16.0;
    if (effectiveWidth < 1024) return 20.0;
    if (effectiveWidth < 1280) return 24.0;
    if (effectiveWidth < 1536) return 28.0;
    if (effectiveWidth < 1920) return 32.0;
    return 36.0;
    }

  double get padding => _basePadding;
  double get atomicPadding => math.max(1.0, _basePadding * 0.15);
  double get nanoPadding => math. max(1.0, _basePadding * 0.25);
  double get microPadding => math.max(1.5, _basePadding * 0.5);
  double get smallPadding => math.max(2.0, _basePadding * 0.75);
  double get largePadding => _basePadding * 1.5;
  double get extraLargePadding => _basePadding * 2.0;
  double get hugePadding => _basePadding * 3.0;

  /// Horizontal padding for content containers
  double get horizontalPadding {
    if (effectiveWidth < 100) return atomicPadding;
    if (effectiveWidth < 200) return nanoPadding;
    if (effectiveWidth < 360) return padding;
    if (effectiveWidth < 600) return padding * 1.25;
    if (effectiveWidth < 840) return padding * 1.5;
    if (effectiveWidth < 1024) return padding * 2;
    if (effectiveWidth < 1280) return math.max((effectiveWidth - 1000) / 2, padding * 2);
    if (effectiveWidth < 1536) return math.max((effectiveWidth - 1200) / 2, padding * 2);
    return math.max((effectiveWidth - 1400) / 2, padding * 3);
  }

  /// Vertical padding for content containers
  double get verticalPadding {
    if (effectiveWidth < 100) return atomicPadding;
    if (isLandscape && effectiveHeight < 200) return padding * 0.25;
    if (isLandscape && effectiveHeight < 400) return padding * 0.5;
    return padding;
  }

  /// Content margin (space around main content)
  double get contentMargin {
    if (effectiveWidth < 100) return 1.0;
    if (effectiveWidth < 200) return 2.0;
    if (effectiveWidth < 360) return 4.0;
    if (effectiveWidth < 600) return 8.0;
    if (effectiveWidth < 1024) return 16.0;
    return 24.0;
  }

  // ==================== FONT SCALING ====================

  double get _baseFontScale {
    if (effectiveWidth < 60) return 0.20;
    if (effectiveWidth < 80) return 0.28;
    if (effectiveWidth < 100) return 0.35;
    if (effectiveWidth < 120) return 0.42;
    if (effectiveWidth < 160) return 0.50;
    if (effectiveWidth < 200) return 0.58;
    if (effectiveWidth < 280) return 0.68;
    if (effectiveWidth < 360) return 0.78;
    if (effectiveWidth < 480) return 0.88;
    if (effectiveWidth < 600) return 0.95;
    if (effectiveWidth < 840) return 1.0;
    if (effectiveWidth < 1024) return 1.05;
    if (effectiveWidth < 1280) return 1.10;
    if (effectiveWidth < 1536) return 1.15;
    if (effectiveWidth < 1920) return 1.20;
    return 1.25;
    }

  double get fontScale => _baseFontScale * math.min(textScaleFactor, 1.3);

  /// Calculate responsive font size with minimum bounds
  double fontSize(double baseSize) {
    final scaled = baseSize * fontScale;
    // Minimum readable sizes based on screen
    double minSize;
    if (effectiveWidth < 80) minSize = 4.0;
    else if (effectiveWidth < 120) minSize = 5.0;
    else if (effectiveWidth < 200) minSize = 6.0;
    else if (effectiveWidth < 280) minSize = 7.0;
    else minSize = 8.0;

    return scaled.clamp(minSize, math.min(baseSize * 2.0, 72.0));
  }

  /// Heading font sizes
  double get headingXL => fontSize(32);
  double get headingL => fontSize(28);
  double get headingM => fontSize(24);
  double get headingS => fontSize(20);
  double get headingXS => fontSize(18);

  /// Body font sizes
  double get bodyL => fontSize(16);
  double get bodyM => fontSize(14);
  double get bodyS => fontSize(12);

  /// Caption font sizes
  double get captionL => fontSize(11);
  double get captionM => fontSize(10);
  double get captionS => fontSize(9);
  double get captionXS => fontSize(8);

  /// Nano text size (for extremely small screens)
  double get nanoText => fontSize(6);

  // ==================== DIMENSION SCALING ====================

  double get _baseDimensionScale {
    if (effectiveWidth < 60) return 0.15;
    if (effectiveWidth < 80) return 0.22;
    if (effectiveWidth < 100) return 0.28;
    if (effectiveWidth < 120) return 0.35;
    if (effectiveWidth < 160) return 0.42;
    if (effectiveWidth < 200) return 0.50;
    if (effectiveWidth < 280) return 0.60;
    if (effectiveWidth < 360) return 0.72;
    if (effectiveWidth < 480) return 0.85;
    if (effectiveWidth < 600) return 0.95;
    if (effectiveWidth < 840) return 1.0;
    if (effectiveWidth < 1024) return 1.10;
    if (effectiveWidth < 1280) return 1.20;
    if (effectiveWidth < 1536) return 1.30;
    if (effectiveWidth < 1920) return 1.40;
    return 1.50;
  }

  /// Calculate responsive dimension with bounds
  double dimension(double baseSize) {
    final scaled = baseSize * _baseDimensionScale;
    // Minimum 1 pixel, maximum 2. 5x base
    return scaled.clamp(1.0, baseSize * 2.5);
  }

  /// Calculate responsive icon size
  double iconSize(double baseSize) {
    double scale;
    if (effectiveWidth < 60) scale = 0.20;
    else if (effectiveWidth < 80) scale = 0.30;
    else if (effectiveWidth < 100) scale = 0.38;
    else if (effectiveWidth < 120) scale = 0.45;
    else if (effectiveWidth < 160) scale = 0.52;
    else if (effectiveWidth < 200) scale = 0.60;
    else if (effectiveWidth < 280) scale = 0.70;
    else if (effectiveWidth < 360) scale = 0.80;
    else if (effectiveWidth < 480) scale = 0.90;
    else if (effectiveWidth < 600) scale = 0.95;
    else if (effectiveWidth < 840) scale = 1.0;
    else if (effectiveWidth < 1024) scale = 1.08;
    else if (effectiveWidth < 1280) scale = 1.15;
    else scale = 1.25;

    // Minimum icon size based on screen
    double minIcon;
    if (effectiveWidth < 80) minIcon = 6.0;
    else if (effectiveWidth < 120) minIcon = 8.0;
    else if (effectiveWidth < 200) minIcon = 10.0;
    else minIcon = 12.0;

    return (baseSize * scale).clamp(minIcon, 64.0);
    }

  // ==================== GRID & LAYOUT ====================

  /// Number of columns for grid layouts
  int get gridColumns {
    if (effectiveWidth < 80) return 1;
    if (effectiveWidth < 160) return 1;
    if (effectiveWidth < 280) return 2;
    if (effectiveWidth < 400) return 2;
    if (effectiveWidth < 600) return 2;
    if (effectiveWidth < 840) return 3;
    if (effectiveWidth < 1024) return 4;
    if (effectiveWidth < 1280) return 4;
    if (effectiveWidth < 1536) return 5;
    if (effectiveWidth < 1920) return 6;
    return 8;
  }

  /// Number of columns for stats grid
  int get statsGridColumns {
    if (effectiveWidth < 120) return 1;
    if (effectiveWidth < 200) return 2;
    if (effectiveWidth < 320) return 2;
    if (effectiveWidth < 500) return 2;
    if (effectiveWidth < 700) return 3;
    if (effectiveWidth < 900) return 4;
    if (effectiveWidth < 1200) return 4;
    if (effectiveWidth < 1600) return 6;
    return 6;
  }

  /// Number of columns for quick actions
  int get quickActionsColumns {
    if (effectiveWidth < 120) return 1;
    if (effectiveWidth < 200) return 2;
    if (effectiveWidth < 320) return 2;
    if (effectiveWidth < 450) return 2;
    if (effectiveWidth < 600) return 3;
    if (effectiveWidth < 800) return 4;
    if (effectiveWidth < 1000) return 4;
    if (effectiveWidth < 1400) return 6;
    return 6;
  }

  /// Number of columns for reports list
  int get reportListColumns {
    if (effectiveWidth < 600) return 1;
    if (effectiveWidth < 1024) return 2;
    if (effectiveWidth < 1536) return 3;
    return 4;
  }

  /// Grid spacing
  double get gridSpacing {
    if (effectiveWidth < 80) return 1;
    if (effectiveWidth < 120) return 2;
    if (effectiveWidth < 200) return 3;
    if (effectiveWidth < 280) return 4;
    if (effectiveWidth < 360) return 6;
    if (effectiveWidth < 480) return 8;
    if (effectiveWidth < 840) return 12;
    if (effectiveWidth < 1200) return 16;
    return 20;
  }

  /// Card aspect ratio for stats
  double get statsCardAspectRatio {
    if (effectiveWidth < 100) return 1.8;
    if (effectiveWidth < 160) return 1.5;
    if (effectiveWidth < 200) return 1.3;
    if (effectiveWidth < 280) return 1.2;
    if (effectiveWidth < 360) return 1.15;
    if (effectiveWidth < 480) return 1.1;
    if (effectiveWidth < 600) return 1.15;
    if (effectiveWidth < 840) return 1.2;
    if (effectiveWidth < 1200) return 1.25;
    return 1.3;
  }

  /// Quick action card aspect ratio
  double get quickActionAspectRatio {
    if (effectiveWidth < 100) return 1.0;
    if (effectiveWidth < 160) return 1.05;
    if (effectiveWidth < 200) return 1.0;
    if (effectiveWidth < 320) return 1.0;
    if (effectiveWidth < 400) return 1.1;
    if (effectiveWidth < 600) return 1.15;
    if (effectiveWidth < 800) return 1.2;
    return 1.3;
  }

  // ==================== BORDER RADIUS ====================

  double get _baseBorderRadius {
    if (effectiveWidth < 60) return 2.0;
    if (effectiveWidth < 80) return 2.5;
    if (effectiveWidth < 100) return 3.0;
    if (effectiveWidth < 120) return 4.0;
    if (effectiveWidth < 160) return 5.0;
    if (effectiveWidth < 200) return 6.0;
    if (effectiveWidth < 280) return 8.0;
    if (effectiveWidth < 360) return 10.0;
    if (effectiveWidth < 480) return 12.0;
    if (effectiveWidth < 600) return 14.0;
    if (effectiveWidth < 840) return 16.0;
    if (effectiveWidth < 1024) return 18.0;
    if (effectiveWidth < 1280) return 20.0;
    return 24.0;
  }

  double get borderRadius => _baseBorderRadius;
  double get tinyBorderRadius => math.max(1.0, _baseBorderRadius * 0.25);
  double get smallBorderRadius => math. max(2.0, _baseBorderRadius * 0.5);
  double get largeBorderRadius => _baseBorderRadius * 1.5;
  double get extraLargeBorderRadius => _baseBorderRadius * 2.0;
  double get roundedBorderRadius => _baseBorderRadius * 3.0;
  double get pillBorderRadius => 999.0;

  // ==================== COMPONENT HEIGHTS ====================

  /// App bar height
  double get appBarHeight {
    if (effectiveWidth < 80) return 28;
    if (effectiveWidth < 120) return 32;
    if (effectiveWidth < 160) return 36;
    if (effectiveWidth < 200) return 40;
    if (effectiveWidth < 280) return 44;
    if (effectiveWidth < 360) return 48;
    if (effectiveWidth < 480) return 52;
    if (effectiveWidth < 600) return 56;
    if (effectiveWidth < 840) return 60;
    return 64;
  }

  /// Bottom navigation height
  double get bottomNavHeight {
    if (effectiveWidth < 80) return 32;
    if (effectiveWidth < 120) return 36;
    if (effectiveWidth < 160) return 40;
    if (effectiveWidth < 200) return 44;
    if (effectiveWidth < 280) return 48;
    if (effectiveWidth < 360) return 52;
    if (effectiveWidth < 480) return 56;
    if (effectiveWidth < 600) return 60;
    if (effectiveWidth < 840) return 64;
    return 72;
  }

  /// Side navigation width
  double get sideNavWidth {
    if (effectiveWidth < 840) return 56;
    if (effectiveWidth < 1024) return 72;
    if (effectiveWidth < 1280) return 240;
    if (effectiveWidth < 1536) return 280;
    return 320;
  }

  /// Side navigation collapsed width
  double get sideNavCollapsedWidth {
    if (effectiveWidth < 600) return 48;
    if (effectiveWidth < 840) return 56;
    return 72;
  }

  /// Button height
  double get buttonHeight {
    if (effectiveWidth < 80) return 18;
    if (effectiveWidth < 120) return 22;
    if (effectiveWidth < 160) return 26;
    if (effectiveWidth < 200) return 30;
    if (effectiveWidth < 280) return 34;
    if (effectiveWidth < 360) return 38;
    if (effectiveWidth < 480) return 42;
    if (effectiveWidth < 600) return 46;
    if (effectiveWidth < 840) return 48;
    return 52;
  }

  /// Large button height
  double get buttonHeightLarge => buttonHeight * 1.2;

  /// Small button height
  double get buttonHeightSmall => math.max(16, buttonHeight * 0.8);

  /// Compact button height
  double get buttonHeightCompact => math.max(14, buttonHeight * 0.65);

  /// Button minimum width
  double get buttonMinWidth {
    if (effectiveWidth < 80) return 20;
    if (effectiveWidth < 120) return 28;
    if (effectiveWidth < 160) return 36;
    if (effectiveWidth < 200) return 44;
    if (effectiveWidth < 280) return 56;
    if (effectiveWidth < 360) return 72;
    if (effectiveWidth < 480) return 88;
    return 100;
  }

  /// Input field height
  double get inputHeight {
    if (effectiveWidth < 80) return 20;
    if (effectiveWidth < 120) return 24;
    if (effectiveWidth < 160) return 28;
    if (effectiveWidth < 200) return 32;
    if (effectiveWidth < 280) return 36;
    if (effectiveWidth < 360) return 40;
    if (effectiveWidth < 480) return 44;
    if (effectiveWidth < 600) return 48;
    return 52;
  }

  /// List tile height
  double get listTileHeight {
    if (effectiveWidth < 80) return 28;
    if (effectiveWidth < 120) return 32;
    if (effectiveWidth < 160) return 40;
    if (effectiveWidth < 200) return 48;
    if (effectiveWidth < 280) return 56;
    if (effectiveWidth < 360) return 64;
    if (effectiveWidth < 480) return 72;
    return 80;
  }

  /// Compact list tile height
  double get listTileHeightCompact => math.max(20, listTileHeight * 0.7);

  // ==================== IMAGE DIMENSIONS ====================

  /// Avatar size
  double get avatarSize {
    if (effectiveWidth < 60) return 12;
    if (effectiveWidth < 80) return 14;
    if (effectiveWidth < 100) return 16;
    if (effectiveWidth < 120) return 18;
    if (effectiveWidth < 160) return 22;
    if (effectiveWidth < 200) return 26;
    if (effectiveWidth < 280) return 30;
    if (effectiveWidth < 360) return 34;
    if (effectiveWidth < 480) return 38;
    if (effectiveWidth < 600) return 42;
    if (effectiveWidth < 840) return 46;
    return 52;
  }

  /// Large avatar size
  double get avatarSizeLarge => avatarSize * 1.5;

  /// Small avatar size
  double get avatarSizeSmall => math. max(8, avatarSize * 0.75);

  /// Mini avatar size
  double get avatarSizeMini => math. max(6, avatarSize * 0.5);

  /// Profile image size (for profile pages)
  double get profileImageSize {
    if (effectiveWidth < 80) return 24;
    if (effectiveWidth < 120) return 36;
    if (effectiveWidth < 160) return 48;
    if (effectiveWidth < 200) return 60;
    if (effectiveWidth < 280) return 72;
    if (effectiveWidth < 360) return 84;
    if (effectiveWidth < 480) return 96;
    if (effectiveWidth < 600) return 108;
    if (effectiveWidth < 840) return 120;
    return 140;
  }

  /// Thumbnail size
  double get thumbnailSize {
    if (effectiveWidth < 80) return 20;
    if (effectiveWidth < 120) return 28;
    if (effectiveWidth < 160) return 36;
    if (effectiveWidth < 200) return 44;
    if (effectiveWidth < 280) return 52;
    if (effectiveWidth < 360) return 60;
    if (effectiveWidth < 480) return 68;
    if (effectiveWidth < 600) return 76;
    if (effectiveWidth < 840) return 88;
    return 100;
  }

  /// Report image height
  double get reportImageHeight {
    if (effectiveWidth < 80) return 40;
    if (effectiveWidth < 120) return 56;
    if (effectiveWidth < 160) return 72;
    if (effectiveWidth < 200) return 88;
    if (effectiveWidth < 280) return 110;
    if (effectiveWidth < 360) return 130;
    if (effectiveWidth < 480) return 160;
    if (effectiveWidth < 600) return 180;
    if (effectiveWidth < 840) return 200;
    if (effectiveWidth < 1024) return 220;
    return 250;
  }

  /// Map marker size
  double get mapMarkerSize {
    if (effectiveWidth < 80) return 12;
    if (effectiveWidth < 120) return 16;
    if (effectiveWidth < 160) return 20;
    if (effectiveWidth < 200) return 24;
    if (effectiveWidth < 280) return 28;
    if (effectiveWidth < 360) return 34;
    if (effectiveWidth < 480) return 40;
    if (effectiveWidth < 600) return 44;
    if (effectiveWidth < 840) return 48;
    return 54;
  }

  // ==================== CHART DIMENSIONS ====================

  /// Chart height
  double get chartHeight {
    if (effectiveWidth < 80) return 36;
    if (effectiveWidth < 120) return 48;
    if (effectiveWidth < 160) return 64;
    if (effectiveWidth < 200) return 80;
    if (effectiveWidth < 280) return 100;
    if (effectiveWidth < 360) return 130;
    if (effectiveWidth < 480) return 160;
    if (effectiveWidth < 600) return 190;
    if (effectiveWidth < 840) return 220;
    if (effectiveWidth < 1024) return 260;
    if (effectiveWidth < 1280) return 300;
    return 340;
  }

  /// Chart bar width
  double get chartBarWidth {
    if (effectiveWidth < 120) return 4;
    if (effectiveWidth < 200) return 6;
    if (effectiveWidth < 280) return 8;
    if (effectiveWidth < 360) return 12;
    if (effectiveWidth < 480) return 16;
    if (effectiveWidth < 600) return 20;
    if (effectiveWidth < 840) return 24;
    if (effectiveWidth < 1024) return 28;
    return 32;
  }

  /// Pie/Circular chart size
  double get pieChartSize {
    final minDimension = math.min(effectiveWidth, effectiveHeight);
    if (minDimension < 100) return minDimension * 0.8;
    if (minDimension < 200) return minDimension * 0.6;
    if (minDimension < 280) return minDimension * 0.5;
    if (minDimension < 480) return minDimension * 0.45;
    if (minDimension < 840) return minDimension * 0.4;
    return math.min(minDimension * 0.35, 300);
  }

  /// Circular progress size
  double get circularProgressSize {
    if (effectiveWidth < 100) return 40;
    if (effectiveWidth < 160) return 60;
    if (effectiveWidth < 240) return 80;
    if (effectiveWidth < 320) return 100;
    if (effectiveWidth < 480) return 120;
    if (effectiveWidth < 640) return 140;
    return 160;
  }

  /// Circular progress stroke width
  double get circularProgressStroke {
    if (effectiveWidth < 120) return 4;
    if (effectiveWidth < 200) return 6;
    if (effectiveWidth < 320) return 8;
    if (effectiveWidth < 480) return 10;
    return 12;
  }

  // ==================== MODAL/SHEET DIMENSIONS ====================

  /// Sheet initial size
  double get sheetInitialSize {
    if (isLandscape && effectiveHeight < 300) return 0.95;
    if (isLandscape && effectiveHeight < 500) return 0.9;
    if (isLandscape) return 0.8;
    if (effectiveWidth < 280) return 0.85;
    if (effectiveWidth < 480) return 0.75;
    if (effectiveWidth < 600) return 0.7;
    return 0.65;
  }

  /// Sheet max size
  double get sheetMaxSize {
    if (isLandscape && effectiveHeight < 300) return 0.99;
    if (isLandscape && effectiveHeight < 400) return 0.98;
    if (isLandscape) return 0.95;
    return 0.92;
  }

  /// Sheet min size
  double get sheetMinSize {
    if (isLandscape) return 0.4;
    return 0.35;
  }

  /// Dialog max width
  double get dialogMaxWidth {
    if (effectiveWidth < 200) return effectiveWidth * 0.98;
    if (effectiveWidth < 360) return effectiveWidth * 0.95;
    if (effectiveWidth < 600) return effectiveWidth * 0.9;
    if (effectiveWidth < 840) return 520;
    if (effectiveWidth < 1200) return 600;
    return 680;
  }

  /// Dialog max height
  double get dialogMaxHeight {
    if (effectiveHeight < 300) return effectiveHeight * 0.95;
    if (effectiveHeight < 480) return effectiveHeight * 0.9;
    if (effectiveHeight < 700) return effectiveHeight * 0.85;
    return effectiveHeight * 0.8;
  }

  // ==================== CONTENT WIDTH ====================

  /// Max content width for centering on large screens
  double get maxContentWidth {
    if (effectiveWidth < 600) return effectiveWidth;
    if (effectiveWidth < 840) return effectiveWidth - (padding * 4);
    if (effectiveWidth < 1024) return 800;
    if (effectiveWidth < 1280) return 960;
    if (effectiveWidth < 1536) return 1120;
    if (effectiveWidth < 1920) return 1280;
    return 1400;
  }

  /// Max card width
  double get maxCardWidth {
    if (effectiveWidth < 280) return effectiveWidth - (padding * 2);
    if (effectiveWidth < 480) return effectiveWidth - (padding * 2);
    if (effectiveWidth < 600) return 460;
    if (effectiveWidth < 840) return 520;
    if (effectiveWidth < 1024) return 600;
    return 680;
  }

  /// Section spacing
  double get sectionSpacing {
    if (effectiveWidth < 100) return 6;
    if (effectiveWidth < 160) return 8;
    if (effectiveWidth < 240) return 10;
    if (effectiveWidth < 320) return 12;
    if (effectiveWidth < 400) return 16;
    if (effectiveWidth < 600) return 20;
    if (effectiveWidth < 900) return 24;
    return 28;
  }

  // ==================== WELCOME HEADER DIMENSIONS ====================

  /// Welcome header avatar size
  double get welcomeAvatarSize {
    if (effectiveWidth < 80) return 20;
    if (effectiveWidth < 120) return 26;
    if (effectiveWidth < 160) return 32;
    if (effectiveWidth < 200) return 36;
    if (effectiveWidth < 280) return 40;
    if (effectiveWidth < 360) return 48;
    if (effectiveWidth < 480) return 56;
    if (effectiveWidth < 600) return 64;
    return 72;
  }

  /// Welcome header title size
  double get welcomeTitleSize {
    if (effectiveWidth < 80) return 8;
    if (effectiveWidth < 120) return 10;
    if (effectiveWidth < 160) return 12;
    if (effectiveWidth < 200) return 13;
    if (effectiveWidth < 280) return 14;
    if (effectiveWidth < 360) return 16;
    if (effectiveWidth < 480) return 18;
    if (effectiveWidth < 600) return 20;
    return 22;
  }

  /// Welcome header subtitle size
  double get welcomeSubtitleSize {
    if (effectiveWidth < 100) return 6;
    if (effectiveWidth < 160) return 7;
    if (effectiveWidth < 200) return 8;
    if (effectiveWidth < 280) return 9;
    if (effectiveWidth < 360) return 10;
    if (effectiveWidth < 480) return 11;
    return 12;
  }

  // ==================== ACTIVITY ITEM DIMENSIONS ====================

  /// Activity item height
  double get activityItemHeight {
    if (effectiveWidth < 120) return 40;
    if (effectiveWidth < 200) return 52;
    if (effectiveWidth < 280) return 64;
    if (effectiveWidth < 360) return 72;
    if (effectiveWidth < 480) return 80;
    return 88;
  }

  /// Activity icon size
  double get activityIconSize {
    if (effectiveWidth < 120) return 12;
    if (effectiveWidth < 200) return 14;
    if (effectiveWidth < 280) return 16;
    if (effectiveWidth < 360) return 18;
    return 20;
  }

  /// Activity items to show
  int get activityItemsCount {
    if (effectiveWidth < 200) return 2;
    if (effectiveWidth < 320) return 3;
    if (effectiveWidth < 480) return 4;
    return 5;
  }

  // ==================== ADAPTIVE TEXT HELPER ====================

  /// Returns appropriate text based on screen size
  String adaptiveText(
      String full, {
        String?  nano,
        String?  ultraMicro,
        String? micro,
        String? mini,
        String?  tiny,
        String? verySmall,
        String? small,
        String? compact,
      }) {
    if (isNanoScreen && nano != null) return nano;
    if (isUltraMicroScreen && (ultraMicro ??  nano) != null) return ultraMicro ??  nano! ;
    if (isMicroScreen && (micro ?? ultraMicro ??  nano) != null) return micro ?? ultraMicro ?? nano! ;
    if (isMiniScreen && (mini ?? micro) != null) return mini ?? micro!;
    if (isTinyScreen && (tiny ?? mini ??  micro) != null) return tiny ?? mini ??  micro!;
    if (isVerySmallScreen && (verySmall ?? tiny) != null) return verySmall ?? tiny!;
    if (isSmallScreen && (small ?? verySmall) != null) return small ?? verySmall!;
    if (isCompactScreen && compact != null) return compact;
    return full;
  }

  /// Truncate text based on screen size
  int get maxTextLines {
    if (effectiveWidth < 80) return 1;
    if (effectiveWidth < 160) return 1;
    if (effectiveWidth < 280) return 2;
    if (effectiveWidth < 360) return 2;
    if (effectiveWidth < 480) return 3;
    return 4;
  }

  /// Max characters for labels
  int get maxLabelChars {
    if (effectiveWidth < 80) return 1;
    if (effectiveWidth < 120) return 2;
    if (effectiveWidth < 160) return 4;
    if (effectiveWidth < 200) return 6;
    if (effectiveWidth < 280) return 10;
    if (effectiveWidth < 360) return 16;
    return 100;
  }

  // ==================== ANIMATION DURATIONS ====================

  /// Standard animation duration
  Duration get animationDuration {
    if (! showAnimations) return Duration.zero;
    if (effectiveWidth < 120) return const Duration(milliseconds: 100);
    if (effectiveWidth < 200) return const Duration(milliseconds: 150);
    if (effectiveWidth < 280) return const Duration(milliseconds: 200);
    return const Duration(milliseconds: 300);
  }

  /// Fast animation duration
  Duration get animationDurationFast => Duration(
    milliseconds: (animationDuration.inMilliseconds * 0.5).round(),
  );

  /// Slow animation duration
  Duration get animationDurationSlow => Duration(
    milliseconds: (animationDuration.inMilliseconds * 1.5).round(),
  );

  // ==================== SHADOW CONFIGURATIONS ====================

  /// Card shadow
  List<BoxShadow> get cardShadow {
    if (!showLightShadows) return [];
    final blur = effectiveWidth < 200 ? 3.0 : effectiveWidth < 480 ? 6.0 : effectiveWidth < 840 ? 10.0 : 15.0;
    final offset = effectiveWidth < 200 ? 1.0 : effectiveWidth < 480 ? 2.0 : effectiveWidth < 840 ? 3.0 : 4.0;
    final opacity = effectiveWidth < 200 ? 0.03 : 0.05;
    return [
    BoxShadow(
    color: Colors.black.withOpacity(opacity),
    blurRadius: blur,
    offset: Offset(0, offset),
    ),
    ];
  }

  /// Elevated shadow
  List<BoxShadow> get elevatedShadow {
    if (! showShadows) return cardShadow;
    final blur = effectiveWidth < 200 ? 6.0 : effectiveWidth < 480 ? 10.0 : effectiveWidth < 840 ? 15.0 : 25.0;
    final offset = effectiveWidth < 200 ? 2.0 : effectiveWidth < 480 ? 4.0 : effectiveWidth < 840 ? 6.0 : 8.0;
    return [
    BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: blur,
    offset: Offset(0, offset),
    ),
    ];
    }

  // ==================== UTILITY METHODS ====================

  /// Get responsive value based on breakpoints
  T responsive<T>({
    required T base,
    T? nano,
    T?  ultraMicro,
    T? micro,
    T?  mini,
    T? tiny,
    T? verySmall,
    T? small,
    T? compact,
    T? medium,
    T?  large,
    T? extraLarge,
    T? wide,
    T?  ultraWide,
    T? massive,
  }) {
    if (isMassiveScreen && massive != null) return massive;
    if (isUltraWideScreen && (ultraWide ?? massive) != null) return ultraWide ?? massive!;
    if (isWideScreen && (wide ?? ultraWide ?? massive) != null) return wide ?? ultraWide ?? massive! ;
    if (isExtraLargeScreen && (extraLarge ?? wide) != null) return extraLarge ?? wide!;
    if (isLargeScreen && (large ?? extraLarge) != null) return large ?? extraLarge! ;
    if (isMediumScreen && (medium ?? large) != null) return medium ?? large!;
    if (isCompactScreen && (compact ?? medium) != null) return compact ??  medium!;
    if (isSmallScreen && (small ??  compact) != null) return small ?? compact! ;
    if (isVerySmallScreen && (verySmall ?? small) != null) return verySmall ??  small!;
    if (isTinyScreen && (tiny ??  verySmall) != null) return tiny ?? verySmall!;
    if (isMiniScreen && (mini ?? tiny) != null) return mini ??  tiny!;
    if (isMicroScreen && (micro ?? mini) != null) return micro ?? mini!;
    if (isUltraMicroScreen && (ultraMicro ?? micro) != null) return ultraMicro ?? micro! ;
    if (isNanoScreen && (nano ?? ultraMicro) != null) return nano ?? ultraMicro!;
    return base;
  }

  /// Calculate percentage of screen width
  double widthPercent(double percent) => effectiveWidth * (percent / 100);

  /// Calculate percentage of screen height
  double heightPercent(double percent) => effectiveHeight * (percent / 100);

  /// Calculate percentage of available width
  double availableWidthPercent(double percent) => availableWidth * (percent / 100);

  /// Calculate percentage of available height
  double availableHeightPercent(double percent) => availableHeight * (percent / 100);

  /// Check if device is high DPI
  bool get isHighDpi => devicePixelRatio > 2;

  /// Check if device is low DPI
  bool get isLowDpi => devicePixelRatio < 1.5;

  /// Get screen category name
  String get screenCategory {
    if (isNanoScreen) return 'Nano';
    if (isUltraMicroScreen) return 'Ultra Micro';
    if (isMicroScreen) return 'Micro';
    if (isMiniScreen) return 'Mini';
    if (isTinyScreen) return 'Tiny';
    if (isVerySmallScreen) return 'Very Small';
    if (isSmallScreen) return 'Small';
    if (isCompactScreen) return 'Compact';
    if (isMediumScreen) return 'Medium';
    if (isLargeScreen) return 'Large';
    if (isExtraLargeScreen) return 'Extra Large';
    if (isWideScreen) return 'Wide';
    if (isUltraWideScreen) return 'Ultra Wide';
    return 'Massive';
  }

  /// Debug info
  String get debugInfo => '''
Screen: ${effectiveWidth. toStringAsFixed(0)}x${effectiveHeight.toStringAsFixed(0)}
Category: $screenCategory
Orientation: ${isLandscape ? 'Landscape' : 'Portrait'}
Type: ${isWatch ? 'Watch' : isPhone ? 'Phone' : isTablet ? 'Tablet' : isDesktop ? 'Desktop' : isTV ? 'TV' : 'Unknown'}
DPR: ${devicePixelRatio.toStringAsFixed(2)}
Text Scale: ${textScaleFactor.toStringAsFixed(2)}
''';

  @override
  String toString() => 'EmployeeResponsiveData(${effectiveWidth.toStringAsFixed(0)}x${effectiveHeight.toStringAsFixed(0)} - $screenCategory)';
}

/// EmployeeResponsiveHelper Widget
class EmployeeResponsiveHelper extends StatelessWidget {
  final Widget Function(BuildContext context, EmployeeResponsiveData responsive) builder;

  const EmployeeResponsiveHelper({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaQuery = MediaQuery. of(context);

        final responsive = EmployeeResponsiveData(
          screenWidth: constraints.maxWidth > 0 ? constraints.maxWidth : mediaQuery. size.width,
          screenHeight: constraints.maxHeight > 0 ? constraints. maxHeight : mediaQuery.size.height,
          safePaddingTop: mediaQuery.padding.top,
          safePaddingBottom: mediaQuery.padding.bottom,
          safePaddingLeft: mediaQuery.padding.left,
          safePaddingRight: mediaQuery.padding.right,
          orientation: mediaQuery.orientation,
          devicePixelRatio: mediaQuery.devicePixelRatio,
          textScaleFactor: mediaQuery. textScaleFactor,
          platformBrightness: mediaQuery.platformBrightness,
        );

        return builder(context, responsive);
      },
    );
  }
}

/// Extension methods for easier responsive widget building
extension ResponsiveContext on BuildContext {
  /// Get responsive data from context
  EmployeeResponsiveData get responsive {
    final mediaQuery = MediaQuery. of(this);
    return EmployeeResponsiveData(
      screenWidth: mediaQuery.size. width,
      screenHeight: mediaQuery. size.height,
      safePaddingTop: mediaQuery. padding.top,
      safePaddingBottom: mediaQuery. padding.bottom,
      safePaddingLeft: mediaQuery. padding.left,
      safePaddingRight: mediaQuery. padding.right,
      orientation: mediaQuery.orientation,
      devicePixelRatio: mediaQuery.devicePixelRatio,
      textScaleFactor: mediaQuery.textScaleFactor,
      platformBrightness: mediaQuery.platformBrightness,
    );
  }
}

/// Responsive widget wrapper with constraints
class ResponsiveConstraints extends StatelessWidget {
  final Widget child;
  final double?  maxWidth;
  final double? maxHeight;
  final bool centerContent;
  final EdgeInsets?  padding;

  const ResponsiveConstraints({
    super.key,
    required this.child,
    this. maxWidth,
    this.maxHeight,
    this.centerContent = true,
    this. padding,
  });

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        Widget content = child;

        if (maxWidth != null || responsive.maxContentWidth < responsive.effectiveWidth) {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ??  responsive.maxContentWidth,
              maxHeight: maxHeight ?? double.infinity,
            ),
            child: content,
          );
        }

        if (padding != null) {
          content = Padding(padding: padding!, child: content);
        }

        if (centerContent && responsive.effectiveWidth > (maxWidth ?? responsive. maxContentWidth)) {
          content = Center(child: content);
        }

        return content;
      },
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? horizontal;
  final double? vertical;
  final double? all;

  const ResponsivePadding({
    super. key,
    required this.child,
    this.horizontal,
    this.vertical,
    this. all,
  });

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        final h = horizontal ?? all ?? responsive.padding;
        final v = vertical ?? all ?? responsive.padding;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
          child: child,
        );
      },
    );
  }
}

/// Responsive sized box
class ResponsiveSizedBox extends StatelessWidget {
  final double?  width;
  final double? height;
  final Widget?  child;

  const ResponsiveSizedBox({
    super.key,
    this.width,
    this.height,
    this.child,
  });

  const ResponsiveSizedBox.square({
    super.key,
    double? dimension,
    this.child,
  })  : width = dimension,
        height = dimension;

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        return SizedBox(
          width: width != null ? responsive.dimension(width!) : null,
          height: height != null ? responsive.dimension(height!) : null,
          child: child,
        );
      },
    );
  }
}

/// Responsive gap (spacing)
class ResponsiveGap extends StatelessWidget {
  final double size;
  final bool horizontal;

  const ResponsiveGap(this.size, {super.key, this.horizontal = false});

  const ResponsiveGap.horizontal(this.size, {super.key}) : horizontal = true;
  const ResponsiveGap.vertical(this.size, {super.key}) : horizontal = false;

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        final scaledSize = responsive. dimension(size);
        return SizedBox(
          width: horizontal ? scaledSize : null,
          height: horizontal ? null : scaledSize,
        );
      },
    );
  }
}

/// Responsive visibility widget
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final Widget? replacement;
  final double? minWidth;
  final double? maxWidth;
  final bool? showOnWatch;
  final bool? showOnPhone;
  final bool?  showOnTablet;
  final bool?  showOnDesktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this. replacement,
    this.minWidth,
    this.maxWidth,
    this. showOnWatch,
    this.showOnPhone,
    this.showOnTablet,
    this. showOnDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        bool visible = true;

        if (minWidth != null && responsive.effectiveWidth < minWidth!) visible = false;
        if (maxWidth != null && responsive.effectiveWidth > maxWidth!) visible = false;

        if (showOnWatch != null && responsive.isWatch) visible = showOnWatch!;
        if (showOnPhone != null && responsive. isPhone) visible = showOnPhone!;
        if (showOnTablet != null && responsive.isTablet) visible = showOnTablet!;
        if (showOnDesktop != null && responsive.isDesktop) visible = showOnDesktop!;

        return visible ? child : (replacement ?? const SizedBox.shrink());
      },
    );
  }
}


/// EmployeeResponsiveHelper - Widget wrapper for responsive building




/// Responsive breakpoint widget for conditional rendering
class ResponsiveBreakpoint extends StatelessWidget {
  final Widget?  mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget fallback;

  const ResponsiveBreakpoint({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= 1200 && desktop != null) {
          return desktop!;
        } else if (width >= 600 && tablet != null) {
          return tablet!;
        } else if (width < 600 && mobile != null) {
          return mobile!;
        }

        return fallback;
      },
    );
  }
}

/// Animated responsive container with smooth transitions
class AnimatedResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EmployeeResponsiveData responsive;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry?  margin;
  final BoxDecoration? decoration;
  final Duration duration;
  final Curve curve;

  const AnimatedResponsiveContainer({
    super.key,
    required this.child,
    required this.responsive,
    this.padding,
    this.margin,
    this. decoration,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      padding: padding,
      margin: margin,
      decoration: decoration,
      child: child,
    );
  }
}