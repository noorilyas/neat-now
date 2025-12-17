import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;

/// BinsMapTab - Task Viewing & Navigation (FR-W4) with AI Verification (FR-W5)
/// Features:
/// - View all active and completed tasks
/// - Display waste image, AI classification, description, location
/// - Navigation to cleanup location
/// - After-cleanup image upload with GPS capture
/// - AI verification workflow
/// - Manual location addition (not editing)
class BinsMapTab extends StatefulWidget {
  final Future<List<Report>> reportsFuture;
  final Function(int, String,
      {String?  imagePath,
      double? latitude,
      double? longitude,
      String? locationAddress}) onUpdateStatus;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;

  const BinsMapTab({
    super.key,
    required this.reportsFuture,
    required this.onUpdateStatus,
    required this.onRefresh,
    required this.responsive,
  });

  @override
  State<BinsMapTab> createState() => _BinsMapTabState();
}

class _BinsMapTabState extends State<BinsMapTab> with TickerProviderStateMixin {
  late MapController _mapController;
  String _selectedFilter = 'all';
  Report? _selectedReport;
  String _mapType = 'street';
  bool _showLegend = false;
  bool _isMapReady = false;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _cardController;
  late Animation<Offset> _cardSlideAnimation;

  // Default location (Sheikhupura)
  static const LatLng _defaultCenter = LatLng(31.7167, 73.9850);
  static const double _defaultZoom = 13.0;

  // Filter options
  final List<_FilterData> _filters = [
    _FilterData('all', 'All', 'A', Colors.grey),
    _FilterData('pending', 'Pending', 'P', Colors.orange),
    _FilterData('in-progress', 'Active', 'W', Colors.blue),
    _FilterData('resolved', 'Done', 'D', Colors.green),
  ];

  @override
  void initState() {
    super.initState();
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
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cardController. dispose();
    super.dispose();
  }

  // ==================== DATA HELPERS ====================

  List<Report> _filterReports(List<Report> reports) {
    final withLocation = reports.where((r) {
      return r. latitude != null &&
          r.longitude != null &&
          r.latitude != 0.0 &&
      r.longitude != 0.0 &&
      r. latitude! .abs() <= 90 &&
      r.longitude! .abs() <= 180;
    }). toList();

    if (_selectedFilter == 'all') return withLocation;
    return withLocation.where((r) => r.status == _selectedFilter).toList();
  }

  void _selectReport(Report?  report) {
    setState(() => _selectedReport = report);
    if (report != null) {
      _cardController.forward();
      if (_isMapReady && report.latitude != null && report.longitude != null) {
        _mapController.move(LatLng(report.latitude!, report. longitude!), 16);
      }
    } else {
      _cardController.reverse();
    }
  }

  int _getCount(List<Report> reports, String filter) {
    final valid = reports.where((r) =>
    r.latitude != null &&
        r.latitude != 0.0 &&
        r. longitude != null &&
        r.longitude != 0.0);
    if (filter == 'all') return valid. length;
    return valid.where((r) => r.status == filter).length;
  }

  // ==================== NAVIGATION ====================

  Future<void> _navigateToLocation(Report report) async {
    if (report.latitude == null || report.longitude == null) {
      _showSnackBar('No GPS coordinates available', isSuccess: false);
      return;
    }

    final lat = report.latitude! ;
    final lng = report.longitude! ;

    // Try Google Maps first, then Apple Maps, then browser
    final googleMapsUrl = 'google.navigation:q=$lat,$lng&mode=d';
    final appleMapsUrl = 'maps://maps. apple.com/? daddr=$lat,$lng&dirflg=d';
    final browserUrl = 'https://www.google.com/maps/dir/? api=1&destination=$lat,$lng&travelmode=driving';

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(Uri.parse(appleMapsUrl));
      } else {
        await launchUrl(Uri.parse(browserUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showSnackBar('Could not open navigation', isSuccess: false);
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final layout = _getLayout(w, h);

        return FutureBuilder<List<Report>>(
          future: widget. reportsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading(w);
            }
            if (snapshot. hasError) {
              return _buildError(snapshot.error. toString(), w);
            }
            if (! snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmpty(w);
            }

            final all = snapshot.data! ;
            final filtered = _filterReports(all);
            return _buildContent(layout, all, filtered, w, h);
          },
        );
      },
    );
  }

  _Layout _getLayout(double w, double h) {
    if (w < 300) return _Layout. micro;
    if (w < 400) return _Layout. compact;
    if (w < 600) return _Layout.mobile;
    if (w < 900) return _Layout. tablet;
    return _Layout.desktop;
  }

  Widget _buildContent(
      _Layout layout, List<Report> all, List<Report> filtered, double w, double h) {
    switch (layout) {
      case _Layout. micro:
        return _buildMicroLayout(all, filtered, w, h);
      case _Layout. compact:
        return _buildCompactLayout(all, filtered, w, h);
      case _Layout. mobile:
        return _buildMobileLayout(all, filtered, w, h);
      case _Layout. tablet:
        return _buildTabletLayout(all, filtered, w, h);
      case _Layout. desktop:
        return _buildDesktopLayout(all, filtered, w, h);
    }
  }

  // ==================== MAP ====================

  Widget _buildMap(List<Report> reports) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: _defaultZoom,
        minZoom: 5,
        maxZoom: 19,
        onTap: (_, __) {
          if (_selectedReport != null) _selectReport(null);
        },
        onMapReady: () => setState(() => _isMapReady = true),
      ),
      children: [
        TileLayer(
          urlTemplate: _mapType == 'satellite'
              ? 'https://server. arcgisonline. com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.neatnow.app',
        ),
        MarkerLayer(markers: _buildMarkers(reports)),
      ],
    );
  }

  List<Marker> _buildMarkers(List<Report> reports) {
    return reports.map((r) {
      final selected = _selectedReport?. id == r.id;
      final color = _statusColor(r.status);
      final baseSize = _getMarkerSize();
      final size = selected ? baseSize * 1.2 : baseSize;

      return Marker(
        point: LatLng(r.latitude!, r.longitude!),
        width: size + 4,
        height: size + 12,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            _selectReport(selected ?  null : r);
          },
          child: _buildMarker(r, selected, color, size),
        ),
      );
    }).toList();
  }

  double _getMarkerSize() {
    final w = widget.responsive.screenWidth;
    if (w < 300) return 28;
    if (w < 400) return 32;
    if (w < 600) return 36;
    return 40;
  }

  Widget _buildMarker(Report r, bool selected, Color color, double size) {
    return Column(
      mainAxisSize: MainAxisSize. min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors. white, width: selected ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(selected ? 0.5 : 0.3),
                blurRadius: selected ? 10 : 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _wasteIcon(r.type),
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        CustomPaint(
          size: Size(8, selected ? 8 : 6),
          painter: _PointerPainter(color),
        ),
      ],
    );
  }

  // ==================== MICRO LAYOUT (<300px) ====================

  Widget _buildMicroLayout(List<Report> all, List<Report> filtered, double w, double h) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        _buildMap(filtered),
        Positioned(
          top: 4,
          left: 4,
          right: 4,
          child: _buildMicroFilter(all),
        ),
        Positioned(
          top: 44,
          right: 4,
          child: _buildMicroControls(),
        ),
        if (filtered.isNotEmpty && _selectedReport == null)
          Positioned(
            bottom: 4,
            right: 4,
            child: _buildCountBadge(filtered. length),
          ),
        if (filtered.isEmpty) _buildMicroEmpty(),
        if (_selectedReport != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _cardSlideAnimation,
              child: _buildMicroCard(_selectedReport!, bottomPad),
            ),
          ),
      ],
    );
  }

  Widget _buildMicroFilter(List<Report> all) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.1), blurRadius: 4)],
      ),
      child: Row(
        children: _filters.map((f) {
          final sel = _selectedFilter == f.value;
          final count = _getCount(all, f. value);
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedFilter = f.value;
                _selectedReport = null;
              }),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: sel ? f.color. withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius. circular(6),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      color: sel ? f.color : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMicroControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.1), blurRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconBtn(Icons.add, 24, () {
            _mapController.move(_mapController.camera.center,
                (_mapController.camera. zoom + 1). clamp(5.0, 19.0));
          }),
          Container(height: 1, width: 20, color: Colors.grey[200]),
          _iconBtn(Icons.remove, 24, () {
            _mapController.move(_mapController.camera.center,
                (_mapController.camera.zoom - 1).clamp(5.0, 19.0));
          }),
          Container(height: 1, width: 20, color: Colors.grey[200]),
          _iconBtn(Icons.my_location, 24, () {
            _mapController.move(_defaultCenter, _defaultZoom);
          }),
        ],
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2AC2AB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight. bold, color: Colors.white),
      ),
    );
  }

  Widget _buildMicroEmpty() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white. withOpacity(0.95),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 24, color: Colors. grey[400]),
            const SizedBox(height: 4),
            Text('No tasks', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroCard(Report r, double bottomPad) {
    final color = _statusColor(r.status);
    final canResolve = r.status == 'in-progress';
    final hasLocation = r.latitude != null && r.longitude != null;

    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, bottomPad + 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 3,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color. withOpacity(0.1),
                  borderRadius: BorderRadius. circular(6),
                ),
                child: Icon(_wasteIcon(r.type), color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r.type,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight. w600),
                  maxLines: 1,
                  overflow: TextOverflow. ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => _selectReport(null),
                child: Icon(Icons.close, size: 16, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _miniBtn('Details', Icons.info_outline, () => _showTaskDetailSheet(r))),
              if (hasLocation) ...[
                const SizedBox(width: 4),
                Expanded(child: _miniBtn('Navigate', Icons.navigation, () => _navigateToLocation(r), isBlue: true)),
              ],
              if (canResolve) ...[
                const SizedBox(width: 4),
                Expanded(child: _miniBtn('Resolve', Icons.check, () => _showResolveSheet(r), isGreen: true)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBtn(String label, IconData icon, VoidCallback onTap, {bool isGreen = false, bool isBlue = false}) {
    final color = isGreen ? Colors.green : (isBlue ? Colors.blue : Colors. grey[100]);
    final textColor = isGreen || isBlue ? Colors.white : Colors. grey[700];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets. symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius. circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts. poppins(fontSize: 9, fontWeight: FontWeight.w600, color: textColor),
                overflow: TextOverflow. ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== COMPACT LAYOUT (300-399px) ====================

  Widget _buildCompactLayout(List<Report> all, List<Report> filtered, double w, double h) {
    final bottomPad = MediaQuery.of(context). padding.bottom;

    return Stack(
      children: [
        _buildMap(filtered),
        Positioned(
          top: 6,
          left: 6,
          right: 6,
          child: _buildCompactFilter(all, w),
        ),
        Positioned(
          top: 52,
          right: 6,
          child: _buildCompactControls(),
        ),
        if (filtered.isNotEmpty && _selectedReport == null)
          Positioned(
            bottom: 8,
            right: 8,
            child: _buildCompactStats(filtered),
          ),
        if (filtered.isEmpty) _buildCompactEmpty(),
        if (_selectedReport != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _cardSlideAnimation,
              child: _buildCompactCard(_selectedReport!, bottomPad),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactFilter(List<Report> all, double w) {
    return Container(
      height: 42,
      padding: const EdgeInsets. all(4),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius. circular(10),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.08), blurRadius: 6)],
      ),
      child: Row(
        children: _filters. map((f) {
          final sel = _selectedFilter == f.value;
          final count = _getCount(all, f.value);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilter = f.value;
                  _selectedReport = null;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: sel ? f.color. withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment. center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: f.color, shape: BoxShape. circle),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                          color: sel ? f.color : Colors. grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }). toList(),
      ),
    );
  }

  Widget _buildCompactControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.1), blurRadius: 6)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconBtn(Icons.add, 30, () {
            _mapController.move(_mapController.camera.center,
                (_mapController.camera.zoom + 1).clamp(5.0, 19.0));
          }),
          _divider(26),
          _iconBtn(Icons. remove, 30, () {
            _mapController.move(_mapController.camera.center,
                (_mapController.camera.zoom - 1).clamp(5.0, 19.0));
          }),
          _divider(26),
          _iconBtn(
            _mapType == 'street' ? Icons.satellite_alt : Icons.map,
            30,
                () => setState(() => _mapType = _mapType == 'street' ? 'satellite' : 'street'),
          ),
          _divider(26),
          _iconBtn(Icons.my_location, 30, () {
            _mapController.move(_defaultCenter, _defaultZoom);
          }),
        ],
      ),
    );
  }

  Widget _buildCompactStats(List<Report> reports) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors. white. withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors. black.withOpacity(0.08), blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.assignment_rounded, size: 14, color: Color(0xFF2AC2AB)),
          const SizedBox(width: 4),
          Text(
            '${reports.length} Tasks',
            style: GoogleFonts. poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactEmpty() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets. all(16),
        decoration: BoxDecoration(
          color: Colors.white. withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize. min,
          children: [
            Icon(Icons.assignment_outlined, size: 32, color: Colors. grey[400]),
            const SizedBox(height: 8),
            Text(
              'No tasks found',
              style: GoogleFonts. poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            if (_selectedFilter != 'all') ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() => _selectedFilter = 'all'),
                child: const Text('Show all'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(Report r, double bottomPad) {
    final color = _statusColor(r.status);
    final canResolve = r.status == 'in-progress';
    final hasLocation = r.latitude != null && r. longitude != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius. circular(16)),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.12), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets. symmetric(vertical: 8),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_wasteIcon(r.type), color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r. type,
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(_statusLabel(r.status), style: GoogleFonts.poppins(fontSize: 10, color: color)),
                          const Spacer(),
                          Text(_timeAgo(r.date), style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500])),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, bottomPad + 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showTaskDetailSheet(r),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2AC2AB),
                      side: const BorderSide(color: Color(0xFF2AC2AB)),
                      minimumSize: const Size(0, 36),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Details', style: TextStyle(fontSize: 11)),
                  ),
                ),
                if (hasLocation) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton. icon(
                      onPressed: () => _navigateToLocation(r),
                      icon: const Icon(Icons.navigation_rounded, size: 14),
                      label: const Text('Go', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors. white,
                        minimumSize: const Size(0, 36),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
                if (canResolve) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showResolveSheet(r),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 36),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Resolve', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT (400-599px) ====================

  Widget _buildMobileLayout(List<Report> all, List<Report> filtered, double w, double h) {
    final bottomPad = MediaQuery. of(context).padding.bottom;
    final isLandscape = w > h;

    return Stack(
      children: [
        _buildMap(filtered),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: _buildMobileFilter(all),
        ),
        Positioned(
          top: 66,
          right: 10,
          child: _buildMobileControls(),
        ),
        if (! isLandscape && _selectedReport == null && _showLegend)
          Positioned(bottom: 12, left: 12, child: _buildLegend()),
        if (! isLandscape && _selectedReport == null && ! _showLegend)
          Positioned(bottom: 12, left: 12, child: _buildLegendToggle()),
        if (_selectedReport == null)
          Positioned(bottom: 12, right: 12, child: _buildMobileStats(filtered)),
        if (filtered.isEmpty) _buildMobileEmpty(),
        if (_selectedReport != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _cardSlideAnimation,
              child: _buildMobileCard(_selectedReport!, bottomPad),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileFilter(List<Report> all) {
    return Container(
      height: 50,
      padding: const EdgeInsets. all(5),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius. circular(14),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.08), blurRadius: 10)],
      ),
      child: Row(
        children: _filters.map((f) {
          final sel = _selectedFilter == f.value;
          final count = _getCount(all, f.value);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilter = f.value;
                  _selectedReport = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: sel ? f.color. withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment. center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: f.color, shape: BoxShape. circle),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          '${f.label} ($count)',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                            color: sel ? f.color : Colors. grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.1), blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconBtn(Icons.add_rounded, 38, () {
            _mapController.move(_mapController.camera.center,
                (_mapController.camera.zoom + 1).clamp(5.0, 19.0));
          }),
          _divider(34),
          _iconBtn(Icons.remove_rounded, 38, () {
            _mapController.move(_mapController.camera.center,
                (_mapController.camera.zoom - 1).clamp(5.0, 19.0));
          }),
          _divider(34),
          _iconBtn(
            _mapType == 'street' ? Icons.satellite_alt_rounded : Icons.map_rounded,
            38,
                () => setState(() => _mapType = _mapType == 'street' ?  'satellite' : 'street'),
          ),
          _divider(34),
          _iconBtn(Icons.my_location_rounded, 38, () {
            _mapController. move(_defaultCenter, _defaultZoom);
          }),
        ],
      ),
    );
  }

  Widget _buildLegendToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showLegend = true),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white. withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.08), blurRadius: 6)],
        ),
        child: Icon(Icons.info_outline_rounded, size: 18, color: Colors. grey[600]),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors. white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.08), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize. min,
            children: [
              Text('Legend', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700])),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _showLegend = false),
                child: Icon(Icons.close, size: 14, color: Colors. grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _legendItem('Pending', Colors.orange),
          _legendItem('Active', Colors.blue),
          _legendItem('Done', Colors.green),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMobileStats(List<Report> reports) {
    final pending = reports.where((r) => r. status == 'pending').length;
    final active = reports. where((r) => r.status == 'in-progress').length;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors. white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons. assignment_rounded, size: 14, color: Color(0xFF2AC2AB)),
              const SizedBox(width: 4),
              Text(
                '${reports.length} Tasks',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$pending pending • $active active',
            style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileEmpty() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets. all(20),
        decoration: BoxDecoration(
          color: Colors. white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.1), blurRadius: 12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange. withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.assignment_outlined, size: 36, color: Colors. orange),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'all' ? 'No tasks available' : 'No ${_selectedFilter} tasks',
              style: GoogleFonts. poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text('Tasks with GPS location will appear here', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            if (_selectedFilter != 'all') ...[
              const SizedBox(height: 12),
              TextButton. icon(
                onPressed: () => setState(() => _selectedFilter = 'all'),
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Show all'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2AC2AB)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCard(Report r, double bottomPad) {
    final color = _statusColor(r.status);
    final canResolve = r.status == 'in-progress';
    final hasLocation = r.latitude != null && r.longitude != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius. circular(20)),
        boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.15), blurRadius: 15)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets. symmetric(vertical: 10),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumb(r, color, 56),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfo(r, color)),
                  ],
                ),
                const SizedBox(height: 12),
                if (hasLocation) _buildCoords(r),
                const SizedBox(height: 12),
                _buildMobileActions(r, canResolve, hasLocation),
              ],
            ),
          ),
          SizedBox(height: bottomPad),
        ],
      ),
    );
  }

  Widget _buildThumb(Report r, Color color, double size) {
    if (r.imageUrl != null && r.imageUrl! .isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          r.imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildIconThumb(r, color, size),
        ),
      );
    }
    return _buildIconThumb(r, color, size);
  }

  Widget _buildIconThumb(Report r, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color. withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_wasteIcon(r.type), color: color, size: size * 0.5),
    );
  }

  Widget _buildInfo(Report r, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                r. type,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color. withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(_statusLabel(r.status), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight. w600, color: color)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.location_on_rounded, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                r.location,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.person_rounded, size: 12, color: Colors. grey[500]),
            const SizedBox(width: 4),
            Text(r.userName, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
            const Spacer(),
            Icon(Icons.access_time_rounded, size: 10, color: Colors. grey[400]),
            const SizedBox(width: 2),
            Text(_timeAgo(r.date), style: GoogleFonts. poppins(fontSize: 10, color: Colors. grey[400])),
          ],
        ),
      ],
    );
  }

  Widget _buildCoords(Report r) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF2AC2AB). withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2AC2AB). withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gps_fixed_rounded, size: 16, color: Color(0xFF2AC2AB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${r.latitude! .toStringAsFixed(6)}, ${r.longitude!.toStringAsFixed(6)}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors. grey[700]),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: '${r.latitude},${r.longitude}'));
              _showSnackBar('Coordinates copied! ');
            },
            child: Container(
              padding: const EdgeInsets. all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF2AC2AB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.copy_rounded, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActions(Report r, bool canResolve, bool hasLocation) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton. icon(
                onPressed: () => _selectReport(null),
                icon: const Icon(Icons. close_rounded, size: 16),
                label: const Text('Close'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey. withOpacity(0.3)),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showTaskDetailSheet(r),
                icon: const Icon(Icons. info_outline_rounded, size: 16),
                label: const Text('Details'),
                style: ElevatedButton. styleFrom(
                  backgroundColor: const Color(0xFF2AC2AB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (hasLocation)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToLocation(r),
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(10)),
                  ),
                ),
              ),
            if (hasLocation && canResolve) const SizedBox(width: 10),
            if (canResolve)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showResolveSheet(r),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text('Resolve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors. white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ==================== TABLET LAYOUT (600-899px) ====================

  Widget _buildTabletLayout(List<Report> all, List<Report> filtered, double w, double h) {
    final isLandscape = w > h;

    if (isLandscape) {
      return Row(
        children: [
          Container(
            width: math.min(w * 0.35, 320),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _buildSideHeader(all, filtered),
                _buildSideFilters(all),
                Expanded(child: _buildSideList(filtered)),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _buildMap(filtered),
                Positioned(top: 12, right: 12, child: _buildMobileControls()),
                if (filtered.isEmpty) _buildMobileEmpty(),
              ],
            ),
          ),
        ],
      );
    }

    return _buildMobileLayout(all, filtered, w, h);
  }

  // ==================== DESKTOP LAYOUT (900px+) ====================

  Widget _buildDesktopLayout(List<Report> all, List<Report> filtered, double w, double h) {
    final sideW = math.min(w * 0.3, 380.0);

    return Row(
      children: [
        Container(
          width: sideW,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              _buildSideHeader(all, filtered),
              _buildSideFilters(all),
              Expanded(child: _buildSideList(filtered)),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _buildMap(filtered),
              Positioned(top: 16, right: 16, child: _buildMobileControls()),
              Positioned(bottom: 16, left: 16, child: _buildLegend()),
              Positioned(bottom: 16, right: 16, child: _buildMobileStats(filtered)),
              if (filtered.isEmpty) _buildMobileEmpty(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSideHeader(List<Report> all, List<Report> filtered) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF2AC2AB), Color(0xFF1FA896)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'My Tasks',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight. bold, color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons. refresh_rounded, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${filtered.length} of ${all.length} tasks on map',
            style: GoogleFonts. poppins(fontSize: 12, color: Colors. white. withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildSideFilters(List<Report> all) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors. grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey. withOpacity(0.2))),
      ),
      child: Row(
        children: _filters.map((f) {
          final sel = _selectedFilter == f.value;
          final count = _getCount(all, f. value);
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedFilter = f.value;
                  _selectedReport = null;
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? f.color. withOpacity(0.15) : Colors.white,
                  borderRadius: BorderRadius. circular(8),
                  border: Border.all(color: sel ?  f.color : Colors.grey. withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      '$count',
                      style: GoogleFonts. poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: sel ? f.color : Colors.grey[700],
                      ),
                    ),
                    Text(
                      f.label,
                      style: GoogleFonts.poppins(fontSize: 10, color: sel ?  f.color : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSideList(List<Report> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons. assignment_outlined, size: 48, color: Colors. grey[400]),
            const SizedBox(height: 12),
            Text('No tasks found', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];
          final sel = _selectedReport?. id == r.id;
          final color = _statusColor(r.status);
          final canResolve = r.status == 'in-progress';
          final hasLocation = r. latitude != null && r.longitude != null;

          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: sel ?  color.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? color : Colors.grey. withOpacity(0.15), width: sel ? 2 : 1),
                boxShadow: [BoxShadow(color: Colors. black.withOpacity(0.03), blurRadius: 4)],
              ),
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _selectReport(sel ?  null : r);
                      },
                      borderRadius: BorderRadius. circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                        Row(
                        children: [
                        Container(
                        width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color. withOpacity(0.1),
                            borderRadius: BorderRadius. circular(10),
                          ),
                          child: Icon(_wasteIcon(r.type), color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r. type,
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow. ellipsis,
                              ),
                              Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                                  const SizedBox(width: 4),
                                  Text(_statusLabel(r. status), style: GoogleFonts.poppins(fontSize: 10, color: color)),
                                  const Spacer(),
                                  Text(_timeAgo(r.date), style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500])),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: Colors. grey[400], size: 20),
                        ],
                      ),
                      if (sel) ...[
                  const SizedBox(height: 12),
              Row(
                  children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showTaskDetailSheet(r),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2AC2AB),
                            side: const BorderSide(color: Color(0xFF2AC2AB)),
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Details', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      if (hasLocation) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton. icon(
                          onPressed: () => _navigateToLocation(r),
                          icon: const Icon(Icons.navigation_rounded, size: 14),
                          label: const Text('Go', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors. white,
                            minimumSize: const Size(0, 36),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                    if (canResolve) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showResolveSheet(r),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Resolve', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ],
              ),
                      ],
                          ],
                        ),
                      ),
                  ),
              ),
          );
        },
    );
  }

  // ==================== SHEET METHODS ====================

  void _showTaskDetailSheet(Report r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(
        report: r,
        onClose: () => Navigator.pop(context),
        onNavigate: () {
          Navigator.pop(context);
          _navigateToLocation(r);
        },
        onResolve: () {
          Navigator.pop(context);
          _showResolveSheet(r);
        },
        onAddLocation: () {
          Navigator.pop(context);
          _showAddLocationSheet(r);
        },
      ),
    );
  }

  void _showResolveSheet(Report r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ResolveSheet(
        report: r,
        onResolve: (imagePath, lat, lng, address, timestamp) async {
          Navigator.pop(context);

          // Show AI verification dialog
          _showAIVerificationDialog(r, imagePath, lat, lng, address, timestamp);
        },
      ),
    );
  }

  void _showAddLocationSheet(Report r) {
    // Only allow adding location if no location exists
    if (r.latitude != null && r.latitude != 0.0 && r. longitude != null && r.longitude != 0.0) {
      _showSnackBar('This task already has a location', isSuccess: false);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLocationSheet(
        report: r,
        onSave: (lat, lng, address) async {
          Navigator.pop(context);
          await widget.onUpdateStatus(
            r.id,
            r.status,
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
        afterImagePath: imagePath,
        latitude: lat,
        longitude: lng,
        address: address,
        timestamp: timestamp,
        onSuccess: () async {
          Navigator. pop(context);
          await widget.onUpdateStatus(
            report. id,
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
          Navigator.pop(context);
          _showResolveSheet(report);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize. min,
            children: [
              Container(
                padding: const EdgeInsets. all(16),
                decoration: BoxDecoration(
                  color: Colors.green. withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
              ),
              const SizedBox(height: 20),
              Text(
                'Task Completed! ',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 12),
              Text(
                'The cleanup has been verified and the task is now resolved.  The citizen has been notified.',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors. grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton. styleFrom(
                    backgroundColor: Colors. green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight. w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  Widget _iconBtn(IconData icon, double size, VoidCallback onTap) {
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
        color: const Color(0xFF2AC2AB),
      ),
    );
  }

  Widget _divider(double width) {
    return Container(height: 1, width: width * 0.7, color: Colors. grey[200]);
  }

  Color _statusColor(String status) {
    switch (status. toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'in-progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
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

  IconData _wasteIcon(String type) {
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

  String _timeAgo(DateTime date) {
    final diff = DateTime.now(). difference(date);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff. inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }

  void _showSnackBar(String msg, {bool isSuccess = true}) {
    if (! mounted) return;
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF2AC2AB) : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ==================== LOADING / ERROR / EMPTY ====================

  Widget _buildLoading(double w) {
    final size = w < 400 ? 40.0 : 50.0;
    return Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    SizedBox(
    width: size,
    height: size,
    child: const CircularProgressIndicator(color: Color(0xFF2AC2AB), strokeWidth: 3),
    ),
    const SizedBox(height: 16),
    Text('Loading tasks...', style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
    ],
    ),
    );
  }

  Widget _buildError(String error, double w) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons. error_outline_rounded, size: 48, color: Colors. red[400]),
            const SizedBox(height: 16),
            Text('Failed to load tasks', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight. w600)),
            const SizedBox(height: 8),
            Text(error, style: GoogleFonts.poppins(fontSize: 12, color: Colors. grey[600]), textAlign: TextAlign.center, maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton. icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2AC2AB),
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(double w) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment. center,
        children: [
          Icon(Icons.assignment_outlined, size: 56, color: Colors. grey[400]),
          const SizedBox(height: 16),
          Text('No tasks assigned', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text('Tasks will appear here when assigned', style: GoogleFonts.poppins(fontSize: 13, color: Colors. grey[500])),
        ],
      ),
    );
  }
}

// ==================== ENUMS & DATA CLASSES ====================

enum _Layout { micro, compact, mobile, tablet, desktop }

class _FilterData {
  final String value;
  final String label;
  final String short;
  final Color color;

  _FilterData(this.value, this.label, this. short, this.color);
}

class _PointerPainter extends CustomPainter {
  final Color color;

  _PointerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      .. lineTo(size. width, 0)
      ..close();

    canvas. drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== TASK DETAIL SHEET (FR-W4) ====================

class TaskDetailSheet extends StatelessWidget {
  final Report report;
  final VoidCallback onClose;
  final VoidCallback onNavigate;
  final VoidCallback onResolve;
  final VoidCallback onAddLocation;

  const TaskDetailSheet({
    super.key,
    required this.report,
    required this. onClose,
    required this.onNavigate,
    required this.onResolve,
    required this.onAddLocation,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size. height;
    final color = _statusColor(report.status);
    final canResolve = report.status == 'in-progress';
    final hasLocation = report. latitude != null && report.longitude != null &&
        report.latitude != 0.0 && report.longitude != 0.0;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.9),
      decoration: const BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius. vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius. circular(2)),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_wasteIcon(report.type), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Task Details', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('#${report.id}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded), color: Colors.grey[600]),
              ],
            ),
          ),

          const Divider(height: 24),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  // Waste Image
                  if (report.imageUrl != null && report.imageUrl! .isNotEmpty)
                    _buildSection(
                      'Waste Image',
                      Icons.image_rounded,
                      Colors.purple,
                      _buildImagePreview(report.imageUrl! ),
                    ),

                  // AI Classification Results
                  _buildSection(
                    'AI Classification',
                    Icons. smart_toy_rounded,
                    Colors.indigo,
                    _buildAIClassification(),
                  ),

                  // Status
                  _buildInfoRow('Status', _statusLabel(report. status), Icons.flag_rounded, color,
                      badge: _buildStatusBadge(report.status, color)),

                  // Waste Type
                  _buildInfoRow('Waste Type', report.type, _wasteIcon(report.type), Colors.purple),

                  // Description
                  if (report.description != null && report.description!.isNotEmpty)
                    _buildInfoRow('Description', report.description!, Icons.description_rounded, Colors.teal),

                  // Location
                  _buildInfoRow('Location Address', report.location, Icons.location_on_rounded, Colors.red),

                  // GPS Coordinates
                  _buildGPSSection(context, hasLocation),

                  // Reporter Info
                  _buildInfoRow('Reported By', report. userName, Icons.person_rounded, Colors.blue),

                  // Assignment Timestamps
                  _buildSection(
                    'Timestamps',
                    Icons.schedule_rounded,
                    Colors.orange,
                    _buildTimestamps(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Actions
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black. withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Column(
              children: [
                // Navigation & Location buttons
                Row(
                  children: [
                    if (hasLocation)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onNavigate,
                          icon: const Icon(Icons.navigation_rounded, size: 18),
                          label: const Text('Navigate'),
                          style: ElevatedButton. styleFrom(
                            backgroundColor: Colors. blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAddLocation,
                          icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                          label: const Text('Add Location'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors. white,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                  ],
                ),
                if (canResolve) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double. infinity,
                    child: ElevatedButton.icon(
                      onPressed: onResolve,
                      icon: const Icon(Icons. check_circle_rounded, size: 18),
                      label: const Text('Mark as Completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color. withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts. poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800])),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildImagePreview(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 180,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons. broken_image_rounded, size: 48, color: Colors. grey)),
        ),
      ),
    );
  }

  Widget _buildAIClassification() {
    // Mock AI classification data - replace with actual data
    final categories = [
      {'name': 'Plastic', 'percentage': 65, 'color': Colors.blue},
      {'name': 'Paper', 'percentage': 20, 'color': Colors.brown},
      {'name': 'Organic', 'percentage': 10, 'color': Colors.green},
      {'name': 'Other', 'percentage': 5, 'color': Colors.grey},
    ];

    return Container(
      padding: const EdgeInsets. all(14),
      decoration: BoxDecoration(
        color: Colors. grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey. withOpacity(0.15)),
      ),
      child: Column(
        children: [
          ... categories.map((cat) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cat['color'] as Color,
                    borderRadius: BorderRadius. circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(cat['name'] as String, style: GoogleFonts. poppins(fontSize: 12)),
                ),
                SizedBox(
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (cat['percentage'] as int) / 100,
                      backgroundColor: Colors.grey[200],
                      color: cat['color'] as Color,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${cat['percentage']}%',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )),
          const Divider(),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: Colors. grey[500]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Classification confidence: 94%',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color, {Widget? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets. all(12),
      decoration: BoxDecoration(
        color: Colors. grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors. grey.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color. withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts. poppins(fontSize: 13, fontWeight: FontWeight. w500, color: Colors. grey[800])),
              ],
            ),
          ),
          if (badge != null) badge,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color. withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(_statusLabel(status), style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight. w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildGPSSection(BuildContext context, bool hasLocation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasLocation ? const Color(0xFF2AC2AB). withOpacity(0.05) : Colors.orange. withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLocation ? const Color(0xFF2AC2AB).withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets. all(8),
            decoration: BoxDecoration(
              color: hasLocation ? const Color(0xFF2AC2AB).withOpacity(0.1) : Colors.orange. withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasLocation ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
              color: hasLocation ? const Color(0xFF2AC2AB) : Colors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GPS Coordinates', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
                Text(
                  hasLocation
                      ? '${report.latitude! . toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}'
                      : 'No GPS location - tap "Add Location" to set',
                  style: GoogleFonts. poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: hasLocation ? Colors.grey[800] : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          if (hasLocation)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: '${report.latitude},${report.longitude}'));
                ScaffoldMessenger. of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Coordinates copied! '),
                    backgroundColor: const Color(0xFF2AC2AB),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: const Color(0xFF2AC2AB), borderRadius: BorderRadius. circular(6)),
                child: const Icon(Icons.copy_rounded, size: 14, color: Colors. white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimestamps() {
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors. grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey. withOpacity(0.15)),
        ),
        child: Column(
            children: [
            _timestampRow('Reported', report.date, Icons.flag_outlined, Colors.orange),
        const Divider(height: 16),
        _timestampRow('Assigned', report.assignedAt ??  report.date, Icons. assignment_ind_outlined, Colors. blue),
        if (report.status == 'resolved' && report.resolvedAt != null) ...[
    const Divider(height: 16),
    _timestampRow('Completed', report.resolvedAt!, Icons.check_circle_outline, Colors.green),
    ],
    ],
    ),
    );
  }

  Widget _timestampRow(String label, DateTime date, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
        const Spacer(),
        Text(
          _formatDateTime(date),
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour. toString().padLeft(2, '0')}:${dt. minute.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String s) {
    switch (s. toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'in-progress': return Colors.blue;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'resolved': return 'Completed';
      case 'in-progress': return 'Assigned';
      case 'pending': return 'Pending';
      default: return s;
    }
  }

  IconData _wasteIcon(String t) {
    final l = t.toLowerCase();
    if (l.contains('plastic')) return Icons.local_drink_rounded;
    if (l.contains('organic')) return Icons.eco_rounded;
    if (l.contains('electronic')) return Icons.devices_rounded;
    if (l.contains('hazardous')) return Icons.warning_amber_rounded;
    if (l.contains('glass')) return Icons.wine_bar_rounded;
    if (l.contains('paper')) return Icons.description_rounded;
    if (l.contains('metal')) return Icons.recycling_rounded;
    return Icons.delete_rounded;
  }
}

// ==================== RESOLVE SHEET (FR-W5) ====================

class ResolveSheet extends StatefulWidget {
  final Report report;
  final Function(String imagePath, double lat, double lng, String address, DateTime timestamp) onResolve;

  const ResolveSheet({
    super.key,
    required this.report,
    required this. onResolve,
  });

  @override
  State<ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends State<ResolveSheet> {
  final ImagePicker _picker = ImagePicker();

  File? _afterImage;
  Position? _position;
  String? _address;
  bool _isLoadingLocation = false;
  String? _locationError;
  DateTime? _captureTime;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please enable GPS');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      String addr = 'Unknown location';
      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks. isNotEmpty) {
          final p = placemarks. first;
          addr = [p.street, p.subLocality, p.locality, p.administrativeArea]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _position = pos;
          _address = addr;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString(). replaceAll('Exception: ', '');
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? img = await _picker. pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (img != null && mounted) {
        setState(() {
          _afterImage = File(img.path);
          _captureTime = DateTime.now();
        });

        if (_position == null) {
          _captureLocation();
        }
      }
    } catch (e) {
      _showError('Failed to capture image');
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors. white,
          borderRadius: BorderRadius. vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets. only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Text('Capture Cleanup Image', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _sourceBtn(Icons.camera_alt_rounded, 'Camera', const Color(0xFF2AC2AB), () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _sourceBtn(Icons.photo_library_rounded, 'Gallery', Colors.blue, () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sourceBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color. withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts. poppins(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_afterImage == null) {
      _showError('Please capture an after-cleanup image');
      return;
    }

    if (_position == null) {
      _showError('GPS location not captured.  Please try again.');
      return;
    }

    HapticFeedback.mediumImpact();
    widget.onResolve(
      _afterImage!.path,
      _position!.latitude,
      _position!. longitude,
      _address ??  'Unknown location',
      _captureTime ?? DateTime.now(),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  bool _canSubmit() {
    return _afterImage != null && _position != null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size. height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.9),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons. check_circle_outline_rounded, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Complete Task', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(widget.report.type, style: GoogleFonts.poppins(fontSize: 12, color: Colors. grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), color: Colors.grey[600]),
              ],
            ),
          ),

          const Divider(height: 24),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Before/After comparison
                  Text('Before & After Comparison', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _imageCard('Before', widget.report.imageUrl, null, false)),
                      const SizedBox(width: 12),
                      Expanded(child: _imageCard('After', null, _afterImage, true, onTap: _showImagePicker)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // GPS Location (auto-captured)
                  _buildGPSCard(),

                  const SizedBox(height: 16),

                  // Timestamp
                  if (_captureTime != null) _buildTimestampCard(),

                  const SizedBox(height: 16),

                  // Info banner
                  _buildInfoBanner(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Submit button
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton. styleFrom(
                      foregroundColor: Colors. grey[700],
                      side: BorderSide(color: Colors.grey. withOpacity(0.3)),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton. icon(
                    onPressed: _canSubmit() ? _submit : null,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Submit for Verification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors. white,
                      disabledBackgroundColor: Colors.grey[300],
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageCard(String label, String?  url, File? file, bool isAfter, {VoidCallback? onTap}) {
    final hasImage = url != null || file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: isAfter ? Colors. green : Colors.orange, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts. poppins(fontSize: 12, fontWeight: FontWeight. w600, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isAfter ? onTap : null,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAfter ? (hasImage ? Colors.green : const Color(0xFF2AC2AB)) : Colors.grey.withOpacity(0.3),
                width: isAfter && ! hasImage ? 2 : 1,
              ),
              image: hasImage
                  ? DecorationImage(
                image: file != null ? FileImage(file) : NetworkImage(url!) as ImageProvider,
                fit: BoxFit. cover,
              )
                  : null,
            ),
            child: ! hasImage
                ?  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isAfter ? Icons. add_a_photo_rounded : Icons.image_not_supported_rounded, size: 28, color: isAfter ? const Color(0xFF2AC2AB) : Colors.grey[400]),
                  const SizedBox(height: 6),
                  Text(isAfter ? 'Tap to capture' : 'No image', style: GoogleFonts.poppins(fontSize: 10, color: isAfter ? const Color(0xFF2AC2AB) : Colors.grey[500])),
                ],
              ),
            )
                : isAfter
                ?  Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.check_rounded, size: 12, color: Colors. white),
              ),
            )
                : null,
          ),
        ),
        if (isAfter && _afterImage != null) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, size: 12, color: Colors. grey[600]),
                const SizedBox(width: 4),
                Text('Retake', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGPSCard() {
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _locationError != null ? Colors.red. withOpacity(0.05) : const Color(0xFF2AC2AB). withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _locationError != null ? Colors.red. withOpacity(0.2) : const Color(0xFF2AC2AB).withOpacity(0.2)),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Row(
        children: [
        Icon(Icons.gps_fixed_rounded, size: 18, color: _locationError != null ? Colors.red : const Color(0xFF2AC2AB)),
        const SizedBox(width: 8),
        Text('GPS Location (Auto-captured)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800])),
        const Spacer(),
        if (_isLoadingLocation)
    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2AC2AB)))
    else if (_position != null)
    const Icon(Icons.check_circle_rounded, size: 18, color: Colors. green)
    else if (_locationError != null)
    GestureDetector(
    onTap: _captureLocation,
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
    child: Text('Retry', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
    ),
    ),
    ],
    ),
    const SizedBox(height: 10),
    if (_isLoadingLocation)
    Text('Capturing your location... ', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]))
    else if (_locationError != null)
    Text(_locationError!, style: GoogleFonts.poppins(fontSize: 12, color: Colors. red))
    else if (_position != null) ...[
    Row(
    children: [
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text('Coordinates', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
    Text(
    '${_position!. latitude.toStringAsFixed(6)}, ${_position! .longitude.toStringAsFixed(6)}',
    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight. w500),
    ),
    ],
    ),
    ),
    Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.green. withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
    child: Text('±${_position!. accuracy.toStringAsFixed(0)}m', style: GoogleFonts. poppins(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
    ),
    ],
    ),
    if (_address != null) ...[
    const SizedBox(height: 8),
    Text('Address', style: GoogleFonts. poppins(fontSize: 10, color: Colors.grey[500])),
    Text(_address!, style: GoogleFonts.poppins(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
    ],
    ],
    ],
    ),
    );
  }

  Widget _buildTimestampCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue. withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Completion Timestamp', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight. w600, color: Colors.grey[800])),
                Text(_formatTime(_captureTime!), style: GoogleFonts.poppins(fontSize: 11, color: Colors. grey[600])),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors. amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.smart_toy_rounded, size: 20, color: Colors. amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Verification', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors. amber. shade800)),
                const SizedBox(height: 4),
                Text(
                  'Your cleanup image will be analyzed by AI.  If remaining waste is detected above threshold, you\'ll be asked to complete the cleanup and resubmit.',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.amber.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour. toString().padLeft(2, '0')}:${dt. minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}

// ==================== ADD LOCATION SHEET ====================

class AddLocationSheet extends StatefulWidget {
  final Report report;
  final Function(double lat, double lng, String address) onSave;

  const AddLocationSheet({
    super.key,
    required this. report,
    required this.onSave,
  });

  @override
  State<AddLocationSheet> createState() => _AddLocationSheetState();
}

class _AddLocationSheetState extends State<AddLocationSheet> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  bool _isLoadingGPS = false;
  bool _useMap = false;
  String? _error;

  // For map selection
  LatLng? _selectedMapLocation;
  late MapController _mapController;

  @override
  void initState() {
    super. initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _streetController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _captureCurrentLocation() async {
    setState(() {
      _isLoadingGPS = true;
      _error = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (! serviceEnabled) {
        throw Exception('Please enable GPS');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _latController.text = pos.latitude.toStringAsFixed(6);
          _lngController.text = pos.longitude.toStringAsFixed(6);
          _selectedMapLocation = LatLng(pos. latitude, pos.longitude);
          _isLoadingGPS = false;
        });

        // Try to get address
        try {
          final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
          if (placemarks.isNotEmpty && mounted) {
            final p = placemarks.first;
            setState(() {
              _streetController.text = p.street ?? '';
              _areaController.text = p. subLocality ?? p.locality ?? '';
              _cityController.text = p. administrativeArea ?? '';
            });
          }
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString(). replaceAll('Exception: ', '');
          _isLoadingGPS = false;
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedMapLocation = point;
      _latController.text = point.latitude.toStringAsFixed(6);
      _lngController.text = point.longitude.toStringAsFixed(6);
      _error = null;
    });

    // Try to get address for selected point
    _getAddressFromCoordinates(point. latitude, point.longitude);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks. first;
        setState(() {
          _streetController.text = p.street ?? '';
          _areaController.text = p.subLocality ??  p.locality ?? '';
          _cityController.text = p. administrativeArea ?? '';
        });
      }
    } catch (_) {}
  }

  void _save() {
    final lat = double.tryParse(_latController.text. trim());
    final lng = double.tryParse(_lngController. text.trim());

    if (lat == null || lng == null) {
      setState(() => _error = 'Please enter valid coordinates or select on map');
      return;
    }

    if (lat. abs() > 90) {
      setState(() => _error = 'Latitude must be between -90 and 90');
      return;
    }

    if (lng.abs() > 180) {
      setState(() => _error = 'Longitude must be between -180 and 180');
      return;
    }

    // Build address string
    final addressParts = [
      _streetController.text. trim(),
      _areaController.text.trim(),
      _cityController.text.trim(),
    ].where((s) => s.isNotEmpty).toList();

    String address = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Location: ${lat. toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

    HapticFeedback.mediumImpact();
    widget.onSave(lat, lng, address);
  }

  bool _canSave() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController. text.trim());
    return lat != null && lng != null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size. height;

    return Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.9),
        decoration: const BoxDecoration(
            color: Colors. white,
          borderRadius: BorderRadius. vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Handle
          Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        ),

        // Header
        Padding(
          padding: const EdgeInsets. symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange. withOpacity(0.1),
                  borderRadius: BorderRadius. circular(12),
                ),
                child: const Icon(Icons.add_location_alt_rounded, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Location', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Set GPS coordinates for this task', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), color: Colors.grey[600]),
            ],
          ),
        ),

        const Divider(height: 24),

        // Content
        Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment. start,
                  children: [
              // Task info
              Container(
              padding: const EdgeInsets. all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius. circular(12),
                border: Border.all(color: Colors. grey. withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2AC2AB). withOpacity(0.1),
                      borderRadius: BorderRadius. circular(8),
                    ),
                    child: const Icon(Icons.assignment_rounded, color: Color(0xFF2AC2AB), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment. start,
                      children: [
                        Text(widget.report.type, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('ID: #${widget.report. id}', style: GoogleFonts. poppins(fontSize: 11, color: Colors. grey[500])),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Method selection
            Text('Select Location Method', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800])),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _methodCard(
                    'GPS',
                    Icons.gps_fixed_rounded,
                    'Use current location',
                    ! _useMap,
                        () => setState(() => _useMap = false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _methodCard(
                    'Map',
                    Icons. map_rounded,
                    'Select on map',
                    _useMap,
                        () => setState(() => _useMap = true),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // GPS capture or Map selection
            if (_useMap)
        _buildMapSelector()
    else
    _buildGPSCapture(),

    const SizedBox(height: 20),

    // Manual coordinates input
    Text('Coordinates', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800])),
    const SizedBox(height: 12),
    Row(
    children: [
    Expanded(child: _textField(_latController, 'Latitude', 'e.g., 31.7167', Icons.north_rounded)),
    const SizedBox(width: 12),
    Expanded(child: _textField(_lngController, 'Longitude', 'e.g., 73.9850', Icons.east_rounded)),
    ],
    ),

    const SizedBox(height: 20),

    // Address fields
    Text('Address Details', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors. grey[800])),
    const SizedBox(height: 12),
    _textField(_streetController, 'Street/Road', 'Enter street name or number', Icons.signpost_rounded, isNumeric: false),
    const SizedBox(height: 12),
    Row(
    children: [
    Expanded(child: _textField(_areaController, 'Area/Locality', 'Enter area name', Icons.location_city_rounded, isNumeric: false)),
    const SizedBox(width: 12),
    Expanded(child: _textField(_cityController, 'City', 'Enter city', Icons.apartment_rounded, isNumeric: false)),
    ],
    ),

    // Error message
    if (_error != null) ...[
    const SizedBox(height: 12),
    Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.red. withOpacity(0.1),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors. red. withOpacity(0.3)),
    ),
    child: Row(
    children: [
    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
    const SizedBox(width: 10),
    Expanded(child: Text(_error!, style: GoogleFonts.poppins(fontSize: 12, color: Colors. red))),
    GestureDetector(
    onTap: () => setState(() => _error = null),
    child: const Icon(Icons.close_rounded, color: Colors. red, size: 18),
    ),
    ],
    ),
    ),
    ],

    const SizedBox(height: 16),

    // Tip
    Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.05),
    borderRadius: BorderRadius. circular(10),
    border: Border.all(color: Colors. blue.withOpacity(0.2)),
    ),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Icon(Icons.lightbulb_outline_rounded, size: 18, color: Colors. blue[600]),
    const SizedBox(width: 10),
    Expanded(
    child: Text(
    'Tip: You can get coordinates from Google Maps by long-pressing on a location and copying the coordinates.',
    style: GoogleFonts.poppins(fontSize: 11, color: Colors. blue[700]),
    ),
    ),
    ],
    ),
    ),

    const SizedBox(height: 20),
    ],
    ),
    ),
    ),

    // Actions
    Container(
    padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
    decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
    ),
    child: Row(
    children: [
    Expanded(
    child: OutlinedButton(
    onPressed: () => Navigator.pop(context),
    style: OutlinedButton.styleFrom(
    foregroundColor: Colors. grey[700],
    side: BorderSide(color: Colors.grey. withOpacity(0.3)),
    minimumSize: const Size(0, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: const Text('Cancel'),
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    flex: 2,
    child: ElevatedButton. icon(
    onPressed: _canSave() ? _save : null,
    icon: const Icon(Icons.save_rounded, size: 18),
    label: const Text('Save Location'),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors. white,
    disabledBackgroundColor: Colors.grey[300],
    minimumSize: const Size(0, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    );
  }

  Widget _methodCard(String title, IconData icon, String subtitle, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets. all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2AC2AB). withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2AC2AB) : Colors.grey. withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: isSelected ? const Color(0xFF2AC2AB) : Colors.grey[600]),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF2AC2AB) : Colors.grey[800])),
            Text(subtitle, style: GoogleFonts. poppins(fontSize: 10, color: Colors.grey[500]), textAlign: TextAlign. center),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSCapture() {
    return GestureDetector(
      onTap: _isLoadingGPS ?  null : _captureCurrentLocation,
      child: Container(
        padding: const EdgeInsets. all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2AC2AB), Color(0xFF1FA896)]),
          borderRadius: BorderRadius. circular(12),
          boxShadow: [
            BoxShadow(color: const Color(0xFF2AC2AB).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
            if (_isLoadingGPS)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            else
              const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(
              _isLoadingGPS ? 'Getting Location...' : 'Capture Current GPS Location',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSelector() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius. circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedMapLocation ??  const LatLng(31.7167, 73.9850),
              initialZoom: 14,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.neatnow.app',
              ),
              if (_selectedMapLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedMapLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
            ],
          ),
          // Instructions overlay
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white. withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 16, color: Colors. grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedMapLocation != null ?  'Tap to change location' : 'Tap on map to select location',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors. grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, String hint, IconData icon, {bool isNumeric = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors. grey[600])),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
          style: GoogleFonts.poppins(fontSize: 14),
          onChanged: (_) => setState(() => _error = null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors. grey[400]),
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors. grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2AC2AB), width: 2),
            ),
            filled: true,
            fillColor: Colors. grey[50],
          ),
        ),
      ],
    );
  }
}

// ==================== AI VERIFICATION DIALOG (FR-W5) ====================

class AIVerificationDialog extends StatefulWidget {
  final Report report;
  final String afterImagePath;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final VoidCallback onSuccess;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const AIVerificationDialog({
    super.key,
    required this. report,
    required this.afterImagePath,
    required this.latitude,
    required this.longitude,
    required this. address,
    required this.timestamp,
    required this.onSuccess,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  State<AIVerificationDialog> createState() => _AIVerificationDialogState();
}

class _AIVerificationDialogState extends State<AIVerificationDialog> with TickerProviderStateMixin {
  bool _isVerifying = true;
  bool?  _isVerified;
  int _cleanlinessScore = 0;
  int _threshold = 85;
  List<String> _detectedIssues = [];
  int _currentStep = 0;

  final List<String> _verificationSteps = [
    'Uploading cleanup image.. .',
    'Capturing GPS location...',
    'Analyzing before image...',
    'Analyzing after image...',
    'Comparing cleanliness...',
    'Generating report...',
  ];

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  Future<void> _startVerification() async {
    // Simulate AI verification process
    for (int i = 0; i < _verificationSteps. length; i++) {
      await Future. delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _currentStep = i + 1);
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate AI result (80% success rate for demo)
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final isClean = random < 80;

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _isVerified = isClean;
        _cleanlinessScore = isClean ? 85 + (random % 15) : 40 + (random % 40);
        if (! isClean) {
          _detectedIssues = [
            'Remaining debris detected in corner',
            'Small waste particles visible',
          ];
        }
      });
    }

    // Auto-proceed on success after short delay
    if (isClean) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        widget.onSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: _isVerifying ?  _buildVerifyingContent() : _buildResultContent(),
      ),
    );
  }

  Widget _buildVerifyingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated icon
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _currentStep / _verificationSteps.length,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF2AC2AB),
                ),
              ),
              Icon(Icons.smart_toy_rounded, size: 36, color: Colors. grey[600]),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'AI Verification',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Analyzing your cleanup...',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        // Progress steps
        ... List.generate(_verificationSteps. length, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep - 1;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : (isCurrent ? const Color(0xFF2AC2AB) : Colors.grey[300]),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors. white)
                      : isCurrent
                      ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _verificationSteps[index],
                    style: GoogleFonts. poppins(
                      fontSize: 12,
                      color: isCompleted ?  Colors.green : (isCurrent ? const Color(0xFF2AC2AB) : Colors.grey[500]),
                      fontWeight: isCurrent ? FontWeight. w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onCancel,
          child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[600])),
        ),
      ],
    );
  }

  Widget _buildResultContent() {
    if (_isVerified == true) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets. all(16),
            decoration: BoxDecoration(
              color: Colors.green. withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 56),
          ),
          const SizedBox(height: 20),
          Text('Cleanup Verified!', style: GoogleFonts. poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 12),
          Text(
            'Great job! The AI has verified that the area is clean.',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors. grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Score display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _scoreItem('Cleanliness', '$_cleanlinessScore%', Colors.green),
                Container(width: 1, height: 40, color: Colors. grey[300]),
                _scoreItem('Threshold', '≥$_threshold%', Colors.blue),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Completing task...', style: GoogleFonts.poppins(fontSize: 12, color: Colors. grey[500])),
        ],
      );
    } else {
      return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
      Container(
      padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.orange.withOpacity(0.1),
    shape: BoxShape.circle,
    ),
    child: const Icon(Icons.warning_rounded, color: Colors. orange, size: 56),
    ),
    const SizedBox(height: 20),
    Text('Cleanup Incomplete', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
    const SizedBox(height: 12),
    Text(
    'The AI detected remaining waste.  Please complete the cleanup and try again.',
    style: GoogleFonts.poppins(fontSize: 13, color: Colors. grey[600]),
    textAlign: TextAlign.center,
    ),
    const SizedBox(height: 16),
    // Score display
    Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors. orange.withOpacity(0.05),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors. orange.withOpacity(0.2)),
    ),
    child: Column(
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text('Cleanliness Score:', style: GoogleFonts.poppins(fontSize: 13)),
    Text('$_cleanlinessScore%', style: GoogleFonts. poppins(fontSize: 16, fontWeight: FontWeight. bold, color: Colors.orange)),
    ],
    ),
    const SizedBox(height: 8),
    Row(
    mainAxisAlignment: MainAxisAlignment. spaceBetween,
    children: [
    Text('Required:', style: GoogleFonts.poppins(fontSize: 13)),
    Text('≥$_threshold%', style: GoogleFonts. poppins(fontSize: 16, fontWeight: FontWeight. bold, color: Colors.green)),
    ],
    ),
    if (_detectedIssues.isNotEmpty) ...[
    const Divider(height: 20),
    Align(
    alignment: Alignment.centerLeft,
    child: Text('Issues detected:', style: GoogleFonts.poppins(fontSize: 11, color: Colors. grey[600])),
    ),
    const SizedBox(height: 6),
    ..._detectedIssues.map((issue) => Padding(
    padding: const EdgeInsets.only(left: 8, top: 4),
    child: Row(
    children: [
    const Icon(Icons.fiber_manual_record, size: 6, color: Colors. orange),
    const SizedBox(width: 8),
    Expanded(child: Text(issue, style: GoogleFonts.poppins(fontSize: 11))),
    ],
    ),
    )),
    ],
    ],
    ),
    ),
    const SizedBox(height: 24),
    Row(
    children: [
    Expanded(
    child: OutlinedButton(
    onPressed: widget.onCancel,
    style: OutlinedButton.styleFrom(
    foregroundColor: Colors. grey[700],
    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: const Text('Cancel'),
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    flex: 2,
    child: ElevatedButton.icon(
    onPressed: widget.onRetry,
    icon: const Icon(Icons.camera_alt_rounded, size: 18),
    label: const Text('Retake Photo'),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    ),
    ),
    ],
    ),
    ],
    );
    }
    }

  Widget _scoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts. poppins(fontSize: 11, color: Colors. grey[600])),
      ],
    );
  }







  // ==================== NAVIGATION ====================

  Future<void> _navigateToLocation(Report report) async {
    if (report.latitude == null || report.longitude == null) {
      _showSnackBar('No GPS coordinates available', isSuccess: false);
      return;
    }

    final lat = report.latitude!;
    final lng = report.longitude!;
    final label = Uri.encodeComponent(report.location);

    _showSnackBar('Opening navigation...');

    bool launched = false;

    try {
      // 1. Google Maps Navigation (Android)
      final googleNavUrl = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
      if (await canLaunchUrl(googleNavUrl)) {
        launched = await launchUrl(googleNavUrl);
        if (launched) return;
      }

      // 2. Google Maps Directions
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      );
      if (await canLaunchUrl(googleMapsUrl)) {
        launched = await launchUrl(
          googleMapsUrl,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      }

      // 3. Apple Maps
      final appleMapsUrl = Uri.parse('maps://maps.apple.com/?daddr=$lat,$lng&dirflg=d');
      if (await canLaunchUrl(appleMapsUrl)) {
        launched = await launchUrl(appleMapsUrl);
        if (launched) return;
      }

      // 4. Geo Fallback (Android)
      final geoUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
      if (await canLaunchUrl(geoUrl)) {
        launched = await launchUrl(geoUrl);
        if (launched) return;
      }

      // 5. Browser fallback
      final browserUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
      launched = await launchUrl(
        browserUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showNavigationOptionsDialog(report);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      _showNavigationOptionsDialog(report);
    }
  }

  // ==================== SHOW OPTIONS BOTTOM SHEET ====================

  void _showNavigationOptionsDialog(Report report) {
    if (report.latitude == null || report.longitude == null) return;

    final lat = report.latitude!;
    final lng = report.longitude!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Navigation Options',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how to navigate to this location',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              _buildNavOption(
                ctx,
                'Open in Google Maps',
                Icons.map_rounded,
                Colors.green,
                    () async {
                  Navigator.pop(ctx);
                  final url = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
                  );
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              ),

              const SizedBox(height: 12),

              _buildNavOption(
                ctx,
                'Copy Coordinates',
                Icons.copy_rounded,
                Colors.blue,
                    () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: '$lat,$lng'));
                  _showSnackBar('Coordinates copied: $lat, $lng');
                },
              ),

              const SizedBox(height: 12),

              _buildNavOption(
                ctx,
                'View on Google Maps',
                Icons.location_on_rounded,
                Colors.red,
                    () async {
                  Navigator.pop(ctx);
                  final url = Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                  );
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                },
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== OPTION WIDGET ====================

  Widget _buildNavOption(
      BuildContext ctx,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ==================== SNACKBAR ====================

  void _showSnackBar(String msg, {bool isSuccess = true}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? const Color(0xFF2AC2AB) : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}


