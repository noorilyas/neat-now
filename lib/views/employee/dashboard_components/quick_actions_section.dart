import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/dashboard_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/employee_dashboard_tab.dart';
import 'dart:math' as math;

class DashboardQuickActionsSection extends StatelessWidget {
  final List<QuickActionData> actions;
  final EmployeeResponsiveData responsive;
  final Function(int) onActionTap;

  const DashboardQuickActionsSection({
    super.key,
    required this. actions,
    required this.responsive,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(r),
        SizedBox(height: r.microPadding),
        SizedBox(
          height: r.dimension(100),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < actions.length - 1 ?  r.microPadding : 0,
                ),
                child: _buildActionCard(r, actions[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(EmployeeResponsiveData r) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(r.nanoPadding),
          decoration:  BoxDecoration(
            color:  DesignSystem.warning. withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.smallBorderRadius),
          ),
          child: Icon(
            Icons.bolt_rounded,
            size: r.iconSize(18),
            color: DesignSystem.warning,
          ),
        ),
        SizedBox(width: r. microPadding),
        Expanded(
          child: Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w700,
              color: DesignSystem.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
      EmployeeResponsiveData r,
      QuickActionData action,
      int index,
      ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves. easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child:  Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:  () {
            HapticFeedback.lightImpact();
            onActionTap(action.targetTabIndex);
          },
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          child: Container(
            width: r.dimension(90),
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: DesignSystem.surfaceWhite,
              borderRadius: BorderRadius.circular(r.largeBorderRadius),
              boxShadow: DesignSystem.softShadow,
              border: Border.all(
                color: action.color. withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(r.microPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.color,
                        action.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment. bottomRight,
                    ),
                    borderRadius: BorderRadius. circular(r.borderRadius),
                    boxShadow: DesignSystem.glowShadow(action.color),
                  ),
                  child: Icon(
                    action.icon,
                    size: r.iconSize(22),
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: r.nanoPadding),
                Text(
                  r.adaptiveText(
                    action. label,
                    nano: action. label[0],
                    micro: action.label.substring(
                      0,
                      math.min(4, action.label.length),
                    ),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}