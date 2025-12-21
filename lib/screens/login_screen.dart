import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/screens/forgot_password_screen.dart';
import 'package:neat_now/screens/register_screen.dart';
import 'package:neat_now/services/auth_service.dart';
import 'package:neat_now/config/credentials.dart';
import 'dart:math' as math;
import 'dart:ui';

import '../views/employee/employee_dashboard_page.dart';
import '../views/user/user_dashboard_view.dart';

/// LoginScreen - Implements FR-U2 (User Authentication) & FR-W1 (Worker Authentication)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Services
  final AuthService _authService = AuthService();

  // State variables
  bool _isUserLogin = true;
  bool _isLoading = false;
  bool _obscureText = true;
  bool _rememberMe = false;
  bool _emailHasFocus = false;
  bool _passwordHasFocus = false;
  String? _emailError;
  String? _passwordError;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // Particles for background animation
  final List<Particle> _particles = [];

  // Screen size breakpoints
  static const double _mobileBreakpoint = 480;
  static const double _tabletBreakpoint = 768;
  static const double _desktopBreakpoint = 1024;

  @override
  void initState() {
    super.initState();
    _initializeSystem();
    _initializeParticles();
    _initializeAnimations();
    _setupFocusListeners();
    _loadSavedCredentials();
    _startAnimations();
  }

  void _initializeSystem() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF064635),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeParticles() {
    for (int i = 0; i < 35; i++) {
      _particles.add(Particle());
    }
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves. elasticOut,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));
  }

  void _setupFocusListeners() {
    _emailFocusNode. addListener(() {
      setState(() => _emailHasFocus = _emailFocusNode.hasFocus);
      if (! _emailFocusNode.hasFocus) {
        _validateEmail(_emailController.text);
      }
    });

    _passwordFocusNode. addListener(() {
      setState(() => _passwordHasFocus = _passwordFocusNode.hasFocus);
      if (!_passwordFocusNode.hasFocus) {
        _validatePassword(_passwordController.text);
      }
    });
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final savedData = await _authService.getSavedCredentials();
      if (savedData != null && savedData['remember'] == true) {
        setState(() {
          _emailController.text = savedData['email'] ?? '';
          _rememberMe = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved credentials: $e');
    }
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 250));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController. dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _slideController. dispose();
    _scaleController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _buttonController. dispose();
    super.dispose();
  }

  // ==================== VALIDATION METHODS ====================

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

  bool _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      return false;
    }

    if (password. length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return false;
    }

    setState(() => _passwordError = null);
    return true;
  }

  bool _validateForm() {
    final isEmailValid = _validateEmail(_emailController. text. trim());
    final isPasswordValid = _validatePassword(_passwordController.text);
    return isEmailValid && isPasswordValid;
  }

  // ==================== AUTHENTICATION METHODS ====================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (! _validateForm()) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        _emailController.text. trim(). toLowerCase(),
        _passwordController.text,
        _isUserLogin,
      );

      if (! mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        if (_rememberMe) {
          await _authService.saveCredentials(
            email: _emailController. text.trim(),
            remember: true,
          );
        } else {
          await _authService.clearSavedCredentials();
        }

        _showSnackBar(
          title: 'Welcome back!',
          message: _isUserLogin ? 'Logged in as Citizen' : 'Logged in as Worker',
          isError: false,
        );

        await Future.delayed(const Duration(milliseconds: 600));

        if (! mounted) return;

        // Get user data from result
        final userData = result['userData'] as Map<String, dynamic>?  ??  {
          'id': '1',
          'name': result['name'] ??  'User',
          'email': _emailController.text. trim(),
          'phone': result['phone'] ?? '',
          'profileImage': result['profileImage'],
          'totalReports': result['totalReports'] ?? 0,
          'verifiedReports': result['verifiedReports'] ??  0,
          'rank': result['rank'] ?? 0,
          'badge': result['badge'],
        };

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              if (_isUserLogin) {
                return UserDashboard(
                  userData: userData,
                  onLogout: () => _handleLogout(context),
                );
              } else {
                return EmployeeDashboard(
                );
              }
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.02, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        _showSnackBar(
          title: 'Login Failed',
          message: result['message'] ??  'Invalid email or password',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      _showSnackBar(
        title: 'Connection Error',
        message: 'Please check your internet connection and try again.',
        isError: true,
      );
    }
  }

  void _handleLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> _googleSignIn() async {
    HapticFeedback.lightImpact();
    _showSnackBar(
      title: 'Coming Soon',
      message: 'Google Sign-In will be available in the next update! ',
      isError: false,
    );
  }

  void _navigateToForgotPassword() {
    HapticFeedback.lightImpact();
    Navigator. push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  void _navigateToRegister() {
    HapticFeedback. lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _fillDemoCredentials() {
    HapticFeedback.lightImpact();
    setState(() {
      _emailController.text = _isUserLogin
          ? AppCredentials.demoUserEmail
          : AppCredentials.demoEmployeeEmail;
      _passwordController.text = _isUserLogin
          ? AppCredentials. demoUserPassword
          : AppCredentials.demoEmployeePassword;
      _emailError = null;
      _passwordError = null;
    });

    _showSnackBar(
      title: 'Demo Credentials',
      message: 'Filled ${_isUserLogin ?  "Citizen" : "Worker"} credentials',
      isError: false,
    );
  }

  void _showSnackBar({
    required String title,
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger. of(context).hideCurrentSnackBar();
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets. all(10),
              decoration: BoxDecoration(
                color: Colors. white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize. min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight. w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight. w400,
                      color: Colors.white. withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow. ellipsis,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  // ==================== RESPONSIVE HELPERS ====================

  ScreenSize _getScreenSize(double width) {
    if (width < _mobileBreakpoint) return ScreenSize.small;
    if (width < _tabletBreakpoint) return ScreenSize.mobile;
    if (width < _desktopBreakpoint) return ScreenSize. tablet;
    return ScreenSize.desktop;
  }

  ResponsiveConfig _getResponsiveConfig(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;
    final screenSize = _getScreenSize(screenWidth);
    final isLandscape = screenWidth > screenHeight;

    double containerWidth;
    double padding;
    double logoSize;
    double fontScale;
    double buttonHeight;
    double inputHeight;
    bool showFloatingIcons;
    bool compactMode;

    switch (screenSize) {
      case ScreenSize.small:
        containerWidth = screenWidth * 0.95;
        padding = 12.0;
        logoSize = math.min(80.0, screenWidth * 0.2);
        fontScale = 0.85;
        buttonHeight = 48.0;
        inputHeight = 52.0;
        showFloatingIcons = false;
        compactMode = true;
        break;
      case ScreenSize. mobile:
        containerWidth = math.min(400.0, screenWidth * 0.92);
        padding = 16.0;
        logoSize = math.min(100.0, screenWidth * 0.22);
        fontScale = 1.0;
        buttonHeight = 54.0;
        inputHeight = 56.0;
        showFloatingIcons = ! isLandscape;
        compactMode = isLandscape;
        break;
      case ScreenSize. tablet:
        containerWidth = math.min(450.0, screenWidth * 0.7);
        padding = 20.0;
        logoSize = 110.0;
        fontScale = 1.1;
        buttonHeight = 58.0;
        inputHeight = 60.0;
        showFloatingIcons = true;
        compactMode = false;
        break;
      case ScreenSize.desktop:
        containerWidth = math.min(480.0, screenWidth * 0.4);
        padding = 24.0;
        logoSize = 120.0;
        fontScale = 1.15;
        buttonHeight = 60.0;
        inputHeight = 62.0;
        showFloatingIcons = true;
        compactMode = false;
        break;
    }

    return ResponsiveConfig(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      containerWidth: containerWidth,
      padding: padding,
      logoSize: logoSize,
      fontScale: fontScale,
      buttonHeight: buttonHeight,
      inputHeight: inputHeight,
      showFloatingIcons: showFloatingIcons,
      compactMode: compactMode,
      isLandscape: isLandscape,
      screenSize: screenSize,
    );
  }

  // ==================== BUILD METHODS ====================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final config = _getResponsiveConfig(constraints);

        return Scaffold(
          resizeToAvoidBottomInset: true,
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
                  Color(0xFF10b981),
                ],
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles background
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ParticlePainter(
                        _particles,
                        _particleController.value,
                        config. screenWidth,
                        config.screenHeight,
                      ),
                      size: Size. infinite,
                    );
                  },
                ),

                // Decorative gradient orbs
                _buildDecorativeOrbs(config),

                // Main content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: config.padding,
                        vertical: config.compactMode
                            ? config. padding * 0.5
                            : config.padding,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: config.containerWidth,
                        ),
                        child: config.isLandscape && config.screenSize == ScreenSize.mobile
                            ? _buildLandscapeLayout(config)
                            : _buildPortraitLayout(config),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(ResponsiveConfig config) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo with animation
        if (! config.compactMode)
          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: _buildLogo(config),
                  );
                },
              ),
            ),
          ),

        SizedBox(height: config.padding * 1.2),

        // Welcome text
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildWelcomeText(config),
          ),
        ),

        SizedBox(height: config. padding * (config.compactMode ? 1.0 : 1.5)),

        // Login type toggle
        FadeTransition(
          opacity: _fadeAnimation,
          child: _buildLoginTypeToggle(config),
        ),

        SizedBox(height: config.padding * (config.compactMode ? 1.0 : 1.3)),

        // Login form
        FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: _buildLoginForm(config),
          ),
        ),

        SizedBox(height: config.padding * 0.8),

        // Demo credentials
        FadeTransition(
          opacity: _fadeAnimation,
          child: _buildDemoCredentials(config),
        ),

        if (! config.compactMode) ...[
          SizedBox(height: config.padding * 0.6),

          // Footer
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildFooter(config),
          ),
        ],
      ],
    );
  }

  Widget _buildLandscapeLayout(ResponsiveConfig config) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - Logo and welcome
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildLogo(config),
                ),
              ),
              SizedBox(height: config.padding),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildWelcomeText(config),
              ),
              SizedBox(height: config.padding),
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildDemoCredentials(config),
              ),
            ],
          ),
        ),

        SizedBox(width: config.padding),

        // Right side - Form
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLoginTypeToggle(config),
              ),
              SizedBox(height: config.padding),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildLoginForm(config),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeOrbs(ResponsiveConfig config) {
    return Stack(
      children: [
        Positioned(
          top: -config.screenHeight * 0.1,
          right: -config.screenWidth * 0.15,
          child: Container(
            width: config.screenWidth * 0.5,
            height: config.screenWidth * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF10b981). withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -config.screenHeight * 0.05,
          left: -config.screenWidth * 0.1,
          child: Container(
            width: config.screenWidth * 0.4,
            height: config.screenWidth * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape. circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF059669).withOpacity(0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(ResponsiveConfig config) {
    return Container(
      width: config.logoSize,
      height: config.logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10b981). withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: config.logoSize * 0.88,
            height: config.logoSize * 0.88,
            decoration: BoxDecoration(
              shape: BoxShape. circle,
              border: Border.all(
                color: const Color(0xFF10b981). withOpacity(0.25),
                width: 2,
              ),
            ),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment. bottomRight,
                  colors: [Color(0xFF047857), Color(0xFF10b981)],
                ). createShader(bounds),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: config.logoSize * 0.32,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: config.logoSize * 0.02),
              Container(
                padding: EdgeInsets. symmetric(
                  horizontal: config.logoSize * 0.1,
                  vertical: config.logoSize * 0.03,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF047857), Color(0xFF10b981)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10b981).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize. min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: config.logoSize * 0.07,
                      color: Colors.white,
                    ),
                    SizedBox(width: config. logoSize * 0.02),
                    Text(
                      'AI',
                      style: GoogleFonts. poppins(
                        fontSize: config.logoSize * 0.09,
                        fontWeight: FontWeight. w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(ResponsiveConfig config) {
    return Column(
      children: [
        Text(
          'Welcome Back! ',
          style: GoogleFonts. poppins(
            fontSize: 26 * config.fontScale,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: Colors.black. withOpacity(0.2),
                offset: const Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: config.padding * 0.3),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: config.padding * 0.8,
            vertical: config.padding * 0.35,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors. white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius. circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize. min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius. circular(8),
                ),
                child: Icon(
                  Icons. eco_rounded,
                  color: Colors.white,
                  size: 14 * config.fontScale,
                ),
              ),
              SizedBox(width: 8 * config.fontScale),
              Flexible(
                child: Text(
                  'AI-Powered Waste Detection',
                  style: GoogleFonts.poppins(
                    fontSize: 11 * config.fontScale,
                    color: Colors.white. withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow. ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginTypeToggle(ResponsiveConfig config) {
    final toggleWidth = math.min(320.0, config.containerWidth * 0.85);

    return Container(
      width: toggleWidth,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors. white.withOpacity(0.12),
            Colors. white.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(
          color: Colors. white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildToggleOption(
            label: 'Citizen',
            icon: Icons.person_rounded,
            isActive: _isUserLogin,
            config: config,
            onTap: () {
              if (! _isUserLogin) {
                HapticFeedback. selectionClick();
                setState(() {
                  _isUserLogin = true;
                  _clearForm();
                });
              }
            },
          ),
          _buildToggleOption(
            label: 'Worker',
            icon: Icons. cleaning_services_rounded,
            isActive: !_isUserLogin,
            config: config,
            onTap: () {
              if (_isUserLogin) {
                HapticFeedback.selectionClick();
                setState(() {
                  _isUserLogin = false;
                  _clearForm();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required IconData icon,
    required bool isActive,
    required ResponsiveConfig config,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 12 * config.fontScale),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
              colors: [Colors.white, Color(0xFFF0FDF4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
                : null,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: Colors. black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets. all(isActive ? 6 : 0),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF10b981). withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius. circular(8),
                ),
                child: Icon(
                  icon,
                  color: isActive
                      ? const Color(0xFF047857)
                      : Colors.white. withOpacity(0.85),
                  size: 18 * config.fontScale,
                ),
              ),
              SizedBox(width: 6 * config.fontScale),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isActive
                      ? const Color(0xFF047857)
                      : Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w700,
                  fontSize: 13 * config.fontScale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _emailError = null;
    _passwordError = null;
  }

  Widget _buildLoginForm(ResponsiveConfig config) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(config.padding * 1.2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.95),
                Colors. white.withOpacity(0.90),
              ],
            ),
            borderRadius: BorderRadius. circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10b981).withOpacity(0.15),
                            const Color(0xFF059669).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius. circular(12),
                      ),
                      child: Icon(
                        _isUserLogin ? Icons.person_rounded : Icons.badge_rounded,
                        color: const Color(0xFF047857),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12 * config.fontScale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment. start,
                        children: [
                          Text(
                            _isUserLogin ?  'Citizen Login' : 'Worker Login',
                            style: GoogleFonts.poppins(
                              fontSize: 18 * config.fontScale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1a1a2e),
                            ),
                          ),
                          Text(
                            'Enter your credentials',
                            style: GoogleFonts. poppins(
                              fontSize: 11 * config.fontScale,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: config.padding * 1.1),

                // Email field
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: 'Email Address',
                  hint: 'Enter your email',
                  icon: Icons.email_rounded,
                  error: _emailError,
                  isFocused: _emailHasFocus,
                  config: config,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),

                SizedBox(height: config.padding * 0.8),

                // Password field
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_rounded,
                  error: _passwordError,
                  isFocused: _passwordHasFocus,
                  config: config,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _login(),
                ),

                SizedBox(height: config.padding * 0.6),

                // Remember me & Forgot password
                _buildFormOptions(config),

                SizedBox(height: config.padding * 1.1),

                // Login button
                _buildLoginButton(config),

                SizedBox(height: config.padding * 0.8),

                // Divider
                _buildDivider(config),

                SizedBox(height: config.padding * 0.8),

                // Google Sign-In
                _buildGoogleSignInButton(config),

                if (_isUserLogin) ...[
                  SizedBox(height: config.padding * 0.8),
                  _buildRegisterLink(config),
                ],
              ],
            ),
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
    required String?  error,
    required bool isFocused,
    required ResponsiveConfig config,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool isPassword = false,
    Function(String)? onSubmitted,
  }) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12 * config.fontScale,
            fontWeight: FontWeight. w600,
            color: hasError
                ? const Color(0xFFDC2626)
                : isFocused
                ? const Color(0xFF047857)
                : const Color(0xFF4a4a4a),
          ),
        ),
        SizedBox(height: 6 * config.fontScale),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius. circular(16),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ?  const Color(0xFFDC2626). withOpacity(0.1)
                    : isFocused
                    ? const Color(0xFF10b981).withOpacity(0.12)
                    : Colors.black.withOpacity(0.03),
                blurRadius: isFocused ? 15 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: isPassword && _obscureText,
            onSubmitted: onSubmitted,
            style: GoogleFonts.poppins(
              fontSize: 14 * config.fontScale,
              color: const Color(0xFF1a1a2e),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 13 * config.fontScale,
                color: Colors.grey[400],
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasError
                        ?  [
                      const Color(0xFFDC2626).withOpacity(0.15),
                      const Color(0xFFDC2626).withOpacity(0.08),
                    ]
                        : isFocused
                        ? [
                      const Color(0xFF10b981). withOpacity(0.18),
                      const Color(0xFF059669).withOpacity(0.1),
                    ]
                        : [
                      const Color(0xFF10b981).withOpacity(0.1),
                      const Color(0xFF059669).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: hasError
                      ? const Color(0xFFDC2626)
                      : isFocused
                      ?  const Color(0xFF047857)
                      : const Color(0xFF059669),
                  size: 18 * config.fontScale,
                ),
              ),
              suffixIcon: isPassword
                  ?  GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _obscureText = !_obscureText);
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _obscureText
                        ? Icons. visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey[600],
                    size: 18 * config.fontScale,
                  ),
                ),
              )
                  : null,
              filled: true,
              fillColor: hasError
                  ?  const Color(0xFFFEF2F2)
                  : isFocused
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius. circular(16),
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
                borderRadius: BorderRadius. circular(16),
                borderSide: BorderSide(
                  color: hasError
                      ?  const Color(0xFFDC2626)
                      : const Color(0xFF10b981),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16 * config.fontScale,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4 * config.fontScale),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 14 * config.fontScale,
                color: const Color(0xFFDC2626),
              ),
              SizedBox(width: 4 * config.fontScale),
              Expanded(
                child: Text(
                  error! ,
                  style: GoogleFonts.poppins(
                    fontSize: 11 * config.fontScale,
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

  Widget _buildFormOptions(ResponsiveConfig config) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _rememberMe = !_rememberMe);
          },
          child: Row(
            mainAxisSize: MainAxisSize. min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  gradient: _rememberMe
                      ? const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10b981)],
                  )
                      : null,
                  color: _rememberMe ?  null : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: _rememberMe ?  Colors.transparent : Colors.grey[400]! ,
                    width: 2,
                  ),
                  boxShadow: _rememberMe
                      ? [
                    BoxShadow(
                      color: const Color(0xFF10b981).withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: _rememberMe
                    ? const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                )
                    : null,
              ),
              SizedBox(width: 8 * config.fontScale),
              Text(
                'Remember me',
                style: GoogleFonts.poppins(
                  fontSize: 12 * config.fontScale,
                  color: Colors.grey[700],
                  fontWeight: FontWeight. w500,
                ),
              ),
            ],
          ),
        ),

        // Forgot password
        TextButton(
          onPressed: _navigateToForgotPassword,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size. zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: GoogleFonts.poppins(
              fontSize: 12 * config. fontScale,
              color: const Color(0xFF059669),
              fontWeight: FontWeight. w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(ResponsiveConfig config) {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController.reverse(),
      onTapCancel: () => _buttonController. reverse(),
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          final scale = 1.0 - (_buttonController.value * 0.03);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: double.infinity,
              height: config.buttonHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF047857),
                    Color(0xFF059669),
                    Color(0xFF10b981),
                  ],
                  begin: Alignment. centerLeft,
                  end: Alignment. centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10b981).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _login,
                  borderRadius: BorderRadius. circular(18),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
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
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontSize: 16 * config.fontScale,
                            fontWeight: FontWeight. w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 10 * config.fontScale),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white. withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18 * config.fontScale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDivider(ResponsiveConfig config) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16 * config.fontScale),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors. grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'OR',
              style: GoogleFonts. poppins(
                color: Colors.grey[500],
                fontWeight: FontWeight. w600,
                fontSize: 11 * config.fontScale,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors. grey[300]!,
                  Colors. transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(ResponsiveConfig config) {
    return Container(
      width: double.infinity,
      height: config. buttonHeight - 4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors. black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _googleSignIn,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google. svg',
                height: 20 * config.fontScale,
                width: 20 * config.fontScale,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.g_mobiledata_rounded,
                  size: 26 * config.fontScale,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 12 * config. fontScale),
              Text(
                'Continue with Google',
                style: GoogleFonts.poppins(
                  fontSize: 14 * config.fontScale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4a4a4a),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ResponsiveConfig config) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.poppins(
            fontSize: 13 * config.fontScale,
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: _navigateToRegister,
          child: Text(
            'Sign Up',
            style: GoogleFonts.poppins(
              fontSize: 13 * config. fontScale,
              color: const Color(0xFF059669),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoCredentials(ResponsiveConfig config) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.all(config.padding * 0.9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors. white.withOpacity(0.15),
                Colors. white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius. circular(20),
            border: Border. all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius. circular(10),
                    ),
                    child: Icon(
                      Icons. science_rounded,
                      color: Colors.white,
                      size: 16 * config.fontScale,
                    ),
                  ),
                  SizedBox(width: 10 * config.fontScale),
                  Text(
                    'Demo Credentials',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14 * config.fontScale,
                    ),
                  ),
                ],
              ),
              SizedBox(height: config.padding * 0.7),
              Row(
                children: [
                  Expanded(
                    child: _buildCredentialCard(
                      type: 'Citizen',
                      email: AppCredentials. demoUserEmail,
                      icon: Icons.person_rounded,
                      isActive: _isUserLogin,
                      config: config,
                    ),
                  ),
                  SizedBox(width: config.padding * 0.4),
                  Expanded(
                    child: _buildCredentialCard(
                      type: 'Worker',
                      email: AppCredentials.demoEmployeeEmail,
                      icon: Icons. cleaning_services_rounded,
                      isActive: ! _isUserLogin,
                      config: config,
                    ),
                  ),
                ],
              ),
              SizedBox(height: config.padding * 0.7),
              _buildQuickFillButton(config),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialCard({
    required String type,
    required String email,
    required IconData icon,
    required bool isActive,
    required ResponsiveConfig config,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets. all(10 * config.fontScale),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
          colors: [
            Colors.white.withOpacity(0.22),
            Colors.white.withOpacity(0.12),
          ],
        )
            : null,
        color: isActive ? null : Colors.white. withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? Colors.white.withOpacity(0.45)
              : Colors.white.withOpacity(0.15),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets. all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius. circular(7),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 14 * config.fontScale,
                ),
              ),
              SizedBox(width: 6 * config.fontScale),
              Expanded(
                child: Text(
                  type,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11 * config.fontScale,
                  ),
                  overflow: TextOverflow. ellipsis,
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius. circular(5),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 10 * config.fontScale,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6 * config.fontScale),
          Text(
            email,
            style: GoogleFonts.poppins(
              color: Colors.white. withOpacity(0.85),
              fontSize: 9 * config.fontScale,
              fontWeight: FontWeight. w500,
            ),
            overflow: TextOverflow. ellipsis,
          ),
          SizedBox(height: 2 * config.fontScale),
          Text(
            '••••••••',
            style: GoogleFonts. poppins(
              color: Colors. white.withOpacity(0.6),
              fontSize: 10 * config.fontScale,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }  Widget _buildQuickFillButton(ResponsiveConfig config) {
    return Container(
      width: double.infinity,
      height: 46 * config.fontScale,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF0FDF4)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _fillDemoCredentials,
          borderRadius: BorderRadius. circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10b981). withOpacity(0.15),
                  borderRadius: BorderRadius. circular(7),
                ),
                child: Icon(
                  Icons.flash_on_rounded,
                  size: 16 * config.fontScale,
                  color: const Color(0xFF059669),
                ),
              ),
              SizedBox(width: 8 * config.fontScale),
              Text(
                'Quick Fill ${_isUserLogin ? "Citizen" : "Worker"}',
                style: GoogleFonts. poppins(
                  fontWeight: FontWeight. w700,
                  fontSize: 12 * config.fontScale,
                  color: const Color(0xFF047857),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ResponsiveConfig config) {
    return Column(
      children: [
        Text(
          'By signing in, you agree to our',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11 * config.fontScale,
          ),
        ),
        SizedBox(height: 4 * config.fontScale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Navigate to Terms of Service
              },
              child: Text(
                'Terms of Service',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11 * config.fontScale,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration. underline,
                  decorationColor: Colors.white. withOpacity(0.5),
                ),
              ),
            ),
            Text(
              '  •  ',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11 * config.fontScale,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Navigate to Privacy Policy
              },
              child: Text(
                'Privacy Policy',
                style: GoogleFonts.poppins(
                  color: Colors. white,
                  fontSize: 11 * config.fontScale,
                  fontWeight: FontWeight. w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== SUPPORTING CLASSES ====================

/// Screen size categories for responsive design
enum ScreenSize { small, mobile, tablet, desktop }

/// Configuration class for responsive values
class ResponsiveConfig {
  final double screenWidth;
  final double screenHeight;
  final double containerWidth;
  final double padding;
  final double logoSize;
  final double fontScale;
  final double buttonHeight;
  final double inputHeight;
  final bool showFloatingIcons;
  final bool compactMode;
  final bool isLandscape;
  final ScreenSize screenSize;

  const ResponsiveConfig({
    required this.screenWidth,
    required this.screenHeight,
    required this.containerWidth,
    required this.padding,
    required this.logoSize,
    required this.fontScale,
    required this. buttonHeight,
    required this.inputHeight,
    required this.showFloatingIcons,
    required this.compactMode,
    required this.isLandscape,
    required this.screenSize,
  });
}

/// Particle class for background animation
class Particle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double speed = 0.015 + math.Random().nextDouble() * 0.06;
  double size = 1.5 + math. Random().nextDouble() * 2.5;
  double opacity = 0.08 + math.Random().nextDouble() * 0.18;
  double twinkleSpeed = 0.5 + math.Random().nextDouble() * 1.2;

  void update() {
    y += speed * 0.005;
    if (y > 1.1) {
      y = -0.1;
      x = math.Random().nextDouble();
      opacity = 0.08 + math.Random().nextDouble() * 0.18;
    }
  }
}

/// Custom painter for particle animation
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final double screenWidth;
  final double screenHeight;

  ParticlePainter(
      this.particles,
      this.animationValue,
      this.screenWidth,
      this.screenHeight,
      );

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      double twinkle = math.sin(animationValue * math.pi * 2 * particle.twinkleSpeed);
      double currentOpacity = particle.opacity * (0.6 + twinkle * 0.4);

      final paint = Paint()
        ..color = Colors.white. withOpacity(currentOpacity. clamp(0.03, 0.35))
        ..style = PaintingStyle.fill
        .. maskFilter = MaskFilter.blur(BlurStyle. normal, particle.size * 0.4);

      canvas. drawCircle(
        Offset(particle.x * screenWidth, particle.y * screenHeight),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}