import 'package:flutter/material.dart';

/// Employee profile for dashboard
class DashboardEmployee {
  final String id;
  final String name;
  final String email;
  final String?  profileImage;
  final String position;
  final int rank;

  const DashboardEmployee({
    required this.id,
    required this.name,
    required this. email,
    this.profileImage,
    this.position = 'Waste Collection Worker',
    this.rank = 0,
  });

  factory DashboardEmployee.fromMap(Map<String, dynamic> map) {
    return DashboardEmployee(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? 'Employee',
      email: map['email'] ?? '',
      profileImage: map['profile_image'] ??  map['profileImage'],
      position: map['position'] ?? 'Waste Collection Worker',
      rank: map['rank'] ?? 0,
    );
  }

  String get firstName => name.split(' ').first;
  String get avatarInitial => name.isNotEmpty ? name[0]. toUpperCase() : '? ';
}

/// Stat card data model
class StatCardData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String?  trend;
  final bool trendUp;

  const StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp = true,
  });

  factory StatCardData.total(int value) {
    return StatCardData(
      label: 'Total',
      value: value,
      icon: Icons.assignment_rounded,
      color: const Color(0xFF3B82F6),
      trend: '+5',
      trendUp: true,
    );
  }

  factory StatCardData.completed(int value) {
    return StatCardData(
      label:  'Completed',
      value: value,
      icon: Icons.check_circle_rounded,
      color: const Color(0xFF10B981),
      trend: '+3',
      trendUp: true,
    );
  }

  factory StatCardData.inProgress(int value) {
    return StatCardData(
      label: 'In Progress',
      value: value,
      icon:  Icons.sync_rounded,
      color: const Color(0xFFF59E0B),
      trend: null,
      trendUp: true,
    );
  }

  factory StatCardData.pending(int value) {
    return StatCardData(
      label:  'Pending',
      value: value,
      icon: Icons.pending_rounded,
      color: const Color(0xFF6B7280),
      trend: '-2',
      trendUp: false,
    );
  }
}

/// Quick action data model
class QuickActionData {
  final String label;
  final IconData icon;
  final Color color;
  final int targetTabIndex;

  const QuickActionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.targetTabIndex,
  });

  static const List<QuickActionData> defaultActions = [
    QuickActionData(
      label: 'New Task',
      icon: Icons.add_task_rounded,
      color: Color(0xFF2AC2AB),
      targetTabIndex: 1,
    ),
    QuickActionData(
      label: 'View Map',
      icon: Icons.map_rounded,
      color: Color(0xFF10B981),
      targetTabIndex: 2,
    ),
    QuickActionData(
      label: 'Analytics',
      icon: Icons.analytics_rounded,
      color: Color(0xFF3B82F6),
      targetTabIndex: 3,
    ),
    QuickActionData(
      label: 'Rankings',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFF59E0B),
      targetTabIndex: 4,
    ),
  ];
}

/// Dashboard data container
class DashboardData {
  final DashboardEmployee employee;
  final List<StatCardData> statCards;
  final List<QuickActionData> quickActions;
  final List<dynamic> activeReports;
  final List<dynamic> topThreeLeaderboard;
  final int overdueCount;
  final bool isDemoMode;
  final double weeklyProgress;

  const DashboardData({
    required this.employee,
    required this.statCards,
    required this.quickActions,
    required this.activeReports,
    required this.topThreeLeaderboard,
    this.overdueCount = 0,
    this.isDemoMode = false,
    this.weeklyProgress = 0.78,
  });

  bool get hasOverdueReports => overdueCount > 0;
  bool get hasActiveReports => activeReports. isNotEmpty;
  bool get hasLeaderboard => topThreeLeaderboard.isNotEmpty;

  int getDisplayReportsCount(int maxToShow) {
    return activeReports.length > maxToShow ?  maxToShow : activeReports.length;
  }

  int getRemainingReportsCount(int maxToShow) {
    return activeReports.length > maxToShow
        ? activeReports.length - maxToShow
        :  0;
  }
}

/// Performance data model
class PerformanceData {
  final double progress;
  final String progressText;
  final String weekLabel;

  const PerformanceData({
    this.progress = 0.78,
    this.progressText = '78%',
    this.weekLabel = 'This Week\'s Progress',
  });

  int get progressPercentage => (progress * 100).toInt();
}

/// Greeting data model
class GreetingData {
  final String greeting;
  final IconData icon;

  const GreetingData({
    required this.greeting,
    required this.icon,
  });

  factory GreetingData.fromTimeOfDay() {
    final hour = DateTime.now().hour;

    if (hour < 5) {
      return const GreetingData(
        greeting: '🌙 Working late? ',
        icon: Icons.nightlight_round,
      );
    } else if (hour < 12) {
      return const GreetingData(
        greeting: '☀️ Good Morning',
        icon: Icons.wb_sunny_rounded,
      );
    } else if (hour < 17) {
      return const GreetingData(
        greeting: '🌤️ Good Afternoon',
        icon: Icons.wb_cloudy_rounded,
      );
    } else if (hour < 21) {
      return const GreetingData(
        greeting:  '🌅 Good Evening',
        icon: Icons.wb_twilight_rounded,
      );
    } else {
      return const GreetingData(
        greeting: '🌙 Good Night',
        icon: Icons. nightlight_round,
      );
    }
  }
}

/// Podium colors for leaderboard
class PodiumColors {
  final List<Color> gradient;
  final Color primary;
  final String medal;

  const PodiumColors({
    required this.gradient,
    required this.primary,
    required this.medal,
  });

  static const PodiumColors gold = PodiumColors(
    gradient: [Color(0xFFFFD700), Color(0xFFFFA500)],
    primary: Color(0xFFFFD700),
    medal: '🥇',
  );

  static const PodiumColors silver = PodiumColors(
    gradient:  [Color(0xFFC0C0C0), Color(0xFFB8B8B8)],
    primary: Color(0xFFC0C0C0),
    medal: '🥈',
  );

  static const PodiumColors bronze = PodiumColors(
    gradient:  [Color(0xFFCD7F32), Color(0xFFB87333)],
    primary: Color(0xFFCD7F32),
    medal: '🥉',
  );

  static PodiumColors forPosition(int position) {
    switch (position) {
      case 0:
        return gold;
      case 1:
        return silver;
      case 2:
        return bronze;
      default:
        return const PodiumColors(
          gradient: [Color(0xFF2AC2AB), Color(0xFF4ECDC4)],
          primary: Color(0xFF2AC2AB),
          medal: '⭐',
        );
    }
  }
}

/// Waste type color mapping
class WasteTypeColors {
  static Color getColor(String type) {
    final t = type.toLowerCase();

    if (t. contains('plastic')) return const Color(0xFF3B82F6);
    if (t.contains('organic')) return const Color(0xFF10B981);
    if (t.contains('hazardous')) return const Color(0xFFEF4444);
    if (t.contains('electronic')) return const Color(0xFF8B5CF6);
    if (t.contains('glass')) return const Color(0xFF06B6D4);
    if (t.contains('metal')) return const Color(0xFF6B7280);
    if (t.contains('paper')) return const Color(0xFFA16207);
    if (t.contains('mixed')) return const Color(0xFFF59E0B);

    return const Color(0xFF6B7280);
  }

  static IconData getIcon(String type) {
    final t = type.toLowerCase();

    if (t.contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('hazardous')) return Icons.warning_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('glass')) return Icons.wine_bar_rounded;
    if (t.contains('metal')) return Icons.build_rounded;
    if (t.contains('paper')) return Icons.description_rounded;
    if (t.contains('mixed')) return Icons.delete_rounded;

    return Icons.delete_outline_rounded;
  }
}

/// Report status color mapping
class ReportStatusColors {
  static Color getColor(String status) {
    switch (status. toLowerCase()) {
      case 'pending':
        return const Color(0xFF6B7280);
      case 'accepted':
        return const Color(0xFF3B82F6);
      case 'in_progress':
      case 'in-progress':
        return const Color(0xFFF59E0B);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static IconData getIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons. pending_rounded;
      case 'accepted':
        return Icons. check_circle_outline_rounded;
      case 'in_progress':
      case 'in-progress':
        return Icons.sync_rounded;
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  static String formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'in-progress':
        return 'IN PROGRESS';
      case 'accepted':
        return 'ACCEPTED';
      case 'resolved':
        return 'RESOLVED';
      case 'pending':
        return 'PENDING';
      case 'rejected':
        return 'REJECTED';
      default:
        return status. toUpperCase();
    }
  }
}

/// Display configuration for reports
class ReportsDisplayConfig {
  final int maxReportsToShow;
  final bool showOverdueBadge;
  final bool showStatusChip;
  final bool showLocation;
  final bool showTimestamp;

  const ReportsDisplayConfig({
    this.maxReportsToShow = 3,
    this.showOverdueBadge = true,
    this.showStatusChip = true,
    this.showLocation = true,
    this.showTimestamp = true,
  });

  factory ReportsDisplayConfig.fromResponsive(dynamic responsive) {
    final maxToShow = responsive. responsive<int>(
      base: 3,
      nano: 1,
      micro: 2,
      mini: 2,
      tiny: 3,
    );

    return ReportsDisplayConfig(
      maxReportsToShow: maxToShow,
      showOverdueBadge: responsive.showBadges,
      showStatusChip:  responsive.showDetailedContent,
      showLocation: responsive. showSecondaryText,
      showTimestamp: responsive.showDetailedContent,
    );
  }
}

/// Leaderboard display configuration
class LeaderboardDisplayConfig {
  final bool showCrown;
  final bool showRating;
  final bool showPoints;
  final bool showName;
  final List<double> podiumHeights;

  const LeaderboardDisplayConfig({
    this.showCrown = true,
    this.showRating = true,
    this. showPoints = true,
    this.showName = true,
    this.podiumHeights = const [120, 100, 80],
  });

  factory LeaderboardDisplayConfig.fromResponsive(dynamic responsive) {
    return LeaderboardDisplayConfig(
      showCrown: responsive.showIcons,
      showRating: responsive.showSecondaryText,
      showPoints: responsive.showMinimalText,
      showName: responsive. showIconLabels,
      podiumHeights: [
        responsive.dimension(120),
        responsive.dimension(100),
        responsive.dimension(80),
      ],
    );
  }

  List<int> get displayOrder => [1, 0, 2]; // Silver, Gold, Bronze
}