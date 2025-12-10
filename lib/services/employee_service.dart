import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/employee_models.dart';

/// EmployeeService - Handles all employee/worker API operations
/// Complete implementation with analytics, reports, and location support
class EmployeeService {
  static const String _baseUrl = 'https://api.neatnow.com/api';
  static const Duration _timeout = Duration(seconds: 15);
  static bool _isDemoMode = true;

  // ==================== DEMO DATA ====================
  /// Update report status with verification data
  static Future<bool> updateReportStatus(
      int reportId,
      String status, {
        String? verificationImagePath,
        double? latitude,
        double?  longitude,
        String? locationAddress,
      }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        debugPrint('No auth token found');
        return false;
      }

      // Prepare multipart request if we have an image
      if (verificationImagePath != null && status == 'resolved') {
        final uri = Uri.parse('$_baseUrl/reports/$reportId/resolve');
        final request = http.MultipartRequest('POST', uri);

        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';

        // Add image file
        final imageFile = await http.MultipartFile.fromPath(
          'verification_image',
          verificationImagePath,
        );
        request. files.add(imageFile);

        // Add other fields
        request.fields['status'] = status;
        request. fields['resolved_at'] = DateTime.now().toIso8601String();

        if (latitude != null) {
          request.fields['resolution_latitude'] = latitude. toString();
        }
        if (longitude != null) {
          request.fields['resolution_longitude'] = longitude.toString();
        }
        if (locationAddress != null) {
          request.fields['resolution_address'] = locationAddress;
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('Report $reportId resolved successfully');
          return true;
        } else {
          debugPrint('Failed to resolve report: ${response.statusCode}');
          debugPrint('Response: ${response.body}');
          return false;
        }
      } else {
        // Simple status update without image
        final response = await http.patch(
          Uri. parse('$_baseUrl/reports/$reportId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'status': status,
            'updated_at': DateTime. now().toIso8601String(),
          }),
        );

        return response.statusCode == 200;
      }
    } catch (e) {
      debugPrint('Error updating report status: $e');
      return false;
    }
  }
  static final Map<String, dynamic> _demoStats = {
    'total_reports': 101,
    'resolved_reports': 89,
    'pending_reports': 8,
    'in_progress_reports': 4,
    'resolution_rate': 88.1,
    'avg_resolution_time': 4.5,
    'this_week_resolved': 12,
    'this_month_resolved': 45,
  };

  static final Map<String, dynamic> _demoAnalytics = {
    'total_reports': 156,
    'resolved_reports': 134,
    'pending_reports': 15,
    'in_progress_reports': 7,
    'resolution_rate': 85.9,
    'growth_rate': 12.5,
    'avg_resolution_time_hours': 3.2,
  'reports_over_time': {
  'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
  'data': [18, 25, 22, 30, 28, 33],
  },
  'waste_distribution': {
  'Plastic Waste': 45,
  'Organic Waste': 32,
  'Electronic Waste': 18,
  'Hazardous Waste': 12,
  'Mixed Waste': 25,
  'Construction Debris': 14,
  'Medical Waste': 10,
  },
  'top_locations': [
  {'name': 'Main Street, Block A', 'reports': 28},
  {'name': 'Central Park Area', 'reports': 22},
  {'name': 'Industrial Zone', 'reports': 18},
  {'name': 'Beach Front', 'reports': 15},
  {'name': 'Residential Block C', 'reports': 12},
  ],
  'daily_activity': {
  'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  'resolved': [5, 8, 6, 9, 7, 4, 3],
  'reported': [6, 7, 8, 6, 9, 5, 4],
  },
  'performance_metrics': {
  'efficiency_score': 92.5,
  'response_time_avg': 2.3,
  'customer_satisfaction': 4.7,
  'tasks_per_day_avg': 6.2,
  },
  'monthly_comparison': {
  'current_month': 45,
  'previous_month': 40,
  'change_percentage': 12.5,
  },
};

static final List<Map<String, dynamic>> _demoReports = [
  {
    'id': 1,
    'type': 'Plastic Waste',
    'location': 'Main Street, Block A, Near Central Plaza',
    'status': 'pending',
    'user_name': 'John Doe',
    'user_id': 1,
    'date': DateTime.now().subtract(const Duration(hours: 2)). toIso8601String(),
    'description': 'Large pile of plastic bottles and packaging materials near the bus stop.',
    'image_url': 'https://images.unsplash. com/photo-1604187351574-c75ca79f5807?w=800',
    'latitude': 33.6844,
    'longitude': 73.0479,
    'ai_confidence': 0.94,
  },
  {
    'id': 2,
    'type': 'Organic Waste',
    'location': 'Central Park, Zone 3, Near Fountain',
    'status': 'in-progress',
    'user_name': 'Jane Smith',
    'user_id': 2,
    'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    'description': 'Decomposing food waste and garden debris scattered around the picnic area.',
    'image_url': 'https://images.unsplash. com/photo-1532996122724-e3c354a0b15b?w=800',
    'latitude': 33.7294,
    'longitude': 73.0931,
    'ai_confidence': 0.89,
    'assigned_to': 'Worker #1',
  },
  {
    'id': 3,
    'type': 'Electronic Waste',
    'location': 'Tech Hub, Building 5, Parking Lot',
    'status': 'resolved',
    'user_name': 'Mike Johnson',
    'user_id': 3,
    'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    'description': 'Old computer parts, monitors, and cables dumped illegally.',
    'image_url': 'https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?w=800',
    'latitude': 33.6995,
    'longitude': 73.0363,
    'ai_confidence': 0.97,
    'resolved_at': DateTime. now().subtract(const Duration(days: 1)).toIso8601String(),
    'resolved_by': 'Worker #2',
    'verification_image': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
  },
  {
    'id': 4,
    'type': 'Hazardous Waste',
    'location': 'Industrial Area, Sector 7, Gate 3',
    'status': 'pending',
    'user_name': 'Sarah Wilson',
    'user_id': 4,
    'date': DateTime.now(). subtract(const Duration(hours: 5)).toIso8601String(),
    'description': 'Chemical containers and paint cans found near drainage system.  Urgent! ',
    'image_url': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
    'latitude': 33.6539,
    'longitude': 73.0674,
    'ai_confidence': 0.91,
  },
  {
    'id': 5,
    'type': 'Mixed Waste',
    'location': 'Residential Block C, Street 12',
    'status': 'resolved',
    'user_name': 'Tom Brown',
    'user_id': 5,
    'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    'description': 'General household waste overflowing from community bins.',
    'image_url': 'https://images. unsplash.com/photo-1591198936750-16d8e15edc57?w=800',
    'latitude': 33.7103,
    'longitude': 73.0582,
    'ai_confidence': 0.86,
    'resolved_at': DateTime. now().subtract(const Duration(days: 2)).toIso8601String(),
    'resolved_by': 'Worker #1',
  },
  {
    'id': 6,
    'type': 'Plastic Waste',
    'location': 'Beach Area, Section 2, Near Lifeguard Tower',
    'status': 'pending',
    'user_name': 'Emily Davis',
    'user_id': 6,
    'date': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
    'description': 'Plastic bags, bottles, and fishing nets washed up on the shore.',
    'image_url': 'https://images.unsplash.com/photo-1621451537084-482c73073a0f?w=800',
    'latitude': 33.6432,
    'longitude': 73.0123,
    'ai_confidence': 0.93,
  },
  {
    'id': 7,
    'type': 'Construction Debris',
    'location': 'New Development Site, Plot 45',
    'status': 'in-progress',
    'user_name': 'Robert Chen',
    'user_id': 7,
    'date': DateTime.now(). subtract(const Duration(hours: 12)).toIso8601String(),
    'description': 'Concrete rubble, broken tiles, and construction materials on public road.',
    'image_url': 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
    'latitude': 33.6721,
    'longitude': 73.0892,
    'ai_confidence': 0.88,
    'assigned_to': 'Worker #3',
  },
  {
    'id': 8,
    'type': 'Medical Waste',
    'location': 'Hospital Road, Behind Clinic',
    'status': 'pending',
    'user_name': 'Lisa Martinez',
    'user_id': 8,
    'date': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    'description': 'Improperly disposed medical supplies found.  Immediate attention required! ',
    'image_url': 'https://images.unsplash.com/photo-1584634731339-252c581abfc5?w=800',
    'latitude': 33.7012,
    'longitude': 73.0445,
    'ai_confidence': 0.95,
  },
  {
    'id': 9,
    'type': 'Organic Waste',
    'location': 'Farmers Market, Stall Area B',
    'status': 'resolved',
    'user_name': 'David Kim',
    'user_id': 9,
    'date': DateTime.now(). subtract(const Duration(days: 4)).toIso8601String(),
    'description': 'Rotting vegetables and fruit waste left after market closing.',
    'image_url': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
    'latitude': 33.6890,
    'longitude': 73.0234,
    'ai_confidence': 0.92,
    'resolved_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    'resolved_by': 'Worker #1',
  },
  {
    'id': 10,
    'type': 'Electronic Waste',
    'location': 'Shopping Mall Basement, Loading Dock',
    'status': 'in-progress',
    'user_name': 'Amanda White',
    'user_id': 10,
    'date': DateTime.now(). subtract(const Duration(hours: 6)).toIso8601String(),
    'description': 'Discarded appliances and electronic equipment found.',
    'image_url': 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=800',
    'latitude': 33.7156,
    'longitude': 73.0678,
    'ai_confidence': 0.90,
    'assigned_to': 'Worker #2',
  },
];

static final List<Map<String, dynamic>> _demoNotifications = [
  {
    'id': 1,
    'title': 'New Report Assigned',
    'message': 'Plastic waste report #8 has been assigned to you',
    'time': DateTime.now(). subtract(const Duration(minutes: 5)).toIso8601String(),
    'read': false,
    'type': 'assignment',
  },
  {
    'id': 2,
    'title': 'Urgent: Hazardous Waste',
    'message': 'High priority report needs immediate attention',
    'time': DateTime. now().subtract(const Duration(hours: 1)).toIso8601String(),
    'read': false,
    'type': 'urgent',
  },
  {
    'id': 3,
    'title': 'Report Verified',
    'message': 'Your resolved report #3 has been verified by admin',
    'time': DateTime.now(). subtract(const Duration(hours: 2)).toIso8601String(),
    'read': true,
    'type': 'verification',
  },
  {
    'id': 4,
    'title': 'Weekly Summary',
    'message': 'You resolved 5 reports this week.  Great work!',
    'time': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    'read': true,
    'type': 'summary',
  },
];

// ==================== ANALYTICS API ====================

/// Get analytics data for employee dashboard
static Future<Map<String, dynamic>> getAnalytics() async {
try {
final response = await http
    .get(
Uri.parse('$_baseUrl/employee/analytics/'),
headers: await _getHeaders(),
)
    .timeout(_timeout);

if (response.statusCode == 200) {
_isDemoMode = false;
return json.decode(response. body);
}
throw Exception('Failed to load analytics');
} catch (e) {
debugPrint('🔧 Using demo analytics: $e');
_isDemoMode = true;
return _demoAnalytics;
}
}

// ==================== STATS API ====================

/// Get employee statistics
static Future<Map<String, dynamic>> getEmployeeStats() async {
try {
final response = await http
    .get(
Uri. parse('$_baseUrl/employee/stats/'),
headers: await _getHeaders(),
)
    .timeout(_timeout);

if (response.statusCode == 200) {
_isDemoMode = false;
return json.decode(response.body);
}
throw Exception('Failed to load stats');
} catch (e) {
debugPrint('🔧 Using demo stats: $e');
_isDemoMode = true;
return _demoStats;
}
}

// ==================== REPORTS API ====================

/// Get all reports
static Future<List<Map<String, dynamic>>> getReports() async {
try {
final response = await http
    .get(
Uri. parse('$_baseUrl/employee/reports/'),
headers: await _getHeaders(),
)
    .timeout(_timeout);

if (response.statusCode == 200) {
_isDemoMode = false;
final List<dynamic> data = json.decode(response.body);
return data.cast<Map<String, dynamic>>();
}
throw Exception('Failed to load reports');
} catch (e) {
debugPrint('🔧 Using demo reports: $e');
_isDemoMode = true;
return _demoReports;
}
}

/// Get single report by ID
static Future<Map<String, dynamic>?> getReportById(int reportId) async {
try {
final response = await http
    .get(
Uri. parse('$_baseUrl/employee/reports/$reportId/'),
headers: await _getHeaders(),
)
    . timeout(_timeout);

if (response. statusCode == 200) {
return json.decode(response.body);
}
throw Exception('Failed to load report');
} catch (e) {
debugPrint('🔧 Using demo report: $e');
return _demoReports.firstWhere(
(r) => r['id'] == reportId,
orElse: () => {},
);
}
}

/// Update report status with optional verification image and location

// ==================== AVAILABILITY API ====================

/// Update employee availability
static Future<bool> updateAvailability(bool isAvailable) async {
try {
final response = await http
    . patch(
Uri.parse('$_baseUrl/employee/availability/'),
headers: await _getHeaders(),
body: json.encode({'is_available': isAvailable}),
)
    .timeout(_timeout);

return response.statusCode == 200;
} catch (e) {
debugPrint('🔧 Demo mode: Simulating availability update');
return _isDemoMode;
}
}

// ==================== PROFILE API ====================

/// Update employee profile
static Future<Map<String, dynamic>> updateEmployeeProfile({
String? name,
String? phoneNumber,
String? address,
String?  bio,
bool? isAvailable,
File? profileImage,
}) async {
try {
if (profileImage != null) {
var request = http.MultipartRequest(
'PATCH',
Uri.parse('$_baseUrl/employee/profile/'),
);

request. headers.addAll(await _getHeaders());

if (name != null) request.fields['name'] = name;
if (phoneNumber != null) request.fields['phone_number'] = phoneNumber;
if (address != null) request.fields['address'] = address;
if (bio != null) request.fields['bio'] = bio;
if (isAvailable != null) request. fields['is_available'] = isAvailable. toString();

request.files.add(
await http. MultipartFile.fromPath('profile_image', profileImage. path),
);

final streamedResponse = await request. send().timeout(_timeout);
final response = await http.Response.fromStream(streamedResponse);

if (response.statusCode == 200) {
return {
'success': true,
'message': 'Profile updated successfully',
'data': json.decode(response. body),
};
}
throw Exception('Failed to update profile');
} else {
final Map<String, dynamic> body = {};
if (name != null) body['name'] = name;
if (phoneNumber != null) body['phone_number'] = phoneNumber;
if (address != null) body['address'] = address;
if (bio != null) body['bio'] = bio;
if (isAvailable != null) body['is_available'] = isAvailable;

final response = await http
    . patch(
Uri.parse('$_baseUrl/employee/profile/'),
headers: await _getHeaders(),
body: json.encode(body),
)
    .timeout(_timeout);

if (response.statusCode == 200) {
return {
'success': true,
'message': 'Profile updated successfully',
'data': json.decode(response.body),
};
}
throw Exception('Failed to update profile');
}
} catch (e) {
debugPrint('🔧 Demo mode: Simulating profile update');
if (_isDemoMode) {
return {
'success': true,
'message': 'Demo: Profile updated locally',
'isDemoMode': true,
};
}
return {
'success': false,
'message': 'Failed to update profile: $e',
};
}
}

// ==================== NOTIFICATIONS API ====================

/// Get notifications
static Future<List<Map<String, dynamic>>> getNotifications() async {
try {
final response = await http
    .get(
Uri.parse('$_baseUrl/employee/notifications/'),
headers: await _getHeaders(),
)
    . timeout(_timeout);

if (response. statusCode == 200) {
final List<dynamic> data = json.decode(response.body);
return data.cast<Map<String, dynamic>>();
}
throw Exception('Failed to load notifications');
} catch (e) {
debugPrint('🔧 Using demo notifications');
return _demoNotifications;
}
}

/// Get unread notification count
static Future<int> getUnreadNotificationCount() async {
try {
final response = await http
    .get(
Uri.parse('$_baseUrl/employee/notifications/unread-count/'),
headers: await _getHeaders(),
)
    .timeout(_timeout);

if (response.statusCode == 200) {
final data = json.decode(response.body);
return data['count'] ?? 0;
}
throw Exception('Failed to get notification count');
} catch (e) {
debugPrint('🔧 Using demo notification count');
return _demoNotifications.where((n) => n['read'] == false).length;
}
}

/// Mark notification as read
static Future<bool> markNotificationRead(int notificationId) async {
try {
final response = await http
    .patch(
Uri.parse('$_baseUrl/employee/notifications/$notificationId/read/'),
headers: await _getHeaders(),
)
    .timeout(_timeout);

return response.statusCode == 200;
} catch (e) {
debugPrint('🔧 Demo mode: Marking notification read');
if (_isDemoMode) {
for (var notif in _demoNotifications) {
if (notif['id'] == notificationId) {
notif['read'] = true;
break;
}
}
return true;
}
return false;
}
}

/// Mark all notifications as read
static Future<bool> markAllNotificationsRead() async {
try {
final response = await http
    .patch(
Uri.parse('$_baseUrl/employee/notifications/read-all/'),
headers: await _getHeaders(),
)
    .timeout(_timeout);

return response.statusCode == 200;
} catch (e) {
debugPrint('🔧 Demo mode: Marking all notifications read');
if (_isDemoMode) {
for (var notif in _demoNotifications) {
notif['read'] = true;
}
return true;
}
return false;
}
}

/// Clear all notifications
static Future<bool> clearAllNotifications() async {
try {
final response = await http
    .delete(
Uri. parse('$_baseUrl/employee/notifications/clear/'),
headers: await _getHeaders(),
)
    .timeout(_timeout);

return response.statusCode == 200 || response.statusCode == 204;
} catch (e) {
debugPrint('🔧 Demo mode: Clearing notifications');
if (_isDemoMode) {
_demoNotifications. clear();
return true;
}
return false;
}
}

// ==================== LOCATION API ====================

/// Get nearby reports based on location
static Future<List<Map<String, dynamic>>> getNearbyReports(
double latitude,
double longitude, {
double radiusKm = 5.0,
}) async {
try {
final response = await http
    .get(
Uri.parse(
'$_baseUrl/employee/reports/nearby/?lat=$latitude&lng=$longitude&radius=$radiusKm',
),
headers: await _getHeaders(),
)
    .timeout(_timeout);

if (response.statusCode == 200) {
final List<dynamic> data = json.decode(response. body);
return data.cast<Map<String, dynamic>>();
}
throw Exception('Failed to load nearby reports');
} catch (e) {
debugPrint('🔧 Using demo nearby reports');
// Filter demo reports that have location
return _demoReports
    .where((r) => r['latitude'] != null && r['longitude'] != null)
    .toList();
}
}

// ==================== HELPER METHODS ====================

/// Get auth headers
static Future<Map<String, String>> _getHeaders() async {
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('auth_token');

return {
'Content-Type': 'application/json',
'Accept': 'application/json',
if (token != null) 'Authorization': 'Bearer $token',
};
}

/// Check if in demo mode
static bool get isDemoMode => _isDemoMode;

/// Set demo mode
static void setDemoMode(bool value) {
_isDemoMode = value;
}

/// Get auth token
static Future<String? > getAuthToken() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getString('auth_token');
}

/// Check if authenticated
static Future<bool> isAuthenticated() async {
final token = await getAuthToken();
return token != null && token.isNotEmpty;
}


  static Future<List<LeaderboardEntry>> getLeaderboard({
    String timeFrame = 'month', // 'week', 'month', 'all'
  }) async {
    try {
// TODO: Replace with actual API call
// final response = await ApiClient.get('/employee/leaderboard? timeFrame=$timeFrame');
// return (response['data'] as List). map((e) => LeaderboardEntry.fromJson(e)).toList();

// Demo data
      await Future.delayed(const Duration(milliseconds: 800));

      return [
        LeaderboardEntry(
          id: '1',
          name: 'Sarah Johnson',
          profileImage: 'https://randomuser.me/api/portraits/women/1.jpg',
          points: 4850,
          rating: 4.9,
          tasksCompleted: 156,
          rank: 1,
          trend: 2,
          badges: ['gold_performer', 'speed_cleaner', 'eco_warrior'],
        ),
        LeaderboardEntry(
          id: '2',
          name: 'Michael Chen',
          profileImage: 'https://randomuser.me/api/portraits/men/2.jpg',
          points: 4520,
          rating: 4.8,
          tasksCompleted: 142,
          rank: 2,
          trend: 1,
          badges: ['silver_performer', 'reliable'],
        ),
        LeaderboardEntry(
          id: '3',
          name: 'Emily Rodriguez',
          profileImage: 'https://randomuser.me/api/portraits/women/3.jpg',
          points: 4280,
          rating: 4.7,
          tasksCompleted: 138,
          rank: 3,
          trend: -1,
          badges: ['bronze_performer'],
        ),
        LeaderboardEntry(
          id: '4',
          name: 'David Kim',
          profileImage: 'https://randomuser.me/api/portraits/men/4.jpg',
          points: 3950,
          rating: 4.6,
          tasksCompleted: 125,
          rank: 4,
          trend: 3,
          badges: ['rising_star'],
        ),
        LeaderboardEntry(
          id: '5',
          name: 'Jessica Taylor',
          profileImage: 'https://randomuser.me/api/portraits/women/5.jpg',
          points: 3720,
          rating: 4.5,
          tasksCompleted: 118,
          rank: 5,
          trend: 0,
          badges: [],
        ),
        LeaderboardEntry(
          id: '6',
          name: 'Robert Wilson',
          profileImage: 'https://randomuser.me/api/portraits/men/6.jpg',
          points: 3580,
          rating: 4.4,
          tasksCompleted: 112,
          rank: 6,
          trend: -2,
          badges: [],
        ),
        LeaderboardEntry(
          id: '7',
          name: 'Amanda Brown',
          profileImage: 'https://randomuser.me/api/portraits/women/7.jpg',
          points: 3420,
          rating: 4.3,
          tasksCompleted: 105,
          rank: 7,
          trend: 1,
          badges: [],
        ),
        LeaderboardEntry(
          id: '8',
          name: 'James Martinez',
          profileImage: 'https://randomuser.me/api/portraits/men/8.jpg',
          points: 3180,
          rating: 4.2,
          tasksCompleted: 98,
          rank: 8,
          trend: 4,
          badges: ['newcomer'],
        ),
        LeaderboardEntry(
          id: '9',
          name: 'Lisa Anderson',
          profileImage: 'https://randomuser.me/api/portraits/women/9.jpg',
          points: 2950,
          rating: 4.1,
          tasksCompleted: 92,
          rank: 9,
          trend: -1,
          badges: [],
        ),
        LeaderboardEntry(
          id: '10',
          name: 'William Thomas',
          profileImage: 'https://randomuser.me/api/portraits/men/10.jpg',
          points: 2780,
          rating: 4.0,
          tasksCompleted: 85,
          rank: 10,
          trend: 2,
          badges: [],
        ),
        LeaderboardEntry(
          id: '11',
          name: 'Jennifer Garcia',
          profileImage: 'https://randomuser.me/api/portraits/women/11.jpg',
          points: 2620,
          rating: 3.9,
          tasksCompleted: 78,
          rank: 11,
          trend: 0,
          badges: [],
        ),
        LeaderboardEntry(
          id: '12',
          name: 'Christopher Lee',
          profileImage: 'https://randomuser.me/api/portraits/men/12.jpg',
          points: 2450,
          rating: 3.8,
          tasksCompleted: 72,
          rank: 12,
          trend: -3,
          badges: [],
        ),
      ];
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }


  /// Get accepted reports for the current worker
  static Future<List<Map<String, dynamic>>> getAcceptedReports() async {
    try {
      // TODO: Replace with actual API call
      // final response = await ApiClient.get('/employee/accepted-reports');
      // return List<Map<String, dynamic>>.from(response['data']);

      // Demo data with some overdue reports
      await Future.delayed(const Duration(milliseconds: 500));

      final now = DateTime.now();

      return [
        {
          'id': 101,
          'title': 'Plastic Waste - Sector 5',
          'description': 'Large amount of plastic waste near the park',
          'location': 'Sector 5, Block C, Main Street',
          'latitude': 31.5204,
          'longitude': 74.3587,
          'status': 'in_progress',
          'waste_type': 'Plastic',
          'priority': 'high',
          'created_at': now.subtract(const Duration(days: 4)).toIso8601String(),
          'accepted_at': now. subtract(const Duration(days: 3)).toIso8601String(),
          'image_url': 'https://example.com/waste1.jpg',
        },
        {
          'id': 102,
          'title': 'Organic Waste - Block A',
          'description': 'Kitchen waste dumped illegally',
          'location': 'Block A, Near Hospital',
          'latitude': 31.5210,
          'longitude': 74.3590,
          'status': 'accepted',
          'waste_type': 'Organic',
          'priority': 'medium',
          'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
          'accepted_at': now.subtract(const Duration(days: 2, hours: 5)).toIso8601String(),
          'image_url': 'https://example.com/waste2.jpg',
        },
        {
          'id': 103,
          'title': 'Mixed Waste - Industrial Area',
          'description': 'Industrial waste mixed with household garbage',
          'location': 'Industrial Zone B',
          'latitude': 31.5215,
          'longitude': 74.3595,
          'status': 'in_progress',
          'waste_type': 'Mixed',
          'priority': 'high',
          'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
          'accepted_at': now.subtract(const Duration(hours: 20)).toIso8601String(),
          'image_url': 'https://example.com/waste3.jpg',
        },
        {
          'id': 104,
          'title': 'Electronic Waste - Tech Park',
          'description': 'Old computers and electronics dumped',
          'location': 'Tech Park, Building 4',
          'latitude': 31.5220,
          'longitude': 74.3600,
          'status': 'accepted',
          'waste_type': 'Electronic',
          'priority': 'medium',
          'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
          'accepted_at': now.subtract(const Duration(hours: 10)).toIso8601String(),
          'image_url': 'https://example.com/waste4.jpg',
        },
      ];
    } catch (e) {
      debugPrint('Error fetching accepted reports: $e');
      return [];
    }
  }
}
// Add this method to your existing EmployeeService class

/// Get leaderboard data
