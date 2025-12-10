import 'package:flutter/cupertino.dart';

import '../models/achievement.dart';
import '../models/user_stats.dart';

class AchievementService extends ChangeNotifier {
  final List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.unlocked).toList();
  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.unlocked).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  AchievementService() {
    _loadMockAchievements();
  }

  void _loadMockAchievements() {
    _achievements.addAll([
      Achievement(
        icon: '🏆',
        title: 'First',
        fullTitle: 'First Report',
        unlocked: true,
        description: 'Submit your first waste report',
      ),
      Achievement(
        icon: '⭐',
        title: '10x',
        fullTitle: '10 Reports',
        unlocked: true,
        description: 'Submit 10 waste reports',
        requiredCount: 10,
      ),
      Achievement(
        icon: '🎯',
        title: '7d',
        fullTitle: '7 Day Streak',
        unlocked: true,
        description: 'Maintain a 7-day reporting streak',
        requiredCount: 7,
      ),
      Achievement(
        icon: '💎',
        title: 'Top5',
        fullTitle: 'Top 5 This Month',
        unlocked: true,
        description: 'Rank in top 5 contributors',
      ),
      Achievement(
        icon: '🔥',
        title: '50x',
        fullTitle: '50 Reports',
        unlocked: false,
        description: 'Submit 50 waste reports',
        requiredCount: 50,
      ),
      Achievement(
        icon: '👑',
        title: 'Lead',
        fullTitle: 'Monthly Leader',
        unlocked: false,
        description: 'Become the top contributor for a month',
      ),
    ]);
  }

  // Fetch achievements from API
  Future<void> fetchAchievements(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch achievements: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check and unlock achievements
  Future<List<Achievement>> checkAndUnlockAchievements(UserStats stats) async {
    final newlyUnlocked = <Achievement>[];

    for (var i = 0; i < _achievements.length; i++) {
      if (!_achievements[i].unlocked) {
        bool shouldUnlock = false;

        // Check conditions for unlocking
        if (_achievements[i].fullTitle.contains('10 Reports') &&
            stats.totalReports >= 10) {
          shouldUnlock = true;
        } else if (_achievements[i].fullTitle.contains('50 Reports') &&
            stats.totalReports >= 50) {
          shouldUnlock = true;
        } else if (_achievements[i].fullTitle.contains('7 Day Streak') &&
            stats.streak >= 7) {
          shouldUnlock = true;
        }

        if (shouldUnlock) {
          _achievements[i] = _achievements[i].copyWith(unlocked: true);
          newlyUnlocked.add(_achievements[i]);
        }
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      notifyListeners();
    }

    return newlyUnlocked;
  }
}