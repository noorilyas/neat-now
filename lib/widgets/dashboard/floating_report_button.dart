import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';

/// FloatingReportButton - Floating action button for reporting
class FloatingReportButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ResponsiveData responsive;

  const FloatingReportButton({
    super.key,
    required this. onPressed,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final size = responsive.isMicroScreen
        ? 40.0
        : responsive.isNanoScreen
        ?  50.0
        : responsive.isMiniScreen
        ? 56.0
        : responsive.dimension(64);

    return Container(
      width: size,
      height: size,
      margin: EdgeInsets. only(bottom: responsive.dimension(10)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ),
        shape: BoxShape.circle,
        boxShadow: responsive.showShadows
            ? [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback. mediumImpact();
            onPressed();
          },
          customBorder: const CircleBorder(),
          child: Center(
            child: responsive.isMicroScreen
                ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '📷',
                style: TextStyle(fontSize: responsive.fontSize(18)),
              ),
            )
                : Icon(
              Icons.add_a_photo_rounded,
              color: Colors.white,
              size: responsive. iconSize(26),
            ),
          ),
        ),
      ),
    );
  }
}