import 'package:flutter/material.dart';
import 'package:neat_now/models/user/user_model.dart';
import 'package:neat_now/models/user/leaderboard_user_model.dart';
import 'package:neat_now/design/user/user_design_system.dart';

class UserLeaderboardViewModel extends ChangeNotifier {
  final UserModel user;
  bool _showFullLeaderboard = false;

  UserLeaderboardViewModel({required this.user});

  // Getters
  bool get showFullLeaderboard => _showFullLeaderboard;
  String get currentUserId => user.id;
  int get currentUserRank => user.rank;
  int get currentUserVerifiedReports => user.verifiedReports;
  String get currentUserName => user.name;
  bool get isCurrentUserTopThree => currentUserRank <= 3;

  // Toggle full leaderboard
  void toggleFullLeaderboard() {
    _showFullLeaderboard = ! _showFullLeaderboard;
    notifyListeners();
  }

  // Get leaderboard data (mock data - replace with actual API call)
  List<LeaderboardUserModel> getLeaderboardData() {
    return [
      const LeaderboardUserModel(
        id: '1',
        name: 'Sarah Khan',
        verifiedReports:  156,
        rank: 1,
        badge: 'platinum',
        avatarUrl: null,
      ),
      const LeaderboardUserModel(
        id: '2',
        name:  'Ahmad Ali',
        verifiedReports:  142,
        rank: 2,
        badge: 'gold',
        avatarUrl: null,
      ),
      const LeaderboardUserModel(
        id: '3',
        name:  'Fatima Ahmed',
        verifiedReports:  128,
        rank: 3,
        badge: 'silver',
        avatarUrl: null,
      ),
      const LeaderboardUserModel(
        id: '4',
        name: 'Omar Hassan',
        verifiedReports:  115,
        rank: 4,
        avatarUrl: null,
      ),
      const LeaderboardUserModel(
        id: '5',
        name: 'Zainab Malik',
        verifiedReports:  98,
        rank: 5,
        avatarUrl: null,
      ),
      const LeaderboardUserModel(
        id: '6',
        name: 'Bilal Khan',
        verifiedReports:  87,
        rank: 6,
        avatarUrl:  null,
      ),
      const LeaderboardUserModel(
        id: '7',
        name: 'Aisha Noor',
        verifiedReports:  76,
        rank: 7,
        avatarUrl: null,
      ),
      const LeaderboardUserModel(
        id:  '8',
        name: 'Hassan Ali',
        verifiedReports:  65,
        rank: 8,
        avatarUrl:  null,
      ),
      const LeaderboardUserModel(
        id: '9',
        name: 'Maryam Shah',
        verifiedReports:  54,
        rank: 9,
        avatarUrl:  null,
      ),
      const LeaderboardUserModel(
        id: '10',
        name: 'Usman Raza',
        verifiedReports:  43,
        rank: 10,
        avatarUrl:  null,
      ),
    ];
  }

  // Get top 3 users
  List<LeaderboardUserModel> getTopThree() {
    return getLeaderboardData().take(3).toList();
  }

  // Check if user is current user
  bool isCurrentUser(String userId) {
    return userId == currentUserId;
  }

  // Get badge data for rank
  BadgeData getBadgeData(int rank) {
    switch (rank) {
      case 1:
        return BadgeData(
          color: UserDesign.platinum,
          icon: Icons.diamond_rounded,
          label: 'Platinum',
          isTopThree: true,
        );
      case 2:
        return BadgeData(
          color: const Color(0xFFFFD700),
          icon: Icons. workspace_premium_rounded,
          label: 'Gold',
          isTopThree:  true,
        );
      case 3:
        return BadgeData(
          color: UserDesign.silver,
          icon: Icons.military_tech_rounded,
          label: 'Silver',
          isTopThree: true,
        );
      default:
        return BadgeData(
          color: UserDesign. textSecondary,
          icon:  Icons.emoji_events_outlined,
          label: '',
          isTopThree: false,
        );
    }
  }

  // Get current user badge data
  BadgeData getCurrentUserBadgeData() {
    return getBadgeData(currentUserRank);
  }

  // Get podium info items
  List<PodiumInfoItem> getPodiumInfoItems() {
    return [
      PodiumInfoItem(
        icon: Icons.diamond_rounded,
        label: 'Platinum',
        rank: '#1',
        color: UserDesign.platinum,
      ),
      PodiumInfoItem(
        icon: Icons.workspace_premium_rounded,
        label: 'Gold',
        rank: '#2',
        color: const Color(0xFFFFD700),
      ),
      PodiumInfoItem(
        icon: Icons.military_tech_rounded,
        label: 'Silver',
        rank: '#3',
        color: UserDesign.silver,
      ),
    ];
  }
}

// Helper classes
class BadgeData {
  final Color color;
  final IconData icon;
  final String label;
  final bool isTopThree;

  BadgeData({
    required this. color,
    required this.icon,
    required this.label,
    required this.isTopThree,
  });
}

class PodiumInfoItem {
  final IconData icon;
  final String label;
  final String rank;
  final Color color;

  PodiumInfoItem({
    required this.icon,
    required this.label,
    required this.rank,
    required this.color,
  });
}