import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;

/// NotificationService - Local notifications without Firebase
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Stream controllers for notification events
  final StreamController<NotificationData> _notificationController = StreamController<NotificationData>.broadcast();
  final StreamController<TaskAssignment> _taskAssignmentController = StreamController<TaskAssignment>.broadcast();

  Stream<NotificationData> get notificationStream => _notificationController.stream;
  Stream<TaskAssignment> get taskAssignmentStream => _taskAssignmentController.stream;

  // Callback for when notification is tapped
  Function(NotificationData)? onNotificationTap;
  Function(TaskAssignment)? onTaskAssignmentReceived;

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('NotificationService already initialized');
      return;
    }

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const taskChannel = AndroidNotificationChannel(
      'task_notifications',
      'Task Notifications',
      description: 'Notifications for new task assignments',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const urgentChannel = AndroidNotificationChannel(
      'urgent_notifications',
      'Urgent Notifications',
      description: 'Urgent task notifications requiring immediate attention',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const generalChannel = AndroidNotificationChannel(
      'general_notifications',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(taskChannel);
    await androidPlugin?.createNotificationChannel(urgentChannel);
    await androidPlugin?.createNotificationChannel(generalChannel);
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.id}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final notificationData = NotificationData.fromJson(data);

        // Add to stream
        _notificationController.add(notificationData);

        // Call callback
        onNotificationTap?.call(notificationData);

        // Handle task assignment
        if (notificationData.type == NotificationType.taskAssignment ||
            notificationData.type == NotificationType.proximityTask) {
          final assignment = TaskAssignment.fromNotificationData(notificationData);
          _taskAssignmentController.add(assignment);
          onTaskAssignmentReceived?.call(assignment);
        }
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
      }
    }
  }

  /// Show a notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? subtitle,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
    List<String>? actions,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ NotificationService not initialized, initializing now...');
      await initialize();
    }

    try {
      final notificationData = NotificationData(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        subtitle: subtitle,
        type: type,
        data: data ?? {},
        timestamp: DateTime.now(),
      );

      await _showLocalNotification(notificationData, actions: actions);

      debugPrint('✅ Notification shown: $title');
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(NotificationData data, {List<String>? actions}) async {
    final channelId = _getChannelId(data.type);
    final importance = _getImportance(data.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(data.type),
      importance: importance,
      priority: importance == Importance.max ? Priority.max : Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        data.body,
        contentTitle: data.title,
        summaryText: data.subtitle,
      ),
      actions: actions != null
          ? actions.map((action) => AndroidNotificationAction(
        action.toLowerCase().replaceAll(' ', '_'),
        action,
        showsUserInterface: true,
      )).toList()
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      subtitle: data.subtitle,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      data.id,
      data.title,
      data.body,
      details,
      payload: jsonEncode(data.toJson()),
    );
  }

  String _getChannelId(NotificationType type) {
    switch (type) {
      case NotificationType.urgentTask:
        return 'urgent_notifications';
      case NotificationType.taskAssignment:
      case NotificationType.proximityTask:
        return 'task_notifications';
      default:
        return 'general_notifications';
    }
  }

  String _getChannelName(NotificationType type) {
    switch (type) {
      case NotificationType.urgentTask:
        return 'Urgent Notifications';
      case NotificationType.taskAssignment:
      case NotificationType.proximityTask:
        return 'Task Notifications';
      default:
        return 'General Notifications';
    }
  }

  Importance _getImportance(NotificationType type) {
    switch (type) {
      case NotificationType.urgentTask:
        return Importance.max;
      case NotificationType.taskAssignment:
      case NotificationType.proximityTask:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  /// Show task assignment notification
  Future<void> showTaskAssignment(TaskAssignment task) async {
    final isProximity = task.assignmentType == TaskAssignmentType.proximity;

    await showNotification(
      title: isProximity ? '🎯 New Task Nearby' : '📋 Task Assigned',
      body: task.taskTitle,
      subtitle: task.location,
      type: task.isUrgent ? NotificationType.urgentTask : NotificationType.taskAssignment,
      data: task.toJson(),
      actions: isProximity ? ['Accept', 'Reject'] : null,
    );

    // Add to stream
    _taskAssignmentController.add(task);
    onTaskAssignmentReceived?.call(task);
  }

  /// Show badge earned notification
  Future<void> showBadgeEarned(String badgeName, String description) async {
    await showNotification(
      title: '🏆 Badge Earned!',
      body: badgeName,
      subtitle: description,
      type: NotificationType.badgeEarned,
    );
  }

  /// Show verification result notification
  Future<void> showVerificationResult({
    required bool verified,
    required String taskTitle,
    String? reason,
  }) async {
    await showNotification(
      title: verified ? '✅ Task Verified' : '❌ Verification Failed',
      body: taskTitle,
      subtitle: reason,
      type: verified ? NotificationType.taskVerified : NotificationType.taskRejected,
    );
  }

  /// Schedule a notification for later
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? subtitle,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final notificationData = NotificationData(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      subtitle: subtitle,
      type: type,
      data: data ?? {},
      timestamp: scheduledTime,
    );

    final channelId = _getChannelId(type);
    final importance = _getImportance(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(type),
      importance: importance,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );


    await _localNotifications.zonedSchedule(
      notificationData.id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local), // ✅ FIXED
      details,
      payload: jsonEncode(notificationData.toJson()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      return await androidPlugin.areNotificationsEnabled() ?? false;
    }

    return true; // Assume enabled for iOS
  }

  void dispose() {
    _notificationController.close();
    _taskAssignmentController.close();
  }
}

// ==================== NOTIFICATION DATA MODELS ====================

enum NotificationType {
  general,
  taskAssignment,      // Admin manually assigned task
  proximityTask,       // Auto-assigned based on proximity (can accept/reject)
  urgentTask,          // Urgent/hazardous task
  taskVerified,        // AI verification passed
  taskRejected,        // AI verification failed
  badgeEarned,         // Performance badge earned
  systemUpdate,        // System notifications
}

class NotificationData {
  final int id;
  final String title;
  final String body;
  final String? subtitle;
  final NotificationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isRead;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.subtitle,
    required this.type,
    required this.data,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      subtitle: json['subtitle'],
      type: _parseNotificationType(json['type']),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'subtitle': subtitle,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type) {
      case 'taskAssignment':
      case 'task_assignment':
        return NotificationType.taskAssignment;
      case 'proximityTask':
      case 'proximity_task':
        return NotificationType.proximityTask;
      case 'urgentTask':
      case 'urgent_task':
        return NotificationType.urgentTask;
      case 'taskVerified':
      case 'task_verified':
        return NotificationType.taskVerified;
      case 'taskRejected':
      case 'task_rejected':
        return NotificationType.taskRejected;
      case 'badgeEarned':
      case 'badge_earned':
        return NotificationType.badgeEarned;
      case 'systemUpdate':
      case 'system_update':
        return NotificationType.systemUpdate;
      default:
        return NotificationType.general;
    }
  }

  NotificationData copyWith({bool? isRead}) {
    return NotificationData(
      id: id,
      title: title,
      body: body,
      subtitle: subtitle,
      type: type,
      data: data,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

// ==================== TASK ASSIGNMENT MODEL ====================

enum TaskAssignmentType {
  manual,     // Admin assigned - mandatory, cannot reject
  proximity,  // Auto-assigned based on proximity - can accept/reject within 60 min
}

enum TaskAssignmentStatus {
  pending,    // Waiting for worker response (for proximity tasks)
  accepted,   // Worker accepted
  rejected,   // Worker rejected
  expired,    // 60 min timeout expired
  assigned,   // Directly assigned by admin
}

class TaskAssignment {
  final int taskId;
  final int reportId;
  final String taskTitle;
  final String taskDescription;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String wasteType;
  final Map<String, double>? aiClassification;
  final TaskAssignmentType assignmentType;
  final TaskAssignmentStatus status;
  final DateTime assignedAt;
  final DateTime? expiresAt;
  final String? assignedBy;
  final double? distance;
  final bool isUrgent;
  final String? priority;

  TaskAssignment({
    required this.taskId,
    required this.reportId,
    required this.taskTitle,
    required this.taskDescription,
    required this.location,
    this.latitude,
    this.longitude,
    this.imageUrl,
    required this.wasteType,
    this.aiClassification,
    required this.assignmentType,
    required this.status,
    required this.assignedAt,
    this.expiresAt,
    this.assignedBy,
    this.distance,
    this.isUrgent = false,
    this.priority,
  });

  factory TaskAssignment.fromNotificationData(NotificationData notification) {
    final data = notification.data;
    final assignmentType = data['assignment_type'] == 'manual'
        ? TaskAssignmentType.manual
        : TaskAssignmentType.proximity;

    DateTime assignedAt = DateTime.now();
    DateTime? expiresAt;

    if (data['assigned_at'] != null) {
      assignedAt = DateTime.parse(data['assigned_at']);
    }

    if (assignmentType == TaskAssignmentType.proximity) {
      expiresAt = assignedAt.add(const Duration(minutes: 60));
    }

    return TaskAssignment(
      taskId: int.tryParse(data['task_id']?.toString() ?? '0') ?? 0,
      reportId: int.tryParse(data['report_id']?.toString() ?? '0') ?? 0,
      taskTitle: data['task_title'] ?? notification.title,
      taskDescription: data['task_description'] ?? notification.body,
      location: data['location'] ?? 'Unknown location',
      latitude: double.tryParse(data['latitude']?.toString() ?? ''),
      longitude: double.tryParse(data['longitude']?.toString() ?? ''),
      imageUrl: data['image_url'],
      wasteType: data['waste_type'] ?? 'General Waste',
      aiClassification: data['ai_classification'] != null
          ? Map<String, double>.from(data['ai_classification'])
          : null,
      assignmentType: assignmentType,
      status: assignmentType == TaskAssignmentType.manual
          ? TaskAssignmentStatus.assigned
          : TaskAssignmentStatus.pending,
      assignedAt: assignedAt,
      expiresAt: expiresAt,
      assignedBy: data['assigned_by'],
      distance: double.tryParse(data['distance']?.toString() ?? ''),
      isUrgent: data['is_urgent'] == true || data['is_urgent'] == 'true',
      priority: data['priority'],
    );
  }

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      taskId: json['task_id'] ?? json['id'] ?? 0,
      reportId: json['report_id'] ?? 0,
      taskTitle: json['task_title'] ?? json['title'] ?? '',
      taskDescription: json['task_description'] ?? json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrl: json['image_url'],
      wasteType: json['waste_type'] ?? 'General Waste',
      aiClassification: json['ai_classification'] != null
          ? Map<String, double>.from(json['ai_classification'])
          : null,
      assignmentType: json['assignment_type'] == 'manual'
          ? TaskAssignmentType.manual
          : TaskAssignmentType.proximity,
      status: _parseStatus(json['status']),
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      assignedBy: json['assigned_by'],
      distance: json['distance']?.toDouble(),
      isUrgent: json['is_urgent'] ?? false,
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'report_id': reportId,
      'task_title': taskTitle,
      'task_description': taskDescription,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'waste_type': wasteType,
      'ai_classification': aiClassification,
      'assignment_type': assignmentType == TaskAssignmentType.manual ? 'manual' : 'proximity',
      'status': status.name,
      'assigned_at': assignedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'assigned_by': assignedBy,
      'distance': distance,
      'is_urgent': isUrgent,
      'priority': priority,
    };
  }

  static TaskAssignmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return TaskAssignmentStatus.pending;
      case 'accepted':
        return TaskAssignmentStatus.accepted;
      case 'rejected':
        return TaskAssignmentStatus.rejected;
      case 'expired':
        return TaskAssignmentStatus.expired;
      case 'assigned':
        return TaskAssignmentStatus.assigned;
      default:
        return TaskAssignmentStatus.pending;
    }
  }

  bool get canRespond {
    if (assignmentType == TaskAssignmentType.manual) return false;
    if (status != TaskAssignmentStatus.pending) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Duration? get remainingTime {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get remainingTimeFormatted {
    final remaining = remainingTime;
    if (remaining == null) return '';
    if (remaining == Duration.zero) return 'Expired';

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s remaining';
    }
    return '${seconds}s remaining';
  }

  String get distanceFormatted {
    if (distance == null) return '';
    if (distance! < 1000) {
      return '${distance!.toStringAsFixed(0)}m away';
    }
    return '${(distance! / 1000).toStringAsFixed(1)}km away';
  }

  TaskAssignment copyWith({TaskAssignmentStatus? status}) {
    return TaskAssignment(
      taskId: taskId,
      reportId: reportId,
      taskTitle: taskTitle,
      taskDescription: taskDescription,
      location: location,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      wasteType: wasteType,
      aiClassification: aiClassification,
      assignmentType: assignmentType,
      status: status ?? this.status,
      assignedAt: assignedAt,
      expiresAt: expiresAt,
      assignedBy: assignedBy,
      distance: distance,
      isUrgent: isUrgent,
      priority: priority,
    );
  }
}