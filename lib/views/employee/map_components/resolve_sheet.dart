import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class ResolveSheet extends StatefulWidget {
  final Report report;
  final MapTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final ImagePicker imagePicker;
  final Function(String imagePath, double lat, double lng, String address, DateTime timestamp) onResolve;

  const ResolveSheet({
    super.key,
    required this. report,
    required this.viewModel,
    required this.responsive,
    required this.imagePicker,
    required this.onResolve,
  });

  @override
  State<ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends State<ResolveSheet> {
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

      String addr = 'Unknown location';
      try {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
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
          _locationError = e.toString().replaceAll('Exception: ', '');
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? img = await widget.imagePicker.pickImage(
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
    final r = widget.responsive;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: MapDesign.surfaceWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(r.extraLargeBorderRadius),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: r.dimension(40),
                height: r.dimension(4),
                margin: EdgeInsets.only(bottom: r.padding),
                decoration: BoxDecoration(
                  color: Colors. grey[300],
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                ),
              ),
              Text(
                'Capture Cleanup Image',
                style: GoogleFonts.poppins(
                  fontSize: r.headingXS,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: r. padding),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceButton(
                      r,
                      Icons.camera_alt_rounded,
                      'Camera',
                      MapDesign.primaryTeal,
                          () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  SizedBox(width: r.padding),
                  Expanded(
                    child: _buildSourceButton(
                      r,
                      Icons.photo_library_rounded,
                      'Gallery',
                      Colors.blue,
                          () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.padding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton(
      EmployeeResponsiveData r,
      IconData icon,
      String label,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: r.padding),
        decoration: BoxDecoration(
          color: color. withOpacity(0.1),
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          border: Border.all(color: color. withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius:  8,
                    offset:  const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: r.iconSize(28), color: Colors.white),
            ),
            SizedBox(height: r. microPadding),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: r. bodyS,
                fontWeight: FontWeight.w600,
                color: color,
              ),
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

    if (_position == null) {
      _showError('GPS location not captured.  Please try again.');
      return;
    }

    HapticFeedback.mediumImpact();
    widget.onResolve(
      _afterImage!.path,
      _position!.latitude,
      _position!.longitude,
      _address ??  'Unknown location',
      _captureTime ?? DateTime.now(),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: MapDesign.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:  BorderRadius.circular(r.borderRadius),
        ),
        margin: EdgeInsets.all(r.padding),
      ),
    );
  }

  bool _canSubmit() {
    return _afterImage != null && _position != null;
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
          top: Radius. circular(r.extraLargeBorderRadius),
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
            decoration:  BoxDecoration(
              color:  Colors.grey[300],
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
                  _buildImageComparison(),
                  SizedBox(height: r.padding),
                  _buildLocationSection(),
                  SizedBox(height: r.padding),
                  if (_captureTime != null) _buildTimestampSection(),
                  SizedBox(height: r.padding),
                  _buildAIInfoBanner(),
                  SizedBox(height: r.padding),
                ],
              ),
            ),
          ),

          // Submit button
          _buildSubmitButton(bottomPad),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r. padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: Colors.green. withOpacity(0.1),
              borderRadius: BorderRadius. circular(r.borderRadius),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: r.iconSize(24),
            ),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Task',
                  style: GoogleFonts.poppins(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.report.type,
                  style: GoogleFonts.poppins(
                    fontSize: r.captionM,
                    color: MapDesign.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  Widget _buildImageComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.compare_rounded,
              size: r.iconSize(18),
              color: MapDesign.textSecondary,
            ),
            SizedBox(width: r.microPadding),
            Text(
              'Before & After Comparison',
              style: GoogleFonts.poppins(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: r.microPadding),
        Row(
          children: [
            Expanded(
              child: _buildImageCard(
                'Before',
                widget.report.imageUrl,
                null,
                false,
              ),
            ),
            SizedBox(width: r.microPadding),
            Expanded(
              child: _buildImageCard(
                'After',
                null,
                _afterImage,
                true,
                onTap: _showImagePicker,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard(
      String label,
      String?  url,
      File? file,
      bool isAfter, {
        VoidCallback? onTap,
      }) {
    final hasImage = url != null || file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: r.dimension(8),
              height: r.dimension(8),
              decoration: BoxDecoration(
                color: isAfter ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: r.nanoPadding),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: r.captionM,
                fontWeight: FontWeight.w600,
                color: MapDesign.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: r.microPadding),
        GestureDetector(
          onTap: isAfter ? onTap : null,
          child: Container(
            height: r.dimension(120),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(r.borderRadius),
              border: Border.all(
                color: isAfter
                    ? (hasImage ? Colors.green : MapDesign.primaryTeal)
                    : Colors.grey. withOpacity(0.3),
                width: isAfter && ! hasImage ? 2 : 1,
              ),
              image: hasImage
                  ? DecorationImage(
                image: file != null
                    ? FileImage(file)
                    : NetworkImage(url!) as ImageProvider,
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: ! hasImage
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAfter
                        ? Icons.add_a_photo_rounded
                        : Icons.image_not_supported_rounded,
                    size: r.iconSize(28),
                    color: isAfter
                        ? MapDesign.primaryTeal
                        : Colors.grey[400],
                  ),
                  SizedBox(height: r.nanoPadding),
                  Text(
                    isAfter ?  'Tap to capture' : 'No image',
                    style: GoogleFonts.poppins(
                      fontSize: r.captionXS,
                      color: isAfter
                          ? MapDesign.primaryTeal
                          : Colors. grey[500],
                    ),
                  ),
                ],
              ),
            )
                : isAfter
                ?  Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.all(r.nanoPadding),
                padding: EdgeInsets.all(r.nanoPadding),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(r.nanoPadding),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: r. iconSize(12),
                  color: Colors. white,
                ),
              ),
            )
                : null,
          ),
        ),
        if (isAfter && _afterImage != null) ...[
          SizedBox(height: r.nanoPadding),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size:  r.iconSize(14),
                  color: MapDesign.textSecondary,
                ),
                SizedBox(width: r.atomicPadding),
                Text(
                  'Retake',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionS,
                    color: MapDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    final isSuccess = _position != null && _locationError == null;
    final isError = _locationError != null;
    final color = isError ? MapDesign.error : MapDesign.primaryTeal;

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment:  CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gps_fixed_rounded,
                size: r.iconSize(18),
                color: color,
              ),
              SizedBox(width: r.microPadding),
              Text(
                'GPS Location (Auto-captured)',
                style: GoogleFonts.poppins(
                  fontSize: r.captionL,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_isLoadingLocation)
                SizedBox(
                  width: r.iconSize(18),
                  height: r.iconSize(18),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: MapDesign.primaryTeal,
                  ),
                )
              else if (isSuccess)
                Icon(
                  Icons.check_circle_rounded,
                  size: r. iconSize(18),
                  color: Colors.green,
                )
              else if (isError)
                  GestureDetector(
                    onTap: _captureLocation,
                    child:  Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.microPadding,
                        vertical: r.nanoPadding,
                      ),
                      decoration: BoxDecoration(
                        color: MapDesign.error,
                        borderRadius: BorderRadius.circular(r.smallBorderRadius),
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(
                          fontSize: r.captionXS,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          SizedBox(height: r. microPadding),
          if (_isLoadingLocation)
            Text(
              'Capturing your location...',
              style: GoogleFonts.poppins(
                fontSize: r.captionM,
                color: MapDesign.textSecondary,
              ),
            )
          else if (isError)
            Text(
              _locationError!,
              style: GoogleFonts.poppins(
                fontSize: r.captionM,
                color: MapDesign.error,
              ),
            )
          else if (isSuccess) ...[
              Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration: BoxDecoration(
                  color: MapDesign.surfaceWhite,
                  borderRadius: BorderRadius.circular(r. borderRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coordinates',
                      style: GoogleFonts.poppins(
                        fontSize: r.captionXS,
                        color: MapDesign.textTertiary,
                      ),
                    ),
                    Text(
                      '${_position! .latitude.toStringAsFixed(6)}, ${_position!.longitude. toStringAsFixed(6)}',
                      style: GoogleFonts.poppins(
                        fontSize: r.captionM,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_address != null) ...[
                      SizedBox(height: r.microPadding),
                      Text(
                        'Address',
                        style: GoogleFonts.poppins(
                          fontSize: r.captionXS,
                          color: MapDesign.textTertiary,
                        ),
                      ),
                      Text(
                        _address!,
                        style: GoogleFonts.poppins(fontSize: r.captionM),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildTimestampSection() {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: Colors.blue. withOpacity(0.05),
        borderRadius: BorderRadius. circular(r.largeBorderRadius),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: r.iconSize(18),
            color: Colors.blue,
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completion Timestamp',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionL,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.viewModel.formatDateTime(_captureTime! ),
                  style: GoogleFonts.poppins(
                    fontSize: r.captionM,
                    color: MapDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            size: r.iconSize(18),
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAIInfoBanner() {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color:  Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border. all(color: Colors.amber. withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.smart_toy_rounded,
            size: r.iconSize(20),
            color: Colors.amber,
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Verification',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionL,
                    fontWeight:  FontWeight.w600,
                    color: Colors.amber. shade800,
                  ),
                ),
                SizedBox(height: r.nanoPadding),
                Text(
                  'Your cleanup image will be analyzed by AI.  If remaining waste is detected, you\'ll be asked to complete the cleanup.',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionS,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.microPadding,
        r.padding,
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
                side: BorderSide(color: Colors.grey. withOpacity(0.3)),
                minimumSize: Size(0, r.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r. borderRadius),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width:  r.microPadding),
          Expanded(
            flex: 2,
            child: ElevatedButton. icon(
              onPressed: _canSubmit() ? _submit : null,
              icon: Icon(Icons.send_rounded, size: r.iconSize(18)),
              label: Text(
                r.adaptiveText(
                  'Submit for Verification',
                  micro: 'Submit',
                  mini: 'Verify',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors. grey[300],
                minimumSize: Size(0, r.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius:  BorderRadius.circular(r.borderRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}