import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/services/notification_service.dart';
import 'package:neat_now/services/task_assignment_service.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:async';

/// TaskNotificationSheet - Shows incoming task notifications with accept/reject (FR-W3)
class TaskNotificationSheet extends StatefulWidget {
  final TaskAssignment assignment;
  final EmployeeResponsiveData responsive;
  final VoidCallback?  onAccepted;
  final VoidCallback? onRejected;
  final VoidCallback? onDismissed;

  const TaskNotificationSheet({
    super.key,
    required this.assignment,
    required this. responsive,
    this.onAccepted,
    this. onRejected,
    this.onDismissed,
  });

  @override
  State<TaskNotificationSheet> createState() => _TaskNotificationSheetState();
}

class _TaskNotificationSheetState extends State<TaskNotificationSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _isProcessing = false;
  String?  _processingAction;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startCountdown();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.assignment. isUrgent) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _startCountdown() {
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    if (! mounted) return;

    final remaining = widget.assignment. remainingTime;
    if (remaining != null) {
      setState(() => _remainingTime = remaining);

      if (remaining == Duration.zero) {
        _countdownTimer?.cancel();
        widget.onDismissed?.call();
      }
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    _countdownTimer?. cancel();
    super.dispose();
  }

  Future<void> _handleAccept() async {
    if (_isProcessing || !widget.assignment. canRespond) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isProcessing = true;
      _processingAction = 'accept';
    });

    final result = await TaskAssignmentService(). acceptAssignment(widget.assignment.taskId);

    if (mounted) {
      setState(() => _isProcessing = false);

      if (result.success) {
        _showSuccessAnimation('Task Accepted! ');
        widget. onAccepted?. call();
      } else {
        _showError(result.message);
      }
    }
  }

  Future<void> _handleReject() async {
    if (_isProcessing || ! widget.assignment.canRespond) return;

    // Show rejection reason dialog
    final reason = await _showRejectReasonDialog();
    if (reason == null) return; // User cancelled

    HapticFeedback.lightImpact();
    setState(() {
      _isProcessing = true;
      _processingAction = 'reject';
    });

    final result = await TaskAssignmentService().rejectAssignment(
      widget.assignment. taskId,
      reason: reason. isNotEmpty ? reason : null,
    );

    if (mounted) {
      setState(() => _isProcessing = false);

      if (result.success) {
        widget.onRejected?.call();
      } else {
        _showError(result.message);
      }
    }
  }

  Future<String?> _showRejectReasonDialog() async {
    final r = widget.responsive;
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Colors.orange, size: r.iconSize(24)),
            SizedBox(width: r.microPadding),
            Text(
              'Reject Task? ',
              style: GoogleFonts.poppins(
                fontSize: r.fontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason (optional):',
              style: GoogleFonts. poppins(
                fontSize: r. fontSize(13),
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: r.microPadding),
            TextField(
              controller: controller,
              maxLines: 3,
              style: GoogleFonts.poppins(fontSize: r.fontSize(13)),
              decoration: InputDecoration(
                hintText: 'e.g., Too far, Already on another task.. .',
                hintStyle: GoogleFonts.poppins(
                  fontSize: r.fontSize(12),
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                contentPadding: EdgeInsets.all(r.microPadding),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
            ),
            child: Text('Reject', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showSuccessAnimation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors. white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(10)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors. white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final assignment = widget.assignment;
    final isManual = assignment.assignmentType == TaskAssignmentType.manual;
    final canRespond = assignment. canRespond;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors. black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
          border: assignment.isUrgent
              ?  Border.all(color: Colors.red, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(r, assignment, isManual),

            // Content
            Padding(
              padding: EdgeInsets.all(r.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task image
                  if (assignment.imageUrl != null && r.showReportImages)
                    _buildTaskImage(r, assignment),

                  // Task details
                  _buildTaskDetails(r, assignment),

                  // AI Classification
                  if (assignment.aiClassification != null && r.showDetailedContent)
                    _buildAIClassification(r, assignment),

                  // Location info
                  _buildLocationInfo(r, assignment),

                  // Timer for proximity tasks
                  if (! isManual && canRespond)
                    _buildCountdownTimer(r),

                  SizedBox(height: r.padding),

                  // Action buttons
                  _buildActionButtons(r, isManual, canRespond),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(EmployeeResponsiveData r, TaskAssignment assignment, bool isManual) {
    return Container(
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: assignment.isUrgent
              ? [Colors.red, Colors. red.shade700]
              : isManual
              ? [Colors. blue, Colors.blue.shade700]
              : [const Color(0xFF2AC2AB), const Color(0xFF1FA896)],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(r. largeBorderRadius),
        ),
      ),
      child: Row(
        children: [
          // Icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: assignment.isUrgent ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: Colors.white. withOpacity(0.2),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Icon(
                assignment.isUrgent
                    ? Icons. warning_rounded
                    : isManual
                    ? Icons.assignment_ind_rounded
                    : Icons.location_on_rounded,
                color: Colors.white,
                size: r.iconSize(24),
              ),
            ),
          ),
          SizedBox(width: r.microPadding),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.isUrgent
                      ?  'URGENT TASK'
                      : isManual
                      ? 'Task Assigned'
                      : 'New Task Nearby',
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(16),
                    fontWeight: FontWeight. bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isManual
                      ? 'Assigned by ${assignment.assignedBy ??  "Administrator"}'
                      : assignment.distanceFormatted,
                  style: GoogleFonts. poppins(
                    fontSize: r.fontSize(11),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Close button
          if (! isManual)
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                widget.onDismissed?.call();
              },
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white. withOpacity(0.8),
                size: r.iconSize(22),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskImage(EmployeeResponsiveData r, TaskAssignment assignment) {
    return Container(
      margin: EdgeInsets. only(bottom: r.padding),
      height: r.reportImageHeight * 0.6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius. circular(r.borderRadius),
        image: DecorationImage(
          image: NetworkImage(assignment.imageUrl! ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius. circular(r.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors. transparent,
              Colors. black.withOpacity(0.5),
            ],
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.all(r.microPadding),
        child: Container(
          padding: EdgeInsets. symmetric(
            horizontal: r. microPadding,
            vertical: r.nanoPadding,
          ),
          decoration: BoxDecoration(
            color: _getWasteTypeColor(assignment.wasteType),
            borderRadius: BorderRadius.circular(r. smallBorderRadius),
          ),
          child: Text(
            assignment. wasteType,
            style: GoogleFonts.poppins(
              fontSize: r.fontSize(10),
              fontWeight: FontWeight. w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDetails(EmployeeResponsiveData r, TaskAssignment assignment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          assignment. taskTitle,
          style: GoogleFonts. poppins(
            fontSize: r. fontSize(16),
            fontWeight: FontWeight.bold,
            color: Colors. grey[900],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: r. nanoPadding),
        Text(
          assignment.taskDescription,
          style: GoogleFonts.poppins(
            fontSize: r.fontSize(13),
            color: Colors.grey[600],
          ),
          maxLines: r.maxTextLines,
          overflow: TextOverflow. ellipsis,
        ),
        SizedBox(height: r.microPadding),
      ],
    );
  }

  Widget _buildAIClassification(EmployeeResponsiveData r, TaskAssignment assignment) {
    final classification = assignment.aiClassification! ;

    return Container(
      margin: EdgeInsets. only(bottom: r.padding),
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors.purple. withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.purple. withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_rounded, size: r.iconSize(16), color: Colors. purple),
              SizedBox(width: r.nanoPadding),
              Text(
                'AI Classification',
                style: GoogleFonts.poppins(
                  fontSize: r.fontSize(12),
                  fontWeight: FontWeight. w600,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: r.nanoPadding),
          Wrap(
            spacing: r.nanoPadding,
            runSpacing: r. nanoPadding,
            children: classification.entries.take(3).map((entry) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.microPadding,
                  vertical: r.nanoPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Text(
                  '${entry.key}: ${(entry.value * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(10),
                    color: Colors.purple,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(EmployeeResponsiveData r, TaskAssignment assignment) {
    return Container(
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(r. borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: r.iconSize(20),
            color: Colors.red,
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.location,
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(13),
                    fontWeight: FontWeight. w500,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow. ellipsis,
                ),
                if (assignment.distance != null)
                  Text(
                    assignment.distanceFormatted,
                    style: GoogleFonts. poppins(
                      fontSize: r.fontSize(11),
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (assignment.latitude != null && assignment. longitude != null)
            IconButton(
              onPressed: () {
                // Navigate to location
              },
              icon: Icon(
                Icons.navigation_rounded,
                color: Colors.blue,
                size: r.iconSize(20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer(EmployeeResponsiveData r) {
    final minutes = _remainingTime. inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    final isLowTime = _remainingTime.inMinutes < 10;

    return Container(
      margin: EdgeInsets. only(top: r.microPadding),
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red. withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(
          color: isLowTime ? Colors. red. withOpacity(0.3) : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_rounded,
            size: r.iconSize(18),
            color: isLowTime ?  Colors.red : Colors.orange,
          ),
          SizedBox(width: r.microPadding),
          Text(
            'Respond within ',
            style: GoogleFonts.poppins(
              fontSize: r.fontSize(12),
              color: isLowTime ?  Colors.red : Colors.orange[800],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r. microPadding,
              vertical: r.nanoPadding,
            ),
            decoration: BoxDecoration(
              color: isLowTime ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Text(
              '${minutes. toString().padLeft(2, '0')}:${seconds. toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(
                fontSize: r.fontSize(14),
                fontWeight: FontWeight. bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EmployeeResponsiveData r, bool isManual, bool canRespond) {
    if (isManual) {
      // Mandatory task - only show "View Task" button
      return SizedBox(
        width: double.infinity,
        height: r.buttonHeight,
        child: ElevatedButton. icon(
          onPressed: () {
            widget.onAccepted?.call();
          },
          icon: Icon(Icons.visibility_rounded, size: r.iconSize(18)),
          label: Text(
            'View Task Details',
            style: GoogleFonts. poppins(
              fontSize: r. fontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors. blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
          ),
        ),
      );
    }

    // Proximity task - show Accept/Reject buttons
    return Row(
      children: [
        // Reject button
        Expanded(
          child: SizedBox(
            height: r.buttonHeight,
            child: OutlinedButton. icon(
              onPressed: canRespond && !_isProcessing ?  _handleReject : null,
              icon: _isProcessing && _processingAction == 'reject'
                  ? SizedBox(
                width: r. iconSize(16),
                height: r.iconSize(16),
                child: const CircularProgressIndicator(strokeWidth: 2),
              )
                  : Icon(Icons.close_rounded, size: r. iconSize(18)),
              label: Text(
                'Reject',
                style: GoogleFonts.poppins(
                  fontSize: r.fontSize(13),
                  fontWeight: FontWeight. w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors. red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius. circular(r.borderRadius),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: r.microPadding),
        // Accept button
        Expanded(
          flex: 2,
          child: SizedBox(
            height: r.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: canRespond && !_isProcessing ? _handleAccept : null,
              icon: _isProcessing && _processingAction == 'accept'
                  ?  SizedBox(
                width: r.iconSize(16),
                height: r.iconSize(16),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors. white,
                ),
              )
                  : Icon(Icons.check_rounded, size: r. iconSize(18)),
              label: Text(
                'Accept Task',
                style: GoogleFonts. poppins(
                  fontSize: r.fontSize(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2AC2AB),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getWasteTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('plastic')) return Colors.blue;
    if (t.contains('organic')) return Colors.green;
    if (t.contains('hazardous')) return Colors.red;
    if (t.contains('electronic')) return Colors.purple;
    if (t.contains('glass')) return Colors.teal;
    if (t.contains('metal')) return Colors. grey;
    return Colors.orange;
  }
}