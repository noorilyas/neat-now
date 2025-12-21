import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class AddLocationSheet extends StatefulWidget {
  final Report report;
  final MapTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final Function(double lat, double lng, String address) onSave;

  const AddLocationSheet({
    super.key,
    required this. report,
    required this.viewModel,
    required this.responsive,
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
  String?  _error;

  LatLng?  _selectedMapLocation;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
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
        permission = await Geolocator. requestPermission();
        if (permission == LocationPermission. denied) {
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

      final pos = await Geolocator. getCurrentPosition(
        desiredAccuracy: LocationAccuracy. high,
        timeLimit: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _latController.text = pos.latitude. toStringAsFixed(6);
          _lngController. text = pos.longitude.toStringAsFixed(6);
          _selectedMapLocation = LatLng(pos.latitude, pos.longitude);
          _isLoadingGPS = false;
        });

        // Try to get address
        try {
          final placemarks = await placemarkFromCoordinates(
            pos.latitude,
            pos.longitude,
          );
          if (placemarks.isNotEmpty && mounted) {
            final p = placemarks.first;
            setState(() {
              _streetController.text = p.street ??  '';
              _areaController. text = p.subLocality ?? p.locality ?? '';
              _cityController. text = p.administrativeArea ?? '';
            });
          }
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoadingGPS = false;
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedMapLocation = point;
      _latController.text = point.latitude. toStringAsFixed(6);
      _lngController.text = point.longitude.toStringAsFixed(6);
      _error = null;
    });

    _getAddressFromCoordinates(point. latitude, point.longitude);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks. isNotEmpty && mounted) {
        final p = placemarks. first;
        setState(() {
          _streetController.text = p.street ?? '';
          _areaController.text = p.subLocality ?? p.locality ?? '';
          _cityController.text = p.administrativeArea ?? '';
        });
      }
    } catch (_) {}
  }

  void _save() {
    final lat = double.tryParse(_latController.text. trim());
    final lng = double.tryParse(_lngController.text.trim());

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

    final addressParts = [
      _streetController.text.trim(),
      _areaController.text. trim(),
      _cityController. text.trim(),
    ].where((s) => s.isNotEmpty).toList();

    String address = addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Location:  ${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

    HapticFeedback.mediumImpact();
    widget.onSave(lat, lng, address);
  }

  bool _canSave() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text. trim());
    return lat != null && lng != null;
  }

  EmployeeResponsiveData get r => widget.responsive;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.9),
      decoration: BoxDecoration(
        color: MapDesign.surfaceWhite,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(r.extraLargeBorderRadius),
        ),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
      // Handle
      Container(
      width: r.dimension(40),
      height: r.dimension(4),
      margin: EdgeInsets.symmetric(vertical: r.microPadding),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(r.pillBorderRadius),
      ),
    ),

    // Header
    _buildHeader(),

    Divider(height: r.padding * 2),

    // Content
    Flexible(
    child: SingleChildScrollView(
    padding: EdgeInsets.symmetric(horizontal: r.padding),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Task info
    _buildTaskInfo(),

    SizedBox(height: r.padding),

    // Method selection
    Text(
    'Select Location Method',
    style: GoogleFonts.poppins(
    fontSize: r.bodyS,
    fontWeight: FontWeight.w600,
    ),
    ),
    SizedBox(height: r. microPadding),
    Row(
    children: [
    Expanded(
    child: _buildMethodCard(
    'GPS',
    Icons.gps_fixed_rounded,
    'Use current location',
    ! _useMap,
    () => setState(() => _useMap = false),
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: _buildMethodCard(
    'Map',
    Icons.map_rounded,
    'Select on map',
    _useMap,
    () => setState(() => _useMap = true),
    ),
    ),
    ],
    ),

    SizedBox(height:  r.padding),

    // GPS capture or Map selection
    if (_useMap)
    _buildMapSelector()
    else
    _buildGPSCapture(),

    SizedBox(height: r.padding),

    // Manual coordinates
    Text(
    'Coordinates',
    style: GoogleFonts.poppins(
    fontSize: r.bodyS,
    fontWeight: FontWeight.w600,
    ),
    ),
    SizedBox(height: r. microPadding),
    Row(
    children: [
    Expanded(
    child: _buildTextField(
    _latController,
    'Latitude',
    'e.g., 31.7167',
    Icons.north_rounded,
    ),
    ),
    SizedBox(width: r. microPadding),
    Expanded(
    child:  _buildTextField(
    _lngController,
    'Longitude',
    'e.g., 73.9850',
    Icons.east_rounded,
    ),
    ),
    ],
    ),

    SizedBox(height: r.padding),

    // Address fields
    Text(
    'Address Details',
    style: GoogleFonts.poppins(
    fontSize: r.bodyS,
    fontWeight: FontWeight.w600,
    ),
    ),
    SizedBox(height: r. microPadding),
    _buildTextField(
    _streetController,
    'Street/Road',
    'Enter street name',
    Icons.signpost_rounded,
    isNumeric: false,
    ),
    SizedBox(height: r. microPadding),
    Row(
    children: [
    Expanded(
    child: _buildTextField(
    _areaController,
    'Area/Locality',
    'Enter area',
    Icons.location_city_rounded,
    isNumeric: false,
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: _buildTextField(
    _cityController,
    'City',
    'Enter city',
    Icons.apartment_rounded,
    isNumeric: false,
    ),
    ),
    ],
    ),

    // Error
    if (_error != null) ...[
    SizedBox(height: r.microPadding),
    _buildErrorBanner(),
    ],

    SizedBox(height: r.microPadding),

    // Tip
    _buildTipBanner(),

    SizedBox(height: r.padding),
    ],
    ),
    ),
    ),

    // Actions
    _buildActions(bottomPad),
    ],
    ),
    );
    }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: Colors.orange. withOpacity(0.1),
              borderRadius: BorderRadius. circular(r.borderRadius),
            ),
            child: Icon(
              Icons.add_location_alt_rounded,
              color: Colors.orange,
              size: r.iconSize(24),
            ),
          ),
          SizedBox(width:  r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Location',
                  style: GoogleFonts.poppins(
                    fontSize:  r.headingXS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Set GPS coordinates for this task',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionM,
                    color: MapDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            color: MapDesign.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo() {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors. grey[50],
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.grey. withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration:  BoxDecoration(
              color:  MapDesign.primaryTeal. withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Icon(
              Icons.assignment_rounded,
              color: MapDesign.primaryTeal,
              size: r.iconSize(20),
            ),
          ),
          SizedBox(width: r. microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.report.type,
                  style: GoogleFonts.poppins(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID: #${widget.report.id}',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionS,
                    color: MapDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(
      String title,
      IconData icon,
      String subtitle,
      bool isSelected,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? MapDesign.primaryTeal.withOpacity(0.1)
              : Colors. grey[50],
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: Border.all(
            color: isSelected
                ? MapDesign.primaryTeal
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: r.iconSize(28),
              color: isSelected ?  MapDesign.primaryTeal :  Colors.grey[600],
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              title,
              style:  GoogleFonts.poppins(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
                color: isSelected ? MapDesign.primaryTeal : MapDesign.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: r. captionXS,
                color: MapDesign.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGPSCapture() {
    return GestureDetector(
      onTap: _isLoadingGPS ? null : _captureCurrentLocation,
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [MapDesign.primaryTeal, MapDesign.primaryTealDark],
          ),
          borderRadius: BorderRadius.circular(r.borderRadius),
          boxShadow: [
            BoxShadow(
              color:  MapDesign.primaryTeal.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoadingGPS)
              SizedBox(
                width: r.iconSize(20),
                height: r.iconSize(20),
                child:  const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors. white,
                ),
              )
            else
              Icon(
                Icons.gps_fixed_rounded,
                color: Colors.white,
                size: r.iconSize(22),
              ),
            SizedBox(width: r.microPadding),
            Text(
              _isLoadingGPS ? 'Getting Location...' : 'Capture Current GPS Location',
              style: GoogleFonts.poppins(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSelector() {
    return Container(
      height: r.dimension(200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.grey. withOpacity(0.3)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedMapLocation ??  MapDesign.defaultCenter,
              initialZoom:  14,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.neatnow.app',
              ),
              if (_selectedMapLocation != null)
                MarkerLayer(
                  markers:  [
                    Marker(
                      point: _selectedMapLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: r.nanoPadding,
            left: r.nanoPadding,
            right: r.nanoPadding,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r. nanoPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: r.iconSize(16),
                    color: MapDesign.textSecondary,
                  ),
                  SizedBox(width: r.nanoPadding),
                  Expanded(
                    child: Text(
                      _selectedMapLocation != null
                          ? 'Tap to change location'
                          : 'Tap on map to select location',
                      style: GoogleFonts.poppins(
                        fontSize:  r.captionS,
                        color: MapDesign.textSecondary,
                      ),
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String hint,
      IconData icon, {
        bool isNumeric = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: r. captionS,
            color: MapDesign.textSecondary,
          ),
        ),
        SizedBox(height:  r.atomicPadding),
        TextField(
          controller: controller,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          )
              : TextInputType.text,
          style: GoogleFonts.poppins(fontSize: r.bodyS),
          onChanged: (_) => setState(() => _error = null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts. poppins(
              fontSize:  r.captionM,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(icon, size: r.iconSize(20), color: Colors.grey[500]),
            contentPadding: EdgeInsets. symmetric(
              horizontal: r.microPadding,
              vertical: r. microPadding,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.borderRadius),
              borderSide: BorderSide(color:  Colors.grey. withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.borderRadius),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r. borderRadius),
              borderSide: const BorderSide(color: MapDesign.primaryTeal, width: 2),
            ),
            filled: true,
            fillColor:  Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color: Colors.red. withOpacity(0.1),
        borderRadius: BorderRadius. circular(r.borderRadius),
        border: Border.all(color: Colors.red. withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red,
            size: r.iconSize(18),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Text(
              _error! ,
              style: GoogleFonts.poppins(
                fontSize: r.captionM,
                color: Colors.red,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _error = null),
            child: Icon(
              Icons.close_rounded,
              color: Colors.red,
              size: r.iconSize(18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipBanner() {
    return Container(
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color:  Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: r.iconSize(18),
            color: Colors.blue[600],
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Text(
              'Tip:  You can get coordinates from Google Maps by long-pressing on a location.',
              style: GoogleFonts.poppins(
                fontSize: r.captionS,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.microPadding,
        r. padding,
        bottomPad + r.microPadding,
      ),
      decoration: BoxDecoration(
        color: MapDesign.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: MapDesign.textSecondary,
                side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                minimumSize: Size(0, r.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r. borderRadius),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            flex: 2,
            child: ElevatedButton. icon(
              onPressed: _canSave() ? _save :  null,
              icon: Icon(Icons.save_rounded, size: r.iconSize(18)),
              label: const Text('Save Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors. orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors. grey[300],
                minimumSize: Size(0, r.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}