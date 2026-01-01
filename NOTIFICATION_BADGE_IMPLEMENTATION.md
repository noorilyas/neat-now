# Notification Badge Implementation Guide

## Current "9+" Logic

### Worker Side (Already Implemented):
```dart
// In employee_dashboard.dart and notification_badge.dart
count > 9 ? '9+' : '$count'
count > 99 ? '99+' : count > 9 ? '9+' : count.toString()
```

### Logic:
- **Count ≤ 9**: Shows exact number (1, 2, 3... 9)
- **Count 10-99**: Shows "9+" 
- **Count ≥ 100**: Shows "99+"

---

## User Side Implementation (To Add)

### 1. Notification Badge Component for User Dashboard

Create: `flutter/lib/views/user/components/user_notification_badge.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/design/user/user_design_system.dart';

class UserNotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  final bool showBackground;

  const UserNotificationBadge({
    super.key,
    required this.count,
    required this.onTap,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return IconButton(
        icon: Icon(Icons.notifications_outlined, color: UserDesign.textSecondary),
        onPressed: onTap,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_rounded,
            color: UserDesign.primaryTeal,
          ),
          onPressed: onTap,
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: count > 9 ? 4 : 0,
              vertical: 2,
            ),
            constraints: BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            decoration: BoxDecoration(
              color: UserDesign.error,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: UserDesign.error.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getBadgeText(count),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getBadgeText(int count) {
    if (count > 99) return '99+';
    if (count > 9) return '9+';
    return count.toString();
  }
}
```

### 2. Add to User Dashboard

In `user_dashboard_view.dart` or `user_home_tab_view.dart`:

```dart
// Add notification provider
final notificationCount = Provider.of<NotificationProvider>(context).unreadCount;

// Add badge to app bar
UserNotificationBadge(
  count: notificationCount,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserNotificationsPage(),
      ),
    );
  },
)
```

### 3. Notification Types for User

```dart
enum UserNotificationType {
  reportAssigned,      // "Your report #123 assigned to Worker Name"
  reportResolved,      // "Your report #123 has been resolved"
  ratingReminder,      // "Rate Worker Name for report #123"
  workerAccepted,      // "Worker Name accepted your report"
}
```

### 4. Notification Provider for User

Create: `flutter/lib/providers/user_notification_provider.dart`

```dart
class UserNotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  List<UserNotification> _notifications = [];

  int get unreadCount => _unreadCount;
  List<UserNotification> get notifications => _notifications;

  Future<void> loadNotifications() async {
    // Fetch from API: GET /api/notifications/
    // Update _notifications and _unreadCount
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    // PATCH /api/notifications/{id}/read/
    _unreadCount--;
    notifyListeners();
  }
}
```

---

## Badge Display Logic Options

### Option 1: Current (9+)
```dart
count > 9 ? '9+' : count.toString()
```
**Pros**: Simple, compact  
**Cons**: Doesn't show exact count after 9

### Option 2: Higher Threshold (99+)
```dart
count > 99 ? '99+' : count.toString()
```
**Pros**: Shows more exact counts  
**Cons**: Badge might get wider

### Option 3: Smart Display
```dart
String getBadgeText(int count) {
  if (count > 999) return '999+';
  if (count > 99) return '99+';
  if (count > 9) return '9+';
  return count.toString();
}
```

### Option 4: Always Show Exact (No Limit)
```dart
count.toString()  // Shows: 1, 2, 3... 99, 100, 101...
```
**Pros**: Always accurate  
**Cons**: Badge can get very wide for large numbers

---

## Recommended Implementation

### For User Dashboard:
```dart
// Use 9+ threshold (same as worker)
count > 9 ? '9+' : count.toString()
```

### For Notification Icon in App Bar:
```dart
// Compact version
count > 99 ? '99+' : count > 9 ? '9+' : count.toString()
```

### Badge Styling:
- **Small screens**: Use "9+" threshold
- **Large screens**: Can show up to "99+"
- **Color**: Red for unread, Teal for read
- **Animation**: Pulse effect when new notification arrives

---

## Integration with Report Assignment

### When Report Gets Assigned:
```dart
// In notification service
void notifyReportAssigned(int reportId, String workerName) {
  // Create notification
  Notification notification = Notification(
    user: citizen,
    report: report,
    type: 'report_assigned',
    title: 'Report Assigned',
    message: 'Your report #$reportId assigned to $workerName',
  );
  
  // Update badge count
  notificationProvider.incrementUnreadCount();
  
  // Show in-app notification
  showNotificationBanner(notification);
}
```

---

## UI/UX Suggestions

### 1. Badge Position
- Top-right corner of notification icon
- Slightly offset for better visibility

### 2. Badge Colors
- **Unread**: Red (#FF6B6B)
- **Read**: Gray (#9CA3AF)
- **Important**: Orange (#FF9800)

### 3. Badge Animation
- Pulse when new notification arrives
- Scale animation on tap
- Slide in from top

### 4. Badge Size
- **Small**: 18x18px (for icons)
- **Medium**: 24x24px (for buttons)
- **Large**: 32x32px (for cards)

---

## Testing Scenarios

1. **Count = 0**: No badge shown
2. **Count = 1-9**: Shows exact number
3. **Count = 10**: Shows "9+"
4. **Count = 99**: Shows "9+"
5. **Count = 100**: Shows "99+" (if using higher threshold)

---

## Next Steps

1. ✅ Create `UserNotificationBadge` component
2. ✅ Add to user dashboard app bar
3. ✅ Implement notification provider
4. ✅ Connect with report assignment API
5. ✅ Add notification page for user
6. ✅ Test badge display with different counts



