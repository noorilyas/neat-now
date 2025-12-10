import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// EmployeeUsersTab - Displays user management list
class EmployeeUsersTab extends StatelessWidget {
  final Future<List<User>> usersFuture;
  final VoidCallback onRefresh;
  final EmployeeResponsiveData responsive;

  const EmployeeUsersTab({
    super.key,
    required this.usersFuture,
    required this.onRefresh,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }
        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error. toString());
        }
        return _buildUsersList(context, snapshot.data! );
      },
    );
  }

  Widget _buildUsersList(BuildContext context, List<User> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_rounded,
              size: responsive.dimension(60),
              color: Colors.grey[400],
            ),
            SizedBox(height: responsive.padding),
            Text(
              'No users found',
              style: GoogleFonts.poppins(
                fontSize: responsive.fontSize(16),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: Colors.green,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(responsive.padding),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return _buildUserCard(context, users[index]);
        },
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    final isActive = user. status == 'active';

    return Card(
      margin: EdgeInsets. only(bottom: responsive.padding),
      elevation: responsive.showShadows ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets. all(responsive.padding),
        child: Row(
          children: [
            // Avatar
            Container(
              width: responsive.dimension(50),
              height: responsive.dimension(50),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [Colors.green. shade400, Colors.green. shade600]
                      : [Colors. grey. shade400, Colors. grey.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ?  user.name[0].toUpperCase() : 'U',
                  style: GoogleFonts.poppins(
                    fontSize: responsive.fontSize(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive.padding),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      user.name,
                      style: GoogleFonts.poppins(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight. w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (responsive.showSecondaryText) ...[
                    SizedBox(height: responsive.nanoPadding),
                    Text(
                      user.email,
                      style: GoogleFonts. poppins(
                        fontSize: responsive.fontSize(12),
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow. ellipsis,
                    ),
                  ],
                  if (responsive.showDetailedContent) ...[
                    SizedBox(height: responsive.nanoPadding),
                    Row(
                      children: [
                        Icon(
                          Icons. assignment_rounded,
                          size: responsive.iconSize(12),
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: responsive.nanoPadding),
                        Text(
                          '${user.reportsCount} reports',
                          style: GoogleFonts. poppins(
                            fontSize: responsive.fontSize(10),
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(width: responsive.microPadding),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: responsive. iconSize(12),
                          color: Colors.grey[500],
                        ),
                        SizedBox(width: responsive.nanoPadding),
                        Text(
                          'Joined ${_formatDate(user. joinDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: responsive. fontSize(10),
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Status badge
            if (! responsive.isMicroScreen)
              Container(
                padding: EdgeInsets. symmetric(
                  horizontal: responsive.microPadding,
                  vertical: responsive.nanoPadding,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors. green. withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive. borderRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize. min,
                  children: [
                    Container(
                      width: responsive.dimension(8),
                      height: responsive.dimension(8),
                      decoration: BoxDecoration(
                        color: isActive ?  Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: responsive. nanoPadding),
                    Text(
                      responsive.adaptiveText(
                        user.status.toUpperCase(),
                        tiny: isActive ?  'ON' : 'OFF',
                        nano: isActive ? 'ACT' : 'OFF',
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: responsive.fontSize(10),
                        fontWeight: FontWeight. w600,
                        color: isActive ? Colors.green : Colors. grey,
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

  String _formatDate(DateTime date) {
    if (responsive.isMicroScreen) {
      return '${date.day}/${date.month}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: responsive.dimension(48),
            color: Colors.red,
          ),
          SizedBox(height: responsive.padding),
          Text(
            'Error loading users',
            style: GoogleFonts.poppins(
              fontSize: responsive.fontSize(16),
              fontWeight: FontWeight. w600,
            ),
          ),
          SizedBox(height: responsive.padding),
          ElevatedButton(
            onPressed: onRefresh,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}