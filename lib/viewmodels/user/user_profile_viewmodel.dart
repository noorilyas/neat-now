import 'package:flutter/material.dart';
import 'package:neat_now/models/user/user_model.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/views/user/user_notifications_page.dart';

class UserProfileViewModel extends ChangeNotifier {
  final UserModel user;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdate;

  bool _isEditMode = false;
  bool _showLogoutConfirm = false;

  // Store BuildContext for navigation (set by the view)
  BuildContext? _context;

  UserProfileViewModel({
    required this.user,
    required this.onLogout,
    required this.onProfileUpdate,
  });

  // Set context from view
  void setContext(BuildContext context) {
    _context = context;
  }

  // Getters
  bool get isEditMode => _isEditMode;
  bool get showLogoutConfirm => _showLogoutConfirm;

  // User data getters
  String get name => user.name;
  String get email => user.email;
  String get phone => user.phone;
  String?  get profileImage => user.profileImage;
  int get totalReports => user.totalReports;
  int get verifiedReports => user.verifiedReports;
  int get pendingReports => user.pendingReports;
  int get rank => user.rank;
  int get points => user.points;
  String?  get badge => user.badge;
  String get memberSince => user.memberSince;

  // Computed properties
  String get avatarInitial => name.isNotEmpty ? name[0]. toUpperCase() : '? ';
  bool get isTopThree => rank > 0 && rank <= 3;

  // Points growth (mock calculation)
  int get weeklyPointsGrowth => (points * 0.12).round();

  // Activity stats (mock data - replace with real API)
  int get reportsThisMonth => (totalReports * 0.3).round();
  int get verificationRate => totalReports > 0
      ? ((verifiedReports / totalReports) * 100).round()
      : 0;
  String get averageResponseTime => '2.5 hrs';

  // Navigation methods
  void navigateToNotifications() {
    if (_context != null) {
      Navigator.push(
        _context!,
        MaterialPageRoute(
          builder: (context) => const UserNotificationsPage(),
        ),
      );
    }
  }

  void navigateToPrivacy() {
    // TODO: Implement privacy page navigation
    _showComingSoon('Privacy & Security');
  }

  void navigateToLanguage() {
    // TODO: Implement language page navigation
    _showComingSoon('Language Settings');
  }

  void navigateToHelp() {
    // TODO: Implement help page navigation
    _showComingSoon('Help & Support');
  }

  void navigateToAbout() {
    // TODO: Implement about page navigation
    _showComingSoon('About NeatNow');
  }

  void _showComingSoon(String feature) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(
            '$feature coming soon!  🚧',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: UserDesign.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // Profile colors based on rank
  ProfileColors getProfileColors() {
    if (rank == 1) {
      return ProfileColors(
        primary: UserDesign.platinum,
        secondary: const Color(0xFFE8E8E8),
        glowColors: [UserDesign.platinum, const Color(0xFFE8E8E8)],
      );
    } else if (rank == 2) {
      return ProfileColors(
        primary:  const Color(0xFFFFD700),
        secondary: const Color(0xFFFFA500),
        glowColors: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
      );
    } else if (rank == 3) {
      return ProfileColors(
        primary:  UserDesign.silver,
        secondary: const Color(0xFFB8B8B8),
        glowColors: [UserDesign.silver, const Color(0xFFB8B8B8)],
      );
    }
    return ProfileColors(
      primary: UserDesign.primaryTeal,
      secondary: UserDesign.primaryTealLight,
      glowColors: [UserDesign.primaryTeal, UserDesign.primaryTealLight],
    );
  }

  // Rank badge data
  RankBadgeData getRankBadgeData() {
    if (rank == 1) {
      return RankBadgeData(
        color: UserDesign.platinum,
        icon: Icons.diamond_rounded,
        title: 'Platinum',
        label: 'Top Reporter',
        description: 'You\'re the #1 reporter!  Keep leading the way.',
      );
    } else if (rank == 2) {
      return RankBadgeData(
        color: const Color(0xFFFFD700),
        icon: Icons.workspace_premium_rounded,
        title: 'Gold',
        label: 'Elite Reporter',
        description: 'Just one step away from the top! Keep pushing.',
      );
    } else if (rank == 3) {
      return RankBadgeData(
        color: UserDesign.silver,
        icon: Icons.military_tech_rounded,
        title: 'Silver',
        label: 'Pro Reporter',
        description: 'You\'re in the Top 3! Amazing achievement.',
      );
    } else if (rank > 0) {
      return RankBadgeData(
        color:  UserDesign.primaryTeal,
        icon: Icons.stars_rounded,
        title: 'Rank #$rank',
        label: 'Active Reporter',
        description: 'Keep reporting to climb the ranks!',
      );
    }
    return RankBadgeData(
      color:  UserDesign.primaryTeal,
      icon: Icons.stars_rounded,
      title: 'New Reporter',
      label: 'Getting Started',
      description: 'Start reporting to earn your rank!',
    );
  }

  // Rank indicator icon
  IconData getRankIndicatorIcon() {
    if (rank == 1) return Icons.diamond_rounded;
    if (rank == 2) return Icons.workspace_premium_rounded;
    return Icons.military_tech_rounded;
  }

  // Activity items
  List<ActivityItem> getActivityItems() {
    return [
      ActivityItem(
        label: 'Reports This Month',
        value: '$reportsThisMonth',
        icon: Icons.calendar_month_rounded,
        color: UserDesign.info,
      ),
      ActivityItem(
        label: 'Verification Rate',
        value: '$verificationRate%',
        icon: Icons.verified_rounded,
        color: UserDesign.success,
      ),
      ActivityItem(
        label: 'Average Response Time',
        value: averageResponseTime,
        icon:  Icons.timer_rounded,
        color: UserDesign.warning,
      ),
    ];
  }

  // Settings menu items
  List<SettingsMenuItem> getSettingsMenuItems(BuildContext context) {
    return [
      SettingsMenuItem(
        icon: Icons.person_rounded,
        title: 'Edit Profile',
        subtitle: 'Update your personal information',
        color: UserDesign.primaryTeal,
        onTap: openEditMode,
      ),
      SettingsMenuItem(
        icon: Icons.notifications_rounded,
        title: 'Notifications',
        subtitle:  'Manage notification preferences',
        color: UserDesign.warning,
        onTap: navigateToNotifications,
      ),
      SettingsMenuItem(
        icon: Icons.lock_rounded,
        title: 'Privacy & Security',
        subtitle: 'Password and security settings',
        color: UserDesign.purple,
        onTap: navigateToPrivacy,
      ),
      SettingsMenuItem(
        icon: Icons.language_rounded,
        title: 'Language',
        subtitle: 'English (US)',
        color: UserDesign.info,
        onTap: navigateToLanguage,
        showValue: true,
      ),
    ];
  }

  List<SettingsMenuItem> getHelpMenuItems(BuildContext context) {
    return [
      SettingsMenuItem(
        icon: Icons.help_outline_rounded,
        title:  'Help & Support',
        subtitle: 'Get help or contact us',
        color: UserDesign.success,
        onTap: navigateToHelp,
      ),
      SettingsMenuItem(
        icon: Icons.info_outline_rounded,
        title: 'About NeatNow',
        subtitle: 'Version 1.0.0',
        color: UserDesign.info,
        onTap: navigateToAbout,
      ),
    ];
  }

  // State management
  void openEditMode() {
    _isEditMode = true;
    notifyListeners();
  }

  void closeEditMode() {
    _isEditMode = false;
    notifyListeners();
  }

  void showLogoutConfirmation() {
    _showLogoutConfirm = true;
    notifyListeners();
  }

  void hideLogoutConfirmation() {
    _showLogoutConfirm = false;
    notifyListeners();
  }

  void confirmLogout() {
    _showLogoutConfirm = false;
    onLogout();
  }

  void handleProfileUpdate(Map<String, dynamic> data) {
    closeEditMode();
    onProfileUpdate();
  }
}

// Helper classes
class ProfileColors {
  final Color primary;
  final Color secondary;
  final List<Color> glowColors;

  ProfileColors({
    required this.primary,
    required this.secondary,
    required this.glowColors,
  });
}

class RankBadgeData {
  final Color color;
  final IconData icon;
  final String title;
  final String label;
  final String description;

  RankBadgeData({
    required this. color,
    required this.icon,
    required this.title,
    required this.label,
    required this.description,
  });
}

class ActivityItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  ActivityItem({
    required this.label,
    required this.value,
    required this.icon,
    required this. color,
  });
}

class SettingsMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showValue;

  SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this. onTap,
    this. showValue = false,
  });
}