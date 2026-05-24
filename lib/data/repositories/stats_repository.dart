import 'package:firebase_database/firebase_database.dart';

class StatsRepository {
  StatsRepository._();

  static final _ref = FirebaseDatabase.instance.ref('stats/global');

  static Future<void> increment(String field) async {
    try {
      await _ref.child(field).runTransaction((Object? current) {
        final n = (current is int ? current : 0) + 1;
        return Transaction.success(n);
      });
    } catch (_) {
      // Stats are non-critical — never let a failure block the main flow.
    }
  }

  /// Returns a live stream of {donors, requests, donations}.
  static Stream<Map<String, int>> stream() {
    return _ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null || val is! Map) return {'donors': 0, 'requests': 0, 'donations': 0};
      final m = Map<String, dynamic>.from(val);
      return {
        'donors':    _toInt(m['donors']),
        'requests':  _toInt(m['requests']),
        'donations': _toInt(m['donations']),
      };
    });
  }

  static int _toInt(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }
}