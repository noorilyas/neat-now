import 'package:flutter/material.dart';
import 'package:neat_now/models/user/user_report_model.dart';
import 'package:neat_now/models/user/filter_option_model.dart';
import 'package:neat_now/models/user/timeline_step_model.dart';
import 'package:neat_now/design/user/user_design_system.dart';

class UserReportsViewModel extends ChangeNotifier {
  final VoidCallback onReportWaste;

  String _selectedFilter = 'all';
  List<UserReportModel> _reports = [];

  UserReportsViewModel({
    required this.onReportWaste,
  }) {
    _loadReports();
  }

  // Getters
  String get selectedFilter => _selectedFilter;
  List<UserReportModel> get reports => _reports;
  int get totalReportsCount => _reports.length;

  // Filtered reports
  List<UserReportModel> get filteredReports {
    if (_selectedFilter == 'all') return _reports;
    return _reports.where((r) => r.status == _selectedFilter).toList();
  }

  // Filter options
  List<FilterOptionModel> get filterOptions => [
    const FilterOptionModel(
      value:  'all',
      label:  'All',
      icon:  Icons.all_inbox_rounded,
      color: UserDesign.textSecondary,
    ),
    const FilterOptionModel(
      value: 'pending',
      label: 'Pending',
      icon: Icons. schedule_rounded,
      color: UserDesign.warning,
    ),
    const FilterOptionModel(
      value: 'assigned',
      label: 'Assigned',
      icon: Icons. person_add_rounded,
      color: UserDesign.info,
    ),
    const FilterOptionModel(
      value: 'resolved',
      label: 'Resolved',
      icon: Icons.check_circle_rounded,
      color: UserDesign.success,
    ),
  ];

  // Get count for filter
  int getFilterCount(String filter) {
    if (filter == 'all') return _reports.length;
    return _reports.where((r) => r.status == filter).length;
  }

  // Change filter
  void selectFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Status helpers
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return UserDesign.warning;
      case 'assigned':
        return UserDesign.info;
      case 'resolved':
        return UserDesign.success;
      default:
        return UserDesign.textTertiary;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  // Waste type icon
  IconData getWasteIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('glass')) return Icons.wine_bar_rounded;
    if (t.contains('paper')) return Icons.description_rounded;
    if (t.contains('construction')) return Icons.construction_rounded;
    if (t.contains('metal')) return Icons.recycling_rounded;
    return Icons.delete_rounded;
  }

  // Date formatting
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year} at ${date.hour. toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }

  // Timeline steps for a report
  List<TimelineStepModel> getTimelineSteps(UserReportModel report) {
    return [
      TimelineStepModel(
        label: 'Uploaded',
        timestamp: report.submittedAt,
        isCompleted: true,
        icon: Icons.cloud_upload_rounded,
      ),
      TimelineStepModel(
        label: 'Pending',
        timestamp: report.submittedAt,
        isCompleted: report.status != 'uploaded',
        icon: Icons.schedule_rounded,
      ),
      TimelineStepModel(
        label: 'Assigned',
        timestamp: report.hasWorker ? report.submittedAt : null,
        isCompleted: report.status == 'assigned' || report.status == 'resolved',
        icon: Icons.person_add_rounded,
      ),
      TimelineStepModel(
        label: 'Resolved',
        timestamp: report.resolvedAt,
        isCompleted: report.status == 'resolved',
        icon: Icons.check_circle_rounded,
      ),
    ];
  }

  // Update report rating
  void updateReportRating(String reportId, int rating, String feedback) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _reports[index] = _reports[index].copyWith(
        rating: rating,
        feedback: feedback,
      );
      notifyListeners();
    }
  }

  // Load reports (mock data - replace with API call)
  void _loadReports() {
    _reports = [
      UserReportModel(
        id: '1',
        type: 'Plastic Waste',
        location: 'Main Street Park, Block A',
        status: 'pending',
        beforeImageUrl: 'https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400',
        description: 'Large pile of plastic bottles near the park bench.  Needs immediate attention.',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        latitude: 31.7167,
        longitude: 73.9850,
      ),
      UserReportModel(
        id: '2',
        type: 'Organic Waste',
        location: 'Central Avenue, Near Metro Station',
        status: 'assigned',
        beforeImageUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400',
        description: 'Food waste dumped on the sidewalk causing bad smell.',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        workerName: 'Ahmed Khan',
        workerPhone: '+92 300 1234567',
        latitude: 31.7200,
        longitude: 73.9900,
      ),
      UserReportModel(
        id: '3',
        type: 'Mixed Waste',
        location: 'Riverside Garden, East Wing',
        status: 'resolved',
        beforeImageUrl: 'https://images.unsplash.com/photo-1605600659908-0ef719419d41?w=400',
        description: 'Various trash items scattered around the garden area.',
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
        workerName: 'Ali Hassan',
        workerPhone: '+92 301 9876543',
        afterImageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        resolvedAt: DateTime.now().subtract(const Duration(days: 2)),
        cleanupDuration: const Duration(minutes: 45),
        latitude: 31.7100,
        longitude: 73.9800,
      ),
      UserReportModel(
        id: '4',
        type:  'Electronic Waste',
        location: 'Tech Park, Building C',
        status: 'resolved',
        beforeImageUrl: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=400',
        description: 'Old computer parts and cables dumped near the parking.',
        submittedAt: DateTime.now().subtract(const Duration(days: 5)),
        workerName: 'Omar Ali',
        workerPhone: '+92 302 5555555',
        afterImageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        resolvedAt: DateTime.now().subtract(const Duration(days: 4)),
        cleanupDuration:  const Duration(hours: 1, minutes: 15),
        latitude: 31.7050,
        longitude: 73.9750,
        rating: 5,
        feedback: 'Excellent work! Very thorough cleanup.',
      ),
      UserReportModel(
        id: '5',
        type:  'Construction Debris',
        location: 'New Housing Society, Plot 45',
        status: 'resolved',
        beforeImageUrl: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
        description: 'Bricks and concrete waste left after construction.',
        submittedAt: DateTime.now().subtract(const Duration(days: 7)),
        workerName: 'Bilal Ahmed',
        workerPhone: '+92 303 1111111',
        afterImageUrl:  'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        resolvedAt: DateTime.now().subtract(const Duration(days: 6)),
        cleanupDuration: const Duration(hours: 2),
        latitude: 31.7000,
        longitude: 73.9700,
        rating: 4,
        feedback: 'Good job, area is clean now.',
      ),
    ];
  }
}