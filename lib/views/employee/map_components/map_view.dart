import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/map_components/report_marker.dart';

class MapView extends StatelessWidget {
  final MapTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final MapController mapController;
  final List<Report> reports;
  final AnimationController pulseAnimation;
  final Function(Report) onReportTap;
  final VoidCallback onMapReady;

  const MapView({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.mapController,
    required this.reports,
    required this.pulseAnimation,
    required this. onReportTap,
    required this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: MapDesign.defaultCenter,
        initialZoom:  MapDesign.defaultZoom,
        minZoom: 5,
        maxZoom: 19,
        onTap: (_, __) {
          if (viewModel.selectedReport != null) {
            onReportTap(viewModel.selectedReport!);
          }
        },
        onMapReady:  onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate:  viewModel.mapType == 'satellite'
              ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.neatnow.app',
        ),
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return reports.map((report) {
      if (! viewModel.hasValidLocation(report)) return null;

      final location = viewModel.getReportLocation(report)!;
      final isSelected = viewModel.selectedReport?. id == report.id;
      final color = viewModel.getStatusColor(report.status);
      final baseSize = viewModel.getMarkerSize(responsive. screenWidth);
      final size = isSelected ? baseSize * 1.2 : baseSize;

      return Marker(
        point: location,
        width: size + 4,
        height: size + 12,
        child: GestureDetector(
          onTap: () => onReportTap(report),
          child: ReportMarker(
            report:  report,
            viewModel: viewModel,
            isSelected: isSelected,
            color: color,
            size: size,
            pulseAnimation: pulseAnimation,
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }
}