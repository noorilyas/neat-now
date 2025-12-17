import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:neat_now/models/employee_models.dart';
import 'dart:io';

/// Resolve Sheet - For marking reports as resolved with verification
class _ResolveSheet extends StatefulWidget {
  final Report report;
  final Function(String imagePath, double lat, double lng, String address) onResolve;

  const _ResolveSheet({
    required this.report,
    required this. onResolve,
  });

  @override
  State<_ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends State<_ResolveSheet> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  File? _afterImage;
  Position? _position;
  String?  _address;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _useManualLocation = false;
  String? _locationError;
  DateTime? _captureTime;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  @override
  void dispose() {
    _addressController. dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
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
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos. longitude);
        if (placemarks. isNotEmpty) {
          final p = placemarks. first;
          addr = [p.street, p.subLocality, p.locality, p.administrativeArea]
              .where((s) => s != null && s. isNotEmpty)
              .join(', ');
        }
      } catch (_) {}

      setState(() {
        _position = pos;
        _address = addr;
        _addressController.text = addr;
        _latController.text = pos.latitude.toStringAsFixed(6);
        _lngController.text = pos.longitude.toStringAsFixed(6);
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
        _useManualLocation = true;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile?  img = await _picker. pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (img != null) {
        setState(() {
          _afterImage = File(img.path);
          _captureTime = DateTime.now();
        });

        if (_position == null && ! _useManualLocation) {
          _captureLocation();
        }
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
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
        child: Column(
          mainAxisSize: MainAxisSize. min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets. only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors. grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Image Source',
              style: GoogleFonts. poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _sourceBtn(
                    Icons.camera_alt_rounded,
                    'Camera',
                    const Color(0xFF2AC2AB),
                        () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _sourceBtn(
                    Icons. photo_library_rounded,
                    'Gallery',
                    Colors.blue,
                        () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource. gallery);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
          ],
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
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: color),
            ),
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

    double?  lat;
    double? lng;
    String addr = _addressController.text.trim();

    if (_useManualLocation) {
      lat = double.tryParse(_latController.text. trim());
      lng = double.tryParse(_lngController.text.trim());

      if (lat == null || lng == null) {
        _showError('Please enter valid coordinates');
        return;
      }

      if (lat. abs() > 90 || lng.abs() > 180) {
        _showError('Invalid coordinate values');
        return;
      }
    } else {
      if (_position == null) {
        _showError('GPS location not captured');
        return;
      }
      lat = _position!. latitude;
      lng = _position!. longitude;
    }

    if (addr.isEmpty) {
      addr = 'Location: $lat, $lng';
    }

    HapticFeedback.mediumImpact();
    widget.onResolve(_afterImage! .path, lat, lng, addr);
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

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size. height;
    final color = _statusColor(widget.report.status);

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
            decoration: BoxDecoration(
              color: Colors.grey[300],
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
                      Text(
                        'Mark as Resolved',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.report.type,
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
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  // Before/After images
                  Text(
                    'Before & After',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _imageCard('Before', widget.report.imageUrl, null, false)),
                      const SizedBox(width: 12),
                      Expanded(child: _imageCard('After', null, _afterImage, true, onTap: _showImagePicker)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Location section
                  Row(
                    children: [
                      Text(
                        'Location',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _useManualLocation = ! _useManualLocation),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _useManualLocation ?  Colors.orange.withOpacity(0.1) : const Color(0xFF2AC2AB). withOpacity(0.1),
                            borderRadius: BorderRadius. circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _useManualLocation ? Icons.edit_rounded : Icons.gps_fixed_rounded,
                                size: 14,
                                color: _useManualLocation ? Colors.orange : const Color(0xFF2AC2AB),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _useManualLocation ?  'Manual' : 'GPS',
                                style: GoogleFonts. poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _useManualLocation ? Colors. orange : const Color(0xFF2AC2AB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_useManualLocation)
                    _buildManualLocationFields()
                  else
                    _buildGPSLocationCard(),

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
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_isSubmitting ? 'Submitting.. .' : 'Submit'),
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

  bool _canSubmit() {
    if (_afterImage == null) return false;
    if (_isSubmitting) return false;

    if (_useManualLocation) {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      return lat != null && lng != null;
    } else {
      return _position != null;
    }
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
              decoration: BoxDecoration(
                color: isAfter ? Colors. green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight. w600, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isAfter ? onTap : null,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius. circular(12),
              border: Border. all(
                color: isAfter
                    ? (hasImage ? Colors.green : const Color(0xFF2AC2AB))
                    : Colors. grey.withOpacity(0.3),
                width: isAfter && ! hasImage ? 2 : 1,
              ),
              image: hasImage
                  ? DecorationImage(
                image: file != null ?  FileImage(file) : NetworkImage(url!) as ImageProvider,
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: ! hasImage
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment. center,
                children: [
                  Icon(
                    isAfter ?  Icons.add_a_photo_rounded : Icons.image_not_supported_rounded,
                    size: 28,
                    color: isAfter ?  const Color(0xFF2AC2AB) : Colors.grey[400],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAfter ?  'Tap to capture' : 'No image',
                    style: GoogleFonts. poppins(
                      fontSize: 10,
                      color: isAfter ?  const Color(0xFF2AC2AB) : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : isAfter
                ?  Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
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
              mainAxisAlignment: MainAxisAlignment. center,
              children: [
                Icon(Icons.refresh_rounded, size: 12, color: Colors. grey[600]),
                const SizedBox(width: 4),
                Text('Retake', style: GoogleFonts.poppins(fontSize: 10, color: Colors. grey[600])),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGPSLocationCard() {
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _locationError != null
              ? Colors.red.withOpacity(0.05)
              : const Color(0xFF2AC2AB). withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _locationError != null
                ? Colors.red. withOpacity(0.2)
                : const Color(0xFF2AC2AB).withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
        children: [
        Icon(
        Icons.gps_fixed_rounded,
          size: 18,
          color: _locationError != null ? Colors.red : const Color(0xFF2AC2AB),
        ),
        const SizedBox(width: 8),
        Text(
          'GPS Location',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800]),
        ),
        const Spacer(),
        if (_isLoadingLocation)
    const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2AC2AB)),
    )
    else if (_position != null)
    const Icon(Icons.check_circle_rounded, size: 18, color: Colors. green)
    else if (_locationError != null)
    GestureDetector(
    onTap: _captureLocation,
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
    child: Text(
    'Retry',
    style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
    ),
    ),
    ),
    ],
    ),
    const SizedBox(height: 10),
    if (_isLoadingLocation)
    Text('Capturing location... ', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]))
    else if (_locationError != null)
    Text(_locationError!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.red))
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
    decoration: BoxDecoration(
    color: Colors.green.withOpacity(0.1),
    borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
    '±${_position!. accuracy.toStringAsFixed(0)}m',
    style: GoogleFonts.poppins(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
    ),
    ),
    ],
    ),
    if (_address != null) ...[
    const SizedBox(height: 8),
    Text('Address', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
    Text(
    _address! ,
    style: GoogleFonts. poppins(fontSize: 12),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    ),
    ],
    ],
    ],
    ),
    );
  }

  Widget _buildManualLocationFields() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange. withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_location_alt_rounded, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Manual Location',
                style: GoogleFonts. poppins(fontSize: 13, fontWeight: FontWeight. w600, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(_latController, 'Latitude', '-90 to 90'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(_lngController, 'Longitude', '-180 to 180'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _textField(_addressController, 'Address (optional)', 'Enter location address'),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: label. contains('Latitude') || label.contains('Longitude')
              ?  const TextInputType.numberWithOptions(decimal: true, signed: true)
              : TextInputType.text,
          style: GoogleFonts.poppins(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors. grey[400]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors. grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius. circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
            filled: true,
            fillColor: Colors. white,
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue. withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture Time',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                Text(
                  _formatTime(_captureTime! ),
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors. grey[600]),
                ),
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
        color: Colors. amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors. amber.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 20, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Required',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber. shade800),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your cleanup photo will be verified.  Ensure the area is fully cleaned before submitting.',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors. amber.shade900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status. toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'in-progress': return Colors. blue;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _formatTime(DateTime dt) {
    final d = dt.day. toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute. toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$d/$m/$y at $h:$min:$s';
  }
}