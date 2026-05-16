import 'package:firebase_database/firebase_database.dart';

import '../../core/utils/id_generator.dart';
import '../models/receiver_model.dart';

class ReceiverRepository {
  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('receivers');

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
    await _ref
        .child(token.id)
        .set(token.toMap())
        .timeout(const Duration(seconds: 8));
    return token;
  }

  Future<void> close(String id) async {
    await _ref
        .child(id)
        .update({'closed': true}).timeout(const Duration(seconds: 8));
  }
}
