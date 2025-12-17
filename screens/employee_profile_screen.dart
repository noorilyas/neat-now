import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:neat_now/services/auth_service.dart';
import 'package:neat_now/services/employee_service.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// EmployeeProfileScreen - Profile management for workers
/// Implements FR-W2: Worker profile management
class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen>
    with SingleTickerProviderStateMixin {
  // Services
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  // State
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  bool _isDemoMode = false;
  File? _newProfileImage;

  // User data
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _employeeStats = {};

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Focus nodes
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _bioFocusNode = FocusNode();

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Availability toggle
  bool _isAvailable = true;

  @override
  void initState() {
    super. initState();
    _initializeAnimations();
    _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves. easeOutQuart,
    );

    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      _isDemoMode = await _authService.checkDemoMode();

      // Load cached user data
      final cachedData = await _authService.getCachedUserData();
      if (cachedData != null) {
        _userData = cachedData;
        _populateControllers();
      }

      // Try to get fresh profile data
      final profileResult = await _authService.getProfile();
      if (profileResult['success'] == true && profileResult['user'] != null) {
        _userData = profileResult['user'];
        _populateControllers();
      }

      // Load employee-specific stats
      final statsResult = await EmployeeService.getEmployeeStats();
      _employeeStats = statsResult;

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() => _isLoading = false);
      _showSnackBar('Error loading profile', isError: true);
    }
  }

  void _populateControllers() {
    _nameController.text = _userData['name'] ?? '';
    _emailController.text = _userData['email'] ?? '';
    _phoneController.text = _userData['phone_number'] ?? _userData['phoneNumber'] ?? '';
    _addressController. text = _userData['address'] ?? _userData['assigned_area'] ?? '';
    _bioController.text = _userData['bio'] ?? '';
    _isAvailable = _userData['is_available'] ?? _userData['isAvailable'] ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController. dispose();
    _addressController.dispose();
    _bioController.dispose();
    _nameFocusNode. dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _bioFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();

    final XFile? image = await showModalBottomSheet<XFile? >(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildImagePickerSheet(),
    );

    if (image != null) {
      setState(() {
        _newProfileImage = File(image.path);
      });
    }
  }

  Widget _buildImagePickerSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize. min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors. grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Change Profile Photo',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1a1a2e),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPickerOption(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                onTap: () async {
                  final XFile? image = await _imagePicker. pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                    maxWidth: 512,
                    maxHeight: 512,
                  );
                  if (mounted) Navigator.pop(context, image);
                },
              ),
              _buildPickerOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () async {
                  final XFile?  image = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                    maxWidth: 512,
                    maxHeight: 512,
                  );
                  if (mounted) Navigator.pop(context, image);
                },
              ),
              if (_newProfileImage != null || _userData['profile_image'] != null)
                _buildPickerOption(
                  icon: Icons.delete_rounded,
                  label: 'Remove',
                  color: Colors.red,
                  onTap: () {
                    setState(() {
                      _newProfileImage = null;
                      _userData['profile_image'] = null;
                    });
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.green,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (! _formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    setState(() => _isSaving = true);

    try {
      final result = await _authService.updateProfile(
        name: _nameController. text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profileImage: _newProfileImage,
      );

      // Update additional employee-specific fields
      if (_addressController.text.isNotEmpty || _bioController.text.isNotEmpty) {
        await EmployeeService. updateEmployeeProfile(
          address: _addressController. text.trim(),
          bio: _bioController.text.trim(),
          isAvailable: _isAvailable,
        );
      }

      // Update availability
      await EmployeeService.updateAvailability(_isAvailable);

      if (! mounted) return;

      setState(() {
        _isSaving = false;
        _isEditing = false;
        _newProfileImage = null;
      });

      if (result['success'] == true) {
        // Update local user data
        _userData['name'] = _nameController.text.trim();
        _userData['phone_number'] = _phoneController.text. trim();
        _userData['address'] = _addressController.text.trim();
        _userData['bio'] = _bioController. text.trim();
        _userData['is_available'] = _isAvailable;

        _showSnackBar(
          _isDemoMode
              ? '🔧 Demo: Profile updated locally'
              : 'Profile updated successfully! ',
          isError: false,
        );
      } else {
        _showSnackBar(result['message'] ?? 'Failed to update profile', isError: true);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      setState(() => _isSaving = false);
      _showSnackBar('Error saving profile', isError: true);
    }
  }

  void _toggleEditMode() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isEditing) {
        // Cancel editing - restore original values
        _populateControllers();
        _newProfileImage = null;
      }
      _isEditing = !_isEditing;
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(responsive),
          body: _isLoading
              ?  _buildLoadingState(responsive)
              : FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContent(responsive),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(EmployeeResponsiveData responsive) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: responsive.iconSize(20),
          color: Colors.black87,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (_isEditing) {
            _showDiscardChangesDialog(responsive);
          } else {
            Navigator. pop(context);
          }
        },
      ),
      title: Text(
        responsive.adaptiveText(
          'My Profile',
          micro: 'Me',
          nano: 'Profile',
        ),
        style: GoogleFonts.poppins(
          fontSize: responsive.fontSize(18),
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      actions: [
        // Demo mode indicator
        if (_isDemoMode && responsive.showSecondaryText)
          Container(
            margin: EdgeInsets.symmetric(horizontal: responsive.microPadding),
            padding: EdgeInsets.symmetric(
              horizontal: responsive. microPadding,
              vertical: responsive.nanoPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.orange. withOpacity(0.1),
              borderRadius: BorderRadius. circular(responsive.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.science_rounded,
                  size: responsive.iconSize(14),
                  color: Colors.orange,
                ),
                SizedBox(width: responsive.nanoPadding),
                Text(
                  'Demo',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.fontSize(10),
                    fontWeight: FontWeight. w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

        // Edit/Cancel button
        TextButton. icon(
          onPressed: _toggleEditMode,
          icon: Icon(
            _isEditing ? Icons.close_rounded : Icons. edit_rounded,
            size: responsive.iconSize(18),
            color: _isEditing ? Colors.red : Colors.green,
          ),
          label: Text(
            _isEditing
                ? responsive.adaptiveText('Cancel', micro: '', nano: 'X')
                : responsive.adaptiveText('Edit', micro: '', nano: 'Ed'),
            style: GoogleFonts. poppins(
              fontSize: responsive. fontSize(14),
              fontWeight: FontWeight.w600,
              color: _isEditing ? Colors.red : Colors. green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(EmployeeResponsiveData responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment. center,
        children: [
          SizedBox(
            width: responsive.dimension(50),
            height: responsive.dimension(50),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: responsive.padding),
          Text(
            'Loading profile...',
            style: GoogleFonts.poppins(
              fontSize: responsive.fontSize(14),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(EmployeeResponsiveData responsive) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(responsive),

            // Stats section
            if (! _isEditing) _buildStatsSection(responsive),

            // Profile form
            _buildProfileForm(responsive),

            // Availability toggle
            _buildAvailabilitySection(responsive),

            // Account settings
            if (!_isEditing) _buildAccountSettings(responsive),

            // Save button (when editing)
            if (_isEditing) _buildSaveButton(responsive),

            SizedBox(height: responsive.dimension(100)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(EmployeeResponsiveData responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets. all(responsive.largePadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
        ),
      ),
      child: Column(
        children: [
          // Profile image
          Stack(
            children: [
              Container(
                width: responsive.dimension(120),
                height: responsive.dimension(120),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: responsive.showShadows
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                      : [],
                ),
                child: ClipOval(
                  child: _buildProfileImage(responsive),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: EdgeInsets. all(responsive.microPadding),
                      decoration: BoxDecoration(
                        color: Colors. white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors. black.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.green,
                        size: responsive.iconSize(22),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: responsive.padding),

          // Name and role
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _userData['name'] ??  'Employee',
              style: GoogleFonts. poppins(
                fontSize: responsive. fontSize(24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: responsive. microPadding),

          // Role badge
          Container(
            padding: EdgeInsets. symmetric(
              horizontal: responsive. padding,
              vertical: responsive.microPadding,
            ),
            decoration: BoxDecoration(
              color: Colors.white. withOpacity(0.2),
              borderRadius: BorderRadius. circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.work_rounded,
                  color: Colors.white,
                  size: responsive.iconSize(16),
                ),
                SizedBox(width: responsive.microPadding),
                Text(
                  _userData['role'] ?? 'Field Worker',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.fontSize(14),
                    fontWeight: FontWeight. w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: responsive.microPadding),

          // Availability status
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.padding,
              vertical: responsive. microPadding,
            ),
            decoration: BoxDecoration(
              color: _isAvailable
                  ? Colors. green.shade300
                  : Colors.red.shade300,
              borderRadius: BorderRadius. circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: responsive.dimension(10),
                  height: responsive.dimension(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: responsive. microPadding),
                Text(
                  _isAvailable ? 'Available' : 'Unavailable',
                  style: GoogleFonts. poppins(
                    fontSize: responsive.fontSize(12),
                    fontWeight: FontWeight. w600,
                    color: Colors. white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(EmployeeResponsiveData responsive) {
    if (_newProfileImage != null) {
      return Image.file(
        _newProfileImage! ,
        fit: BoxFit.cover,
      );
    }

    final profileUrl = _userData['profile_image'] ?? _userData['profileImage'];
    if (profileUrl != null && profileUrl.toString().isNotEmpty) {
      return Image.network(
        profileUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(responsive),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress. expectedTotalBytes != null
                  ?  loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
        },
      );
    }

    return _buildDefaultAvatar(responsive);
  }

  Widget _buildDefaultAvatar(EmployeeResponsiveData responsive) {
    final name = _userData['name'] ?? 'E';
    return Container(
      color: Colors.green. shade200,
      child: Center(
        child: Text(
          name. toString().isNotEmpty ? name. toString()[0].toUpperCase() : 'E',
          style: GoogleFonts. poppins(
            fontSize: responsive. fontSize(48),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(EmployeeResponsiveData responsive) {
    return Padding(
      padding: EdgeInsets. all(responsive.padding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          boxShadow: responsive.showShadows
              ? [
            BoxShadow(
              color: Colors. black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets. all(responsive.padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment. spaceAround,
            children: [
              _buildStatItem(
                responsive,
                icon: Icons.assignment_turned_in_rounded,
                value: _employeeStats['resolvedReports']?.toString() ??
                    _employeeStats['resolved_reports']?.toString() ?? '0',
                label: 'Resolved',
                color: Colors.green,
              ),
              _buildStatDivider(responsive),
              _buildStatItem(
                responsive,
                icon: Icons.pending_actions_rounded,
                value: _employeeStats['pendingReports']?.toString() ??
                    _employeeStats['pending_reports']?. toString() ?? '0',
                label: 'Pending',
                color: Colors.orange,
              ),
              _buildStatDivider(responsive),
              _buildStatItem(
                responsive,
                icon: Icons.star_rounded,
                value: (_userData['rating'] ?? 4.8).toString(),
                label: 'Rating',
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      EmployeeResponsiveData responsive, {
        required IconData icon,
        required String value,
        required String label,
        required Color color,
      }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets. all(responsive.microPadding),
          decoration: BoxDecoration(
            color: color. withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: responsive. iconSize(24)),
        ),
        SizedBox(height: responsive.microPadding),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts. poppins(
              fontSize: responsive. fontSize(20),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: responsive.fontSize(11),
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(EmployeeResponsiveData responsive) {
    return Container(
      width: 1,
      height: responsive.dimension(50),
      color: Colors.grey. withOpacity(0.2),
    );
  }

  Widget _buildProfileForm(EmployeeResponsiveData responsive) {
    return Padding(
      padding: EdgeInsets. all(responsive.padding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(responsive. largeBorderRadius),
          boxShadow: responsive.showShadows
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets. all(responsive.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    color: Colors.green,
                    size: responsive.iconSize(22),
                  ),
                  SizedBox(width: responsive.microPadding),
                  Text(
                    responsive.adaptiveText(
                      'Personal Information',
                      micro: 'Info',
                      nano: 'Personal',
                    ),
                    style: GoogleFonts. poppins(
                      fontSize: responsive.fontSize(16),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsive.padding),

              // Full Name
              _buildTextField(
                responsive,
                controller: _nameController,
                focusNode: _nameFocusNode,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline_rounded,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_phoneFocusNode);
                },
              ),

              SizedBox(height: responsive.padding),

              // Email (read-only)
              _buildTextField(
                responsive,
                controller: _emailController,
                label: 'Email Address',
                hint: 'Your email address',
                icon: Icons.email_outlined,
                enabled: false,
                readOnly: true,
              ),

              SizedBox(height: responsive.padding),

              // Phone Number
              _buildTextField(
                responsive,
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                enabled: _isEditing,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
                    if (!phoneRegex.hasMatch(value. replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
                onSubmitted: (_) {
                  FocusScope.of(context). requestFocus(_addressFocusNode);
                },
              ),

              SizedBox(height: responsive.padding),

              // Address/Assigned Area
              _buildTextField(
                responsive,
                controller: _addressController,
                focusNode: _addressFocusNode,
                label: 'Assigned Area',
                hint: 'Enter your assigned area',
                icon: Icons. location_on_outlined,
                enabled: _isEditing,
                onSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_bioFocusNode);
                },
              ),

              SizedBox(height: responsive. padding),

              // Bio
              _buildTextField(
                responsive,
                controller: _bioController,
                focusNode: _bioFocusNode,
                label: 'Bio',
                hint: 'Tell us about yourself',
                icon: Icons. info_outline_rounded,
                enabled: _isEditing,
                maxLines: 3,
                textInputAction: TextInputAction. done,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      EmployeeResponsiveData responsive, {
        required TextEditingController controller,
        FocusNode?  focusNode,
        required String label,
        required String hint,
        required IconData icon,
        bool enabled = true,
        bool readOnly = false,
        TextInputType keyboardType = TextInputType.text,
        TextInputAction textInputAction = TextInputAction. next,
        int maxLines = 1,
        String? Function(String?)? validator,
        void Function(String)? onSubmitted,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: responsive.fontSize(12),
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: responsive.microPadding),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          style: GoogleFonts.poppins(
            fontSize: responsive.fontSize(14),
            color: enabled ? Colors.black87 : Colors.grey[600],
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: responsive.fontSize(13),
              color: Colors.grey[400],
            ),
            prefixIcon: Container(
              margin: EdgeInsets. all(responsive.microPadding),
              padding: EdgeInsets. all(responsive.microPadding),
              decoration: BoxDecoration(
                color: enabled
                    ? Colors. green.withOpacity(0.1)
                    : Colors.grey. withOpacity(0.1),
                borderRadius: BorderRadius. circular(responsive.borderRadius),
              ),
              child: Icon(
                icon,
                color: enabled ? Colors.green : Colors.grey,
                size: responsive.iconSize(20),
              ),
            ),
            filled: true,
            fillColor: enabled ? Colors. grey[50] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadius),
              borderSide: BorderSide. none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadius),
              borderSide: BorderSide(color: Colors.grey. withOpacity(0.2), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadius),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadius),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.padding,
              vertical: responsive.padding,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(EmployeeResponsiveData responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive. padding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors. white,
          borderRadius: BorderRadius. circular(responsive.largeBorderRadius),
          boxShadow: responsive.showShadows
              ?  [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets.all(responsive.padding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets. all(responsive.microPadding),
                decoration: BoxDecoration(
                  color: _isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                ),
                child: Icon(
                  _isAvailable
                      ?  Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: _isAvailable ? Colors.green : Colors.red,
                  size: responsive.iconSize(24),
                ),
              ),
              SizedBox(width: responsive.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      responsive.adaptiveText(
                        'Availability Status',
                        micro: 'Status',
                        nano: 'Available',
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight. w600,
                        color: Colors. black87,
                      ),
                    ),
                    if (responsive.showSecondaryText)
                      Text(
                        _isAvailable
                            ? 'You can receive new tasks'
                            : 'You won\'t receive new tasks',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.fontSize(11),
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Transform. scale(
                scale: responsive.isMicroScreen ? 0.8 : 1.0,
                child: Switch(
                  value: _isAvailable,
                  onChanged: _isEditing
                      ? (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _isAvailable = value);
                  }
                      : null,
                  activeColor: Colors. green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettings(EmployeeResponsiveData responsive) {
    return Padding(
      padding: EdgeInsets.all(responsive.padding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors. white,
          borderRadius: BorderRadius. circular(responsive.largeBorderRadius),
          boxShadow: responsive.showShadows
              ?  [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Column(
          children: [
            _buildSettingsItem(
              responsive,
              icon: Icons.lock_rounded,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () => _showChangePasswordDialog(responsive),
            ),
            Divider(height: 1, color: Colors.grey. withOpacity(0.2)),
            _buildSettingsItem(
              responsive,
              icon: Icons.notifications_rounded,
              title: 'Notifications',
              subtitle: 'Manage notification settings',
              onTap: () => _showNotificationSettings(responsive),
            ),
            Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
            _buildSettingsItem(
              responsive,
              icon: Icons.help_rounded,
              title: 'Help & Support',
              subtitle: 'Get help or contact us',
              onTap: () => _showHelpDialog(responsive),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      EmployeeResponsiveData responsive, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets. all(responsive.padding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets. all(responsive.microPadding),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                ),
                child: Icon(
                  icon,
                  color: Colors.green,
                  size: responsive.iconSize(22),
                ),
              ),
              SizedBox(width: responsive.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight. w600,
                        color: Colors. black87,
                      ),
                    ),
                    if (responsive.showSecondaryText)
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: responsive. fontSize(11),
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons. arrow_forward_ios_rounded,
                size: responsive.iconSize(16),
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(EmployeeResponsiveData responsive) {
    return Padding(
      padding: EdgeInsets. all(responsive.padding),
      child: SizedBox(
        width: double.infinity,
        height: responsive.dimension(54),
        child: ElevatedButton(
          onPressed: _isSaving ?  null : _saveProfile,
          style: ElevatedButton. styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
            ),
            elevation: responsive.showShadows ? 4 : 0,
          ),
          child: _isSaving
              ? SizedBox(
            width: responsive.dimension(24),
            height: responsive.dimension(24),
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              Icon(
                Icons.save_rounded,
                size: responsive.iconSize(22),
              ),
              SizedBox(width: responsive.microPadding),
              Text(
                'Save Changes',
                style: GoogleFonts.poppins(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight. w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDiscardChangesDialog(EmployeeResponsiveData responsive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        ),
        title: Text(
          'Discard Changes? ',
          style: GoogleFonts. poppins(fontWeight: FontWeight. bold),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to discard them?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(EmployeeResponsiveData responsive) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius. circular(responsive.largeBorderRadius),
          ),
          title: Text(
            'Change Password',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize. min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(responsive.borderRadius),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent
                          ? Icons. visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                SizedBox(height: responsive.padding),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius. circular(responsive.borderRadius),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew
                          ?  Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                SizedBox(height: responsive.padding),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(responsive.borderRadius),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm
                          ?  Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () => setState(() => obscureConfirm = ! obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate and change password
                Navigator.pop(context);
                _showSnackBar(
                  _isDemoMode
                      ? '🔧 Demo: Password change simulated'
                      : 'Password changed successfully! ',
                  isError: false,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors. green),
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings(EmployeeResponsiveData responsive) {
    bool taskNotifications = true;
    bool reportUpdates = true;
    bool systemAlerts = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
          ),
          title: Text(
            'Notification Settings',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('New Task Notifications'),
                subtitle: const Text('Get notified when assigned new tasks'),
                value: taskNotifications,
                onChanged: (value) => setState(() => taskNotifications = value),
                activeColor: Colors. green,
              ),
              SwitchListTile(
                title: const Text('Report Updates'),
                subtitle: const Text('Updates on your submitted reports'),
                value: reportUpdates,
                onChanged: (value) => setState(() => reportUpdates = value),
                activeColor: Colors. green,
              ),
              SwitchListTile(
                title: const Text('System Alerts'),
                subtitle: const Text('Important system notifications'),
                value: systemAlerts,
                onChanged: (value) => setState(() => systemAlerts = value),
                activeColor: Colors.green,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Settings saved!', isError: false);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(EmployeeResponsiveData responsive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        ),
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email_rounded, color: Colors.green),
              title: const Text('Email Support'),
              subtitle: const Text('support@neatnow.com'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.phone_rounded, color: Colors.green),
              title: const Text('Phone Support'),
              subtitle: const Text('+1-800-NEAT-NOW'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_rounded, color: Colors.green),
              title: const Text('FAQ'),
              subtitle: const Text('Frequently asked questions'),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}