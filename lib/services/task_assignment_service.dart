import 'package:flutter/material.dart';
import 'dart:async';
import 'package:neat_now/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// TaskAssignmentService - Manages task assignments and responses (FR-W3)
class TaskAssignmentService {
  static final TaskAssignmentService _instance = TaskAssignmentService._internal();
  factory TaskAssignmentService() => _instance;
  TaskAssignmentService._internal();

  final List<TaskAssignment> _pendingAssignments = [];
  final List<TaskAssignment> _assignmentHistory = [];

  final StreamController<List<TaskAssignment>> _pendingController =
  StreamController<List<TaskAssignment>>.broadcast();
  final StreamController<TaskAssignment> _assignmentUpdateController =
  StreamController<TaskAssignment>.broadcast();

  Stream<List<TaskAssignment>> get pendingAssignmentsStream => _pendingController.stream;
  Stream<TaskAssignment> get assignmentUpdateStream => _assignmentUpdateController. stream;

  List<TaskAssignment> get pendingAssignments => List.unmodifiable(_pendingAssignments);
  int get pendingCount => _pendingAssignments.where((a) => a.canRespond).length;

  Timer? _expirationTimer;

  /// Initialize service
  Future<void> initialize() async {
    await _loadPendingAssignments();
    _startExpirationChecker();

    // Listen to notification service for new assignments
    NotificationService(). taskAssignmentStream.listen(_handleNewAssignment);
  }

  void _handleNewAssignment(TaskAssignment assignment) {
    // Check if already exists
    final existingIndex = _pendingAssignments.indexWhere((a) => a. taskId == assignment. taskId);

    if (existingIndex >= 0) {
      _pendingAssignments[existingIndex] = assignment;
    } else {
      _pendingAssignments.add(assignment);
    }

    _savePendingAssignments();
    _pendingController.add(_pendingAssignments);
  }

  /// Accept a task assignment
  Future<TaskAssignmentResult> acceptAssignment(int taskId) async {
    final index = _pendingAssignments.indexWhere((a) => a.taskId == taskId);

    if (index < 0) {
      return TaskAssignmentResult(
        success: false,
        message: 'Assignment not found',
      );
    }

    final assignment = _pendingAssignments[index];

    // Check if it's a manual assignment (already assigned, can't accept/reject)
    if (assignment.assignmentType == TaskAssignmentType.manual) {
      return TaskAssignmentResult(
        success: false,
        message: 'This task was assigned by administrator and is already active',
      );
    }

    // Check if expired
    if (assignment.isExpired) {
      _pendingAssignments[index] = assignment. copyWith(status: TaskAssignmentStatus.expired);
      _pendingController.add(_pendingAssignments);
      _savePendingAssignments();

      return TaskAssignmentResult(
        success: false,
        message: 'Assignment has expired',
      );
    }

    // Check if can respond
    if (! assignment.canRespond) {
      return TaskAssignmentResult(
        success: false,
        message: 'Cannot respond to this assignment',
      );
    }

    try {
      // Call API to accept assignment
      final success = await _sendAssignmentResponse(taskId, true);

      if (success) {
        final updatedAssignment = assignment.copyWith(status: TaskAssignmentStatus.accepted);
        _pendingAssignments[index] = updatedAssignment;
        _assignmentHistory.add(updatedAssignment);
        _pendingAssignments.removeAt(index);

        _pendingController.add(_pendingAssignments);
        _assignmentUpdateController.add(updatedAssignment);
        _savePendingAssignments();

        return TaskAssignmentResult(
          success: true,
          message: 'Task accepted successfully',
          assignment: updatedAssignment,
        );
      } else {
        return TaskAssignmentResult(
          success: false,
          message: 'Failed to accept task.  Please try again.',
        );
      }
    } catch (e) {
      return TaskAssignmentResult(
        success: false,
        message: 'Error accepting task: ${e.toString()}',
      );
    }
  }

  /// Reject a task assignment
  Future<TaskAssignmentResult> rejectAssignment(int taskId, {String? reason}) async {
    final index = _pendingAssignments. indexWhere((a) => a.taskId == taskId);

    if (index < 0) {
      return TaskAssignmentResult(
        success: false,
        message: 'Assignment not found',
      );
    }

    final assignment = _pendingAssignments[index];

    // Check if it's a manual assignment (cannot reject)
    if (assignment.assignmentType == TaskAssignmentType.manual) {
      return TaskAssignmentResult(
        success: false,
        message: 'Tasks assigned by administrator cannot be rejected',
      );
    }

    // Check if expired
    if (assignment.isExpired) {
      _pendingAssignments[index] = assignment.copyWith(status: TaskAssignmentStatus.expired);
      _pendingController.add(_pendingAssignments);
      _savePendingAssignments();

      return TaskAssignmentResult(
        success: false,
        message: 'Assignment has expired',
      );
    }

    // Check if can respond
    if (! assignment.canRespond) {
      return TaskAssignmentResult(
        success: false,
        message: 'Cannot respond to this assignment',
      );
    }

    try {
      // Call API to reject assignment
      final success = await _sendAssignmentResponse(taskId, false, reason: reason);

      if (success) {
        final updatedAssignment = assignment.copyWith(status: TaskAssignmentStatus.rejected);
        _pendingAssignments[index] = updatedAssignment;
        _assignmentHistory.add(updatedAssignment);
        _pendingAssignments.removeAt(index);

        _pendingController.add(_pendingAssignments);
        _assignmentUpdateController.add(updatedAssignment);
        _savePendingAssignments();

        return TaskAssignmentResult(
          success: true,
          message: 'Task rejected',
          assignment: updatedAssignment,
        );
      } else {
        return TaskAssignmentResult(
          success: false,
          message: 'Failed to reject task. Please try again.',
        );
      }
    } catch (e) {
      return TaskAssignmentResult(
        success: false,
        message: 'Error rejecting task: ${e. toString()}',
      );
    }
  }

  Future<bool> _sendAssignmentResponse(int taskId, bool accept, {String? reason}) async {
    // TODO: Implement actual API call
    // For now, simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  void _startExpirationChecker() {
    _expirationTimer?. cancel();
    _expirationTimer = Timer. periodic(const Duration(seconds: 30), (_) {
      _checkExpirations();
    });
  }

  void _checkExpirations() {
    bool hasChanges = false;

    for (int i = 0; i < _pendingAssignments.length; i++) {
      final assignment = _pendingAssignments[i];
      if (assignment.status == TaskAssignmentStatus.pending && assignment.isExpired) {
        _pendingAssignments[i] = assignment. copyWith(status: TaskAssignmentStatus.expired);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      _pendingController.add(_pendingAssignments);
      _savePendingAssignments();
    }
  }

  Future<void> _loadPendingAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('pending_assignments');

      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        _pendingAssignments.clear();
        _pendingAssignments.addAll(
          jsonList.map((json) => TaskAssignment.fromJson(json)).toList(),
        );
        _pendingController.add(_pendingAssignments);
      }
    } catch (e) {
      debugPrint('Error loading pending assignments: $e');
    }
  }

  Future<void> _savePendingAssignments() async {
    try {
      final prefs = await SharedPreferences. getInstance();
      final data = jsonEncode(_pendingAssignments.map((a) => a.toJson()).toList());
      await prefs.setString('pending_assignments', data);
    } catch (e) {
      debugPrint('Error saving pending assignments: $e');
    }
  }

  /// Get assignment by task ID
  TaskAssignment?  getAssignment(int taskId) {
    return _pendingAssignments.firstWhere(
          (a) => a.taskId == taskId,
      orElse: () => _assignmentHistory.firstWhere(
            (a) => a. taskId == taskId,
        orElse: () => throw StateError('Assignment not found'),
      ),
    );
  }

  /// Clear expired assignments
  void clearExpiredAssignments() {
    _pendingAssignments.removeWhere((a) => a.status == TaskAssignmentStatus.expired);
    _pendingController.add(_pendingAssignments);
    _savePendingAssignments();
  }

  void dispose() {
    _expirationTimer?.cancel();
    _pendingController.close();
    _assignmentUpdateController.close();
  }
}

class TaskAssignmentResult {
  final bool success;
  final String message;
  final TaskAssignment? assignment;

  TaskAssignmentResult({
    required this.success,
    required this. message,
    this.assignment,
  });
}