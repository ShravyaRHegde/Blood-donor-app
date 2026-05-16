import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/receiver_model.dart';
import '../data/repositories/receiver_repository.dart';

class ReceiverProvider extends ChangeNotifier {
  final ReceiverRepository _repo = ReceiverRepository();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  List<ReceiverToken> _all = const [];
  List<ReceiverToken> get all => _all;

  List<ReceiverToken> byOwner(String email) =>
      _all.where((r) => r.ownerEmail == email.toLowerCase()).toList();

  ReceiverToken? byId(String id) {
    for (final r in _all) {
      if (r.id == id) return r;
    }
    return null;
  }

  void init() {
    _sub = FirebaseFirestore.instance
        .collection('receivers')
        .snapshots()
        .listen((snap) {
      final list =
          snap.docs.map((d) => ReceiverToken.fromMap(d.data())).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _all = list;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<ReceiverToken> create({
    required String ownerEmail,
    required String name,
    required String bloodGroup,
    required String location,
    required String phone,
    required String cause,
    String causeOther = '',
    required int unitsNeeded,
  }) =>
      _repo.create(
        ownerEmail: ownerEmail,
        name: name,
        bloodGroup: bloodGroup,
        location: location,
        phone: phone,
        cause: cause,
        causeOther: causeOther,
        unitsNeeded: unitsNeeded,
      );

  Future<void> close(String id) => _repo.close(id);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
