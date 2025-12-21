import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/reports_tab_viewmodel.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class ReportsHeader extends StatelessWidget {
  final ReportsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final List<Report> allReports;
  final double scrollOffset;
  final TextEditingController searchController;
  final AnimationController refreshAnimation;
  final VoidCallback onRefresh;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchClear;
  final VoidCallback onSearchToggle;
  final Function(String) onFilterSelected;

  const ReportsHeader({
    super.key,
    required this. viewModel,
    required this. responsive,
    required this.allReports,
    required this. scrollOffset,
    required this. searchController,
    required this. refreshAnimation,
    required this. onRefresh,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onSearchToggle,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final showElevation = scrollOffset > 10;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.padding,
        r.padding,
        r.microPadding,
      ),
      decoration: BoxDecoration(
        color: ReportsDesign.surfacePure,
        boxShadow: showElevation ? ReportsDesign.softShadow : null,
      ),
      child: Column(
        children: [
          _buildTitleRow(r),
          SizedBox(height: r.microPadding),
          _buildSearchBar(r),
          SizedBox(height: r.microPadding),
          _buildFilterChips(r),
        ],
      ),
    );
  }

  Widget _buildTitleRow(EmployeeResponsiveData r) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.adaptiveText(
                  'My Tasks',
                  nano: 'T',
                  micro: 'Tasks',
                  mini: 'My Tasks',
                ),
                style: GoogleFonts.inter(
                  fontSize: r.headingS,
                  fontWeight: FontWeight.w800,
                  color: ReportsDesign.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              if (r.showSecondaryText)
                Text(
                  'Manage your assigned reports',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    color: ReportsDesign.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (! viewModel.isSearchExpanded && r.effectiveWidth < 400)
          _buildHeaderIconButton(
            r,
            Icons.search_rounded,
            onSearchToggle,
          ),
        SizedBox(width: r.nanoPadding),
        AnimatedBuilder(
          animation: refreshAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: refreshAnimation.value * 2 * math.pi,
              child: child,
            );
          },
          child: _buildHeaderIconButton(
            r,
            Icons.refresh_rounded,
            onRefresh,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderIconButton(
      EmployeeResponsiveData r,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Material(
      color: ReportsDesign.surfaceLight,
      borderRadius: BorderRadius.circular(r.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.borderRadius),
        child: Container(
          width: r.buttonHeightSmall,
          height: r. buttonHeightSmall,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: r.iconSize(20),
            color: ReportsDesign.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(EmployeeResponsiveData r) {
    final showSearch = viewModel.isSearchExpanded || r.effectiveWidth >= 400;

    if (! showSearch) return const SizedBox. shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves. easeOutCubic,
      height: r.buttonHeight,
      decoration: BoxDecoration(
        color: ReportsDesign.surfaceLight,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
      ),
      child: Row(
        children: [
          SizedBox(width: r.microPadding),
          Icon(
            Icons.search_rounded,
            color: ReportsDesign.textTertiary,
            size: r.iconSize(20),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: ReportsDesign.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: r.adaptiveText(
                  'Search by type, location, or ID.. .',
                  nano: 'Search',
                  micro: 'Search.. .',
                  mini: 'Search tasks...',
                ),
                hintStyle: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  color: ReportsDesign.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets. symmetric(vertical: r.microPadding),
              ),
            ),
          ),
          if (viewModel.searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onSearchClear();
              },
              child:  Padding(
                padding: EdgeInsets.all(r.microPadding),
                child: Icon(
                  Icons.close_rounded,
                  color:  ReportsDesign.textTertiary,
                  size: r.iconSize(18),
                ),
              ),
            ),
          if (viewModel.isSearchExpanded && r.effectiveWidth < 400)
            GestureDetector(
              onTap: () {
                searchController.clear();
                onSearchClear();
                onSearchToggle();
              },
              child: Padding(
                padding: EdgeInsets.all(r.microPadding),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: r.captionM,
                    color: ReportsDesign.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          SizedBox(width: r. microPadding),
        ],
      ),
    );
  }

  Widget _buildFilterChips(EmployeeResponsiveData r) {
    return SizedBox(
      height: r.dimension(44),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: viewModel.filterOptions.length,
        separatorBuilder: (_, __) => SizedBox(width: r.microPadding),
        itemBuilder: (context, index) {
          final filter = viewModel.filterOptions[index];
          final count = viewModel.getFilterCount(allReports, filter. value);
          final isSelected = viewModel.selectedFilter == filter.value;

          return _buildFilterChip(r, filter, count, isSelected);
        },
      ),
    );
  }

  Widget _buildFilterChip(
      EmployeeResponsiveData r,
      FilterOption filter,
      int count,
      bool isSelected,
      ) {
    return GestureDetector(
      onTap: () => onFilterSelected(filter.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: r.microPadding,
          vertical: r. nanoPadding,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [filter.color, filter.color.withOpacity(0.85)],
          )
              : null,
          color: isSelected ? null : ReportsDesign.surfaceLight,
          borderRadius: BorderRadius. circular(r.pillBorderRadius),
          boxShadow: isSelected ?  ReportsDesign.glowShadow(filter.color) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter.icon,
              size: r.iconSize(16),
              color: isSelected ? Colors.white : filter.color,
            ),
            SizedBox(width: r. nanoPadding),
            Text(
              r.adaptiveText(
                filter.label,
                nano: filter.nano,
                micro: filter.shortLabel,
                mini: filter. shortLabel,
              ),
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : ReportsDesign.textSecondary,
              ),
            ),
            if (count > 0 && r.showBadges) ...[
              SizedBox(width: r.nanoPadding),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r. nanoPadding,
                  vertical: r.atomicPadding,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white. withOpacity(0.25)
                      : filter.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(r.smallBorderRadius),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : filter.color,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}