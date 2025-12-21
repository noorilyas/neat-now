import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class ResolveSheet extends StatefulWidget {
  final Report report;
  final EmployeeResponsiveData responsive;
  final ImagePicker imagePicker;
  final Function(String imagePath, double lat, double lng, String address, DateTime timestamp) onResolve;

  const ResolveSheet({
    super.key,
    required this.report,
    required this.responsive,
    required this.imagePicker,
    required this.onResolve,
  });

  @override
  State<ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends State<ResolveSheet> with SingleTickerProviderStateMixin {
  File? _capturedImage;
  Position? _position;
  String? _address;
  bool _isLoadingLocation = false;
  bool _useManualLocation = false;
  String? _locationError;
  DateTime?  _captureTime;

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = CurvedAnimation(
      parent:  _animController,
      curve:  Curves.easeOutCubic,
    );

    // ✅ SAFE ANIMATION START
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animController. forward();
        _captureLocation();
      }
    });
  }

  @override
  void dispose() {
    _animController.stop();
    _animController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    if (! mounted) return;

    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission. denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please enable GPS/Location services');
      }

      final pos = await Geolocator. getCurrentPosition(
        desiredAccuracy: LocationAccuracy. high,
        timeLimit: const Duration(seconds: 15),
      );

      String addr = 'Location captured';
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
          _latController.text = pos.latitude. toStringAsFixed(6);
          _lngController.text = pos.longitude.toStringAsFixed(6);
          _addressController.text = addr;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString().replaceAll('Exception: ', '');
          _isLoadingLocation = false;
          _useManualLocation = true;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticFeedback.lightImpact();
      final XFile?  img = await widget.imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (img != null && mounted) {
        setState(() {
          _capturedImage = File(img.path);
          _captureTime = DateTime.now();
        });

        if (_position == null && ! _useManualLocation) {
          _captureLocation();
        }
      }
    } catch (e) {
      _showError('Failed to capture image');
    }
  }

  void _showImageSourcePicker() {
    final r = widget.responsive;

    showModalBottomSheet(
      context:  context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: ReportsDesign.surfacePure,
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
                  color: ReportsDesign.textLight,
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                ),
              ),
              Text(
                'Capture Cleanup Image',
                style: GoogleFonts.inter(
                  fontSize: r.headingXS,
                  fontWeight: FontWeight.w700,
                  color: ReportsDesign.textPrimary,
                ),
              ),
              SizedBox(height: r.padding),
              Row(
                children: [
                  Expanded(
                    child: _buildSourceButton(
                      r,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: ReportsDesign.primaryTeal,
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  SizedBox(width: r.padding),
                  Expanded(
                    child: _buildSourceButton(
                      r,
                      icon: Icons.photo_library_rounded,
                      label:  'Gallery',
                      color: ReportsDesign.info,
                      onTap:  () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: r. padding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceButton(
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
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
          border: Border.all(color: color. withOpacity(0.2)),
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
                boxShadow: ReportsDesign.glowShadow(color),
              ),
              child: Icon(icon, size: r.iconSize(28), color: Colors.white),
            ),
            SizedBox(height: r. microPadding),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
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
    if (_capturedImage == null) {
      _showError('Please capture an after-cleanup image');
      return;
    }

    double?  lat;
    double? lng;
    String addr;

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

      addr = _addressController.text.trim().isNotEmpty
          ? _addressController.text. trim()
          : 'Location:  ${lat. toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
    } else {
      if (_position == null) {
        _showError('GPS location not captured.  Please try again or use manual entry.');
        return;
      }
      lat = _position!.latitude;
      lng = _position! .longitude;
      addr = _address ??  'Unknown location';
    }

    HapticFeedback.mediumImpact();
    widget.onResolve(
      _capturedImage!.path,
      lat,
      lng,
      addr,
      _captureTime ??  DateTime.now(),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(msg, style: GoogleFonts. inter(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: ReportsDesign.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  bool _canSubmit() {
    if (_capturedImage == null) return false;

    if (_useManualLocation) {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text. trim());
      return lat != null && lng != null;
    } else {
      return _position != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return SlideTransition(
      position:  Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.9),
        decoration: BoxDecoration(
          color: ReportsDesign.surfacePure,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(r. extraLargeBorderRadius),
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
                color:  ReportsDesign.textLight,
                borderRadius: BorderRadius. circular(r.pillBorderRadius),
              ),
            ),

            // Header
            _buildSheetHeader(r),

            Divider(height: r.padding * 2, color: ReportsDesign.surfaceLight),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: r.padding),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageComparison(r),
                    SizedBox(height: r.padding),
                    _buildLocationSection(r),
                    SizedBox(height: r.padding),
                    if (_captureTime != null) _buildTimestampSection(r),
                    SizedBox(height: r. padding),
                    _buildAIInfoBanner(r),
                    SizedBox(height: r.padding),
                  ],
                ),
              ),
            ),

            // Submit button
            _buildSubmitButton(r, bottomPad),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r. padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              gradient: ReportsDesign.successGradient,
              borderRadius: BorderRadius.circular(r.borderRadius),
              boxShadow: ReportsDesign.glowShadow(ReportsDesign.success),
            ),
            child:  Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
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
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: ReportsDesign.textPrimary,
                  ),
                ),
                Text(
                  widget.report.type,
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    color: ReportsDesign.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:  EdgeInsets.all(r. nanoPadding),
              decoration: const BoxDecoration(
                color:  ReportsDesign.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: ReportsDesign.textSecondary,
                size: r.iconSize(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageComparison(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.compare_rounded,
              size: r.iconSize(18),
              color: ReportsDesign.textSecondary,
            ),
            SizedBox(width: r. microPadding),
            Text(
              'Before & After Comparison',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
                color: ReportsDesign.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: r.microPadding),
        Row(
          children: [
            Expanded(
              child: _buildImageCard(
                r,
                'Before',
                widget.report.imageUrl,
                null,
                false,
              ),
            ),
            SizedBox(width: r.microPadding),
            Expanded(
              child: _buildImageCard(
                r,
                'After',
                null,
                _capturedImage,
                true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard(
      EmployeeResponsiveData r,
      String label,
      String?  url,
      File? file,
      bool isAfter,
      ) {
    final hasImage = url != null || file != null;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    Row(
    children: [
    Container(
    width: r.dimension(10),
    height: r.dimension(10),
    decoration: BoxDecoration(
    gradient: isAfter
    ?  ReportsDesign.successGradient
        : LinearGradient(
    colors: [
    ReportsDesign.warning,
    ReportsDesign.warning.withOpacity(0.8),
    ],
    ),
    shape: BoxShape. circle,
    ),
    ),
    SizedBox(width: r.nanoPadding),
    Text(
    label,
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    fontWeight: FontWeight.w600,
    color: ReportsDesign.textSecondary,
    ),
    ),
    ],
    ),
    SizedBox(height: r.microPadding),
    GestureDetector(
    onTap: isAfter ? _showImageSourcePicker : null,
    child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    height: r.dimension(140),
    decoration: BoxDecoration(
    color: ReportsDesign.surfaceLight,
    borderRadius: BorderRadius.circular(r.largeBorderRadius),
    border: Border.all(
    color: isAfter
    ? (hasImage
    ? ReportsDesign. success
        : ReportsDesign.primaryTeal)
        : ReportsDesign.surfaceOverlay,
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
    Container(
    padding: EdgeInsets.all(r.microPadding),
    decoration: BoxDecoration(
    color: isAfter
    ? ReportsDesign.primaryTeal. withOpacity(0.1)
        : ReportsDesign.surfaceOverlay,
    shape: BoxShape.circle,
    ),
    child: Icon(
    isAfter
    ? Icons.add_a_photo_rounded
        : Icons. image_not_supported_rounded,
    size: r.iconSize(24),
    color: isAfter
    ? ReportsDesign.primaryTeal
        : ReportsDesign. textTertiary,
    ),
    ),
    SizedBox(height: r.nanoPadding),
    Text(
    isAfter ?  'Tap to capture' : 'No image',
    style: GoogleFonts.inter(
    fontSize: r.captionS,
    color: isAfter
    ? ReportsDesign.primaryTeal
        : ReportsDesign.textTertiary,
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
    color: ReportsDesign.success,
    borderRadius: BorderRadius.circular(r.nanoPadding),
    ),
    child: Icon(
    Icons.check_rounded,
    size: r.iconSize(12),
    color: Colors.white,
    ),
    ),
    )
        : null,
    ),
    ),
    if (isAfter && _capturedImage != null) ...[
    SizedBox(height: r.nanoPadding),
    GestureDetector(
    onTap: _showImageSourcePicker,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(
    Icons.refresh_rounded,
    size:  r.iconSize(14),
    color: ReportsDesign.textSecondary,
    ),
    SizedBox(width: r.atomicPadding),
    Text(
    'Retake',
    style: GoogleFonts.inter(
    fontSize: r.captionS,
    color: ReportsDesign.textSecondary,
    ),
    ),
    ],
    ),
    ),
    ],
    ],
    );
  }

  Widget _buildLocationSection(EmployeeResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment. start,
      children: [
        Row(
          children: [
            Icon(
              Icons. location_on_rounded,
              size: r.iconSize(18),
              color:  ReportsDesign.textSecondary,
            ),
            SizedBox(width: r.microPadding),
            Text(
              'Location Verification',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
                color: ReportsDesign.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap:  () {
                HapticFeedback.selectionClick();
                setState(() => _useManualLocation = ! _useManualLocation);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.microPadding,
                  vertical: r.nanoPadding,
                ),
                decoration: BoxDecoration(
                  gradient: _useManualLocation
                      ? LinearGradient(
                    colors: [
                      ReportsDesign.warning,
                      ReportsDesign.warning.withOpacity(0.8),
                    ],
                  )
                      : ReportsDesign.primaryGradient,
                  borderRadius: BorderRadius.circular(r. pillBorderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _useManualLocation
                          ? Icons.edit_rounded
                          : Icons.gps_fixed_rounded,
                      size: r. iconSize(12),
                      color: Colors.white,
                    ),
                    SizedBox(width:  r.atomicPadding),
                    Text(
                      _useManualLocation ?  'Manual' : 'GPS',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        fontWeight:  FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: r. microPadding),
        if (_useManualLocation)
          _buildManualLocationFields(r)
        else
          _buildGPSLocationCard(r),
      ],
    );
  }

  Widget _buildGPSLocationCard(EmployeeResponsiveData r) {
    final isSuccess = _position != null && _locationError == null;
    final isError = _locationError != null;
    final color = isError ? ReportsDesign.error : ReportsDesign.primaryTeal;

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: color. withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border. all(color: color.withOpacity(0.2)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      Row(
      children: [
      Container(
      padding: EdgeInsets.all(r.nanoPadding),
      decoration:  BoxDecoration(
        gradient: isError ?  null : ReportsDesign.primaryGradient,
        color: isError ? ReportsDesign.error : null,
        borderRadius: BorderRadius.circular(r.smallBorderRadius),
      ),
      child: Icon(
        Icons.gps_fixed_rounded,
        size: r.iconSize(16),
        color: Colors. white,
      ),
    ),
    SizedBox(width:  r.microPadding),
    Expanded(
    child: Text(
    'GPS Location (Auto)',
    style: GoogleFonts.inter(
    fontSize: r.captionL,
    fontWeight: FontWeight.w600,
    color: ReportsDesign.textPrimary,
    ),
    ),
    ),
    if (_isLoadingLocation)
    SizedBox(
    width: r.iconSize(18),
    height: r. iconSize(18),
    child: const CircularProgressIndicator(
    strokeWidth: 2,
    color: ReportsDesign.primaryTeal,
    ),
    )
    else if (isSuccess)
    Container(
    padding: EdgeInsets.all(r.atomicPadding),
    decoration: const BoxDecoration(
    color: ReportsDesign.success,
    shape: BoxShape.circle,
    ),
    child: Icon(
    Icons.check_rounded,
    size: r. iconSize(12),
    color: Colors. white,
    ),
    )
    else if (isError)
    GestureDetector(
    onTap: _captureLocation,
    child:  Container(
    padding: EdgeInsets.symmetric(
    horizontal: r. microPadding,
    vertical: r.nanoPadding,
    ),
    decoration: BoxDecoration(
    color: ReportsDesign. error,
    borderRadius:  BorderRadius.circular(r.smallBorderRadius),
    ),
    child: Text(
    'Retry',
    style: GoogleFonts.inter(
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
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: ReportsDesign.textSecondary,
    ),
    )
    else if (isError)
    Text(
    _locationError! ,
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: ReportsDesign.error,
    ),
    )
    else if (isSuccess) ...[
    Container(
    padding: EdgeInsets.all(r.microPadding),
    decoration:  BoxDecoration(
    color:  ReportsDesign.surfacePure,
    borderRadius: BorderRadius.circular(r. borderRadius),
    ),
    child: Row(
    children: [
    Expanded(
    child: Column(
    crossAxisAlignment:  CrossAxisAlignment.start,
    children: [
    Text(
    'Coordinates',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    color: ReportsDesign.textTertiary,
    ),
    ),
    Text(
    '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude. toStringAsFixed(6)}',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    fontWeight: FontWeight.w600,
    color: ReportsDesign.textPrimary,
    ),
    ),
    ],
    ),
    ),
    Container(
    padding: EdgeInsets.symmetric(
    horizontal: r.microPadding,
    vertical:  r.nanoPadding,
    ),
    decoration:  BoxDecoration(
    color: ReportsDesign.success. withOpacity(0.1),
    borderRadius: BorderRadius.circular(r.smallBorderRadius),
    ),
    child: Text(
    '±${_position!.accuracy.toStringAsFixed(0)}m',
    style:  GoogleFonts.inter(
    fontSize: r.captionXS,
    fontWeight: FontWeight.w700,
    color: ReportsDesign.success,
    ),
    ),
    ),
    ],
    ),
    ),
    if (_address != null) ...[
    SizedBox(height: r.microPadding),
    Text(
    'Address',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    color: ReportsDesign.textTertiary,
    ),
    ),
    Text(
    _address!,
    style: GoogleFonts. inter(
    fontSize: r.captionM,
    color: ReportsDesign.textPrimary,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    ),
    ],
    ],
    ],
    ),
    );
  }

  Widget _buildManualLocationFields(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign. warning. withOpacity(0.05),
        borderRadius: BorderRadius. circular(r.largeBorderRadius),
        border: Border.all(color: ReportsDesign. warning.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment:  CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets. all(r.nanoPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ReportsDesign.warning,
                      ReportsDesign.warning.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(
                  Icons.edit_location_alt_rounded,
                  size:  r.iconSize(16),
                  color: Colors.white,
                ),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Manual Location',
                style: GoogleFonts. inter(
                  fontSize: r.captionL,
                  fontWeight: FontWeight.w600,
                  color: ReportsDesign.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  r,
                  _latController,
                  'Latitude',
                  'e.g., 31.7167',
                ),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: _buildTextField(
                  r,
                  _lngController,
                  'Longitude',
                  'e.g., 73.9850',
                ),
              ),
            ],
          ),
          SizedBox(height: r. microPadding),
          _buildTextField(
            r,
            _addressController,
            'Address (Optional)',
            'Enter address or area name',
            isNumeric: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      EmployeeResponsiveData r,
      TextEditingController controller,
      String label,
      String hint, {
        bool isNumeric = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: r.captionXS,
            color: ReportsDesign.textSecondary,
          ),
        ),
        SizedBox(height: r.atomicPadding),
        Container(
          decoration: BoxDecoration(
            color: ReportsDesign.surfacePure,
            borderRadius:  BorderRadius.circular(r.borderRadius),
            boxShadow: ReportsDesign.softShadow,
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric
                ? const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            )
                : TextInputType.text,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: ReportsDesign.textPrimary,
            ),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts. inter(
                fontSize: r. captionM,
                color:  ReportsDesign.textTertiary,
              ),
              contentPadding: EdgeInsets. symmetric(
                horizontal: r. microPadding,
                vertical: r.microPadding,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r.borderRadius),
                borderSide: BorderSide. none,
              ),
              filled: true,
              fillColor: ReportsDesign. surfacePure,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampSection(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ReportsDesign.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border. all(color: ReportsDesign.info.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors:  [
                  ReportsDesign.info,
                  ReportsDesign.info.withOpacity(0.8),
                ],
              ),
              borderRadius:  BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Icon(
              Icons.access_time_rounded,
              size: r.iconSize(16),
              color: Colors.white,
            ),
          ),
          SizedBox(width: r. microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completion Timestamp',
                  style: GoogleFonts.inter(
                    fontSize: r.captionL,
                    fontWeight: FontWeight.w600,
                    color: ReportsDesign.textPrimary,
                  ),
                ),
                Text(
                  _formatTimestamp(_captureTime! ),
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    color: ReportsDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(r.atomicPadding),
            decoration: const BoxDecoration(
              color:  ReportsDesign.success,
              shape: BoxShape. circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: r.iconSize(12),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInfoBanner(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:  [
            ReportsDesign. purple. withOpacity(0.08),
            ReportsDesign. purple.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: ReportsDesign.purple.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ReportsDesign.purple,
                  ReportsDesign.purple.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
              boxShadow: ReportsDesign.glowShadow(ReportsDesign.purple),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: r.iconSize(18),
              color: Colors.white,
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Verification',
                  style: GoogleFonts.inter(
                    fontSize: r.captionL,
                    fontWeight: FontWeight.w700,
                    color: ReportsDesign.purple,
                  ),
                ),
                SizedBox(height:  r.atomicPadding),
                Text(
                  'Your cleanup image will be analyzed by AI.  If remaining waste is detected, you\'ll be asked to complete the cleanup.',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: ReportsDesign.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(EmployeeResponsiveData r, double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.microPadding,
        r. padding,
        bottomPad + r.microPadding,
      ),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        boxShadow: [
          BoxShadow(
            color:  Colors.black. withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: r.buttonHeight,
              decoration: BoxDecoration(
                border: Border.all(color: ReportsDesign.textLight),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight.w600,
                        color: ReportsDesign.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: r.buttonHeight,
              decoration: BoxDecoration(
                gradient: _canSubmit()
                    ? ReportsDesign.successGradient
                    : const LinearGradient(
                  colors: [
                    ReportsDesign.textLight,
                    ReportsDesign.textLight,
                  ],
                ),
                borderRadius: BorderRadius. circular(r.borderRadius),
                boxShadow: _canSubmit()
                    ?  ReportsDesign.glowShadow(ReportsDesign.success)
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _canSubmit() ? _submit :  null,
                  borderRadius:  BorderRadius.circular(r.borderRadius),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size:  r.iconSize(18),
                        color: _canSubmit()
                            ? Colors.white
                            : ReportsDesign.textTertiary,
                      ),
                      SizedBox(width:  r.nanoPadding),
                      Text(
                        r.adaptiveText(
                          'Submit for Verification',
                          nano: 'Submit',
                          micro: 'Submit',
                          mini: 'Verify',
                        ),
                        style: GoogleFonts. inter(
                          fontSize: r.bodyS,
                          fontWeight:  FontWeight.w600,
                          color: _canSubmit()
                              ?  Colors.white
                              : ReportsDesign.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour. toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}