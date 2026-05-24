import 'package:firebase_database/firebase_database.dart';

import '../../core/utils/id_generator.dart';
import '../models/notification_model.dart';
import '../models/request_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/notification_repository.dart';

class RequestRepository {
  RequestRepository();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final NotificationRepository _notifRepo = NotificationRepository();
  final AuthRepository _authRepo = AuthRepository();

  Future<BloodRequest> create({
    required String donorTokenId,
    required String receiverTokenId,
    required String senderEmail,
    required String recipientEmail,
    required String receiverName,
    required String donorName,
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

    // Notify the donor that a request was received
    final donorUid = await _authRepo.uidByEmail(recipientEmail);
    if (donorUid != null) {
      await _notifRepo.create(
        recipientUid: donorUid,
        title: 'New blood request',
        body: '$receiverName needs blood — tap to respond.',
        type: NotificationType.requestReceived,
        requestId: id,
      );
    }

    return req;
  }

  Future<BloodRequest> updateStatus(
    String id,
    RequestStatus status, {
    String? receiverName,
    String? donorName,
  }) async {
    final reqRef = _db.ref('requests/$id');
    final reqSnap =
        await reqRef.get().timeout(const Duration(seconds: 8));
    if (reqSnap.value == null) {
      throw StateError('Request not found: $id');
    }
    final existing = BloodRequest.fromMap(
      Map<String, dynamic>.from(reqSnap.value as Map),
    );

    final updated =
        existing.copyWith(status: status, updatedAt: DateTime.now());

    if (status == RequestStatus.accepted) {
      // Atomic update — close donor + accept request together
      await _db.ref().update({
        'requests/$id': updated.toMap(),
        'donors/${existing.donorTokenId}/closed': true,
        'donors/${existing.donorTokenId}/acceptedRequestId': updated.id,
      }).timeout(const Duration(seconds: 8));

      // Notify receiver that request was accepted
      final receiverUid =
          await _authRepo.uidByEmail(existing.senderEmail);
      if (receiverUid != null) {
        await _notifRepo.create(
          recipientUid: receiverUid,
          title: 'Request accepted!',
          body:
              '${donorName ?? 'A donor'} has accepted your blood request.',
          type: NotificationType.requestAccepted,
          requestId: id,
        );
      }
    } else {
      await reqRef
          .set(updated.toMap())
          .timeout(const Duration(seconds: 8));

      // Notify based on status
      switch (status) {
        case RequestStatus.declined:
          final receiverUid =
              await _authRepo.uidByEmail(existing.senderEmail);
          if (receiverUid != null) {
            await _notifRepo.create(
              recipientUid: receiverUid,
              title: 'Request declined',
              body:
                  '${donorName ?? 'The donor'} could not accept your request. Try another donor.',
              type: NotificationType.requestDeclined,
              requestId: id,
            );
          }
          break;

        case RequestStatus.withdrawn:
          final donorUid =
              await _authRepo.uidByEmail(existing.recipientEmail);
          if (donorUid != null) {
            await _notifRepo.create(
              recipientUid: donorUid,
              title: 'Request withdrawn',
              body:
                  '${receiverName ?? 'The receiver'} has withdrawn their request.',
              type: NotificationType.requestWithdrawn,
              requestId: id,
            );
          }
          break;

        case RequestStatus.contacted:
          final receiverUid =
              await _authRepo.uidByEmail(existing.senderEmail);
          if (receiverUid != null) {
            await _notifRepo.create(
              recipientUid: receiverUid,
              title: 'Donor contacted you',
              body:
                  '${donorName ?? 'The donor'} has contacted the patient.',
              type: NotificationType.statusContacted,
              requestId: id,
            );
          }
          break;

        case RequestStatus.arranged:
          final receiverUid =
              await _authRepo.uidByEmail(existing.senderEmail);
          if (receiverUid != null) {
            await _notifRepo.create(
              recipientUid: receiverUid,
              title: 'Blood arranged',
              body:
                  '${donorName ?? 'The donor'} has arranged the blood.',
              type: NotificationType.statusArranged,
              requestId: id,
            );
          }
          break;

        case RequestStatus.completed:
          final receiverUid =
              await _authRepo.uidByEmail(existing.senderEmail);
          if (receiverUid != null) {
            await _notifRepo.create(
              recipientUid: receiverUid,
              title: 'Donation complete',
              body: 'The blood donation is complete. Thank you!',
              type: NotificationType.statusCompleted,
              requestId: id,
            );
          }
          break;

        default:
          break;
      }
    }

    return updated;
  }
}