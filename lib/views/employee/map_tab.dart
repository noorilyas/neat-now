import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/map_components/map_view.dart';
import 'package:neat_now/views/employee/map_components/map_controls.dart';
import 'package:neat_now/views/employee/map_components/map_filters.dart';
import 'package:neat_now/views/employee/map_components/task_detail_sheet.dart';
import 'package:neat_now/views/employee/map_components/resolve_sheet.dart';
import 'package:neat_now/views/employee/map_components/add_location_sheet.dart';
import 'package:neat_now/views/employee/map_components/ai_verification_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// BinsMapTab - Task Viewing & Navigation with AI Verification (MVVM)
class BinsMapTab extends StatefulWidget {
  final Future<List<Report>> reportsFuture;
  final Function(int, String, {String? imagePath, double? latitude, double? longitude, String? locationAddress}) onUpdateStatus;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;

  const BinsMapTab({
    super.key,
    required this.reportsFuture,
    required this.onUpdateStatus,
    required this.onRefresh,
    required this. responsive,
  });

  @override
  State<BinsMapTab> createState() => _BinsMapTabState();
}

class _BinsMapTabState extends State<BinsMapTab> with TickerProviderStateMixin {
  late MapTabViewModel _viewModel;
  late MapController _mapController;
  final ImagePicker _imagePicker = ImagePicker();

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _cardController;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = MapTabViewModel();
    _mapController = MapController();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset. zero,
    ).animate(CurvedAnimation(
      parent:  _cardController,
      curve:  Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController.stop();
    _cardController.stop();
    _pulseController.dispose();
    _cardController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _selectReport(Report?  report) {
    _viewModel.selectReport(report);
    if (report != null) {
      _cardController.forward();
      if (_viewModel.isMapReady && _viewModel.hasValidLocation(report)) {
        final location = _viewModel.getReportLocation(report)!;
        _mapController. move(location, 16);
      }
    } else {
      _cardController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _viewModel.getLayout(constraints. maxWidth, constraints.maxHeight);

        return FutureBuilder<List<Report>>(
          future: widget.reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error. toString());
            }
            if (!snapshot.hasData || snapshot.data! .isEmpty) {
              return _buildEmptyState();
            }

            final allReports = snapshot.data!;
            final filteredReports = _viewModel.filterReports(allReports);

            return ListenableBuilder(
              listenable: _viewModel,
              builder: (context, child) {
                return _buildContent(
                  layout,
                  allReports,
                  filteredReports,
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
      MapLayout layout,
      List<Report> allReports,
      List<Report> filteredReports,
      double width,
      double height,
      ) {
    final r = widget.responsive;

    // Common map view
    final mapView = MapView(
      viewModel: _viewModel,
      responsive: r,
      mapController: _mapController,
      reports: filteredReports,
      pulseAnimation: _pulseController,
      onReportTap: (report) {
        HapticFeedback.selectionClick();
        final isSelected = _viewModel.selectedReport?. id == report.id;
        _selectReport(isSelected ?  null : report);
      },
      onMapReady: () => _viewModel.setMapReady(true),
    );

    switch (layout) {
      case MapLayout.micro:
      case MapLayout.compact:
      case MapLayout.mobile:
        return _buildMobileLayout(allReports, filteredReports, mapView, width, height);

      case MapLayout.tablet:
        return _buildTabletLayout(allReports, filteredReports, mapView, width, height);

      case MapLayout.desktop:
        return _buildDesktopLayout(allReports, filteredReports, mapView, width);
    }
  }

  Widget _buildMobileLayout(
      List<Report> allReports,
      List<Report> filteredReports,
      Widget mapView,
      double width,
      double height,
      ) {
    final r = widget.responsive;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final layout = _viewModel.getLayout(width, height);

    return Stack(
      children: [
        mapView,

        // Filters at top
        Positioned(
          top: layout == MapLayout.micro ? 4 : (layout == MapLayout.compact ? 6 : 10),
          left: layout == MapLayout.micro ? 4 : (layout == MapLayout. compact ? 6 : 10),
          right: layout == MapLayout.micro ?  4 : (layout == MapLayout.compact ? 6 :  10),
          child: MapFilters(
            viewModel: _viewModel,
            responsive: r,
            allReports: allReports,
            layout: layout,
            onFilterSelected: (filter) {
              HapticFeedback.selectionClick();
              _viewModel. setSelectedFilter(filter);
            },
          ),
        ),

        // Controls at top right
        Positioned(
          top: layout == MapLayout.micro ?  44 : (layout == MapLayout. compact ? 52 : 66),
          right: layout == MapLayout.micro ? 4 : (layout == MapLayout. compact ? 6 : 10),
          child: MapControls(
            viewModel: _viewModel,
            responsive: r,
            mapController: _mapController,
            layout: layout,
            onZoomIn: () {
              _mapController.move(
                _mapController.camera.center,
                (_mapController.camera.zoom + 1).clamp(5.0, 19.0),
              );
            },
            onZoomOut:  () {
              _mapController. move(
                _mapController. camera.center,
                (_mapController.camera.zoom - 1).clamp(5.0, 19.0),
              );
            },
            onToggleMapType: () => _viewModel.toggleMapType(),
            onRecenter: () {
              _mapController.move(MapDesign.defaultCenter, MapDesign.defaultZoom);
            },
          ),
        ),

        // Stats/Legend
        if (_viewModel.selectedReport == null && filteredReports.isNotEmpty)
          Positioned(
            bottom: layout == MapLayout.mobile ? 12 : 8,
            right: layout == MapLayout.mobile ?  12 : 8,
            child: _buildStats(filteredReports, layout),
          ),

        // Empty state
        if (filteredReports.isEmpty) _buildNoResultsState(layout),

        // Selected report card
        if (_viewModel.selectedReport != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position:  _cardSlideAnimation,
              child: _buildReportCard(_viewModel.selectedReport!, bottomPad, layout),
            ),
          ),
      ],
    );
  }

  Widget _buildTabletLayout(
      List<Report> allReports,
      List<Report> filteredReports,
      Widget mapView,
      double width,
      double height,
      ) {
    final r = widget.responsive;
    final isLandscape = width > height;

    if (isLandscape) {
      return Row(
        children: [
          Container(
            width: (width * 0.35).clamp(280.0, 320.0),
            decoration: BoxDecoration(
              color: MapDesign.surfaceWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius:  10,
                ),
              ],
            ),
            child: _buildSidePanel(allReports, filteredReports),
          ),
          Expanded(
            child: Stack(
              children: [
                mapView,
                Positioned(
                  top: 12,
                  right: 12,
                  child: MapControls(
                    viewModel: _viewModel,
                    responsive: r,
                    mapController: _mapController,
                    layout: MapLayout.tablet,
                    onZoomIn:  () {
                      _mapController.move(
                        _mapController.camera.center,
                        (_mapController.camera.zoom + 1).clamp(5.0, 19.0),
                      );
                    },
                    onZoomOut:  () {
                      _mapController.move(
                        _mapController.camera.center,
                        (_mapController.camera.zoom - 1).clamp(5.0, 19.0),
                      );
                    },
                    onToggleMapType: () => _viewModel.toggleMapType(),
                    onRecenter: () {
                      _mapController.move(MapDesign.defaultCenter, MapDesign. defaultZoom);
                    },
                  ),
                ),
                if (filteredReports.isEmpty) _buildNoResultsState(MapLayout.tablet),
              ],
            ),
          ),
        ],
      );
    }

    return _buildMobileLayout(allReports, filteredReports, mapView, width, height);
  }

  Widget _buildDesktopLayout(
      List<Report> allReports,
      List<Report> filteredReports,
      Widget mapView,
      double width,
      ) {
    final r = widget.responsive;
    final sideWidth = (width * 0.3).clamp(320.0, 380.0);

    return Row(
      children: [
        Container(
          width: sideWidth,
          decoration: BoxDecoration(
            color: MapDesign.surfaceWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: _buildSidePanel(allReports, filteredReports),
        ),
        Expanded(
          child: Stack(
            children: [
              mapView,
              Positioned(
                top: 16,
                right: 16,
                child: MapControls(
                  viewModel: _viewModel,
                  responsive: r,
                  mapController: _mapController,
                  layout:  MapLayout.desktop,
                  onZoomIn: () {
                    _mapController.move(
                      _mapController.camera.center,
                      (_mapController.camera.zoom + 1).clamp(5.0, 19.0),
                    );
                  },
                  onZoomOut: () {
                    _mapController.move(
                      _mapController.camera.center,
                      (_mapController.camera.zoom - 1).clamp(5.0, 19.0),
                    );
                  },
                  onToggleMapType: () => _viewModel.toggleMapType(),
                  onRecenter: () {
                    _mapController. move(MapDesign.defaultCenter, MapDesign.defaultZoom);
                  },
                ),
              ),
              if (filteredReports.isEmpty) _buildNoResultsState(MapLayout.desktop),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidePanel(List<Report> allReports, List<Report> filteredReports) {
    // Implementation similar to the desktop layout side panel
    // For brevity, this would include header, filters, and list
    return Column(
      children: [
        // Header, filters, and list will be implemented in separate components
        Expanded(child: Container()), // Placeholder
      ],
    );
  }

  Widget _buildReportCard(Report report, double bottomPad, MapLayout layout) {
    // Compact card implementation
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPad + 12),
      decoration: BoxDecoration(
        color: MapDesign. surfaceWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card content
          Text(report.type), // Placeholder
        ],
      ),
    );
  }

  Widget _buildStats(List<Report> reports, MapLayout layout) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: MapDesign. surfaceWhite. withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('${reports.length} Tasks'),
    );
  }

  // Navigation
  Future<void> _navigateToLocation(Report report) async {
    if (! _viewModel.hasValidLocation(report)) {
      _showSnackBar('No GPS coordinates available', isSuccess: false);
      return;
    }

    final lat = report.latitude! ;
    final lng = report.longitude!;

    try {
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/? api=1&destination=$lat,$lng&travelmode=driving',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open navigation', isSuccess: false);
      }
    } catch (e) {
      _showSnackBar('Navigation error', isSuccess: false);
    }
  }

  // Sheets
  void _showTaskDetailSheet(Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(
        report: report,
        viewModel: _viewModel,
        responsive: widget.responsive,
        onClose: () => Navigator.pop(context),
        onNavigate: () {
          Navigator.pop(context);
          _navigateToLocation(report);
        },
        onResolve: () {
          Navigator.pop(context);
          _showResolveSheet(report);
        },
        onAddLocation: () {
          Navigator. pop(context);
          _showAddLocationSheet(report);
        },
      ),
    );
  }

  void _showResolveSheet(Report report) {
    showModalBottomSheet(
      context:  context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResolveSheet(
        report: report,
        viewModel: _viewModel,
        responsive: widget.responsive,
        imagePicker: _imagePicker,
        onResolve: (imagePath, lat, lng, address, timestamp) {
          Navigator.pop(context);
          _showAIVerificationDialog(report, imagePath, lat, lng, address, timestamp);
        },
      ),
    );
  }

  void _showAddLocationSheet(Report report) {
    if (_viewModel.hasValidLocation(report)) {
      _showSnackBar('This task already has a location', isSuccess: false);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLocationSheet(
        report: report,
        viewModel: _viewModel,
        responsive: widget. responsive,
        onSave: (lat, lng, address) async {
          Navigator.pop(context);
          await widget.onUpdateStatus(
            report. id,
            report.status,
            latitude: lat,
            longitude: lng,
            locationAddress: address,
          );
          widget.onRefresh();
          _showSnackBar('Location added successfully! ');
        },
      ),
    );
  }

  void _showAIVerificationDialog(
      Report report,
      String imagePath,
      double lat,
      double lng,
      String address,
      DateTime timestamp,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AIVerificationDialog(
        report: report,
        viewModel: _viewModel,
        responsive: widget.responsive,
        afterImagePath: imagePath,
        latitude: lat,
        longitude: lng,
        address: address,
        timestamp: timestamp,
        onSuccess: () async {
          Navigator.pop(context);
          await widget.onUpdateStatus(
            report.id,
            'resolved',
            imagePath: imagePath,
            latitude: lat,
            longitude: lng,
            locationAddress: address,
          );
          _selectReport(null);
          widget.onRefresh();
          _showSuccessDialog();
        },
        onRetry: () {
          Navigator. pop(context);
          _showResolveSheet(report);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showSuccessDialog() {
    // Success dialog implementation
  }

  // States
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String error) {
    return Center(child: Text('Error: $error'));
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No tasks assigned'));
  }

  Widget _buildNoResultsState(MapLayout layout) {
    return const Center(child: Text('No tasks found'));
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    if (! mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? MapDesign.primaryTeal : MapDesign.error,
      ),
    );
  }
}