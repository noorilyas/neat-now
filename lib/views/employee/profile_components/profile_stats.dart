import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/profile_viewmodel.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class ProfileStats extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final ProfileViewModel viewModel;
  final Animation<double> statsAnimation;

  const ProfileStats({
    super.key,
    required this. responsive,
    required this.viewModel,
    required this.statsAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Transform.translate(
      offset: Offset(0, -r.dimension(40)),
      child: Padding(
        padding: EdgeInsets. symmetric(horizontal: r.padding),
        child: Container(
          padding: EdgeInsets.all(r.padding),
          decoration: BoxDecoration(
            color: ProfileDesign.surfacePure,
            borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
            boxShadow: ProfileDesign. elevatedShadow,
          ),
          child: Column(
            children: [
              // Section title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r.nanoPadding),
                    decoration: BoxDecoration(
                      color: ProfileDesign.primaryTeal. withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: ProfileDesign.primaryTeal,
                      size: r. iconSize(18),
                    ),
                  ),
                  SizedBox(width: r.microPadding),
                  Text(
                    'Performance Stats',
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight:  FontWeight.w700,
                      color: ProfileDesign.textPrimary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: r.padding),

              // Stats row
              Row(
                children:  [
                  Expanded(
                    child: _buildStatItem(
                      r,
                      'Completed',
                      viewModel.completedTasks,
                      Icons.check_circle_rounded,
                      ProfileDesign.success,
                    ),
                  ),
                  _buildStatDivider(r),
                  Expanded(
                    child: _buildStatItem(
                      r,
                      'Pending',
                      viewModel.pendingTasks,
                      Icons.schedule_rounded,
                      ProfileDesign.warning,
                    ),
                  ),
                  _buildStatDivider(r),
                  Expanded(
                    child: _buildRatingStatItem(r),
                  ),
                ],
              ),

              SizedBox(height: r.padding),

              // Progress bar
              _buildCompletionProgress(r),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      EmployeeResponsiveData r,
      String label,
      int value,
      IconData icon,
      Color color,
      ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(r.microPadding),
          decoration:  BoxDecoration(
            color:  color. withOpacity(0.1),
            borderRadius: BorderRadius. circular(r.borderRadius),
          ),
          child: Icon(icon, color: color, size: r.iconSize(22)),
        ),
        SizedBox(height: r.microPadding),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Text(
              '$animValue',
              style: GoogleFonts.inter(
                fontSize: r.headingS,
                fontWeight: FontWeight.w800,
                color: ProfileDesign.textPrimary,
              ),
            );
          },
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: r.captionS,
            color: ProfileDesign.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStatItem(EmployeeResponsiveData r) {
    return Column(
      children: [
        Container(
          padding:  EdgeInsets.all(r. microPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:  [
                ProfileDesign.gold.withOpacity(0.2),
                ProfileDesign.gold.withOpacity(0.1)
              ],
            ),
            borderRadius: BorderRadius.circular(r.borderRadius),
          ),
          child: Icon(Icons.star_rounded, color: ProfileDesign. gold, size: r.iconSize(22)),
        ),
        SizedBox(height: r.microPadding),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: viewModel.rating),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, animValue, child) {
            return Text(
              animValue.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: r.headingS,
                fontWeight: FontWeight.w800,
                color: ProfileDesign.textPrimary,
              ),
            );
          },
        ),
        _buildAnimatedStars(r),
      ],
    );
  }

  Widget _buildAnimatedStars(EmployeeResponsiveData r) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: viewModel.rating),
      duration: const Duration(milliseconds:  1500),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = (animValue - index).clamp(0.0, 1.0);
            return Icon(
              starValue >= 1
                  ? Icons.star_rounded
                  : (starValue > 0 ? Icons.star_half_rounded : Icons.star_outline_rounded),
              color: ProfileDesign.gold,
              size: r.iconSize(12),
            );
          }),
        );
      },
    );
  }

  Widget _buildStatDivider(EmployeeResponsiveData r) {
    return Container(
      width: 1,
      height: r. dimension(60),
      color: ProfileDesign.surfaceOverlay,
    );
  }

  Widget _buildCompletionProgress(EmployeeResponsiveData r) {
    final progress = viewModel.completionRate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:  [
            Text(
              'Task Completion Rate',
              style:  GoogleFonts.inter(
                fontSize: r.captionM,
                color: ProfileDesign.textSecondary,
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end:  progress * 100),
              duration: const Duration(milliseconds: 1500),
              curve: Curves. easeOutCubic,
              builder: (context, value, child) {
                return Text(
                  '${value. round()}%',
                  style:  GoogleFonts.inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w700,
                    color: ProfileDesign.primaryTeal,
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: r. nanoPadding),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end:  progress),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder:  (context, value, child) {
            return Stack(
              children: [
                Container(
                  height: r.dimension(8),
                  decoration: BoxDecoration(
                    color: ProfileDesign.surfaceOverlay,
                    borderRadius: BorderRadius.circular(r. pillBorderRadius),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: r.dimension(8),
                    decoration: BoxDecoration(
                      gradient: ProfileDesign.primaryGradient,
                      borderRadius: BorderRadius.circular(r.pillBorderRadius),
                      boxShadow: ProfileDesign. glowShadow(ProfileDesign.primaryTeal),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}