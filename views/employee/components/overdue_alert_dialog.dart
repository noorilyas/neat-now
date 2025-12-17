import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

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
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: math.min(
                responsive.dialogMaxWidth,
                responsive.effectiveWidth - responsive.padding * 2,
              ),
              constraints: BoxConstraints(
                maxHeight: responsive.dialogMaxHeight,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  responsive.extraLargeBorderRadius,
                ),
                boxShadow: responsive.elevatedShadow,
              ),
              child: SingleChildScrollView(
                child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(responsive),
                    _buildContent(responsive),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(EmployeeResponsiveData responsive) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red. shade600,
            Colors.red.shade400,
          ],
          begin:  Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:  BorderRadius.vertical(
          top: Radius. circular(responsive.extraLargeBorderRadius),
        ),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin:  0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: Container(
              padding: EdgeInsets.all(responsive.padding),
              decoration: BoxDecoration(
                color: Colors.white. withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: responsive.iconSize(40),
              ),
            ),
          ),
          SizedBox(height: responsive.microPadding),
          if (responsive.showMinimalText)
            Text(
              responsive.adaptiveText(
                'Overdue Alert! ',
                nano: '! ',
                ultraMicro:  '!! ',
                micro: 'Alert! ',
                mini: 'Overdue! ',
              ),
              style:  GoogleFonts.poppins(
                fontSize: responsive.headingS,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(EmployeeResponsiveData responsive) {
    return Padding(
      padding: EdgeInsets.all(responsive.padding),
      child: Column(
        children: [
          // Count Display
          Container(
            padding: EdgeInsets.all(responsive.padding),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                responsive.largeBorderRadius,
              ),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$overdueCount',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.headingXL,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: responsive.microPadding),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task${overdueCount > 1 ? 's' :  ''}',
                      style:  GoogleFonts.poppins(
                        fontSize: responsive. bodyM,
                        fontWeight: FontWeight.w600,
                        color: Colors. red. shade800,
                      ),
                    ),
                    if (responsive.showSecondaryText)
                      Text(
                        'Overdue > 2 days',
                        style: GoogleFonts.poppins(
                          fontSize: responsive.captionM,
                          color: Colors. red.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: responsive.microPadding),

          // Description
          if (responsive.showFullDescriptions)
            Text(
              'You have tasks pending for more than 2 days.  Please complete them to maintain your performance rating.',
              textAlign: TextAlign.center,
              style: GoogleFonts. poppins(
                fontSize:  responsive.bodyS,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

          SizedBox(height: responsive. padding),

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
                      borderRadius: BorderRadius.circular(
                        responsive.borderRadius,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.microPadding,
                    ),
                  ),
                  child: Text(
                    responsive.adaptiveText(
                      'Later',
                      nano: 'X',
                      micro: 'X',
                      mini: 'Later',
                    ),
                    style: GoogleFonts. poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: responsive.bodyS,
                    ),
                  ),
                ),
              ),
              SizedBox(width:  responsive.microPadding),
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
                      borderRadius: BorderRadius.circular(
                        responsive.borderRadius,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.microPadding,
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: [
                      if (responsive.showIcons)
                        Icon(
                          Icons.visibility_rounded,
                          size: responsive.iconSize(18),
                        ),
                      if (responsive.showIcons)
                        SizedBox(width: responsive.nanoPadding),
                      Text(
                        responsive.adaptiveText(
                          'View Tasks',
                          nano: '→',
                          micro: 'View',
                          mini: 'View',
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: responsive.bodyS,
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