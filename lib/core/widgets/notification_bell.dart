// lib/core/widgets/notification_bell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/sg_colors.dart';
import '../services/notification_service.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: NotificationService.getUnreadCount(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return GestureDetector(
          onTap: () => context.push('/notifications'),
          child: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: SGColors.htmlPink,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
