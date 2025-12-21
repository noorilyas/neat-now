import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class TaskDetailSheet extends StatelessWidget {
  final Report report;
  final MapTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final VoidCallback onClose;
  final VoidCallback onNavigate;
  final VoidCallback onResolve;
  final VoidCallback onAddLocation;

  const TaskDetailSheet({
    super.key,
    required this.report,
    required this.viewModel,
    required this.responsive,
    required this.onClose,
    required this.onNavigate,
    required this.onResolve,
    required this.onAddLocation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size.height;
    final color = viewModel.getStatusColor(report.status);
    final canResolve = report.status == 'in-progress';
    final hasLocation = viewModel.hasValidLocation(report);

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.9),
      decoration: const BoxDecoration(
        color:  MapDesign.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: r.dimension(40),
            height: r.dimension(4),
            margin: EdgeInsets.symmetric(vertical: r.microPadding),
            decoration:  BoxDecoration(
              color:  Colors.grey[300],
              borderRadius: BorderRadius.circular(r.tinyBorderRadius),
            ),
          ),

          // Header
          _buildHeader(r, color, context),

          Divider(height: r.padding * 2),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: r.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Waste Image
                  if (report.imageUrl != null && report.imageUrl! .isNotEmpty)
                    _buildSection(
                      r,
                      'Waste Image',
                      Icons.image_rounded,
                      Colors.purple,
                      _buildImagePreview(r),
                    ),

                  // AI Classification
                  _buildSection(
                    r,
                    'AI Classification',
                    Icons.smart_toy_rounded,
                    Colors. indigo,
                    _buildAIClassification(r),
                  ),

                  // Status
                  _buildInfoRow(
                    r,
                    'Status',
                    viewModel.getStatusLabel(report.status),
                    Icons.flag_rounded,
                    color,
                    badge: _buildStatusBadge(r, color),
                  ),

                  // Waste Type
                  _buildInfoRow(
                    r,
                    'Waste Type',
                    report.type,
                    viewModel.getWasteIcon(report.type),
                    Colors.purple,
                  ),

                  // Description
                  if (report.description != null && report.description!.isNotEmpty)
                    _buildInfoRow(
                      r,
                      'Description',
                      report.description!,
                      Icons.description_rounded,
                      Colors.teal,
                    ),

                  // Location
                  _buildInfoRow(
                    r,
                    'Location Address',
                    report.location,
                    Icons.location_on_rounded,
                    Colors.red,
                  ),

                  // GPS Coordinates
                  _buildGPSSection(r, hasLocation, context),

                  // Reporter Info
                  _buildInfoRow(
                    r,
                    'Reported By',
                    report.userName,
                    Icons.person_rounded,
                    Colors.blue,
                  ),

                  // Timestamps
                  _buildSection(
                    r,
                    'Timestamps',
                    Icons.schedule_rounded,
                    Colors. orange,
                    _buildTimestamps(r),
                  ),

                  SizedBox(height: r.padding),
                ],
              ),
            ),
          ),

          // Actions
          _buildActions(r, bottomPad, hasLocation, canResolve),
        ],
      ),
    );
  }

  Widget _buildHeader(EmployeeResponsiveData r, Color color, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r. padding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius.circular(r.borderRadius),
            ),
            child: Icon(
              viewModel.getWasteIcon(report.type),
              color: color,
              size: r.iconSize(24),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Details',
                  style: GoogleFonts.poppins(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '#${report.id}',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionM,
                    color: MapDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: MapDesign.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      EmployeeResponsiveData r,
      String title,
      IconData icon,
      Color color,
      Widget content,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: r.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration:  BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r. smallBorderRadius),
                ),
                child: Icon(icon, color: color, size: r.iconSize(16)),
              ),
              SizedBox(width: r.microPadding),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: r.bodyS,
                  fontWeight: FontWeight.w600,
                  color: MapDesign.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r.microPadding),
          content,
        ],
      ),
    );
  }

  Widget _buildImagePreview(EmployeeResponsiveData r) {
    if (report.imageUrl == null || report.imageUrl!. isEmpty) {
      return Container(
        height: r.dimension(180),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(r.borderRadius),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported_rounded,
            size: r.iconSize(48),
            color:  Colors.grey,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(r. borderRadius),
      child: Image.network(
        report.imageUrl! ,
        height: r.dimension(180),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: r.dimension(180),
          color: Colors.grey[200],
          child: Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: r.iconSize(48),
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIClassification(EmployeeResponsiveData r) {
    final classification = viewModel.getAIClassification();

    return Container(
      padding:  EdgeInsets.all(r. microPadding),
      decoration: BoxDecoration(
        color:  Colors.grey[50],
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.grey. withOpacity(0.15)),
      ),
      child: Column(
        children: [
          ... classification.categories.map((category) => Padding(
            padding: EdgeInsets.only(bottom: r.microPadding),
            child: Row(
              children: [
                Container(
                  width: r.dimension(12),
                  height: r. dimension(12),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(r.atomicPadding),
                  ),
                ),
                SizedBox(width: r.microPadding),
                Expanded(
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(fontSize: r.captionM),
                  ),
                ),
                SizedBox(
                  width: r.dimension(100),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(r.atomicPadding),
                    child: LinearProgressIndicator(
                      value: category.percentage / 100,
                      backgroundColor:  Colors.grey[200],
                      color: category.color,
                      minHeight: r.dimension(8),
                    ),
                  ),
                ),
                SizedBox(width: r. microPadding),
                Text(
                  '${category.percentage}%',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )),
          const Divider(),
          Row(
            children:  [
              Icon(
                Icons.info_outline_rounded,
                size: r.iconSize(14),
                color: Colors.grey[500],
              ),
              SizedBox(width: r.nanoPadding),
              Expanded(
                child: Text(
                  'Classification confidence: ${(classification.confidence * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionS,
                    color: MapDesign.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      EmployeeResponsiveData r,
      String label,
      String value,
      IconData icon,
      Color color, {
        Widget? badge,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: r.microPadding),
      padding: EdgeInsets.all(r.microPadding),
      decoration: BoxDecoration(
        color:  Colors.grey[50],
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius. circular(r.smallBorderRadius),
            ),
            child:  Icon(icon, color: color, size: r.iconSize(18)),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:  GoogleFonts.poppins(
                    fontSize: r. captionXS,
                    color: MapDesign.textSecondary,
                  ),
                ),
                SizedBox(height: r.atomicPadding),
                Text(
                  value,
                  style: GoogleFonts. poppins(
                    fontSize: r.captionL,
                    fontWeight: FontWeight.w500,
                    color: MapDesign.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null) badge,
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EmployeeResponsiveData r, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.microPadding,
        vertical:  r.nanoPadding,
      ),
      decoration: BoxDecoration(
        color: color. withOpacity(0.1),
        borderRadius: BorderRadius. circular(r.pillBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: r.dimension(6),
            height: r.dimension(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: r.nanoPadding),
          Text(
            viewModel.getStatusLabel(report.status),
            style: GoogleFonts.poppins(
              fontSize: r.captionXS,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPSSection(EmployeeResponsiveData r, bool hasLocation, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: r.microPadding),
      padding: EdgeInsets. all(r.microPadding),
      decoration: BoxDecoration(
        color: hasLocation
            ? MapDesign.primaryTeal. withOpacity(0.05)
            : Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(
          color: hasLocation
              ? MapDesign.primaryTeal.withOpacity(0.2)
              : Colors.orange. withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.nanoPadding),
            decoration: BoxDecoration(
              color: hasLocation
                  ?  MapDesign.primaryTeal. withOpacity(0.1)
                  : Colors.orange. withOpacity(0.1),
              borderRadius: BorderRadius. circular(r.smallBorderRadius),
            ),
            child:  Icon(
              hasLocation ?  Icons.gps_fixed_rounded : Icons.gps_off_rounded,
              color: hasLocation ? MapDesign. primaryTeal : Colors.orange,
              size: r.iconSize(18),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPS Coordinates',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionXS,
                    color: MapDesign.textSecondary,
                  ),
                ),
                Text(
                  hasLocation
                      ? '${report.latitude! .toStringAsFixed(6)}, ${report.longitude!.toStringAsFixed(6)}'
                      : 'No GPS location - tap "Add Location" to set',
                  style: GoogleFonts.poppins(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w500,
                    color: hasLocation ? MapDesign.textPrimary : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          if (hasLocation)
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: '${report.latitude},${report.longitude}'),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Coordinates copied! '),
                    backgroundColor: MapDesign.primaryTeal,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(r.nanoPadding),
                decoration:  BoxDecoration(
                  color: MapDesign.primaryTeal,
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Icon(
                  Icons. copy_rounded,
                  size: r.iconSize(14),
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimestamps(EmployeeResponsiveData r) {
    return Container(
        padding: EdgeInsets.all(r.microPadding),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius. circular(r.borderRadius),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          children: [
          _timestampRow(
          r,
          'Reported',
          report.date,
          Icons.flag_outlined,
          Colors.orange,
        ),
        Divider(height: r.padding),
        _timestampRow(
          r,
          'Assigned',
          report.assignedAt ??  report.date,
          Icons. assignment_ind_outlined,
          Colors.blue,
        ),
        if (report.status == 'resolved' && report.resolvedAt != null) ...[
    Divider(height: r.padding),
    _timestampRow(
    r,
    'Completed',
    report.resolvedAt!,
    Icons.check_circle_outline,
    Colors.green,
    ),
    ],
    ],
    ),
    );
  }

  Widget _timestampRow(
      EmployeeResponsiveData r,
      String label,
      DateTime date,
      IconData icon,
      Color color,
      ) {
    return Row(
      children: [
        Icon(icon, size: r.iconSize(16), color: color),
        SizedBox(width: r.microPadding),
        Text(
          label,
          style:  GoogleFonts.poppins(
            fontSize: r.captionM,
            color: MapDesign.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          viewModel.formatDateTime(date),
          style: GoogleFonts.poppins(
            fontSize: r.captionM,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(
      EmployeeResponsiveData r,
      double bottomPad,
      bool hasLocation,
      bool canResolve,
      ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.microPadding,
        r. padding,
        bottomPad + r.microPadding,
      ),
      decoration: BoxDecoration(
        color: MapDesign.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (hasLocation)
                Expanded(
                  child: ElevatedButton. icon(
                    onPressed:  onNavigate,
                    icon: Icon(Icons.navigation_rounded, size: r.iconSize(18)),
                    label: const Text('Navigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(0, r.buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r. borderRadius),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAddLocation,
                    icon: Icon(
                      Icons.add_location_alt_rounded,
                      size:  r.iconSize(18),
                    ),
                    label:  const Text('Add Location'),
                    style: ElevatedButton. styleFrom(
                      backgroundColor:  Colors.orange,
                      foregroundColor:  Colors.white,
                      minimumSize: Size(0, r.buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r. borderRadius),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (canResolve) ...[
            SizedBox(height: r.microPadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onResolve,
                icon: Icon(
                  Icons.check_circle_rounded,
                  size: r.iconSize(18),
                ),
                label: const Text('Mark as Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize:  Size(0, r.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}