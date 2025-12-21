import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/viewmodels/employee/map_tab_viewmodel.dart';
import 'package:neat_now/models/employee/map_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class MapFilters extends StatelessWidget {
  final MapTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final List<Report> allReports;
  final MapLayout layout;
  final Function(String) onFilterSelected;

  const MapFilters({
    super.key,
    required this.viewModel,
    required this.responsive,
    required this.allReports,
    required this.layout,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case MapLayout.micro:
        return _buildMicroFilters();
      case MapLayout.compact:
        return _buildCompactFilters();
      case MapLayout. mobile:
      case MapLayout.tablet:
      case MapLayout.desktop:
        return _buildStandardFilters();
    }
  }

  Widget _buildMicroFilters() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: MapDesign.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow:  [
          BoxShadow(
            color: Colors.black. withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: viewModel.filterOptions.map((filter) {
          final isSelected = viewModel.selectedFilter == filter. value;
          final count = viewModel.getFilterCount(allReports, filter.value);

          return Expanded(
            child: GestureDetector(
              onTap: () => onFilterSelected(filter.value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? filter.color. withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight. bold : FontWeight.normal,
                      color: isSelected ? filter.color :  Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactFilters() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MapDesign.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow:  [
          BoxShadow(
            color: Colors.black. withOpacity(0.08),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: viewModel. filterOptions.map((filter) {
          final isSelected = viewModel.selectedFilter == filter.value;
          final count = viewModel. getFilterCount(allReports, filter.value);

          return Expanded(
            child: GestureDetector(
              onTap: () => onFilterSelected(filter.value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? filter.color. withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: filter.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child:  Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? filter.color : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStandardFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: MapDesign.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow:  [
          BoxShadow(
            color: Colors.black. withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: viewModel.filterOptions.map((filter) {
          final isSelected = viewModel. selectedFilter == filter.value;
          final count = viewModel.getFilterCount(allReports, filter.value);

          return Expanded(
            child: GestureDetector(
              onTap: () => onFilterSelected(filter.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? filter.color. withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  Column(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: filter.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child:  Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          '${filter.label} ($count)',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? filter.color : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}