import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NotificationSettings - Manage notification preferences (FR-W3)
class NotificationSettings extends StatefulWidget {
  final EmployeeResponsiveData responsive;

  const NotificationSettings({
    super.key,
    required this.responsive,
  });

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _isLoading = true;

  // Notification preferences
  bool _enableAllNotifications = true;
  bool _enableTaskAssignments = true;
  bool _enableProximityTasks = true;
  bool _enableUrgentTasks = true;
  bool _enableVerificationResults = true;
  bool _enableBadgeEarned = true;
  bool _enableSound = true;
  bool _enableVibration = true;
  bool _enableQuietHours = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);
  double _proximityRadius = 5.0; // km

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _enableAllNotifications = prefs. getBool('notif_all') ?? true;
      _enableTaskAssignments = prefs. getBool('notif_task_assignments') ?? true;
      _enableProximityTasks = prefs.getBool('notif_proximity_tasks') ?? true;
      _enableUrgentTasks = prefs.getBool('notif_urgent_tasks') ??  true;
      _enableVerificationResults = prefs.getBool('notif_verification') ?? true;
      _enableBadgeEarned = prefs.getBool('notif_badges') ?? true;
      _enableSound = prefs.getBool('notif_sound') ?? true;
      _enableVibration = prefs. getBool('notif_vibration') ??  true;
      _enableQuietHours = prefs.getBool('notif_quiet_hours') ??  false;
      _proximityRadius = prefs.getDouble('proximity_radius') ?? 5.0;

      final quietStartHour = prefs. getInt('quiet_start_hour') ?? 22;
      final quietStartMinute = prefs.getInt('quiet_start_minute') ?? 0;
      final quietEndHour = prefs.getInt('quiet_end_hour') ?? 7;
      final quietEndMinute = prefs.getInt('quiet_end_minute') ?? 0;

      _quietHoursStart = TimeOfDay(hour: quietStartHour, minute: quietStartMinute);
      _quietHoursEnd = TimeOfDay(hour: quietEndHour, minute: quietEndMinute);

      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences. getInstance();

    await prefs.setBool('notif_all', _enableAllNotifications);
    await prefs.setBool('notif_task_assignments', _enableTaskAssignments);
    await prefs.setBool('notif_proximity_tasks', _enableProximityTasks);
    await prefs. setBool('notif_urgent_tasks', _enableUrgentTasks);
    await prefs.setBool('notif_verification', _enableVerificationResults);
    await prefs.setBool('notif_badges', _enableBadgeEarned);
    await prefs.setBool('notif_sound', _enableSound);
    await prefs. setBool('notif_vibration', _enableVibration);
    await prefs.setBool('notif_quiet_hours', _enableQuietHours);
    await prefs.setDouble('proximity_radius', _proximityRadius);
    await prefs.setInt('quiet_start_hour', _quietHoursStart.hour);
    await prefs.setInt('quiet_start_minute', _quietHoursStart. minute);
    await prefs.setInt('quiet_end_hour', _quietHoursEnd.hour);
    await prefs.setInt('quiet_end_minute', _quietHoursEnd.minute);
  }

  void _updatePreference(String key, bool value) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (key) {
        case 'all':
          _enableAllNotifications = value;
          if (! value) {
            _enableTaskAssignments = false;
            _enableProximityTasks = false;
            _enableUrgentTasks = false;
            _enableVerificationResults = false;
            _enableBadgeEarned = false;
          }
          break;
        case 'task_assignments':
          _enableTaskAssignments = value;
          break;
        case 'proximity_tasks':
          _enableProximityTasks = value;
          break;
        case 'urgent_tasks':
          _enableUrgentTasks = value;
          break;
        case 'verification':
          _enableVerificationResults = value;
          break;
        case 'badges':
          _enableBadgeEarned = value;
          break;
        case 'sound':
          _enableSound = value;
          break;
        case 'vibration':
          _enableVibration = value;
          break;
        case 'quiet_hours':
          _enableQuietHours = value;
          break;
      }
    });
    _savePreferences();
  }

  Future<void> _selectTime(bool isStart) async {
    final initialTime = isStart ? _quietHoursStart : _quietHoursEnd;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2AC2AB),
            ),
          ),
          child: child! ,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        if (isStart) {
          _quietHoursStart = selectedTime;
        } else {
          _quietHoursEnd = selectedTime;
        }
      });
      _savePreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors. white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: Colors.grey. withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              Icons. arrow_back_ios_new_rounded,
              size: r.iconSize(18),
              color: Colors.grey[800],
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification Settings',
          style: GoogleFonts.poppins(
            fontSize: r.fontSize(18),
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
      ),
      body: _isLoading
          ?  Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF2AC2AB),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(r.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master toggle
            _buildMasterToggle(r),
            SizedBox(height: r.padding),

            // Task Notifications section
            _buildSection(
              r,
              title: 'Task Notifications',
              icon: Icons.assignment_rounded,
              iconColor: Colors.blue,
              children: [
                _buildToggleTile(
                  r,
                  title: 'Task Assignments',
                  subtitle: 'Notifications for tasks assigned by administrator',
                  icon: Icons.assignment_ind_rounded,
                  value: _enableTaskAssignments,
                  onChanged: (v) => _updatePreference('task_assignments', v),
                  enabled: _enableAllNotifications,
                  isImportant: true,
                ),
                _buildToggleTile(
                  r,
                  title: 'Proximity Tasks',
                  subtitle: 'Notifications for tasks near your location',
                  icon: Icons.location_on_rounded,
                  value: _enableProximityTasks,
                  onChanged: (v) => _updatePreference('proximity_tasks', v),
                  enabled: _enableAllNotifications,
                ),
                _buildToggleTile(
                  r,
                  title: 'Urgent Tasks',
                  subtitle: 'High priority and hazardous waste alerts',
                  icon: Icons.warning_rounded,
                  value: _enableUrgentTasks,
                  onChanged: (v) => _updatePreference('urgent_tasks', v),
                  enabled: _enableAllNotifications,
                  isImportant: true,
                ),
              ],
            ),
            SizedBox(height: r.padding),

            // Status Notifications section
            _buildSection(
              r,
              title: 'Status Notifications',
              icon: Icons.notifications_rounded,
              iconColor: Colors.green,
              children: [
                _buildToggleTile(
                  r,
                  title: 'Verification Results',
                  subtitle: 'AI cleanup verification results',
                  icon: Icons.verified_rounded,
                  value: _enableVerificationResults,
                  onChanged: (v) => _updatePreference('verification', v),
                  enabled: _enableAllNotifications,
                ),
                _buildToggleTile(
                  r,
                  title: 'Badge Earned',
                  subtitle: 'Performance badges and achievements',
                  icon: Icons.military_tech_rounded,
                  value: _enableBadgeEarned,
                  onChanged: (v) => _updatePreference('badges', v),
                  enabled: _enableAllNotifications,
                ),
              ],
            ),
            SizedBox(height: r.padding),

            // Proximity Settings section
            _buildSection(
              r,
              title: 'Proximity Settings',
              icon: Icons.radar_rounded,
              iconColor: Colors.orange,
              children: [
                _buildProximityRadiusSlider(r),
              ],
            ),
            SizedBox(height: r.padding),

            // Sound & Vibration section
            _buildSection(
              r,
              title: 'Sound & Vibration',
              icon: Icons.volume_up_rounded,
              iconColor: Colors.purple,
              children: [
                _buildToggleTile(
                  r,
                  title: 'Sound',
                  subtitle: 'Play notification sounds',
                  icon: Icons. volume_up_rounded,
                  value: _enableSound,
                  onChanged: (v) => _updatePreference('sound', v),
                  enabled: _enableAllNotifications,
                ),
                _buildToggleTile(
                  r,
                  title: 'Vibration',
                  subtitle: 'Vibrate for notifications',
                  icon: Icons.vibration_rounded,
                  value: _enableVibration,
                  onChanged: (v) => _updatePreference('vibration', v),
                  enabled: _enableAllNotifications,
                ),
              ],
            ),
            SizedBox(height: r.padding),

            // Quiet Hours section
            _buildSection(
              r,
              title: 'Quiet Hours',
              icon: Icons.bedtime_rounded,
              iconColor: Colors.indigo,
              children: [
                _buildToggleTile(
                  r,
                  title: 'Enable Quiet Hours',
                  subtitle: 'Mute notifications during specified hours',
                  icon: Icons.bedtime_rounded,
                  value: _enableQuietHours,
                  onChanged: (v) => _updatePreference('quiet_hours', v),
                  enabled: _enableAllNotifications,
                ),
                if (_enableQuietHours) _buildQuietHoursSelector(r),
              ],
            ),

            SizedBox(height: r. dimension(100)),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterToggle(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _enableAllNotifications
              ? [const Color(0xFF2AC2AB), const Color(0xFF1FA896)]
              : [Colors.grey, Colors.grey. shade600],
        ),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: (_enableAllNotifications ?  const Color(0xFF2AC2AB) : Colors.grey)
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: Colors.white. withOpacity(0.2),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              _enableAllNotifications
                  ? Icons. notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: Colors.white,
              size: r.iconSize(28),
            ),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(16),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _enableAllNotifications ?  'Enabled' : 'Disabled',
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(12),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enableAllNotifications,
            onChanged: (v) => _updatePreference('all', v),
            activeColor: Colors.white,
            activeTrackColor: Colors. white.withOpacity(0.4),
            inactiveThumbColor: Colors. white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      EmployeeResponsiveData r, {
        required String title,
        required IconData icon,
        required Color iconColor,
        required List<Widget> children,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        boxShadow: r.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.all(r.padding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets. all(r.microPadding),
                  decoration: BoxDecoration(
                    color: iconColor. withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                  child: Icon(icon, color: iconColor, size: r. iconSize(20)),
                ),
                SizedBox(width: r.microPadding),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(15),
                    fontWeight: FontWeight. bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey. withOpacity(0.1)),

          // Section content
          ... children,
        ],
      ),
    );
  }

  Widget _buildToggleTile(
      EmployeeResponsiveData r, {
        required String title,
        required String subtitle,
        required IconData icon,
        required bool value,
        required ValueChanged<bool> onChanged,
        bool enabled = true,
        bool isImportant = false,
      }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: EdgeInsets. symmetric(
          horizontal: r. padding,
          vertical: r.microPadding,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: r.iconSize(20),
              color: isImportant ? Colors.red : Colors.grey[600],
            ),
            SizedBox(width: r. padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: r.fontSize(14),
                          fontWeight: FontWeight. w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (isImportant) ...[
                        SizedBox(width: r.nanoPadding),
                        Container(
                          padding: EdgeInsets. symmetric(
                            horizontal: r.nanoPadding + 2,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(r.smallBorderRadius),
                          ),
                          child: Text(
                            'Important',
                            style: GoogleFonts.poppins(
                              fontSize: r.fontSize(8),
                              fontWeight: FontWeight. bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: r.fontSize(11),
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value && enabled,
              onChanged: enabled ? onChanged : null,
              activeColor: const Color(0xFF2AC2AB),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProximityRadiusSlider(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets. all(r.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar_rounded, size: r. iconSize(20), color: Colors.orange),
              SizedBox(width: r.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proximity Radius',
                      style: GoogleFonts. poppins(
                        fontSize: r.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      'Receive notifications for tasks within this distance',
                      style: GoogleFonts.poppins(
                        fontSize: r.fontSize(11),
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.microPadding,
                  vertical: r.nanoPadding,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Text(
                  '${_proximityRadius.toStringAsFixed(1)} km',
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(13),
                    fontWeight: FontWeight. bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors. orange,
              inactiveTrackColor: Colors.orange. withOpacity(0.2),
              thumbColor: Colors.orange,
              overlayColor: Colors. orange.withOpacity(0.2),
            ),
            child: Slider(
              value: _proximityRadius,
              min: 1.0,
              max: 20.0,
              divisions: 19,
              onChanged: _enableAllNotifications && _enableProximityTasks
                  ? (value) {
                setState(() => _proximityRadius = value);
                _savePreferences();
              }
                  : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 km', style: GoogleFonts. poppins(fontSize: r.fontSize(10), color: Colors.grey[500])),
              Text('20 km', style: GoogleFonts.poppins(fontSize: r.fontSize(10), color: Colors.grey[500])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSelector(EmployeeResponsiveData r) {
    return Padding(
      padding: EdgeInsets.all(r. padding),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeButton(
              r,
              label: 'Start',
              time: _quietHoursStart,
              onTap: () => _selectTime(true),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r. microPadding),
            child: Icon(Icons.arrow_forward_rounded, color: Colors.grey[400]),
          ),
          Expanded(
            child: _buildTimeButton(
              r,
              label: 'End',
              time: _quietHoursEnd,
              onTap: () => _selectTime(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(
      EmployeeResponsiveData r, {
        required String label,
        required TimeOfDay time,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          color: Colors.indigo. withOpacity(0.05),
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: Border.all(color: Colors.indigo. withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: r.fontSize(11),
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              time. format(context),
              style: GoogleFonts.poppins(
                fontSize: r.fontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}