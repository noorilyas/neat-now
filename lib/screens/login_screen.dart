import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'dart:ui';

// Import your screens/widgets
import 'package:neat_now/screens/user_dashboard.dart';
import 'package:neat_now/screens/employee_dashboard.dart';

/// ==================== LOGIN SCREEN ====================
/// Single login - differentiates Worker/Citizen based on email domain
/// Citizen emails: any regular email (e.g., user@gmail.com)
/// Worker emails: @neatnow. work or specific worker emails
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  // ==================== CONTROLLERS ====================
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // ==================== ANIMATION CONTROLLERS ====================
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _buttonController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // ==================== STATE VARIABLES ====================
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _emailHasFocus = false;
  bool _passwordHasFocus = false;
  String? _emailError;
  String? _passwordError;

  // Particles for background animation
  final List<_Particle> _particles = [];

  // ==================== DEMO CREDENTIALS ====================
  // Worker emails end with @neatnow.work or are in the worker list
  static const List<String> _workerEmails = [
    'worker@neatnow. work',
    'admin@neatnow.work',
    'employee@neatnow.work',
  ];

  // Demo accounts for testing
  static const Map<String, Map<String, dynamic>> _demoAccounts = {
    // Citizen accounts
    'user@gmail.com': {
      'password': 'user123',
      'type': 'citizen',
      'data': {
        'id': '1',
        'name': 'Ahmad Ali',
        'email': 'user@gmail.com',
        'phone': '+92 300 1234567',
        'profileImage': null,
        'totalReports': 25,
        'verifiedReports': 18,
        'rank': 5,
        'badge': 'Eco Warrior',
      },
    },
    'citizen@example.com': {
      'password': 'citizen123',
      'type': 'citizen',
      'data': {
        'id': '2',
        'name': 'Sara Khan',
        'email': 'citizen@example.com',
        'phone': '+92 301 9876543',
        'profileImage': null,
        'totalReports': 42,
        'verifiedReports': 35,
        'rank': 2,
        'badge': 'Top Contributor',
      },
    },
    // Worker accounts
    'worker@neatnow.work': {
      'password': 'worker123',
      'type': 'worker',
      'data': {
        'id': '1',
        'name': 'Ali Hassan',
        'email': 'worker@neatnow. work',
        'phone': '+92 302 5555555',
        'employeeId': 'EMP001',
        'profileImage': null,
        'completedTasks': 45,
        'pendingTasks': 3,
        'rating': 4.8,
        'badges': ['Fast Responder', 'Top Performer'],
      },
    },
    'admin@neatnow.work': {
      'password': 'admin123',
      'type': 'worker',
      'data': {
        'id': '2',
        'name': 'Bilal Ahmed',
        'email': 'admin@neatnow. work',
        'phone': '+92 303 1111111',
        'employeeId': 'EMP002',
        'profileImage': null,
        'completedTasks': 120,
        'pendingTasks': 5,
        'rating': 4.9,
        'badges': ['Team Lead', 'Excellence Award'],
      },
    },
  };

  // ==================== LIFECYCLE ====================

  @override
  void initState() {
    super.initState();
    _initializeSystem();
    _initializeParticles();
    _initializeAnimations();
    _setupFocusListeners();
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
      _particles.add(_Particle());
    }
  }

  void _initializeAnimations() {
    // Fade Animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
    );

    // Slide Animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Scale Animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves. elasticOut,
    );

    // Particle Animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    ).. repeat();

    // Pulse Animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));

    // Button Animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() {
      setState(() => _emailHasFocus = _emailFocusNode.hasFocus);
      if (!_emailFocusNode.hasFocus) {
        _validateEmail(_emailController.text);
      }
    });

    _passwordFocusNode.addListener(() {
      setState(() => _passwordHasFocus = _passwordFocusNode.hasFocus);
      if (!_passwordFocusNode.hasFocus) {
        _validatePassword(_passwordController. text);
      }
    });
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
    _emailFocusNode. dispose();
    _passwordFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _particleController. dispose();
    _pulseController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  // ==================== HELPER METHODS ====================

  /// Check if email belongs to a worker
  bool _isWorkerEmail(String email) {
    final lowerEmail = email. toLowerCase(). trim();

    // Check if email ends with worker domain
    if (lowerEmail.endsWith('@neatnow.work')) {
      return true;
    }

    // Check if email is in the worker list
    if (_workerEmails.contains(lowerEmail)) {
      return true;
    }

    // Check in demo accounts
    final account = _demoAccounts[lowerEmail];
    if (account != null && account['type'] == 'worker') {
      return true;
    }

    return false;
  }

  /// Get user type label for display
  String _getUserTypeLabel(String email) {
    return _isWorkerEmail(email) ? 'Worker' : 'Citizen';
  }

  // ==================== VALIDATION ====================

  bool _validateEmail(String email) {
    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return false;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9. _%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
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
    final isEmailValid = _validateEmail(_emailController.text. trim());
    final isPasswordValid = _validatePassword(_passwordController.text);
    return isEmailValid && isPasswordValid;
  }

  // ==================== AUTHENTICATION ====================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_validateForm()) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));

      if (! mounted) return;

      final email = _emailController. text.trim(). toLowerCase();
      final password = _passwordController.text;

      // Check credentials in demo accounts
      final account = _demoAccounts[email];

      bool isValidCredentials = false;
      Map<String, dynamic> userData = {};
      bool isWorker = false;

      if (account != null && account['password'] == password) {
        isValidCredentials = true;
        userData = Map<String, dynamic>. from(account['data']);
        isWorker = account['type'] == 'worker';
      }

      setState(() => _isLoading = false);

      if (isValidCredentials) {
        final userTypeLabel = isWorker ? 'Worker' : 'Citizen';

        _showSnackBar(
          title: 'Welcome back! ',
          message: 'Logged in as $userTypeLabel',
          isError: false,
          icon: isWorker ? Icons. badge_rounded : Icons.person_rounded,
        );

        await Future.delayed(const Duration(milliseconds: 600));

        if (! mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              if (isWorker) {
                return EmployeeDashboard(
                );
              } else {
                return UserDashboard(
                  userData: userData,
                  onLogout: () => _handleLogout(context),
                );
              }
            },
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        _showSnackBar(
          title: 'Login Failed',
          message: 'Invalid email or password',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      _showSnackBar(
        title: 'Connection Error',
        message: 'Please check your internet connection',
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

  void _fillDemoCredentials({required bool asWorker}) {
    HapticFeedback.lightImpact();

    if (asWorker) {
      _emailController.text = 'worker@neatnow.work';
      _passwordController.text = 'worker123';
    } else {
      _emailController.text = 'user@gmail.com';
      _passwordController.text = 'user123';
    }

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    _showSnackBar(
      title: 'Demo Credentials',
      message: 'Filled ${asWorker ? "Worker" : "Citizen"} credentials',
      isError: false,
      icon: asWorker ? Icons. badge_rounded : Icons.person_rounded,
    );
  }

  void _showSnackBar({
    required String title,
    required String message,
    required bool isError,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context). hideCurrentSnackBar();
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon ??  (isError ? Icons. error_outline_rounded : Icons.check_circle_rounded),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
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
                    overflow: TextOverflow.ellipsis,
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
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
            // Animated Particles Background
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    _particles,
                    _particleController.value,
                    size.width,
                    size.height,
                  ),
                  size: Size. infinite,
                );
              },
            ),

            // Decorative Gradient Orbs
            _buildDecorativeOrbs(size),

            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(size. width),
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _getMaxWidth(size.width),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: _buildLogo(),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Welcome Text
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildWelcomeText(),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Login Form
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildLoginForm(),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Demo Credentials
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildDemoCredentials(),
                        ),

                        const SizedBox(height: 20),

                        // Footer
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildFooter(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getHorizontalPadding(double width) {
    if (width < 400) return 16;
    if (width < 600) return 24;
    return 32;
  }

  double _getMaxWidth(double width) {
    if (width < 500) return width * 0.92;
    if (width < 800) return 420;
    return 450;
  }

  // ==================== DECORATIVE ELEMENTS ====================

  Widget _buildDecorativeOrbs(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.1,
          right: -size.width * 0.15,
          child: Container(
            width: size.width * 0.5,
            height: size.width * 0.5,
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
          bottom: -size.height * 0.05,
          left: -size.width * 0.1,
          child: Container(
            width: size.width * 0.4,
            height: size.width * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
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

  // ==================== LOGO ====================

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10b981).withOpacity(0.5),
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
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
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
                ).createShader(bounds),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                child: Text(
                  'NeatNow',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight. w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== WELCOME TEXT ====================

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome Back!  👋',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 3),
                blurRadius: 10,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Sign in to continue',
          style: GoogleFonts. poppins(
            fontSize: 16,
            color: Colors.white. withOpacity(0.85),
            fontWeight: FontWeight. w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets. symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors. white.withOpacity(0.15),
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
                padding: const EdgeInsets. all(6),
                decoration: BoxDecoration(
                  color: Colors.white. withOpacity(0.15),
                  borderRadius: BorderRadius. circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI-Powered Waste Detection',
                style: GoogleFonts. poppins(
                  fontSize: 13,
                  color: Colors.white. withOpacity(0.95),
                  fontWeight: FontWeight. w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== LOGIN FORM ====================

  Widget _buildLoginForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
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
                _buildFormHeader(),

                const SizedBox(height: 28),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  label: 'Email Address',
                  hint: 'Enter your email',
                  icon: Icons.email_rounded,
                  error: _emailError,
                  isFocused: _emailHasFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),

                const SizedBox(height: 20),

                // Password Field
                _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  label: 'Password',
                  hint: 'Enter your password',
                  icon: Icons.lock_rounded,
                  error: _passwordError,
                  isFocused: _passwordHasFocus,
                  isPassword: true,
                  textInputAction: TextInputAction. done,
                  onSubmitted: (_) => _login(),
                ),

                const SizedBox(height: 18),

                // Remember Me & Forgot Password
                _buildFormOptions(),

                const SizedBox(height: 28),

                // Login Button
                _buildLoginButton(),

                const SizedBox(height: 24),

                // Divider
                _buildDivider(),

                const SizedBox(height: 24),

                // Google Sign-In
                _buildGoogleSignInButton(),

                const SizedBox(height: 24),

                // Register Link
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets. all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10b981).withOpacity(0.15),
                const Color(0xFF059669).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons. login_rounded,
            color: Color(0xFF047857),
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sign In',
                style: GoogleFonts. poppins(
                  fontSize: 22,
                  fontWeight: FontWeight. w700,
                  color: const Color(0xFF1a1a2e),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Access your account',
                style: GoogleFonts. poppins(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight. w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: hasError
                ? const Color(0xFFDC2626)
                : isFocused
                ? const Color(0xFF047857)
                : const Color(0xFF4a4a4a),
          ),
        ),
        const SizedBox(height: 10),
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
            obscureText: isPassword && _obscurePassword,
            onSubmitted: onSubmitted,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF1a1a2e),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasError
                        ?  [
                      const Color(0xFFDC2626). withOpacity(0.15),
                      const Color(0xFFDC2626).withOpacity(0.08),
                    ]
                        : isFocused
                        ? [
                      const Color(0xFF10b981).withOpacity(0.18),
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
                      ? const Color(0xFF047857)
                      : const Color(0xFF059669),
                  size: 20,
                ),
              ),
              suffixIcon: isPassword
                  ? GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey. withOpacity(0.1),
                    borderRadius: BorderRadius. circular(10),
                  ),
                  child: Icon(
                    _obscurePassword
                        ? Icons. visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              )
                  : null,
              filled: true,
              fillColor: hasError
                  ?  const Color(0xFFFEF2F2)
                  : isFocused
                  ?  const Color(0xFFF0FDF4)
                  : const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius. circular(16),
                borderSide: BorderSide. none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError
                      ? const Color(0xFFDC2626). withOpacity(0.5)
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  error,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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

  Widget _buildFormOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _rememberMe = !_rememberMe);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: _rememberMe
                      ? const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF10b981)],
                  )
                      : null,
                  color: _rememberMe ?  null : Colors.transparent,
                  borderRadius: BorderRadius. circular(7),
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
                  Icons. check_rounded,
                  color: Colors.white,
                  size: 16,
                )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                'Remember me',
                style: GoogleFonts. poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight. w500,
                ),
              ),
            ],
          ),
        ),

        // Forgot Password
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _showSnackBar(
              title: 'Reset Password',
              message: 'Password reset feature coming soon!',
              isError: false,
              icon: Icons.lock_reset_rounded,
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size. zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password? ',
            style: GoogleFonts. poppins(
              fontSize: 14,
              color: const Color(0xFF059669),
              fontWeight: FontWeight. w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTapDown: (_) => _buttonController.forward(),
      onTapUp: (_) => _buttonController. reverse(),
      onTapCancel: () => _buttonController. reverse(),
      child: AnimatedBuilder(
        animation: _buttonController,
        builder: (context, child) {
          final scale = 1.0 - (_buttonController.value * 0.03);
          return Transform.scale(
          scale: scale,
          child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
          gradient: const LinearGradient(
          colors: [
          Color(0xFF047857),
          Color(0xFF059669),
          Color(0xFF10b981),
          ],
          begin: Alignment.centerLeft,
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
          onTap: _isLoading ?  null : _login,
          borderRadius: BorderRadius. circular(18),
          child: Center(
          child: _isLoading
          ? const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          )
              : Row(
          mainAxisAlignment: MainAxisAlignment. center,
          children: [
          Text(
          'Sign In',
          style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
          ),
          ),
          const SizedBox(width: 12),
          Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
          color: Colors.white. withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white,
          size: 20,
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

  Widget _buildDivider() {
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
          padding: const EdgeInsets. symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'OR',
              style: GoogleFonts. poppins(
                color: Colors.grey[500],
                fontWeight: FontWeight. w600,
                fontSize: 12,
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
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback. lightImpact();
            _showSnackBar(
              title: 'Coming Soon',
              message: 'Google Sign-In will be available in the next update! ',
              isError: false,
              icon: Icons.update_rounded,
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight. w700,
                      color: const Color(0xFF4285F4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight. w600,
                  color: const Color(0xFF4a4a4a),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showSnackBar(
              title: 'Register',
              message: 'Registration feature coming soon!',
              isError: false,
              icon: Icons.person_add_rounded,
            );
          },
          child: Text(
            'Sign Up',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF059669),
              fontWeight: FontWeight. w700,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== DEMO CREDENTIALS ====================

  Widget _buildDemoCredentials() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors. white.withOpacity(0.18),
                Colors. white.withOpacity(0.08),
              ],
              begin: Alignment. topLeft,
              end: Alignment. bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius. circular(10),
                    ),
                    child: const Icon(
                      Icons.science_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Demo Accounts',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Tap to auto-fill credentials',
                style: GoogleFonts. poppins(
                  color: Colors.white. withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Demo Account Cards
              Row(
                children: [
                  Expanded(
                    child: _buildDemoAccountCard(
                      title: 'Citizen',
                      subtitle: 'Report waste',
                      email: 'user@gmail.com',
                      icon: Icons.person_rounded,
                      color: const Color(0xFF3B82F6),
                      onTap: () => _fillDemoCredentials(asWorker: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDemoAccountCard(
                      title: 'Worker',
                      subtitle: 'Clean waste',
                      email: 'worker@neatnow.work',
                      icon: Icons.cleaning_services_rounded,
                      color: const Color(0xFFF59E0B),
                      onTap: () => _fillDemoCredentials(asWorker: true),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Info Banner
              Container(
                padding: const EdgeInsets. symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius. circular(12),
                  border: Border.all(
                    color: Colors.white. withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors. white. withOpacity(0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Workers use @neatnow. work email domain',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccountCard({
    required String title,
    required String subtitle,
    required String email,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets. all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.25),
              color. withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius. circular(16),
          border: Border.all(
            color: color. withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color. withOpacity(0.3),
                    borderRadius: BorderRadius. circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts. poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white. withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      color: Colors.white. withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight. w500,
                    ),
                    overflow: TextOverflow. ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '••••••••',
                    style: GoogleFonts. poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double. infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flash_on_rounded,
                    color: color,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Quick Fill',
                    style: GoogleFonts.poppins(
                      color: color,
                      fontWeight: FontWeight. w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FOOTER ====================

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By signing in, you agree to our',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Text(
                'Terms of Service',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration. underline,
                  decorationColor: Colors. white. withOpacity(0.5),
                ),
              ),
            ),
            Text(
              '  •  ',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Text(
                'Privacy Policy',
                style: GoogleFonts. poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight. w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '© 2024 NeatNow. All rights reserved.',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ==================== PARTICLE CLASSES ====================

class _Particle {
  double x = math.Random(). nextDouble();
  double y = math.Random().nextDouble();
  double speed = 0.015 + math.Random().nextDouble() * 0.06;
  double size = 1.5 + math.Random().nextDouble() * 2.5;
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

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;
  final double screenWidth;
  final double screenHeight;

  _ParticlePainter(
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