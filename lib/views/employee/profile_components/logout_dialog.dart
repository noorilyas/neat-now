import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class LogoutConfirmDialog extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const LogoutConfirmDialog({
    super.key,
    required this.responsive,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<LogoutConfirmDialog> createState() => _LogoutConfirmDialogState();
}

class _LogoutConfirmDialogState extends State<LogoutConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds:  300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve:  Curves.easeOutBack),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return GestureDetector(
      onTap: widget.onCancel,
      child: FadeTransition(
        opacity:  _fadeAnimation,
        child:  Container(
          color: Colors.black. withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent dismissal when tapping dialog
              child: ScaleTransition(
                scale:  _scaleAnimation,
                child: Container(
                  margin: EdgeInsets.all(r.largePadding),
                  padding: EdgeInsets.all(r.largePadding),
                  constraints: BoxConstraints(maxWidth: r.dimension(400)),
                  decoration: BoxDecoration(
                    color: ProfileDesign.surfacePure,
                    borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
                    boxShadow: ProfileDesign. elevatedShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.all(r.padding),
                        decoration:  BoxDecoration(
                          color: ProfileDesign.error. withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color:  ProfileDesign.error,
                          size: r.iconSize(40),
                        ),
                      ),

                      SizedBox(height: r.padding),

                      Text(
                        'Sign Out? ',
                        style: GoogleFonts.inter(
                          fontSize: r.headingXS,
                          fontWeight: FontWeight.w700,
                          color: ProfileDesign.textPrimary,
                        ),
                      ),

                      SizedBox(height:  r.nanoPadding),

                      Text(
                        'Are you sure you want to sign out of your account?',
                        style: GoogleFonts.inter(
                          fontSize: r.bodyS,
                          color: ProfileDesign.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: r.largePadding),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onCancel,
                              child: Container(
                                height: r.buttonHeight,
                                decoration: BoxDecoration(
                                  color: ProfileDesign.surfaceLight,
                                  borderRadius:  BorderRadius.circular(r.borderRadius),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.inter(
                                      fontSize: r.bodyS,
                                      fontWeight: FontWeight.w600,
                                      color: ProfileDesign.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: r. microPadding),
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onConfirm,
                              child:  Container(
                                height: r.buttonHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ProfileDesign.error,
                                      ProfileDesign. error.withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(r.borderRadius),
                                  boxShadow: ProfileDesign.glowShadow(ProfileDesign.error),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign Out',
                                    style:  GoogleFonts.inter(
                                      fontSize: r.bodyS,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
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
          ),
        ),
      ),
    );
  }
}