class LeaderboardUserModel {
  final String id;
  final String name;
  final int verifiedReports;
  final int rank;
  final String? badge;
  final String? avatarUrl;

  const LeaderboardUserModel({
    required this.id,
    required this.name,
    required this.verifiedReports,
    required this.rank,
    this.badge,
    this.avatarUrl,
  });

  // Helper to get first letter for avatar
  String get avatarInitial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  // Helper to get first name
  String get firstName => name.split(' ').first;

  // Check if top 3
  bool get isTopThree => rank <= 3;
}