import 'package:flutter/material.dart';
import 'package:neat_now/models/user/user_model.dart';
import 'package:neat_now/models/user/recent_report_model.dart';
import 'package:neat_now/design/user/user_design_system.dart';

class UserHomeViewModel extends ChangeNotifier {
  final UserModel user;
  final VoidCallback onViewReports;
  final VoidCallback onViewLeaderboard;
  final VoidCallback onReportWaste;

  UserHomeViewModel({
    required this.user,
    required this.onViewReports,
    required this.onViewLeaderboard,
    required this. onReportWaste,
  });

  // User data getters
  String get name => user.name;
  String get firstName => name.split(' ').first;
  int get totalReports => user.totalReports;
  int get verifiedReports => user.verifiedReports;
  int get rank => user.rank;
  String?  get badge => user.badge;
  String? get profileImage => user.profileImage;

  // Avatar initial
  String get avatarInitial => name. isNotEmpty ? name[0]. toUpperCase() : '?';

  // Greeting logic
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // Rank badge data
  RankBadgeData getRankBadgeData() {
    if (rank == 1) {
      return RankBadgeData(
        color: UserDesign.platinum,
        icon: Icons.diamond_rounded,
        label: '#1',
        isTopThree: true,
      );
    } else if (rank == 2) {
      return RankBadgeData(
        color: UserDesign.gold,
        icon: Icons.workspace_premium_rounded,
        label: '#2',
        isTopThree: true,
      );
    } else if (rank == 3) {
      return RankBadgeData(
        color: UserDesign.silver,
        icon: Icons.military_tech_rounded,
        label: '#3',
        isTopThree: true,
      );
    } else {
      return RankBadgeData(
        color: UserDesign.textTertiary,
        icon: Icons.tag_rounded,
        label: '#$rank',
        isTopThree: false,
      );
    }
  }

  // Recent reports data
  List<RecentReportModel> getRecentReports() {
    return [
      RecentReportModel(
        type: 'Plastic Waste',
        status: 'Pending',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        color: UserDesign.warning,
      ),
      RecentReportModel(
        type:  'Organic Waste',
        status: 'Assigned',
        date: DateTime.now().subtract(const Duration(days: 1)),
        color: UserDesign.info,
      ),
      RecentReportModel(
        type:  'Mixed Waste',
        status: 'Resolved',
        date: DateTime.now().subtract(const Duration(days: 3)),
        color: UserDesign.success,
      ),
    ];
  }

  // Format time ago
  String formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // Has notifications
  bool get hasNotifications => true; // Can be replaced with actual logic

  // Eco tip
  EcoTip getEcoTip() {
    return const EcoTip(
      title: 'Did you know?',
      message: 'One plastic bottle can take up to 450 years to decompose. Help by reporting plastic waste! ',
    );
  }
}

// Helper classes
class RankBadgeData {
  final Color color;
  final IconData icon;
  final String label;
  final bool isTopThree;

  RankBadgeData({
    required this. color,
    required this.icon,
    required this.label,
    required this.isTopThree,
  });
}

class EcoTip {
  final String title;
  final String message;

  const EcoTip({
    required this.title,
    required this.message,
  });
}