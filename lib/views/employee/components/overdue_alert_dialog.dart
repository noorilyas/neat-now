import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class OverdueAlertDialog extends StatelessWidget {
  final int overdueCount;
  final VoidCallback onViewTasks;
  final VoidCallback onDismiss;

  const OverdueAlertDialog({
    super.key,
    required this. overdueCount,
    required this.onViewTasks,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return EmployeeResponsiveHelper(
      builder: (context, responsive) {
        final r = responsive;

        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: math.min(
                r.dialogMaxWidth,
                r.effectiveWidth - r.padding * 2,
              ),
              constraints: BoxConstraints(
                maxHeight: r.dialogMaxHeight,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  r.extraLargeBorderRadius,
                ),
                boxShadow: r.elevatedShadow,
              ),
              child: SingleChildScrollView(
                child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(r),
                    _buildContent(r),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(EmployeeResponsiveData r) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade600,
            Colors. red.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius. circular(r.extraLargeBorderRadius),
        ),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: Container(
              padding: EdgeInsets. all(r.padding),
              decoration: BoxDecoration(
                color: Colors.white. withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: r.iconSize(40),
              ),
            ),
          ),
          SizedBox(height: r.microPadding),
          if (r.showMinimalText)
            Text(
              r. adaptiveText(
                'Overdue Alert! ',
                nano: '! ',
                ultraMicro:  '!! ',
                micro: 'Alert! ',
                mini: 'Overdue!',
              ),
              style: GoogleFonts. poppins(
                fontSize:  r.headingS,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: Column(
        children: [
          // Count Display
          Container(
            padding: EdgeInsets.all(r.padding),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.largeBorderRadius),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child:  Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                Text(
                  '$overdueCount',
                  style: GoogleFonts.poppins(
                    fontSize: r.headingXL,
                    fontWeight:  FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: r.microPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task${overdueCount > 1 ?  's' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: r.bodyM,
                        fontWeight: FontWeight.w600,
                        color: Colors. red. shade800,
                      ),
                    ),
                    if (r.showSecondaryText)
                      Text(
                        'Overdue > 2 days',
                        style: GoogleFonts.poppins(
                          fontSize:  r.captionM,
                          color: Colors. red.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: r.microPadding),

          // Description
          if (r.showFullDescriptions)
            Text(
              'You have tasks pending for more than 2 days. Please complete them to maintain your performance rating.',
              textAlign: TextAlign.center,
              style: GoogleFonts. poppins(
                fontSize:  r.bodyS,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

          SizedBox(height: r.padding),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onDismiss();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[400]! ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r. borderRadius),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: r.microPadding,
                    ),
                  ),
                  child: Text(
                    r.adaptiveText(
                      'Later',
                      nano: 'X',
                      micro: 'X',
                      mini: 'Later',
                    ),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: r.bodyS,
                    ),
                  ),
                ),
              ),
              SizedBox(width: r.microPadding),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onViewTasks();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r. borderRadius),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: r.microPadding,
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (r.showIcons)
                        Icon(
                          Icons.visibility_rounded,
                          size: r.iconSize(18),
                        ),
                      if (r.showIcons) SizedBox(width: r.nanoPadding),
                      Text(
                        r.adaptiveText(
                          'View Tasks',
                          nano: '→',
                          micro: 'View',
                          mini: 'View',
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: r.bodyS,
                        ),
                      ),
                    ],
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