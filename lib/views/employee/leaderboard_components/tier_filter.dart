import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/leaderboard_models.dart';
import 'package:neat_now/viewmodels/employee/leaderboard_viewmodel.dart';
import 'package:neat_now/design/leaderboard_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';
import 'dart:math' as math;

class TierFilterSection extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final LeaderboardViewModel viewModel;

  const TierFilterSection({
    super.key,
    required this. responsive,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return SizedBox(
      height: r.dimension(50),
      child: ListView(
        scrollDirection: Axis. horizontal,
        padding: EdgeInsets.symmetric(horizontal: r.padding),
        physics: const BouncingScrollPhysics(),
        children: [
          _TierFilterChip(
            responsive: r,
            viewModel:  viewModel,
            tier: null,
            count: viewModel.allEntries.length,
            label: 'All',
          ),
          ... LeaderboardTier.values
              .where((t) => t != LeaderboardTier.unranked)
              .map((tier) {
            return _TierFilterChip(
              responsive: r,
              viewModel: viewModel,
              tier: tier,
              count: viewModel.tierCounts[tier] ?? 0,
              label:  tier.name,
            );
          }),
        ],
      ),
    );
  }
}

/// ==================== TIER FILTER CHIP (Internal) ====================
class _TierFilterChip extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final LeaderboardViewModel viewModel;
  final LeaderboardTier? tier;
  final int count;
  final String label;

  const _TierFilterChip({
    required this.responsive,
    required this. viewModel,
    required this. tier,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final isSelected = viewModel.selectedTierFilter == tier;
    final color = tier?. primaryColor ?? LeaderboardDesign. primaryTeal;

    return Padding(
      padding: EdgeInsets.only(right: r. microPadding),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            viewModel.filterByTier(tier);
          },
          borderRadius: BorderRadius.circular(r.pillBorderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical: r. nanoPadding,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                  colors: tier?.gradientColors ?? [color, color.withOpacity(0.7)])
                  : null,
              color: isSelected ?  null : LeaderboardDesign.surfaceWhite,
              borderRadius: BorderRadius.circular(r.pillBorderRadius),
              border: Border.all(
                color: isSelected ? Colors.transparent : color. withOpacity(0.3),
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius:  8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tier != null)
                  Icon(
                    tier! .icon,
                    size: r.iconSize(16),
                    color: isSelected
                        ? (tier == LeaderboardTier.silver
                        ? LeaderboardDesign.textPrimary
                        : Colors.white)
                        : color,
                  ),
                if (tier != null) SizedBox(width: r. nanoPadding),
                Text(
                  r.adaptiveText(label,
                      nano: label[0],
                      micro: label.substring(0, math.min(3, label.length))),
                  style: GoogleFonts. inter(
                    fontSize: r.captionM,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (tier == LeaderboardTier.silver
                        ? LeaderboardDesign. textPrimary
                        :  Colors.white)
                        :  LeaderboardDesign.textSecondary,
                  ),
                ),
                if (count > 0 && r.showBadges) ...[
                  SizedBox(width: r.nanoPadding),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: r.nanoPadding,
                      vertical: r.atomicPadding,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white. withOpacity(0.2)
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(r.smallBorderRadius),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        fontWeight:  FontWeight.w700,
                        color: isSelected
                            ? (tier == LeaderboardTier.silver
                            ? LeaderboardDesign. textPrimary
                            :  Colors.white)
                            :  color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ==================== SEARCH BAR WIDGET (Bonus - Internal) ====================
class SearchBarWidget extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final TextEditingController controller;
  final LeaderboardViewModel viewModel;

  const SearchBarWidget({
    super.key,
    required this. responsive,
    required this.controller,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.microPadding),
      decoration: BoxDecoration(
        color:  LeaderboardDesign.surfaceWhite,
        borderRadius:  BorderRadius.circular(r.borderRadius),
        border: Border. all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: r.iconSize(20),
            color:  LeaderboardDesign.textSecondary,
          ),
          SizedBox(width: r. microPadding),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (value) => viewModel.setSearchQuery(value),
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                color: LeaderboardDesign.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search workers...',
                hintStyle: GoogleFonts.inter(
                  fontSize: r.bodyS,
                  color: LeaderboardDesign.textTertiary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: r.microPadding),
              ),
            ),
          ),
          if (viewModel.searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                viewModel. clearSearch();
              },
              child:  Icon(
                Icons.close_rounded,
                size: r. iconSize(18),
                color: LeaderboardDesign.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}