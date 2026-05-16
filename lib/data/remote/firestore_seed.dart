import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/id_generator.dart';
import '../models/donor_model.dart';

/// Pre-loads six seed donor tokens across blood groups and cities so the
/// "Find Donor" screen is populated for any user. Seeding is gated by a
/// meta doc so multiple clients booting the app can't double-insert.
class FirestoreSeed {
  FirestoreSeed._();

  static const _seedDocId = 'seed_v1';
  static const _seedOwnerEmail = 'seed@community.local';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static Future<void> ensureSeeded() async {
    final metaRef = _db.collection('meta').doc(_seedDocId);
    final already = await metaRef.get();
    if (already.exists && already.data()?['done'] == true) return;

    // Race guard: claim the seed slot inside a transaction so two clients
    // booting simultaneously don't both run the loop.
    final shouldRun = await _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(metaRef);
      if (snap.exists && snap.data()?['done'] == true) return false;
      tx.set(metaRef, {
        'done': false,
        'startedAt': FieldValue.serverTimestamp(),
      });
      return true;
    });
    if (!shouldRun) return;

    final now = DateTime.now();
    final seeds = <_Seed>[
      _Seed('Anitha K', 'O+', 'Bengaluru, Karnataka', '9876543201', '2026-01-10'),
      _Seed('Ramesh Pillai', 'A+', 'Chennai, Tamil Nadu', '9876543202', '2025-11-22'),
      _Seed('Divya Sharma', 'B+', 'Mumbai, Maharashtra', '9876543203', '2026-02-04'),
      _Seed('Ibrahim Khan', 'AB+', 'Hyderabad, Telangana', '9876543204', '2025-09-18'),
      _Seed('Priya Menon', 'O-', 'Kochi, Kerala', '9876543205', '2026-03-01'),
      _Seed('Arjun Reddy', 'B-', 'Pune, Maharashtra', '9876543206', '2025-12-12'),
    ];

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
      await _db.collection('donors').doc(token.id).set(token.toMap());
    }

    await metaRef.set({
      'done': true,
      'completedAt': FieldValue.serverTimestamp(),
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
