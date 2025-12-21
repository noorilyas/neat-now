import 'package:flutter/material.dart';
import 'package:neat_now/models/employee/analytics_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

/// Performance Chart Painter
class PerformanceChartPainter extends CustomPainter {
  final double progress;
  final List<int> data;
  final ChartType chartType;
  final Color color;
  final Color secondaryColor;
  final bool showComparison;
  final EmployeeResponsiveData responsive;

  PerformanceChartPainter({
    required this.progress,
    required this.data,
    required this.chartType,
    required this.color,
    required this.secondaryColor,
    required this.showComparison,
    required this.responsive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final effectiveData = data.length > 7 ? data.sublist(0, 7) : data;
    final maxValue = effectiveData.isNotEmpty
        ? effectiveData.reduce(math.max).toDouble()
        : 1.0;

    switch (chartType) {
      case ChartType.line:
        _drawLineChart(canvas, size, effectiveData, maxValue);
        break;
      case ChartType.bar:
        _drawBarChart(canvas, size, effectiveData, maxValue);
        break;
      case ChartType. area:
        _drawAreaChart(canvas, size, effectiveData, maxValue);
        break;
      case ChartType.pie:
        break;
    }

    if (showComparison && chartType != ChartType.pie) {
      _drawComparisonLine(canvas, size, effectiveData, maxValue);
    }

    _drawGridLines(canvas, size);
  }

  void _drawLineChart(
      Canvas canvas,
      Size size,
      List<int> effectiveData,
      double maxValue,
      ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color. withOpacity(0.3), color.withOpacity(0.05)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect. fromLTWH(0, 0, size.width, size. height));

    final stepX = size.width / (effectiveData.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < effectiveData.length; i++) {
      final x = i * stepX;
      final y = size.height -
          (effectiveData[i] / maxValue * size.height * 0.8 * progress);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height -
            (effectiveData[i - 1] / maxValue * size.height * 0.8 * progress);
        final cpX = (prevX + x) / 2;

        path.quadraticBezierTo(cpX, prevY, cpX, (prevY + y) / 2);
        path.quadraticBezierTo(cpX, y, x, y);

        fillPath.quadraticBezierTo(cpX, prevY, cpX, (prevY + y) / 2);
        fillPath.quadraticBezierTo(cpX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size. height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    _drawDataPoints(canvas, size, effectiveData, maxValue, color);
  }

  void _drawBarChart(
      Canvas canvas,
      Size size,
      List<int> effectiveData,
      double maxValue,
      ) {
    final barWidth = (size.width / effectiveData. length) * 0.6;
    final gap = (size.width / effectiveData.length) * 0.4;

    for (int i = 0; i < effectiveData.length; i++) {
      final x = i * (barWidth + gap) + gap / 2;
      final barHeight =
      (effectiveData[i] / maxValue * size.height * 0.8 * progress);
      final y = size. height - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect. fromLTWH(x, y, barWidth, barHeight),
        Radius.circular(responsive.smallBorderRadius),
      );

      final gradient = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

      final paint = Paint()..shader = gradient. createShader(rect. outerRect);

      canvas.drawRRect(rect, paint);
    }
  }

  void _drawAreaChart(
      Canvas canvas,
      Size size,
      List<int> effectiveData,
      double maxValue,
      ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.5), color.withOpacity(0.05)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final stepX = size.width / (effectiveData.length - 1);
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < effectiveData.length; i++) {
      final x = i * stepX;
      final y = size.height -
          (effectiveData[i] / maxValue * size.height * 0.8 * progress);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size. height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  void _drawComparisonLine(
      Canvas canvas,
      Size size,
      List<int> effectiveData,
      double maxValue,
      ) {
    final paint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap. round;

    final comparisonData =
    effectiveData.map((v) => (v * 0.85).round()).toList();
    final stepX = size.width / (comparisonData.length - 1);
    final path = Path();

    for (int i = 0; i < comparisonData. length; i++) {
      final x = i * stepX;
      final y = size.height -
          (comparisonData[i] / maxValue * size. height * 0.8 * progress);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final dashPath = _createDashedPath(path, 5.0, 3.0);
    canvas.drawPath(dashPath, paint);
  }

  void _drawDataPoints(
      Canvas canvas,
      Size size,
      List<int> effectiveData,
      double maxValue,
      Color pointColor,
      ) {
    final stepX = size.width / (effectiveData.length - 1);
    final paint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < effectiveData. length; i++) {
      final x = i * stepX;
      final y = size.height -
          (effectiveData[i] / maxValue * size.height * 0.8 * progress);

      canvas.drawCircle(Offset(x, y), 4, borderPaint);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey. withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas. drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final dashPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = math.min(distance + dashWidth, metric.length);
        dashPath.addPath(metric.extractPath(start, end), Offset. zero);
        distance += dashWidth + dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(PerformanceChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate. chartType != chartType ||
        oldDelegate.showComparison != showComparison;
  }
}

/// Pie Chart Painter
class PieChartPainter extends CustomPainter {
  final double progress;
  final List<DistributionItem> items;
  final int total;
  final EmployeeResponsiveData responsive;

  PieChartPainter({
    required this.progress,
    required this.items,
    required this.total,
    required this.responsive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0 || items.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = -math.pi / 2;

    for (final item in items) {
      final sweepAngle =
          2 * math.pi * (item.count / total) * progress;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      final shadowPaint = Paint()
        ..color = item.color. withOpacity(0.3)
        ..maskFilter = const MaskFilter. blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center:  center, radius: radius + 2),
        startAngle,
        sweepAngle,
        true,
        shadowPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw white separator
      final separatorPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas. drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        separatorPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = AnalyticsDesign.surfaceWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate. progress != progress;
  }
}