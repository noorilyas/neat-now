import 'package:flutter/cupertino.dart';

import '../models/leaderboard_entry.dart';

class LeaderboardService extends ChangeNotifier {
  final List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  List<LeaderboardEntry> get leaderboard => List.unmodifiable(_leaderboard);
  List<LeaderboardEntry> get topThree =>
      _leaderboard.length >= 3 ? _leaderboard.sublist(0, 3) : _leaderboard;
  List<LeaderboardEntry> get restOfLeaderboard =>
      _leaderboard.length > 3 ? _leaderboard.sublist(3) : [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  LeaderboardService() {
    _loadMockLeaderboard();
  }

  void _loadMockLeaderboard() {
    _leaderboard.addAll([
      LeaderboardEntry(
        rank: 1,
        name: 'Ahmed Khan',
        points: 1200,
        reports: 45,
        avatar: '👨',
      ),
      LeaderboardEntry(
        rank: 2,
        name: 'Sara Ali',
        points: 980,
        reports: 38,
        avatar: '👩',
      ),
      LeaderboardEntry(
        rank: 3,
        name: 'You',
        points: 850,
        reports: 24,
        avatar: '🙋',
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        rank: 4,
        name: 'Hassan R',
        points: 720,
        reports: 29,
        avatar: '👨',
      ),
      LeaderboardEntry(
        rank: 5,
        name: 'Fatima N',
        points: 650,
        reports: 22,
        avatar: '👩',
      ),
      LeaderboardEntry(
        rank: 6,
        name: 'Ali H',
        points: 590,
        reports: 20,
        avatar: '👨',
      ),
      LeaderboardEntry(
        rank: 7,
        name: 'Ayesha K',
        points: 540,
        reports: 18,
        avatar: '👩',
      ),
    ]);
  }

  // Fetch leaderboard from API
  Future<void> fetchLeaderboard({String? period = 'monthly'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      // In production: _leaderboard = await getLeaderboardFromAPI(period);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch leaderboard: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current user position
  LeaderboardEntry? getCurrentUserEntry() {
    try {
      return _leaderboard.firstWhere((entry) => entry.isCurrentUser);
    } catch (e) {
      return null;
    }
  }

  // API call example
  Future<List<LeaderboardEntry>> getLeaderboardFromAPI(String period) async {
    // TODO: Implement actual API call
    throw UnimplementedError('API integration pending');
  }
}
