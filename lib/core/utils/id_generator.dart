import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

/// Mints readable tokens like DNR-20260420-001 / RCV-... / REQ-...
///
/// Sequence counters live at `counters/{prefix_YYYYMMDD}` in Realtime
/// Database. Each mint runs as an RTDB transaction so two concurrent
/// callers — even on different devices — can't read-then-write the same
/// counter and produce duplicate IDs. RTDB's optimistic concurrency
/// retries one of the racers automatically.
class IdGenerator {
  IdGenerator._();

  static const _prefixDonor = 'DNR';
  static const _prefixReceiver = 'RCV';
  static const _prefixRequest = 'REQ';

  static FirebaseDatabase get _db => FirebaseDatabase.instance;

  static Future<String> donor() => _mint(_prefixDonor);
  static Future<String> receiver() => _mint(_prefixReceiver);
  static Future<String> request() => _mint(_prefixRequest);

  static Future<String> _mint(String prefix) async {
    final today = DateFormat('yyyyMMdd').format(DateTime.now());
    final ref = _db.ref('counters/${prefix}_$today');

    final result = await ref.runTransaction((Object? current) {
      final n = _coerceInt(current) + 1;
      return Transaction.success(n);
    });

    final n = _coerceInt(result.snapshot.value);
    return '$prefix-$today-${n.toString().padLeft(3, '0')}';
  }

  static int _coerceInt(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
