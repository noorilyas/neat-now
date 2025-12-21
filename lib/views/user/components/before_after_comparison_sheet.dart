import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/models/user/user_report_model.dart';
import 'package:neat_now/viewmodels/user/user_reports_viewmodel.dart';

class BeforeAfterComparisonSheet extends StatefulWidget {
  final UserReportModel report;
  final UserResponsiveData responsive;
  final UserReportsViewModel viewModel;

  const BeforeAfterComparisonSheet({
    super.key,
    required this. report,
    required this.responsive,
    required this.viewModel,
  });

  @override
  State<BeforeAfterComparisonSheet> createState() =>
      _BeforeAfterComparisonSheetState();
}

class _BeforeAfterComparisonSheetState
    extends State<BeforeAfterComparisonSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSlider = true;
  double _sliderPosition = 0.5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final report = widget.report;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: UserDesign.surfacePure,
        borderRadius: BorderRadius.vertical(
          top: Radius. circular(r.extraLargeBorderRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: r.dimension(40),
            height: r.dimension(4),
            margin: EdgeInsets.symmetric(vertical: r.microPadding),
            decoration:  BoxDecoration(
              color:  UserDesign.textLight,
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.padding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.microPadding),
                  decoration: BoxDecoration(
                    gradient: UserDesign.successGradient,
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                  child: Icon(
                    Icons.compare_rounded,
                    color: Colors.white,
                    size: r.iconSize(20),
                  ),
                ),
                SizedBox(width: r.microPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Before & After',
                        style:  GoogleFonts.inter(
                          fontSize: r.headingXS,
                          fontWeight:  FontWeight.w700,
                          color: UserDesign.textPrimary,
                        ),
                      ),
                      Text(
                        report.type,
                        style: GoogleFonts.inter(
                          fontSize: r.captionS,
                          color: UserDesign.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(r.microPadding),
                    decoration: BoxDecoration(
                      color: UserDesign. surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color:  UserDesign.textSecondary,
                      size: r.iconSize(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: r.microPadding),

          // View Toggle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.padding),
            child: Container(
              padding: EdgeInsets.all(r.nanoPadding),
              decoration:  BoxDecoration(
                color:  UserDesign.surfaceLight,
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
              child: Row(
                children: [
                  _buildViewToggleButton(
                    r,
                    'Slider',
                    Icons.compare_arrows_rounded,
                    _showSlider,
                        () {
                      setState(() => _showSlider = true);
                    },
                  ),
                  _buildViewToggleButton(
                    r,
                    'Side by Side',
                    Icons.view_column_rounded,
                    !_showSlider,
                        () {
                      setState(() => _showSlider = false);
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: r.padding),

          // Image Comparison
          Expanded(
            child:  Padding(
              padding: EdgeInsets.symmetric(horizontal: r. padding),
              child: _showSlider
                  ? _buildSliderComparison(r, report)
                  : _buildSideBySideComparison(r, report),
            ),
          ),

          // Info Section
          _buildComparisonInfo(r, report),

          SizedBox(height: r.safePaddingBottom + r.padding),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(
      UserResponsiveData r,
      String label,
      IconData icon,
      bool isActive,
      VoidCallback onTap,
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: r.microPadding),
          decoration: BoxDecoration(
            color: isActive ? UserDesign.primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(r.pillBorderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: r.iconSize(16),
                color: isActive ?  Colors.white : UserDesign.textSecondary,
              ),
              SizedBox(width: r.nanoPadding),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: r. captionM,
                  fontWeight: FontWeight.w600,
                  color: isActive ?  Colors.white : UserDesign. textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderComparison(UserResponsiveData r, UserReportModel report) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(r. largeBorderRadius),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _sliderPosition = (_sliderPosition + details.delta. dx / width)
                    .clamp(0.0, 1.0);
              });
            },
            child: Stack(
              children: [
                // After Image (Full)
                Positioned. fill(
                  child: Image.network(
                    report.afterImageUrl ??  '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: UserDesign.surfaceLight),
                  ),
                ),

                // Before Image (Clipped)
                Positioned. fill(
                  child: ClipRect(
                    clipper: _ImageClipper(_sliderPosition * width),
                    child: Image.network(
                      report. beforeImageUrl ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: UserDesign.surfaceLight),
                    ),
                  ),
                ),

                // Slider Line
                Positioned(
                  left: _sliderPosition * width - 2,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius:  8,
                        ),
                      ],
                    ),
                  ),
                ),

                // Slider Handle
                Positioned(
                  left: _sliderPosition * width - 20,
                  top: height / 2 - 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment:  MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          size: 16,
                          color: UserDesign.textSecondary,
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: UserDesign.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                // Before Label
                Positioned(
                  left: r.microPadding,
                  top: r.microPadding,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.microPadding,
                      vertical:  r.nanoPadding,
                    ),
                    decoration: BoxDecoration(
                      color: UserDesign.error,
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Text(
                      'BEFORE',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // After Label
                Positioned(
                  right: r.microPadding,
                  top: r.microPadding,
                  child: Container(
                    padding:  EdgeInsets.symmetric(
                      horizontal: r.microPadding,
                      vertical: r.nanoPadding,
                    ),
                    decoration: BoxDecoration(
                      color:  UserDesign.success,
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Text(
                      'AFTER',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        fontWeight:  FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSideBySideComparison(
      UserResponsiveData r, UserReportModel report) {
    return Row(
      children: [
        // Before
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.microPadding,
                  vertical:  r.nanoPadding,
                ),
                decoration: BoxDecoration(
                  color: UserDesign.error,
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Text(
                  'BEFORE',
                  style:  GoogleFonts.inter(
                    fontSize: r.captionXS,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: r.nanoPadding),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  child: Image.network(
                    report. beforeImageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        Container(color: UserDesign.surfaceLight),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: r.microPadding),
        // After
        Expanded(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r. microPadding,
                  vertical: r.nanoPadding,
                ),
                decoration:  BoxDecoration(
                  color: UserDesign.success,
                  borderRadius: BorderRadius. circular(r.smallBorderRadius),
                ),
                child:  Text(
                  'AFTER',
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height:  r.nanoPadding),
              Expanded(
                child:  ClipRRect(
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  child: Image.network(
                    report.afterImageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) =>
                        Container(color: UserDesign.surfaceLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonInfo(UserResponsiveData r, UserReportModel report) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: r.padding),
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: UserDesign.success. withOpacity(0.05),
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        border: Border.all(color: UserDesign.success. withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: UserDesign. success,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: r.iconSize(20),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cleanup Verified',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight:  FontWeight.w700,
                    color: UserDesign.success,
                  ),
                ),
                if (report.cleanupDuration != null)
                  Text(
                    'Cleaned in ${widget.viewModel.formatDuration(report.cleanupDuration! )} by ${report.workerName}',
                    style:  GoogleFonts.inter(
                      fontSize: r.captionS,
                      color: UserDesign.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageClipper extends CustomClipper<Rect> {
  final double clipWidth;

  _ImageClipper(this. clipWidth);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipWidth, size.height);
  }

  @override
  bool shouldReclip(covariant _ImageClipper oldClipper) {
    return oldClipper.clipWidth != clipWidth;
  }
}