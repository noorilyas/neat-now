import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// ResolveWithPhotoSheet - Upload verification photo with location
/// Camera: Auto-detect GPS location
/// Gallery: Manual location entry
class ResolveWithPhotoSheet extends StatefulWidget {
  final Report report;
  final EmployeeResponsiveData responsive;
  final ImagePicker imagePicker;
  final Function(String?  imagePath, double? latitude, double?  longitude, String? locationAddress) onResolve;

  const ResolveWithPhotoSheet({
    super.key,
    required this.report,
    required this. responsive,
    required this.imagePicker,
    required this.onResolve,
  });

  @override
  State<ResolveWithPhotoSheet> createState() => _ResolveWithPhotoSheetState();
}

class _ResolveWithPhotoSheetState extends State<ResolveWithPhotoSheet> {
  File? _selectedImage;
  bool _isUploading = false;
  bool _isGettingLocation = false;
  bool _isFromCamera = false;

  // Location data
  double? _latitude;
  double? _longitude;
  String? _locationAddress;

  // Manual location controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _latController.dispose();
    _lngController. dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      setState(() => _isGettingLocation = true);

      // Request location permission first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Pick image from camera
      final XFile? image = await widget.imagePicker. pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isFromCamera = true;
        });

        // Auto-get location from GPS
        if (permission == LocationPermission. always || permission == LocationPermission.whileInUse) {
          try {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 10),
            );

            _latitude = position.latitude;
            _longitude = position.longitude;

            // Get address from coordinates
            try {
              final placemarks = await placemarkFromCoordinates(
                position.latitude,
                position.longitude,
              );

              if (placemarks.isNotEmpty) {
                final place = placemarks.first;

                _locationAddress = [
                  place.street,
                  place.subLocality,
                  place.locality,
                  place.postalCode,
                ]
                    .where((e) => e != null && e.toString().trim().isNotEmpty)
                    .join(', ');
              }
            } catch (e) {
              print("Error fetching address: $e");
            }


            setState(() {});
          } catch (e) {
            debugPrint('Error getting location: $e');
            _showLocationError();
          }
        } else {
          _showLocationError();
        }
      }

      setState(() => _isGettingLocation = false);
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await widget.imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isFromCamera = false;
          // Clear any auto-detected location
          _latitude = null;
          _longitude = null;
          _locationAddress = null;
        });

        // Show manual location entry dialog
        _showManualLocationDialog();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showLocationError() {
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(child: Text('Could not get location.  You can add it manually.')),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(10)),
        action: SnackBarAction(
          label: 'Add',
          textColor: Colors.white,
          onPressed: _showManualLocationDialog,
        ),
      ),
    );
  }

  void _showManualLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.responsive.largeBorderRadius)),
        title: Row(
          children: [
            Icon(Icons.edit_location_alt_rounded, color: const Color(0xFF2AC2AB), size: widget.responsive.iconSize(24)),
            SizedBox(width: widget.responsive.microPadding),
            Text('Add Location', style: GoogleFonts. poppins(fontWeight: FontWeight. bold, fontSize: widget.responsive.fontSize(16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the location where you resolved this report',
                style: GoogleFonts.poppins(fontSize: widget.responsive.fontSize(12), color: Colors.grey[600]),
              ),
              SizedBox(height: widget. responsive.padding),
              // Address field
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address / Location Description',
                  hintText: 'e.g., Main Street, Block A',
                  prefixIcon: const Icon(Icons.location_on_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget. responsive.borderRadius)),
                ),
                style: GoogleFonts.poppins(fontSize: widget.responsive.fontSize(13)),
                maxLines: 2,
              ),
              SizedBox(height: widget.responsive.padding),
              // Optional coordinates
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      decoration: InputDecoration(
                        labelText: 'Latitude (optional)',
                        hintText: 'e.g., 33.6844',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.responsive.borderRadius)),
                        contentPadding: EdgeInsets.symmetric(horizontal: widget.responsive.microPadding, vertical: widget. responsive.microPadding),
                      ),
                      style: GoogleFonts.poppins(fontSize: widget.responsive.fontSize(12)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  SizedBox(width: widget.responsive. microPadding),
                  Expanded(
                    child: TextField(
                      controller: _lngController,
                      decoration: InputDecoration(
                        labelText: 'Longitude (optional)',
                        hintText: 'e.g., 73.0479',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(widget.responsive.borderRadius)),
                        contentPadding: EdgeInsets.symmetric(horizontal: widget. responsive.microPadding, vertical: widget.responsive.microPadding),
                      ),
                      style: GoogleFonts.poppins(fontSize: widget. responsive.fontSize(12)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Skip', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _locationAddress = _addressController.text. isNotEmpty ? _addressController.text : null;
                _latitude = double.tryParse(_latController.text);
                _longitude = double. tryParse(_lngController.text);
              });
              Navigator. pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2AC2AB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.responsive.borderRadius)),
            ),
            child: Text('Save', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(widget.responsive. extraLargeBorderRadius)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets. all(widget.responsive.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets. only(bottom: widget.responsive. padding),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),

            // Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(widget.responsive. microPadding),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2AC2AB). withOpacity(0.1),
                    borderRadius: BorderRadius.circular(widget.responsive.borderRadius),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: const Color(0xFF2AC2AB), size: widget. responsive.iconSize(22)),
                ),
                SizedBox(width: widget.responsive.padding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment. start,
                    children: [
                      Text(
                        'Resolve Report',
                        style: GoogleFonts.poppins(fontSize: widget.responsive.fontSize(16), fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Upload verification photo',
                        style: GoogleFonts. poppins(fontSize: widget.responsive. fontSize(11), color: Colors. grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: widget.responsive.padding),

            // Report info
            Container(
              padding: EdgeInsets.all(widget.responsive.microPadding),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(widget.responsive. borderRadius),
              ),
              child: Row(
                children: [
                  if (widget.report.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(widget.responsive.borderRadius),
                      child: Image.network(
                        widget.report.imageUrl!,
                        width: widget.responsive.thumbnailSize,
                        height: widget.responsive. thumbnailSize,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: widget.responsive.thumbnailSize,
                          height: widget.responsive.thumbnailSize,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                      ),
                    ),
                  SizedBox(width: widget.responsive.padding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment. start,
                      children: [
                        Text(
                          widget.report.type,
                          style: GoogleFonts. poppins(fontSize: widget.responsive. fontSize(13), fontWeight: FontWeight.w600),
                        ),
                        Text(
                          widget.report.location,
                          style: GoogleFonts.poppins(fontSize: widget.responsive.fontSize(11), color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow. ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: widget.responsive.padding),

            // Photo selection area
            if (_selectedImage == null)
              _buildPhotoSelectionArea()
            else
              _buildSelectedPhotoArea(),

            SizedBox(height: widget.responsive.padding),

            // Location info (if available)
            if (_latitude != null || _locationAddress != null)
              _buildLocationInfo(),

            SizedBox(height: widget.responsive.padding),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, widget.responsive.buttonHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.responsive.borderRadius)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.poppins(fontSize: widget.responsive. fontSize(13))),
                  ),
                ),
                SizedBox(width: widget.responsive.padding),
                Expanded(
                  flex: 2,
                  child: ElevatedButton. icon(
                    onPressed: _isUploading
                        ? null
                        : () {
                      HapticFeedback.heavyImpact();
                      widget.onResolve(
                        _selectedImage?. path,
                        _latitude,
                        _longitude,
                        _locationAddress,
                      );
                    },
                    icon: _isUploading
                        ? SizedBox(
                      width: widget.responsive.dimension(18),
                      height: widget.responsive. dimension(18),
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Icon(Icons.check_rounded, size: widget. responsive.iconSize(20)),
                    label: Text(
                      _isUploading ? 'Uploading.. .' : 'Resolve Report',
                      style: GoogleFonts.poppins(fontSize: widget.responsive.fontSize(13), fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2AC2AB),
                      foregroundColor: Colors. white,
                      minimumSize: Size(0, widget. responsive.buttonHeight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget. responsive.borderRadius)),
                    ),
                  ),
                ),
              ],
            ),

            // Note
            SizedBox(height: widget.responsive.microPadding),
            Container(
              padding: EdgeInsets.all(widget.responsive. microPadding),
              decoration: BoxDecoration(
                color: Colors.orange. withOpacity(0.1),
                borderRadius: BorderRadius.circular(widget. responsive.borderRadius),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.orange, size: widget.responsive. iconSize(16)),
                  SizedBox(width: widget.responsive.microPadding),
                  Expanded(
                    child: Text(
                      'Photo is recommended but optional',
                      style: GoogleFonts.poppins(fontSize: widget.responsive.fontSize(10), color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + widget.responsive.padding),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSelectionArea() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets. all(widget.responsive.largePadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius. circular(widget.responsive.largeBorderRadius),
        border: Border.all(color: Colors. grey. withOpacity(0.2), width: 2, style: BorderStyle. none),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(widget.responsive. padding),
            decoration: BoxDecoration(
              color: const Color(0xFF2AC2AB). withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_a_photo_rounded,
              color: const Color(0xFF2AC2AB),
              size: widget. responsive.dimension(36),
            ),
          ),
          SizedBox(height: widget.responsive.padding),
          Text(
            'Add Verification Photo',
            style: GoogleFonts.poppins(fontSize: widget. responsive.fontSize(14), fontWeight: FontWeight.w600),
          ),
          SizedBox(height: widget.responsive. microPadding),
          Text(
            'Take a photo of the cleaned area',
            style: GoogleFonts.poppins(fontSize: widget.responsive.fontSize(11), color: Colors.grey[600]),
          ),
          SizedBox(height: widget.responsive.padding),
          Row(
            children: [
              Expanded(
                child: _buildSourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  sublabel: 'Auto location',
                  color: const Color(0xFF2AC2AB),
                  onTap: _isGettingLocation ?  null : _pickFromCamera,
                  isLoading: _isGettingLocation,
                ),
              ),
              SizedBox(width: widget. responsive.padding),
              Expanded(
                child: _buildSourceButton(
                  icon: Icons. photo_library_rounded,
                  label: 'Gallery',
                  sublabel: 'Manual location',
                  color: Colors.blue,
                  onTap: _pickFromGallery,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(widget.responsive. padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.responsive. borderRadius),
          border: Border.all(color: color. withOpacity(0.3)),
        ),
        child: Column(
          children: [
            isLoading
                ?  SizedBox(
              width: widget. responsive.dimension(28),
              height: widget.responsive. dimension(28),
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
                : Icon(icon, color: color, size: widget.responsive.dimension(28)),
            SizedBox(height: widget.responsive.microPadding),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: widget. responsive.fontSize(12),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              sublabel,
              style: GoogleFonts. poppins(
                fontSize: widget. responsive.fontSize(9),
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedPhotoArea() {
    return Container(
      width: double.infinity,
      height: widget.responsive.dimension(200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius. circular(widget.responsive.largeBorderRadius),
        border: Border.all(color: const Color(0xFF2AC2AB), width: 2),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(widget. responsive.largeBorderRadius - 2),
            child: Image.file(
              _selectedImage! ,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Remove button
          Positioned(
            top: widget.responsive.microPadding,
            right: widget. responsive.microPadding,
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedImage = null;
                _latitude = null;
                _longitude = null;
                _locationAddress = null;
                _isFromCamera = false;
              }),
              child: Container(
                padding: EdgeInsets. all(widget.responsive.microPadding),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, color: Colors.white, size: widget. responsive.iconSize(18)),
              ),
            ),
          ),
          // Source indicator
          Positioned(
            bottom: widget.responsive.microPadding,
            left: widget.responsive.microPadding,
            child: Container(
              padding: EdgeInsets. symmetric(
                horizontal: widget. responsive.microPadding,
                vertical: widget.responsive. nanoPadding,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2AC2AB),
                borderRadius: BorderRadius. circular(widget.responsive.borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isFromCamera ? Icons.camera_alt_rounded : Icons.photo_library_rounded,
                    color: Colors.white,
                    size: widget. responsive.iconSize(14),
                  ),
                  SizedBox(width: widget.responsive.nanoPadding),
                  Text(
                    _isFromCamera ? 'Camera' : 'Gallery',
                    style: GoogleFonts.poppins(
                      fontSize: widget.responsive.fontSize(10),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Edit location button (for gallery)
          if (! _isFromCamera)
            Positioned(
              bottom: widget.responsive.microPadding,
              right: widget.responsive.microPadding,
              child: GestureDetector(
                onTap: _showManualLocationDialog,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget. responsive.microPadding,
                    vertical: widget.responsive.nanoPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius. circular(widget.responsive.borderRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_location_alt_rounded, color: Colors.white, size: widget. responsive.iconSize(14)),
                      SizedBox(width: widget.responsive. nanoPadding),
                      Text(
                        _locationAddress != null ?  'Edit' : 'Add Location',
                        style: GoogleFonts.poppins(
                          fontSize: widget.responsive.fontSize(10),
                          color: Colors. white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: EdgeInsets.all(widget.responsive.microPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF2AC2AB). withOpacity(0.1),
        borderRadius: BorderRadius.circular(widget. responsive.borderRadius),
        border: Border.all(color: const Color(0xFF2AC2AB). withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _isFromCamera ? Icons. gps_fixed_rounded : Icons.edit_location_alt_rounded,
            color: const Color(0xFF2AC2AB),
            size: widget.responsive. iconSize(18),
          ),
          SizedBox(width: widget.responsive.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isFromCamera ? 'Auto-detected Location' : 'Manual Location',
                  style: GoogleFonts.poppins(
                    fontSize: widget. responsive.fontSize(10),
                    color: const Color(0xFF2AC2AB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _locationAddress ?? 'Lat: ${_latitude?.toStringAsFixed(4)}, Lng: ${_longitude?.toStringAsFixed(4)}',
                  style: GoogleFonts.poppins(fontSize: widget.responsive. fontSize(11), color: Colors. grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (! _isFromCamera)
            GestureDetector(
              onTap: _showManualLocationDialog,
              child: Icon(Icons.edit_rounded, color: Colors. grey[600], size: widget.responsive.iconSize(18)),
            ),
        ],
      ),
    );
  }
}

// ==================== SUCCESS ANIMATION DIALOG ====================

class SuccessAnimationDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const SuccessAnimationDialog({super.key, required this.onComplete});

  @override
  State<SuccessAnimationDialog> createState() => _SuccessAnimationDialogState();
}

class _SuccessAnimationDialogState extends State<SuccessAnimationDialog> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    _checkController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.easeOutQuart);

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _checkController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController. dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white. withOpacity(0.97),
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF2AC2AB), Color(0xFF1FA896)]),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF2AC2AB).withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                  ],
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _checkAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(55, 55),
                        painter: _CheckPainter(_checkAnimation. value),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {                return Opacity(
                  opacity: _scaleAnimation.value.  clamp(0.0, 1.0),
                  child: Column(
                    children: [
                      Text(
                        'Report Resolved! ',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight. bold,
                          color: Colors.  grey[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thank you for your service',
                        style: GoogleFonts. poppins(
                          fontSize: 15,
                          color: Colors. grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2AC2AB).  withOpacity(0.1),
                          borderRadius: BorderRadius.  circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco_rounded, size: 18, color: Color(0xFF2AC2AB)),
                            const SizedBox(width: 8),
                            Text(
                              'Making the world cleaner',
                              style: GoogleFonts. poppins(
                                fontSize: 12,
                                color: const Color(0xFF2AC2AB),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                },
            ),
              ],
            ),
        ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;

  _CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors. white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final start = Offset(size.width * 0.2, size.height * 0.5);
    final mid = Offset(size.width * 0.42, size.height * 0.7);
    final end = Offset(size.width * 0.8, size.height * 0.28);

    if (progress < 0.5) {
      final p = progress * 2;
      path.moveTo(start.dx, start.dy);
      path.lineTo(
        start.dx + (mid.dx - start.dx) * p,
        start. dy + (mid. dy - start.dy) * p,
      );
    } else {
      path.moveTo(start.dx, start.  dy);
      path.lineTo(mid.dx, mid. dy);
      final p = (progress - 0.5) * 2;
      path.lineTo(
        mid.  dx + (end.  dx - mid. dx) * p,
        mid.dy + (end.dy - mid.dy) * p,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => oldDelegate.  progress != progress;
}