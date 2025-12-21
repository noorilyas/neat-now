import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'dart:math' as math;

class MapTabViewModel extends ChangeNotifier {
  MapState _state = const MapState();

  MapState get state => _state;
  String get selectedFilter => _state.selectedFilter;
  Report? get selectedReport => _state. selectedReport;
  String get mapType => _state.mapType;
  bool get showLegend => _state.showLegend;
  bool get isMapReady => _state.isMapReady;

  List<MapFilterOption> get filterOptions => MapFilterOption.defaults;

  // Filter reports with valid location
  List<Report> filterReports(List<Report> reports) {
    final withLocation = reports.where((r) {
      return r.latitude != null &&
          r.longitude != null &&
          r.latitude != 0.0 &&
          r.longitude != 0.0 &&
          r.latitude!. abs() <= 90 &&
          r.longitude!. abs() <= 180;
    }).toList();

    if (_state.selectedFilter == 'all') return withLocation;
    return withLocation.where((r) => r.status == _state.selectedFilter).toList();
  }

  int getFilterCount(List<Report> reports, String filter) {
    final valid = reports.where((r) =>
    r.latitude != null &&
        r.latitude != 0.0 &&
        r.longitude != null &&
        r.longitude != 0.0);
    if (filter == 'all') return valid.length;
    return valid.where((r) => r.status == filter).length;
  }

  // Get map layout based on screen dimensions
  MapLayout getLayout(double width, double height) {
    if (width < 300) return MapLayout.micro;
    if (width < 400) return MapLayout.compact;
    if (width < 600) return MapLayout.mobile;
    if (width < 900) return MapLayout.tablet;
    return MapLayout.desktop;
  }

  // Get marker size based on screen width
  double getMarkerSize(double screenWidth) {
    if (screenWidth < 300) return 28;
    if (screenWidth < 400) return 32;
    if (screenWidth < 600) return 36;
    return 40;
  }

  // State mutations
  void setSelectedFilter(String filter) {
    _state = _state.copyWith(selectedFilter: filter, clearSelectedReport: true);
    notifyListeners();
  }

  void selectReport(Report?  report) {
    _state = _state.copyWith(
      selectedReport: report,
      clearSelectedReport: report == null,
    );
    notifyListeners();
  }

  void toggleMapType() {
    _state = _state.copyWith(
      mapType: _state.mapType == 'street' ? 'satellite' : 'street',
    );
    notifyListeners();
  }

  void toggleLegend() {
    _state = _state.copyWith(showLegend: !_state. showLegend);
    notifyListeners();
  }

  void setMapReady(bool ready) {
    _state = _state. copyWith(isMapReady:  ready);
    notifyListeners();
  }

  // Helper methods
  Color getStatusColor(String status) {
    switch (status. toLowerCase()) {
      case 'resolved':
        return MapDesign.success;
      case 'in-progress':
        return MapDesign.info;
      case 'pending':
        return MapDesign.warning;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 'Completed';
      case 'in-progress':
        return 'Assigned';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  IconData getWasteIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('plastic')) return Icons.local_drink_rounded;
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

  String formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour. toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  bool hasValidLocation(Report report) {
    return report. latitude != null &&
        report.longitude != null &&
        report.latitude != 0.0 &&
        report.longitude != 0.0;
  }

  LatLng?  getReportLocation(Report report) {
    if (!hasValidLocation(report)) return null;
    return LatLng(report.latitude!, report.longitude!);
  }

  // AI Verification simulation
  Future<AIVerificationResult> performAIVerification() async {
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));

    // 80% success rate for demo
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final isClean = random < 80;

    return AIVerificationResult(
      isVerified: isClean,
      cleanlinessScore: isClean ? 85 + (random % 15) : 40 + (random % 40),
      threshold: 85,
      detectedIssues:  isClean
          ? []
          : [
        'Remaining debris detected in corner',
        'Small waste particles visible',
      ],
    );
  }

  AIClassificationResult getAIClassification() {
    return AIClassificationResult. mock;
  }
}