import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:neat_now/models/user/confetti_particle_model.dart';
import 'package:neat_now/design/user/user_design_system.dart';

class ReportSuccessViewModel extends ChangeNotifier {
  final VoidCallback onComplete;
  List<ConfettiParticleModel> _particles = [];
  bool _isCompleted = false;

  ReportSuccessViewModel({required this.onComplete});

  List<ConfettiParticleModel> get particles => _particles;
  bool get isCompleted => _isCompleted;

  // Generate confetti particles
  void generateParticles() {
    final random = math.Random();
    final colors = [
      UserDesign. primaryTeal,
      UserDesign.primaryTealLight,
      UserDesign.success,
      UserDesign.info,
      UserDesign.purple,
      UserDesign.warning,
      Colors.white,
    ];

    final particles = <ConfettiParticleModel>[];
    for (int i = 0; i < 80; i++) {
      particles.add(ConfettiParticleModel(
        angle: random.nextDouble() * 2 * math.pi,
        velocity: 100 + random.nextDouble() * 250,
        size: 4 + random.nextDouble() * 10,
        color: colors[random.nextInt(colors.length)],
        delay: random.nextDouble() * 0.3,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
        shape: random.nextInt(3), // 0: circle, 1: square, 2: star
      ));
    }

    _particles = particles;
    notifyListeners();
  }

  // Complete the success sequence
  void complete() {
    if (! _isCompleted) {
      _isCompleted = true;
      onComplete();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}