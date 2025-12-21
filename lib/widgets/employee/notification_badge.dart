import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// NotificationBadge - Ultra-responsive notification icon with count badge
/// Supports screens from 52px to ultrawide displays
class NotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  final EmployeeResponsiveData responsive;
  final Color? iconColor;
  final Color? badgeColor;
  final Color? backgroundColor;
  final bool showBackground;
  final bool mini;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.onTap,
    required this.responsive,
    this.iconColor,
    this. badgeColor,
    this.backgroundColor,
    this.showBackground = true,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine sizes based on screen width and mini mode
    final sizes = _calculateSizes();

    // For extremely small screens, show minimal version
    if (responsive.isNanoScreen) {
      return _buildNanoVersion(sizes);
    }

    // For ultra micro screens, show compact version
    if (responsive.isUltraMicroScreen) {
      return _buildUltraMicroVersion(sizes);
    }

    // For micro screens
    if (responsive. isMicroScreen) {
      return _buildMicroVersion(sizes);
    }

    // Standard version for larger screens
    return _buildStandardVersion(sizes);
  }

  _BadgeSizes _calculateSizes() {
    final width = responsive.effectiveWidth;
    final isMiniMode = mini || width < 200;

    double containerPadding;
    double iconSize;
    double badgeSize;
    double badgeFontSize;
    double borderRadius;
    double borderWidth;
    double badgeOffset;

    if (width < 60) {
      // Nano
      containerPadding = 1;
      iconSize = 10;
      badgeSize = 6;
      badgeFontSize = 4;
      borderRadius = 2;
      borderWidth = 0.5;
      badgeOffset = 0;
    } else if (width < 80) {
      // Ultra Nano
      containerPadding = 1.5;
    iconSize = 12;
    badgeSize = 7;
    badgeFontSize = 4.5;
    borderRadius = 3;
    borderWidth = 0.5;
    badgeOffset = 0;
    } else if (width < 100) {
    // Ultra Micro small
    containerPadding = 2;
    iconSize = 14;
    badgeSize = 8;
    badgeFontSize = 5;
    borderRadius = 4;
    borderWidth = 1;
    badgeOffset = -1;
    } else if (width < 120) {
    // Ultra Micro
    containerPadding = 2.5;
    iconSize = 16;
    badgeSize = 10;
    badgeFontSize = 5.5;
    borderRadius = 5;
    borderWidth = 1;
    badgeOffset = -1;
    } else if (width < 160) {
    // Micro
    containerPadding = 3;
    iconSize = 18;
    badgeSize = 12;
    badgeFontSize = 6;
    borderRadius = 6;
    borderWidth = 1;
    badgeOffset = -2;
    } else if (width < 200) {
    // Mini
    containerPadding = 4;
    iconSize = 20;
    badgeSize = 14;
    badgeFontSize = 7;
    borderRadius = 6;
    borderWidth = 1.5;
    badgeOffset = -2;
    } else if (width < 280) {
    // Tiny
    containerPadding = 5;
    iconSize = 22;
    badgeSize = 16;
    badgeFontSize = 8;
    borderRadius = 8;
    borderWidth = 1.5;
    badgeOffset = -2;
    } else if (width < 360) {
    // Very Small
    containerPadding = 6;
    iconSize = 24;
    badgeSize = 18;
    badgeFontSize = 9;
    borderRadius = 8;
    borderWidth = 2;
    badgeOffset = -3;
    } else if (width < 480) {
    // Small
    containerPadding = 7;
    iconSize = 26;
    badgeSize = 20;
    badgeFontSize = 10;
    borderRadius = 10;
    borderWidth = 2;
    badgeOffset = -3;
    } else if (width < 600) {
    // Compact
    containerPadding = 8;
    iconSize = 28;
    badgeSize = 22;
    badgeFontSize = 11;
    borderRadius = 10;
    borderWidth = 2;
    badgeOffset = -4;
    } else if (width < 840) {
    // Medium
    containerPadding = 8;
    iconSize = 28;
    badgeSize = 22;
    badgeFontSize = 11;
    borderRadius = 12;
    borderWidth = 2;
    badgeOffset = -4;
    } else {
    // Large+
    containerPadding = 10;
    iconSize = 30;
    badgeSize = 24;
    badgeFontSize = 12;
    borderRadius = 12;
    borderWidth = 2;
    badgeOffset = -4;
    }

    // Apply mini mode reduction
    if (isMiniMode && width >= 200) {
    containerPadding *= 0.75;
    iconSize *= 0.8;
    badgeSize *= 0.8;
    badgeFontSize *= 0.85;
    }

    return _BadgeSizes(
    containerPadding: containerPadding,
    iconSize: iconSize,
    badgeSize: badgeSize,
    badgeFontSize: badgeFontSize,
    borderRadius: borderRadius,
    borderWidth: borderWidth,
    badgeOffset: badgeOffset,
    );
  }

  // ==================== NANO VERSION (52-79px) ====================

  Widget _buildNanoVersion(_BadgeSizes sizes) {
    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
      behavior: HitTestBehavior. opaque,
      child: SizedBox(
        width: sizes.iconSize + (sizes.containerPadding * 2),
        height: sizes.  iconSize + (sizes.containerPadding * 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Icon only (no background for nano screens)
            Center(
              child: Icon(
                Icons.notifications_rounded,
                size: sizes.iconSize,
                color: iconColor ??  Colors.grey[700],
              ),
            ),
            // Minimal dot indicator
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: sizes.  badgeSize,
                  height: sizes. badgeSize,
                  decoration: BoxDecoration(
                    color: badgeColor ??  Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== ULTRA MICRO VERSION (80-119px) ====================

  Widget _buildUltraMicroVersion(_BadgeSizes sizes) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(sizes.containerPadding),
        decoration: showBackground
            ? BoxDecoration(
          color: backgroundColor ??  Colors.  grey. withOpacity(0.1),
          borderRadius: BorderRadius. circular(sizes.  borderRadius),
        )
            : null,
        child: SizedBox(
          width: sizes.iconSize,
          height: sizes.iconSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Icon
              Icon(
                Icons. notifications_rounded,
                size: sizes.  iconSize,
                color: iconColor ??  Colors.grey[700],
              ),
              // Badge - just a dot with optional number
              if (count > 0)
                Positioned(
                  right: sizes.badgeOffset,
                  top: sizes.badgeOffset,
                  child: Container(
                    width: sizes. badgeSize,
                    height: sizes.badgeSize,
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors. red,
                      shape: BoxShape. circle,
                      border: sizes.borderWidth > 0
                          ? Border. all(
                        color: Colors.white,
                        width: sizes.borderWidth,
                      )
                          : null,
                    ),
                    child: responsive.effectiveWidth >= 100 && count <= 9
                        ? Center(
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: sizes.badgeFontSize,
                          fontWeight: FontWeight.  bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MICRO VERSION (120-199px) ====================

  Widget _buildMicroVersion(_BadgeSizes sizes) {
    final showCount = responsive.effectiveWidth >= 140;

    return GestureDetector(
      onTap: () {
        HapticFeedback. lightImpact();
        onTap();
      },
      behavior: HitTestBehavior. opaque,
      child: Container(
        padding: EdgeInsets.all(sizes.containerPadding),
        decoration: showBackground
            ?  BoxDecoration(
          color: backgroundColor ??  Colors. grey.  withOpacity(0.1),
          borderRadius: BorderRadius.circular(sizes. borderRadius),
        )
            : null,
        child: SizedBox(
          width: sizes. iconSize + (count > 0 ?  sizes.badgeSize * 0.3 : 0),
          height: sizes.iconSize + (count > 0 ? sizes.badgeSize * 0.3 : 0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment. center,
            children: [
              // Icon
              Icon(
                Icons.notifications_rounded,
                size: sizes.iconSize,
                color: iconColor ??  Colors.grey[700],
              ),
              // Badge with count
              if (count > 0)
                Positioned(
                  right: sizes.badgeOffset,
                  top: sizes.badgeOffset,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: sizes.badgeSize,
                      minHeight: sizes.badgeSize,
                    ),
                    padding: EdgeInsets. symmetric(
                      horizontal: showCount && count > 9 ? 2 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.red,
                      borderRadius: BorderRadius. circular(sizes.badgeSize / 2),
                      border: Border.all(
                        color: Colors. white,
                        width: sizes.borderWidth,
                      ),
                    ),
                    child: Center(
                      child: showCount
                          ?  Text(
                        count > 9 ?   '9+' : count.toString(),
                        style: TextStyle(
                          fontSize: sizes.badgeFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      )
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== STANDARD VERSION (200px+) ====================

  Widget _buildStandardVersion(_BadgeSizes sizes) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(sizes.borderRadius),
        child: Container(
          padding: EdgeInsets.all(sizes.containerPadding),
          decoration: showBackground
              ? BoxDecoration(
            color: backgroundColor ?? Colors. grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(sizes.borderRadius),
          )
              : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Icon
              Icon(
                Icons. notifications_rounded,
                size: sizes. iconSize,
                color: iconColor ??  Colors.grey[700],
              ),
              // Badge with count
              if (count > 0)
                Positioned(
                  right: sizes.badgeOffset,
                  top: sizes.badgeOffset,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: sizes.badgeSize,
                      minHeight: sizes.badgeSize,
                    ),
                    padding: EdgeInsets. symmetric(
                      horizontal: count > 9 ?  sizes.badgeFontSize * 0.4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.red,
                      borderRadius: BorderRadius. circular(sizes.badgeSize / 2),
                      border: Border.all(
                        color: Colors.white,
                        width: sizes.borderWidth,
                      ),
                      boxShadow: responsive.showLightShadows
                          ? [
                        BoxShadow(
                          color: (badgeColor ?? Colors. red).  withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : count > 9 ? '9+' : count.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: sizes.  badgeFontSize,
                          fontWeight: FontWeight. bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal class to hold calculated sizes
class _BadgeSizes {
  final double containerPadding;
  final double iconSize;
  final double badgeSize;
  final double badgeFontSize;
  final double borderRadius;
  final double borderWidth;
  final double badgeOffset;

  const _BadgeSizes({
    required this.containerPadding,
    required this.iconSize,
    required this.badgeSize,
    required this.badgeFontSize,
    required this.borderRadius,
    required this.borderWidth,
    required this. badgeOffset,
  });
}

// ==================== NOTIFICATION BADGE VARIANTS ====================

/// Outlined notification badge
class NotificationBadgeOutlined extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  final EmployeeResponsiveData responsive;
  final Color?  borderColor;
  final Color? iconColor;
  final Color? badgeColor;

  const NotificationBadgeOutlined({
    super.key,
    required this.count,
    required this. onTap,
    required this.responsive,
    this.borderColor,
    this.iconColor,
    this. badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = _calculateSizes();

    return GestureDetector(
      onTap: () {
        HapticFeedback. lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(sizes. containerPadding),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor ??  Colors.grey. withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(sizes.borderRadius),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons. notifications_outlined,
              size: sizes.iconSize,
              color: iconColor ?? Colors.grey[700],
            ),
            if (count > 0)
              Positioned(
                right: sizes.badgeOffset,
                top: sizes.  badgeOffset,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: sizes.badgeSize,
                    minHeight: sizes.  badgeSize,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: count > 9 ?  2 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors. red,
                    borderRadius: BorderRadius.circular(sizes. badgeSize / 2),
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : count.toString(),
                      style: TextStyle(
                        fontSize: sizes.badgeFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _BadgeSizes _calculateSizes() {
    final width = responsive.  effectiveWidth;

    if (width < 120) {
      return const _BadgeSizes(
        containerPadding: 2,
        iconSize: 14,
        badgeSize: 8,
        badgeFontSize: 5,
        borderRadius: 4,
        borderWidth: 0.5,
        badgeOffset: -2,
      );
    } else if (width < 200) {
      return const _BadgeSizes(
        containerPadding: 4,
        iconSize: 18,
        badgeSize: 12,
        badgeFontSize: 6,
        borderRadius: 6,
        borderWidth: 1,
        badgeOffset: -3,
      );
    } else if (width < 360) {
      return const _BadgeSizes(
        containerPadding: 6,
        iconSize: 22,
        badgeSize: 16,
        badgeFontSize: 8,
        borderRadius: 8,
        borderWidth: 1.5,
        badgeOffset: -4,
      );
    } else {
      return const _BadgeSizes(
        containerPadding: 8,
        iconSize: 26,
        badgeSize: 20,
        badgeFontSize: 10,
        borderRadius: 10,
        borderWidth: 2,
        badgeOffset: -5,
      );
    }
  }
}

/// Animated notification badge with pulse effect
class NotificationBadgeAnimated extends StatefulWidget {
  final int count;
  final VoidCallback onTap;
  final EmployeeResponsiveData responsive;
  final Color?  iconColor;
  final Color? badgeColor;
  final bool animate;

  const NotificationBadgeAnimated({
    super.  key,
    required this.count,
    required this.onTap,
    required this.responsive,
    this.iconColor,
    this.badgeColor,
    this.animate = true,
  });

  @override
  State<NotificationBadgeAnimated> createState() => _NotificationBadgeAnimatedState();
}

class _NotificationBadgeAnimatedState extends State<NotificationBadgeAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate && widget.count > 0 && widget.responsive. showAnimations) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NotificationBadgeAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget. count > 0 && widget.animate && widget.responsive. showAnimations) {
      if (! _controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      _controller. stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _calculateSizes();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback. lightImpact();
          widget.onTap();
        },
        borderRadius: BorderRadius.circular(sizes.borderRadius),
        child: Container(
          padding: EdgeInsets. all(sizes.containerPadding),
          decoration: BoxDecoration(
            color: Colors.grey.  withOpacity(0.1),
            borderRadius: BorderRadius.circular(sizes. borderRadius),
          ),
          child: Stack(
            clipBehavior: Clip.  none,
            children: [
              Icon(
                Icons. notifications_rounded,
                size: sizes. iconSize,
                color: widget.iconColor ??  Colors.grey[700],
              ),
              if (widget.count > 0)
                Positioned(
                  right: sizes.badgeOffset,
                  top: sizes. badgeOffset,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: widget.animate && widget.responsive.showComplexAnimations
                            ? _scaleAnimation.value
                            : 1.0,
                        child: child,
                      );
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: sizes.badgeSize,
                        minHeight: sizes.badgeSize,
                      ),
                      padding: EdgeInsets. symmetric(
                        horizontal: widget.count > 9 ?  3 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: widget. badgeColor ??  Colors.red,
                        borderRadius: BorderRadius. circular(sizes.badgeSize / 2),
                        border: Border.  all(
                          color: Colors.  white,
                          width: sizes.borderWidth,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.badgeColor ?? Colors.red). withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.count > 99
                              ? '99+'
                              : widget.count > 9
                              ? '9+'
                              : widget.count.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: sizes. badgeFontSize,
                            fontWeight: FontWeight. bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _BadgeSizes _calculateSizes() {
    final width = widget.responsive.effectiveWidth;

    if (width < 120) {
      return const _BadgeSizes(
        containerPadding: 3,
        iconSize: 16,
        badgeSize: 10,
        badgeFontSize: 5,
        borderRadius: 5,
        borderWidth: 1,
        badgeOffset: -2,
      );
    } else if (width < 200) {
      return const _BadgeSizes(
        containerPadding: 5,
        iconSize: 20,
        badgeSize: 14,
        badgeFontSize: 7,
        borderRadius: 6,
        borderWidth: 1.5,
        badgeOffset: -3,
      );
    } else if (width < 360) {
      return const _BadgeSizes(
        containerPadding: 7,
        iconSize: 24,
        badgeSize: 18,
        badgeFontSize: 9,
        borderRadius: 8,
        borderWidth: 2,
        badgeOffset: -4,
      );
    } else {
      return const _BadgeSizes(
        containerPadding: 8,
        iconSize: 28,
        badgeSize: 22,
        badgeFontSize: 11,
        borderRadius: 10,
        borderWidth: 2,
        badgeOffset: -5,
      );
    }
  }
}

/// Simple icon-only notification indicator (for extremely small spaces)
class NotificationDot extends StatelessWidget {
  final bool hasNotifications;
  final VoidCallback?  onTap;
  final EmployeeResponsiveData responsive;
  final Color? dotColor;
  final double?  size;

  const NotificationDot({
    super.key,
    required this. hasNotifications,
    this.onTap,
    required this.responsive,
    this.dotColor,
    this. size,
  });

  @override
  Widget build(BuildContext context) {
    final dotSize = size ?? _calculateDotSize();
    final iconSize = dotSize * 2;

    return GestureDetector(
      onTap: onTap != null
          ? () {
        HapticFeedback.selectionClick();
        onTap!();
      }
          : null,
      child: SizedBox(
        width: iconSize + 4,
        height: iconSize + 4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_rounded,
              size: iconSize,
              color: Colors.grey[600],
            ),
            if (hasNotifications)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: dotColor ?? Colors.red,
                    shape: BoxShape.circle,
                    border: dotSize > 4
                        ? Border. all(color: Colors.white, width: 1)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateDotSize() {
    final width = responsive.effectiveWidth;
    if (width < 80) return 4;
    if (width < 120) return 5;
    if (width < 200) return 6;
    if (width < 320) return 7;
    return 8;
  }
}

/// Compact notification badge for app bars
class NotificationBadgeCompact extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  final EmployeeResponsiveData responsive;

  const NotificationBadgeCompact({
    super.key,
    required this.count,
    required this.onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      count: count,
      onTap: onTap,
      responsive: responsive,
      mini: true,
      showBackground: false,
    );
  }
}