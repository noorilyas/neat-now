import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee_models.dart';
import 'package:neat_now/widgets/employee/responsive_employee_helper.dart';

/// MiniLeaderboardWidget - Compact leaderboard for dashboard panels
class MiniLeaderboardWidget extends StatefulWidget {
  final Future<List<LeaderboardEntry>> leaderboardFuture;
  final String?  currentUserId;
  final VoidCallback?  onViewAll;
  final EmployeeResponsiveData responsive;

  const MiniLeaderboardWidget({
    super.key,
    required this.leaderboardFuture,
    this.currentUserId,
    this.onViewAll,
    required this.responsive,
  });

  @override
  State<MiniLeaderboardWidget> createState() => _MiniLeaderboardWidgetState();
}

class _MiniLeaderboardWidgetState extends State<MiniLeaderboardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(r),

          // Content
          Expanded(
            child: FutureBuilder<List<LeaderboardEntry>>(
              future: widget.leaderboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoading(r);
                }
                if (! snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmpty(r);
                }

                final entries = snapshot.data!. take(5).toList();
                return _buildList(r, entries);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(EmployeeResponsiveData r) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius. vertical(
          top: Radius.circular(r. largeBorderRadius),
        ),
      ),
      child: Row(
        children: [
          // Animated trophy
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.scale(
                  scale: 1.0 + (_animController.value * 0.1),
              child: child,
              );
            },
            child: Container(
              padding: EdgeInsets. all(r.microPadding),
              decoration: BoxDecoration(
                color: Colors.white. withOpacity(0.2),
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: r.iconSize(24),
              ),
            ),
          ),
          SizedBox(width: r. microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Performers',
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(14),
                    fontWeight: FontWeight. bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'This Month',
                  style: GoogleFonts.poppins(
                    fontSize: r.fontSize(10),
                    color: Colors.white. withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          if (widget.onViewAll != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onViewAll!();
              },
              child: Container(
                padding: EdgeInsets. all(r.microPadding),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors. white,
                  size: r.iconSize(14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(EmployeeResponsiveData r, List<LeaderboardEntry> entries) {
    return ListView.builder(
      padding: EdgeInsets. all(r.microPadding),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _buildMiniEntry(r, entries[index], index);
      },
    );
  }

  Widget _buildMiniEntry(EmployeeResponsiveData r, LeaderboardEntry entry, int index) {
    final isCurrentUser = entry.id == widget.currentUserId;
    final rankColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFC0C0C0), // Silver
      const Color(0xFFCD7F32), // Bronze
      const Color(0xFF667EEA), // 4th+
      const Color(0xFF667EEA),
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets. only(bottom: r.microPadding),
        padding: EdgeInsets. all(r.microPadding),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? const Color(0xFF2AC2AB). withOpacity(0.1)
              : rankColors[index]. withOpacity(0.08),
          borderRadius: BorderRadius.circular(r.borderRadius),
          border: isCurrentUser
              ?  Border.all(color: const Color(0xFF2AC2AB), width: 1.5)
              : Border.all(color: rankColors[index]. withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: r.dimension(28),
              height: r.dimension(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rankColors[index], rankColors[index].withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: r. fontSize(12),
                    fontWeight: FontWeight. bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: r.microPadding),

            // Avatar
            Container(
              width: r. avatarSizeSmall,
              height: r.avatarSizeSmall,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: rankColors[index],
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: entry.profileImage != null
                    ?  Image.network(entry.profileImage!, fit: BoxFit.cover)
                    : _buildAvatarPlaceholder(entry.name, r.avatarSizeSmall),
              ),
            ),
            SizedBox(width: r.microPadding),

            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name. split(' ').first,
                    style: GoogleFonts. poppins(
                      fontSize: r.fontSize(12),
                      fontWeight: FontWeight. w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: r.iconSize(10), color: Colors. amber),
                      SizedBox(width: r.nanoPadding),
                      Text(
                        entry.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: r.fontSize(9),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Points
            Container(
              padding: EdgeInsets. symmetric(
                horizontal: r. microPadding,
                vertical: r.nanoPadding,
              ),
              decoration: BoxDecoration(
                color: rankColors[index],
                borderRadius: BorderRadius.circular(r.smallBorderRadius),
              ),
              child: Text(
                '${entry.points}',
                style: GoogleFonts. poppins(
                  fontSize: r.fontSize(10),
                  fontWeight: FontWeight. bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name, double size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0]. toUpperCase() : '?',
          style: GoogleFonts.poppins(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: r.dimension(30),
            height: r.dimension(30),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFFD700),
            ),
          ),
          SizedBox(height: r.microPadding),
          Text(
            'Loading.. .',
            style: GoogleFonts. poppins(
              fontSize: r. fontSize(11),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(EmployeeResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment. center,
        children: [
          Icon(
            Icons. leaderboard_outlined,
            size: r.dimension(40),
            color: Colors.grey[400],
          ),
          SizedBox(height: r.microPadding),
          Text(
            'No rankings yet',
            style: GoogleFonts.poppins(
              fontSize: r.fontSize(12),
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}