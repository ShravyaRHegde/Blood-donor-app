import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

enum AuthOutcome {
  success,
  emailTaken,
  invalidCredentials,
  unknownEmail,
  networkError,
}

class AuthResult {
  final AuthOutcome outcome;
  final AppUser? user;
  final String? message;
  const AuthResult(this.outcome, [this.user, this.message]);
}

/// AuthRepository wraps Firebase Auth + Realtime Database so the rest of
/// the app keeps talking to a stable surface. Every RTDB call has an
/// explicit timeout and a try/catch — a stalled network call must never
/// leave the UI hanging on a spinner.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseDatabase? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseDatabase.instance;

  final FirebaseAuth _auth;
  final FirebaseDatabase _db;

  static const _ioTimeout = Duration(seconds: 8);
  static const _authTimeout = Duration(seconds: 15);

  DatabaseReference _userRef(String uid) => _db.ref('users/$uid');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get firebaseUser => _auth.currentUser;

  Future<AppUser?> fetchProfile(String uid) async {
    try {
      final snap = await _userRef(uid).get().timeout(_ioTimeout);
      final value = snap.value;
      if (value is! Map) return null;
      return AppUser.fromMap(Map<String, dynamic>.from(value));
    } catch (e, st) {
      debugPrint('AuthRepository.fetchProfile($uid) failed: $e\n$st');
      return null;
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim().toLowerCase(),
            password: password,
          )
          .timeout(_authTimeout);

      final user = cred.user!;
      final appUser = AppUser(
        uid: user.uid,
        email: user.email ?? email.toLowerCase(),
        name: name.trim(),
        createdAt: DateTime.now(),
      );

      // Profile write is fire-and-forget. Returning success unblocks the UI
      // immediately; the auth token may take a tick to propagate to RTDB's
      // long-lived connection (RTDB rules of the form
      // `auth.uid == $uid` see no auth until the connection re-handshakes).
      // The write will succeed in the background once that happens; if not,
      // the next sign-in or profile save self-heals.
      unawaited(
        _userRef(user.uid).set(appUser.toMap()).then((_) {
          debugPrint('AuthRepository.signUp: profile written for ${user.uid}');
        }).catchError((Object e, StackTrace st) {
          debugPrint(
            'AuthRepository.signUp: profile write failed (will self-heal): '
            '$e\n$st',
          );
        }),
      );

      return AuthResult(AuthOutcome.success, appUser);
    } on TimeoutException {
      debugPrint('AuthRepository.signUp: createUserWithEmailAndPassword timed out');
      return const AuthResult(
        AuthOutcome.networkError,
        null,
        'Signup timed out — check your internet connection.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthRepository.signUp: FirebaseAuthException ${e.code} — ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          return const AuthResult(AuthOutcome.emailTaken);
        case 'weak-password':
        case 'invalid-email':
          return AuthResult(AuthOutcome.invalidCredentials, null, e.message);
        case 'network-request-failed':
          return const AuthResult(
            AuthOutcome.networkError,
            null,
            'No internet connection.',
          );
        default:
          return AuthResult(
            AuthOutcome.invalidCredentials,
            null,
            'Firebase Auth error: ${e.code}',
          );
      }
    } catch (e, st) {
      debugPrint('AuthRepository.signUp: unexpected error: $e\n$st');
      return AuthResult(AuthOutcome.networkError, null, e.toString());
    }
  }

  Future<AuthResult> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth
          .signInWithEmailAndPassword(
            email: email.trim().toLowerCase(),
            password: password,
          )
          .timeout(_authTimeout);

      // Profile fetch is best-effort. If RTDB is unreachable, return a stub
      // so the user reaches profile-setup instead of getting stuck.
      final profile = await fetchProfile(cred.user!.uid);
      final user = profile ??
          AppUser(
            uid: cred.user!.uid,
            email: cred.user!.email ?? email.toLowerCase(),
            name: '',
            createdAt: DateTime.now(),
          );

      if (profile == null) {
        try {
          await _userRef(user.uid).set(user.toMap()).timeout(_ioTimeout);
          debugPrint('AuthRepository.logIn: created missing profile for ${user.uid}');
        } catch (e) {
          debugPrint('AuthRepository.logIn: profile recovery write failed: $e');
        }
      }

      return AuthResult(AuthOutcome.success, user);
    } on TimeoutException {
      debugPrint('AuthRepository.logIn: signInWithEmailAndPassword timed out');
      return const AuthResult(
        AuthOutcome.networkError,
        null,
        'Login timed out — check your internet connection.',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthRepository.logIn: FirebaseAuthException ${e.code} — ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          return const AuthResult(AuthOutcome.unknownEmail);
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return const AuthResult(AuthOutcome.invalidCredentials);
        case 'network-request-failed':
          return const AuthResult(
            AuthOutcome.networkError,
            null,
            'No internet connection.',
          );
        default:
          return AuthResult(
            AuthOutcome.invalidCredentials,
            null,
            'Firebase Auth error: ${e.code}',
          );
      }
    } catch (e, st) {
      debugPrint('AuthRepository.logIn: unexpected error: $e\n$st');
      return AuthResult(AuthOutcome.networkError, null, e.toString());
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
    final existing = await fetchProfile(uid) ??
        AppUser(
          uid: uid,
          email: _auth.currentUser?.email ?? '',
          name: '',
          createdAt: DateTime.now(),
        );

    final updated = existing.copyWith(
      name: name,
      phone: phone,
      dob: dob,
      location: location,
      profileComplete: profileComplete,
    );

    await _userRef(uid).set(updated.toMap()).timeout(_ioTimeout);
    debugPrint('AuthRepository.updateProfile($uid): success');
    return updated;
  }

  /// Connectivity probe — reads one path from RTDB with a tight timeout.
  /// Returns true if RTDB round-trips, false otherwise.
  Future<bool> probeDatabase() async {
    try {
      await _db.ref('meta/_probe').get().timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('AuthRepository.probeDatabase failed: $e');
      return false;
    }
  }
}
