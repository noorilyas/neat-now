import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/screens/login_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _waveController;
  late AnimationController _featureController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _iconRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _featureFadeAnimation;

  final List<Particle> particles = [];
  int currentFeatureIndex = 0;
  bool showMainContent = false;

  // Project features to showcase
  final List<FeatureData> features = [
    FeatureData(
      icon: Icons.camera_alt_rounded,
      title: 'Capture Waste',
      color: Color(0xFF2196F3),
    ),
    FeatureData(
      icon: Icons.image_rounded,
      title: 'Upload Image',
      color: Color(0xFF9C27B0),
    ),
    FeatureData(
      icon: Icons.psychology_rounded,
      title: 'AI Detection',
      color: Color(0xFFFF9800),
    ),
    FeatureData(
      icon: Icons.notifications_active_rounded,
      title: 'Send Alert',
      color: Color(0xFFF44336),
    ),
    FeatureData(
      icon: Icons.map_rounded,
      title: 'Track Location',
      color: Color(0xFF4CAF50),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize particles
    for (int i = 0; i < 40; i++) {
      particles.add(Particle());
    }

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Icon rotation
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _iconRotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOutCubic),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Feature showcase animation
    _featureController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _featureFadeAnimation = CurvedAnimation(
      parent: _featureController,
      curve: Curves.easeInOut,
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _startAnimationSequence();

    // Navigate to login
    Future.delayed(const Duration(milliseconds: 6500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  void _startAnimationSequence() async {
    // Show feature sequence
    await Future.delayed(const Duration(milliseconds: 300));
    _cycleFeatures();
  }

  void _cycleFeatures() async {
    for (int i = 0; i < features.length; i++) {
      if (!mounted) return;

      setState(() {
        currentFeatureIndex = i;
      });

      _featureController.reset();
      await _featureController.forward();

      await Future.delayed(const Duration(milliseconds: 500));

      if (i == features.length - 1) {
        // Last feature - transition to main logo
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          showMainContent = true;
        });
        _mainController.forward();
        _iconController.repeat();

        await Future.delayed(const Duration(milliseconds: 800));
        _textController.forward();
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _iconController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _waveController.dispose();
    _featureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A3D2C),
              const Color(0xFF1B5E20),
              const Color(0xFF2E7D32),
              const Color(0xFF388E3C),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated wave background
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: WavePainter(_waveController.value),
                  size: Size.infinite,
                );
              },
            ),

            // Particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(particles, _particleController.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo or Feature Display
                    SizedBox(
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Feature showcase
                          if (!showMainContent) _buildFeatureDisplay(),

                          // Main logo
                          if (showMainContent) _buildMainLogo(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // App name and tagline
                    if (showMainContent) _buildAppTitle(),

                    const Spacer(flex: 1),

                    // Feature descriptions
                    if (showMainContent) _buildFeatureList(),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),

            // Floating tech elements
            if (showMainContent) ..._buildFloatingElements(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureDisplay() {
    final feature = features[currentFeatureIndex];

    return AnimatedBuilder(
      animation: _featureFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _featureFadeAnimation.value,
          child: Transform.scale(
            scale: 0.5 + (_featureFadeAnimation.value * 0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: feature.color.withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    feature.icon,
                    size: 60,
                    color: feature.color,
                  ),
                ),
                const SizedBox(height: 24),
                // Feature title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    feature.title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
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

  Widget _buildMainLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScaleAnimation, _logoFadeAnimation, _iconRotateAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoFadeAnimation.value,
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.9),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating outer ring
                  Transform.rotate(
                    angle: _iconRotateAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2E7D32).withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                  // Camera + AI icon
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_rounded,
                        size: 45,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: SlideTransition(
        position: _textSlideAnimation,
        child: Column(
          children: [
            // App name
            ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Colors.white,
                    Color(0xFFE8F5E9),
                  ],
                ).createShader(bounds);
              },
              child: Column(
                children: [
                  Text(
                    'NeatNow',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Animated divider
            Container(
              height: 3,
              width: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white,
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 12),

            // Subtitle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'AI-POWERED WASTE MANAGEMENT',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            _buildFeatureItem(Icons.camera_alt_rounded, 'Capture or Upload Images'),
            const SizedBox(height: 8),
            _buildFeatureItem(Icons.psychology_rounded, 'AI Waste Detection'),
            const SizedBox(height: 8),
            _buildFeatureItem(Icons.notifications_active_rounded, 'Real-time Alerts'),
            const SizedBox(height: 8),
            _buildFeatureItem(Icons.map_rounded, 'Location Tracking & Reports'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingElements() {
    return List.generate(6, (index) {
      final icons = [
        Icons.camera_alt_outlined,
        Icons.image_outlined,
        Icons.psychology_outlined,
        Icons.notifications_outlined,
        Icons.location_on_outlined,
        Icons.recycling_outlined,
      ];

      return AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          double offset = (_particleController.value + (index * 0.15)) % 1.0;
          double horizontalOffset = math.sin(_particleController.value * 2 * math.pi + index) * 30;

          return Positioned(
            left: 40 + (index * 60.0) + horizontalOffset,
            top: MediaQuery.of(context).size.height * offset,
            child: Opacity(
              opacity: 0.15 + (math.sin(_particleController.value * 2 * math.pi + index) * 0.1),
              child: Transform.rotate(
                angle: _particleController.value * 2 * math.pi,
                child: Icon(
                  icons[index],
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

// Feature data class
class FeatureData {
  final IconData icon;
  final String title;
  final Color color;

  FeatureData({
    required this.icon,
    required this.title,
    required this.color,
  });
}

// Particle class
class Particle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double speed = 0.1 + math.Random().nextDouble() * 0.3;
  double size = 1.5 + math.Random().nextDouble() * 2.5;

  void update() {
    y += speed * 0.01;
    if (y > 1.1) {
      y = -0.1;
      x = math.Random().nextDouble();
    }
  }
}

// Particle painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      particle.update();
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Wave painter for background
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveHeight = 40.0;
      final waveLength = size.width / 2;
      final offsetY = size.height * 0.3 + (i * 100);

      path.moveTo(0, offsetY);

      for (double x = 0; x <= size.width; x++) {
        final y = offsetY +
            math.sin((x / waveLength * 2 * math.pi) + (animationValue * 2 * math.pi) + (i * 0.5)) *
                waveHeight;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}