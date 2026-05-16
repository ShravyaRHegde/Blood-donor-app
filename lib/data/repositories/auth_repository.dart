import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

enum AuthOutcome { success, emailTaken, invalidCredentials, unknownEmail }

class AuthResult {
  final AuthOutcome outcome;
  final AppUser? user;
  const AuthResult(this.outcome, [this.user]);
}

/// AuthRepository wraps Firebase Auth + Firestore so the rest of the app
/// keeps talking to a stable surface (signUp / logIn / logOut / updateProfile).
/// Identity comes from Firebase Auth; the editable profile fields live in
/// the `users/{uid}` Firestore doc.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  /// Streams the auth-state user-record pair. Providers listen to this to
  /// rebuild whenever the user signs in or out.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get firebaseUser => _auth.currentUser;

  Future<AppUser?> fetchProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return AppUser.fromMap(data);
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final user = cred.user!;
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? email.toLowerCase(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );
      await _users.doc(user.uid).set(appUser.toMap());
      return AuthResult(AuthOutcome.success, appUser);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return const AuthResult(AuthOutcome.emailTaken);
        case 'weak-password':
        case 'invalid-email':
          return const AuthResult(AuthOutcome.invalidCredentials);
        default:
          return const AuthResult(AuthOutcome.invalidCredentials);
      }
    }
  }

  Future<AuthResult> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final profile = await fetchProfile(cred.user!.uid);
      // Profile doc missing — should be unreachable after signUp wrote it,
      // but we recover by creating a minimal record so the user can finish
      // profile setup rather than getting stuck.
      final user = profile ??
          AppUser(
            uid: cred.user!.uid,
            email: cred.user!.email ?? email.toLowerCase(),
            name: '',
            createdAt: DateTime.now(),
          );
      if (profile == null) {
        await _users.doc(user.uid).set(user.toMap());
      }
      return AuthResult(AuthOutcome.success, user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return const AuthResult(AuthOutcome.unknownEmail);
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return const AuthResult(AuthOutcome.invalidCredentials);
        default:
          return const AuthResult(AuthOutcome.invalidCredentials);
      }
    }
  }

  Future<void> logOut() => _auth.signOut();

  Future<AppUser> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? dob,
    String? location,
    bool? profileComplete,
  }) async {
    final existing = await fetchProfile(uid);
    if (existing == null) {
      throw StateError('Profile not found for uid $uid');
    }
    final updated = existing.copyWith(
      name: name,
      phone: phone,
      dob: dob,
      location: location,
      profileComplete: profileComplete,
    );
    await _users.doc(uid).set(updated.toMap());
    return updated;
  }
}
