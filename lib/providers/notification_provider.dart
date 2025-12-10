import 'package:flutter/foundation.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/services/employee_service.dart';

/// NotificationProvider - Manages notification state and real-time updates
class NotificationProvider extends ChangeNotifier {
  List<NotificationData> _notifications = [];
  int _unreadCount = 0;
  bool _isInitialized = false;
  bool _hasNewAssignments = false;
  int _pendingAssignments = 0;

  // Getters
  List<NotificationData> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;
  bool get hasNewAssignments => _hasNewAssignments;
  int get pendingAssignments => _pendingAssignments;
  int get totalBadgeCount => _unreadCount + _pendingAssignments;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadNotifications();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadNotifications() async {
    try {
      final rawNotifications = await EmployeeService.getNotifications();

      _notifications = rawNotifications. map((data) {
        return NotificationData. fromJson(data);
      }).toList();

      _unreadCount = _notifications.where((n) => ! n.isRead). length;
      _pendingAssignments = _notifications.where((n) =>
      n.type == NotificationType.taskAssignment && !n.isRead
      ).length;
      _hasNewAssignments = _pendingAssignments > 0;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final success = await EmployeeService.markNotificationRead(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _updateCounts();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final success = await EmployeeService. markAllNotificationsRead();

      if (success) {
        _notifications = _notifications.map((n) => n. copyWith(isRead: true)).toList();
        _updateCounts();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final success = await EmployeeService.clearAllNotifications();

      if (success) {
        _notifications. clear();
        _updateCounts();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  void addNotification(NotificationData notification) {
    _notifications.insert(0, notification);
    _updateCounts();
    notifyListeners();
  }

  void removeNotification(int notificationId) {
    _notifications. removeWhere((n) => n.id == notificationId);
    _updateCounts();
    notifyListeners();
  }

  void _updateCounts() {
    _unreadCount = _notifications. where((n) => !n.isRead).length;
    _pendingAssignments = _notifications. where((n) =>
    n. type == NotificationType.taskAssignment && !n.isRead
    ).length;
    _hasNewAssignments = _pendingAssignments > 0;
  }

  // Get notifications by type
  List<NotificationData> getByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get recent notifications
  List<NotificationData> getRecent({int limit = 5}) {
    return _notifications.take(limit).toList();
  }

  // Check if there are urgent notifications
  bool get hasUrgentNotifications {
    return _notifications.any((n) =>
    n.type == NotificationType.urgent && !n.isRead
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}