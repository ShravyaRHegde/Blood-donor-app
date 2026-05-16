import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/id_generator.dart';
import '../models/receiver_model.dart';

class ReceiverRepository {
  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('receivers');

  Future<ReceiverToken> create({
    required String ownerEmail,
    required String name,
    required String bloodGroup,
    required String location,
    required String phone,
    required String cause,
    String causeOther = '',
    required int unitsNeeded,
  }) async {
    final id = await IdGenerator.receiver();
    final token = ReceiverToken(
      id: id,
      ownerEmail: ownerEmail.toLowerCase(),
      name: name,
      bloodGroup: bloodGroup,
      location: location,
      phone: phone,
      cause: cause,
      causeOther: causeOther,
      unitsNeeded: unitsNeeded,
      createdAt: DateTime.now(),
    );
    await _col.doc(token.id).set(token.toMap());
    return token;
  }

  Future<void> close(String id) async {
    await _col.doc(id).update({'closed': true});
  }
}
