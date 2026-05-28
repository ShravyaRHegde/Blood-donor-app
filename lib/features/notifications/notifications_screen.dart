import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/notification_model.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../state/auth_provider.dart';
import '../../state/donor_provider.dart';
import '../../state/notification_provider.dart';
import '../../state/request_provider.dart';
import '../donor/donor_token_requests_screen.dart';
import '../receiver/receiver_status_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().current;
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.all;

    if (user != null && notifProvider.hasUnread) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifProvider.markAllRead(user.uid);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const AppHeader(
            eyebrow: 'Updates',
            title: 'Notifications',
          ),
          Expanded(
            child: notifications.isEmpty
                ? const EmptyState(
                    headline: 'No notifications yet',
                    body:
                        'When donors respond to your requests or receivers contact you, updates appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      return _NotificationCard(
                        notification: n,
                        onTap: n.requestId != null
                            ? () => _navigate(context, n)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, AppNotification n) {
    final requestId = n.requestId!;

    // Donor-side notifications → find the donor token, open DonorTokenRequestsScreen
    if (n.type == NotificationType.requestReceived ||
        n.type == NotificationType.requestWithdrawn) {
      final req = context.read<RequestProvider>().byId(requestId);
      if (req == null) return;
      final donorToken =
          context.read<DonorProvider>().byId(req.donorTokenId);
      if (donorToken == null) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => DonorTokenRequestsScreen(token: donorToken),
      ));
      return;
    }

    // All other types → receiver-side status screen
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReceiverStatusScreen(requestId: requestId),
    ));
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  const _NotificationCard({required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.read
              ? AppColors.surface
              : AppColors.surfaceMuted,
          border: Border.all(
            color: notification.read
                ? AppColors.hairline
                : AppColors.hairlineStrong,
            width: 1,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _iconBg(notification.type),
                borderRadius: const BorderRadius.all(Radius.circular(2)),
              ),
              child: Icon(_icon(notification.type), size: 18,
                  color: AppColors.onMaroon),
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
                            style: AppText.bodyStrong(size: 14)),
                      ),
                      if (!notification.read)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.maroon,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(notification.body,
                      style: AppText.body(
                          color: AppColors.inkMuted, size: 13)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(_timeAgo(notification.createdAt),
                          style: AppText.caption(
                              color: AppColors.inkFaint, size: 11)),
                      if (onTap != null) ...[
                        const Spacer(),
                        Text(
                          'View →',
                          style: AppText.caption(
                                  color: AppColors.maroon, size: 11)
                              .copyWith(fontWeight: FontWeight.w600),
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
    );
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.requestReceived:
        return Icons.volunteer_activism_outlined;
      case NotificationType.requestAccepted:
        return Icons.check_circle_outline_rounded;
      case NotificationType.requestDeclined:
        return Icons.cancel_outlined;
      case NotificationType.requestWithdrawn:
        return Icons.undo_rounded;
      case NotificationType.statusContacted:
        return Icons.phone_outlined;
      case NotificationType.statusArranged:
        return Icons.bloodtype_outlined;
      case NotificationType.statusCompleted:
        return Icons.favorite_outline_rounded;
    }
  }

  Color _iconBg(NotificationType type) {
    switch (type) {
      case NotificationType.requestDeclined:
        return AppColors.danger;
      case NotificationType.requestWithdrawn:
        return AppColors.inkMuted;
      case NotificationType.statusCompleted:
        return AppColors.success;
      default:
        return AppColors.maroon;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }
}