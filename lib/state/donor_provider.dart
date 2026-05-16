import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../data/models/donor_model.dart';
import '../data/repositories/donor_repository.dart';

class DonorProvider extends ChangeNotifier {
  final DonorRepository _repo = DonorRepository();
  StreamSubscription<DatabaseEvent>? _sub;

  List<DonorToken> _all = const [];
  List<DonorToken> get all => _all;

  List<DonorToken> get available => _all.where((d) => !d.closed).toList();

  List<DonorToken> byOwner(String email) =>
      _all.where((d) => d.ownerEmail == email.toLowerCase()).toList();

  DonorToken? byId(String id) {
    for (final d in _all) {
      if (d.id == id) return d;
    }
    return null;
  }

  void init() {
    _sub = FirebaseDatabase.instance.ref('donors').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) {
        _all = const [];
      } else if (value is Map) {
        final map = Map<dynamic, dynamic>.from(value);
        final next = map.values
            .map((v) => DonorToken.fromMap(Map<String, dynamic>.from(v as Map)))
            .toList();
        next.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _all = next;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  Future<DonorToken> create({
    required String ownerEmail,
    required String name,
    required String bloodGroup,
    required String location,
    required String phone,
    String lastDonationDate = '',
  }) =>
      _repo.create(
        ownerEmail: ownerEmail,
        name: name,
        bloodGroup: bloodGroup,
        location: location,
        phone: phone,
        lastDonationDate: lastDonationDate,
      );

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
