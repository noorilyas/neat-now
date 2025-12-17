import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/viewmodels/user/logout_dialog_viewmodel.dart';

class ModernLogoutDialog extends StatefulWidget {
  final UserResponsiveData responsive;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ModernLogoutDialog({
    super. key,
    required this.responsive,
    required this.onConfirm,
    required this. onCancel,
  });

  @override
  State<ModernLogoutDialog> createState() => _ModernLogoutDialogState();
}

class _ModernLogoutDialogState extends State<ModernLogoutDialog>
    with SingleTickerProviderStateMixin {
  late LogoutDialogViewModel _viewModel;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize ViewModel
    _viewModel = LogoutDialogViewModel(onConfirm: widget.onConfirm);
    _viewModel.addListener(_onViewModelChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve:  Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _animationController.reverse();
    widget.onCancel();
  }

  Future<void> _confirm() async {
    HapticFeedback.heavyImpact();
    await _viewModel.confirm();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return AnimatedBuilder(
      animation: _animationController,
      builder:  (context, child) {
        return Stack(
          children: [
            // Backdrop
            GestureDetector(
              onTap: _viewModel.isLoggingOut ? null : _close,
              child: Container(
                color: Colors.black.withOpacity(0.6 * _fadeAnimation.value),
              ),
            ),

            // Dialog
            Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child:  Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    margin: EdgeInsets.all(r.largePadding),
                    padding: EdgeInsets.all(r.largePadding),
                    decoration: BoxDecoration(
                      color: UserDesign.surfacePure,
                      borderRadius: BorderRadius.circular(
                          r.extraLargeBorderRadius + 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius:  30,
                          offset:  const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(r.padding + 4),
                          decoration:  BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                UserDesign.error.withOpacity(0.15),
                                UserDesign. error.withOpacity(0.05),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(r.padding),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  UserDesign.error,
                                  UserDesign. error.withOpacity(0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: UserDesign.error.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: r.iconSize(32),
                            ),
                          ),
                        ),

                        SizedBox(height: r.padding),

                        // Title
                        Text(
                          'Sign Out? ',
                          style: GoogleFonts.inter(
                            fontSize: r.headingS,
                            fontWeight: FontWeight.w700,
                            color: UserDesign.textPrimary,
                          ),
                        ),

                        SizedBox(height:  r.microPadding),

                        // Description
                        Text(
                          'Are you sure you want to sign out?\nYou\'ll need to sign in again to access your account.',
                          style: GoogleFonts.inter(
                            fontSize: r.bodyS,
                            color: UserDesign. textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: r.largePadding),

                        // Buttons
                        Row(
                          children: [
                            // Cancel Button
                            Expanded(
                              child: GestureDetector(
                                onTap: _viewModel.isLoggingOut ?  null : _close,
                                child: Container(
                                  height: r.buttonHeight + 4,
                                  decoration: BoxDecoration(
                                    color: UserDesign.surfaceLight,
                                    borderRadius: BorderRadius.circular(
                                        r.largeBorderRadius),
                                    border: Border.all(
                                      color: UserDesign. surfaceOverlay,
                                      width: 1.5,
                                    ),
                                  ),
                                  child:  Center(
                                    child:  Text(
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

                            // Sign Out Button
                            Expanded(
                              child: GestureDetector(
                                onTap: _viewModel.isLoggingOut
                                    ? null
                                    : _confirm,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: r.buttonHeight + 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        UserDesign.error,
                                        UserDesign. error.withOpacity(0.85),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        r.largeBorderRadius),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        UserDesign. error.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _viewModel.isLoggingOut
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:  CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color:  Colors.white,
                                      ),
                                    )
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment. center,
                                      children:  [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: Colors.white,
                                          size: r.iconSize(18),
                                        ),
                                        SizedBox(width:  r.nanoPadding),
                                        Text(
                                          'Sign Out',
                                          style: GoogleFonts.inter(
                                            fontSize: r.bodyS,
                                            fontWeight: FontWeight.w600,
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
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Export for use in profile tab
class _ModernLogoutDialog extends ModernLogoutDialog {
  const _ModernLogoutDialog({
    required super.responsive,
    required super.onConfirm,
    required super.onCancel,
  });
}