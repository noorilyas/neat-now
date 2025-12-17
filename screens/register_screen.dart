import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/services/auth_service.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// RegisterScreen - Implements FR-U1: User Registration & Profile Management
/// Allows users to register using their name, email, password, phone number,
/// and an optional profile image.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  // Focus nodes
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  File? _profileImage;
  int _currentStep = 0;

  // Error states
  Map<String, String? > _errors = {};

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController. dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController. dispose();
    _nameFocusNode. dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode. dispose();
    _animationController.dispose();
    super. dispose();
  }

  // Validation methods
  bool _validateName(String name) {
    if (name.isEmpty) {
      _errors['name'] = 'Name is required';
      return false;
    }
    if (name.length < 2) {
      _errors['name'] = 'Name must be at least 2 characters';
      return false;
    }
    _errors['name'] = null;
    return true;
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      _errors['email'] = 'Email is required';
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex. hasMatch(email)) {
      _errors['email'] = 'Please enter a valid email address';
      return false;
    }
    _errors['email'] = null;
    return true;
  }

  bool _validatePhone(String phone) {
    if (phone.isEmpty) {
      _errors['phone'] = 'Phone number is required';
      return false;
    }
    final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
    if (!phoneRegex. hasMatch(phone. replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      _errors['phone'] = 'Please enter a valid phone number';
      return false;
    }
    _errors['phone'] = null;
    return true;
  }

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      _errors['password'] = 'Password is required';
      return false;
    }
    if (password.length < 8) {
      _errors['password'] = 'Password must be at least 8 characters';
      return false;
    }
    if (! RegExp(r'[A-Z]'). hasMatch(password)) {
      _errors['password'] = 'Password must contain an uppercase letter';
      return false;
    }
    if (! RegExp(r'[0-9]').hasMatch(password)) {
      _errors['password'] = 'Password must contain a number';
      return false;
    }
    _errors['password'] = null;
    return true;
  }

  bool _validateConfirmPassword(String confirmPassword) {
    if (confirmPassword.isEmpty) {
      _errors['confirmPassword'] = 'Please confirm your password';
      return false;
    }
    if (confirmPassword != _passwordController.text) {
      _errors['confirmPassword'] = 'Passwords do not match';
      return false;
    }
    _errors['confirmPassword'] = null;
    return true;
  }

  bool _validateCurrentStep() {
    setState(() {
      _errors = {};
    });

    bool isValid = true;

    if (_currentStep == 0) {
      isValid = _validateName(_nameController.text. trim()) &&
          _validateEmail(_emailController. text.trim()) &&
          _validatePhone(_phoneController.text.trim());
    } else if (_currentStep == 1) {
      isValid = _validatePassword(_passwordController.text) &&
          _validateConfirmPassword(_confirmPasswordController.text);
    }

    setState(() {});
    return isValid;
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
        _profileImage = File(image.path);
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors. grey[300],
              borderRadius: BorderRadius. circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose Profile Photo',
            style: GoogleFonts. poppins(
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
                  final XFile? image = await _imagePicker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                    maxWidth: 512,
                    maxHeight: 512,
                  );
                  if (context.mounted) Navigator.pop(context, image);
                },
              ),
              _buildPickerOption(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                onTap: () async {
                  final XFile? image = await _imagePicker. pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                    maxWidth: 512,
                    maxHeight: 512,
                  );
                  if (context.mounted) Navigator.pop(context, image);
                },
              ),
              if (_profileImage != null)
                _buildPickerOption(
                  icon: Icons.delete_rounded,
                  label: 'Remove',
                  color: const Color(0xFFDC2626),
                  onTap: () {
                    setState(() => _profileImage = null);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF059669),
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

  Future<void> _register() async {
    FocusScope.of(context). unfocus();

    if (! _agreeToTerms) {
      _showSnackBar(
        title: 'Terms Required',
        message: 'Please agree to the Terms of Service and Privacy Policy',
        isError: true,
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final result = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text. trim(). toLowerCase(),
        password: _passwordController. text,
        phoneNumber: _phoneController.text.trim(),
        profileImage: _profileImage,
      );

      if (! mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        _showSnackBar(
          title: 'Registration Successful! ',
          message: 'Please check your email to verify your account.',
          isError: false,
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(
          title: 'Registration Failed',
          message: result['message'] ?? 'Please try again',
          isError: true,
        );
      }
    } catch (e) {
      if (! mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(
        title: 'Connection Error',
        message: 'Please check your internet connection.',
        isError: true,
      );
    }
  }

  void _showSnackBar({
    required String title,
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context). showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight. w700,
                    ),
                  ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.05;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF022c22),
              Color(0xFF064e3b),
              Color(0xFF047857),
              Color(0xFF059669),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white. withOpacity(0.15),
                          borderRadius: BorderRadius. circular(14),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight. w700,
                        color: Colors. white,
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Indicator
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: _buildProgressIndicator(),
              ),

              SizedBox(height: padding),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets. all(padding),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCurrentStep(padding),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        final isCompleted = index < _currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors. white
                        : Colors. white.withOpacity(0.3),
                    borderRadius: BorderRadius. circular(2),
                  ),
                ),
              ),
              if (index < 2) const SizedBox(width: 8),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep(double padding) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep(padding);
      case 1:
        return _buildPasswordStep(padding);
      case 2:
        return _buildProfilePhotoStep(padding);
      default:
        return _buildPersonalInfoStep(padding);
    }
  }

  Widget _buildPersonalInfoStep(double padding) {
    return _buildFormCard(
      title: 'Personal Information',
      subtitle: 'Enter your basic details',
      icon: Icons.person_rounded,
      padding: padding,
      children: [
        _buildTextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline_rounded,
          error: _errors['name'],
          textInputAction: TextInputAction. next,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
        ),
        SizedBox(height: padding),
        _buildTextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          error: _errors['email'],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocusNode),
        ),
        SizedBox(height: padding),
        _buildTextField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          label: 'Phone Number',
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
          error: _errors['phone'],
          keyboardType: TextInputType. phone,
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: padding * 1.5),
        _buildNextButton('Continue', () {
          if (_validateCurrentStep()) {
            setState(() => _currentStep = 1);
          }
        }),
      ],
    );
  }

  Widget _buildPasswordStep(double padding) {
    return _buildFormCard(
      title: 'Create Password',
      subtitle: 'Choose a strong password',
      icon: Icons.lock_rounded,
      padding: padding,
      children: [
        _buildTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          label: 'Password',
          hint: 'Create a password',
          icon: Icons.lock_outline_rounded,
          error: _errors['password'],
          isPassword: true,
          obscureText: _obscurePassword,
          onToggleObscure: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope. of(context).requestFocus(_confirmPasswordFocusNode),
        ),
        SizedBox(height: padding * 0.5),
        _buildPasswordStrengthIndicator(),
        SizedBox(height: padding),
        _buildTextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          label: 'Confirm Password',
          hint: 'Confirm your password',
          icon: Icons.lock_outline_rounded,
          error: _errors['confirmPassword'],
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onToggleObscure: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: padding * 1.5),
        Row(
          children: [
            Expanded(
              child: _buildBackButton(() {
                setState(() => _currentStep = 0);
              }),
            ),
            SizedBox(width: padding),
            Expanded(
              flex: 2,
              child: _buildNextButton('Continue', () {
                if (_validateCurrentStep()) {
                  setState(() => _currentStep = 2);
                }
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController. text;
    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]'). hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),. ?":{}|<>]').hasMatch(password)) strength++;

    Color strengthColor;
    String strengthText;

    if (strength <= 2) {
      strengthColor = const Color(0xFFDC2626);
      strengthText = 'Weak';
    } else if (strength <= 3) {
      strengthColor = const Color(0xFFF59E0B);
      strengthText = 'Medium';
    } else {
      strengthColor = const Color(0xFF059669);
      strengthText = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: index < strength
                      ? strengthColor
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        if (password.isNotEmpty)
          Text(
            'Password Strength: $strengthText',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: strengthColor,
            ),
          ),
      ],
    );
  }

  Widget _buildProfilePhotoStep(double padding) {
    return _buildFormCard(
      title: 'Profile Photo',
      subtitle: 'Add a photo (optional)',
      icon: Icons.camera_alt_rounded,
      padding: padding,
      children: [
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF0FDF4),
                    border: Border.all(
                      color: const Color(0xFF10b981). withOpacity(0.3),
                      width: 3,
                    ),
                    image: _profileImage != null
                        ?  DecorationImage(
                      image: FileImage(_profileImage!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _profileImage == null
                      ?  const Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: Color(0xFF10b981),
                  )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors. white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: padding),
        Text(
          'Tap to add a profile photo',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: padding * 1.5),

        // Terms checkbox
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _agreeToTerms = !_agreeToTerms);
          },
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: _agreeToTerms
                      ? const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10b981)],
                  )
                      : null,
                  color: _agreeToTerms ?  null : Colors.transparent,
                  borderRadius: BorderRadius. circular(7),
                  border: Border.all(
                    color: _agreeToTerms
                        ? Colors. transparent
                        : Colors.grey[400]! ,
                    width: 2,
                  ),
                ),
                child: _agreeToTerms
                    ? const Icon(Icons.check_rounded, color: Colors. white, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight. w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: padding * 1.5),
        Row(
          children: [
            Expanded(
              child: _buildBackButton(() {
                setState(() => _currentStep = 1);
              }),
            ),
            SizedBox(width: padding),
            Expanded(
              flex: 2,
              child: _buildNextButton(
                'Create Account',
                _register,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required double padding,
    required List<Widget> children,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(padding * 1.2),
          decoration: BoxDecoration(
            color: Colors. white. withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10b981). withOpacity(0.15),
                      borderRadius: BorderRadius. circular(14),
                    ),
                    child: Icon(icon, color: const Color(0xFF047857), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts. poppins(
                          fontSize: 18,
                          fontWeight: FontWeight. w700,
                          color: const Color(0xFF1a1a2e),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: padding * 1.2),
              ... children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    String?  error,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleObscure,
    Function(String)? onSubmitted,
  }) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: hasError
            ? const Color(0xFFDC2626)
            : const Color(0xFF4a4a4a),
      ),
    ),
    const SizedBox(height: 8),
    TextField(
    controller: controller,
    focusNode: focusNode,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    obscureText: isPassword && obscureText,
    onSubmitted: onSubmitted,
    style: GoogleFonts.poppins(
    fontSize: 15,
    color: const Color(0xFF1a1a2e),
    ),
    decoration: InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.grey[400],
    ),
    prefixIcon: Container(
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: const Color(0xFF10b981).withOpacity(0.1),
    borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: const Color(0xFF059669), size: 20),
    ),
    suffixIcon: isPassword
    ? GestureDetector(
    onTap: onToggleObscure,
    child: Container(
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets. all(8),
    child: Icon(
    obscureText
    ? Icons. visibility_off_rounded
        : Icons.visibility_rounded,
    color: Colors.grey[500],
    size: 20,
    ),
    ),
    )
        : null,
    filled: true,
    fillColor: hasError
    ? const Color(0xFFFEF2F2)
    : const Color(0xFFF8F9FA),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide. none,
    ),
    enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
    color: hasError
    ?  const Color(0xFFDC2626). withOpacity(0.5)
        : Colors.grey. withOpacity(0.1),
    width: 1.5,
    ),
    ),
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(
    color: hasError
    ? const Color(0xFFDC2626)
        : const Color(0xFF10b981),
    width: 2,
    ),
    ),
    contentPadding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
    ),
    ),
    ),
    if (hasError) ...[
    const SizedBox(height: 6),
    Row(
    children: [
    const Icon(
    Icons.error_outline_rounded,
    size: 14,
    color: Color(0xFFDC2626),
    ),
    const SizedBox(width: 4),
    Expanded(
    child: Text(
    error,
    style: GoogleFonts.poppins(
    fontSize: 11,
    color: const Color(0xFFDC2626),
    fontWeight: FontWeight.w500,
    ),
    ),
    ),
    ],
    ),
    ],
    ],
    );
  }

  Widget _buildNextButton(String text, VoidCallback onPressed, {bool isLoading = false}) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x67F0C0), Color(0x67F0C0), Color(0x67F0C0)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x67F0C0).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius. circular(16),
          child: Center(
            child: isLoading
                ?  const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight. w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(VoidCallback onPressed) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors. grey[300]! ,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius. circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.grey[700],
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight. w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}