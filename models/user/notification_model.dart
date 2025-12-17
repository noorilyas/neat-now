class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedId; // Report ID, etc.
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this. message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.relatedId,
    this.data,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message:  map['message'] ?? '',
      type: NotificationType.fromString(map['type'] ?? 'info'),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: map['isRead'] ?? false,
      relatedId: map['relatedId'],
      data: map['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.value,
      'timestamp': timestamp. toIso8601String(),
      'isRead': isRead,
      'relatedId': relatedId,
      'data':  data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String?  message,
    NotificationType?  type,
    DateTime? timestamp,
    bool? isRead,
    String? relatedId,
    Map<String, dynamic>?  data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this. relatedId,
      data:  data ?? this.data,
    );
  }

  // Time ago helper
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference. inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference. inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

enum NotificationType {
  reportSubmitted('report_submitted'),
  reportAssigned('report_assigned'),
  reportInProgress('report_in_progress'),
  reportResolved('report_resolved'),
  reportRejected('report_rejected'),
  pointsEarned('points_earned'),
  rankUp('rank_up'),
  achievement('achievement'),
  system('system'),
  info('info');

  final String value;
  const NotificationType(this. value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => NotificationType.info,
    );
  }
}