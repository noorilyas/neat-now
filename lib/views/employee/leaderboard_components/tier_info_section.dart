import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/leaderboard_models.dart';
import 'package:neat_now/design/leaderboard_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class TierInfoSection extends StatelessWidget {
  final EmployeeResponsiveData responsive;

  const TierInfoSection({super.key, required this.responsive});

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: LeaderboardDesign.surfaceWhite,
        borderRadius: BorderRadius.circular(r.extraLargeBorderRadius),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: r.iconSize(20),
                color: LeaderboardDesign.info,
              ),
              SizedBox(width: r.microPadding),
              Text(
                'Tier System',
                style: GoogleFonts.inter(
                  fontSize: r.bodyM,
                  fontWeight: FontWeight.w700,
                  color: LeaderboardDesign.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: r. microPadding),
          ...LeaderboardTier.values
              .where((t) => t != LeaderboardTier.unranked)
              .map((tier) {
            return _TierInfoCard(responsive: r, tier: tier);
          }),
        ],
      ),
    );
  }
}

/// ==================== TIER INFO CARD (Internal) ====================
class _TierInfoCard extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final LeaderboardTier tier;

  const _TierInfoCard({
    required this.responsive,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Container(
      margin: EdgeInsets.only(bottom: r.microPadding),
      padding: EdgeInsets.all(r. microPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tier.primaryColor.withOpacity(0.15),
            tier.primaryColor. withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(r.borderRadius),
        border: Border.all(color: tier.primaryColor. withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration:  BoxDecoration(
              gradient: LinearGradient(colors: tier.gradientColors),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: tier.glowColor. withOpacity(0.4),
                  blurRadius:  8,
                ),
              ],
            ),
            child: Icon(
              tier.icon,
              size: r.iconSize(24),
              color: tier == LeaderboardTier.silver
                  ? LeaderboardDesign. textPrimary
                  :  Colors.white,
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.name,
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w700,
                    color: LeaderboardDesign.textPrimary,
                  ),
                ),
                Text(
                  'Rating: ${tier.minRating. toStringAsFixed(1)} - ${tier.maxRating. toStringAsFixed(1)}',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: LeaderboardDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.microPadding,
              vertical: r. nanoPadding,
            ),
            decoration: BoxDecoration(
              color: tier.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(r.smallBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size:  r.iconSize(14),
                  color: tier. primaryColor,
                ),
                SizedBox(width: r. atomicPadding),
                Text(
                  tier.bonus,
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    fontWeight: FontWeight.w600,
                    color: tier.primaryColor,
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