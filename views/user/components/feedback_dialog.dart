import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/models/user/user_report_model.dart';

class FeedbackDialog extends StatefulWidget {
  final UserReportModel report;
  final UserResponsiveData responsive;
  final Function(int rating, String feedback) onSubmit;

  const FeedbackDialog({
    super.key,
    required this.report,
    required this.responsive,
    required this.onSubmit,
  });

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  final List<String> _quickFeedback = [
    'Excellent work! ',
    'Very thorough cleanup',
    'Quick response time',
    'Area looks great now',
    'Professional service',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent:  _animController,
      curve:  Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return ScaleTransition(
      scale: _scaleAnimation,
      child:  Dialog(
        backgroundColor: UserDesign.surfacePure,
        shape: RoundedRectangleBorder(
          borderRadius:  BorderRadius.circular(r.extraLargeBorderRadius),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: r.dimension(400)),
          padding: EdgeInsets.all(r.largePadding),
          child: SingleChildScrollView(
            child:  Column(
              mainAxisSize:  MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(r.padding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700).withOpacity(0.15),
                        const Color(0xFFFFD700).withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: r.iconSize(40),
                    color: const Color(0xFFFFD700),
                  ),
                ),

                SizedBox(height: r.padding),

                Text(
                  'Rate the Cleanup',
                  style: GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign.textPrimary,
                  ),
                ),

                SizedBox(height: r.nanoPadding),

                Text(
                  'How was ${widget.report.workerName}\'s work?',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    color: UserDesign.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: r.largePadding),

                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedRating = starIndex);
                      },
                      child: AnimatedScale(
                        scale: _selectedRating >= starIndex ?  1.2 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child:  Padding(
                          padding: EdgeInsets.symmetric(horizontal: r.nanoPadding),
                          child: Icon(
                            _selectedRating >= starIndex
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: _selectedRating >= starIndex
                                ? const Color(0xFFFFD700)
                                : UserDesign.textLight,
                            size: r.iconSize(40),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height:  r.microPadding),

                // Rating Label
                AnimatedOpacity(
                  opacity: _selectedRating > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _getRatingLabel(_selectedRating),
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight:  FontWeight.w600,
                      color: _getRatingColor(_selectedRating),
                    ),
                  ),
                ),

                SizedBox(height: r.largePadding),

                // Quick Feedback Chips
                Wrap(
                  spacing: r. nanoPadding,
                  runSpacing: r.nanoPadding,
                  children: _quickFeedback.map((text) {
                    final isSelected = _feedbackController.text.contains(text);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (isSelected) {
                          _feedbackController.text = _feedbackController.text
                              . replaceAll(text, '')
                              .trim();
                        } else {
                          if (_feedbackController.text.isNotEmpty) {
                            _feedbackController.text += ' $text';
                          } else {
                            _feedbackController. text = text;
                          }
                        }
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.microPadding,
                          vertical: r.nanoPadding,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? UserDesign.primaryTeal. withOpacity(0.15)
                              : UserDesign.surfaceLight,
                          borderRadius: BorderRadius.circular(r. pillBorderRadius),
                          border: Border.all(
                            color: isSelected
                                ? UserDesign.primaryTeal
                                : UserDesign.textLight,
                          ),
                        ),
                        child: Text(
                          text,
                          style: GoogleFonts. inter(
                            fontSize: r.captionS,
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight. w500,
                            color:  isSelected
                                ? UserDesign.primaryTeal
                                : UserDesign.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: r.padding),

                // Feedback Text Field
                Container(
                  decoration: BoxDecoration(
                    color: UserDesign.surfaceLight,
                    borderRadius:  BorderRadius.circular(r.borderRadius),
                  ),
                  child: TextField(
                    controller:  _feedbackController,
                    maxLines: 3,
                    maxLength: 300,
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      color: UserDesign.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add your feedback (optional).. .',
                      hintStyle: GoogleFonts. inter(
                        fontSize: r.captionM,
                        color: UserDesign.textTertiary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:  BorderRadius.circular(r.borderRadius),
                        borderSide: BorderSide. none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(r. borderRadius),
                        borderSide: const BorderSide(
                          color: UserDesign.primaryTeal,
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets. all(r.microPadding),
                      counterStyle: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        color: UserDesign.textTertiary,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                SizedBox(height:  r.largePadding),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: r.buttonHeight,
                          decoration: BoxDecoration(
                            border: Border.all(color: UserDesign.textLight),
                            borderRadius: BorderRadius.circular(r.borderRadius),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                fontSize: r.bodyS,
                                fontWeight: FontWeight.w600,
                                color: UserDesign.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: r.microPadding),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _selectedRating > 0
                            ? () => widget.onSubmit(
                          _selectedRating,
                          _feedbackController.text. trim(),
                        )
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: r.buttonHeight,
                          decoration: BoxDecoration(
                            gradient: _selectedRating > 0
                                ? const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500),
                              ],
                            )
                                : null,
                            color: _selectedRating > 0 ? null : UserDesign.textLight,
                            borderRadius: BorderRadius.circular(r.borderRadius),
                            boxShadow: _selectedRating > 0
                                ? UserDesign.glowShadow(const Color(0xFFFFD700))
                                : null,
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                size:  r.iconSize(18),
                                color: _selectedRating > 0
                                    ? Colors.white
                                    : UserDesign.textTertiary,
                              ),
                              SizedBox(width:  r.nanoPadding),
                              Text(
                                'Submit Feedback',
                                style: GoogleFonts.inter(
                                  fontSize: r.bodyS,
                                  fontWeight:  FontWeight.w600,
                                  color: _selectedRating > 0
                                      ?  Colors.white
                                      :  UserDesign.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor 😞';
      case 2:
        return 'Fair 😐';
      case 3:
        return 'Good 🙂';
      case 4:
        return 'Very Good 😊';
      case 5:
        return 'Excellent!  🤩';
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return UserDesign.error;
      case 2:
        return UserDesign.warning;
      case 3:
        return UserDesign.info;
      case 4:
        return UserDesign.success;
      case 5:
        return const Color(0xFFFFD700);
      default:
        return UserDesign.textTertiary;
    }
  }
}