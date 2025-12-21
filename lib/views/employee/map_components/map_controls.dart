import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class MapControls extends StatelessWidget {
  final MapTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final MapController mapController;
  final MapLayout layout;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onToggleMapType;
  final VoidCallback onRecenter;

  const MapControls({
    super.key,
    required this.viewModel,
    required this.responsive,
    required this.mapController,
    required this.layout,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onToggleMapType,
    required this. onRecenter,
  });

  @override
  Widget build(BuildContext context) {
    final controlSize = _getControlSize();

    return Container(
        decoration: BoxDecoration(
          color: MapDesign.surfaceWhite,
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: layout == MapLayout.micro ? 4 : 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          _buildControlButton(
          Icons.add_rounded,
          controlSize,
          onZoomIn,
        ),
        _buildDivider(controlSize * 0.8),
        _buildControlButton(
          Icons.remove_rounded,
          controlSize,
          onZoomOut,
        ),
        if (layout != MapLayout.micro) ...[
    _buildDivider(controlSize * 0.8),
    _buildControlButton(
    viewModel.mapType == 'street'
    ? Icons.satellite_alt_rounded
        : Icons. map_rounded,
    controlSize,
    onToggleMapType,
    ),
    ],
    _buildDivider(controlSize * 0.8),
    _buildControlButton(
    Icons.my_location_rounded,
    controlSize,
    onRecenter,
    ),
    ],
    ),
    );
  }

  Widget _buildControlButton(IconData icon, double size, VoidCallback onTap) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        icon: Icon(icon, size: size * 0.5),
        onPressed: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        padding: EdgeInsets.zero,
        color: MapDesign.primaryTeal,
      ),
    );
  }

  Widget _buildDivider(double width) {
    return Container(
      height: 1,
      width: width,
      color: Colors.grey[200],
    );
  }

  double _getControlSize() {
    switch (layout) {
      case MapLayout.micro:
        return 24;
      case MapLayout.compact:
        return 30;
      case MapLayout.mobile:
        return 38;
      case MapLayout.tablet:
      case MapLayout.desktop:
        return 42;
    }
  }

  double _getBorderRadius() {
    switch (layout) {
      case MapLayout.micro:
      case MapLayout.compact:
        return 6;
      case MapLayout.mobile:
        return 8;
      case MapLayout.tablet:
      case MapLayout.desktop:
        return 12;
    }
  }
}