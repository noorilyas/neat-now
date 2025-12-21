import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';

class AnalyticsTabViewModel extends ChangeNotifier {
  final AnalyticsData analyticsData;
  AnalyticsState _state = const AnalyticsState();

  AnalyticsTabViewModel({required this.analyticsData});

  // State Getters
  AnalyticsState get state => _state;
  AnalyticsPeriod get selectedPeriod => _state.selectedPeriod;
  ChartType get selectedChartType => _state.selectedChartType;
  bool get showComparison => _state.showComparison;
  bool get isExporting => _state.isExporting;

  // Data Getters
  List<int> get weeklyData => analyticsData.weeklyData;
  List<int> get dailyResolved => analyticsData.dailyResolved;
  List<int> get dailyReported => analyticsData.dailyReported;
  List<TopLocation> get topLocations => analyticsData.topLocations;

  // Metrics
  List<MetricCardData> get metricCards => [
    MetricCardData. tasks(
      value: analyticsData.totalTasks,
      trend: '+12%',
      trendUp: true,
    ),
    MetricCardData. completed(
      value: analyticsData.completedTasks,
      trend:  '+8%',
      trendUp:  true,
    ),
    MetricCardData.efficiency(
      value: analyticsData.efficiency,
      trend: '+5%',
      trendUp:  true,
    ),
    MetricCardData.responseTime(
      value: analyticsData.avgResponseTime,
      trend: '-3m',
      trendUp: true,
    ),
  ];

  // Distribution
  List<DistributionItem> get distributionItems {
    final colors = AnalyticsDesign. getDistributionColors();
    return [
      DistributionItem('Plastic', analyticsData.plasticTasks, colors[0]),
      DistributionItem('Organic', analyticsData.organicTasks, colors[1]),
      DistributionItem('Electronic', analyticsData.electronicTasks, colors[2]),
      DistributionItem('Hazardous', analyticsData.hazardousTasks, colors[3]),
      DistributionItem('Other', analyticsData.otherTasks, colors[4]),
    ];
  }

  int get totalDistributionCount {
    return distributionItems.fold<int>(0, (sum, item) => sum + item.count);
  }

  // Efficiency Data
  int get efficiencyPercentage => analyticsData.efficiency;
  int get avgResponseTime => analyticsData.avgResponseTime;
  int get completionRate => analyticsData.completionRate. round();
  double get userRating => analyticsData.userRating;

  // Comparison Data
  List<int> generateComparisonData(List<int> currentData) {
    return currentData.map((v) => (v * 0.85).round()).toList();
  }

  // Day Details
  DayDetailsData getDayDetails(int dayIndex, int value) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final dayName = dayIndex < days.length ? days[dayIndex] : 'Day ${dayIndex + 1}';

    return DayDetailsData(
      dayName: dayName,
      dayIndex: dayIndex,
      value: value,
      tasksCompleted: dayIndex < dailyResolved.length ? dailyResolved[dayIndex] : 0,
      tasksReported: dayIndex < dailyReported.length ? dailyReported[dayIndex] : 0,
      efficiency: value > 0 ? (value * 0.85) :  0,
      topLocation:  topLocations. isNotEmpty ? topLocations. first.name : 'Unknown',
    );
  }

  // State Mutations
  void setPeriod(AnalyticsPeriod period) {
    _state = _state.copyWith(selectedPeriod: period);
    notifyListeners();
  }

  void setChartType(ChartType type) {
    _state = _state.copyWith(selectedChartType: type);
    notifyListeners();
  }

  void toggleMetric(String metricKey) {
    final newMetrics = Map<String, bool>.from(_state.visibleMetrics);
    newMetrics[metricKey] = !(newMetrics[metricKey] ?? true);
    _state = _state.copyWith(visibleMetrics: newMetrics);
    notifyListeners();
  }

  void toggleComparison() {
    _state = _state. copyWith(showComparison:  !_state.showComparison);
    notifyListeners();
  }

  bool isMetricVisible(String key) => _state.isMetricVisible(key);

  // Export
  Future<void> exportData(ExportFormat format) async {
    _state = _state.copyWith(isExporting: true);
    notifyListeners();

    // Simulate export
    await Future.delayed(const Duration(seconds: 2));

    _state = _state.copyWith(isExporting: false);
    notifyListeners();
  }

  // Chart Type Options
  List<ChartTypeOption> get chartTypeOptions => [
    ChartTypeOption(ChartType.line, Icons.show_chart_rounded),
    ChartTypeOption(ChartType.bar, Icons. bar_chart_rounded),
    ChartTypeOption(ChartType.area, Icons.area_chart_rounded),
  ];

  // Export Options
  List<ExportOption> get exportOptions => [
    ExportOption(ExportFormat.pdf, Icons.picture_as_pdf_rounded, 'PDF'),
    ExportOption(ExportFormat.csv, Icons.table_chart_rounded, 'CSV'),
    ExportOption(ExportFormat.excel, Icons.grid_on_rounded, 'Excel'),
    ExportOption(ExportFormat.image, Icons.image_rounded, 'Image'),
  ];

  // Periods
  List<String> get periods => [
    AnalyticsPeriod.week. displayName,
    AnalyticsPeriod.month.displayName,
    AnalyticsPeriod.year.displayName,
  ];

  String getPeriodLabel(AnalyticsPeriod period) => period.displayName;

  // Days of Week
  List<String> get daysOfWeek => ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  List<String> get fullDaysOfWeek => [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
}

// Helper Classes
class ChartTypeOption {
  final ChartType type;
  final IconData icon;

  const ChartTypeOption(this.type, this.icon);
}

class ExportOption {
  final ExportFormat format;
  final IconData icon;
  final String label;

  const ExportOption(this.format, this.icon, this.label);
}