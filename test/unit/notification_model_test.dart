import 'package:flutter_test/flutter_test.dart';

import 'package:blood_donor_receiver/data/models/notification_model.dart';

void main() {
  group('AppNotification', () {
    test('toMap -> fromMap round-trip preserves all fields', () {
      final n = AppNotification(
        id: 'notif-001',
        recipientUid: 'uid-abc123',
        title: 'New blood request',
        body: 'Someone needs blood — tap to respond.',
        type: NotificationType.requestReceived,
        requestId: 'REQ-20260421-001',
        read: false,
        createdAt: DateTime.utc(2026, 4, 21, 10, 0, 0),
      );
      final again = AppNotification.fromMap(n.toMap());
      expect(again.id, n.id);
      expect(again.recipientUid, n.recipientUid);
      expect(again.title, n.title);
      expect(again.body, n.body);
      expect(again.type, n.type);
      expect(again.requestId, n.requestId);
      expect(again.read, n.read);
      expect(again.createdAt, n.createdAt);
    });

    test('copyWith flips read flag', () {
      final n = AppNotification(
        id: 'notif-002',
        recipientUid: 'uid-abc123',
        title: 'Request accepted',
        body: 'Your request was accepted.',
        type: NotificationType.requestAccepted,
        read: false,
        createdAt: DateTime.utc(2026, 4, 21),
      );
      final read = n.copyWith(read: true);
      expect(read.read, isTrue);
      expect(read.id, n.id);
      expect(read.title, n.title);
    });

    test('all NotificationTypes survive wire round-trip', () {
      for (final type in NotificationType.values) {
        final parsed = NotificationTypeMeta.parse(type.wire);
        expect(parsed, type, reason: '${type.wire} should round-trip');
      }
    });

    test('unknown type defaults to requestReceived', () {
      final parsed = NotificationTypeMeta.parse('unknownType');
      expect(parsed, NotificationType.requestReceived);
    });

    test('requestId is nullable and survives null round-trip', () {
      final n = AppNotification(
        id: 'notif-003',
        recipientUid: 'uid-xyz',
        title: 'Test',
        body: 'Test body',
        type: NotificationType.statusCompleted,
        requestId: null,
        read: true,
        createdAt: DateTime.utc(2026, 4, 21),
      );
      final again = AppNotification.fromMap(n.toMap());
      expect(again.requestId, isNull);
    });
  });
}