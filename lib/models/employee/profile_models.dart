import 'package:flutter/material.dart';

/// ==================== PROFILE MODELS ====================

/// Employee Profile Data
class EmployeeProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String?  profileImage;
  final String employeeId;

  EmployeeProfile({
    required this.id,
    required this.name,
    required this.email,
    required this. phone,
    this.profileImage,
    required this.employeeId,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    return EmployeeProfile(
      id: json['id']?. toString() ?? '',
      name: json['name'] ?? json['fullName'] ?? '',
      email:  json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? json['avatar'],
      employeeId: json['employeeId'] ?? json['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':  id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'employeeId': employeeId,
    };
  }

  EmployeeProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) {
    return EmployeeProfile(
      id: id,
      name: name ?? this. name,
      email: email ??  this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this. profileImage,
      employeeId: employeeId,
    );
  }
}

/// Employee Stats
class EmployeeStats {
  final double rating;
  final int completedTasks;
  final int pendingTasks;
  final int totalPoints;

  EmployeeStats({
    required this.rating,
    required this.completedTasks,
    required this.pendingTasks,
    required this. totalPoints,
  });

  factory EmployeeStats.fromJson(Map<String, dynamic> json) {
    return EmployeeStats(
      rating: (json['rating'] ??  json['averageRating'] ?? 0.0).toDouble(),
      completedTasks:  json['completedTasks'] ??  json['completed'] ?? 0,
      pendingTasks: json['pendingTasks'] ?? json['pending'] ??  0,
      totalPoints:  json['totalPoints'] ?? json['points'] ?? 0,
    );
  }

  int get totalTasks => completedTasks + pendingTasks;
  double get completionRate => totalTasks > 0 ? completedTasks / totalTasks :  0.0;
}

/// Badge Tier
enum BadgeTier { platinum, gold, silver, bronze, none }

extension BadgeTierExtension on BadgeTier {
  String get name {
    switch (this) {
      case BadgeTier.platinum:
        return 'Platinum';
      case BadgeTier.gold:
        return 'Gold';
      case BadgeTier.silver:
        return 'Silver';
      case BadgeTier.bronze:
        return 'Bronze';
      case BadgeTier.none:
        return 'Member';
    }
  }

  IconData get icon {
    switch (this) {
      case BadgeTier.platinum:
        return Icons.diamond_rounded;
      case BadgeTier.gold:
        return Icons. workspace_premium_rounded;
      case BadgeTier.silver:
        return Icons.military_tech_rounded;
      case BadgeTier.bronze:
        return Icons.emoji_events_rounded;
      case BadgeTier.none:
        return Icons.person_rounded;
    }
  }

  List<Color> get colors {
    switch (this) {
      case BadgeTier.platinum:
        return [const Color(0xFFE8E8E8), const Color(0xFFB8B8B8), const Color(0xFFE8E8E8)];
      case BadgeTier.gold:
        return [const Color(0xFFFFD700), const Color(0xFFFFA500), const Color(0xFFFFD700)];
      case BadgeTier.silver:
        return [const Color(0xFFE8E8E8), const Color(0xFFC0C0C0), const Color(0xFFE8E8E8)];
      case BadgeTier.bronze:
        return [const Color(0xFFDDA15E), const Color(0xFFCD7F32), const Color(0xFFDDA15E)];
      case BadgeTier. none:
        return [const Color(0xFF9CA3AF), const Color(0xFF6B7280), const Color(0xFF9CA3AF)];
    }
  }

  Color get glowColor {
    switch (this) {
      case BadgeTier.platinum:
        return const Color(0xFFE8E8E8);
      case BadgeTier.gold:
        return const Color(0xFFFFD700);
      case BadgeTier.silver:
        return const Color(0xFFC0C0C0);
      case BadgeTier.bronze:
        return const Color(0xFFCD7F32);
      case BadgeTier.none:
        return const Color(0xFF9CA3AF);
    }
  }

  static BadgeTier fromRating(double rating) {
    if (rating >= 4.8) return BadgeTier.platinum;
    if (rating >= 4.5) return BadgeTier.gold;
    if (rating >= 4.0) return BadgeTier.silver;
    if (rating >= 3.5) return BadgeTier.bronze;
    return BadgeTier.none;
  }
}

/// Badge Info
class BadgeInfo {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final DateTime earnedAt;

  BadgeInfo({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.earnedAt,
  });
}

/// Task History Item
class TaskHistoryItem {
  final String id;
  final String type;
  final String location;
  final DateTime completedAt;
  final double rating;
  final String?  imageUrl;

  TaskHistoryItem({
    required this.id,
    required this.type,
    required this.location,
    required this. completedAt,
    required this.rating,
    this.imageUrl,
  });

  factory TaskHistoryItem.fromJson(Map<String, dynamic> json) {
    return TaskHistoryItem(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? json['wasteType'] ?? '',
      location: json['location'] ?? json['address'] ?? '',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : DateTime.now(),
      rating: (json['rating'] ??  0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? json['image'],
    );
  }
}

/// Settings Model
class SettingsModel {
  final bool notificationsEnabled;
  final bool locationEnabled;
  final bool darkModeEnabled;
  final bool soundEnabled;

  SettingsModel({
    this.notificationsEnabled = true,
    this.locationEnabled = true,
    this.darkModeEnabled = false,
    this. soundEnabled = true,
  });

  SettingsModel copyWith({
    bool? notificationsEnabled,
    bool? locationEnabled,
    bool? darkModeEnabled,
    bool? soundEnabled,
  }) {
    return SettingsModel(
      notificationsEnabled: notificationsEnabled ?? this. notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      darkModeEnabled: darkModeEnabled ?? this. darkModeEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled':  notificationsEnabled,
      'locationEnabled': locationEnabled,
      'darkModeEnabled': darkModeEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      locationEnabled: json['locationEnabled'] ?? true,
      darkModeEnabled:  json['darkModeEnabled'] ??  false,
      soundEnabled: json['soundEnabled'] ?? true,
    );
  }
}

/// FAQ Item
class FAQItem {
  final String question;
  final String answer;

  FAQItem(this.question, this.answer);
}