// lib/features/notifications/presentation/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/sg_colors.dart';
import '../../../../core/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SGColors.carbonBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: SGColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildNotificationsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            'NOTIFICATIONS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Colors.white),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => NotificationService.markAllAsRead(),
            child: const Text('Mark all read', style: TextStyle(color: SGColors.htmlViolet, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: NotificationService.getUserNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SGColors.htmlViolet));
        }

        final notifications = snapshot.data?.docs ?? [];

        if (notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 60, color: SGColors.htmlMuted),
                SizedBox(height: 16),
                Text('No notifications yet', style: TextStyle(fontSize: 16, color: SGColors.htmlMuted)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index].data() as Map<String, dynamic>;
            final notificationId = notifications[index].id;
            return _buildNotificationItem(notificationId, notification);
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(String id, Map<String, dynamic> notification) {
    final isRead = notification['read'] ?? false;
    final title = notification['title'] ?? '';
    final body = notification['body'] ?? '';
    final createdAt = notification['createdAt'] as Timestamp?;
    final timeAgo = createdAt != null ? _getTimeAgo(createdAt.toDate()) : '';

    return GestureDetector(
      onTap: () => NotificationService.markAsRead(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isRead ? SGColors.htmlGlass : SGColors.htmlViolet.withOpacity(0.1),
          border: Border.all(color: isRead ? SGColors.borderSubtle : SGColors.htmlViolet.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: SGColors.htmlViolet.withOpacity(0.2),
              ),
              child: const Icon(Icons.notifications, color: SGColors.htmlViolet, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: SGColors.htmlViolet),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: const TextStyle(fontSize: 13, color: SGColors.htmlMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(timeAgo, style: const TextStyle(fontSize: 11, color: SGColors.htmlMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
