import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neat_now/views/user/responsive_user_helper.dart';
import 'package:neat_now/design/user/user_design_system.dart';
import 'package:neat_now/viewmodels/user/notifications_viewmodel.dart';
import 'package:neat_now/models/user/notification_model.dart';

class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({super.key});

  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage>
    with SingleTickerProviderStateMixin {
  late NotificationsViewModel _viewModel;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _viewModel = NotificationsViewModel();
    _viewModel.addListener(_onViewModelChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _viewModel.refresh();
  }

  void _showClearAllDialog() {
    final r = UserResponsiveData. of(context);

    showDialog(
      context:  context,
      builder: (context) => AlertDialog(
        backgroundColor: UserDesign.surfacePure,
        shape: RoundedRectangleBorder(
          borderRadius:  BorderRadius.circular(r.largeBorderRadius),
        ),
        title: Text(
          'Clear All Notifications? ',
          style: GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will permanently delete all your notifications. This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: r.captionM),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.clearAll();
              _showSnackBar('All notifications cleared');
            },
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(color: UserDesign.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: UserDesign.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = UserResponsiveData. of(context);

    return Scaffold(
      backgroundColor: UserDesign.surfaceLight,
      body: Column(
        children: [
          _buildAppBar(r),
          _buildFilterChips(r),
          Expanded(
            child: _viewModel.isLoading
                ? _buildLoadingState(r)
                : ! _viewModel.hasNotifications
                ? _buildEmptyState(r)
                : _buildNotificationsList(r),
          ),
        ],
      ),
    );
  }

  // ==================== APP BAR ====================
  Widget _buildAppBar(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        r.padding,
        r.safePaddingTop + r.microPadding,
        r. padding,
        r.microPadding,
      ),
      decoration: BoxDecoration(
        color: UserDesign.surfacePure,
        boxShadow: UserDesign.softShadow,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(r.microPadding),
              decoration: BoxDecoration(
                color: UserDesign. surfaceLight,
                borderRadius: BorderRadius.circular(r.borderRadius),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: UserDesign.textSecondary,
                size: r.iconSize(20),
              ),
            ),
          ),
          SizedBox(width: r.microPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style:  GoogleFonts.inter(
                    fontSize: r.headingXS,
                    fontWeight: FontWeight.w700,
                    color: UserDesign.textPrimary,
                  ),
                ),
                Text(
                  '${_viewModel.unreadCount} unread',
                  style: GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: UserDesign.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_viewModel.hasNotifications) ...[
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _viewModel.markAllAsRead();
                _showSnackBar('All notifications marked as read');
              },
              child: Container(
                padding:  EdgeInsets.all(r. microPadding),
                decoration: BoxDecoration(
                  color: UserDesign.primaryTeal. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child:  Icon(
                  Icons.done_all_rounded,
                  color: UserDesign.primaryTeal,
                  size:  r.iconSize(20),
                ),
              ),
            ),
            SizedBox(width: r. microPadding),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showClearAllDialog();
              },
              child: Container(
                padding: EdgeInsets.all(r.microPadding),
                decoration: BoxDecoration(
                  color: UserDesign. error. withOpacity(0.1),
                  borderRadius: BorderRadius.circular(r.borderRadius),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: UserDesign.error,
                  size: r.iconSize(20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== FILTER CHIPS ====================
  Widget _buildFilterChips(UserResponsiveData r) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.padding,
        vertical: r.microPadding,
      ),
      color: UserDesign.surfacePure,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(r, 'All', NotificationFilter.all, _viewModel.totalCount),
            SizedBox(width: r.microPadding),
            _buildFilterChip(r, 'Unread', NotificationFilter. unread, _viewModel.unreadCount),
            SizedBox(width: r.microPadding),
            _buildFilterChip(r, 'Reports', NotificationFilter.reports, null),
            SizedBox(width: r.microPadding),
            _buildFilterChip(r, 'Achievements', NotificationFilter.achievements, null),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      UserResponsiveData r,
      String label,
      NotificationFilter filter,
      int? count,
      ) {
    final isSelected = _viewModel.currentFilter == filter;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _viewModel.setFilter(filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: r.padding,
          vertical: r.microPadding,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ?  UserDesign.primaryGradient : null,
          color: isSelected ?  null : UserDesign.surfaceLight,
          borderRadius: BorderRadius.circular(r.pillBorderRadius),
          boxShadow: isSelected ? UserDesign.glowShadow(UserDesign.primaryTeal) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : UserDesign.textSecondary,
              ),
            ),
            if (count != null && count > 0) ...[
              SizedBox(width: r.atomicPadding),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r. atomicPadding + 2,
                  vertical: 2,
                ),
                decoration:  BoxDecoration(
                  color: isSelected
                      ? Colors.white. withOpacity(0.3)
                      : UserDesign.primaryTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(r.pillBorderRadius),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.inter(
                    fontSize: r.captionXS,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : UserDesign.primaryTeal,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== NOTIFICATIONS LIST ====================
  Widget _buildNotificationsList(UserResponsiveData r) {
    final groupedNotifications = _viewModel. groupedNotifications;

    if (groupedNotifications.isEmpty) {
      return _buildEmptyFilterState(r);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: UserDesign.primaryTeal,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(
          top: r.microPadding,
          bottom: r.safePaddingBottom + 100,
        ),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final group = groupedNotifications. entries.toList()[index];
          return _buildNotificationGroup(r, group. key, group.value);
        },
      ),
    );
  }

  Widget _buildNotificationGroup(
      UserResponsiveData r,
      String title,
      List<NotificationModel> notifications,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            r.padding,
            r.padding,
            r.padding,
            r.microPadding,
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: r.captionM,
              fontWeight: FontWeight.w700,
              color: UserDesign.textSecondary,
            ),
          ),
        ),
        ...notifications.map((notification) {
          return _buildNotificationCard(r, notification);
        }).toList(),
        SizedBox(height: r. microPadding),
      ],
    );
  }

  Widget _buildNotificationCard(UserResponsiveData r, NotificationModel notification) {
    final color = _viewModel.getNotificationColor(notification.type);
    final icon = _viewModel.getNotificationIcon(notification.type);

    return FadeTransition(
      opacity: _fadeAnimation,
      child:  Dismissible(
        key: Key(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: EdgeInsets.symmetric(
            horizontal: r.padding,
            vertical: r.atomicPadding,
          ),
          decoration: BoxDecoration(
            color: UserDesign.error,
            borderRadius: BorderRadius. circular(r.largeBorderRadius),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: r.padding),
          child: Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: r.iconSize(24),
          ),
        ),
        onDismissed: (direction) {
          _viewModel.deleteNotification(notification.id);
          _showSnackBar('Notification deleted');
        },
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: r.padding,
            vertical: r.atomicPadding,
          ),
          decoration: BoxDecoration(
            color: UserDesign.surfacePure,
            borderRadius:  BorderRadius.circular(r.largeBorderRadius),
            border: Border.all(
              color: ! notification.isRead
                  ? color.withOpacity(0.3)
                  : UserDesign.surfaceOverlay,
              width: ! notification.isRead ?  2 : 1,
            ),
            boxShadow: ! notification.isRead
                ? [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius:  8,
                offset:  const Offset(0, 2),
              ),
            ]
                : UserDesign.softShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                onTap:  () {
                  HapticFeedback.lightImpact();
                  if (!notification.isRead) {
                    _viewModel.markAsRead(notification.id);
                  }
                  // TODO: Navigate to related content
                },
                borderRadius: BorderRadius.circular(r.largeBorderRadius),
                child:  Padding(
                    padding: EdgeInsets.all(r.padding),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: r. dimension(48),
                          height: r. dimension(48),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.2),
                                color.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(r.borderRadius),
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: r.iconSize(24),
                          ),
                        ),

                        SizedBox(width: r.microPadding),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment:  CrossAxisAlignment.start,
                            children: [
                          Row(
                          children: [
                          Expanded(
                          child: Text(
                            notification.title,
                            style: GoogleFonts.inter(
                              fontSize: r.bodyS,
                              fontWeight:  FontWeight.w700,
                              color: UserDesign.textPrimary,
                            ),
                          ),
                        ),
                        if (! notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration:  BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: r.atomicPadding),
                    Text(
                      notification.message,
                      style: GoogleFonts.inter(
                        fontSize: r.captionM,
                        color: UserDesign.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: r.microPadding),
                    Row(
                      children: [
                      Icon(
                      Icons.access_time_rounded,
                      size: r.iconSize(12),
                      color: UserDesign.textTertiary,
                    ),
                    SizedBox(width:  r.atomicPadding),
                    Text(
                      notification.timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: r.captionXS,
                        color:  UserDesign.textTertiary,
                      ),
                    ),
                    if (notification.relatedId != null) ...[
                SizedBox(width: r.microPadding),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.nanoPadding,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius:  BorderRadius.circular(r.smallBorderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link_rounded,
                    size: r. iconSize(10),
                    color: color,
                  ),
                  SizedBox(width: r.atomicPadding),
                  Text(
                    'View',
                    style: GoogleFonts.inter(
                      fontSize: r.captionXS,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            ],
            ],
          ),
          ],
        ),
      ),
      ],
    ),
    ),
    ),
    ),
    ),
    ),
    );
  }

  // ==================== LOADING STATE ====================
  Widget _buildLoadingState(UserResponsiveData r) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: UserDesign. primaryTeal,
            strokeWidth: 3,
          ),
          SizedBox(height: r.padding),
          Text(
            'Loading notifications...',
            style: GoogleFonts.inter(
              fontSize: r.captionM,
              color: UserDesign.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(UserResponsiveData r) {
    return Center(
      child:  Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.center,
          children: [
            Container(
              width: r.dimension(120),
              height: r.dimension(120),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    UserDesign.primaryTeal.withOpacity(0.1),
                    UserDesign. purple.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: r.iconSize(60),
                color: UserDesign.textLight,
              ),
            ),
            SizedBox(height: r.largePadding),
            Text(
              'No Notifications',
              style: GoogleFonts.inter(
                fontSize: r.headingXS,
                fontWeight: FontWeight.w700,
                color: UserDesign.textPrimary,
              ),
            ),
            SizedBox(height: r. microPadding),
            Text(
              'You\'re all caught up!\nWe\'ll notify you when something happens.',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: UserDesign.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterState(UserResponsiveData r) {
    return Center(
      child:  Padding(
        padding: EdgeInsets.all(r.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: r.dimension(100),
              height: r.dimension(100),
              decoration: BoxDecoration(
                color: UserDesign.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list_off_rounded,
                size: r.iconSize(50),
                color: UserDesign.textLight,
              ),
            ),
            SizedBox(height: r.largePadding),
            Text(
              'No Results',
              style: GoogleFonts.inter(
                fontSize: r.headingXS,
                fontWeight: FontWeight.w700,
                color: UserDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.microPadding),
            Text(
              'No notifications match this filter.\nTry selecting a different filter.',
              style: GoogleFonts.inter(
                fontSize: r.captionM,
                color: UserDesign.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r. largePadding),
            GestureDetector(
              onTap: () {
                _viewModel.setFilter(NotificationFilter.all);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.largePadding,
                  vertical: r.microPadding,
                ),
                decoration: BoxDecoration(
                  gradient: UserDesign.primaryGradient,
                  borderRadius: BorderRadius.circular(r.borderRadius),
                  boxShadow: UserDesign. glowShadow(UserDesign.primaryTeal),
                ),
                child: Text(
                  'Show All',
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}