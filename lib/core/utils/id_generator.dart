import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Mints readable tokens like DNR-20260420-001 / RCV-... / REQ-...
///
/// Sequence counters live in a `counters/{prefix_YYYYMMDD}` doc in Firestore.
/// Each mint runs as a Firestore transaction so two concurrent callers — even
/// on different devices — can never read-then-write the same counter and
/// produce duplicate IDs. Firestore's optimistic concurrency retries one of
/// the racers until the read snapshot is fresh.
class IdGenerator {
  IdGenerator._();

  static const _prefixDonor = 'DNR';
  static const _prefixReceiver = 'RCV';
  static const _prefixRequest = 'REQ';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static Future<String> donor() => _mint(_prefixDonor);
  static Future<String> receiver() => _mint(_prefixReceiver);
  static Future<String> request() => _mint(_prefixRequest);

  static Future<String> _mint(String prefix) async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final ref = _db.collection('counters').doc('${prefix}_$today');
    final next = await _db.runTransaction<int>((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['value'] as int?) ?? 0;
      final n = current + 1;
      tx.set(ref, {'value': n, 'updatedAt': FieldValue.serverTimestamp()});
      return n;
    });
    return '$prefix-$today-${next.toString().padLeft(3, '0')}';
  }
}
