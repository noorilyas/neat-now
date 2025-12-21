import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder:  (context, responsive) {
        final r = responsive;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: math.min(
                r.dialogMaxWidth * 0.9,
                r.effectiveWidth - r.padding * 2,
              ),
              padding: EdgeInsets.all(r.padding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  r.extraLargeBorderRadius,
                ),
                boxShadow: r.elevatedShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder:  (context, value, child) => Transform.scale(
                      scale: value,
                      child:  child,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(r.microPadding),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color:  Colors.red,
                        size: r. iconSize(32),
                      ),
                    ),
                  ),

                  SizedBox(height: r.microPadding),

                  // Title
                  Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize:  r.headingS,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),

                  SizedBox(height: r.microPadding),

                  // Description
                  if (r.showSecondaryText)
                    Text(
                      'Are you sure you want to logout?  You\'ll need to sign in again.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: r.bodyS,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),

                  SizedBox(height:  r.padding),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:  () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context, false);
                          },
                          style: OutlinedButton. styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[400]!),
                            shape:  RoundedRectangleBorder(
                              borderRadius:  BorderRadius.circular(
                                r.borderRadius,
                              ),
                            ),
                            padding: EdgeInsets. symmetric(
                              vertical: r.microPadding,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight. w600,
                              fontSize:  r.bodyS,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: r. microPadding),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context, true);
                          },
                          style:  ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor:  Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                r.borderRadius,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: r. microPadding,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: r.bodyS,
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
        );
      },
    );
  }
}