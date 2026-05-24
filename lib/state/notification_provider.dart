import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();
  StreamSubscription<List<AppNotification>>? _sub;

  List<AppNotification> _notifications = const [];

  List<AppNotification> get all => _notifications;

  int get unreadCount =>
      _notifications.where((n) => !n.read).length;

  bool get hasUnread => unreadCount > 0;

  /// Call this after the user logs in with their Firebase uid.
  void init(String uid) {
    _sub?.cancel();
    _notifications = const [];
    _sub = _repo.stream(uid).listen((list) {
      _notifications = list;
      notifyListeners();
    });
  }

  /// Call this on logout to stop listening and clear data.
  void clear() {
    _sub?.cancel();
    _sub = null;
    _notifications = const [];
    notifyListeners();
  }

  Future<void> markRead(String uid, String notificationId) async {
    await _repo.markRead(uid, notificationId);
  }

  Future<void> markAllRead(String uid) async {
    await _repo.markAllRead(uid);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}