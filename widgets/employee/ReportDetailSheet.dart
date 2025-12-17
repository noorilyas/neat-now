import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:intl/intl.dart';

/// Report Detail Sheet - Shows full report details
class _ReportDetailSheet extends StatelessWidget {
  final Report report;
  final VoidCallback onClose;
  final VoidCallback onResolve;
  final VoidCallback onUpdateLocation;

  const _ReportDetailSheet({
    required this.report,
    required this.onClose,
    required this.onResolve,
    required this.onUpdateLocation,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size. height;
    final color = _statusColor(report.status);
    final canResolve = report.status == 'in-progress';
    final hasLocation = report.latitude != null && report. longitude != null &&
        report.latitude != 0.0 && report. longitude != 0.0;

    return Container(
    constraints: BoxConstraints(maxHeight: screenH * 0.85),
    decoration: const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    // Handle
    Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
    color: Colors.grey[300],
    borderRadius: BorderRadius.circular(2),
    ),
    ),

    // Header
    Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
    children: [
    Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    color: color. withOpacity(0.1),
    borderRadius: BorderRadius. circular(12),
    ),
    child: Icon(_wasteIcon(report.type), color: color, size: 24),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Report Details',
    style: GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    ),
    ),
    Text(
    '#${report.id}',
    style: GoogleFonts.poppins(
    fontSize: 12,
    color: Colors.grey[500],
    ),
    ),
    ],
    ),
    ),
    IconButton(
    onPressed: onClose,
    icon: const Icon(Icons.close_rounded),
    color: Colors.grey[600],
    ),
    ],
    ),
    ),

    const Divider(height: 24),

    // Content
    Flexible(
    child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Image
    if (report.imageUrl != null && report.imageUrl! .isNotEmpty)
    _buildImageSection(),

    // Status
    _buildInfoCard(
    'Status',
    _statusLabel(report. status),
    Icons.flag_rounded,
    color,
    trailing: Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
    mainAxisSize: MainAxisSize. min,
    children: [
    Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape. circle),
    ),
    const SizedBox(width: 6),
    Text(
    _statusLabel(report. status),
    style: GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight. w600,
    color: color,
    ),
    ),
    ],
    ),
    ),
    ),

    // Type
    _buildInfoCard(
    'Waste Type',
    report.type,
    _wasteIcon(report.type),
    Colors.purple,
    ),

    // Location


    // GPS Coordinates
    _buildGPSCard(hasLocation),

    // Reporter
    _buildInfoCard(
    'Reported By',
    report.userName,
    Icons.person_rounded,
    Colors.blue,
    ),

    // Date
    _buildInfoCard(
    'Date Reported',
    _formatDate(report.date),
    Icons.calendar_today_rounded,
    Colors.teal,
    ),

    // Description
    if (report.description != null && report.description!.isNotEmpty)
    _buildDescriptionCard(),

    const SizedBox(height: 20),
    ],
    ),
    ),
    ),

    // Actions
    Container(
    padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
    decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
    BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 10,
    offset: const Offset(0, -4),
    ),
    ],
    ),
    child: Row(
    children: [
    // Update Location button
    Expanded(
    child: OutlinedButton. icon(
    onPressed: onUpdateLocation,
    icon: const Icon(Icons.edit_location_alt_rounded, size: 18),
    label: const Text('Edit Location'),
    style: OutlinedButton.styleFrom(
    foregroundColor: Colors. orange,
    side: const BorderSide(color: Colors. orange),
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    ),
    ),
    if (canResolve) ...[
    const SizedBox(width: 12),
    Expanded(
    child: ElevatedButton. icon(
    onPressed: onResolve,
    icon: const Icon(Icons.check_circle_rounded, size: 18),
    label: const Text('Resolve'),
    style: ElevatedButton. styleFrom(
    backgroundColor: Colors. green,
    foregroundColor: Colors.white,
    minimumSize: const Size(0, 48),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    ),
    ),
    ),
    ],
    ],
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waste Image',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              report.imageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.broken_image_rounded, size: 48, color: Colors. grey),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  height: 180,
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2AC2AB),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color, {Widget?  trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey. withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow. ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildGPSCard(bool hasLocation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasLocation
            ? const Color(0xFF2AC2AB). withOpacity(0.05)
            : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasLocation
              ? const Color(0xFF2AC2AB). withOpacity(0.2)
              : Colors.orange.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets. all(8),
            decoration: BoxDecoration(
              color: hasLocation
                  ?  const Color(0xFF2AC2AB). withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasLocation ?  Icons.gps_fixed_rounded : Icons.gps_off_rounded,
              color: hasLocation ?  const Color(0xFF2AC2AB) : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment. start,
              children: [
                Text(
                  'GPS Coordinates',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                ),
                Text(
                  hasLocation
                      ? '${report.latitude! .toStringAsFixed(6)}, ${report. longitude!.toStringAsFixed(6)}'
                      : 'No GPS location set',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight. w500,
                    color: hasLocation ? Colors.grey[800] : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          if (hasLocation)
            Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(
                    text: '${report.latitude},${report.longitude}',
                  ));
                  ScaffoldMessenger. of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Coordinates copied! '),
                      backgroundColor: const Color(0xFF2AC2AB),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius. circular(10)),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2AC2AB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.copy_rounded, size: 16, color: Colors. white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets. all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius. circular(12),
        border: Border. all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_rounded, color: Colors.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Description',
                style: GoogleFonts. poppins(
                  fontSize: 13,
                  fontWeight: FontWeight. w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            report.description!,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors. grey[700], height: 1.5),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return Colors.green;
      case 'in-progress': return Colors.blue;
      case 'pending': return Colors.orange;
      default: return Colors. grey;
    }
  }

  String _statusLabel(String status) {
    switch (status. toLowerCase()) {
      case 'resolved': return 'Resolved';
      case 'in-progress': return 'In Progress';
      case 'pending': return 'Pending';
      default: return status;
    }
  }

  IconData _wasteIcon(String type) {
    final t = type.toLowerCase();
    if (t. contains('plastic')) return Icons.local_drink_rounded;
    if (t.contains('organic')) return Icons.eco_rounded;
    if (t.contains('electronic')) return Icons.devices_rounded;
    if (t.contains('hazardous')) return Icons.warning_amber_rounded;
    if (t.contains('glass')) return Icons.wine_bar_rounded;
    if (t.contains('paper')) return Icons. description_rounded;
    if (t. contains('metal')) return Icons.recycling_rounded;
    return Icons.delete_rounded;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a'). format(date);
  }
}