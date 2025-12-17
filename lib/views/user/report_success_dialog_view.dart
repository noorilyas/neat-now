import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:neat_now/viewmodels/user/report_success_viewmodel.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/models/user/confetti_particle_model.dart';

// ==================== MODERN REPORT SUCCESS DIALOG ====================
class ReportSuccessDialogView extends StatelessWidget {
  final VoidCallback onComplete;

  const ReportSuccessDialogView({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportSuccessViewModel(onComplete: onComplete)
        ..generateParticles(),
      child: const _ReportSuccessDialogContent(),
    );
  }
}

class _ReportSuccessDialogContent extends StatefulWidget {
  const _ReportSuccessDialogContent();

  @override
  State<_ReportSuccessDialogContent> createState() =>
      _ReportSuccessDialogContentState();
}

class _ReportSuccessDialogContentState
    extends State<_ReportSuccessDialogContent> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _checkController;
  late AnimationController _textController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // Scale animation for container
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent:  _scaleController,
      curve: Curves.elasticOut,
    );

    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutBack,
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _textAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds:  3000),
      vsync: this,
    );

    // Pulse animation for glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve:  Curves.easeInOut),
    );
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));

    HapticFeedback.heavyImpact();
    _scaleController.forward();
    _confettiController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      final viewModel = context.read<ReportSuccessViewModel>();
      viewModel.complete();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    _checkController.dispose();
    _textController.dispose();
    _pulseController. dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final viewModel = context.watch<ReportSuccessViewModel>();

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti Layer
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _ModernConfettiPainter(
                  particles: viewModel.particles,
                  progress: _confettiController.value,
                  centerX: size.width / 2,
                  centerY: size.height / 2 - 80,
                ),
              );
            },
          ),

          // Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              ScaleTransition(
                scale:  _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: UserDesign.success.withOpacity(
                              0.3 * _pulseAnimation.value,
                            ),
                            blurRadius: 60 * _pulseAnimation.value,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: UserDesign.successGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: UserDesign.success.withOpacity(0.4),
                          blurRadius:  30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ScaleTransition(
                      scale: _checkAnimation,
                      child: const Icon(
                        Icons.check_rounded,
                        size: 70,
                        color: Colors. white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Text Content
              FadeTransition(
                opacity: _textAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end:  Offset.zero,
                  ).animate(_textAnimation),
                  child:  Column(
                    children: [
                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            UserDesign.textPrimary,
                            UserDesign.primaryTeal,
                          ],
                        ).createShader(bounds),
                        child: Text(
                          'Report Submitted!  🎉',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Thank you for helping keep our environment clean!',
                        style:  GoogleFonts.inter(
                          fontSize: 15,
                          color: UserDesign.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Processing indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: UserDesign.primaryTealSoft,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: UserDesign.primaryTeal. withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize:  MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  UserDesign.primaryTeal,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'AI is verifying your report...',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: UserDesign.primaryTeal,
                              ),
                            ),
                          ],
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

// ==================== CONFETTI PAINTER ====================
class _ModernConfettiPainter extends CustomPainter {
  final List<ConfettiParticleModel> particles;
  final double progress;
  final double centerX;
  final double centerY;

  _ModernConfettiPainter({
    required this.particles,
    required this. progress,
    required this.centerX,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final adjusted = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (adjusted <= 0) continue;

      final distance = p.velocity * adjusted;
      final gravity = 400 * adjusted * adjusted;
      final x = centerX + math.cos(p.angle) * distance;
      final y = centerY + math.sin(p.angle) * distance * 0.6 + gravity;

      // Fade out
      final opacity = (1 - adjusted * 0.7).clamp(0.0, 1.0);

      // Scale down
      final scale = (1 - adjusted * 0.5).clamp(0.3, 1.0);
      final currentSize = p.size * scale;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotationSpeed * adjusted * math.pi);

      final paint = Paint()
        ..color = p.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      // Draw different shapes
      switch (p.shape) {
        case 0:  // Circle
          canvas.drawCircle(Offset. zero, currentSize / 2, paint);
          break;
        case 1: // Square
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset. zero,
                width: currentSize,
                height:  currentSize,
              ),
              Radius.circular(currentSize * 0.2),
            ),
            paint,
          );
          break;
        case 2: // Star shape (simplified as diamond)
          final path = Path();
          path.moveTo(0, -currentSize / 2);
          path.lineTo(currentSize / 2, 0);
          path.lineTo(0, currentSize / 2);
          path.lineTo(-currentSize / 2, 0);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ModernConfettiPainter old) =>
      old.progress != progress;
}