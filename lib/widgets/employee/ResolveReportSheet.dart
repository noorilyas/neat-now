import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'dart:io';

/// ResolveReportSheet - Bottom sheet for resolving reports with verification
/// Features:
/// - Before image display
/// - After image capture (camera/gallery)
/// - GPS location capture
/// - Timestamp logging
class ResolveReportSheet extends StatefulWidget {
  final Report report;
  final EmployeeResponsiveData responsive;
  final Function(String imagePath, double latitude, double longitude, String address) onResolve;

  const ResolveReportSheet({
    super.key,
    required this.report,
    required this. responsive,
    required this.onResolve,
  });

  @override
  State<ResolveReportSheet> createState() => _ResolveReportSheetState();
}

class _ResolveReportSheetState extends State<ResolveReportSheet> {
  final ImagePicker _imagePicker = ImagePicker();

  File? _afterImage;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isCapturingLocation = false;
  bool _isSubmitting = false;
  String? _locationError;
  DateTime? _captureTimestamp;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isCapturingLocation = true;
      _locationError = null;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator. requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.  Please enable in settings.');
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS.');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get address from coordinates
      String address = 'Unknown location';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks. isNotEmpty) {
          final place = placemarks.first;
          address = [
            place.street,
            place. subLocality,
            place.locality,
            place. administrativeArea,
          ].where((s) => s != null && s. isNotEmpty).join(', ');
        }
      } catch (e) {
        debugPrint('Geocoding error: $e');
      }

      setState(() {
        _currentPosition = position;
        _currentAddress = address;
        _isCapturingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isCapturingLocation = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker. pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _afterImage = File(image.path);
          _captureTimestamp = DateTime.now();
        });

        // Re-capture location when image is taken
        if (_currentPosition == null) {
          _captureLocation();
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors. white,
          borderRadius: BorderRadius. vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors. grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Image Source',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF2AC2AB),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: Colors.blue,
                    onTap: () {
                      Navigator. pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color. withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color. withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitResolution() {
    if (_afterImage == null) {
      _showErrorSnackBar('Please capture an after-cleanup image');
      return;
    }

    if (_currentPosition == null) {
      _showErrorSnackBar('Unable to capture GPS location.  Please try again.');
      return;
    }

    HapticFeedback.mediumImpact();

    widget.onResolve(
      _afterImage!.path,
      _currentPosition!.latitude,
      _currentPosition! .longitude,
      _currentAddress ??  'Unknown location',
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
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
    final bottomPadding = MediaQuery.of(context). padding.bottom;
    final screenHeight = MediaQuery.of(context).size. height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      decoration: const BoxDecoration(
        color: Colors. white,
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
                    color: Colors.green. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark as Resolved',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight. bold,
                        ),
                      ),
                      Text(
                        widget.report.type,
                        style: GoogleFonts. poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons. close),
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
                  // Before/After comparison
                  Text(
                    'Before & After Comparison',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight. w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Before image
                      Expanded(
                        child: _buildImageCard(
                          label: 'Before',
                          imageUrl: widget.report.imageUrl,
                          isAfter: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // After image
                      Expanded(
                        child: _buildImageCard(
                          label: 'After',
                          imageFile: _afterImage,
                          isAfter: true,
                          onTap: _showImageSourceDialog,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Location info
                  _buildLocationCard(),

                  const SizedBox(height: 20),

                  // Timestamp info
                  if (_captureTimestamp != null) _buildTimestampCard(),

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
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 12),
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors. grey[700],
                      side: BorderSide(color: Colors.grey. withOpacity(0.3)),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _afterImage != null && _currentPosition != null && ! _isSubmitting
                        ? _submitResolution
                        : null,
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_isSubmitting ? 'Submitting.. .' : 'Submit for Verification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildImageCard({
    required String label,
    String? imageUrl,
    File? imageFile,
    required bool isAfter,
    VoidCallback? onTap,
  }) {
    final hasImage = imageUrl != null || imageFile != null;

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
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isAfter ? onTap : null,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isAfter
                    ? (hasImage ? Colors.green : const Color(0xFF2AC2AB))
                    : Colors. grey. withOpacity(0.3),
                width: isAfter && ! hasImage ? 2 : 1,
                style: isAfter && !hasImage ? BorderStyle. solid : BorderStyle.solid,
              ),
              image: hasImage
                  ? DecorationImage(
                image: imageFile != null
                    ?  FileImage(imageFile)
                    : NetworkImage(imageUrl!) as ImageProvider,
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: ! hasImage
                ?  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment. center,
                children: [
                  Icon(
                    isAfter ? Icons. add_a_photo_rounded : Icons.image_not_supported_rounded,
                    size: 32,
                    color: isAfter ?  const Color(0xFF2AC2AB) : Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAfter ? 'Tap to capture' : 'No image',
                    style: GoogleFonts. poppins(
                      fontSize: 11,
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
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
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
                Icon(Icons.refresh_rounded, size: 14, color: Colors. grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Retake',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
        padding: const EdgeInsets. all(14),
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
          crossAxisAlignment: CrossAxisAlignment. start,
          children: [
        Row(
        children: [
        Icon(
        Icons.location_on_rounded,
          size: 18,
          color: _locationError != null ? Colors.red : const Color(0xFF2AC2AB),
        ),
        const SizedBox(width: 8),
        Text(
          'GPS Location',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight. w600,
            color: Colors.grey[800],
          ),
        ),
        const Spacer(),
        if (_isCapturingLocation)
    const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Color(0xFF2AC2AB),
      ),
    )
    else if (_currentPosition != null)
    const Icon(Icons.check_circle, size: 18, color: Colors.green)
    else if (_locationError != null)
    GestureDetector(
    onTap: _captureLocation,
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
    color: Colors.red,
    borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
    'Retry',
    style: GoogleFonts.poppins(
    fontSize: 10,
    color: Colors.white,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ),
    ],
    ),
    const SizedBox(height: 10),
    if (_isCapturingLocation)
    Text(
    'Capturing your current location...',
    style: GoogleFonts.poppins(fontSize: 12, color: Colors. grey[600]),
    )
    else if (_locationError != null)
    Text(
    _locationError!,
    style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
    )
    else if (_currentPosition != null) ...[
    Row(
    children: [
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Coordinates',
    style: GoogleFonts.poppins(fontSize: 10, color: Colors. grey[500]),
    ),
    Text(
    '${_currentPosition! .latitude. toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight. w500),
    ),
    ],
    ),
    ),
    Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
    color: Colors.green. withOpacity(0.1),
    borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
    '±${_currentPosition! .accuracy.toStringAsFixed(0)}m',
    style: GoogleFonts.poppins(
    fontSize: 10,
    color: Colors.green,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ],
    ),
    if (_currentAddress != null) ...[
    const SizedBox(height: 8),
    Text(
    'Address',
    style: GoogleFonts.poppins(fontSize: 10, color: Colors. grey[500]),
    ),
    Text(
    _currentAddress!,
    style: GoogleFonts.poppins(fontSize: 12),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    ),
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
        border: Border.all(color: Colors.blue. withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, size: 18, color: Colors. blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cleanup Timestamp',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight. w600,
                    color: Colors. grey[800],
                  ),
                ),
                Text(
                  _formatTimestamp(_captureTimestamp! ),
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors. grey[600]),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors. amber. withOpacity(0.1),
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
                  'AI Verification',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your cleanup image will be verified by AI to ensure the area is clean.  If waste is still detected, you\'ll be asked to retake the photo.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.amber[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final day = dt.day. toString().padLeft(2, '0');
    final month = dt.month. toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute. toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$day/$month/$year at $hour:$minute:$second';
  }
}