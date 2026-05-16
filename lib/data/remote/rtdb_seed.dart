import 'package:firebase_database/firebase_database.dart';

import '../../core/utils/id_generator.dart';
import '../models/donor_model.dart';

/// Pre-loads six seed donor tokens across blood groups and cities so the
/// "Find Donor" screen is populated for any user. Gated by a meta node
/// claimed inside an RTDB transaction so multiple clients booting the app
/// can't double-insert.
class RtdbSeed {
  RtdbSeed._();

  static const _seedKey = 'seed_v1';
  static const _seedOwnerEmail = 'seed@community.local';

  static FirebaseDatabase get _db => FirebaseDatabase.instance;

  static Future<void> ensureSeeded() async {
    final metaRef = _db.ref('meta/$_seedKey');

    final existing =
        await metaRef.get().timeout(const Duration(seconds: 6));
    if (existing.value is Map) {
      final m = Map<String, dynamic>.from(existing.value as Map);
      if (m['done'] == true) return;
    }

    final claim = await metaRef.runTransaction((Object? current) {
      if (current is Map && current['done'] == true) {
        return Transaction.abort();
      }
      return Transaction.success(<String, Object?>{
        'done': false,
        'startedAt': ServerValue.timestamp,
      });
    });
    if (!claim.committed) return;

    final now = DateTime.now();
    final seeds = <_Seed>[
      _Seed('Anitha K', 'O+', 'Bengaluru, Karnataka', '9876543201', '2026-01-10'),
      _Seed('Ramesh Pillai', 'A+', 'Chennai, Tamil Nadu', '9876543202', '2025-11-22'),
      _Seed('Divya Sharma', 'B+', 'Mumbai, Maharashtra', '9876543203', '2026-02-04'),
      _Seed('Ibrahim Khan', 'AB+', 'Hyderabad, Telangana', '9876543204', '2025-09-18'),
      _Seed('Priya Menon', 'O-', 'Kochi, Kerala', '9876543205', '2026-03-01'),
      _Seed('Arjun Reddy', 'B-', 'Pune, Maharashtra', '9876543206', '2025-12-12'),
    ];

    final donorsRoot = _db.ref('donors');
    for (var i = 0; i < seeds.length; i++) {
      final s = seeds[i];
      final id = await IdGenerator.donor();
      final token = DonorToken(
        id: id,
        ownerEmail: _seedOwnerEmail,
        name: s.name,
        bloodGroup: s.bloodGroup,
        location: s.location,
        phone: s.phone,
        lastDonationDate: s.lastDonation,
        createdAt: now.subtract(Duration(hours: i * 6)),
      );
      await donorsRoot.child(id).set(token.toMap());
    }

    await metaRef.set(<String, Object?>{
      'done': true,
      'completedAt': ServerValue.timestamp,
      'count': seeds.length,
    });
  }
}

class _Seed {
  final String name;
  final String bloodGroup;
  final String location;
  final String phone;
  final String lastDonation;
  const _Seed(
    this.name,
    this.bloodGroup,
    this.location,
    this.phone,
    this.lastDonation,
  );
}
