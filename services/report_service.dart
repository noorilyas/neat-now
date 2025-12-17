import 'package:flutter/cupertino.dart';

import '../models/waste_report.dart';

class ReportService extends ChangeNotifier {
  final List<WasteReport> _reports = [];
  final List<WasteReport> _recentReports = [];
  bool _isLoading = false;
  String? _error;

  List<WasteReport> get reports => List.unmodifiable(_reports);
  List<WasteReport> get recentReports => List.unmodifiable(_recentReports);
  List<WasteReport> get allReports => [..._recentReports, ..._reports];
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReportService() {
    _loadMockReports();
  }

  void _loadMockReports() {
    _recentReports.addAll([
      WasteReport(
        id: '1',
        location: 'Park Area A',
        type: 'Plastic Waste',
        status: ReportStatus.resolved,
        date: '2h',
        quantity: 'High',
        wasteTypes: ['Plastic', 'Paper'],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      WasteReport(
        id: '2',
        location: 'Street 5',
        type: 'Mixed Waste',
        status: ReportStatus.pending,
        date: '5h',
        quantity: 'Med',
        wasteTypes: ['Mixed'],
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      WasteReport(
        id: '3',
        location: 'Playground',
        type: 'Paper Waste',
        status: ReportStatus.inProgress,
        date: '1d',
        quantity: 'Low',
        wasteTypes: ['Paper', 'Cardboard'],
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  // Fetch reports from API
  Future<void> fetchReports({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // In production, replace with actual API call
      // final reports = await getReportsFromAPI(userId);
      // _reports.clear();
      // _reports.addAll(reports);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit new report
  Future<bool> submitReport(WasteReport report) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));

      // In production, call actual API
      // final response = await postReportToAPI(report);

      _reports.insert(0, report);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit report: $e';
      notifyListeners();
      return false;
    }
  }

  // Update report status
  Future<bool> updateReportStatus(String reportId, ReportStatus newStatus) async {
    try {
      final index = _reports.indexWhere((r) => r.id == reportId);
      if (index != -1) {
        _reports[index] = _reports[index].copyWith(status: newStatus);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update report: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete report
  Future<bool> deleteReport(String reportId) async {
    try {
      _reports.removeWhere((r) => r.id == reportId);
      _recentReports.removeWhere((r) => r.id == reportId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete report: $e';
      notifyListeners();
      return false;
    }
  }

  // Get report by ID
  WasteReport? getReportById(String id) {
    try {
      return allReports.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  // API call example
  Future<List<WasteReport>> getReportsFromAPI(String? userId) async {
    // TODO: Implement actual API call
    throw UnimplementedError('API integration pending');
  }

  Future<WasteReport> postReportToAPI(WasteReport report) async {
    // TODO: Implement actual API call
    throw UnimplementedError('API integration pending');
  }
}