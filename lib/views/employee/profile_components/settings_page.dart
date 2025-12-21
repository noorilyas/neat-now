import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/profile_viewmodel.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class SettingsPage extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final ProfileViewModel viewModel;

  const SettingsPage({
    super.key,
    required this.responsive,
    required this. viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Scaffold(
      backgroundColor: ProfileDesign.surfaceLight,
      appBar: AppBar(
        backgroundColor: ProfileDesign.surfacePure,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(r.microPadding),
            decoration:  BoxDecoration(
              color:  ProfileDesign.surfaceLight,
              borderRadius: BorderRadius. circular(r.borderRadius),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ProfileDesign.textPrimary,
              size: r.iconSize(18),
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight.w700,
            color: ProfileDesign.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(r.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications section
            _buildSectionTitle(r, 'Notifications'),
            SizedBox(height:  r.microPadding),
            _buildSettingsCard(r, context, [
              _buildSwitchItem(
                context,
                r,
                icon: Icons.notifications_rounded,
                label: 'Push Notifications',
                subtitle: 'Receive task updates',
                color: ProfileDesign.info,
                value: viewModel.settings.notificationsEnabled,
                onChanged:  (v) => viewModel.toggleSetting('notifications', v),
              ),
              _buildSwitchItem(
                context,
                r,
                icon: Icons.volume_up_rounded,
                label: 'Sound',
                subtitle: 'Play notification sounds',
                color: ProfileDesign.purple,
                value: viewModel. settings.soundEnabled,
                onChanged: (v) => viewModel.toggleSetting('sound', v),
              ),
            ]),

            SizedBox(height: r.padding),

            // Privacy section
            _buildSectionTitle(r, 'Privacy'),
            SizedBox(height: r.microPadding),
            _buildSettingsCard(r, context, [
              _buildSwitchItem(
                context,
                r,
                icon:  Icons.location_on_rounded,
                label: 'Location Services',
                subtitle: 'Allow location access',
                color: ProfileDesign.success,
                value: viewModel. settings.locationEnabled,
                onChanged: (v) => viewModel.toggleSetting('location', v),
              ),
            ]),

            SizedBox(height: r.padding),

            // Appearance section
            _buildSectionTitle(r, 'Appearance'),
            SizedBox(height: r.microPadding),
            _buildSettingsCard(r, context, [
              _buildSwitchItem(
                context,
                r,
                icon: Icons.dark_mode_rounded,
                label: 'Dark Mode',
                subtitle: 'Use dark theme',
                color: ProfileDesign.textSecondary,
                value:  viewModel.settings.darkModeEnabled,
                onChanged:  (v) => viewModel.toggleSetting('darkMode', v),
              ),
            ]),

            SizedBox(height: r.padding),

            // About section
            _buildSectionTitle(r, 'About'),
            SizedBox(height: r.microPadding),
            _buildSettingsCard(r, context, [
              _buildInfoItem(r, 'App Version', '1.0.0'),
              _buildInfoItem(r, 'Build', '2024.12.18'),
            ]),

            SizedBox(height: r.safePaddingBottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(EmployeeResponsiveData r, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: r.captionM,
        fontWeight:  FontWeight.w600,
        color: ProfileDesign.textSecondary,
      ),
    );
  }

  Widget _buildSettingsCard(
      EmployeeResponsiveData r,
      BuildContext context,
      List<Widget> children,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: ProfileDesign.surfacePure,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        boxShadow: ProfileDesign.softShadow,
      ),
      child: Column(
        children: children. asMap().entries.map((entry) {
          final isLast = entry.key == children. length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: r.padding),
                  child: Divider(height: 1, color: ProfileDesign.surfaceOverlay),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSwitchItem(
      BuildContext context,
      EmployeeResponsiveData r, {
        required IconData icon,
        required String label,
        required String subtitle,
        required Color color,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    return Padding(
      padding: EdgeInsets.all(r.padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius. circular(r.borderRadius),
            ),
            child: Icon(icon, color: color, size: r.iconSize(20)),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts. inter(
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w600,
                    color: ProfileDesign.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts. inter(
                    fontSize: r.captionS,
                    color: ProfileDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v);
            },
            activeColor: ProfileDesign.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(EmployeeResponsiveData r, String label, String value) {
    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:  [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              color: ProfileDesign.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: r.bodyS,
              fontWeight: FontWeight.w600,
              color: ProfileDesign.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}