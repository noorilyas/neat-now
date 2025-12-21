import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neat_now/viewmodels/employee/reports_tab_viewmodel.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'package:neat_now/views/employee/reports_components/report_card.dart';

class ReportsList extends StatelessWidget {
  final ReportsTabViewModel viewModel;
  final EmployeeResponsiveData responsive;
  final List<Report> reports;
  final ScrollController scrollController;
  final Animation<double> shimmerAnimation;
  final VoidCallback onRefresh;
  final Function(Report) onReportTap;
  final Function(String) onImageTap;
  final Function(double, double) onNavigate;
  final Function(int, String, {String? imagePath, double? latitude, double? longitude, String? locationAddress}) onUpdateStatus;
  final Function(Report) onShowResolveSheet;

  const ReportsList({
    super.key,
    required this.viewModel,
    required this.responsive,
    required this.reports,
    required this.scrollController,
    required this.shimmerAnimation,
    required this.onRefresh,
    required this.onReportTap,
    required this.onImageTap,
    required this. onNavigate,
    required this.onUpdateStatus,
    required this.onShowResolveSheet,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: ReportsDesign.primaryTeal,
      backgroundColor: ReportsDesign.surfacePure,
      strokeWidth: 2.5,
      displacement: 60,
      child: ListView.builder(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.all(r.padding),
        itemCount: reports. length,
        itemBuilder: (context, index) {
          return ReportCard(
            reportCardData: viewModel.getReportCardData(reports[index]),
            viewModel: viewModel,
            responsive: r,
            index: index,
            shimmerAnimation: shimmerAnimation,
            isHovered: viewModel.hoveredCardIndex == index,
            onTap: () => onReportTap(reports[index]),
            onImageTap: () {
              if (reports[index].imageUrl != null &&
                  reports[index].imageUrl!.isNotEmpty) {
                onImageTap(reports[index].imageUrl!);
              }
            },
            onNavigate: () {
              if (reports[index].latitude != null &&
                  reports[index].longitude != null) {
                onNavigate(
                  reports[index].latitude!,
                  reports[index].longitude! ,
                );
              }
            },
            onUpdateStatus: (status) {
              HapticFeedback.mediumImpact();
              onUpdateStatus(reports[index]. id, status);
            },
            onResolve: () => onShowResolveSheet(reports[index]),
            onHover: (isHovering) {
              viewModel.setHoveredCard(isHovering ?  index : null);
            },
          );
        },
      ),
    );
  }
}