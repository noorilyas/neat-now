import 'package:flutter/material.dart';

/// ==================== PROFILE DESIGN SYSTEM ====================
/// 
/// Comprehensive design system for the Employee Profile feature
/// including colors, typography, shadows, gradients, and animations. 
/// 
/// Based on Oklch color space for perceptual uniformity
/// Primary:  Oklch(0.696 0.17 162. 48) -> Teal

class ProfileDesign {
  // ==================== PRIMARY COLORS ====================

  /// Primary Teal - Main brand color
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color primaryTealGlow = Color(0xFF95E1D3);

  // Teal Variations
  static const Color teal50 = Color(0xFFE6F7F4);
  static const Color teal100 = Color(0xFFB3E8E0);
  static const Color teal200 = Color(0xFF80D9CC);
  static const Color teal300 = Color(0xFF4DCAB8);
  static const Color teal400 = Color(0xFF2AC2AB);
  static const Color teal500 = Color(0xFF1FA896);
  static const Color teal600 = Color(0xFF1B9486);
  static const Color teal700 = Color(0xFF167A70);
  static const Color teal800 = Color(0xFF12605A);
  static const Color teal900 = Color(0xFF0D4644);

  // ==================== SURFACE COLORS ====================

  /// Surface colors for backgrounds and cards
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);
  static const Color surfaceOverlay = Color(0xFFF3F4F6);
  static const Color surfaceDark = Color(0xFFEFF1F3);

  // ==================== TEXT COLORS ====================

  /// Text hierarchy colors
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);
  static const Color textDisabled = Color(0xFFE5E7EB);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ==================== STATUS COLORS ====================

  /// Success states
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  /// Warning states
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  /// Error states
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  /// Info states
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF2563EB);

  // ==================== ACCENT COLORS ====================

  /// Purple accent
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purpleDark = Color(0xFF7C3AED);

  /// Pink accent
  static const Color pink = Color(0xFFEC4899);
  static const Color pinkLight = Color(0xFFFCE7F3);
  static const Color pinkDark = Color(0xFFDB2777);

  /// Orange accent
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFEDD5);
  static const Color orangeDark = Color(0xFFEA580C);

  // ==================== BADGE/TIER COLORS ====================

  /// Tier colors for gamification
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color platinumLight = Color(0xFFF5F5F5);
  static const Color platinumDark = Color(0xFFB8B8B8);

  static const Color gold = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFE55C);
  static const Color goldDark = Color(0xFFFFA500);
  static const Color goldGlow = Color(0xFFFFE873);

  static const Color silver = Color(0xFFC0C0C0);
  static const Color silverLight = Color(0xFFE8E8E8);
  static const Color silverDark = Color(0xFFA8A8A8);

  static const Color bronze = Color(0xFFCD7F32);
  static const Color bronzeLight = Color(0xFFDDA15E);
  static const Color bronzeDark = Color(0xFFB87333);

  // ==================== SEMANTIC COLORS ====================

  /// Online/Active state
  static const Color online = Color(0xFF10B981);

  /// Offline/Inactive state
  static const Color offline = Color(0xFF6B7280);

  /// Busy/Warning state
  static const Color busy = Color(0xFFF59E0B);

  /// Away state
  static const Color away = Color(0xFF8B5CF6);

  // ==================== SHADOWS ====================

  /// Soft shadow for cards and containers
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF1A1D21).withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Medium shadow for elevated elements
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: const Color(0xFF1A1D21).withOpacity(0.08),
      blurRadius: 25,
      offset: const Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  /// Elevated shadow for floating elements
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF1A1D21).withOpacity(0.06),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: const Color(0xFF1A1D21).withOpacity(0.04),
      blurRadius: 15,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Strong shadow for modals and dialogs
  static List<BoxShadow> get strongShadow => [
    BoxShadow(
      color:  const Color(0xFF1A1D21).withOpacity(0.12),
      blurRadius: 40,
      offset:  const Offset(0, 12),
      spreadRadius: -6,
    ),
  ];

  /// Glow shadow with custom color
  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.3}) => [
    BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  /// Inner shadow effect (for depressed elements)
  static List<BoxShadow> get innerShadow => [
    BoxShadow(
      color: const Color(0xFF1A1D21).withOpacity(0.08),
      blurRadius:  8,
      offset: const Offset(0, 2),
      spreadRadius: -4,
    ),
  ];

  // ==================== GRADIENTS ====================

  /// Primary teal gradient
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryTeal, primaryTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary teal gradient (vertical)
  static LinearGradient get primaryGradientVertical => const LinearGradient(
    colors: [primaryTeal, primaryTealLight],
    begin: Alignment. topCenter,
    end: Alignment. bottomCenter,
  );

  /// Header gradient with fade
  static LinearGradient get headerGradient => LinearGradient(
    colors:  [
      primaryTeal. withOpacity(0.15),
      primaryTealLight.withOpacity(0.05),
      surfacePure,
    ],
    begin:  Alignment.topCenter,
    end: Alignment. bottomCenter,
    stops: const [0.0, 0.5, 1.0],
  );

  /// Gold gradient for premium elements
  static LinearGradient get goldGradient => const LinearGradient(
    colors: [gold, goldLight, gold],
    begin: Alignment. topLeft,
    end:  Alignment.bottomRight,
  );

  /// Silver gradient
  static LinearGradient get silverGradient => const LinearGradient(
    colors: [silverLight, silver, silverLight],
    begin: Alignment. topLeft,
    end:  Alignment.bottomRight,
  );

  /// Bronze gradient
  static LinearGradient get bronzeGradient => const LinearGradient(
    colors: [bronzeLight, bronze, bronzeDark],
    begin:  Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient
  static LinearGradient get successGradient => LinearGradient(
    colors:  [success, success.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Error gradient
  static LinearGradient get errorGradient => LinearGradient(
    colors: [error, error.withOpacity(0.85)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass morphism gradient
  static LinearGradient glassMorphismGradient(Color color) => LinearGradient(
    colors: [
      color.withOpacity(0.2),
      color.withOpacity(0.1),
    ],
    begin: Alignment. topLeft,
    end:  Alignment.bottomRight,
  );

  /// Shimmer animation gradient
  static LinearGradient shimmerGradient(double animationValue) => LinearGradient(
    colors: [
      Colors. white.withOpacity(0.0),
      Colors.white.withOpacity(0.4),
      Colors.white.withOpacity(0.0),
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment(-1.0 + animationValue * 3, 0),
    end: Alignment(animationValue * 3, 0),
  );

  /// Overlay gradient for darkening
  static LinearGradient get overlayGradient => LinearGradient(
    colors: [
      const Color(0xFF000000).withOpacity(0.6),
      const Color(0xFF000000).withOpacity(0.3),
    ],
    begin: Alignment.topCenter,
    end: Alignment. bottomCenter,
  );

  // ==================== BORDER RADIUS ====================

  /// Border radius constants
  static const double radiusTiny = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusPill = 999.0;

  /// Border radius getters
  static BorderRadius get tinyRadius => BorderRadius.circular(radiusTiny);
  static BorderRadius get smallRadius => BorderRadius.circular(radiusSmall);
  static BorderRadius get mediumRadius => BorderRadius.circular(radiusMedium);
  static BorderRadius get largeRadius => BorderRadius. circular(radiusLarge);
  static BorderRadius get xLargeRadius => BorderRadius.circular(radiusXLarge);
  static BorderRadius get xxLargeRadius => BorderRadius. circular(radiusXXLarge);
  static BorderRadius get pillRadius => BorderRadius.circular(radiusPill);

  // ==================== SPACING ====================

  /// Spacing scale (8pt grid system)
  static const double spaceAtomic = 2.0;  // 2px
  static const double spaceNano = 4.0;    // 4px
  static const double spaceMicro = 8.0;   // 8px
  static const double spaceSmall = 12.0;  // 12px
  static const double spaceMedium = 16.0; // 16px
  static const double spaceLarge = 24.0;  // 24px
  static const double spaceXLarge = 32.0; // 32px
  static const double spaceXXLarge = 40.0; // 40px
  static const double spaceHuge = 48.0;   // 48px

  // ==================== DURATIONS ====================

  /// Animation durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds:  800);

  // ==================== CURVES ====================

  /// Animation curves
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseIn = Curves. easeIn;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveElastic = Curves.elasticOut;
  static const Curve curveBounce = Curves.bounceOut;

  // ==================== ELEVATION ====================

  /// Material elevation levels
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;

  // ==================== OPACITY ====================

  /// Opacity levels
  static const double opacityDisabled = 0.4;
  static const double opacityHover = 0.8;
  static const double opacityPressed = 0.6;
  static const double opacityOverlay = 0.5;

  // ==================== UTILITY METHODS ====================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Darken a color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Lighten a color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Get contrast color (black or white) for given background
  static Color getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? textPrimary : textInverse;
  }

  /// Interpolate between two colors
  static Color lerpColor(Color a, Color b, double t) {
    return Color. lerp(a, b, t) ??  a;
  }

  // ==================== DECORATION HELPERS ====================

  /// Card decoration
  static BoxDecoration cardDecoration({
    Color?  color,
    List<BoxShadow>? boxShadow,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? surfacePure,
      borderRadius: borderRadius ?? largeRadius,
      boxShadow: boxShadow ?? softShadow,
      border:  border,
    );
  }

  /// Elevated card decoration
  static BoxDecoration elevatedCardDecoration({
    Color? color,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? surfacePure,
      borderRadius: borderRadius ?? xLargeRadius,
      boxShadow: elevatedShadow,
    );
  }

  /// Glass morphism decoration
  static BoxDecoration glassMorphismDecoration({
    required Color color,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: glassMorphismGradient(color),
      borderRadius: borderRadius ?? largeRadius,
      border: Border.all(
        color: Colors.white. withOpacity(0.2),
        width: 1,
      ),
      boxShadow: softShadow,
    );
  }

  /// Button decoration
  static BoxDecoration buttonDecoration({
    required Color color,
    BorderRadius? borderRadius,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: isPressed ? darken(color, 0.1) : color,
      borderRadius: borderRadius ??  mediumRadius,
      boxShadow: isPressed ?  [] : glowShadow(color),
    );
  }

  /// Input decoration
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? fillColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText:  labelText,
      filled: true,
      fillColor: fillColor ?? surfaceLight,
      prefixIcon: prefixIcon != null ?  Icon(prefixIcon, color: textTertiary) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: textTertiary) : null,
      border: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: BorderSide. none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:  mediumRadius,
        borderSide: const BorderSide(color: primaryTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: mediumRadius,
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceMedium,
        vertical:  spaceMedium,
      ),
    );
  }

  // ==================== DIVIDERS ====================

  /// Horizontal divider
  static Widget horizontalDivider({
    Color?  color,
    double?  thickness,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      color: color ??  surfaceOverlay,
      thickness: thickness ??  1,
      indent: indent,
      endIndent: endIndent,
      height: 1,
    );
  }

  /// Vertical divider
  static Widget verticalDivider({
    Color? color,
    double? thickness,
    double?  width,
  }) {
    return Container(
      width: thickness ?? 1,
      height:  width ??  40,
      color: color ?? surfaceOverlay,
    );
  }

  // ==================== LOADING INDICATOR ====================

  /// Circular progress indicator with brand colors
  static Widget loadingIndicator({
    Color? color,
    double? size,
    double? strokeWidth,
  }) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? primaryTeal),
        strokeWidth: strokeWidth ?? 3,
      ),
    );
  }

  // ==================== EMPTY STATE ====================

  /// Empty state decoration
  static BoxDecoration emptyStateDecoration() {
    return BoxDecoration(
      color: surfaceLight,
      borderRadius: xLargeRadius,
      border: Border.all(
        color: surfaceOverlay,
        width:  2,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    );
  }
}