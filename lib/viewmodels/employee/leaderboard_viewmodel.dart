import 'package:flutter/foundation.dart';


import '../../models/employee/leaderboard_models.dart'; // ✅ Use your existing models

/// ==================== LEADERBOARD VIEW STATE ====================
enum LeaderboardViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// ==================== LEADERBOARD VIEWMODEL ====================
class LeaderboardViewModel extends ChangeNotifier {
  // Dependencies
  final String currentUserId;
  final Future<List<LeaderboardEntry>> Function() fetchLeaderboard;

  // State
  LeaderboardViewState _viewState = LeaderboardViewState. initial;
  List<LeaderboardEntry> _allEntries = [];
  String?  _errorMessage;

  // Filters
  LeaderboardTier? _selectedTierFilter;
  String _searchQuery = '';
  bool _showOnlyCurrentUser = false;

  // Constructor
  LeaderboardViewModel({
    required this.currentUserId,
    required this.fetchLeaderboard,
  }) {
    loadLeaderboard();
  }

  // Getters - State
  LeaderboardViewState get viewState => _viewState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _viewState == LeaderboardViewState.loading;
  bool get hasError => _viewState == LeaderboardViewState.error;
  bool get isEmpty => _viewState == LeaderboardViewState.empty;
  bool get isLoaded => _viewState == LeaderboardViewState.loaded;

  // Getters - Data
  List<LeaderboardEntry> get allEntries => _allEntries;
  List<LeaderboardEntry> get topThree => _allEntries.take(3).toList();

  LeaderboardEntry? get currentUserEntry {
    try {
      return _allEntries.firstWhere(
            (e) => e.id.toString() == currentUserId,
      );
    } catch (_) {
      return _allEntries.isNotEmpty ? _allEntries. first : null;
    }
  }

  int get currentUserRank {
    final entry = currentUserEntry;
    if (entry == null) return 0;
    return _allEntries. indexOf(entry) + 1;
  }

  LeaderboardTier get currentUserTier {
    final entry = currentUserEntry;
    if (entry == null) return LeaderboardTier. unranked;
    return LeaderboardTierExtension.fromRating(entry.rating);
  }

  // Getters - Filters
  LeaderboardTier? get selectedTierFilter => _selectedTierFilter;
  String get searchQuery => _searchQuery;
  bool get showOnlyCurrentUser => _showOnlyCurrentUser;

  // Computed - Filtered Entries
  List<LeaderboardEntry> get filteredEntries {
    var filtered = _allEntries;

    // Filter by tier
    if (_selectedTierFilter != null) {
      filtered = filtered.where((e) {
        final tier = LeaderboardTierExtension. fromRating(e.rating);
        return tier == _selectedTierFilter;
      }).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) {
        return e.name. toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by current user
    if (_showOnlyCurrentUser) {
      filtered = filtered.where((e) {
        return e.id.toString() == currentUserId;
      }).toList();
    }

    return filtered;
  }

  // Computed - Tier Counts
  Map<LeaderboardTier, int> get tierCounts {
    final counts = <LeaderboardTier, int>{};
    for (final entry in _allEntries) {
      final tier = LeaderboardTierExtension.fromRating(entry. rating);
      counts[tier] = (counts[tier] ?? 0) + 1;
    }
    return counts;
  }

  // Actions
  Future<void> loadLeaderboard() async {
    _viewState = LeaderboardViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _allEntries = await fetchLeaderboard();

      if (_allEntries. isEmpty) {
        _viewState = LeaderboardViewState.empty;
      } else {
        _viewState = LeaderboardViewState.loaded;
      }
    } catch (e) {
      _viewState = LeaderboardViewState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await loadLeaderboard();
  }

  void filterByTier(LeaderboardTier? tier) {
    _selectedTierFilter = tier == _selectedTierFilter ? null : tier;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void toggleShowOnlyCurrentUser() {
    _showOnlyCurrentUser = !_showOnlyCurrentUser;
    notifyListeners();
  }

  void clearFilters() {
    _selectedTierFilter = null;
    _searchQuery = '';
    _showOnlyCurrentUser = false;
    notifyListeners();
  }

  // Helper Methods
  int getRankForEntry(LeaderboardEntry entry) {
    return _allEntries.indexOf(entry) + 1;
  }

  LeaderboardTier getTierForEntry(LeaderboardEntry entry) {
    return LeaderboardTierExtension.fromRating(entry.rating);
  }

  bool isCurrentUser(LeaderboardEntry entry) {
    return entry.id.toString() == currentUserId;
  }
}