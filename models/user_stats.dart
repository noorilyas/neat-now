class UserStats {
  final int totalReports;
  final int resolved;
  final int pending;
  final int points;
  final int rank;
  final int streak;
  final String userName;
  final String level;

  UserStats({
    required this.totalReports,
    required this.resolved,
    required this.pending,
    required this.points,
    required this.rank,
    required this.streak,
    required this.userName,
    required this.level,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalReports: json['totalReports'] ?? 0,
      resolved: json['resolved'] ?? 0,
      pending: json['pending'] ?? 0,
      points: json['points'] ?? 0,
      rank: json['rank'] ?? 0,
      streak: json['streak'] ?? 0,
      userName: json['userName'] ?? '',
      level: json['level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalReports': totalReports,
      'resolved': resolved,
      'pending': pending,
      'points': points,
      'rank': rank,
      'streak': streak,
      'userName': userName,
      'level': level,
    };
  }

  UserStats copyWith({
    int? totalReports,
    int? resolved,
    int? pending,
    int? points,
    int? rank,
    int? streak,
    String? userName,
    String? level,
  }) {
    return UserStats(
      totalReports: totalReports ?? this.totalReports,
      resolved: resolved ?? this.resolved,
      pending: pending ?? this.pending,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      streak: streak ?? this.streak,
      userName: userName ?? this.userName,
      level: level ?? this.level,
    );
  }
}
