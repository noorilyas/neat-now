import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

/// ==================== NOTIFICATION OVERLAY ====================
/// Shows toast-style notifications with animations
class NotificationOverlay extends StatefulWidget {
  final Widget child;
  final EmployeeResponsiveData responsive;

  const NotificationOverlay({
    super.key,
    required this.child,
    required this.responsive,
  });

  static NotificationOverlayState?  of(BuildContext context) {
    return context.findAncestorStateOfType<NotificationOverlayState>();
  }

  @override
  State<NotificationOverlay> createState() => NotificationOverlayState();
}

class NotificationOverlayState extends State<NotificationOverlay>
    with TickerProviderStateMixin {

  final List<_ToastNotification> _notifications = [];

  void showNotification({
    required String title,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    HapticFeedback. lightImpact();

    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    final notification = _ToastNotification(
      id: DateTime.now(). millisecondsSinceEpoch. toString(),
      title: title,
      message: message,
      type: type,
      controller: controller,
      onTap: onTap,
      actionLabel: actionLabel,
      onAction: onAction,
    );

    setState(() {
      _notifications.add(notification);
    });

    controller. forward();

    // Auto dismiss
    Future.delayed(duration, () {
      _dismissNotification(notification);
    });
  }

  void _dismissNotification(_ToastNotification notification) {
    if (! mounted) return;

    notification.controller.reverse(). then((_) {
      if (mounted) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        notification.controller.dispose();
      }
    });
  }

  @override
  void dispose() {
    for (var notification in _notifications) {
      notification. controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Stack(
      children: [
        widget.child,

        // Notification stack
        Positioned(
          top: r.safePaddingTop + r.padding,
          left: r.padding,
          right: r.padding,
          child: Column(
            children: _notifications.map((notification) {
              return _buildToastCard(r, notification);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildToastCard(EmployeeResponsiveData r, _ToastNotification notification) {
    final config = _getTypeConfig(notification.type);

    return AnimatedBuilder(
      animation: notification.controller,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: notification. controller,
          curve: Curves.easeOutBack,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: notification. controller,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key(notification. id),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => _dismissNotification(notification),
        child: Container(
            margin: EdgeInsets.only(bottom: r.microPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(r. largeBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: config.color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: config. color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      notification.onTap?.call();
                      _dismissNotification(notification);
                    },
                    borderRadius: BorderRadius. circular(r.largeBorderRadius),
                    child: Padding(
                      padding: EdgeInsets. all(r.padding),
                      child: Row(
                          children: [
                      // Icon
                      Container(
                      padding: EdgeInsets. all(r.microPadding),
                      decoration: BoxDecoration(
                        color: config. color. withOpacity(0.1),
                        borderRadius: BorderRadius. circular(r.borderRadius),
                      ),
                      child: Icon(
                        config.icon,
                        size: r.iconSize(22),
                        color: config.color,
                      ),
                    ),
                    SizedBox(width: r.microPadding),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: r.bodyS,
                              fontWeight: FontWeight. w700,
                              color: const Color(0xFF1A1D21),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow. ellipsis,
                          ),
                          SizedBox(height: r.atomicPadding),
                          Text(
                            notification. message,
                            style: GoogleFonts.inter(
                              fontSize: r.captionM,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Action button or close
                    if (notification.actionLabel != null) ...[
                SizedBox(width: r.microPadding),
            TextButton(
              onPressed: () {
                notification.onAction?.call();
                _dismissNotification(notification);
              },
              style: TextButton.styleFrom(
                foregroundColor: config. color,
                padding: EdgeInsets. symmetric(
                  horizontal: r.microPadding,
                  vertical: r.nanoPadding,
                ),
              ),
              child: Text(
                notification.actionLabel! ,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight. w600,
                ),
              ),
            ),
            ] else ...[
        SizedBox(width: r.nanoPadding),
        IconButton(
          onPressed: () => _dismissNotification(notification),
          icon: Icon(
            Icons.close_rounded,
            size: r.iconSize(18),
            color: const Color(0xFF9CA3AF),
          ),
          padding: EdgeInsets. zero,
          constraints: BoxConstraints(
            minWidth: r.dimension(32),
            minHeight: r.dimension(32),
          ),
        ),
        ],
        ],
      ),
    ),
    ),
    ),
    ),
    ),
    );
  }

  _ToastConfig _getTypeConfig(ToastType type) {
    switch (type) {
    case ToastType. success:
    return _ToastConfig(
    color: const Color(0xFF10B981),
    icon: Icons.check_circle_rounded,
    );
    case ToastType.error:
    return _ToastConfig(
    color: const Color(0xFFEF4444),
    icon: Icons.error_rounded,
    );
    case ToastType.warning:
    return _ToastConfig(
    color: const Color(0xFFF59E0B),
    icon: Icons.warning_rounded,
    );
    case ToastType.info:

      case ToastType. assignment:
        return _ToastConfig(
          color: const Color(0xFF3B82F6),
          icon: Icons.assignment_rounded,
        );
      case ToastType. achievement:
        return _ToastConfig(
          color: const Color(0xFFF59E0B),
          icon: Icons.emoji_events_rounded,
        );
    default:
    return _ToastConfig(
    color: const Color(0xFF2AC2AB),
    icon: Icons.info_rounded,
    );

    }
  }
}

enum ToastType {
  success,
  error,
  warning,
  info,
  assignment,
  achievement,
}

class _ToastNotification {
  final String id;
  final String title;
  final String message;
  final ToastType type;
  final AnimationController controller;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  _ToastNotification({
    required this.id,
    required this. title,
    required this.message,
    required this.type,
    required this.controller,
    this.onTap,
    this. actionLabel,
    this.onAction,
  });
}

class _ToastConfig {
  final Color color;
  final IconData icon;

  _ToastConfig({
    required this. color,
    required this.icon,
  });
}