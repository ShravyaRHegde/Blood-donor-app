import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/id_generator.dart';
import '../models/donor_model.dart';

class DonorRepository {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('donors');

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
    await _col.doc(token.id).set(token.toMap());
    return token;
  }

  /// Used when a request is accepted: pin the request + remove from search list.
  Future<void> closeOnAcceptance(String id, String requestId) async {
    await _col.doc(id).update({
      'closed': true,
      'acceptedRequestId': requestId,
    });
  }
}
