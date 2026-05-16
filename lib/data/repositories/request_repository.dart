import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/id_generator.dart';
import '../models/request_model.dart';

class RequestRepository {
  RequestRepository();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    await _db.collection('requests').doc(req.id).set(req.toMap());
    return req;
  }

  /// Atomically advances a request's status. On [RequestStatus.accepted],
  /// the associated donor token is closed in the same transaction, so the
  /// request and donor either both update or neither does.
  Future<BloodRequest> updateStatus(String id, RequestStatus status) {
    return _db.runTransaction<BloodRequest>((tx) async {
      final reqRef = _db.collection('requests').doc(id);
      final reqSnap = await tx.get(reqRef);
      if (!reqSnap.exists) {
        throw StateError('Request not found: $id');
      }
      final existing = BloodRequest.fromMap(
        Map<String, dynamic>.from(reqSnap.data()!),
      );

      if (status == RequestStatus.accepted) {
        final donorRef = _db.collection('donors').doc(existing.donorTokenId);
        final donorSnap = await tx.get(donorRef);
        if (!donorSnap.exists) {
          throw StateError('Donor token not found: ${existing.donorTokenId}');
        }
        tx.update(donorRef, {
          'closed': true,
          'acceptedRequestId': existing.id,
        });
      }

      final updated =
          existing.copyWith(status: status, updatedAt: DateTime.now());
      tx.set(reqRef, updated.toMap());
      return updated;
    });
  }
}
