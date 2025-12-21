import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:neat_now/models/employee_models.dart';

/// Map Design Constants
class MapDesign {
  static const Color primaryTeal = Color(0xFF2AC2AB);
  static const Color primaryTealDark = Color(0xFF1FA896);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFB);

  static const LatLng defaultCenter = LatLng(31.7167, 73.9850); // Sheikhupura
  static const double defaultZoom = 13.0;
}

/// Filter Option Model
class MapFilterOption {
  final String value;
  final String label;
  final String shortLabel;
  final String nano;
  final Color color;

  const MapFilterOption({
    required this.value,
    required this. label,
    required this.shortLabel,
    required this.nano,
    required this.color,
  });

  static final List<MapFilterOption> defaults = [
    MapFilterOption(
      value: 'all',
      label: 'All',
      shortLabel: 'All',
      nano: 'A',
      color: Colors.grey,
    ),
    MapFilterOption(
      value: 'pending',
      label: 'Pending',
      shortLabel: 'Pending',
      nano:  'P',
      color:  MapDesign.warning,
    ),
    MapFilterOption(
      value: 'in-progress',
      label: 'Active',
      shortLabel: 'Active',
      nano: 'W',
      color: MapDesign.info,
    ),
    MapFilterOption(
      value: 'resolved',
      label: 'Done',
      shortLabel: 'Done',
      nano: 'D',
      color: MapDesign.success,
    ),
  ];
}

/// Map Layout Modes
enum MapLayout { micro, compact, mobile, tablet, desktop }

/// Map State Model
class MapState {
  final String selectedFilter;
  final Report? selectedReport;
  final String mapType;
  final bool showLegend;
  final bool isMapReady;

  const MapState({
    this.selectedFilter = 'all',
    this. selectedReport,
    this.mapType = 'street',
    this.showLegend = false,
    this.isMapReady = false,
  });

  MapState copyWith({
    String?  selectedFilter,
    Report? selectedReport,
    bool clearSelectedReport = false,
    String? mapType,
    bool?  showLegend,
    bool? isMapReady,
  }) {
    return MapState(
      selectedFilter: selectedFilter ??  this.selectedFilter,
      selectedReport: clearSelectedReport ? null : (selectedReport ?? this.selectedReport),
      mapType: mapType ??  this.mapType,
      showLegend: showLegend ?? this.showLegend,
      isMapReady: isMapReady ?? this.isMapReady,
    );
  }
}

/// AI Classification Result
class AIClassificationResult {
  final List<WasteCategory> categories;
  final double confidence;

  const AIClassificationResult({
    required this.categories,
    required this.confidence,
  });

  static AIClassificationResult get mock => AIClassificationResult(
    categories: [
      WasteCategory(name: 'Plastic', percentage: 65, color: Colors.blue),
      WasteCategory(name: 'Paper', percentage: 20, color: Colors.brown),
      WasteCategory(name: 'Organic', percentage: 10, color: Colors.green),
      WasteCategory(name: 'Other', percentage: 5, color:  Colors.grey),
    ],
    confidence: 0.94,
  );
}

class WasteCategory {
  final String name;
  final int percentage;
  final Color color;

  const WasteCategory({
    required this.name,
    required this.percentage,
    required this.color,
  });
}

/// Verification Step Model
class VerificationStep {
  final String label;
  final bool isCompleted;
  final bool isCurrent;

  const VerificationStep({
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
  });

  static List<String> get defaultSteps => [
    'Uploading cleanup image.. .',
    'Capturing GPS location...',
    'Analyzing before image.. .',
    'Analyzing after image...',
    'Comparing cleanliness...',
    'Generating report...',
  ];
}

/// AI Verification Result
class AIVerificationResult {
  final bool isVerified;
  final int cleanlinessScore;
  final int threshold;
  final List<String> detectedIssues;

  const AIVerificationResult({
    required this. isVerified,
    required this.cleanlinessScore,
    this.threshold = 85,
    this.detectedIssues = const [],
  });
}