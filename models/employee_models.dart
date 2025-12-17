import 'dart:ui';

import 'package:flutter/material.dart';

/// EmployeeStats Model


/// AnalyticsData Model


/// Report Model


/// User Model (for display purposes)


/// User Model
class User {
  final int id;
  final String name;
  final String email;
  final String status;
  final int reportsCount;
  final DateTime joinDate;
  final String?  profileImage;
  final String? phoneNumber;

  User({
    required this.id,
    required this.name,
    required this. email,
    required this.status,
    required this.reportsCount,
    required this.joinDate,
    this. profileImage,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ??  '',
      status: json['status'] ?? 'inactive',
      reportsCount: json['reports_count'] ?? json['reportsCount'] ?? 0,
      joinDate: json['join_date'] != null || json['joinDate'] != null
          ?  DateTime.tryParse((json['join_date'] ?? json['joinDate']).toString()) ?? DateTime.now()
          : DateTime. now(),
      profileImage: json['profile_image'] ?? json['profileImage'],
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status,
      'reports_count': reportsCount,
      'join_date': joinDate. toIso8601String(),
      'profile_image': profileImage,
      'phone_number': phoneNumber,
    };
  }
}

/// Analytics Data Model


/// Photo Model
class Photo {
  final int id;
  final String imageUrl;
  final String wasteType;
  final String location;
  final String uploadedBy;
  final int uploadedById;
  final DateTime uploadDate;
  final String? status;
  final double? confidence;

  Photo({
  required this. id,
  required this.imageUrl,
  required this. wasteType,
  required this.location,
  required this.uploadedBy,    required this.uploadedById,
    required this.uploadDate,
    this.status,
    this.confidence,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? 'https://via. placeholder.com/300',
      wasteType: json['waste_type'] ?? json['wasteType'] ?? 'Unknown',
      location: json['location'] ??  'Unknown Location',
      uploadedBy: json['uploaded_by'] ?? json['uploadedBy'] ?? 'Anonymous',
      uploadedById: json['uploaded_by_id'] ?? json['uploadedById'] ?? 0,
      uploadDate: json['upload_date'] != null || json['uploadDate'] != null
          ?  DateTime.tryParse((json['upload_date'] ?? json['uploadDate']).toString()) ?? DateTime.now()
          : DateTime. now(),
      status: json['status'],
      confidence: json['confidence']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'waste_type': wasteType,
      'location': location,
      'uploaded_by': uploadedBy,
      'uploaded_by_id': uploadedById,
      'upload_date': uploadDate. toIso8601String(),
      'status': status,
      'confidence': confidence,
    };
  }
}
// Add this method to your existing EmployeeService class
// Add this class to your existing employee_models.dart file

/// LeaderboardEntry - Represents a worker in the leaderboard


/// ==================== EMPLOYEE STATS MODEL ====================
class EmployeeStats {
  final int totalReports;
  final int resolvedReports;
  final int pendingReports;
  final int inProgressReports;
  final double resolutionRate;
  final double avgResolutionTime;
  final int thisWeekResolved;
  final int thisMonthResolved;
  final double efficiency;
  final double rating;
  final int avgResponseTime;

  EmployeeStats({
    required this.totalReports,
    required this. resolvedReports,
    required this. pendingReports,
    required this. inProgressReports,
    required this. resolutionRate,
    required this. avgResolutionTime,
    required this.thisWeekResolved,
    required this.thisMonthResolved,
    this.efficiency = 0,
    this.rating = 0,
    this.avgResponseTime = 0,
  });

  factory EmployeeStats.fromJson(Map<String, dynamic> json) {
    final totalReports = json['total_reports'] ??  json['totalReports'] ?? 0;
    final resolvedReports = json['resolved_reports'] ?? json['resolvedReports'] ?? 0;

    return EmployeeStats(
      totalReports: totalReports,
      resolvedReports: resolvedReports,
      pendingReports: json['pending_reports'] ?? json['pendingReports'] ?? 0,
      inProgressReports: json['in_progress_reports'] ?? json['inProgressReports'] ?? 0,
      resolutionRate: (json['resolution_rate'] ?? json['resolutionRate'] ??  0).toDouble(),
      avgResolutionTime: (json['avg_resolution_time'] ?? json['avgResolutionTime'] ?? 0).toDouble(),
      thisWeekResolved: json['this_week_resolved'] ?? json['thisWeekResolved'] ??  0,
      thisMonthResolved: json['this_month_resolved'] ??  json['thisMonthResolved'] ?? 0,
      efficiency: totalReports > 0 ? (resolvedReports / totalReports * 100) : 0,
      rating: (json['rating'] ?? json['user_rating'] ?? 4.5).toDouble(),
      avgResponseTime: (json['avg_response_time'] ??  json['avgResponseTime'] ?? 15).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_reports': totalReports,
      'resolved_reports': resolvedReports,
      'pending_reports': pendingReports,
      'in_progress_reports': inProgressReports,
      'resolution_rate': resolutionRate,
      'avg_resolution_time': avgResolutionTime,
      'this_week_resolved': thisWeekResolved,
      'this_month_resolved': thisMonthResolved,
      'efficiency': efficiency,
      'rating': rating,
      'avg_response_time': avgResponseTime,
    };
  }
}

/// ==================== ANALYTICS DATA MODEL ====================
/// ==================== ANALYTICS DATA MODEL ====================
class AnalyticsData {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int inProgressTasks;
  final int efficiency;
  final int avgResponseTime;
  final double completionRate;
  final double userRating;
  final double growthRate;
  final List<int> weeklyData;
  final Map<String, int> wasteDistribution;
  final List<TopLocation> topLocations;
  final List<int> dailyResolved;
  final List<int> dailyReported;
  final Map<String, dynamic> reportsOverTime; // Added for line chart

  // Task breakdown by type
  final int plasticTasks;
  final int organicTasks;
  final int electronicTasks;
  final int hazardousTasks;
  final int otherTasks;

  AnalyticsData({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.inProgressTasks,
    required this.efficiency,
    required this.avgResponseTime,
    required this.completionRate,
    required this.userRating,
    required this. growthRate,
    required this.weeklyData,
    required this.wasteDistribution,
    required this.topLocations,
    required this.dailyResolved,
    required this.dailyReported,
    required this.reportsOverTime,
    required this.plasticTasks,
    required this.organicTasks,
    required this.electronicTasks,
    required this.hazardousTasks,
    required this.otherTasks,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    // Parse waste distribution
    final wasteDistMap = <String, int>{};
    if (json['waste_distribution'] != null) {
      (json['waste_distribution'] as Map<String, dynamic>). forEach((key, value) {
        wasteDistMap[key] = (value as num).toInt();
      });
    }

    // Parse top locations
    final topLocationsList = <TopLocation>[];
    if (json['top_locations'] != null) {
      for (var loc in json['top_locations']) {
        topLocationsList.add(TopLocation.fromJson(loc));
      }
    }

    // Parse daily activity
    List<int> dailyResolved = [5, 8, 6, 9, 7, 4, 3];
    List<int> dailyReported = [6, 7, 8, 6, 9, 5, 4];
    if (json['daily_activity'] != null) {
      dailyResolved = List<int>.from(json['daily_activity']['resolved'] ?? dailyResolved);
      dailyReported = List<int>. from(json['daily_activity']['reported'] ?? dailyReported);
    }

    // Parse reports over time
    Map<String, dynamic> reportsOverTime = {
      'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
      'data': [18, 25, 22, 30, 28, 33],
    };
    if (json['reports_over_time'] != null) {
      reportsOverTime = Map<String, dynamic>. from(json['reports_over_time']);
    }

    // Parse weekly data from reports over time
    List<int> weeklyData = [18, 25, 22, 30, 28, 33, 35];
    if (reportsOverTime['data'] != null) {
      weeklyData = List<int>. from(reportsOverTime['data']);
    }

    // Parse performance metrics
    final perfMetrics = json['performance_metrics'] ?? {};

    return AnalyticsData(
      totalTasks: json['total_reports'] ?? json['totalTasks'] ?? 0,
      completedTasks: json['resolved_reports'] ?? json['completedTasks'] ??  0,
      pendingTasks: json['pending_reports'] ?? json['pendingTasks'] ??  0,
      inProgressTasks: json['in_progress_reports'] ?? json['inProgressTasks'] ?? 0,
      efficiency: (perfMetrics['efficiency_score'] ?? json['efficiency'] ?? 85).toInt(),
      avgResponseTime: (perfMetrics['response_time_avg'] ?? json['avg_resolution_time_hours'] ?? 3). toInt(),
      completionRate: (json['resolution_rate'] ?? json['completionRate'] ?? 85).toDouble(),
      userRating: (perfMetrics['customer_satisfaction'] ?? json['userRating'] ?? 4.5).toDouble(),
      growthRate: (json['growth_rate'] ?? json['growthRate'] ?? 10).toDouble(),
      weeklyData: weeklyData,
      wasteDistribution: wasteDistMap,
      topLocations: topLocationsList,
      dailyResolved: dailyResolved,
      dailyReported: dailyReported,
      reportsOverTime: reportsOverTime,
      plasticTasks: wasteDistMap['Plastic Waste'] ?? 45,
      organicTasks: wasteDistMap['Organic Waste'] ?? 32,
      electronicTasks: wasteDistMap['Electronic Waste'] ?? 18,
      hazardousTasks: wasteDistMap['Hazardous Waste'] ?? 12,
      otherTasks: (wasteDistMap['Mixed Waste'] ?? 25) +
          (wasteDistMap['Construction Debris'] ?? 14) +
          (wasteDistMap['Medical Waste'] ?? 10),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_reports': totalTasks,
      'resolved_reports': completedTasks,
      'pending_reports': pendingTasks,
      'in_progress_reports': inProgressTasks,
      'efficiency': efficiency,
      'avg_response_time': avgResponseTime,
      'completion_rate': completionRate,
      'user_rating': userRating,
      'growth_rate': growthRate,
      'weekly_data': weeklyData,
      'waste_distribution': wasteDistribution,
      'reports_over_time': reportsOverTime,
    };
  }
}

/// Top Location model for analytics
class TopLocation {
  final String name;
  final int reports;

  TopLocation({required this.name, required this.reports});

  factory TopLocation. fromJson(Map<String, dynamic> json) {
    return TopLocation(
      name: json['name'] ?? 'Unknown',
      reports: json['reports'] ?? 0,
    );
  }
}

/// ==================== REPORT MODEL ====================
class Report {
  final int id;
  final String type;
  final String location;
  final String status;
  final String userName;
  final int userId;
  final DateTime date;
  final String?  imageUrl;
  final String? description;
  final double?  latitude;
  final double? longitude;
  final String? assignedTo;
  final DateTime?  resolvedAt;
  final String? resolvedBy;
  final double? aiConfidence;
  final String? verificationImage;
  final double? verificationLatitude;
  final double? verificationLongitude;
  final String? verificationLocation;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final String? title;
  final String? priority;
  final String? afterImageUrl;
  final double? resolutionLatitude;
  final double? resolutionLongitude;

  Report({
    required this.id,
    required this. type,
    required this.location,
    required this.status,
    required this.userName,
    required this.userId,
    required this. date,
    this.afterImageUrl,
    this.assignedAt,
    this. acceptedAt,
    this.title,
    this. priority,
    this.resolutionLatitude,
    this.resolutionLongitude,
    this. imageUrl,
    this.description,
    this.latitude,
    this. longitude,
    this.assignedTo,
    this.resolvedAt,
    this. resolvedBy,
    this.aiConfidence,
    this.verificationImage,
    this.verificationLatitude,
    this.verificationLongitude,
    this.verificationLocation,
  });

  factory Report. fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? 0,
      type: json['type'] ?? json['waste_type'] ?? 'Unknown',
      location: json['location'] ??  'Unknown Location',
      status: json['status'] ??  'pending',
      userName: json['user_name'] ?? json['userName'] ?? 'Anonymous',
      userId: json['user_id'] ?? json['userId'] ?? 0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : json['created_at'] != null
          ? DateTime. tryParse(json['created_at']. toString()) ?? DateTime. now()
          : DateTime.now(),
      imageUrl: json['image_url'] ?? json['imageUrl'],
      description: json['description'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      assignedTo: json['assigned_to'] ?? json['assignedTo'],
      assignedAt: json['assigned_at'] != null
          ? DateTime.tryParse(json['assigned_at'].toString())
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'].toString())
          : null,
      title: json['title'],
      priority: json['priority'],
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'].toString())
          : null,
      resolvedBy: json['resolved_by'] ?? json['resolvedBy'],
      aiConfidence: _parseDouble(json['ai_confidence'] ?? json['aiConfidence']),
      verificationImage: json['verification_image'] ?? json['verificationImage'],
      verificationLatitude: _parseDouble(json['verification_latitude'] ?? json['verificationLatitude']),
      verificationLongitude: _parseDouble(json['verification_longitude'] ?? json['verificationLongitude']),
      verificationLocation: json['verification_location'] ?? json['verificationLocation'],
      afterImageUrl: json['after_image_url'] ?? json['afterImageUrl'],
      resolutionLatitude: _parseDouble(json['resolution_latitude'] ?? json['resolutionLatitude']),
      resolutionLongitude: _parseDouble(json['resolution_longitude'] ?? json['resolutionLongitude']),
    );
  }

  static double?  _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'location': location,
      'status': status,
      'user_name': userName,
      'user_id': userId,
      'date': date.toIso8601String(),
      'image_url': imageUrl,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'assigned_to': assignedTo,
      'assigned_at': assignedAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'title': title,
      'priority': priority,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'ai_confidence': aiConfidence,
      'verification_image': verificationImage,
      'verification_latitude': verificationLatitude,
      'verification_longitude': verificationLongitude,
      'verification_location': verificationLocation,
      'after_image_url': afterImageUrl,
      'resolution_latitude': resolutionLatitude,
      'resolution_longitude': resolutionLongitude,
    };
  }

  Report copyWith({
    int? id,
    String? type,
    String? location,
    String?  status,
    String? userName,
    int? userId,
    DateTime? date,
    String? imageUrl,
    String? description,
    double? latitude,
    double? longitude,
    String? assignedTo,
    DateTime? assignedAt,
    DateTime? acceptedAt,
    String?  title,
    String? priority,
    DateTime? resolvedAt,
    String? resolvedBy,
    double? aiConfidence,
    String?  verificationImage,
    double? verificationLatitude,
    double? verificationLongitude,
    String? verificationLocation,
    String?  afterImageUrl,
    double? resolutionLatitude,
    double? resolutionLongitude,
  }) {
    return Report(
      id: id ??  this.id,
      type: type ??  this.type,
      location: location ??  this.location,
      status: status ??  this.status,
      userName: userName ??  this.userName,
      userId: userId ??  this.userId,
      date: date ??  this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this. description,
      latitude: latitude ?? this. latitude,
      longitude: longitude ?? this. longitude,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedAt: assignedAt ?? this. assignedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      resolvedAt: resolvedAt ??  this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      verificationImage: verificationImage ?? this. verificationImage,
      verificationLatitude: verificationLatitude ?? this.verificationLatitude,
      verificationLongitude: verificationLongitude ?? this.verificationLongitude,
      verificationLocation: verificationLocation ??  this.verificationLocation,
      afterImageUrl: afterImageUrl ?? this.afterImageUrl,
      resolutionLatitude: resolutionLatitude ?? this.resolutionLatitude,
      resolutionLongitude: resolutionLongitude ??  this.resolutionLongitude,
    );
  }

  /// Get display title (falls back to type + id if no title)
  String get displayTitle => title ?? '$type - #$id';

  /// Get the date when report was accepted/assigned for overdue calculation
  DateTime get acceptanceDate => acceptedAt ?? assignedAt ?? date;

  /// Check if report has location data
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if report is resolved
  bool get isResolved => status == 'resolved';

  /// Check if report is pending
  bool get isPending => status == 'pending';

  /// Check if report is in progress
  bool get isInProgress => status == 'in-progress' || status == 'in_progress';

  /// Check if report is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if report is active (accepted or in progress)
  bool get isActive => isAccepted || isInProgress;

  /// Check if report has verification data
  bool get hasVerification => verificationImage != null || verificationLatitude != null;

  /// Check if report is overdue (more than 2 days since acceptance)
  bool get isOverdue {
    if (!isActive) return false;
    final daysSinceAccepted = DateTime.now().difference(acceptanceDate).inDays;
    return daysSinceAccepted >= 2;
  }

  /// Get days since accepted
  int get daysSinceAccepted => DateTime.now().difference(acceptanceDate).inDays;

  /// Get priority level
  String get priorityLevel => priority ??  'medium';

  /// Get priority color
  Color get priorityColor {
    switch (priorityLevel. toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.grey;
      case 'accepted':
        return Colors. blue;
      case 'in-progress':
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'verified':
        return const Color(0xFF2AC2AB);
      default:
        return Colors. grey;
    }
  }
}

/// ==================== LEADERBOARD ENTRY MODEL ====================
class LeaderboardEntry {
  final String id;
  final String name;
  final String?  profileImage;
  final int points;
  final double rating;
  final int tasksCompleted;
  final int rank;
  final int trend; // positive = up, negative = down, 0 = same
  final List<String> badges;

  LeaderboardEntry({
    required this.id,
    required this.name,
    this. profileImage,
    required this.points,
    required this. rating,
    required this.tasksCompleted,
    required this.rank,
    this.trend = 0,
    this.badges = const [],
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      profileImage: json['profile_image'] ??  json['profileImage'],
      points: json['points'] ?? 0,
      rating: (json['rating'] ??  0.0).toDouble(),
      tasksCompleted: json['tasks_completed'] ?? json['tasksCompleted'] ?? 0,
      rank: json['rank'] ?? 0,
      trend: json['trend'] ?? 0,
      badges: json['badges'] != null
          ? List<String>.from(json['badges'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'points': points,
      'rating': rating,
      'tasks_completed': tasksCompleted,
      'rank': rank,
      'trend': trend,
      'badges': badges,
    };
  }

  /// Get trend icon
  IconData get trendIcon {
    if (trend > 0) return Icons.arrow_upward_rounded;
    if (trend < 0) return Icons.arrow_downward_rounded;
    return Icons. remove_rounded;
  }

  /// Get trend color
  Color get trendColor {
    if (trend > 0) return Colors.green;
    if (trend < 0) return Colors.red;
    return Colors.grey;
  }

  /// Get rank medal color
  Color get rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF667EEA); // Default purple
    }
  }

  /// Check if user is in top 3
  bool get isTopThree => rank >= 1 && rank <= 3;
}

/// ==================== NOTIFICATION DATA MODEL ====================
class NotificationData {
  final int id;
  final String title;
  final String body;
  final String? subtitle;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;

  NotificationData({
    required this.id,
    required this. title,
    required this.body,
    this.subtitle,
    required this. type,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['message'] ?? json['body'] ?? '',
      subtitle: json['subtitle'],
      type: _parseNotificationType(json['type']),
      data: json['data'] ??  {},
      timestamp: json['time'] != null
          ? DateTime.tryParse(json['time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['read'] ?? false,
    );
  }

  static NotificationType _parseNotificationType(String?  type) {
    switch (type?. toLowerCase()) {
      case 'assignment':
      case 'task_assignment':
        return NotificationType.taskAssignment;
      case 'urgent':
        return NotificationType.urgent;
      case 'verification':
        return NotificationType.verification;
      case 'summary':
        return NotificationType.summary;
      case 'proximity':
      case 'proximity_task':
        return NotificationType.proximityTask;
      case 'badge':
      case 'badge_earned':
        return NotificationType.badgeEarned;
      default:
        return NotificationType.general;
    }
  }

  NotificationData copyWith({
    int? id,
    String?  title,
    String? body,
    String? subtitle,
    NotificationType?  type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationData(
      id: id ?? this. id,
      title: title ?? this. title,
      body: body ?? this. body,
      subtitle: subtitle ?? this. subtitle,
      type: type ?? this. type,
      data: data ?? this. data,
      timestamp: timestamp ?? this. timestamp,
      isRead: isRead ??  this.isRead,
    );
  }

  /// Get icon based on notification type
  IconData get icon {
    switch (type) {
      case NotificationType.taskAssignment:
        return Icons. assignment_rounded;
      case NotificationType.urgent:
        return Icons.warning_amber_rounded;
      case NotificationType. verification:
        return Icons.verified_rounded;
      case NotificationType. summary:
        return Icons.summarize_rounded;
      case NotificationType.proximityTask:
        return Icons. location_on_rounded;
      case NotificationType.badgeEarned:
        return Icons.military_tech_rounded;
      case NotificationType.general:
      default:
        return Icons.notifications_rounded;
    }
  }

  /// Get color based on notification type
  Color get color {
    switch (type) {
      case NotificationType.taskAssignment:
        return Colors.blue;
      case NotificationType.urgent:
        return Colors.red;
      case NotificationType.verification:
        return Colors.green;
      case NotificationType.summary:
        return Colors. purple;
      case NotificationType.proximityTask:
        return Colors.orange;
      case NotificationType.badgeEarned:
        return Colors.amber;
      case NotificationType.general:
      default:
        return const Color(0xFF2AC2AB);
    }
  }
}

/// Notification types
enum NotificationType {
  taskAssignment,
  urgent,
  verification,
  summary,
  proximityTask,
  badgeEarned,
  general,
}

/// ==================== TASK ASSIGNMENT MODEL ====================
class TaskAssignment {
  final int taskId;
  final int reportId;
  final String assignmentType; // 'manual', 'proximity', 'auto'
  final String? assignedBy;
  final DateTime assignedAt;
  final DateTime? expiresAt;
  final bool isAccepted;
  final bool isRejected;
  final String? rejectionReason;
  final Report? report;

  TaskAssignment({
    required this.taskId,
    required this.reportId,
    required this. assignmentType,
    this.assignedBy,
    required this. assignedAt,
    this.expiresAt,
    this. isAccepted = false,
    this.isRejected = false,
    this.rejectionReason,
    this.report,
  });

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      taskId: json['task_id'] ?? json['taskId'] ?? 0,
      reportId: json['report_id'] ?? json['reportId'] ?? 0,
      assignmentType: json['assignment_type'] ?? json['assignmentType'] ?? 'manual',
      assignedBy: json['assigned_by'] ?? json['assignedBy'],
      assignedAt: json['assigned_at'] != null
          ?  DateTime.tryParse(json['assigned_at'].toString()) ?? DateTime.now()
          : DateTime. now(),
      expiresAt: json['expires_at'] != null
          ?  DateTime.tryParse(json['expires_at'].toString())
          : null,
      isAccepted: json['is_accepted'] ?? json['isAccepted'] ??  false,
      isRejected: json['is_rejected'] ?? json['isRejected'] ?? false,
      rejectionReason: json['rejection_reason'] ??  json['rejectionReason'],
      report: json['report'] != null ? Report. fromJson(json['report']) : null,
    );
  }

  /// Check if assignment can still be responded to
  bool get canRespond {
    if (isAccepted || isRejected) return false;
    if (expiresAt == null) return true;
    return DateTime. now().isBefore(expiresAt!);
  }

  /// Get remaining time to respond
  Duration?  get remainingTime {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get remaining minutes
  int get remainingMinutes {
    final remaining = remainingTime;
    if (remaining == null) return -1;
    return remaining.inMinutes;
  }

  /// Check if assignment is expiring soon (< 15 minutes)
  bool get isExpiringSoon {
    final minutes = remainingMinutes;
    return minutes >= 0 && minutes < 15;
  }
}

/// Task assignment result
class TaskAssignmentResult {
  final bool success;
  final String? message;
  final TaskAssignment?  assignment;

  TaskAssignmentResult({
    required this. success,
    this.message,
    this.assignment,
  });
}