import 'package:flutter/material.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';

class ReportsTabViewModel extends ChangeNotifier {
  ReportsState _state = const ReportsState();

  ReportsState get state => _state;
  String get selectedFilter => _state.selectedFilter;
  String get searchQuery => _state.searchQuery;
  bool get isSearchExpanded => _state.isSearchExpanded;
  int? get hoveredCardIndex => _state. hoveredCardIndex;

  // Filters
  List<FilterOption> get filterOptions => FilterOption.defaults;

  // Filter and Search
  List<Report> filterReports(List<Report> reports) {
    var filtered = reports;

    if (_state.selectedFilter != 'all') {
      filtered = filtered.where((r) => r.status == _state.selectedFilter).toList();
    }

    if (_state. searchQuery.isNotEmpty) {
      final query = _state.searchQuery. toLowerCase();
      filtered = filtered. where((r) =>
      r.type.toLowerCase().contains(query) ||
          r.location.toLowerCase().contains(query) ||
          r.userName.toLowerCase().contains(query) ||
          r.id.toString().contains(query)).toList();
    }

    filtered. sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  int getFilterCount(List<Report> reports, String filter) {
    if (filter == 'all') return reports.length;
    return reports.where((r) => r.status == filter).length;
  }

  // Create Report Card Data
  ReportCardData getReportCardData(Report report) {
    return ReportCardData(
      report: report,
      statusColor: getStatusColor(report.status),
      hasLocation: report.latitude != null &&
          report.longitude != null &&
          report.latitude != 0.0 &&
          report.longitude != 0.0,
      timeAgo: formatTimeAgo(report.date),
      isRecent: DateTime.now().difference(report.date).inHours < 2,
    );
  }

  // Timeline Events
  List<TimelineEvent> getTimelineEvents(Report report) {
    return [
      TimelineEvent(
        title: 'Reported',
        date: report.date,
        icon: Icons.flag_rounded,
        color: ReportsDesign.warning,
        isCompleted: true,
      ),
      TimelineEvent(
        title: 'Assigned',
        date: report.assignedAt ??  report.date,
        icon: Icons.assignment_ind_rounded,
        color: ReportsDesign.info,
        isCompleted: true,
      ),
      if (report.status == 'in-progress')
        TimelineEvent(
          title: 'In Progress',
          date: DateTime.now(),
          icon: Icons.sync_rounded,
          color: ReportsDesign.info,
          isCompleted: true,
        ),
      if (report.status == 'resolved' && report.resolvedAt != null)
        TimelineEvent(
          title: 'Completed',
          date: report.resolvedAt!,
          icon:  Icons.check_circle_rounded,
          color: ReportsDesign.success,
          isCompleted: true,
        ),
      if (report.status != 'resolved')
        TimelineEvent(
          title: 'Pending Completion',
          date: DateTime.now(),
          icon: Icons.pending_rounded,
          color: ReportsDesign.textTertiary,
          isCompleted: false,
        ),
    ];
  }

  // State Mutations
  void setSelectedFilter(String filter) {
    _state = _state.copyWith(selectedFilter: filter);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void toggleSearchExpanded() {
    _state = _state.copyWith(isSearchExpanded: !_state.isSearchExpanded);
    notifyListeners();
  }

  void setSearchExpanded(bool value) {
    _state = _state.copyWith(isSearchExpanded: value);
    notifyListeners();
  }

  void setHoveredCard(int?  index) {
    _state = _state.copyWith(
      hoveredCardIndex: index,
      clearHoveredCard: index == null,
    );
    notifyListeners();
  }

  void clearSearch() {
    _state = _state.copyWith(searchQuery: '', isSearchExpanded: false);
    notifyListeners();
  }

  void clearFilters() {
    _state = _state.copyWith(
      searchQuery: '',
      selectedFilter:  'all',
      isSearchExpanded: false,
    );
    notifyListeners();
  }

  // Helpers
  Color getStatusColor(String status) {
    switch (status. toLowerCase()) {
      case 'resolved':
        return ReportsDesign.success;
      case 'in-progress':
        return ReportsDesign.info;
      case 'pending':
        return ReportsDesign.warning;
      default:
        return ReportsDesign.textTertiary;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'Completed';
      case 'in-progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'in-progress':
        return Icons.sync_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  IconData getWasteIcon(String type) {
    final t = type.toLowerCase();
    if (t. contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('hazardous')) return Icons.warning_amber_rounded;
    if (t.contains('glass')) return Icons.wine_bar_rounded;
    if (t.contains('paper')) return Icons.description_rounded;
    if (t.contains('metal')) return Icons.recycling_rounded;
    if (t.contains('medical')) return Icons.medical_services_rounded;
    if (t.contains('construction')) return Icons.construction_rounded;
    return Icons.delete_rounded;
  }

  String formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour. toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String formatTimestamp(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}