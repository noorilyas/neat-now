import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:neat_now/models/employee_models.dart';

/// Location Editor Sheet - For manually adding/updating GPS location
class _LocationEditorSheet extends StatefulWidget {
  final Report report;
  final Function(double lat, double lng, String address) onSave;

  const _LocationEditorSheet({
    required this.report,
    required this. onSave,
  });

  @override
  State<_LocationEditorSheet> createState() => _LocationEditorSheetState();
}

class _LocationEditorSheetState extends State<_LocationEditorSheet> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoadingGPS = false;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing coordinates if available
    if (widget.report.latitude != null && widget. report.latitude != 0.0) {
      _latController.text = widget.report.latitude! .toStringAsFixed(6);
    }
    if (widget.report.longitude != null && widget. report.longitude != 0.0) {
      _lngController.text = widget.report.longitude! .toStringAsFixed(6);
    }
    _addressController.text = widget.report.location;
  }

  @override
  void dispose() {
    _latController. dispose();
    _lngController.dispose();
    _addressController.dispose();
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
        throw Exception('Location permission permanently denied.  Please enable in settings.');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please enable GPS/Location services');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      String addr = '';
      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos. longitude);
        if (placemarks. isNotEmpty) {
          final p = placemarks. first;
          addr = [p.street, p.subLocality, p.locality, p.administrativeArea]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
        }
      } catch (_) {}

      setState(() {
        _latController.text = pos.latitude.toStringAsFixed(6);
        _lngController.text = pos.longitude.toStringAsFixed(6);
        if (addr.isNotEmpty) {
          _addressController.text = addr;
        }
        _isLoadingGPS = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingGPS = false;
      });
    }
  }

  void _save() {
    final lat = double.tryParse(_latController. text. trim());
    final lng = double.tryParse(_lngController. text.trim());
    final addr = _addressController. text.trim();

    if (lat == null || lng == null) {
      setState(() => _error = 'Please enter valid coordinates');
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

    HapticFeedback.mediumImpact();
    widget.onSave(lat, lng, addr. isNotEmpty ? addr : 'Location: $lat, $lng');
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size. height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.8),
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
        decoration: BoxDecoration(
          color: Colors. grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),

      // Header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange. withOpacity(0.1),
                borderRadius: BorderRadius. circular(12),
              ),
              child: const Icon(Icons.edit_location_alt_rounded, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Location',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Update GPS coordinates',
                    style: GoogleFonts. poppins(fontSize: 12, color: Colors. grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons. close_rounded),
              color: Colors.grey[600],
            ),
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
              // Current report info
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
                    child: const Icon(Icons.delete_rounded, color: Color(0xFF2AC2AB), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment. start,
                      children: [
                        Text(
                          widget.report.type,
                          style: GoogleFonts. poppins(fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: #${widget.report. id}',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors. grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // GPS capture button
            GestureDetector(
              onTap: _isLoadingGPS ?  null : _captureCurrentLocation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2AC2AB), Color(0xFF1FA896)],
                  ),
                  borderRadius: BorderRadius. circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2AC2AB).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment. center,
                  children: [
                    if (_isLoadingGPS)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.gps_fixed_rounded, color: Colors. white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      _isLoadingGPS ? 'Getting Location...' : 'Use Current GPS Location',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Or divider
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey. withOpacity(0.3))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR ENTER MANUALLY',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight. w600,
                      color: Colors. grey[500],
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey. withOpacity(0.3))),
              ],
            ),

            const SizedBox(height: 16),

            // Manual input fields
            Text(
              'Coordinates',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _latController,
                    label: 'Latitude',
                    hint: 'e.g., 31.7167',
                    icon: Icons.north_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _lngController,
                    label: 'Longitude',
                    hint: 'e. g., 73.9850',
                    icon: Icons.east_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Address',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _addressController,
              label: 'Location Address',
              hint: 'Street, City, Area',
              icon: Icons.location_on_rounded,
              maxLines: 2,
            ),

            // Error message
            if (_error != null) ...[
        const SizedBox(height: 12),
    Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.red. withOpacity(0.1),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: Colors. red.withOpacity(0.3)),
    ),
    child: Row(
    children: [
    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
    const SizedBox(width: 10),
    Expanded(
    child: Text(
    _error! ,
    style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
    ),
    ),
    GestureDetector(
    onTap: () => setState(() => _error = null),
    child: const Icon(Icons.close_rounded, color: Colors. red, size: 18),
    ),
    ],
    ),
    ),
    ],

    const SizedBox(height: 16),

    // Help text
    Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.blue.withOpacity(0.05),
    borderRadius: BorderRadius. circular(10),
    border: Border.all(color: Colors.blue.withOpacity(0.2)),
    ),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Icon(Icons.lightbulb_outline_rounded, size: 18, color: Colors. blue[600]),
    const SizedBox(width: 10),
    Expanded(
    child: Text(
    'Tip: You can get coordinates from Google Maps by long-pressing on a location.',
    style: GoogleFonts. poppins(fontSize: 11, color: Colors. blue[700]),
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
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
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
    onPressed: _canSave() ? _save : null,
    icon: _isSaving
    ? const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    )
        : const Icon(Icons. save_rounded, size: 18),
    label: Text(_isSaving ? 'Saving...' : 'Save Location'),
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

  bool _canSave() {
    if (_isSaving) return false;
    final lat = double.tryParse(_latController. text. trim());
    final lng = double.tryParse(_lngController. text.trim());
    return lat != null && lng != null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14),
          onChanged: (_) => setState(() => _error = null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors. grey[400]),
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors. grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius. circular(12),
              borderSide: const BorderSide(color: Color(0xFF2AC2AB), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors. grey[50],
          ),
        ),
      ],
    );
  }
}