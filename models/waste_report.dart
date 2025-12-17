enum ReportStatus { resolved, pending, inProgress }

class WasteReport {
  final String id;
  final String location;
  final String type;
  final ReportStatus status;
  final String date;
  final String quantity;
  final String? image;
  final List<String> wasteTypes;
  final DateTime timestamp;

  WasteReport({
    required this.id,
    required this.location,
    required this.type,
    required this.status,
    required this.date,
    required this.quantity,
    this.image,
    required this.wasteTypes,
    required this.timestamp,
  });

  factory WasteReport.fromJson(Map<String, dynamic> json) {
    return WasteReport(
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      status: _parseStatus(json['status']),
      date: json['date'] ?? '',
      quantity: json['quantity'] ?? '',
      image: json['image'],
      wasteTypes: List<String>.from(json['wasteTypes'] ?? []),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'type': type,
      'status': status.name,
      'date': date,
      'quantity': quantity,
      'image': image,
      'wasteTypes': wasteTypes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static ReportStatus _parseStatus(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'resolved':
          return ReportStatus.resolved;
        case 'in-progress':
        case 'inprogress':
          return ReportStatus.inProgress;
        default:
          return ReportStatus.pending;
      }
    }
    return ReportStatus.pending;
  }

  WasteReport copyWith({
    String? id,
    String? location,
    String? type,
    ReportStatus? status,
    String? date,
    String? quantity,
    String? image,
    List<String>? wasteTypes,
    DateTime? timestamp,
  }) {
    return WasteReport(
      id: id ?? this.id,
      location: location ?? this.location,
      type: type ?? this.type,
      status: status ?? this.status,
      date: date ?? this.date,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      wasteTypes: wasteTypes ?? this.wasteTypes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

// models/achievement.dart
class Achievement {
  final String icon;
  final String title;
  final String fullTitle;
  final bool unlocked;
  final String? description;
  final int? requiredCount;

  Achievement({
    required this.icon,
    required this.title,
    required this.fullTitle,
    required this.unlocked,
    this.description,
    this.requiredCount,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      icon: json['icon'] ?? '',
      title: json['title'] ?? '',
      fullTitle: json['fullTitle'] ?? json['title'] ?? '',
      unlocked: json['unlocked'] ?? false,
      description: json['description'],
      requiredCount: json['requiredCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'title': title,
      'fullTitle': fullTitle,
      'unlocked': unlocked,
      'description': description,
      'requiredCount': requiredCount,
    };
  }

  Achievement copyWith({
    String? icon,
    String? title,
    String? fullTitle,
    bool? unlocked,
    String? description,
    int? requiredCount,
  }) {
    return Achievement(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      fullTitle: fullTitle ?? this.fullTitle,
      unlocked: unlocked ?? this.unlocked,
      description: description ?? this.description,
      requiredCount: requiredCount ?? this.requiredCount,
    );
  }
}

// models/leaderboard_entry.dart
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
