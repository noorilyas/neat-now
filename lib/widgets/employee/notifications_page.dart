import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'package:neat_now/services/employee_service.dart';
import 'dart:math' as math;

/// ==================== DESIGN SYSTEM ====================
class NotificationDesign {
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAFBFC);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color purple = Color(0xFF8B5CF6);
}

/// ==================== NOTIFICATION TYPES ====================
enum ModernNotificationType {
  newAssignment,      // New report assigned - can accept/reject
  taskReminder,       // Reminder for pending tasks
  overdueAlert,       // Overdue task alert
  feedbackReceived,   // Feedback on resolved report
  reportVerified,     // Report verified by admin
  achievementUnlocked,// Badge or achievement
  systemUpdate,       // System notifications
}

/// ==================== NOTIFICATIONS PAGE ====================
class NotificationsPage extends StatefulWidget {
  final EmployeeResponsiveData responsive;

  const NotificationsPage({
    super.key,
    required this.responsive,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _successController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<ModernNotification> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  bool _showSuccessOverlay = false;
  String _successMessage = '';

  final List<_FilterOption> _filters = [
    _FilterOption('all', 'All', Icons.all_inbox_rounded),
    _FilterOption('assignments', 'Assignments', Icons.assignment_rounded),
    _FilterOption('feedback', 'Feedback', Icons.rate_review_rounded),
    _FilterOption('alerts', 'Alerts', Icons.warning_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadNotifications();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset. zero,
    ). animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _successController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController. forward();
    _slideController.forward();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    // Simulated notifications data
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _notifications = _generateDemoNotifications();
      _isLoading = false;
    });
  }

  List<ModernNotification> _generateDemoNotifications() {
    final now = DateTime.now();

    return [
      // New Assignment - Can Accept/Reject
      ModernNotification(
        id: '1',
        type: ModernNotificationType.newAssignment,
        title: 'New Task Assignment',
        message: 'Plastic waste collection near Central Park has been assigned to you.',
        timestamp: now. subtract(const Duration(minutes: 5)),
        isRead: false,
        isActionable: true,
        reportData: {
          'id': 101,
          'type': 'Plastic Waste',
          'location': 'Central Park, Block A',
          'priority': 'high',
          'image_url': 'https://example.com/waste1.jpg',
          'distance': '1. 2 km',
          'estimated_time': '25 min',
        },
      ),

      // Feedback Received
      ModernNotification(
        id: '2',
        type: ModernNotificationType. feedbackReceived,
        title: 'New Feedback Received!  ⭐',
        message: 'You received a 5-star rating for Report #98. Great work!',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        feedbackData: {
          'report_id': 98,
          'rating': 5,
          'comment': 'Excellent job!  The area is now spotlessly clean.  Thank you for your quick response.',
          'reviewer_name': 'Admin Sarah',
          'report_type': 'Organic Waste',
        },
      ),

      // Another Assignment
      ModernNotification(
        id: '3',
        type: ModernNotificationType.newAssignment,
        title: 'Urgent: Hazardous Waste',
        message: 'High priority hazardous waste report needs immediate attention.',
        timestamp: now. subtract(const Duration(hours: 2)),
        isRead: false,
        isActionable: true,
        isUrgent: true,
        reportData: {
          'id': 102,
          'type': 'Hazardous Waste',
          'location': 'Industrial Zone, Sector 5',
          'priority': 'urgent',
          'image_url': 'https://example.com/waste2.jpg',
          'distance': '3.5 km',
          'estimated_time': '45 min',
        },
      ),

      // Report Verified
      ModernNotification(
        id: '4',
        type: ModernNotificationType.reportVerified,
        title: 'Report Verified ✓',
        message: 'Your resolved Report #95 has been verified and approved.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        reportData: {
          'id': 95,
          'type': 'Electronic Waste',
          'points_earned': 50,
        },
      ),

      // Overdue Alert
      ModernNotification(
        id: '5',
        type: ModernNotificationType.overdueAlert,
        title: 'Overdue Task Alert! ',
        message: 'Report #89 has been pending for 3 days. Please take action.',
        timestamp: now.subtract(const Duration(hours: 5)),
        isRead: true,
        isUrgent: true,
        reportData: {
          'id': 89,
          'type': 'Mixed Waste',
          'days_overdue': 3,
        },
      ),

      // Achievement
      ModernNotification(
        id: '6',
        type: ModernNotificationType.achievementUnlocked,
        title: '🏆 Achievement Unlocked!',
        message: 'You\'ve completed 100 tasks this month. You earned the "Century Hero" badge!',
        timestamp: now. subtract(const Duration(days: 1)),
        isRead: true,
        achievementData: {
          'badge_name': 'Century Hero',
          'badge_icon': 'military_tech',
          'points_earned': 500,
        },
      ),

      // Feedback with lower rating
      ModernNotification(
        id: '7',
        type: ModernNotificationType. feedbackReceived,
        title: 'Feedback Received',
        message: 'You received feedback for Report #85.',
        timestamp: now.subtract(const Duration(days: 1, hours: 5)),
        isRead: true,
        feedbackData: {
          'report_id': 85,
          'rating': 4,
          'comment': 'Good work, but please ensure to take after photos next time.',
          'reviewer_name': 'Supervisor Mike',
          'report_type': 'Plastic Waste',
        },
      ),

      // Task Reminder
      ModernNotification(
        id: '8',
        type: ModernNotificationType.taskReminder,
        title: 'Task Reminder',
        message: 'You have 2 tasks pending for today. Don\'t forget to complete them!',
        timestamp: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];
  }

  List<ModernNotification> get _filteredNotifications {
    if (_selectedFilter == 'all') return _notifications;

    return _notifications.where((n) {
      switch (_selectedFilter) {
        case 'assignments':
          return n.type == ModernNotificationType. newAssignment;
        case 'feedback':
          return n.type == ModernNotificationType.feedbackReceived;
        case 'alerts':
          return n.type == ModernNotificationType.overdueAlert ||
              n.type == ModernNotificationType.taskReminder;
        default:
          return true;
      }
    }). toList();
  }

  void _handleAcceptTask(ModernNotification notification) async {
    HapticFeedback.heavyImpact();

    // Show success animation
    setState(() {
      _showSuccessOverlay = true;
      _successMessage = 'Task Accepted Successfully!';
    });

    _successController.forward(from: 0);

    // Remove from list after animation
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _notifications.removeWhere((n) => n.id == notification. id);
      _showSuccessOverlay = false;
    });
  }

  void _handleRejectTask(ModernNotification notification) async {
    HapticFeedback. mediumImpact();

    // Show rejection dialog
    final confirmed = await _showRejectDialog();

    if (confirmed == true) {
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });

      _showSnackBar('Task declined', isError: false);
    }
  }

  Future<bool? > _showRejectDialog() {
    final r = widget.responsive;

    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Reject',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: math.min(r.dialogMaxWidth, r.effectiveWidth - r.padding * 2),
              padding: EdgeInsets.all(r.largePadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors. black.withOpacity(0.1),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets. all(r.microPadding),
                    decoration: BoxDecoration(
                      color: NotificationDesign.warning.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons. help_outline_rounded,
                      size: r.iconSize(36),
                      color: NotificationDesign.warning,
                    ),
                  ),
                  SizedBox(height: r.padding),
                  Text(
                    'Decline Task? ',
                    style: GoogleFonts.inter(
                      fontSize: r. headingXS,
                      fontWeight: FontWeight. w700,
                      color: NotificationDesign.textPrimary,
                    ),
                  ),
                  SizedBox(height: r.microPadding),
                  Text(
                    'This task will be reassigned to another worker.',
                    style: GoogleFonts. inter(
                      fontSize: r.bodyS,
                      color: NotificationDesign.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: r.largePadding),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NotificationDesign.textSecondary,
                            side: BorderSide(color: Colors.grey[300]! ),
                            padding: EdgeInsets. symmetric(vertical: r.microPadding),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(r. borderRadius),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(fontWeight: FontWeight. w600),
                          ),
                        ),
                      ),
                      SizedBox(width: r.microPadding),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NotificationDesign.error,
                            foregroundColor: Colors. white,
                            padding: EdgeInsets. symmetric(vertical: r.microPadding),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(r.borderRadius),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Decline',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ?  Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: isError ? NotificationDesign.error : NotificationDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Scaffold(
      backgroundColor: NotificationDesign.surfaceLight,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // App Bar
                _buildAppBar(r),

                // Filter chips
                _buildFilterChips(r),

                // Notifications List
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _isLoading
                          ? _buildLoadingState(r)
                          : _filteredNotifications.isEmpty
                          ? _buildEmptyState(r)
                          : _buildNotificationsList(r),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Success Overlay
          if (_showSuccessOverlay)
            _buildSuccessOverlay(r),
        ],
      ),
    );
  }

  Widget _buildAppBar(EmployeeResponsiveData r) {
    final unreadCount = _notifications. where((n) => ! n.isRead).length;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r. padding,
        vertical: r.microPadding,
      ),
      decoration: BoxDecoration(
        color: NotificationDesign.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black. withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius. circular(r.borderRadius),
              child: Container(
                padding: EdgeInsets.all(r.microPadding),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: r.iconSize(20),
                  color: NotificationDesign.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: r. microPadding),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: NotificationDesign.textPrimary,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      color: NotificationDesign.primaryTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Mark all read button
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  for (var n in _notifications) {
                    n.isRead = true;
                  }
                });
              },
              child: Text(
                'Mark all read',
                style: GoogleFonts. inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight. w600,
                  color: NotificationDesign.primaryTeal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(EmployeeResponsiveData r) {
    return Container(
      height: r.dimension(50),
      padding: EdgeInsets.symmetric(vertical: r.nanoPadding),
      child: ListView.builder(
        scrollDirection: Axis. horizontal,
        padding: EdgeInsets. symmetric(horizontal: r. padding),
        itemCount: _filters. length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter. value;
          final count = _getFilterCount(filter. value);

          return Padding(
            padding: EdgeInsets.only(right: r. microPadding),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedFilter = filter.value);
                },
                borderRadius: BorderRadius. circular(r.pillBorderRadius),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets. symmetric(
                    horizontal: r.microPadding,
                    vertical: r. nanoPadding,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? NotificationDesign.primaryTeal
                        : NotificationDesign. surfaceWhite,
                    borderRadius: BorderRadius.circular(r.pillBorderRadius),
                    border: Border.all(
                      color: isSelected
                          ?  NotificationDesign. primaryTeal
                          : Colors.grey. withOpacity(0.2),
                    ),
                    boxShadow: isSelected
                        ?  [
                      BoxShadow(
                        color: NotificationDesign.primaryTeal.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter. icon,
                        size: r.iconSize(16),
                        color: isSelected
                            ? Colors.white
                            : NotificationDesign.textSecondary,
                      ),
                      SizedBox(width: r.nanoPadding),
                      Text(
                        filter.label,
                        style: GoogleFonts.inter(
                          fontSize: r. captionM,
                          fontWeight: FontWeight. w600,
                          color: isSelected
                              ?  Colors.white
                              : NotificationDesign.textSecondary,
                        ),
                      ),
                      if (count > 0) ...[
                        SizedBox(width: r.nanoPadding),
                        Container(
                          padding: EdgeInsets. symmetric(
                            horizontal: r.nanoPadding,
                            vertical: r.atomicPadding,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ?  Colors.white. withOpacity(0.2)
                                : NotificationDesign.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius. circular(r.smallBorderRadius),
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.inter(
                              fontSize: r.captionXS,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors. white
                                  : NotificationDesign.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  int _getFilterCount(String filter) {
    if (filter == 'all') return _notifications.where((n) => ! n.isRead). length;

    return _notifications. where((n) {
      if (n.isRead) return false;
      switch (filter) {
        case 'assignments':
          return n. type == ModernNotificationType.newAssignment;
        case 'feedback':
          return n.type == ModernNotificationType.feedbackReceived;
        case 'alerts':
          return n.type == ModernNotificationType.overdueAlert ||
              n. type == ModernNotificationType.taskReminder;
        default:
          return false;
      }
    }).length;
  }

  Widget _buildNotificationsList(EmployeeResponsiveData r) {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: NotificationDesign.primaryTeal,
      child: ListView.builder(
        padding: EdgeInsets. all(r.padding),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = _filteredNotifications[index];
          return _buildNotificationCard(r, notification, index);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      EmployeeResponsiveData r,
      ModernNotification notification,
      int index,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets. only(bottom: r.microPadding),
        decoration: BoxDecoration(
          color: NotificationDesign.surfaceWhite,
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: notification.isUrgent
              ?  Border.all(color: NotificationDesign.error. withOpacity(0.3), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() => notification.isRead = true);
              _handleNotificationTap(notification);
            },
            borderRadius: BorderRadius. circular(r.largeBorderRadius),
            child: Padding(
              padding: EdgeInsets. all(r.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      _buildNotificationIcon(r, notification),
                      SizedBox(width: r.microPadding),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment. start,
                          children: [
                            // Title row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: GoogleFonts.inter(
                                      fontSize: r.bodyS,
                                      fontWeight: notification.isRead
                                          ?  FontWeight.w600
                                          : FontWeight.w700,
                                      color: notification.isUrgent
                                          ? NotificationDesign.error
                                          : NotificationDesign. textPrimary,
                                    ),
                                  ),
                                ),
                                if (! notification.isRead)
                                  Container(
                                    width: r.dimension(8),
                                    height: r.dimension(8),
                                    decoration: BoxDecoration(
                                      color: NotificationDesign.primaryTeal,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: r.atomicPadding),

                            // Message
                            Text(
                              notification.message,
                              style: GoogleFonts.inter(
                                fontSize: r. captionM,
                                color: NotificationDesign.textSecondary,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: r.nanoPadding),

                            // Timestamp
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: GoogleFonts.inter(
                                fontSize: r.captionXS,
                                color: NotificationDesign.textSecondary. withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Extended content based on type
                  if (notification.type == ModernNotificationType. newAssignment &&
                      notification. isActionable)
                    _buildAssignmentCard(r, notification),

                  if (notification.type == ModernNotificationType.feedbackReceived)
                    _buildFeedbackCard(r, notification),

                  if (notification.type == ModernNotificationType.achievementUnlocked)
                    _buildAchievementCard(r, notification),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(EmployeeResponsiveData r, ModernNotification notification) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (notification. type) {
      case ModernNotificationType.newAssignment:
        icon = Icons.assignment_rounded;
        color = notification.isUrgent ? NotificationDesign.error : NotificationDesign. info;
        bgColor = color.withOpacity(0.1);
        break;
      case ModernNotificationType.feedbackReceived:
        icon = Icons.rate_review_rounded;
        color = NotificationDesign.warning;
        bgColor = color.withOpacity(0.1);
        break;
      case ModernNotificationType.reportVerified:
        icon = Icons.verified_rounded;
        color = NotificationDesign.success;
        bgColor = color.withOpacity(0.1);
        break;
      case ModernNotificationType.overdueAlert:
        icon = Icons.warning_rounded;
        color = NotificationDesign. error;
        bgColor = color.withOpacity(0.1);
        break;
      case ModernNotificationType. achievementUnlocked:
        icon = Icons.emoji_events_rounded;
        color = NotificationDesign.warning;
        bgColor = color.withOpacity(0.1);
        break;
      case ModernNotificationType.taskReminder:
        icon = Icons.schedule_rounded;
        color = NotificationDesign.purple;
        bgColor = color.withOpacity(0.1);
        break;
      default:
        icon = Icons.notifications_rounded;
        color = NotificationDesign.primaryTeal;
        bgColor = color. withOpacity(0.1);
    }

    return Container(
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(r.borderRadius),
      ),
      child: Icon(icon, size: r. iconSize(22), color: color),
    );
  }

  Widget _buildAssignmentCard(EmployeeResponsiveData r, ModernNotification notification) {
    final data = notification.reportData ??  {};

    return Container(
      margin: EdgeInsets. only(top: r.microPadding),
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: NotificationDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(
          color: notification.isUrgent
              ? NotificationDesign.error. withOpacity(0.2)
              : Colors.grey. withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
      // Report details
      Row(
      children: [
      // Waste type chip
      Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.nanoPadding,
        vertical: r.atomicPadding,
      ),
      decoration: BoxDecoration(
        color: _getWasteTypeColor(data['type'] ?? ''). withOpacity(0.1),
        borderRadius: BorderRadius. circular(r.smallBorderRadius),
      ),
      child: Text(
        data['type'] ?? 'Unknown',
        style: GoogleFonts.inter(
          fontSize: r. captionXS,
          fontWeight: FontWeight.w600,
          color: _getWasteTypeColor(data['type'] ?? ''),
        ),
      ),
    ),
    SizedBox(width: r. microPadding),

    // Location
    Icon(
    Icons. location_on_outlined,
    size: r.iconSize(14),
    color: NotificationDesign.textSecondary,
    ),
    SizedBox(width: r.atomicPadding),
    Expanded(
    child: Text(
    data['location'] ?? 'Unknown location',
    style: GoogleFonts.inter(
    fontSize: r. captionS,
    color: NotificationDesign.textSecondary,
    ),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    ),
    ),
    ],
    ),
    SizedBox(height: r.microPadding),

    // Distance and time
    Row(
    children: [
    _buildInfoChip(r, Icons.directions_walk_rounded, data['distance'] ?? '-'),
    SizedBox(width: r.microPadding),
    _buildInfoChip(r, Icons.schedule_rounded, data['estimated_time'] ?? '-'),
    if (data['priority'] == 'urgent' || data['priority'] == 'high') ...[
    SizedBox(width: r.microPadding),
    Container(
    padding: EdgeInsets. symmetric(
    horizontal: r.nanoPadding,
    vertical: r.atomicPadding,
    ),
    decoration: BoxDecoration(
    color: NotificationDesign.error,
    borderRadius: BorderRadius.circular(r.smallBorderRadius),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(Icons.priority_high_rounded, size: r. iconSize(12), color: Colors.white),
    SizedBox(width: r.atomicPadding),
    Text(
    'URGENT',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    ),
    ),
    ],
    ),
    ),
    ],
    ],
    ),
    SizedBox(height: r.microPadding),

    // Action buttons
    Row(
    children: [
    // Reject button
    Expanded(
    child: OutlinedButton.icon(
    onPressed: () => _handleRejectTask(notification),
    icon: Icon(Icons.close_rounded, size: r.iconSize(18)),
    label: Text(
    'Decline',
    style: GoogleFonts.inter(fontWeight: FontWeight. w600),
    ),
    style: OutlinedButton.styleFrom(
    foregroundColor: NotificationDesign.error,
    side: BorderSide(color: NotificationDesign.error. withOpacity(0.5)),
    padding: EdgeInsets. symmetric(vertical: r.microPadding),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(r.borderRadius),
    ),
    ),
    ),
    ),
    SizedBox(width: r.microPadding),

    // Accept button
    Expanded(
    flex: 2,
    child: ElevatedButton.icon(
    onPressed: () => _handleAcceptTask(notification),
    icon: Icon(Icons.check_rounded, size: r.iconSize(18)),
    label: Text(
    'Accept Task',
    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
    ),
    style: ElevatedButton. styleFrom(
    backgroundColor: NotificationDesign.success,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(vertical: r.microPadding),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(r.borderRadius),
    ),
    elevation: 0,
    ),
    ),
    ),
    ],
    ),
    ],
    ),
    );
  }

  Widget _buildFeedbackCard(EmployeeResponsiveData r, ModernNotification notification) {
    final data = notification.feedbackData ?? {};
    final rating = data['rating'] ?? 0;

    return Container(
      margin: EdgeInsets. only(top: r.microPadding),
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NotificationDesign.warning.withOpacity(0.1),
            NotificationDesign.warning.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius. circular(r.borderRadius),
        border: Border.all(color: NotificationDesign.warning.withOpacity(0.2)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      // Rating stars
      Row(
      children: [
      ... List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(right: r. atomicPadding),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Icon(
              index < rating ? Icons. star_rounded : Icons.star_outline_rounded,
              size: r.iconSize(24),
              color: index < rating
                  ? NotificationDesign.warning
                  : NotificationDesign.textSecondary. withOpacity(0.3),
            ),
          ),
        );
      }),
      const Spacer(),
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.nanoPadding,
          vertical: r.atomicPadding,
        ),
        decoration: BoxDecoration(
          color: NotificationDesign. warning,
          borderRadius: BorderRadius.circular(r.smallBorderRadius),
        ),
        child: Text(
          '$rating/5',
          style: GoogleFonts.inter(
            fontSize: r.captionS,
            fontWeight: FontWeight. w700,
            color: Colors.white,
          ),
        ),
      ),
      ],
    ),

    if (data['comment'] != null && data['comment']. toString().isNotEmpty) ...[
    SizedBox(height: r.microPadding),
    Container(
    padding: EdgeInsets.all(r.microPadding),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(r.smallBorderRadius),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Icon(
    Icons.format_quote_rounded,
    size: r.iconSize(16),
    color: NotificationDesign.textSecondary. withOpacity(0.5),
    ),
    SizedBox(width: r.nanoPadding),
    Text(
    data['reviewer_name'] ?? 'Anonymous',
    style: GoogleFonts.inter(
    fontSize: r. captionXS,
    fontWeight: FontWeight.w600,
    color: NotificationDesign.textSecondary,
    ),
    ),
    ],
    ),
    SizedBox(height: r.nanoPadding),
    Text(
    data['comment'] ?? '',
    style: GoogleFonts. inter(
    fontSize: r.captionM,
    color: NotificationDesign.textPrimary,
    fontStyle: FontStyle.italic,
    height: 1.4,
    ),
    ),
    ],
    ),
    ),
    ],

    SizedBox(height: r.microPadding),
    Row(
    children: [
    Icon(
    Icons. assignment_rounded,
    size: r.iconSize(14),
    color: NotificationDesign. textSecondary,
    ),
    SizedBox(width: r.atomicPadding),
    Text(
    'Report #${data['report_id'] ?? '-'} • ${data['report_type'] ?? ''}',
    style: GoogleFonts.inter(
    fontSize: r. captionXS,
    color: NotificationDesign.textSecondary,
    ),
    ),
    ],
    ),
    ],
    ),
    );
  }

  Widget _buildAchievementCard(EmployeeResponsiveData r, ModernNotification notification) {
    final data = notification. achievementData ?? {};

    return Container(
      margin: EdgeInsets. only(top: r.microPadding),
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFFBEB),
            const Color(0xFFFEF3C7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(r. borderRadius),
        border: Border.all(color: NotificationDesign.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Badge icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform. scale(
                scale: value,
                child: Transform.rotate(
                  angle: (1 - value) * 0.5,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NotificationDesign. warning,
                    NotificationDesign.warning. withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: NotificationDesign.warning. withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.military_tech_rounded,
                size: r.iconSize(28),
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: r.microPadding),

          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['badge_name'] ?? 'Achievement',
                  style: GoogleFonts. inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w700,
                    color: NotificationDesign.textPrimary,
                  ),
                ),
                SizedBox(height: r.atomicPadding),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: r.iconSize(14),
                      color: NotificationDesign.warning,
                    ),
                    SizedBox(width: r. atomicPadding),
                    Text(
                      '+${data['points_earned'] ?? 0} points',
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        fontWeight: FontWeight. w600,
                        color: NotificationDesign.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Confetti icon
          Icon(
            Icons. celebration_rounded,
            size: r.iconSize(24),
            color: NotificationDesign. warning. withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(EmployeeResponsiveData r, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r. nanoPadding,
        vertical: r.atomicPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r. smallBorderRadius),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.iconSize(12), color: NotificationDesign.textSecondary),
          SizedBox(width: r.atomicPadding),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: r. captionXS,
              color: NotificationDesign.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay(EmployeeResponsiveData r) {
    return AnimatedBuilder(
        animation: _successController,
        builder: (context, child) {
          final progress = _successController. value;

          return Container(
              color: Colors.black.withOpacity(0.5 * math.min(1, progress * 2)),
              child: Center(
                  child: Transform.scale(
                      scale: Curves.elasticOut.transform(math.min(1, progress * 1.5)),
                      child: Container(
                          padding: EdgeInsets.all(r.largePadding),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius. circular(r.extraLargeBorderRadius),
                            boxShadow: [
                              BoxShadow(
                                color: NotificationDesign.success.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize. min,
                            children: [
                            // Animated checkmark
                            Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ring
                              SizedBox(
                                width: r.dimension(80),
                                height: r.dimension(80),
                                child: CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 4,
                                  color: NotificationDesign.success,
                                  backgroundColor: NotificationDesign.success.withOpacity(0.2),
                                ),
                              ),
                              // Check icon
                              Container(
                                padding: EdgeInsets.all(r.padding),
                                decoration: BoxDecoration(
                                  color: NotificationDesign.success,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: r.iconSize(36),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: r.padding),
                          Text(
                              _successMessage,
                              style: GoogleFonts.inter(
                                  fontSize: r. bodyM,
                                fontWeight: FontWeight. w700,
                                color: NotificationDesign.textPrimary,
                              ),
                            textAlign: TextAlign. center,
                          ),
                              SizedBox(height: r.nanoPadding),
                              Text(
                                'The task has been added to your queue',
                                style: GoogleFonts. inter(
                                  fontSize: r.captionM,
                                  color: NotificationDesign.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              // Confetti particles
                              if (progress > 0.5)
                                SizedBox(
                                  height: r. dimension(60),
                                  child: _buildConfettiParticles(r, progress),
                                ),
                            ],
                          ),
                      ),
                  ),
              ),
          );
        },
    );
  }

  Widget _buildConfettiParticles(EmployeeResponsiveData r, double progress) {
    final colors = [
      NotificationDesign.primaryTeal,
      NotificationDesign.success,
      NotificationDesign.warning,
      NotificationDesign.info,
      NotificationDesign.purple,
    ];

    return Stack(
      alignment: Alignment.center,
      children: List.generate(20, (index) {
        final random = math.Random(index);
        final angle = (index / 20) * 2 * math.pi;
        final radius = 30 + random.nextDouble() * 50;
        final size = 4 + random.nextDouble() * 6;
        final color = colors[index % colors.length];

        final animProgress = ((progress - 0.5) * 2).clamp(0.0, 1.0);
        final x = math.cos(angle) * radius * animProgress;
        final y = math.sin(angle) * radius * animProgress - (animProgress * 20);

        return Transform.translate(
          offset: Offset(x, y),
          child: Opacity(
            opacity: (1 - animProgress). clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: index % 2 != 0 ? BorderRadius.circular(2) : null,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: r.avatarSize,
              height: r.avatarSize,
              decoration: BoxDecoration(
                gradient: SweepGradient(
                  colors: [
                    NotificationDesign.primaryTeal,
                    NotificationDesign.primaryTeal.withOpacity(0.1),
                    NotificationDesign. primaryTeal,
                  ],
                ),
                shape: BoxShape. circle,
              ),
              child: Center(
                child: Container(
                  width: r.avatarSize - 8,
                  height: r.avatarSize - 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    size: r.iconSize(20),
                    color: NotificationDesign.primaryTeal,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: r.padding),
          Text(
            'Loading notifications.. .',
            style: GoogleFonts. inter(
              fontSize: r.bodyS,
              color: NotificationDesign. textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(EmployeeResponsiveData r) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform. scale(scale: value, child: child);
              },
              child: Container(
                padding: EdgeInsets. all(r.largePadding),
                decoration: BoxDecoration(
                  color: NotificationDesign.primaryTeal. withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons. notifications_off_outlined,
                  size: r.iconSize(56),
                  color: NotificationDesign.primaryTeal,
                ),
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'All caught up!',
              style: GoogleFonts.inter(
                fontSize: r. headingXS,
                fontWeight: FontWeight. w700,
                color: NotificationDesign. textPrimary,
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              'No notifications to show right now.\nCheck back later for updates.',
              style: GoogleFonts. inter(
                fontSize: r.bodyS,
                color: NotificationDesign. textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(ModernNotification notification) {
    // Handle different notification types
    switch (notification.type) {
      case ModernNotificationType.reportVerified:
      case ModernNotificationType.overdueAlert:
      // Navigate to reports tab
        Navigator.pop(context);
        break;
      case ModernNotificationType. achievementUnlocked:
      // Navigate to profile/achievements
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference. inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Color _getWasteTypeColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('plastic')) return NotificationDesign.info;
    if (t.contains('organic')) return NotificationDesign.success;
    if (t.contains('hazardous')) return NotificationDesign.error;
    if (t.contains('electronic')) return NotificationDesign.purple;
    if (t.contains('mixed')) return NotificationDesign.warning;
    return NotificationDesign.textSecondary;
  }
}

// ==================== DATA MODELS ====================
class ModernNotification {
  final String id;
  final ModernNotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final bool isActionable;
  final bool isUrgent;
  final Map<String, dynamic>? reportData;
  final Map<String, dynamic>? feedbackData;
  final Map<String, dynamic>? achievementData;

  ModernNotification({
    required this.id,
    required this.type,
    required this.title,
    required this. message,
    required this.timestamp,
    this.isRead = false,
    this. isActionable = false,
    this. isUrgent = false,
    this.reportData,
    this.feedbackData,
    this.achievementData,
  });
}

class _FilterOption {
  final String value;
  final String label;
  final IconData icon;

  _FilterOption(this.value, this.label, this. icon);
}