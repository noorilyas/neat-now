import 'package:flutter/material.dart';
import 'package:neat_now/models/user/notification_model.dart';
import 'package:neat_now/design/user/user_design_system.dart';

class NotificationsViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _filteredNotifications = [];
  NotificationFilter _currentFilter = NotificationFilter. all;
  bool _isLoading = false;
  String?  _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _filteredNotifications;
  NotificationFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNotifications => _notifications.isNotEmpty;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get totalCount => _notifications.length;

  NotificationsViewModel() {
    _loadNotifications();
  }

  // Load notifications (mock data for now)
  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 800));

      _notifications = _getMockNotifications();
      _applyFilter(_currentFilter);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load notifications';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh notifications
  Future<void> refresh() async {
    await _loadNotifications();
  }

  // Change filter
  void setFilter(NotificationFilter filter) {
    _currentFilter = filter;
    _applyFilter(filter);
    notifyListeners();
  }

  void _applyFilter(NotificationFilter filter) {
    switch (filter) {
      case NotificationFilter.all:
        _filteredNotifications = List.from(_notifications);
        break;
      case NotificationFilter.unread:
        _filteredNotifications = _notifications.where((n) => !n.isRead).toList();
        break;
      case NotificationFilter.reports:
        _filteredNotifications = _notifications.where((n) {
          return n.type == NotificationType.reportSubmitted ||
              n.type == NotificationType. reportAssigned ||
              n. type == NotificationType.reportInProgress ||
              n.type == NotificationType.reportResolved ||
              n.type == NotificationType.reportRejected;
        }).toList();
        break;
      case NotificationFilter.achievements:
        _filteredNotifications = _notifications.where((n) {
          return n.type == NotificationType.achievement ||
              n.type == NotificationType. pointsEarned ||
              n.type == NotificationType. rankUp;
        }).toList();
        break;
    }
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _applyFilter(_currentFilter);
      notifyListeners();

      // TODO: API call to mark as read
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _applyFilter(_currentFilter);
    notifyListeners();

    // TODO: API call to mark all as read
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _applyFilter(_currentFilter);
    notifyListeners();

    // TODO: API call to delete
  }

  // Clear all notifications
  Future<void> clearAll() async {
    _notifications. clear();
    _filteredNotifications.clear();
    notifyListeners();

    // TODO: API call to clear all
  }

  // Get icon for notification type
  IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType. reportSubmitted:
        return Icons.upload_rounded;
      case NotificationType. reportAssigned:
        return Icons.assignment_ind_rounded;
      case NotificationType.reportInProgress:
        return Icons.engineering_rounded;
      case NotificationType.reportResolved:
        return Icons.check_circle_rounded;
      case NotificationType.reportRejected:
        return Icons.cancel_rounded;
      case NotificationType.pointsEarned:
        return Icons.stars_rounded;
      case NotificationType.rankUp:
        return Icons.emoji_events_rounded;
      case NotificationType.achievement:
        return Icons.military_tech_rounded;
      case NotificationType.system:
        return Icons.notifications_active_rounded;
      case NotificationType.info:
        return Icons.info_rounded;
    }
  }

  // Get color for notification type
  Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.reportSubmitted:
        return UserDesign.info;
      case NotificationType.reportAssigned:
        return UserDesign.purple;
      case NotificationType. reportInProgress:
        return UserDesign.warning;
      case NotificationType. reportResolved:
        return UserDesign.success;
      case NotificationType.reportRejected:
        return UserDesign. error;
      case NotificationType.pointsEarned:
        return const Color(0xFFFFD700);
      case NotificationType.rankUp:
        return const Color(0xFFFF6B6B);
      case NotificationType.achievement:
        return UserDesign.primaryTeal;
      case NotificationType. system:
        return UserDesign.textSecondary;
      case NotificationType.info:
        return UserDesign.info;
    }
  }

  // Group notifications by date
  Map<String, List<NotificationModel>> get groupedNotifications {
    final groups = <String, List<NotificationModel>>{};
    final now = DateTime.now();

    for (final notification in _filteredNotifications) {
      String key;
      final difference = now.difference(notification.timestamp).inDays;

      if (difference == 0) {
        key = 'Today';
      } else if (difference == 1) {
        key = 'Yesterday';
      } else if (difference < 7) {
        key = 'This Week';
      } else if (difference < 30) {
        key = 'This Month';
      } else {
        key = 'Earlier';
      }

      groups. putIfAbsent(key, () => []);
      groups[key]!. add(notification);
    }

    return groups;
  }

  // Mock data generator
  List<NotificationModel> _getMockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1',
        title: 'Report Resolved ✅',
        message: 'Your plastic waste report at Park Avenue has been successfully resolved! ',
        type: NotificationType.reportResolved,
        timestamp: now. subtract(const Duration(minutes: 15)),
        isRead: false,
        relatedId: 'report_123',
      ),
      NotificationModel(
        id: '2',
        title: 'Points Earned 🌟',
        message: 'You earned 50 points for your verified waste report!',
        type: NotificationType.pointsEarned,
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Worker Assigned',
        message: 'John Doe has been assigned to your organic waste report.',
        type: NotificationType.reportAssigned,
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        relatedId: 'report_124',
      ),
      NotificationModel(
        id: '4',
        title: 'Rank Up!  🎉',
        message: 'Congratulations!  You\'ve been promoted to Gold Rank!',
        type: NotificationType.rankUp,
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'Report Submitted',
        message: 'Your construction waste report has been submitted successfully.',
        type: NotificationType.reportSubmitted,
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
        relatedId: 'report_125',
      ),
      NotificationModel(
        id: '6',
        title: 'Achievement Unlocked!',
        message: 'You\'ve unlocked "Eco Warrior" badge for 10 verified reports!',
        type: NotificationType.achievement,
        timestamp: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      NotificationModel(
        id: '7',
        title: 'Cleanup In Progress',
        message: 'Worker has started cleaning your reported area.',
        type: NotificationType.reportInProgress,
        timestamp: now.subtract(const Duration(days: 5)),
        isRead: true,
        relatedId: 'report_126',
      ),
      NotificationModel(
        id: '8',
        title: 'System Update',
        message: 'NeatNow has been updated to version 1.1.0 with new features! ',
        type: NotificationType.system,
        timestamp: now.subtract(const Duration(days: 7)),
        isRead: true,
      ),
    ];
  }
}

enum NotificationFilter {
  all,
  unread,
  reports,
  achievements,
}