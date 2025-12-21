import 'package:flutter/material.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'dart:ui' as ui;

class ReportMarker extends StatelessWidget {
  final Report report;
  final MapTabViewModel viewModel;
  final bool isSelected;
  final Color color;
  final double size;
  final AnimationController pulseAnimation;

  const ReportMarker({
    super.key,
    required this.report,
    required this.viewModel,
    required this.isSelected,
    required this.color,
    required this.size,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isSelected ? 0.5 :  0.3),
                blurRadius: isSelected ? 10 : 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            viewModel.getWasteIcon(report.type),
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        CustomPaint(
          size: Size(8, isSelected ? 8 : 6),
          painter: _PointerPainter(color),
        ),
      ],
    );
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;

  _PointerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(size.width / 2, size. height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}