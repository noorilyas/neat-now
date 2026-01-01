import 'package:flutter/material.dart';
import 'dart:ui';

/// ==================== USER DESIGN SYSTEM ====================
class UserDesign {
  // Primary Colors - Modern Teal Palette
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color primaryTealGlow = Color(0xFF95E1D3);
  static const Color primaryTealSoft = Color(0xFFE8FAF7);

  // Surfaces - Clean & Minimal
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);
  static const Color surfaceOverlay = Color(0xFFF3F4F6);
  static const Color surfaceGlass = Color(0xFFFFFFFE);

  // Text - Clear Hierarchy
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);
  static const Color textMuted = Color(0xFFE5E7EB);

  // Status Colors - Vibrant & Clear
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningSoft = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorSoft = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoSoft = Color(0xFFEFF6FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purpleSoft = Color(0xFFF5F3FF);

  // Badge & Rank Colors
  static const Color platinum = Color(0xFFE5E4E2);
  static const Color platinumShine = Color(0xFFF5F5F5);
  static const Color gold = Color(0xFFFFD700);
  static const Color goldShine = Color(0xFFFFF4CC);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color silverShine = Color(0xFFE8E8E8);
  static const Color bronze = Color(0xFFCD7F32);

  // Shadows - Soft & Layered
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 32,
          offset: const Offset(0, 12),
          spreadRadius: -8,
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color. withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 40,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> subtleGlow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
      ];

  // Gradients - Smooth & Modern
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primaryTeal, primaryTealLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get primaryGradientVertical => const LinearGradient(
        colors: [primaryTeal, primaryTealLight],
        begin: Alignment.topCenter,
        end: Alignment. bottomCenter,
      );

  static LinearGradient get successGradient => const LinearGradient(
        colors: [success, Color(0xFF34D399)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get errorGradient => const LinearGradient(
        colors: [error, Color(0xFFF87171)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get purpleGradient => const LinearGradient(
        colors: [purple, Color(0xFFA78BFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get glassGradient => LinearGradient(
        colors:  [
          Colors.white. withOpacity(0.9),
          Colors.white.withOpacity(0.7),
        ],
        begin: Alignment. topLeft,
        end:  Alignment.bottomRight,
      );

  static LinearGradient shimmerGradient(double value) => LinearGradient(
        colors:  [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment(-1.0 + value * 3, 0),
        end: Alignment(value * 3, 0),
      );

  // Border Radius Constants
  static const double radiusXS = 6;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusFull = 100;
}