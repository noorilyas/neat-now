import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/profile_viewmodel.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class TaskHistoryPage extends StatefulWidget {
  final EmployeeResponsiveData responsive;
  final ProfileViewModel viewModel;

  const TaskHistoryPage({
    super.key,
    required this.responsive,
    required this.viewModel,
  });

  @override
  State<TaskHistoryPage> createState() => _TaskHistoryPageState();
}

class _TaskHistoryPageState extends State<TaskHistoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve:  Curves.easeOutCubic);
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
    final tasks = widget.viewModel.taskHistory;

    return Scaffold(
      backgroundColor: ProfileDesign.surfaceLight,
      appBar: AppBar(
        backgroundColor: ProfileDesign.surfacePure,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: ProfileDesign.surfaceLight,
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ProfileDesign.textPrimary,
              size: r.iconSize(18),
            ),
          ),
        ),
        title: Text(
          'Task History',
          style: GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight.w700,
            color: ProfileDesign.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity:  _fadeAnimation,
        child:  tasks.isEmpty
            ? _buildEmptyState(r)
            : ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(r.padding),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return _buildTaskCard(r, tasks[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(r.largePadding),
            decoration:  BoxDecoration(
              color:  ProfileDesign.purple. withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: ProfileDesign.purple,
              size: r.iconSize(48),
            ),
          ),
          SizedBox(height: r.padding),
          Text(
            'No task history',
            style: GoogleFonts.inter(
              fontSize: r.bodyM,
              fontWeight: FontWeight.w600,
              color: ProfileDesign.textPrimary,
            ),
          ),
          SizedBox(height: r.nanoPadding),
          Text(
            'Completed tasks will appear here',
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: ProfileDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(EmployeeResponsiveData r, dynamic task, int index) {
    return TweenAnimationBuilder<double>(
      tween:  Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder:  (context, value, child) {
        return Transform. translate(
          offset: Offset(0, 20 * (1 - value)),
          child:  Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: r.microPadding),
        padding: EdgeInsets.all(r.padding),
        decoration: BoxDecoration(
          color: ProfileDesign.surfacePure,
          borderRadius: BorderRadius.circular(r.largeBorderRadius),
          boxShadow: ProfileDesign.softShadow,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: ProfileDesign.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: ProfileDesign.success,
                size: r.iconSize(24),
              ),
            ),

            SizedBox(width: r.microPadding),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.type,
                    style: GoogleFonts.inter(
                      fontSize: r.bodyS,
                      fontWeight: FontWeight.w700,
                      color: ProfileDesign.textPrimary,
                    ),
                  ),
                  SizedBox(height:  r.atomicPadding),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: r.iconSize(12),
                        color: ProfileDesign.textTertiary,
                      ),
                      SizedBox(width:  r.atomicPadding),
                      Expanded(
                        child: Text(
                          task.location,
                          style: GoogleFonts.inter(
                            fontSize: r.captionS,
                            color: ProfileDesign.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.atomicPadding),
                  Text(
                    widget.viewModel.formatDate(task.completedAt),
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      color: ProfileDesign.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Rating
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.microPadding,
                vertical: r. nanoPadding,
              ),
              decoration: BoxDecoration(
                color: ProfileDesign.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: r.iconSize(14),
                    color: ProfileDesign.gold,
                  ),
                  SizedBox(width: r.atomicPadding),
                  Text(
                    task.rating.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: r.captionM,
                      fontWeight: FontWeight.w700,
                      color: ProfileDesign.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}