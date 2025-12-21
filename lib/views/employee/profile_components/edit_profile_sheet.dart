import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:neat_now/viewmodels/employee/profile_viewmodel.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class EditProfileSheet extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final ProfileViewModel viewModel;
  final VoidCallback onSuccess;

  const EditProfileSheet({
    super.key,
    required this.responsive,
    required this. viewModel,
    required this. onSuccess,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _newImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve:  Curves.easeOutCubic));
    _animController.forward();

    _nameController = TextEditingController(text: widget.viewModel.name);
    _emailController = TextEditingController(text: widget. viewModel.email);
    _phoneController = TextEditingController(text: widget.viewModel.phone);
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _newImage = File(image. path));
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Name cannot be empty');
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final success = await widget.viewModel. updateProfile({
      'name': _nameController.text.trim(),
      'email': _emailController.text. trim(),
      'phone': _phoneController.text.trim(),
      'profileImage': _newImage?.path,
    });

    if (success) {
      widget.onSuccess();
    } else {
      setState(() => _isSaving = false);
      _showError('Failed to update profile');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ProfileDesign.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return GestureDetector(
      onTap: () => widget.viewModel.setEditMode(false),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {}, // Prevent dismissal when tapping sheet
          child: SlideTransition(
            position:  _slideAnimation,
            child:  Align(
              alignment: Alignment. bottomCenter,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: ProfileDesign.surfacePure,
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
                      height: r. dimension(4),
                      margin: EdgeInsets.symmetric(vertical: r.microPadding),
                      decoration: BoxDecoration(
                        color: ProfileDesign.textLight,
                        borderRadius: BorderRadius.circular(r.pillBorderRadius),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.padding),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => widget.viewModel.setEditMode(false),
                            child: Container(
                              padding: EdgeInsets.all(r.microPadding),
                              decoration:  BoxDecoration(
                                color: ProfileDesign.surfaceLight,
                                borderRadius: BorderRadius.circular(r.borderRadius),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: ProfileDesign.textSecondary,
                                size: r.iconSize(20),
                              ),
                            ),
                          ),
                          SizedBox(width: r. padding),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.inter(
                              fontSize: r.headingXS,
                              fontWeight: FontWeight.w700,
                              color: ProfileDesign.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.padding),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: r.padding),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // Profile image
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: r.dimension(100),
                                    height: r.dimension(100),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: ProfileDesign.primaryGradient,
                                    ),
                                    child:  Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: ClipOval(
                                        child: _newImage != null
                                            ? Image.file(_newImage!, fit: BoxFit.cover)
                                            :  widget.viewModel.profileImage != null
                                            ? Image.network(
                                          widget. viewModel.profileImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _buildInitial(r),
                                        )
                                            : _buildInitial(r),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom:  0,
                                    child: Container(
                                      padding: EdgeInsets.all(r.microPadding),
                                      decoration: BoxDecoration(
                                        gradient: ProfileDesign.primaryGradient,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: ProfileDesign.surfacePure,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        color:  Colors.white,
                                        size: r.iconSize(16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: r.largePadding),

                            // Form fields
                            _buildTextField(r, _nameController, 'Full Name', Icons.person_rounded),
                            SizedBox(height: r.microPadding),
                            _buildTextField(
                              r,
                              _emailController,
                              'Email',
                              Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: r.microPadding),
                            _buildTextField(
                              r,
                              _phoneController,
                              'Phone',
                              Icons.phone_rounded,
                              keyboardType: TextInputType.phone,
                            ),

                            SizedBox(height:  r.largePadding),
                          ],
                        ),
                      ),
                    ),

                    // Save button
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        r.padding,
                        r.microPadding,
                        r.padding,
                        r. safePaddingBottom + r.microPadding,
                      ),
                      child:  GestureDetector(
                        onTap: _isSaving ? null : _save,
                        child: AnimatedContainer(
                          duration:  const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: r.buttonHeight + 4,
                          decoration: BoxDecoration(
                            gradient: _isSaving
                                ? LinearGradient(
                              colors: [
                                ProfileDesign.primaryTeal. withOpacity(0.5),
                                ProfileDesign.primaryTealLight.withOpacity(0.5),
                              ],
                            )
                                : ProfileDesign.primaryGradient,
                            borderRadius: BorderRadius.circular(r.borderRadius),
                            boxShadow:  _isSaving
                                ?  []
                                : ProfileDesign. glowShadow(ProfileDesign.primaryTeal),
                          ),
                          child: Row(
                            mainAxisAlignment:  MainAxisAlignment.center,
                            children: [
                              if (_isSaving)
                                SizedBox(
                                  width: r.iconSize(20),
                                  height: r.iconSize(20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                  size: r.iconSize(20),
                                ),
                              SizedBox(width: r.nanoPadding),
                              Text(
                                _isSaving ? 'Saving...' :  'Save Changes',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitial(EmployeeResponsiveData r) {
    return Container(
      color: ProfileDesign.surfaceLight,
      child: Center(
        child: Text(
          widget.viewModel.name.isNotEmpty ?  widget.viewModel.name[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
            fontSize: r.dimension(40),
            fontWeight: FontWeight.w700,
            color: ProfileDesign.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      EmployeeResponsiveData r,
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: r.captionM,
            fontWeight: FontWeight.w600,
            color: ProfileDesign.textSecondary,
          ),
        ),
        SizedBox(height: r.nanoPadding),
        Container(
          decoration: BoxDecoration(
            color: ProfileDesign.surfaceLight,
            borderRadius: BorderRadius.circular(r.borderRadius),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: ProfileDesign.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: ProfileDesign.textTertiary,
                size: r.iconSize(20),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r.borderRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:  BorderRadius.circular(r.borderRadius),
                borderSide:  const BorderSide(color: ProfileDesign.primaryTeal, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical:  r.microPadding,
              ),
            ),
          ),
        ),
      ],
    );
  }
}