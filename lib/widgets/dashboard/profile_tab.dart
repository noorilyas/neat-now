import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/widgets/dashboard/responsive_helper.dart';
import 'package:neat_now/widgets/dashboard/components/section_header.dart';

/// ProfileTab - User profile and settings
/// Implements FR-U1: Profile Management
class ProfileTab extends StatelessWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic> userStats;
  final bool isDemoMode;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdate;
  final ResponsiveData responsive;

  const ProfileTab({
    super. key,
    required this.userData,
    required this.userStats,
    required this.isDemoMode,
    required this.onLogout,
    required this. onProfileUpdate,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(responsive.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                SizedBox(height: responsive.largePadding),
                _buildStatsOverview(),
                SizedBox(height: responsive.largePadding),
                _buildProfileMenu(context),
                SizedBox(height: responsive.largePadding),
                _buildAccountSettings(context),
                SizedBox(height: responsive.largePadding),
                _buildAboutSection(context),
                SizedBox(height: responsive.dimension(80)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: responsive.isMicroScreen
          ? 60.0
          : responsive.isNanoScreen
          ? 80.0
          : responsive.dimension(140) + responsive.safePaddingTop,
      pinned: true,
      backgroundColor: const Color(0xFF1B5E20),
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A3D2C),
                Color(0xFF1B5E20),
                Color(0xFF2E7D32),
              ],
            ),
          ),
          child: SafeArea(
              child: Padding(
                  padding: EdgeInsets.all(responsive.padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment. centerLeft,
                          child: Text(
                            responsive.adaptiveText(
                              'My Profile',
                              micro: '👤',
                              nano: 'Me',
                              mini: 'Profile',
                            ),
                            style: GoogleFonts. poppins(
                              fontSize: responsive.fontSize(24),
                              fontWeight: FontWeight. bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (isDemoMode)
                        Container(
                          padding: EdgeInsets. symmetric(
                            horizontal: responsive.microPadding,
                            vertical: responsive. nanoPadding,
                          ),
                          decoration: BoxDecoration(
                            color: Colors. orange.withOpacity(0.2),
                            borderRadius: BorderRadius. circular(responsive.borderRadius),
                          ),
                          child: Text(
                            '🔧 Demo',
                            style: GoogleFonts. poppins(
                              fontSize: responsive.fontSize(10),
                              color: Colors.orange[200],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (responsive.showSecondaryText) ...[
              SizedBox(height: responsive.microPadding),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Manage your account & settings',
              style: GoogleFonts.poppins(
                fontSize: responsive.fontSize(12),
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          ],
          ],
        ),
      ),
    ),
    ),
    ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
        children: [
    // Avatar
    Container(
    width: responsive. dimension(100),
    height: responsive.dimension(100),
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    ),
    shape: BoxShape. circle,
    boxShadow: responsive.showShadows
    ? [
    BoxShadow(
    color: const Color(0xFF4CAF50).withOpacity(0.3),
    blurRadius: responsive.dimension(15),
    offset: const Offset(0, 5),
    ),
    ]
        : [],
    ),
    child: Center(
    child: Text(
    userStats['userName'].toString().isNotEmpty
    ? userStats['userName']. toString(). split(' ')[0][0].toUpperCase()
        : 'U',
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(40),
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    ),
    ),
    SizedBox(height: responsive.padding),

    // Name
    FittedBox(
    fit: BoxFit. scaleDown,
    child: Text(
    userStats['userName'],
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(20),
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    ),
    SizedBox(height: responsive.microPadding),

    // Level badge
    Container(
    padding: EdgeInsets. symmetric(
    horizontal: responsive.padding,
    vertical: responsive.microPadding,
    ),
    decoration: BoxDecoration(
    gradient: const LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    ),
    borderRadius: BorderRadius. circular(responsive.dimension(20)),
    ),
    child: FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
    userStats['level'],
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(14),
    fontWeight: FontWeight. w600,
    color: Colors.white,
    ),
    ),
    ),
    ),

    if (responsive.showSecondaryText) ...[
    SizedBox(height: responsive.microPadding),
    FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
    'Rank #${userStats['rank']} • ${userStats['points']} points',
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(12),
    color: Colors.grey[600],
    ),
    ),
    ),
    ],

    // Email
    if (userData['email'] != null && responsive.showSecondaryText) ...[
    SizedBox(height: responsive.microPadding),
    Text(
    userData['email'],
    style: GoogleFonts.poppins(
    fontSize: responsive.fontSize(11),
    color: Colors.grey[500],
    ),
    ),
    ],
    ],
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        boxShadow: responsive.showShadows
            ?  [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: responsive. dimension(10),
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets. all(responsive.padding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatBox('Reports', userStats['totalReports']. toString(), Colors.blue),
            _buildStatDivider(),
            _buildStatBox('Resolved', userStats['resolved'].toString(), Colors. green),
            _buildStatDivider(),
            _buildStatBox('Pending', userStats['pending'].toString(), Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts. poppins(
                fontSize: responsive. fontSize(22),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          SizedBox(height: responsive.nanoPadding),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              responsive.adaptiveText(
                label,
                micro: label.substring(0, 1),
                nano: label.substring(0, 3),
              ),
              style: GoogleFonts. poppins(
                fontSize: responsive. fontSize(11),
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: responsive.dimension(40),
      color: Colors.grey. withOpacity(0.2),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    final menuItems = [
      {'icon': Icons.edit_rounded, 'title': 'Edit Profile', 'subtitle': 'Update your information', 'action': 'edit'},
      {'icon': Icons. location_on_rounded, 'title': 'Saved Locations', 'subtitle': 'Manage favorite areas', 'action': 'locations'},
      {'icon': Icons.language_rounded, 'title': 'Language', 'subtitle': 'Change language', 'action': 'language'},
      {'icon': Icons.notifications_rounded, 'title': 'Notifications', 'subtitle': 'Manage alerts', 'action': 'notifications'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Settings',
          micro: '⚙️',
          nano: 'Set',
          responsive: responsive,
        ),
        SizedBox(height: responsive.padding),
        ... menuItems.map((item) => Padding(
          padding: EdgeInsets.only(bottom: responsive.microPadding),
          child: _buildMenuItem(
            context,
            icon: item['icon'] as IconData,
            title: item['title'] as String,
            subtitle: item['subtitle'] as String,
            onTap: () => _handleMenuAction(context, item['action'] as String),
          ),
        )),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius. circular(responsive.borderRadius),
        border: Border.all(color: Colors.grey. withOpacity(0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius. circular(responsive.borderRadius),
          child: Padding(
            padding: EdgeInsets.all(responsive.padding * 0.8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets. all(responsive.microPadding),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50). withOpacity(0.1),
                    borderRadius: BorderRadius.circular(responsive.borderRadius),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4CAF50),
                    size: responsive.iconSize(20),
                  ),
                ),
                SizedBox(width: responsive.padding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: responsive. fontSize(14),
                            fontWeight: FontWeight. w600,
                            color: Colors. black87,
                          ),
                        ),
                      ),
                      if (responsive.showSecondaryText)
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: responsive.fontSize(11),
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (responsive.showDetailedContent)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: responsive.iconSize(16),
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Account',
          micro: '🔐',
          nano: 'Acc',
          responsive: responsive,
        ),
        SizedBox(height: responsive. padding),
        _buildToggleSetting('Two-Factor Auth', 'Secure your account', false),
        SizedBox(height: responsive. microPadding),
        _buildToggleSetting('Email Updates', 'Receive notifications', true),
        SizedBox(height: responsive.microPadding),
        _buildToggleSetting('Public Profile', 'Show on leaderboard', true),
      ],
    );
  }

  Widget _buildToggleSetting(String title, String subtitle, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isEnabled = initialValue;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(responsive.borderRadius),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Padding(
            padding: EdgeInsets. all(responsive.padding * 0.8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment. start,
                    children: [
                      FittedBox(
                        fit: BoxFit. scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: responsive.fontSize(14),
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (responsive.showSecondaryText)
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: responsive. fontSize(11),
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: responsive.isMicroScreen ? 0.7 : 0.9,
                  child: Switch(
                    value: isEnabled,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => isEnabled = value);
                    },
                    activeColor: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Help & Support',
          micro: '❓',
          nano: 'Help',
          responsive: responsive,
        ),
        SizedBox(height: responsive. padding),
        _buildHelpItem(context, 'About App', Icons.info_rounded),
        SizedBox(height: responsive.microPadding),
        _buildHelpItem(context, 'Privacy Policy', Icons.privacy_tip_rounded),
        SizedBox(height: responsive. microPadding),
        _buildHelpItem(context, 'Terms of Service', Icons.description_rounded),
        SizedBox(height: responsive.microPadding),
        _buildHelpItem(context, 'Contact Us', Icons.email_rounded),
        SizedBox(height: responsive.largePadding),

        // Logout button
        _buildLogoutButton(context),

        // Version info
        SizedBox(height: responsive.padding),
        Center(
          child: Text(
            'Version 1.0. 0',
            style: GoogleFonts.poppins(
              fontSize: responsive.fontSize(11),
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem(BuildContext context, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border.all(color: Colors.grey. withOpacity(0.15)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback. lightImpact();
            _showInfoDialog(context, title);
          },
          borderRadius: BorderRadius.circular(responsive.borderRadius),
          child: Padding(
            padding: EdgeInsets.all(responsive.padding * 0.8),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF4CAF50),
                  size: responsive.iconSize(20),
                ),
                SizedBox(width: responsive.padding),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: responsive.fontSize(14),
                      fontWeight: FontWeight. w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: responsive.iconSize(16),
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.red. withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive. borderRadius),
        border: Border.all(color: Colors. red.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors. transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(responsive.borderRadius),
          child: Padding(
            padding: EdgeInsets.all(responsive. padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: responsive.iconSize(20),
                ),
                SizedBox(width: responsive. microPadding),
                Text(
                  'Logout',
                  style: GoogleFonts. poppins(
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'edit':
        _showEditProfileDialog(context);
        break;
      case 'locations':
      case 'language':
      case 'notifications':
        _showComingSoonDialog(context, action);
        break;
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: userStats['userName']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.largeBorderRadius),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight. bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator. pop(context);
              onProfileUpdate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title) {
    final content = {
      'About App': 'Neat Now helps communities track and manage waste efficiently using AI detection technology.',
      'Privacy Policy': 'Your data is encrypted and protected.  We never share your personal information with third parties.',
      'Terms of Service': 'By using this app, you agree to report waste responsibly and help keep our community clean.',
      'Contact Us': 'Email: support@neatnow.com\nPhone: +1-800-NEAT-NOW\nWebsite: www.neatnow.com',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius. circular(responsive.largeBorderRadius),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          content[title] ?? 'Information not available.',
          style: GoogleFonts.poppins(fontSize: responsive.fontSize(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadius),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive. largeBorderRadius),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts. poppins(fontWeight: FontWeight. bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}