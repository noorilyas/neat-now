import 'package:flutter/material.dart';
import 'package:neat_now/models/user/user_model.dart';
import 'package:neat_now/models/user/nav_item_model.dart';
import 'package:neat_now/design/user/user_design_system.dart';

class UserDashboardViewModel extends ChangeNotifier {
  UserModel _user;
  int _currentIndex = 0;
  int _previousIndex = 0;
  final VoidCallback _onLogout;

  UserDashboardViewModel({
    Map<String, dynamic>? userData,
    required VoidCallback onLogout,
  })  : _user = userData != null
      ? UserModel.fromMap(userData)
      : UserModel.defaultUser,
        _onLogout = onLogout;

  // Getters
  UserModel get user => _user;
  Map<String, dynamic> get userMap => _user.toMap();
  int get currentIndex => _currentIndex;
  int get previousIndex => _previousIndex;

  // Navigation items
  List<NavItemModel> get navItems => [
    const NavItemModel(
      label:  'Home',
      activeIcon: Icons.home_rounded,
      icon: Icons.home_outlined,
      color: UserDesign.primaryTeal,
    ),
    const NavItemModel(
      label: 'Reports',
      activeIcon: Icons.assignment_rounded,
      icon: Icons.assignment_outlined,
      color: UserDesign.info,
    ),
    const NavItemModel(
      label: 'Add',
      activeIcon: Icons.add_rounded,
      icon: Icons.add_rounded,
      color: UserDesign.primaryTeal,
      isFab: true,
    ),
    const NavItemModel(
      label: 'Ranks',
      activeIcon: Icons. leaderboard_rounded,
      icon: Icons.leaderboard_outlined,
      color: UserDesign.warning,
    ),
    const NavItemModel(
      label: 'Profile',
      activeIcon:  Icons.person_rounded,
      icon: Icons.person_outlined,
      color: UserDesign.purple,
    ),
  ];

  // Check if index is FAB
  bool isFabIndex(int index) => index == 2;

  // Check if current index is selected
  bool isSelected(int index) => _currentIndex == index;

  // Navigation logic
  void onNavTap(int index) {
    if (index == 2) {
      // FAB - handled by view (opens report page)
      return;
    }

    if (index == _currentIndex) return;

    _previousIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();
  }

  // Get page index (accounting for FAB placeholder)
  int getPageIndex(int navIndex) {
    return navIndex > 2 ? navIndex - 1 : navIndex;
  }

  // Update user data
  void updateUserData(Map<String, dynamic> userData) {
    _user = UserModel.fromMap(userData);
    notifyListeners();
  }

  // Update user model directly
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  // Logout
  void logout() {
    _onLogout();
  }

  // Handle profile update
  void onProfileUpdate() {
    notifyListeners();
  }

  // Navigate to specific tab
  void navigateToTab(int index) {
    if (index >= 0 && index < navItems.length && index != 2) {
      onNavTap(index);
    }
  }

  // Navigate to reports
  void navigateToReports() => navigateToTab(1);

  // Navigate to leaderboard
  void navigateToLeaderboard() => navigateToTab(3);

  // Handle report submission success
  void onReportSuccess() {
    // Update user stats if needed
    _user = _user.copyWith(
      totalReports: _user.totalReports + 1,
      pendingReports: _user.pendingReports + 1,
    );
    notifyListeners();
  }
}