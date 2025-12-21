import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class SuccessAnimationDialog extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onComplete;

  const SuccessAnimationDialog({
    super.key,
    required this.responsive,
    required this.onComplete,
  });

  @override
  State<SuccessAnimationDialog> createState() => _SuccessAnimationDialogState();
}

class _SuccessAnimationDialogState extends State<SuccessAnimationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _confettiController;
  late AnimationController _textController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _textAnimation;

  final List<ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateParticles();

    // ✅ SAFE ANIMATION START
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startSequence();
      }
    });
  }

  void _initAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent:  _scaleController,
      curve: Curves.elasticOut,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutBack,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    );
  }

  void _generateParticles() {
    final random = math.Random();
    final colors = [
      ReportsDesign.primaryTeal,
      ReportsDesign.primaryTealLight,
      Colors.white,
      ReportsDesign.success,
      ReportsDesign. info,
      ReportsDesign. warning,
    ];

    for (int i = 0; i < 50; i++) {
      _particles.add(
        ConfettiParticle(
          angle: random.nextDouble() * 2 * math.pi,
          velocity: 80 + random.nextDouble() * 250,
          rotationSpeed: random.nextDouble() * 12 - 6,
          size: 4 + random.nextDouble() * 10,
          color: colors[random.nextInt(colors.length)],
          shape: random.nextInt(3),
          delay: random.nextDouble() * 0.3,
        ),
      );
    }
  }

  Future<void> _startSequence() async {
    if (! mounted) return;

    await Future.delayed(const Duration(milliseconds: 100));
    if (! mounted) return;
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _checkController.forward();
    _confettiController.forward();
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController. stop();
    _checkController. stop();
    _confettiController.stop();
    _textController.stop();

    _scaleController.dispose();
    _checkController.dispose();
    _confettiController.dispose();
    _textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                  centerX: size.width / 2,
                  centerY: size.height / 2 - 50,
                ),
              );
            },
          ),

          // Main content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale:  _scaleAnimation,
                child: Container(
                  width: r.dimension(140),
                  height: r. dimension(140),
                  decoration: BoxDecoration(
                    gradient: ReportsDesign.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ReportsDesign.primaryTeal.withOpacity(0.5),
                        blurRadius:  50,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: ScaleTransition(
                    scale: _checkAnimation,
                    child: Icon(
                      Icons.check_rounded,
                      size: r.dimension(70),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: r.largePadding),
              FadeTransition(
                opacity: _textAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end:  Offset. zero,
                  ).animate(_textAnimation),
                  child:  Column(
                    children: [
                      Text(
                        'Report Submitted',
                        style: GoogleFonts.inter(
                          fontSize: r.headingM,
                          fontWeight: FontWeight.w800,
                          color: ReportsDesign.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: r.nanoPadding),
                      ShaderMask(
                        shaderCallback: (bounds) => ReportsDesign.primaryGradient
                            .createShader(bounds),
                        child: Text(
                          'Thank You!',
                          style: GoogleFonts.inter(
                            fontSize: r.headingS,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: r. padding),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.padding,
                          vertical: r.microPadding,
                        ),
                        decoration: BoxDecoration(
                          color: ReportsDesign.surfaceLight,
                          borderRadius: BorderRadius.circular(r. pillBorderRadius),
                        ),
                        child: Text(
                          'The citizen has been notified',
                          style: GoogleFonts.inter(
                            fontSize: r.bodyS,
                            color: ReportsDesign.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Confetti Painter
class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  final double centerX;
  final double centerY;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final adjustedProgress =
      ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final distance = particle.velocity * adjustedProgress;
      final gravity = 300 * adjustedProgress * adjustedProgress;

      final x = centerX + math.cos(particle.angle) * distance;
      final y = centerY + math.sin(particle. angle) * distance + gravity;

      final opacity = (1 - adjustedProgress * 0.8).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = particle.color. withOpacity(opacity)
        ..style = PaintingStyle. fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotationSpeed * adjustedProgress * math.pi * 2);

      switch (particle.shape) {
        case 0:
          canvas. drawCircle(Offset. zero, particle.size / 2, paint);
          break;
        case 1:
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset. zero,
                width: particle.size,
                height: particle.size * 0.6,
              ),
              Radius.circular(particle.size * 0.1),
            ),
            paint,
          );
          break;
        case 2:
          final path = Path()
            ..moveTo(0, -particle.size / 2)
            ..lineTo(particle.size / 2, particle.size / 2)
            ..lineTo(-particle.size / 2, particle.size / 2)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}