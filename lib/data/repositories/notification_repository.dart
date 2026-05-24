import 'package:firebase_database/firebase_database.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference _ref(String uid) =>
      _db.ref('notifications/$uid');

  /// Creates a notification for a specific user (by uid).
  Future<void> create({
    required String recipientUid,
    required String title,
    required String body,
    required NotificationType type,
    String? requestId,
  }) async {
    final ref = _ref(recipientUid).push();
    final id = ref.key!;
    final notification = AppNotification(
      id: id,
      recipientUid: recipientUid,
      title: title,
      body: body,
      type: type,
      requestId: requestId,
      read: false,
      createdAt: DateTime.now(),
    );
    await ref
        .set(notification.toMap())
        .timeout(const Duration(seconds: 8));
  }

  /// Marks a single notification as read.
  Future<void> markRead(String uid, String notificationId) async {
    await _ref(uid)
        .child(notificationId)
        .update({'read': true}).timeout(const Duration(seconds: 8));
  }

  /// Marks all notifications as read for a user.
  Future<void> markAllRead(String uid) async {
    final snap =
        await _ref(uid).get().timeout(const Duration(seconds: 8));
    if (snap.value == null) return;
    final map = Map<dynamic, dynamic>.from(snap.value as Map);
    final updates = <String, dynamic>{};
    for (final key in map.keys) {
      updates['$key/read'] = true;
    }
    if (updates.isNotEmpty) {
      await _ref(uid)
          .update(updates)
          .timeout(const Duration(seconds: 8));
    }
  }

  /// Returns a stream of all notifications for a user, newest first.
  Stream<List<AppNotification>> stream(String uid) {
    return _ref(uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return <AppNotification>[];
      if (value is! Map) return <AppNotification>[];
      final list = Map<dynamic, dynamic>.from(value)
          .values
          .map((v) => AppNotification.fromMap(
                Map<String, dynamic>.from(v as Map),
              ))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}