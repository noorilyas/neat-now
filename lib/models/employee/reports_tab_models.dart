import 'package:flutter/material.dart';
import 'package:neat_now/models/employee_models.dart';

/// Reports Design System
class ReportsDesign {
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color primaryTealGlow = Color(0xFF95E1D3);
  static const Color surfacePure = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);
  static const Color surfaceOverlay = Color(0xFFF3F4F6);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFEDE9FE);

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color:  Colors.black.withOpacity(0.06),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get hoverShadow => [
    BoxShadow(
      color:  primaryTeal.withOpacity(0.15),
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color. withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryTeal, primaryTealLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradient => LinearGradient(
    colors: [success, success.withOpacity(0.85)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shimmerGradient(double value) => LinearGradient(
    colors: [
      Colors.white.withOpacity(0.0),
      Colors.white.withOpacity(0.3),
      Colors.white.withOpacity(0.0),
    ],
    stops: const [0.0, 0.5, 1.0],
    begin: Alignment(-1.0 + value * 2, 0),
    end: Alignment(1.0 + value * 2, 0),
  );
}

/// Filter Option Model
class FilterOption {
  final String value;
  final String label;
  final String shortLabel;
  final String nano;
  final Color color;
  final IconData icon;

  const FilterOption({
    required this. value,
    required this.label,
    required this.shortLabel,
    required this.nano,
    required this.color,
    required this.icon,
  });

  static final List<FilterOption> defaults = [
    FilterOption(
      value: 'all',
      label: 'All Tasks',
      shortLabel: 'All',
      nano: 'A',
      color: ReportsDesign.textSecondary,
      icon: Icons.all_inbox_rounded,
    ),
    FilterOption(
      value: 'pending',
      label: 'Pending',
      shortLabel: 'New',
      nano: 'N',
      color: ReportsDesign.warning,
      icon: Icons.schedule_rounded,
    ),
    FilterOption(
      value: 'in-progress',
      label: 'In Progress',
      shortLabel:  'Active',
      nano:  'P',
      color: ReportsDesign.info,
      icon: Icons.sync_rounded,
    ),
    FilterOption(
      value: 'resolved',
      label: 'Completed',
      shortLabel: 'Done',
      nano: 'D',
      color: ReportsDesign.success,
      icon: Icons.check_circle_rounded,
    ),
  ];
}

/// Report Card Display Data
class ReportCardData {
  final Report report;
  final Color statusColor;
  final bool hasLocation;
  final String timeAgo;
  final bool isRecent;

  const ReportCardData({
    required this.report,
    required this.statusColor,
    required this.hasLocation,
    required this.timeAgo,
    required this.isRecent,
  });
}

/// Timeline Event Model
class TimelineEvent {
  final String title;
  final DateTime date;
  final IconData icon;
  final Color color;
  final bool isCompleted;

  const TimelineEvent({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
    required this.isCompleted,
  });
}

/// Verification Step Model
class VerificationStep {
  final String label;
  final IconData icon;

  const VerificationStep(this.label, this.icon);

  static final List<VerificationStep> defaults = [
    VerificationStep('Uploading image', Icons.cloud_upload_rounded),
    VerificationStep('Verifying GPS', Icons.gps_fixed_rounded),
    VerificationStep('Analyzing before', Icons.image_rounded),
    VerificationStep('Analyzing after', Icons.compare_rounded),
    VerificationStep('Comparing cleanliness', Icons.auto_awesome_rounded),
    VerificationStep('Generating report', Icons.description_rounded),
  ];
}

/// Confetti Particle Model
class ConfettiParticle {
  final double angle;
  final double velocity;
  final double rotationSpeed;
  final double size;
  final Color color;
  final int shape;
  final double delay;

  const ConfettiParticle({
    required this.angle,
    required this.velocity,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.shape,
    this.delay = 0,
  });
}

/// Reports State Model
class ReportsState {
  final String selectedFilter;
  final String searchQuery;
  final bool isSearchExpanded;
  final int?  hoveredCardIndex;

  const ReportsState({
    this.selectedFilter = 'all',
    this. searchQuery = '',
    this. isSearchExpanded = false,
    this.hoveredCardIndex,
  });

  ReportsState copyWith({
    String? selectedFilter,
    String?  searchQuery,
    bool? isSearchExpanded,
    int?  hoveredCardIndex,
    bool clearHoveredCard = false,
  }) {
    return ReportsState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this. searchQuery,
      isSearchExpanded: isSearchExpanded ?? this.isSearchExpanded,
      hoveredCardIndex: clearHoveredCard ? null : (hoveredCardIndex ?? this.hoveredCardIndex),
    );
  }
}