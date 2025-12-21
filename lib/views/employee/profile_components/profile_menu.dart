import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/profile_viewmodel.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class ProfileMenu extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final ProfileViewModel viewModel;
  final VoidCallback onEditProfile;
  final VoidCallback onTaskHistory;
  final VoidCallback onFeedback;
  final VoidCallback onSettings;
  final VoidCallback onHelp;

  const ProfileMenu({
    super.key,
    required this.responsive,
    required this.viewModel,
    required this.onEditProfile,
    required this.onTaskHistory,
    required this.onFeedback,
    required this.onSettings,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.padding),
      child: Container(
        decoration: BoxDecoration(
          color: ProfileDesign.surfacePure,
          borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
          boxShadow: ProfileDesign. softShadow,
        ),
        child: Column(
          children: [
            _buildMenuItem(
              r,
              icon: Icons.edit_rounded,
              label: 'Edit Profile',
              color: ProfileDesign.primaryTeal,
              onTap: onEditProfile,
            ),
            _buildMenuDivider(r),
            _buildMenuItem(
              r,
              icon:  Icons.history_rounded,
              label: 'Task History',
              color: ProfileDesign.purple,
              onTap: onTaskHistory,
            ),
            _buildMenuDivider(r),
            _buildMenuItem(
              r,
              icon: Icons.feedback_rounded,
              label: 'View Feedback',
              color: ProfileDesign.info,
              onTap: onFeedback,
            ),
            _buildMenuDivider(r),
            _buildMenuItem(
              r,
              icon:  Icons.settings_rounded,
              label: 'Settings',
              color: ProfileDesign.textSecondary,
              onTap: onSettings,
            ),
            _buildMenuDivider(r),
            _buildMenuItem(
              r,
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              color: ProfileDesign.success,
              onTap: onHelp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.borderRadius),
        child: Padding(
          padding: EdgeInsets.all(r.padding),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration:  BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r. borderRadius),
                ),
                child: Icon(icon, color: color, size: r.iconSize(20)),
              ),
              SizedBox(width: r.padding),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: r. bodyS,
                    fontWeight: FontWeight.w500,
                    color: ProfileDesign.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: ProfileDesign.textTertiary,
                size: r.iconSize(22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.padding),
      child:  Divider(height: 1, color: ProfileDesign.surfaceOverlay),
    );
  }
}