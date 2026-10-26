import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/notification_model.dart';
import '../../services/auth_notifier.dart';
import '../../services/mock_support_services.dart';

/// In-app notifications center for KaamHub.
class NotificationsScreen extends StatefulWidget {
  final AuthNotifier? authNotifier;

  const NotificationsScreen({super.key, this.authNotifier});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final MockNotificationService _service = MockNotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  String get _userId =>
      widget.authNotifier?.currentUser?.uid ?? 'customer_demo_001';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifs = await _service.getNotificationsForUser(_userId);
    if (mounted) {
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    await _service.markAllRead(_userId);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded,
                          size: 56, color: AppColors.textMuted),
                      SizedBox(height: 16),
                      Text('No notifications',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: AppConstants.paddingScreen,
                    itemCount: _notifications.length,
                    separatorBuilder: (_, r) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      return _NotificationCard(
                        notification: notif,
                        onTap: () async {
                          await _service.markRead(notif.id);
                          _loadNotifications();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.newMessage:
        return Icons.chat_bubble_rounded;
      case NotificationType.bookingAccepted:
      case NotificationType.newRequest:
        return Icons.work_rounded;
      case NotificationType.jobCompleted:
        return Icons.task_alt_rounded;
      case NotificationType.applicationApproved:
        return Icons.verified_rounded;
      case NotificationType.applicationRejected:
        return Icons.cancel_rounded;
      case NotificationType.quoteReceived:
        return Icons.request_quote_rounded;
      case NotificationType.securityAlert:
        return Icons.security_rounded;
      case NotificationType.reportStatusUpdate:
        return Icons.report_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.applicationApproved:
      case NotificationType.jobCompleted:
        return AppColors.success;
      case NotificationType.applicationRejected:
        return AppColors.error;
      case NotificationType.securityAlert:
        return AppColors.warning;
      case NotificationType.newMessage:
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.surface
            : AppColors.primary.withAlpha(8),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: notification.isRead
              ? AppColors.cardBorder
              : AppColors.primary.withAlpha(40),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _iconColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notification.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: AppColors.textPrimary,
                              )),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.body,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
