import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/services/auth_service.dart';
import 'dart:ui';

/// ForgotPasswordScreen - Implements FR-U1: Password Reset
/// Allows users to reset their forgotten password through email-based verification
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  final FocusNode _emailFocusNode = FocusNode();

  bool _isLoading = false;
  bool _emailSent = false;
  bool _emailHasFocus = false;
  String? _emailError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves. easeOutQuart,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _emailFocusNode.addListener(() {
      setState(() => _emailHasFocus = _emailFocusNode.hasFocus);
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode. dispose();
    _animationController.dispose();
    super. dispose();
  }

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return false;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex. hasMatch(email)) {
      setState(() => _emailError = 'Please enter a valid email address');
      return false;
    }

    setState(() => _emailError = null);
    return true;
  }

  Future<void> _sendResetEmail() async {
    FocusScope.of(context).unfocus();

    if (!_validateEmail(_emailController. text. trim())) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final result = await _authService.requestPasswordReset(
        _emailController.text. trim(). toLowerCase(),
      );

      if (! mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        setState(() => _emailSent = true);
        _showSnackBar(
          title: 'Email Sent! ',
          message: 'Check your inbox for the password reset link.',
          isError: false,
        );
      } else {
        _showSnackBar(
          title: 'Error',
          message: result['message'] ?? 'Failed to send reset email',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
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
              isError ?  Icons.error_outline_rounded : Icons.check_circle_rounded,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight. w400,
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
    final size = MediaQuery. of(context).size;
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
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius. circular(14),
                          border: Border.all(
                            color: Colors.white. withOpacity(0.2),
                          ),
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
                      'Forgot Password',
                      style: GoogleFonts. poppins(
                        fontSize: 20,
                        fontWeight: FontWeight. w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets. all(padding),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _emailSent
                          ?  _buildSuccessContent(padding)
                          : _buildFormContent(padding),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(double padding) {
    return Column(
      children: [
        SizedBox(height: padding * 2),

        // Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10b981).withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 50,
            color: Color(0xFF047857),
          ),
        ),

        SizedBox(height: padding * 2),

        // Title
        Text(
          'Reset Your Password',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: padding * 0.5),

        // Subtitle
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white. withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: padding * 2),

        // Form Card
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: EdgeInsets. all(padding * 1.2),
              decoration: BoxDecoration(
                color: Colors. white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
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
                  Text(
                    'Email Address',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight. w600,
                      color: _emailError != null
                          ? const Color(0xFFDC2626)
                          : _emailHasFocus
                          ? const Color(0xFF047857)
                          : const Color(0xFF4a4a4a),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts. poppins(
                      fontSize: 15,
                      color: const Color(0xFF1a1a2e),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10b981).withOpacity(0.1),
                          borderRadius: BorderRadius. circular(10),
                        ),
                        child: Icon(
                          Icons.email_rounded,
                          color: _emailHasFocus
                              ? const Color(0xFF047857)
                              : const Color(0xFF059669),
                          size: 20,
                        ),
                      ),
                      filled: true,
                      fillColor: _emailHasFocus
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide. none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius. circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF10b981),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  if (_emailError != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _emailError!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: padding * 1.5),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius. circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send Reset Link',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight. w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.send_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(height: padding * 2),

        // Back to login
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator. pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons. arrow_back_rounded,
                color: Colors.white. withOpacity(0.8),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Back to Login',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors. white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessContent(double padding) {
    return Column(
      children: [
        SizedBox(height: padding * 3),

        // Success Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10b981).withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 60,
            color: Color(0xFF059669),
          ),
        ),

        SizedBox(height: padding * 2),

        Text(
          'Check Your Email',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign. center,
        ),

        SizedBox(height: padding * 0.5),

        Text(
          'We\'ve sent a password reset link to:',
          style: GoogleFonts. poppins(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: padding * 0.5),

        Container(
          padding: EdgeInsets. symmetric(
            horizontal: padding,
            vertical: padding * 0.5,
          ),
          decoration: BoxDecoration(
            color: Colors.white. withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _emailController.text.trim(),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight. w600,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(height: padding * 2),

        // Instructions
        Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors. white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildInstructionRow(
                '1',
                'Open the email we sent you',
                Icons.email_outlined,
              ),
              SizedBox(height: padding * 0.8),
              _buildInstructionRow(
                '2',
                'Click on the reset password link',
                Icons.link_rounded,
              ),
              SizedBox(height: padding * 0.8),
              _buildInstructionRow(
                '3',
                'Create your new password',
                Icons.lock_outline_rounded,
              ),
            ],
          ),
        ),

        SizedBox(height: padding * 2),

        // Resend button
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: Text(
            'Didn\'t receive the email? Resend',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration. underline,
            ),
          ),
        ),

        SizedBox(height: padding),

        // Back to login
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator. pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors. white,
              side: const BorderSide(color: Colors. white, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius. circular(16),
              ),
            ),
            child: Text(
              'Back to Login',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionRow(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white. withOpacity(0.9),
            ),
          ),
        ),
        Icon(
          icon,
          color: Colors.white.withOpacity(0.6),
          size: 20,
        ),
      ],
    );
  }
}