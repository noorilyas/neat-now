import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/viewmodels/user/edit_profile_viewmodel.dart';

class ModernEditProfileSheet extends StatefulWidget {
  final UserResponsiveData responsive;
  final Map<String, dynamic> userData;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSave;

  const ModernEditProfileSheet({
    super.key,
    required this. responsive,
    required this.userData,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<ModernEditProfileSheet> createState() => _ModernEditProfileSheetState();
}

class _ModernEditProfileSheetState extends State<ModernEditProfileSheet>
    with SingleTickerProviderStateMixin {
  late EditProfileViewModel _viewModel;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Track if save was successful
  bool _saveCompleted = false;

  @override
  void initState() {
    super.initState();

    _viewModel = EditProfileViewModel(
      userData: widget.userData,
      onSave: widget.onSave,
    );
    _viewModel.addListener(_onViewModelChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve:  Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0, end:  1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves. easeOut),
    );

    _animationController.forward();
  }

  void _onViewModelChanged() {
    if (! mounted) return;
    setState(() {});

    if (_viewModel.errorMessage != null) {
      _showError(_viewModel.errorMessage!);
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildImageSourceSheet(),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      _viewModel.setNewImage(File(image.path));
    }
  }

  Widget _buildImageSourceSheet() {
    final r = widget.responsive;

    return Container(
      margin: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: UserDesign.surfacePure,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: r. dimension(40),
            height: r.dimension(4),
            margin: EdgeInsets.symmetric(vertical: r.padding),
            decoration: BoxDecoration(
              color: UserDesign.textLight. withOpacity(0.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.padding),
            child: Text(
              'Change Profile Photo',
              style: GoogleFonts.inter(
                fontSize: r.bodyM,
                fontWeight: FontWeight.w700,
                color: UserDesign.textPrimary,
              ),
            ),
          ),

          SizedBox(height: r.padding),

          _buildImageSourceOption(
            r,
            icon: Icons.camera_alt_rounded,
            label: 'Take Photo',
            subtitle: 'Use camera to take a new photo',
            color: UserDesign.primaryTeal,
            onTap: () => Navigator.pop(context, ImageSource. camera),
          ),

          Divider(height: 1, color: UserDesign. surfaceOverlay),

          _buildImageSourceOption(
            r,
            icon: Icons.photo_library_rounded,
            label: 'Choose from Gallery',
            subtitle: 'Select from your photos',
            color: UserDesign.purple,
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),

          if (_viewModel.newImage != null ||
              _viewModel.currentProfileImage. isNotEmpty) ...[
            Divider(height: 1, color: UserDesign.surfaceOverlay),
            _buildImageSourceOption(
              r,
              icon: Icons.delete_rounded,
              label: 'Remove Photo',
              subtitle: 'Use default avatar',
              color: UserDesign.error,
              onTap: () {
                _viewModel.removeNewImage();
                Navigator.pop(context);
              },
            ),
          ],

          SizedBox(height: r.padding),

          Padding(
            padding: EdgeInsets.fromLTRB(
              r.padding,
              0,
              r.padding,
              r.safePaddingBottom + r.padding,
            ),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: r.microPadding + 2),
                decoration: BoxDecoration(
                  color: UserDesign.surfaceLight,
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w600,
                      color: UserDesign.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSourceOption(
      UserResponsiveData r, {
        required IconData icon,
        required String label,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:  onTap,
        child:  Padding(
          padding: EdgeInsets.symmetric(
            horizontal: r.padding,
            vertical: r.padding,
          ),
          child: Row(
            children: [
              Container(
                width: r.dimension(56),
                height: r.dimension(56),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(r.largeBorderRadius),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: r. iconSize(28),
                ),
              ),

              SizedBox(width: r.padding),

              Expanded(
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts. inter(
                        fontSize: r.bodyS,
                        fontWeight: FontWeight.w600,
                        color: UserDesign.textPrimary,
                      ),
                    ),
                    SizedBox(height: r.atomicPadding),
                    Text(
                      subtitle,
                      style: GoogleFonts. inter(
                        fontSize: r.captionS,
                        color:  UserDesign.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: UserDesign.textLight,
                size: r.iconSize(24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final success = await _viewModel.save();
    if (success) {
      HapticFeedback. mediumImpact();

      // Mark save as completed - skip discard dialog
      _saveCompleted = true;

      // Close sheet
      _closeSheet();
    }
  }

  void _showError(String message) {
    if (! mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:  Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(message, style: GoogleFonts. inter(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: UserDesign.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _closeSheet() async {
    // Only show discard dialog if there are unsaved changes
    // AND save was not just completed
    if (_viewModel.hasChanges && !_viewModel.isSaving && !_saveCompleted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => _buildDiscardChangesDialog(),
      );

      if (confirm != true) return;
    }

    await _animationController.reverse();
    widget.onClose();
  }

  Widget _buildDiscardChangesDialog() {
    final r = widget.responsive;

    return AlertDialog(
      backgroundColor: UserDesign.surfacePure,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r. largeBorderRadius),
      ),
      title: Text(
        'Discard Changes?',
        style:  GoogleFonts.inter(
          fontSize: r.bodyM,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        'You have unsaved changes. Are you sure you want to discard them?',
        style: GoogleFonts.inter(fontSize: r.captionM),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel', style: GoogleFonts.inter()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Discard',
            style: GoogleFonts. inter(color: UserDesign.error),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return AnimatedBuilder(
      animation: _animationController,
      builder:  (context, child) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _closeSheet,
              child: Container(
                color: Colors.black.withOpacity(0.6 * _fadeAnimation. value),
              ),
            ),

            Align(
              alignment: Alignment. bottomCenter,
              child: Transform.translate(
                offset: Offset(
                  0,
                  MediaQuery.of(context).size.height *
                      0.85 *
                      _slideAnimation.value,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  decoration: BoxDecoration(
                    color: UserDesign.surfacePure,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(r.extraLargeBorderRadius + 8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius:  30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: r.dimension(48),
                        height: r. dimension(5),
                        margin: EdgeInsets.symmetric(vertical: r.microPadding),
                        decoration: BoxDecoration(
                          color: UserDesign.textLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      _buildHeader(r),

                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: r.padding),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildProfileImagePicker(r),

                              SizedBox(height:  r.largePadding),

                              _buildModernTextField(
                                r,
                                _viewModel.nameController,
                                'Full Name',
                                'Enter your full name',
                                Icons.person_rounded,
                              ),
                              SizedBox(height:  r.padding),

                              _buildModernTextField(
                                r,
                                _viewModel.phoneController,
                                'Phone Number',
                                'Enter your phone number',
                                Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: r. padding),

                              _buildModernTextField(
                                r,
                                _viewModel.bioController,
                                'Bio',
                                'Tell us about yourself.. .',
                                Icons.edit_note_rounded,
                                maxLines: 3,
                              ),

                              SizedBox(height:  160), // Extra space for button
                            ],
                          ),
                        ),
                      ),

                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _viewModel.hasChanges
                            ? _buildSaveButton(r)
                            : const SizedBox. shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(UserResponsiveData r) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.padding, r.microPadding, r.padding, r.padding),
      child: Row(
        children: [
          GestureDetector(
            onTap: _closeSheet,
            child: Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration:  BoxDecoration(
                color:  UserDesign.surfaceLight,
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Icon(
                Icons.close_rounded,
                color: UserDesign.textSecondary,
                size: r.iconSize(22),
              ),
            ),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style:  GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign.textPrimary,
                  ),
                ),
                Text(
                  'Update your personal information',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color:  UserDesign.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (_viewModel.hasChanges)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical:  r.atomicPadding,
              ),
              decoration: BoxDecoration(
                color: UserDesign. warning. withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
                border: Border.all(
                  color: UserDesign.warning. withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: UserDesign.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: r.atomicPadding),
                  Text(
                    'Unsaved',
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      fontWeight: FontWeight.w600,
                      color: UserDesign.warning,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker(UserResponsiveData r) {
    return GestureDetector(
      onTap: _viewModel.imageUploading ?  null : _pickImage,
      child: Stack(
        children: [
          Container(
            width: r. dimension(110),
            height: r.dimension(110),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: UserDesign.primaryGradient,
              boxShadow: UserDesign.glowShadow(UserDesign.primaryTeal),
            ),
            child:  Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _viewModel.newImage != null
                      ? Image.file(_viewModel.newImage!, fit: BoxFit.cover)
                      : _viewModel.currentProfileImage. isNotEmpty
                      ? Image.network(
                    _viewModel. currentProfileImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(r),
                  )
                      : _buildPlaceholder(r),
                ),
              ),
            ),
          ),

          if (_viewModel.imageUploading)
            Positioned. fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize:  MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: _viewModel.uploadProgress,
                          strokeWidth:  3,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: r.nanoPadding),
                      Text(
                        '${(_viewModel.uploadProgress * 100).toInt()}%',
                        style: GoogleFonts. inter(
                          fontSize: r.captionS,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (! _viewModel.imageUploading)
            Positioned(
              right: 0,
              bottom: 0,
              child:  Container(
                padding: EdgeInsets.all(r.microPadding + 2),
                decoration: BoxDecoration(
                  gradient: UserDesign.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: UserDesign.primaryTeal.withOpacity(0.3),
                      blurRadius:  8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: r.iconSize(18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(UserResponsiveData r) {
    return Container(
      color: UserDesign.surfaceLight,
      child: Center(
        child: Text(
          _viewModel.currentName[0].toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            color: UserDesign.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField(
      UserResponsiveData r,
      TextEditingController controller,
      String label,
      String hint,
      IconData icon, {
        TextInputType?  keyboardType,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: r.captionM,
            fontWeight: FontWeight.w600,
            color: UserDesign.textSecondary,
          ),
        ),
        SizedBox(height: r.nanoPadding),
        Container(
          decoration: BoxDecoration(
            color: UserDesign.surfaceLight,
            borderRadius:  BorderRadius.circular(r.largeBorderRadius),
            border: Border.all(
              color: UserDesign.surfaceOverlay,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts. inter(
              fontSize: r. bodyS,
              color: UserDesign.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon:  Padding(
                padding: EdgeInsets.only(left: r.microPadding, right: r.nanoPadding),
                child:  Icon(icon, color: UserDesign.textTertiary, size: r.iconSize(20)),
              ),
              prefixIconConstraints: BoxConstraints(minWidth: r.dimension(48)),
              hintText: hint,
              hintStyle: GoogleFonts. inter(fontSize: r.bodyS, color: UserDesign.textLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius. circular(r.largeBorderRadius),
                borderSide: BorderSide. none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:  BorderRadius.circular(r.largeBorderRadius),
                borderSide: BorderSide(color: UserDesign.primaryTeal, width: 2),
              ),
              contentPadding: EdgeInsets. symmetric(
                horizontal: r.padding,
                vertical: r.padding,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(UserResponsiveData r) {
    final canSave = _viewModel.hasChanges &&
        ! _viewModel.isSaving &&
        ! _viewModel.imageUploading;

    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;

    return Container(
      padding: EdgeInsets.fromLTRB(
        r. padding,
        r.padding,
        r.padding,
        bottomPadding,
      ),
      decoration: BoxDecoration(
        color: UserDesign.surfacePure,
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: canSave ? _save :  null,
        child: Container(
          width: double.infinity,
          height: r.buttonHeight + 8,
          decoration: BoxDecoration(
            gradient: canSave ?  UserDesign.primaryGradient : null,
            color: canSave ? null : UserDesign.textLight,
            borderRadius: BorderRadius.circular(r.largeBorderRadius),
            boxShadow: canSave ?  UserDesign.glowShadow(UserDesign.primaryTeal) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_viewModel.isSaving || _viewModel.imageUploading)
                SizedBox(
                  width:  22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: canSave ? Colors.white : UserDesign.textSecondary,
                  ),
                )
              else
                Icon(
                  Icons.check_rounded,
                  color: canSave ? Colors.white : UserDesign.textTertiary,
                  size:  r.iconSize(22),
                ),
              SizedBox(width: r.nanoPadding),
              Text(
                _viewModel.imageUploading
                    ? 'Uploading Image...'
                    : _viewModel.isSaving
                    ? 'Saving...'
                    : 'Save Changes',
                style: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w700,
                  color: canSave ? Colors.white : UserDesign.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}