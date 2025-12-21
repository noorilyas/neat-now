import 'package:flutter/material.dart';

/// Chart types
enum ChartType { line, bar, area, pie }

/// Export formats
enum ExportFormat { pdf, csv, excel, image }

/// Analytics Period
enum AnalyticsPeriod { week, month, year }

extension AnalyticsPeriodExtension on AnalyticsPeriod {
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.year:
        return 'This Year';
    }
  }

  int get index {
    switch (this) {
      case AnalyticsPeriod.week:
        return 0;
      case AnalyticsPeriod.month:
        return 1;
      case AnalyticsPeriod. year:
        return 2;
    }
  }

  static AnalyticsPeriod fromIndex(int index) {
    switch (index) {
      case 0:
        return AnalyticsPeriod.week;
      case 1:
        return AnalyticsPeriod.month;
      case 2:
        return AnalyticsPeriod.year;
      default:
        return AnalyticsPeriod.month;
    }
  }
}

/// Metric Card Data
class MetricCardData {
  final String key;
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String?  trend;
  final bool trendUp;
  final String suffix;

  const MetricCardData({
    required this.key,
    required this.label,
    required this. value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp = true,
    this.suffix = '',
  });

  factory MetricCardData.tasks({
    required int value,
    String?  trend,
    bool trendUp = true,
  }) {
    return MetricCardData(
      key: 'tasks',
      label: 'Total',
      value: value,
      icon: Icons.assignment_rounded,
      color: const Color(0xFF3B82F6),
      trend: trend,
      trendUp: trendUp,
    );
  }

  factory MetricCardData.completed({
    required int value,
    String? trend,
    bool trendUp = true,
  }) {
    return MetricCardData(
      key: 'efficiency',
      label: 'Done',
      value: value,
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF10B981),
      trend: trend,
      trendUp: trendUp,
    );
  }

  factory MetricCardData.efficiency({
    required int value,
    String? trend,
    bool trendUp = true,
  }) {
    return MetricCardData(
      key: 'rating',
      label: 'Rate',
      value: value,
      icon: Icons.speed_rounded,
      color: const Color(0xFF2AC2AB),
      trend: trend,
      trendUp: trendUp,
      suffix: '%',
    );
  }

  factory MetricCardData.responseTime({
    required int value,
    String? trend,
    bool trendUp = false,
  }) {
    return MetricCardData(
      key: 'time',
      label: 'Time',
      value: value,
      icon: Icons.timer_rounded,
      color: const Color(0xFFF59E0B),
      trend: trend,
      trendUp: trendUp,
      suffix: 'm',
    );
  }
}

/// Distribution Item
class DistributionItem {
  final String label;
  final int count;
  final Color color;

  const DistributionItem(this.label, this.count, this.color);

  double getPercentage(int total) {
    return total > 0 ? count / total :  0.0;
  }
}

/// Analytics State
class AnalyticsState {
  final AnalyticsPeriod selectedPeriod;
  final ChartType selectedChartType;
  final Map<String, bool> visibleMetrics;
  final bool showComparison;
  final bool isExporting;

  const AnalyticsState({
    this.selectedPeriod = AnalyticsPeriod.month,
    this.selectedChartType = ChartType.line,
    this.visibleMetrics = const {
      'tasks': true,
      'efficiency': true,
      'rating': true,
      'time': true,
    },
    this.showComparison = true,
    this.isExporting = false,
  });

  AnalyticsState copyWith({
    AnalyticsPeriod? selectedPeriod,
    ChartType? selectedChartType,
    Map<String, bool>? visibleMetrics,
    bool? showComparison,
    bool? isExporting,
  }) {
    return AnalyticsState(
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedChartType: selectedChartType ?? this.selectedChartType,
      visibleMetrics: visibleMetrics ?? Map. from(this.visibleMetrics),
      showComparison: showComparison ?? this.showComparison,
      isExporting: isExporting ?? this.isExporting,
    );
  }

  bool isMetricVisible(String key) => visibleMetrics[key] ?? true;
}

/// Analytics Design System
class AnalyticsDesign {
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealLight = Color(0xFF4ECDC4);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color surfaceCard = Color(0xFFF8FAFB);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color indigo = Color(0xFF6366F1);
  static const Color cyan = Color(0xFF06B6D4);

  static const List<Color> chartColors = [
    primaryTeal,
    info,
    warning,
    purple,
    pink,
    success,
    error,
    cyan,
  ];

  static const List<Color> gradientColors = [
    Color(0xFF2AC2AB),
    Color(0xFF4ECDC4),
  ];

  static List<Color> getDistributionColors() => [
    info,
    success,
    purple,
    error,
    textSecondary,
  ];

  // Add elevated shadow
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1), // subtle shadow
      blurRadius: 10,
      offset: Offset(0, 4), // x, y offset
    ),
  ];
}


/// Day Details Data
class DayDetailsData {
  final String dayName;
  final int dayIndex;
  final int value;
  final int tasksCompleted;
  final int tasksReported;
  final double efficiency;
  final String topLocation;

  const DayDetailsData({
    required this.dayName,
    required this.dayIndex,
    required this.value,
    this.tasksCompleted = 0,
    this.tasksReported = 0,
    this.efficiency = 0.0,
    this.topLocation = 'Unknown',
  });
}