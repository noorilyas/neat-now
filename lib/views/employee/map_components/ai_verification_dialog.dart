import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class AIVerificationDialog extends StatefulWidget {
  final Report report;
  final MapTabViewModel viewModel;
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
    required this.viewModel,
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
    with SingleTickerProviderStateMixin {
  bool _isVerifying = true;
  AIVerificationResult? _result;
  int _currentStep = 0;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final List<String> _steps = VerificationStep.defaultSteps;

  @override
  void initState() {
    super.initState();
    _initAnimation();

    // ✅ SAFE ANIMATION START
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startVerification();
      }
    });
  }

  void _initAnimation() {
    _animController = AnimationController(
      duration: const Duration(milliseconds:  600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent:  _animController,
      curve:  Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animController.stop();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startVerification() async {
    // Simulate step-by-step verification
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _currentStep = i + 1);
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Perform AI verification
    final result = await widget.viewModel.performAIVerification();

    if (mounted) {
      setState(() {
        _isVerifying = false;
        _result = result;
      });
      _animController.forward();
    }

    HapticFeedback.heavyImpact();

    // Auto-proceed on success
    if (result.isVerified) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        widget.onSuccess();
      }
    }
  }

  EmployeeResponsiveData get r => widget.responsive;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: MapDesign.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius:  BorderRadius.circular(r.extraLargeBorderRadius),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: r.dimension(400)),
        padding: EdgeInsets.all(r.largePadding),
        child: _isVerifying
            ? _buildVerifyingContent()
            : _buildResultContent(),
      ),
    );
  }

  Widget _buildVerifyingContent() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
    // Animated progress
    SizedBox(
    width: r.dimension(80),
    height: r.dimension(80),
    child: Stack(
    alignment: Alignment.center,
    children: [
    SizedBox(
    width: r.dimension(80),
    height: r.dimension(80),
    child: CircularProgressIndicator(
    value: _currentStep / _steps.length,
    strokeWidth: 4,
    backgroundColor: Colors.grey[200],
    color: MapDesign.primaryTeal,
    ),
    ),
    Icon(
    Icons.smart_toy_rounded,
    size: r.iconSize(36),
    color: MapDesign.textSecondary,
    ),
    ],
    ),
    ),
    SizedBox(height: r.largePadding),
    Text(
    'AI Verification',
    style: GoogleFonts.poppins(
    fontSize: r.headingXS,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: r.nanoPadding),
    Text(
    'Analyzing your cleanup.. .',
    style: GoogleFonts.poppins(
    fontSize: r.bodyS,
    color: MapDesign.textSecondary,
    ),
    ),
    SizedBox(height: r. largePadding),

    // Progress steps
    ..._buildVerificationSteps(),

    SizedBox(height: r.padding),
    TextButton(
    onPressed: widget.onCancel,
    child: Text(
    'Cancel',
    style: GoogleFonts.poppins(color: MapDesign.textSecondary),
    ),
    ),
    ],
    );
  }

  List<Widget> _buildVerificationSteps() {
    return List.generate(_steps.length, (index) {
      final isCompleted = index < _currentStep;
      final isCurrent = index == _currentStep - 1;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: r.atomicPadding),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: r.dimension(20),
              height: r.dimension(20),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : (isCurrent ? MapDesign.primaryTeal : Colors.grey[300]),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? Icon(
                Icons.check_rounded,
                size: r.iconSize(14),
                color: Colors. white,
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
                  : null,
            ),
            SizedBox(width: r.microPadding),
            Expanded(
              child: Text(
                _steps[index],
                style: GoogleFonts. poppins(
                  fontSize: r.captionM,
                  color: isCompleted
                      ? Colors.green
                      : (isCurrent
                      ? MapDesign.primaryTeal
                      : MapDesign.textTertiary),
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildResultContent() {
    if (_result == null) return const SizedBox. shrink();

    if (_result!.isVerified) {
      return _buildSuccessResult();
    } else {
      return _buildFailureResult();
    }
  }

  Widget _buildSuccessResult() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(r.padding),
            decoration: BoxDecoration(
              color: Colors.green. withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: r.iconSize(56),
            ),
          ),
          SizedBox(height: r.padding),
          Text(
            'Cleanup Verified!',
            style:  GoogleFonts.poppins(
              fontSize: r.headingXS,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: r.microPadding),
          Text(
            'Great job! The AI has verified that the area is clean.',
            style: GoogleFonts.poppins(
              fontSize: r.captionL,
              color: MapDesign.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: r. padding),

          // Score display
          Container(
            padding:  EdgeInsets.all(r. padding),
            decoration: BoxDecoration(
              color: Colors. grey[50],
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreItem('Cleanliness', '${_result!.cleanlinessScore}%', Colors.green),
                Container(
                  width: 1,
                  height: r. dimension(40),
                  color: Colors.grey[300],
                ),
                _buildScoreItem('Threshold', '≥${_result!.threshold}%', Colors.blue),
              ],
            ),
          ),
          SizedBox(height: r.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: r.iconSize(16),
                height: r.iconSize(16),
                child:  const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Completing task.. .',
                style: GoogleFonts.poppins(
                  fontSize: r.captionM,
                  color: MapDesign.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFailureResult() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
      Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color:  Colors.orange.withOpacity(0.1),
        shape: BoxShape. circle,
      ),
      child: Icon(
        Icons.warning_rounded,
        color: Colors.orange,
        size: r.iconSize(56),
      ),
    ),
    SizedBox(height: r.padding),
    Text(
    'Cleanup Incomplete',
    style: GoogleFonts.poppins(
    fontSize: r.headingXS,
    fontWeight: FontWeight.bold,
    color: Colors.orange,
    ),
    ),
    SizedBox(height: r.microPadding),
    Text(
    'The AI detected remaining waste. Please complete the cleanup and try again.',
    style: GoogleFonts.poppins(
    fontSize: r.captionL,
    color: MapDesign.textSecondary,
    ),
    textAlign: TextAlign.center,
    ),
    SizedBox(height: r. padding),

    // Score display
    Container(
    padding: EdgeInsets.all(r.padding),
    decoration: BoxDecoration(
    color: Colors.orange. withOpacity(0.05),
    borderRadius: BorderRadius.circular(r.borderRadius),
    border: Border.all(color: Colors.orange.withOpacity(0.2)),
    ),
    child:  Column(
    children: [
    Row(
    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Cleanliness Score: ',
    style: GoogleFonts.poppins(fontSize: r.captionL),
    ),
    Text(
    '${_result!.cleanlinessScore}%',
    style: GoogleFonts.poppins(
    fontSize: r.bodyM,
    fontWeight: FontWeight.bold,
    color: Colors.orange,
    ),
    ),
    ],
    ),
    SizedBox(height: r.nanoPadding),
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    'Required: ',
    style: GoogleFonts.poppins(fontSize: r.captionL),
    ),
    Text(
    '≥${_result!.threshold}%',
    style: GoogleFonts.poppins(
    fontSize: r.bodyM,
    fontWeight:  FontWeight.bold,
    color: Colors.green,
    ),
    ),
    ],
    ),
    if (_result!.detectedIssues.isNotEmpty) ...[
    Divider(height: r.padding),
    Align(
    alignment: Alignment.centerLeft,
    child: Text(
    'Issues detected:',
    style: GoogleFonts.poppins(
    fontSize: r.captionS,
    color: MapDesign.textSecondary,
    ),
    ),
    ),
    SizedBox(height: r.nanoPadding),
    ..._result!.detectedIssues. map((issue) => Padding(
    padding: EdgeInsets.only(left: r.microPadding, top: r.atomicPadding),
    child: Row(
    children: [
    Icon(
    Icons.fiber_manual_record,
    size: r.iconSize(6),
    color: Colors. orange,
    ),
    SizedBox(width: r.nanoPadding),
    Expanded(
    child: Text(
    issue,
    style: GoogleFonts.poppins(fontSize: r.captionM),
    ),
    ),
    ],
    ),
    )),
    ],
    ],
    ),
    ),
    SizedBox(height: r. largePadding),

    // Action buttons
    Row(
    children: [
    Expanded(
    child: OutlinedButton(
    onPressed: widget.onCancel,
    style: OutlinedButton.styleFrom(
    foregroundColor: MapDesign.textSecondary,
    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
    minimumSize: Size(0, r.buttonHeight),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(r.borderRadius),
    ),
    ),
    child: const Text('Cancel'),
    ),
    ),
    SizedBox(width: r.microPadding),
    Expanded(
    flex: 2,
    child: ElevatedButton. icon(
    onPressed:  widget.onRetry,
    icon: Icon(Icons.camera_alt_rounded, size: r.iconSize(18)),
    label: const Text('Retake Photo'),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
    minimumSize: Size(0, r.buttonHeight),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(r. borderRadius),
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

  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: r.headingS,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: r. captionS,
            color: MapDesign.textSecondary,
          ),
        ),
      ],
    );
  }
}