// ...  your other models ...

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ==================== LEADERBOARD ENTRY ====================
/// ==================== LEADERBOARD ENTRY ====================
class LeaderboardEntry {
  final String id;
  final String name;
  final String? profileImage;
  final int points;
  final double rating;
  final int tasksCompleted;
  final int?  rank;
  final int?  trend;
  final List<String>? badges;

  LeaderboardEntry({
    required this.id,
    required this.name,
    this. profileImage,
    required this. points,
    required this.rating,
    required this.tasksCompleted,
    this.rank,
    this.trend,
    this.badges,
  });

  factory LeaderboardEntry. fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id:  json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'],
      points: json['points'] ?? 0,
      rating: (json['rating'] ??  0.0).toDouble(),
      tasksCompleted: json['tasksCompleted'] ?? 0,
      rank: json['rank'],
      trend: json['trend'],
      badges: json['badges'] != null
          ? List<String>.from(json['badges'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name':  name,
      'profileImage':  profileImage,
      'points':  points,
      'rating': rating,
      'tasksCompleted': tasksCompleted,
      'rank': rank,
      'trend': trend,
      'badges': badges,
    };
  }

  // Helper getter for trend icon
  IconData?  get trendIcon {
    if (trend == null || trend == 0) return null;
    return trend!  > 0
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
  }

  // Helper getter for trend color
  Color? get trendColor {
    if (trend == null || trend == 0) return null;
    return trend! > 0
        ? const Color(0xFF10B981) // Green
        : const Color(0xFFEF4444); // Red
  }
}

/// ==================== TIER ENUM ====================
enum LeaderboardTier {
  diamond,
  gold,
  silver,
  bronze,
  unranked,
}

extension LeaderboardTierExtension on LeaderboardTier {
  String get name {
    switch (this) {
      case LeaderboardTier.diamond: return 'Diamond';
      case LeaderboardTier.gold: return 'Gold';
      case LeaderboardTier.silver: return 'Silver';
      case LeaderboardTier.bronze: return 'Bronze';
      case LeaderboardTier.unranked: return 'Unranked';
    }
  }

  String get shortName {
    switch (this) {
      case LeaderboardTier.diamond: return 'DIA';
      case LeaderboardTier.gold: return 'GLD';
      case LeaderboardTier.silver: return 'SLV';
      case LeaderboardTier.bronze: return 'BRZ';
      case LeaderboardTier.unranked: return 'URK';
    }
  }

  IconData get icon {
    switch (this) {
      case LeaderboardTier.diamond: return Icons.diamond_rounded;
      case LeaderboardTier.gold: return Icons.workspace_premium_rounded;
      case LeaderboardTier.silver: return Icons. military_tech_rounded;
      case LeaderboardTier.bronze: return Icons.emoji_events_rounded;
      case LeaderboardTier.unranked: return Icons.star_border_rounded;
    }
  }

  Color get primaryColor {
    switch (this) {
      case LeaderboardTier.diamond: return const Color(0xFF00D9FF);
      case LeaderboardTier.gold: return const Color(0xFFFFD700);
      case LeaderboardTier.silver: return const Color(0xFFC0C0C0);
      case LeaderboardTier.bronze: return const Color(0xFFCD7F32);
      case LeaderboardTier.unranked: return const Color(0xFF9CA3AF);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case LeaderboardTier.diamond: return const Color(0xFF00B4D8);
      case LeaderboardTier.gold: return const Color(0xFFFFA500);
      case LeaderboardTier.silver: return const Color(0xFFA8A8A8);
      case LeaderboardTier.bronze: return const Color(0xFFB87333);
      case LeaderboardTier.unranked: return const Color(0xFF6B7280);
    }
  }

  Color get glowColor {
    switch (this) {
      case LeaderboardTier.diamond: return const Color(0xFF48CAE4);
      case LeaderboardTier.gold: return const Color(0xFFFFE55C);
      case LeaderboardTier.silver: return const Color(0xFFE8E8E8);
      case LeaderboardTier.bronze: return const Color(0xFFDDA15E);
      case LeaderboardTier.unranked: return const Color(0xFF9CA3AF);
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case LeaderboardTier.diamond:
        return [
          const Color(0xFF00D9FF),
          const Color(0xFF00B4D8),
          const Color(0xFF0077B6),
        ];
      case LeaderboardTier.gold:
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
          const Color(0xFFFF8C00),
        ];
      case LeaderboardTier. silver:
        return [
          const Color(0xFFE8E8E8),
          const Color(0xFFC0C0C0),
          const Color(0xFFA8A8A8),
        ];
      case LeaderboardTier. bronze:
        return [
          const Color(0xFFDDA15E),
          const Color(0xFFCD7F32),
          const Color(0xFFB87333),
        ];
      case LeaderboardTier.unranked:
        return [
          const Color(0xFF9CA3AF),
          const Color(0xFF6B7280),
        ];
    }
  }

  double get minRating {
    switch (this) {
      case LeaderboardTier.diamond: return 4.5;
      case LeaderboardTier.gold: return 4.0;
      case LeaderboardTier.silver: return 3.5;
      case LeaderboardTier.bronze: return 3.0;
      case LeaderboardTier.unranked: return 0.0;
    }
  }

  double get maxRating {
    switch (this) {
      case LeaderboardTier.diamond: return 5.0;
      case LeaderboardTier.gold: return 4.49;
      case LeaderboardTier.silver: return 3.99;
      case LeaderboardTier.bronze: return 3.49;
      case LeaderboardTier.unranked: return 2.99;
    }
  }

  String get bonus {
    switch (this) {
      case LeaderboardTier.diamond: return '+50% bonus';
      case LeaderboardTier.gold: return '+30% bonus';
      case LeaderboardTier.silver: return '+15% bonus';
      case LeaderboardTier.bronze: return '+5% bonus';
      case LeaderboardTier.unranked: return 'No bonus';
    }
  }

  static LeaderboardTier fromRating(double rating) {
    if (rating >= 4.5) return LeaderboardTier.diamond;
    if (rating >= 4.0) return LeaderboardTier. gold;
    if (rating >= 3.5) return LeaderboardTier.silver;
    if (rating >= 3.0) return LeaderboardTier. bronze;
    return LeaderboardTier.unranked;
  }
}

/// ==================== ACHIEVEMENT MODEL ====================
class Achievement {
  final String name;
  final IconData icon;
  final Color color;

  Achievement({
    required this. name,
    required this.icon,
    required this.color,
  });
}

// ...  rest of your models ...