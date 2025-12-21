import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/viewmodels/employee/profile_viewmodel.dart';
import 'package:neat_now/models/employee/profile_models.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class ProfileBadges extends StatelessWidget {
  final EmployeeResponsiveData responsive;
  final ProfileViewModel viewModel;
  final Animation<double> badgesAnimation;

  const ProfileBadges({
    super.key,
    required this. responsive,
    required this.viewModel,
    required this.badgesAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    final badges = viewModel.badges;

    return Transform.translate(
      offset: Offset(0, -r.dimension(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r. padding),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(r.nanoPadding),
                  decoration:  BoxDecoration(
                    color: ProfileDesign.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(r.smallBorderRadius),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: ProfileDesign.purple,
                    size: r.iconSize(18),
                  ),
                ),
                SizedBox(width:  r.microPadding),
                Text(
                  'Earned Badges',
                  style:  GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w700,
                    color: ProfileDesign.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${badges. length} badges',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: ProfileDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: r.microPadding),

          SizedBox(
            height: r.dimension(110),
            child: badges.isEmpty
                ? _buildEmptyBadges(r)
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: r.padding),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                return ScaleTransition(
                  scale: badgesAnimation,
                  child:  _buildBadgeItem(context, r, badges[index], index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBadges(EmployeeResponsiveData r) {
    return Center(
      child: Text(
        'No badges earned yet',
        style: GoogleFonts.inter(
          fontSize: r.captionM,
          color: ProfileDesign.textTertiary,
        ),
      ),
    );
  }

  Widget _buildBadgeItem(BuildContext context, EmployeeResponsiveData r, BadgeInfo badge, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showBadgeDetails(context, r, badge);
      },
      child: Container(
        width: r.dimension(90),
        margin: EdgeInsets.only(right: r.microPadding),
        padding: EdgeInsets.all(r. microPadding),
        decoration: BoxDecoration(
          color: ProfileDesign.surfacePure,
          borderRadius:  BorderRadius.circular(r.largeBorderRadius),
          boxShadow: ProfileDesign.softShadow,
          border: Border.all(color: badge.color. withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  colors: [badge.color.withOpacity(0.2), badge.color.withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(badge.icon, color: badge.color, size: r.iconSize(24)),
            ),
            SizedBox(height: r.nanoPadding),
            Text(
              badge.name,
              style: GoogleFonts.inter(
                fontSize: r.captionXS,
                fontWeight: FontWeight.w600,
                color: ProfileDesign.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, EmployeeResponsiveData r, BadgeInfo badge) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BadgeDetailsSheet(badge: badge, responsive: r),
    );
  }
}

class _BadgeDetailsSheet extends StatefulWidget {
  final BadgeInfo badge;
  final EmployeeResponsiveData responsive;

  const _BadgeDetailsSheet({required this.badge, required this.responsive});

  @override
  State<_BadgeDetailsSheet> createState() => _BadgeDetailsSheetState();
}

class _BadgeDetailsSheetState extends State<_BadgeDetailsSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final badge = widget.badge;

    return Container(
      padding:  EdgeInsets.all(r. largePadding),
      decoration: BoxDecoration(
        color:  ProfileDesign.surfacePure,
        borderRadius: BorderRadius. vertical(top: Radius.circular(r.extraLargeBorderRadius)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: r.dimension(40),
              height: r.dimension(4),
              decoration: BoxDecoration(
                color: ProfileDesign.textLight,
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
            ),
            SizedBox(height: r.largePadding),

            ScaleTransition(
              scale:  _scaleAnimation,
              child: Container(
                padding: EdgeInsets.all(r.largePadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [badge.color.withOpacity(0.2), badge.color.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: ProfileDesign.glowShadow(badge.color),
                ),
                child:  Icon(badge.icon, color: badge.color, size: r.iconSize(48)),
              ),
            ),

            SizedBox(height: r.padding),
            Text(
              badge.name,
              style: GoogleFonts.inter(
                fontSize: r.headingXS,
                fontWeight: FontWeight.w700,
                color: ProfileDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.nanoPadding),

            Container(
              padding: EdgeInsets.symmetric(horizontal: r.padding, vertical: r.microPadding),
              decoration:  BoxDecoration(
                color:  badge.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(r.pillBorderRadius),
              ),
              child: Text(
                badge.description,
                style: GoogleFonts.inter(fontSize: r.bodyS, color: badge.color),
              ),
            ),

            SizedBox(height: r.largePadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: badge.color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: r.microPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.borderRadius),
                  ),
                  elevation: 0,
                ),
                child: Text('Awesome!', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}