import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/donor_model.dart';
import '../data/repositories/donor_repository.dart';

class DonorProvider extends ChangeNotifier {
  final DonorRepository _repo = DonorRepository();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

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
    _sub = FirebaseFirestore.instance
        .collection('donors')
        .snapshots()
        .listen((snap) {
      final next = snap.docs
          .map((d) => DonorToken.fromMap(d.data()))
          .toList();
      next.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _all = next;
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
