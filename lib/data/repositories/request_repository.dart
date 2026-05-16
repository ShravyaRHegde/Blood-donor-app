import 'package:firebase_database/firebase_database.dart';

import '../../core/utils/id_generator.dart';
import '../models/request_model.dart';

class RequestRepository {
  RequestRepository();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<BloodRequest> create({
    required String donorTokenId,
    required String receiverTokenId,
    required String senderEmail,
    required String recipientEmail,
  }) async {
    final id = await IdGenerator.request();
    final req = BloodRequest(
      id: id,
      donorTokenId: donorTokenId,
      receiverTokenId: receiverTokenId,
      senderEmail: senderEmail.toLowerCase(),
      recipientEmail: recipientEmail.toLowerCase(),
      status: RequestStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db
        .ref('requests/${req.id}')
        .set(req.toMap())
        .timeout(const Duration(seconds: 8));
    return req;
  }

  /// Atomically advances a request's status. On [RequestStatus.accepted],
  /// the associated donor token is closed in the same multi-path update,
  /// so the request and donor either both update or neither does (RTDB
  /// guarantees atomicity for a single `update()` call on the root ref
  /// with slash-separated keys).
  Future<BloodRequest> updateStatus(String id, RequestStatus status) async {
    final reqRef = _db.ref('requests/$id');
    final reqSnap = await reqRef.get().timeout(const Duration(seconds: 8));
    if (reqSnap.value == null) {
      throw StateError('Request not found: $id');
    }
    final existing = BloodRequest.fromMap(
      Map<String, dynamic>.from(reqSnap.value as Map),
    );

    final updated =
        existing.copyWith(status: status, updatedAt: DateTime.now());

    if (status == RequestStatus.accepted) {
      final donorRef = _db.ref('donors/${existing.donorTokenId}');
      final donorSnap =
          await donorRef.get().timeout(const Duration(seconds: 8));
      if (donorSnap.value == null) {
        throw StateError('Donor token not found: ${existing.donorTokenId}');
      }

      await _db.ref().update({
        'requests/$id': updated.toMap(),
        'donors/${existing.donorTokenId}/closed': true,
        'donors/${existing.donorTokenId}/acceptedRequestId': updated.id,
      }).timeout(const Duration(seconds: 8));
    } else {
      await reqRef
          .set(updated.toMap())
          .timeout(const Duration(seconds: 8));
    }

    return updated;
  }
}
