class LeaderboardEntry {
  final int rank;
  final String name;
  final int points;
  final int reports;
  final String avatar;
  final bool isCurrentUser;
  final String? userId;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.points,
    required this.reports,
    required this.avatar,
    this.isCurrentUser = false,
    this.userId,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
      reports: json['reports'] ?? 0,
      avatar: json['avatar'] ?? '👤',
      isCurrentUser: json['isCurrentUser'] ?? false,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'name': name,
      'points': points,
      'reports': reports,
      'avatar': avatar,
      'isCurrentUser': isCurrentUser,
      'userId': userId,
    };
  }
}

