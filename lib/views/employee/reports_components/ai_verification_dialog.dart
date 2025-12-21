import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class AIVerificationDialog extends StatefulWidget {
  final Report report;
  final EmployeeResponsiveData responsive;
  final String afterImagePath;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime timestamp;
  final VoidCallback onSuccess;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const AIVerificationDialog({
    super.key,
    required this. report,
    required this.responsive,
    required this.afterImagePath,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
    required this.onSuccess,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  State<AIVerificationDialog> createState() => _AIVerificationDialogState();
}

class _AIVerificationDialogState extends State<AIVerificationDialog>
    with TickerProviderStateMixin {
  bool _isVerifying = true;
  bool?  _isVerified;
  int _cleanlinessScore = 0;
  final int _threshold = 85;
  List<String> _detectedIssues = [];
  int _currentStep = 0;

  late AnimationController _progressController;
  late AnimationController _resultController;
  late Animation<double> _resultAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _resultAnimation = CurvedAnimation(
      parent:  _resultController,
      curve:  Curves.elasticOut,
    );

    // ✅ SAFE ANIMATION START
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startVerification();
      }
    });
  }

  @override
  void dispose() {
    _progressController.stop();
    _resultController.stop();
    _progressController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  Future<void> _startVerification() async {
    final steps = VerificationStep.defaults;

    for (int i = 0; i < steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _currentStep = i + 1);
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final isClean = random < 85;

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _isVerified = isClean;
        _cleanlinessScore = isClean ? 85 + (random % 15) : 40 + (random % 40);
        if (! isClean) {
          _detectedIssues = [
            'Remaining debris detected',
            'Small waste particles visible',
            'Cleanup incomplete in corner'
          ].take(1 + random % 3).toList();
        }
      });
      _resultController.forward();
    }

    HapticFeedback.heavyImpact();

    if (isClean) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Dialog(
      backgroundColor: ReportsDesign.surfacePure,
      shape: RoundedRectangleBorder(
        borderRadius:  BorderRadius.circular(r.extraLargeBorderRadius),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: r.dimension(400)),
        padding: EdgeInsets.all(r.largePadding),
        child: _isVerifying
            ? _buildVerifyingContent(r)
            : _buildResultContent(r),
      ),
    );
  }

  Widget _buildVerifyingContent(EmployeeResponsiveData r) {
    final steps = VerificationStep.defaults;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated loading
        TweenAnimationBuilder<double>(
          tween:  Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1500),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 2 * 3.14159,
              child: child,
            );
          },
          child: Container(
            width: r.dimension(80),
            height: r.dimension(80),
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: [
                  ReportsDesign.purple,
                  ReportsDesign.purple. withOpacity(0.1),
                  ReportsDesign.purple,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: r.dimension(68),
                height: r.dimension(68),
                decoration: const BoxDecoration(
                  color: ReportsDesign.surfacePure,
                  shape:  BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: r.dimension(32),
                  color: ReportsDesign.purple,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: r.largePadding),
        Text(
          'AI Verification',
          style: GoogleFonts.inter(
            fontSize: r.headingXS,
            fontWeight: FontWeight.w700,
            color: ReportsDesign.textPrimary,
          ),
        ),
        SizedBox(height: r.nanoPadding),
        Text(
          'Analyzing your cleanup...',
          style: GoogleFonts.inter(
            fontSize: r.bodyS,
            color: ReportsDesign.textSecondary,
          ),
        ),
        SizedBox(height: r.largePadding),

        // Steps
        ... List.generate(steps.length, (index) {
          final step = steps[index];
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep - 1 && _currentStep <= steps.length;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end:  isCompleted || isCurrent ? 1.0 : 0.5),
            duration: const Duration(milliseconds: 300),
            builder: (context, opacity, child) => Opacity(
              opacity: opacity,
              child: child,
            ),
            child:  Padding(
              padding: EdgeInsets.symmetric(vertical: r.nanoPadding),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration:  const Duration(milliseconds: 300),
                    width: r.dimension(28),
                    height: r. dimension(28),
                    decoration: BoxDecoration(
                      gradient: isCompleted
                          ? ReportsDesign. successGradient
                          :  (isCurrent ?  ReportsDesign.primaryGradient : null),
                      color: ! isCompleted && ! isCurrent
                          ? ReportsDesign.surfaceLight
                          : null,
                      shape: BoxShape.circle,
                      boxShadow: isCompleted || isCurrent
                          ? ReportsDesign.glowShadow(
                        isCompleted
                            ? ReportsDesign.success
                            : ReportsDesign.primaryTeal,
                      )
                          :  null,
                    ),
                    child: isCompleted
                        ? Icon(
                      Icons.check_rounded,
                      size: r. iconSize(14),
                      color: Colors.white,
                    )
                        : isCurrent
                        ? SizedBox(
                      width:  r.iconSize(14),
                      height: r.iconSize(14),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Icon(
                      step. icon,
                      size: r.iconSize(12),
                      color: ReportsDesign.textTertiary,
                    ),
                  ),
                  SizedBox(width: r. microPadding),
                  Expanded(
                    child: Text(
                      step.label,
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: isCompleted
                            ? ReportsDesign. success
                            : (isCurrent
                            ? ReportsDesign. primaryTeal
                            : ReportsDesign.textTertiary),
                        fontWeight: isCurrent ?  FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        SizedBox(height: r.padding),
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            foregroundColor: ReportsDesign. textSecondary,
          ),
          child: Text(
            'Cancel',
            style:  GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(EmployeeResponsiveData r) {
    if (_isVerified == true) {
      return ScaleTransition(
        scale:  _resultAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: r.dimension(100),
              height: r.dimension(100),
              decoration: BoxDecoration(
                gradient: ReportsDesign.successGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ReportsDesign.success. withOpacity(0.4),
                    blurRadius:  30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                size: r.dimension(50),
                color: Colors.white,
              ),
            ),
            SizedBox(height: r.padding),
            Text(
              'Cleanup Verified! ',
              style: GoogleFonts.inter(
                fontSize: r.headingXS,
                fontWeight: FontWeight.w700,
                color: ReportsDesign.success,
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              'Great job! The area is clean.',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: ReportsDesign.textSecondary,
              ),
            ),
            SizedBox(height: r.padding),
            Container(
              padding: EdgeInsets.all(r.padding),
              decoration: BoxDecoration(
                color: ReportsDesign.surfaceLight,
                borderRadius: BorderRadius.circular(r.largeBorderRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:  [
                  _buildScoreItem(
                    r,
                    'Score',
                    '$_cleanlinessScore%',
                    ReportsDesign.success,
                  ),
                  Container(
                    width: 1,
                    height: r. dimension(40),
                    color: ReportsDesign.textLight,
                  ),
                  _buildScoreItem(
                    r,
                    'Threshold',
                    '≥$_threshold%',
                    ReportsDesign.info,
                  ),
                ],
              ),
            ),
            SizedBox(height: r. padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width:  r.dimension(16),
                  height: r. dimension(16),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ReportsDesign.success,
                  ),
                ),
                SizedBox(width: r.microPadding),
                Text(
                  'Completing task.. .',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    color:  ReportsDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return ScaleTransition(
        scale: _resultAnimation,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
        Container(
        width: r.dimension(100),
        height: r.dimension(100),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ReportsDesign.warning,
              ReportsDesign.warning.withOpacity(0.8),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow:  [
            BoxShadow(
              color: ReportsDesign.warning.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.warning_rounded,
          size: r.dimension(50),
          color: Colors.white,
        ),
      ),
    SizedBox(height: r.padding),
    Text(
    'Cleanup Incomplete',
    style: GoogleFonts.inter(
    fontSize: r.headingXS,
    fontWeight: FontWeight.w700,
    color: ReportsDesign.warning,
    ),
    ),
    SizedBox(height: r.nanoPadding),
    Text(
    'AI detected remaining waste.',
    style: GoogleFonts.inter(
    fontSize: r.bodyS,
    color: ReportsDesign.textSecondary,
    ),
    textAlign: TextAlign.center,
    ),
    SizedBox(height: r.padding),

    // Score display
    Container(
    padding:  EdgeInsets.all(r. padding),
    decoration: BoxDecoration(
    color: ReportsDesign.warning. withOpacity(0.05),
    borderRadius: BorderRadius.circular(r.largeBorderRadius),
    border: Border.all(
    color: ReportsDesign.warning.withOpacity(0.2),
    ),
    ),
    child: Column(
    children: [
    Row(
    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Score: ',
    style: GoogleFonts.inter(fontSize: r.bodyS),
    ),
    Text(
    '$_cleanlinessScore%',
    style: GoogleFonts.inter(
    fontSize: r.bodyM,
    fontWeight: FontWeight.w700,
    color: ReportsDesign.warning,
    ),
    ),
    ],
    ),
    SizedBox(height: r.nanoPadding),
    Row(
    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Required:',
    style: GoogleFonts.inter(fontSize: r.bodyS),
    ),
    Text(
    '≥$_threshold%',
    style: GoogleFonts. inter(
    fontSize: r.bodyM,
    fontWeight: FontWeight.w700,
    color: ReportsDesign.success,
    ),
    ),
    ],
    ),
    if (_detectedIssues.isNotEmpty) ...[
    Divider(
    height: r.padding,
    color: ReportsDesign.warning.withOpacity(0.3),
    ),
    ..._detectedIssues.map((issue) => Padding(
    padding: EdgeInsets.only(top: r.nanoPadding),
    child: Row(
    children: [
    Icon(
    Icons.fiber_manual_record,
    size:  r.iconSize(8),
    color: ReportsDesign.warning,
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    child: Text(
    issue,
    style: GoogleFonts.inter(
    fontSize: r.captionM,
    color: ReportsDesign.textSecondary,
    ),
    ),
    ),
    ],
    ),
    )),
    ],
    ],
    ),
    ),
    SizedBox(height: r.largePadding),

    // Action buttons
    Row(
    children: [
    Expanded(
    child: Container(
    height: r.buttonHeight,
    decoration: BoxDecoration(
    border: Border.all(color: ReportsDesign.textLight),
    borderRadius: BorderRadius.circular(r.borderRadius),
    ),
    child: Material(
    color: Colors. transparent,
    child: InkWell(
    onTap: widget.onCancel,
    borderRadius: BorderRadius.circular(r.borderRadius),
    child: Center(
    child: Text(
    'Cancel',
    style: GoogleFonts. inter(
    fontSize: r.bodyS,
    fontWeight: FontWeight.w600,
    color: ReportsDesign.textSecondary,
    ),
    ),
    ),
    ),
    ),
    ),
    ),
    SizedBox(width: r. microPadding),
    Expanded(
    flex: 2,
    child: Container(
    height:  r.buttonHeight,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [
    ReportsDesign.warning,
    ReportsDesign.warning.withOpacity(0.9),
    ],
    ),
    borderRadius: BorderRadius.circular(r.borderRadius),
    boxShadow: ReportsDesign.glowShadow(ReportsDesign.warning),
    ),
    child: Material(
    color: Colors. transparent,
    child: InkWell(
    onTap: widget.onRetry,
    borderRadius:  BorderRadius.circular(r.borderRadius),
    child: Row(
    mainAxisAlignment:  MainAxisAlignment.center,
    children: [
    Icon(
    Icons.camera_alt_rounded,
    size: r. iconSize(18),
    color: Colors.white,
    ),
    SizedBox(width:  r.nanoPadding),
    Text(
    'Retake Photo',
    style: GoogleFonts.inter(
    fontSize: r.bodyS,
    fontWeight: FontWeight. w600,
    color:  Colors.white,
    ),
    ),
    ],
    ),
    ),
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

  Widget _buildScoreItem(
      EmployeeResponsiveData r,
      String label,
      String value,
      Color color,
      ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: r.headingS,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: r.captionS,
            color: ReportsDesign.textSecondary,
          ),
        ),
      ],
    );
  }
}