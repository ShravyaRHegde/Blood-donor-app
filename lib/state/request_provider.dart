import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../data/models/request_model.dart';
import '../data/repositories/request_repository.dart';

class RequestProvider extends ChangeNotifier {
  final RequestRepository _repo = RequestRepository();
  StreamSubscription<DatabaseEvent>? _sub;

  List<BloodRequest> _all = const [];
  List<BloodRequest> get all => _all;

  List<BloodRequest> bySender(String email) =>
      _all.where((r) => r.senderEmail == email.toLowerCase()).toList();

  List<BloodRequest> byRecipient(String email) =>
      _all.where((r) => r.recipientEmail == email.toLowerCase()).toList();

  List<BloodRequest> forDonorToken(String donorTokenId) =>
      _all.where((r) => r.donorTokenId == donorTokenId).toList();

  BloodRequest? byId(String id) {
    for (final r in _all) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Existing active (non-terminal) request between this receiver token
  /// and this donor token, if any.
  BloodRequest? activeBetween({
    required String donorTokenId,
    required String receiverTokenId,
  }) {
    for (final r in _all) {
      if (r.donorTokenId == donorTokenId &&
          r.receiverTokenId == receiverTokenId &&
          r.status.isActive) {
        return r;
      }
    }
    return null;
  }

  void init() {
    _sub = FirebaseDatabase.instance.ref('requests').onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) {
        _all = const [];
      } else if (value is Map) {
        final map = Map<dynamic, dynamic>.from(value);
        final next = map.values
            .map((v) =>
                BloodRequest.fromMap(Map<String, dynamic>.from(v as Map)))
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _all = next;
      } else {
        _all = const [];
      }
      notifyListeners();
    });
    notifyListeners();
  }

  Future<BloodRequest> send({
    required String donorTokenId,
    required String receiverTokenId,
    required String senderEmail,
    required String recipientEmail,
  }) =>
      _repo.create(
        donorTokenId: donorTokenId,
        receiverTokenId: receiverTokenId,
        senderEmail: senderEmail,
        recipientEmail: recipientEmail,
      );

  Future<BloodRequest> advance(String id, RequestStatus next) =>
      _repo.updateStatus(id, next);

  Future<void> withdraw(String id) =>
      _repo.updateStatus(id, RequestStatus.withdrawn);

  Future<void> decline(String id) =>
      _repo.updateStatus(id, RequestStatus.declined);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
