

import '../employee_models.dart';

class EmployeeDashboardData {
  final EmployeeUser user;
  final EmployeeStats stats;
  final List<Report> reports;
  final List<Report> acceptedReports;
  final AnalyticsData analytics;
  final List<LeaderboardEntry> leaderboard;
  final bool isDemoMode;

  const EmployeeDashboardData({
    required this.user,
    required this.stats,
    required this.reports,
    required this.acceptedReports,
    required this.analytics,
    required this.leaderboard,
    this.isDemoMode = false,
  });


}

class EmployeeUser {
  final String id;
  final String name;
  final String email;
  final String?  profileImage;
  final String? phone;
  final String role;
  final DateTime createdAt;

  const EmployeeUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this. phone,
    this.role = 'employee',
    required this.createdAt,
  });

  factory EmployeeUser.fromMap(Map<String, dynamic> map) {
    return EmployeeUser(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? 'Employee',
      email: map['email'] ?? '',
      profileImage: map['profile_image'] ?? map['profileImage'],
      phone:  map['phone'],
      role: map['role'] ?? 'employee',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get avatarInitial => name.isNotEmpty ? name[0]. toUpperCase() : 'E';
}

class OverdueAlert {
  final int count;
  final List<Report> reports;

  const OverdueAlert({
    required this.count,
    required this. reports,
  });

  bool get hasOverdue => count > 0;
}
