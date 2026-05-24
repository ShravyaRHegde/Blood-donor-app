import 'stats_repository.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../core/utils/id_generator.dart';
import '../models/donor_model.dart';

class DonorRepository {
  DatabaseReference get _ref => FirebaseDatabase.instance.ref('donors');

  Future<DonorToken> create({
    required String ownerEmail,
    required String name,
    required String bloodGroup,
    required String location,
    required String phone,
    String lastDonationDate = '',
  }) async {
    final id = await IdGenerator.donor();
    final token = DonorToken(
      id: id,
      ownerEmail: ownerEmail.toLowerCase(),
      name: name,
      bloodGroup: bloodGroup,
      location: location,
      phone: phone,
      lastDonationDate: lastDonationDate,
      createdAt: DateTime.now(),
    );
    await _ref
        .child(token.id)
        .set(token.toMap())
        .timeout(const Duration(seconds: 8));
    return token;
  }

  /// Used when a request is accepted: pin the request + remove from search list.
  Future<void> closeOnAcceptance(String id, String requestId) async {
    await _ref.child(id).update({
      'closed': true,
      'acceptedRequestId': requestId,
    }).timeout(const Duration(seconds: 8));
    unawaited(StatsRepository.increment('donors'));
  }
}
