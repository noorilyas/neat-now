import 'package:flutter/material.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/dashboard_tab_models.dart';

import '../../models/employee/leaderboard_models.dart';

class DashboardTabViewModel extends ChangeNotifier {
  // Core Data
  final DashboardEmployee employee;
  final EmployeeStats stats;
  final List<Report> activeReports;
  final List<LeaderboardEntry> topThree;
  final int overdueCount;
  final bool isDemoMode;

  DashboardTabViewModel({
    required Map<String, dynamic> employeeData,
    required this.stats,
    required this. activeReports,
    required this.topThree,
    required this.overdueCount,
    required this.isDemoMode,
  }) : employee = DashboardEmployee.fromMap(employeeData);

  // Employee Getters
  String get employeeName => employee.name;
  String get firstName => employee.firstName;
  String get employeeEmail => employee.email;
  String?  get profileImage => employee.profileImage;
  String get position => employee.position;
  int get rank => employee.rank;
  String get avatarInitial => employee. avatarInitial;

  // Greeting
  GreetingData get greetingData => GreetingData. fromTimeOfDay();
  String get greeting => greetingData.greeting;

  // Performance
  PerformanceData get performanceData => const PerformanceData();
  double get weeklyProgress => performanceData.progress;
  String get weeklyProgressText => performanceData.progressText;

  // Stats
  List<StatCardData> get statCards => [
    StatCardData. total(stats.totalReports),
    StatCardData. completed(stats.resolvedReports),
    StatCardData.inProgress(stats.inProgressReports),
    StatCardData.pending(stats.pendingReports),
  ];

  // Quick Actions
  List<QuickActionData> get quickActions => QuickActionData.defaultActions;

  // Reports
  bool get hasActiveReports => activeReports.isNotEmpty;

  List<Report> getDisplayReports(int maxCount) {
    return activeReports.take(maxCount).toList();
  }

  int getRemainingReportsCount(int maxCount) {
    return activeReports.length > maxCount
        ? activeReports.length - maxCount
        : 0;
  }

  ReportsDisplayConfig getReportsConfig(dynamic responsive) {
    return ReportsDisplayConfig.fromResponsive(responsive);
  }

  // Leaderboard
  bool get hasLeaderboard => topThree.isNotEmpty;

  LeaderboardDisplayConfig getLeaderboardConfig(dynamic responsive) {
    return LeaderboardDisplayConfig.fromResponsive(responsive);
  }

  PodiumColors getPodiumColors(int position) {
    return PodiumColors.forPosition(position);
  }

  bool isCurrentUser(LeaderboardEntry entry) {
    return entry.id. toString() == employee.id;
  }

  // Helpers - Waste Type
  Color getWasteTypeColor(String type) => WasteTypeColors.getColor(type);
  IconData getWasteTypeIcon(String type) => WasteTypeColors.getIcon(type);

  // Helpers - Status
  Color getStatusColor(String status) => ReportStatusColors. getColor(status);
  IconData getStatusIcon(String status) => ReportStatusColors.getIcon(status);
  String formatStatus(String status) => ReportStatusColors.formatStatus(status);

  // Dashboard Data
  DashboardData get dashboardData => DashboardData(
    employee: employee,
    statCards: statCards,
    quickActions: quickActions,
    activeReports: activeReports,
    topThreeLeaderboard: topThree,
    overdueCount: overdueCount,
    isDemoMode:  isDemoMode,
    weeklyProgress: weeklyProgress,
  );
}