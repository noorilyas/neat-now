import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/viewmodels/user/report_waste_viewmodel.dart';
import 'package:neat_now/models/user/search_result_model.dart';

/// ==================== USER REPORT WASTE PAGE ====================
class UserReportWastePage extends StatefulWidget {
  final Map<String, dynamic>?   userData;
  final Function(Map<String, dynamic>) onSubmit;

  const UserReportWastePage({
    super.key,
    this.userData,
    required this.onSubmit,
  });

  @override
  State<UserReportWastePage> createState() => _UserReportWastePageState();
}

class _UserReportWastePageState extends State<UserReportWastePage>
    with TickerProviderStateMixin {
  late ReportWasteViewModel _viewModel;
  late PageController _pageController;
  late MapController _mapController;
  late TextEditingController _descriptionController;
  late TextEditingController _searchController;

  Key _mapKey = UniqueKey();
  bool _isMapReady = false;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _pinBounceController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pinBounceAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize ViewModel
    _viewModel = ReportWasteViewModel(
      userId: widget.userData?['id'],
    );
    _viewModel.addListener(_onViewModelChanged);

    // Controllers
    _pageController = PageController();
    _mapController = MapController();
    _descriptionController = TextEditingController();
    _searchController = TextEditingController();

    _initAnimations();
    _startAnimations();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve:  Curves.easeInOut),
    );

    _pinBounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pinBounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _pinBounceController, curve: Curves. easeOut),
    );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      _fadeController.forward();
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _pinBounceController.dispose();
    _pageController.dispose();
    _mapController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Navigation
  void _nextStep() {
    if (_viewModel.canProceed()) {
      HapticFeedback.lightImpact();
      _viewModel.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves. easeOutCubic,
      );
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _previousStep() {
    if (_viewModel.currentStep > 0) {
      HapticFeedback.lightImpact();
      _viewModel.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds:  350),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.pop(context);
    }
  }

  // Image capture
  Future<void> _captureImage(ImageSource source) async {
    HapticFeedback.mediumImpact();
    final success = await _viewModel.captureImage(source);
    if (!  success) {
      _showSnackBar('Failed to capture image', isError: true);
    } else if (source == ImageSource.  gallery) {
      _openLocationPicker();
    }
  }

  // Location picker
  void _openLocationPicker() {
    _mapController.dispose();
    _mapController = MapController();
    setState(() {
      _mapKey = UniqueKey();
      _isMapReady = false;
    });
    _viewModel.openLocationPicker();
  }

  void _onMapPositionChanged(MapCamera position, bool hasGesture) {
    if (hasGesture && ! _viewModel.isDraggingMap) {
      _viewModel.  setMapDragging(true);
      _pinBounceController.forward();
    }
  }

  void _onMapMoveEnd() async {
    if (_viewModel. isDraggingMap && _isMapReady) {
      _viewModel.setMapDragging(false);
      _pinBounceController.reverse();

      try {
        final center = _mapController.camera.center;
        await _viewModel.updateLocationAndAddress(center);
      } catch (e) {
        debugPrint('Error getting map center: $e');
      }
    }
  }

  void _searchLocation(String query) {
    _viewModel.searchLocation(query);
  }

  void _selectSearchResult(SearchResultModel result) async {
    HapticFeedback.selectionClick();
    _searchController.clear();

    try {
      if (_isMapReady) {
        _mapController.move(result.location, 16);
      }
      await _viewModel.updateLocationAndAddress(result.location);
    } catch (e) {
      debugPrint('Error selecting search result: $e');
    }
  }

  void _goToMyLocation() async {
    HapticFeedback.lightImpact();
    final success = await _viewModel.fetchCurrentLocation();
    if (success && _isMapReady && _viewModel.selectedLocation != null) {
      _mapController.move(_viewModel. selectedLocation!, 16);
    } else {
      _showSnackBar('Could not get current location', isError: true);
    }
  }

  // Submit
  Future<void> _submitReport() async {
    _viewModel.setDescription(_descriptionController.text);
    final reportData = await _viewModel.submitReport();

    if (reportData != null) {
      widget.onSubmit(reportData. toMap());
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (! mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: GoogleFonts.inter(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: isError ? UserDesign.error : UserDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildImageWidget({
    required double height,
    required double width,
    required BoxFit fit,
  }) {
    if (_viewModel.capturedImageFile == null) {
      return Container(
        height: height,
        width: width,
        color: UserDesign.surfaceLight,
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
    }

    if (kIsWeb) {
      return Image.network(
        _viewModel.capturedImageFile!.path,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: UserDesign.surfaceLight,
            child: const Center(child: Icon(Icons. broken_image)),
          );
        },
      );
    } else {
      return Image.file(
        File(_viewModel.capturedImageFile!.path),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: UserDesign.surfaceLight,
            child: const Center(child: Icon(Icons.broken_image)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = UserResponsiveData.of(context);

    return Scaffold(
      backgroundColor: UserDesign.surfaceLight,
      body: Stack(
        children: [
          // Main Content
          Column(
            children: [
              if (! _viewModel.showLocationPicker) _buildAppBar(r),
              if (! _viewModel.showLocationPicker) _buildProgressIndicator(r),
              Expanded(
                child: _viewModel.showLocationPicker
                    ? const SizedBox. shrink()
                    : PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children:  [
                    _buildCaptureStep(r),
                    _buildLocationStep(r),
                    _buildReviewStep(r),
                  ],
                ),
              ),
              if (! _viewModel.showLocationPicker) _buildBottomActions(r),
            ],
          ),

          // Location Picker Overlay
          if (_viewModel. showLocationPicker) _buildLocationPickerOverlay(r),

          // AI Verification Overlay
          if (_viewModel. showAIVerification) _buildAIVerificationOverlay(r),
        ],
      ),
    );
  }

  // ==================== APP BAR ====================
  Widget _buildAppBar(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.safePaddingTop + r.microPadding,
        r. padding,
        r.microPadding,
      ),
      decoration: BoxDecoration(
        color: UserDesign.surfacePure,
        boxShadow: UserDesign.softShadow,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _previousStep,
            child: Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration:  BoxDecoration(
                color:  UserDesign.surfaceLight,
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child:  Icon(
                _viewModel.currentStep == 0
                    ? Icons. close_rounded
                    : Icons. arrow_back_ios_new_rounded,
                color: UserDesign.textSecondary,
                size: r.iconSize(20),
              ),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Waste',
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign.textPrimary,
                  ),
                ),
                Text(
                  'Step ${_viewModel.currentStep + 1} of ${_viewModel. steps.length}:  ${_viewModel.steps[_viewModel.currentStep]}',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: UserDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical: r. nanoPadding,
            ),
            decoration: BoxDecoration(
              gradient: UserDesign.primaryGradient,
              borderRadius: BorderRadius.circular(r. pillBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: r.iconSize(14)),
                SizedBox(width: r.atomicPadding),
                Text(
                  '${_viewModel.currentStep + 1}/${_viewModel.steps.length}',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROGRESS INDICATOR ====================
  Widget _buildProgressIndicator(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      child: Row(
        children: List.generate(_viewModel.steps.length * 2 - 1, (index) {
          if (index. isOdd) {
            final stepIndex = index ~/ 2;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 3,
                decoration: BoxDecoration(
                  color: stepIndex < _viewModel.currentStep
                      ? UserDesign.primaryTeal
                      : UserDesign.surfaceOverlay,
                  borderRadius:  BorderRadius.circular(2),
                ),
              ),
            );
          } else {
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < _viewModel.currentStep;
            final isCurrent = stepIndex == _viewModel. currentStep;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: r.dimension(32),
              height: r.dimension(32),
              decoration: BoxDecoration(
                gradient:
                isCompleted || isCurrent ?  UserDesign.primaryGradient : null,
                color: ! isCompleted && !isCurrent
                    ?  UserDesign.surfaceOverlay
                    : null,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? UserDesign.glowShadow(UserDesign.primaryTeal)
                    : null,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(Icons.check_rounded,
                    color: Colors.white, size: r.iconSize(16))
                    : Text(
                  '${stepIndex + 1}',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w700,
                    color: isCurrent
                        ? Colors.white
                        : UserDesign.textTertiary,
                  ),
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  // ==================== BOTTOM ACTIONS ====================
  Widget _buildBottomActions(UserResponsiveData r) {
    final canProceed = _viewModel.canProceed();
    final isLastStep = _viewModel.currentStep == _viewModel.steps.length - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.microPadding,
        r. padding,
        r.safePaddingBottom + r.padding,
      ),
      decoration: BoxDecoration(
        color:  UserDesign.surfacePure,
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
          if (_viewModel.currentStep > 0)
            Expanded(
              child: GestureDetector(
                onTap: _previousStep,
                child: Container(
                  height: r.buttonHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: UserDesign.primaryTeal),
                    borderRadius: BorderRadius.circular(r. borderRadius),
                  ),
                  child: Center(
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight.w600,
                        color: UserDesign.primaryTeal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_viewModel.currentStep > 0) SizedBox(width: r.microPadding),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: canProceed ? (isLastStep ? _submitReport : _nextStep) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: r.buttonHeight,
                decoration: BoxDecoration(
                  gradient: canProceed ?  UserDesign.primaryGradient : null,
                  color: canProceed ? null : UserDesign.textLight,
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  boxShadow: canProceed
                      ? UserDesign.glowShadow(UserDesign.primaryTeal)
                      : null,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastStep ? 'Submit Report' : 'Continue',
                        style: GoogleFonts.inter(
                          fontSize: r.bodyS,
                          fontWeight: FontWeight.w700,
                          color: canProceed
                              ? Colors.white
                              : UserDesign.textTertiary,
                        ),
                      ),
                      if (! isLastStep) ...[
                        SizedBox(width: r.nanoPadding),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: canProceed
                              ? Colors.white
                              : UserDesign.textTertiary,
                          size: r.iconSize(18),
                        ),
                      ],
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

  // ==================== STEP 1: CAPTURE ====================
  Widget _buildCaptureStep(UserResponsiveData r) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position:  _slideAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(r.padding),
          child: Column(
            children: [
              _viewModel.capturedImageFile != null
                  ? _buildImagePreview(r)
                  :  _buildCaptureArea(r),

              SizedBox(height: r.padding),

              if (_viewModel.capturedImageFile == null)
                _buildCaptureOptions(r)
              else
                _buildImageActions(r),

              SizedBox(height: r.padding),

              _buildCaptureTips(r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureArea(UserResponsiveData r) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => _captureImage(ImageSource.camera),
        child: Container(
          height: r.dimension(280),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:  [
                UserDesign.primaryTeal. withOpacity(0.1),
                UserDesign.primaryTealLight.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
            border: Border.all(
              color: UserDesign.primaryTeal. withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(r.largePadding),
                decoration:  BoxDecoration(
                  gradient: UserDesign.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
                ),
                child:  Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: r.iconSize(48)),
              ),
              SizedBox(height: r.padding),
              Text(
                'Tap to Capture',
                style:  GoogleFonts.inter(
                  fontSize: r.bodyM,
                  fontWeight: FontWeight.w700,
                  color: UserDesign.textPrimary,
                ),
              ),
              SizedBox(height: r.nanoPadding),
              Text(
                'Take a clear photo of the waste',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: UserDesign.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(UserResponsiveData r) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(r. extraLargeBorderRadius),
          child: _buildImageWidget(
            height: r.dimension(280),
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // SOURCE BADGE
        Positioned(
          top: r.microPadding,
          left: r.microPadding,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical: r. nanoPadding,
            ),
            decoration: BoxDecoration(
              color: _viewModel.imageSource == ImageSource.camera
                  ? UserDesign.success
                  : UserDesign. info,
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _viewModel.imageSource == ImageSource.camera
                      ? Icons.camera_alt_rounded
                      : Icons.photo_library_rounded,
                  color:  Colors.white,
                  size: r.iconSize(14),
                ),
                SizedBox(width: r.atomicPadding),
                Text(
                  _viewModel.imageSource == ImageSource.camera
                      ? 'Camera'
                      : 'Gallery',
                  style: GoogleFonts. inter(
                    fontSize: r.captionS,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // TIMESTAMP BADGE
        if (_viewModel.captureTimestamp != null)
          Positioned(
            bottom: r.microPadding,
            left: r.microPadding,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r.nanoPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded,
                      color: Colors.white, size: r.iconSize(14)),
                  SizedBox(width: r.atomicPadding),
                  Text(
                    _viewModel.formatTimestamp(_viewModel.captureTimestamp! ),
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // LOCATION BADGE
        if (_viewModel.selectedLocation != null)
          Positioned(
            bottom: r.microPadding,
            right: r.microPadding,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r.nanoPadding,
              ),
              decoration: BoxDecoration(
                color: UserDesign.success,
                borderRadius: BorderRadius. circular(r.pillBorderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      color: Colors. white, size: r.iconSize(14)),
                  SizedBox(width: r.atomicPadding),
                  Text(
                    'Location Set',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // LOADING OVERLAY
        if (_viewModel.isLoadingLocation)
          Positioned. fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: r. microPadding),
                    Text(
                      'Getting location...',
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCaptureOptions(UserResponsiveData r) {
    return Row(
      children: [
        Expanded(
          child: _buildCaptureOptionCard(
            r,
            icon: Icons.camera_alt_rounded,
            label: 'Camera',
            sublabel: 'Auto GPS location',
            color: UserDesign.primaryTeal,
            badge: 'Recommended',
            onTap: () => _captureImage(ImageSource.camera),
          ),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: _buildCaptureOptionCard(
            r,
            icon: Icons.photo_library_rounded,
            label:  'Gallery',
            sublabel: 'Set location manually',
            color: UserDesign.purple,
            onTap: () => _captureImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureOptionCard(
      UserResponsiveData r, {
        required IconData icon,
        required String label,
        required String sublabel,
        required Color color,
        String? badge,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: UserDesign.surfacePure,
          borderRadius: BorderRadius. circular(r.largeBorderRadius),
          border: Border.all(color: color. withOpacity(0.2)),
          boxShadow: UserDesign.softShadow,
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                margin: EdgeInsets.only(bottom: r.nanoPadding),
                padding: EdgeInsets.symmetric(
                  horizontal: r. nanoPadding,
                  vertical: r.atomicPadding,
                ),
                decoration: BoxDecoration(
                  color: color. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts. inter(
                    fontSize: r.captionXS,
                    fontWeight:  FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration:  BoxDecoration(
                color:  color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Icon(icon, color: color, size: r.iconSize(28)),
            ),
            SizedBox(height: r.microPadding),
            Text(
              label,
              style:  GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
                color: UserDesign.textPrimary,
              ),
            ),
            Text(
              sublabel,
              style: GoogleFonts.inter(
                fontSize: r.captionXS,
                color: UserDesign.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageActions(UserResponsiveData r) {
    return Wrap(
      spacing: r.microPadding,
      runSpacing: r.microPadding,
      alignment: WrapAlignment.center,
      children: [
        // Change Photo Button
        GestureDetector(
          onTap: () {
            _viewModel.clearImage();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.padding,
              vertical: r.microPadding,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: UserDesign.primaryTeal),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded,
                    color: UserDesign.primaryTeal, size: r.iconSize(18)),
                SizedBox(width: r.nanoPadding),
                Text(
                  'Change Photo',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w600,
                    color: UserDesign.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Set/Change Location Button
        if (_viewModel.selectedLocation == null ||
            _viewModel.imageSource == ImageSource.gallery)
          GestureDetector(
            onTap: _openLocationPicker,
            child: Container(
              padding: EdgeInsets. symmetric(
                horizontal: r. padding,
                vertical: r. microPadding,
              ),
              decoration: BoxDecoration(
                gradient: _viewModel.selectedLocation == null
                    ? UserDesign.primaryGradient
                    : null,
                border: _viewModel.selectedLocation != null
                    ? Border.all(color: UserDesign.info)
                    : null,
                borderRadius: BorderRadius.circular(r.borderRadius),
                boxShadow: _viewModel.selectedLocation == null
                    ? UserDesign.glowShadow(UserDesign.primaryTeal)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize. min,
                children: [
                  Icon(
                    _viewModel.selectedLocation == null
                        ? Icons.add_location_rounded
                        : Icons. edit_location_rounded,
                    color: _viewModel.selectedLocation == null
                        ? Colors.white
                        : UserDesign.info,
                    size: r.iconSize(18),
                  ),
                  SizedBox(width: r.nanoPadding),
                  Text(
                    _viewModel.selectedLocation == null
                        ? 'Set Location'
                        : 'Change Location',
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight:  FontWeight.w600,
                      color: _viewModel.selectedLocation == null
                          ? Colors.white
                          : UserDesign.info,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCaptureTips(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color:  UserDesign.info. withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: UserDesign.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons. lightbulb_rounded,
                  color: UserDesign.info, size: r.iconSize(18)),
              SizedBox(width: r.nanoPadding),
              Text(
                'Tips for best results',
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  fontWeight: FontWeight.w600,
                  color: UserDesign.info,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          _buildTipRow(r, '📸', 'Use Camera for automatic GPS tagging'),
          _buildTipRow(r, '🗺️', 'Gallery photos require manual location selection'),
          _buildTipRow(r, '🎯', 'Ensure good lighting and focus on the waste'),
          _buildTipRow(r, '📐', 'Include surrounding area for context'),
        ],
      ),
    );
  }

  Widget _buildTipRow(UserResponsiveData r, String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(top: r.nanoPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: r.captionM)),
          SizedBox(width: r.nanoPadding),
          Expanded(
            child: Text(
              text,
              style:  GoogleFonts.inter(
                fontSize: r.captionS,
                color: UserDesign.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 2: LOCATION ====================
  Widget _buildLocationStep(UserResponsiveData r) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics:  const BouncingScrollPhysics(),
        padding: EdgeInsets.all(r.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationStatusCard(r),
            SizedBox(height: r.padding),
            if (_viewModel.selectedLocation != null) _buildMiniMapPreview(r),
            SizedBox(height: r.padding),
            _buildAddressDisplay(r),
            SizedBox(height: r.padding),
            _buildChangeLocationButton(r),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatusCard(UserResponsiveData r) {
    final hasLocation = _viewModel.selectedLocation != null;

    return Container(
      padding:  EdgeInsets.all(r. padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:  hasLocation
              ? [
            UserDesign.success.withOpacity(0.1),
            UserDesign.success.withOpacity(0.05)
          ]
              : [
            UserDesign.warning.withOpacity(0.1),
            UserDesign. warning.withOpacity(0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(
          color: hasLocation
              ? UserDesign.success. withOpacity(0.3)
              : UserDesign.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              gradient: hasLocation
                  ? UserDesign.successGradient
                  : LinearGradient(colors: [
                UserDesign.warning,
                UserDesign. warning.withOpacity(0.8)
              ]),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child:  Icon(
              hasLocation ?  Icons.check_circle_rounded : Icons.location_off_rounded,
              color: Colors.white,
              size: r.iconSize(20),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasLocation ? 'Location Set ✓' : 'Location Required',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w600,
                    color: hasLocation ? UserDesign.success :  UserDesign.warning,
                  ),
                ),
                if (hasLocation)
                  Text(
                    _viewModel.imageSource == ImageSource.camera
                        ? 'Auto-detected via GPS'
                        : 'Manually selected on map',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: UserDesign.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMapPreview(UserResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.map_rounded, color: UserDesign.info, size: r.iconSize(18)),
            SizedBox(width: r.nanoPadding),
            Text(
              'Location Preview',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                fontWeight: FontWeight.w600,
                color: UserDesign.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: r.microPadding),
        ClipRRect(
          borderRadius: BorderRadius.circular(r. largeBorderRadius),
          child: SizedBox(
            height: r.dimension(180),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _viewModel.selectedLocation! ,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.neatnow.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _viewModel.selectedLocation!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: UserDesign.primaryTeal,
                          shape:  BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow:
                          UserDesign.glowShadow(UserDesign.primaryTeal),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressDisplay(UserResponsiveData r) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address',
          style: GoogleFonts.inter(
            fontSize: r.captionM,
            fontWeight: FontWeight. w600,
            color: UserDesign.textSecondary,
          ),
        ),
        SizedBox(height: r.nanoPadding),
        Container(
          padding: EdgeInsets.all(r.padding),
          decoration: BoxDecoration(
            color: UserDesign.surfacePure,
            borderRadius: BorderRadius.circular(r. borderRadius),
            boxShadow: UserDesign. softShadow,
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: UserDesign.primaryTeal,
                size: r.iconSize(20),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Text(
                  _viewModel.selectedAddress. isNotEmpty
                      ? _viewModel.selectedAddress
                      :  'No address set',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    color: _viewModel.selectedAddress.isNotEmpty
                        ? UserDesign.textPrimary
                        : UserDesign.textTertiary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChangeLocationButton(UserResponsiveData r) {
    return GestureDetector(
      onTap: _openLocationPicker,
      child:  Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: r.microPadding),
        decoration: BoxDecoration(
          border: Border.all(color: UserDesign.primaryTeal),
          borderRadius:  BorderRadius.circular(r.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_location_rounded,
                color: UserDesign.primaryTeal, size: r.iconSize(18)),
            SizedBox(width: r.nanoPadding),
            Text(
              'Change Location on Map',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w600,
                color: UserDesign.primaryTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== LOCATION PICKER OVERLAY ====================
  Widget _buildLocationPickerOverlay(UserResponsiveData r) {
    final centerLocation = _viewModel.selectedLocation ??  _viewModel.defaultLocation;

    return Container(
      color: UserDesign.surfaceLight,
      child: Column(
        children: [
          _buildLocationPickerHeader(r),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  key: _mapKey,
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: centerLocation,
                    initialZoom: 16,
                    minZoom: 3,
                    maxZoom:  18,
                    onPositionChanged: _onMapPositionChanged,
                    onMapEvent: (event) {
                      if (event is MapEventMoveEnd) {
                        _onMapMoveEnd();
                      }
                    },
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag. all,
                    ),
                    onMapReady: () {
                      setState(() => _isMapReady = true);
                      if (_viewModel.selectedLocation == null) {
                        _viewModel.updateLocationAndAddress(centerLocation);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.neatnow.app',
                      maxZoom: 19,
                    ),
                  ],
                ),

                if (! _isMapReady)
                  Container(
                    color: UserDesign.surfaceLight,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: UserDesign.primaryTeal,
                          ),
                          SizedBox(height: r.microPadding),
                          Text(
                            'Loading map...',
                            style: GoogleFonts.inter(
                              fontSize: r.captionM,
                              color:  UserDesign.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_isMapReady)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation:  _pinBounceAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _pinBounceAnimation.value),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(r.microPadding),
                            decoration: BoxDecoration(
                              gradient: UserDesign.primaryGradient,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  UserDesign. primaryTeal. withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: r.iconSize(28),
                            ),
                          ),
                        ),
                        Container(
                          width: 3,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                UserDesign.primaryTeal,
                                UserDesign.primaryTeal.withOpacity(0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_isMapReady)
                  Center(
                    child:  Transform.translate(
                      offset: const Offset(0, 38),
                      child: Container(
                        width: 20,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.black. withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                if (_isMapReady)
                  Positioned(
                    right: r.padding,
                    bottom: r.dimension(180),
                    child: GestureDetector(
                      onTap: _goToMyLocation,
                      child: Container(
                        padding: EdgeInsets.all(r.microPadding),
                        decoration: BoxDecoration(
                          color: UserDesign. surfacePure,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius:  10,
                              offset:  const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.my_location_rounded,
                          color: UserDesign.primaryTeal,
                          size: r.iconSize(24),
                        ),
                      ),
                    ),
                  ),

                if (_viewModel.isLoadingLocation && _isMapReady)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          _buildLocationPickerBottom(r),
        ],
      ),
    );
  }

  Widget _buildLocationPickerHeader(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.safePaddingTop + r.microPadding,
        r.padding,
        r.microPadding,
      ),
      decoration: BoxDecoration(
        color: UserDesign.surfacePure,
        boxShadow: UserDesign.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _viewModel.closeLocationPicker(),
                child:  Container(
                  padding: EdgeInsets.all(r.microPadding),
                  decoration: BoxDecoration(
                    color: UserDesign.surfaceLight,
                    borderRadius:  BorderRadius.circular(r.borderRadius),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: UserDesign.textSecondary,
                    size: r.iconSize(20),
                  ),
                ),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                child: Text(
                  'Set Waste Location',
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          Container(
            decoration: BoxDecoration(
              color: UserDesign.surfaceLight,
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child:  TextField(
              controller: _searchController,
              onChanged: _searchLocation,
              style: GoogleFonts.inter(
                  fontSize: r.bodyS, color: UserDesign.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search location or address.. .',
                hintStyle: GoogleFonts.inter(
                    fontSize: r.captionM, color: UserDesign.textTertiary),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: UserDesign.textTertiary,
                  size: r.iconSize(20),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ?  GestureDetector(
                  onTap: () {
                    _searchController. clear();
                    _viewModel.clearSearchResults();
                  },
                  child: Icon(
                    Icons.close_rounded,
                    color:  UserDesign.textTertiary,
                    size: r.iconSize(20),
                  ),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets. symmetric(
                  horizontal: r.microPadding,
                  vertical:  r.microPadding,
                ),
              ),
            ),
          ),

          // Search Results
          if (_viewModel.searchResults.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: r.microPadding),
              constraints: BoxConstraints(maxHeight: r.dimension(200)),
              decoration: BoxDecoration(
                color: UserDesign.surfacePure,
                borderRadius:  BorderRadius.circular(r.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _viewModel.searchResults.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: UserDesign.surfaceOverlay,
                ),
                itemBuilder: (context, index) {
                  final result = _viewModel.searchResults[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Icons. location_on_rounded,
                      color: UserDesign.primaryTeal,
                      size: r.iconSize(20),
                    ),
                    title: Text(
                      result.address,
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: UserDesign.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),

          // Searching Indicator
          if (_viewModel.isSearching)
            Padding(
              padding: EdgeInsets.all(r.microPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: r.iconSize(16),
                    height: r. iconSize(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: UserDesign.primaryTeal,
                    ),
                  ),
                  SizedBox(width: r.microPadding),
                  Text(
                    'Searching...',
                    style: GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: UserDesign.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationPickerBottom(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.padding,
        r.padding,
        r.safePaddingBottom + r.padding,
      ),
      decoration: BoxDecoration(
        color:  UserDesign.surfacePure,
        borderRadius: BorderRadius.vertical(
          top: Radius. circular(r.extraLargeBorderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: r.dimension(40),
            height: r.dimension(4),
            margin: EdgeInsets.only(bottom: r.padding),
            decoration: BoxDecoration(
              color: UserDesign.textLight,
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
          ),

          // Address Display
          Container(
            width:  double.infinity,
            padding: EdgeInsets.all(r.padding),
            decoration: BoxDecoration(
              color: UserDesign.surfaceLight,
              borderRadius: BorderRadius.circular(r.largeBorderRadius),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.microPadding),
                  decoration: BoxDecoration(
                    color: UserDesign.primaryTeal. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: UserDesign.primaryTeal,
                    size: r.iconSize(22),
                  ),
                ),
                SizedBox(width:  r.microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Location',
                        style: GoogleFonts.inter(
                          fontSize: r.captionXS,
                          color: UserDesign.textTertiary,
                        ),
                      ),
                      SizedBox(height: r.atomicPadding),
                      _viewModel.isLoadingLocation
                          ? Row(
                        children: [
                          SizedBox(
                            width: r.iconSize(14),
                            height: r.iconSize(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: UserDesign.primaryTeal,
                            ),
                          ),
                          SizedBox(width: r.nanoPadding),
                          Text(
                            'Getting address...',
                            style: GoogleFonts.inter(
                              fontSize: r.bodyS,
                              color:  UserDesign.textSecondary,
                            ),
                          ),
                        ],
                      )
                          : Text(
                        _viewModel.selectedAddress.isNotEmpty
                            ? _viewModel.selectedAddress
                            : 'Drag map to set location',
                        style: GoogleFonts.inter(
                          fontSize: r.bodyS,
                          fontWeight: FontWeight.w600,
                          color: _viewModel.selectedAddress.isNotEmpty
                              ? UserDesign.textPrimary
                              : UserDesign.textTertiary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: r.padding),

          // Confirm Button
          GestureDetector(
            onTap: _viewModel.selectedLocation != null &&
                ! _viewModel.isLoadingLocation
                ?  () {
              _viewModel.confirmLocation();
            }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              height: r.buttonHeight + 4,
              decoration: BoxDecoration(
                gradient: _viewModel.selectedLocation != null &&
                    ! _viewModel.isLoadingLocation
                    ? UserDesign.primaryGradient
                    : null,
                color: _viewModel.selectedLocation != null &&
                    !_viewModel.isLoadingLocation
                    ? null
                    : UserDesign. textLight,
                borderRadius: BorderRadius.circular(r.borderRadius),
                boxShadow: _viewModel.selectedLocation != null &&
                    !_viewModel. isLoadingLocation
                    ?  UserDesign.glowShadow(UserDesign.primaryTeal)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_rounded,
                    color:  _viewModel.selectedLocation != null &&
                        !_viewModel.isLoadingLocation
                        ? Colors.white
                        : UserDesign.textTertiary,
                    size:  r.iconSize(20),
                  ),
                  SizedBox(width: r. nanoPadding),
                  Text(
                    'Confirm Location',
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w700,
                      color: _viewModel.selectedLocation != null &&
                          !_viewModel.isLoadingLocation
                          ? Colors.white
                          : UserDesign.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: r.microPadding),

          // Tip Text
          Text(
            'Drag the map to position the pin at the waste location',
            style: GoogleFonts.inter(
              fontSize: r.captionXS,
              color: UserDesign.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== STEP 3:  REVIEW ====================
  Widget _buildReviewStep(UserResponsiveData r) {
    return FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(r.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
              'Review Your Report',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: UserDesign.textPrimary,
              ),
            ),

            SizedBox(height: r.microPadding),

            // Image Preview
            if (_viewModel.capturedImageFile != null)
        ClipRRect(
    borderRadius: BorderRadius.circular(r. largeBorderRadius),
    child:  Stack(
    children: [
    _buildImageWidget(
    height: r.dimension(180),
    width: double.infinity,
    fit: BoxFit.cover,
    ),

    // Badge (Camera / Gallery)
    Positioned(
    top: r.microPadding,
    left: r.microPadding,
    child: Container(
    padding: EdgeInsets.symmetric(
    horizontal: r.microPadding,
    vertical:  r.nanoPadding,
    ),
    decoration: BoxDecoration(
    color: _viewModel.imageSource == ImageSource.camera
    ? UserDesign.success
        : UserDesign. info,
    borderRadius:
    BorderRadius.circular(r.pillBorderRadius),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    _viewModel.imageSource == ImageSource.camera
    ? Icons.camera_alt_rounded
        : Icons.photo_library_rounded,
    color:  Colors.white,
    size: r.iconSize(12),
    ),
    SizedBox(width: r. atomicPadding),
    Text(
    _viewModel. imageSource == ImageSource.camera
    ? 'Camera'
        : 'Gallery',
    style: GoogleFonts.inter(
    fontSize: r.captionXS,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    ),
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    ),

    SizedBox(height: r.padding),

    // Report Details Card
    Container(
    padding: EdgeInsets.all(r.padding),
    decoration: BoxDecoration(
    color: UserDesign.surfacePure,
    borderRadius:  BorderRadius.circular(r.largeBorderRadius),
    boxShadow: UserDesign.softShadow,
    ),
    child: Column(
    children: [
    _buildReviewItem(
    r,
    Icons.location_on_rounded,
    'Location',
    _viewModel.selectedAddress. isNotEmpty
    ? _viewModel.selectedAddress
        : 'Not set',
    UserDesign.error,
    ),

    if (_viewModel.selectedLocation != null) ...[
    Divider(height: r.padding, color: UserDesign.surfaceOverlay),
    _buildReviewItem(
    r,
    Icons.gps_fixed_rounded,
    'GPS Coordinates',
    '${_viewModel.selectedLocation! .latitude. toStringAsFixed(6)}, '
    '${_viewModel.selectedLocation!. longitude.toStringAsFixed(6)}',
    UserDesign.success,
    ),
    ],

    Divider(height: r.padding, color: UserDesign.surfaceOverlay),

    _buildReviewItem(
    r,
    Icons.access_time_rounded,
    'Timestamp',
    _viewModel. formatTimestamp(
    _viewModel.captureTimestamp ?? DateTime.now()),
    UserDesign.warning,
    ),

    Divider(height: r. padding, color: UserDesign. surfaceOverlay),

    _buildReviewItem(
    r,
    _viewModel.imageSource == ImageSource.camera
    ? Icons.camera_alt_rounded
        : Icons. photo_library_rounded,
    'Image Source',
    _viewModel. imageSource == ImageSource.camera
    ? 'Camera (Auto GPS)'
        : 'Gallery (Manual Location)',
    UserDesign. info,
    ),
    ],
    ),
    ),

    SizedBox(height: r.padding),

    // Optional Description Field
    _buildOptionalDescriptionSection(r),

    SizedBox(height: r.padding),

    _buildAIInfoBanner(r),
    ],
    ),
    ),
    );
  }

  Widget _buildReviewItem(
      UserResponsiveData r,
      IconData icon,
      String label,
      String value,
      Color color, {
        bool isMultiLine = false,
      }) {
    return Row(
      crossAxisAlignment:
      isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(r.nanoPadding),
          decoration:  BoxDecoration(
            color:  color. withOpacity(0.1),
            borderRadius: BorderRadius. circular(r.smallBorderRadius),
          ),
          child: Icon(icon, color: color, size: r.iconSize(18)),
        ),
        SizedBox(width: r.microPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: r.captionXS,
                  color: UserDesign.textTertiary,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w600,
                  color: UserDesign.textPrimary,
                ),
                maxLines: isMultiLine ? null : 2,
                overflow: isMultiLine ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionalDescriptionSection(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color:  UserDesign.surfacePure,
        borderRadius:  BorderRadius.circular(r.largeBorderRadius),
        boxShadow: UserDesign.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: UserDesign.primaryTeal,
                size: r.iconSize(20),
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                'Add Description',
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w600,
                  color: UserDesign.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r. nanoPadding,
                  vertical: r.atomicPadding,
                ),
                decoration: BoxDecoration(
                  color: UserDesign.info. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Text(
                  'Optional',
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    fontWeight: FontWeight.w600,
                    color: UserDesign.info,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          Text(
            'You can add additional details about the waste location, size, or any other relevant information.',
            style: GoogleFonts. inter(
              fontSize: r. captionS,
              color: UserDesign.textSecondary,
            ),
          ),
          SizedBox(height: r. microPadding),
          Container(
            decoration: BoxDecoration(
              color: UserDesign.surfaceLight,
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 500,
              style: GoogleFonts.inter(
                  fontSize: r.bodyS, color: UserDesign.textPrimary),
              decoration: InputDecoration(
                hintText:
                'E.g., Large pile of plastic waste near the park entrance.. .',
                hintStyle: GoogleFonts. inter(
                    fontSize: r.captionM, color: UserDesign.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  borderSide: BorderSide. none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  borderSide:  const BorderSide(
                      color: UserDesign.primaryTeal, width: 2),
                ),
                contentPadding: EdgeInsets. all(r.microPadding),
                counterStyle: GoogleFonts.inter(
                    fontSize: r.captionXS, color: UserDesign. textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInfoBanner(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets. all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:  [
            UserDesign.purple. withOpacity(0.1),
            UserDesign.primaryTeal.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(
          color: UserDesign.purple.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration:  BoxDecoration(
              gradient: LinearGradient(
                colors: [UserDesign.purple, UserDesign.primaryTeal],
              ),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: r.iconSize(24),
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
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w700,
                    color: UserDesign.textPrimary,
                  ),
                ),
                SizedBox(height: r. atomicPadding),
                Text(
                  'Your report will be verified by our AI system to ensure it contains valid waste imagery before submission.',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: UserDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== AI VERIFICATION OVERLAY ====================
  Widget _buildAIVerificationOverlay(UserResponsiveData r) {
    return Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Container(
              margin: EdgeInsets.all(r.largePadding),
              padding: EdgeInsets.all(r.largePadding),
              decoration:  BoxDecoration(
                color:  UserDesign.surfacePure,
                borderRadius:  BorderRadius.circular(r.extraLargeBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: UserDesign.primaryTeal.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  if (_viewModel.aiVerificationResult == null) ...[
          // Loading State
          Container(
          padding: EdgeInsets.all(r.largePadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                UserDesign.purple.withOpacity(0.2),
                UserDesign. primaryTeal.withOpacity(0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: r.dimension(80),
                height: r. dimension(80),
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      UserDesign.primaryTeal),
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                color: UserDesign.purple,
                size: r. iconSize(36),
              ),
            ],
          ),
        ),
        SizedBox(height: r. largePadding),
        Text(
          'AI Analyzing Image.. .',
          style: GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight.w700,
            color: UserDesign.textPrimary,
          ),
        ),
        SizedBox(height: r. microPadding),
        Text(
          'Verifying waste content in your image',
          style: GoogleFonts.inter(
            fontSize: r.captionM,
            color: UserDesign.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        ] else if (_viewModel.aiVerificationResult == true) ...[
    // Success State
    Container(
    padding: EdgeInsets.all(r.largePadding),
    decoration: BoxDecoration(
    gradient: UserDesign.successGradient,
    shape: BoxShape.circle,
    boxShadow: UserDesign.glowShadow(UserDesign.success),
    ),
    child: Icon(
    Icons.check_rounded,
    color: Colors.white,
    size: r.iconSize(48),
    ),
    ),
    SizedBox(height:  r.largePadding),
    Text(
    'Waste Detected!  ✓',
    style: GoogleFonts.inter(
    fontSize: r.bodyM,
    fontWeight: FontWeight. w700,
    color:  UserDesign.success,
    ),
    ),
    SizedBox(height:  r.microPadding),
    Text(
    'Your report is being submitted.. .',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: UserDesign.textSecondary,
    ),
    textAlign: TextAlign.center,
    ),
    ] else ...[
    // Failure State
    Container(
    padding: EdgeInsets.all(r.largePadding),
    decoration: BoxDecoration(
    color: UserDesign.error. withOpacity(0.1),
    shape: BoxShape.circle,
    border: Border.all(color: UserDesign.error, width: 3),
    ),
    child: Icon(
    Icons.close_rounded,
    color: UserDesign.error,
    size: r.iconSize(48),
    ),
    ),
    SizedBox(height: r.largePadding),
    Text(
    'No Waste Detected',
    style: GoogleFonts.inter(
    fontSize: r.bodyM,
    fontWeight: FontWeight.w700,
    color: UserDesign.error,
    ),
    ),
    SizedBox(height: r.microPadding),
    Padding(
    padding: EdgeInsets.symmetric(horizontal: r.padding),
    child: Text(
    'Our AI could not detect waste in your image. Please try again with a clearer photo.',
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: UserDesign.textSecondary,
    ),
    textAlign: TextAlign.center,
    ),
    ),
    SizedBox(height: r. largePadding),
    GestureDetector(
    onTap: () {
    _viewModel.retryWithNewImage();
    _pageController.animateToPage(
    0,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
    );
    },
    child:  Container(
    padding: EdgeInsets.symmetric(
    horizontal: r.largePadding,
    vertical: r.microPadding,
    ),
    decoration: BoxDecoration(
    gradient: UserDesign.primaryGradient,
    borderRadius: BorderRadius.circular(r. borderRadius),
    boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
    ),
    child: Row(
    mainAxisSize:  MainAxisSize.min,
    children: [
    Icon(Icons.refresh_rounded,
    color: Colors.white, size: r.iconSize(18)),
    SizedBox(width: r.nanoPadding),
    Text(
    'Try Again',
    style: GoogleFonts.inter(
    fontSize: r.bodyS,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    ),
    ),
    ],
    ),
    ),
    ),
    ],
    ],
    ),
    ),
    ),
    );
  }
}