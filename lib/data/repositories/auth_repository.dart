import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

/// AuthRepository wraps Firebase Auth + Firestore so the rest of the app
/// keeps talking to a stable surface. Every Firestore call has an explicit
/// timeout and a try/catch — a stalled Firestore network call must never
/// leave the UI hanging on a spinner.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  // Tight enough that the user sees "something went wrong" within seconds
  // instead of staring at an indeterminate spinner.
  static const _fsTimeout = Duration(seconds: 8);
  static const _authTimeout = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get firebaseUser => _auth.currentUser;

  /// Returns null on any failure (missing doc, timeout, permission denied,
  /// network error). Callers must tolerate null.
  Future<AppUser?> fetchProfile(String uid) async {
    try {
      final snap = await _users.doc(uid).get().timeout(_fsTimeout);
      final data = snap.data();
      if (data == null) return null;
      return AppUser.fromMap(data);
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

      // Profile write is best-effort. The Firebase Auth account is created
      // either way — if Firestore is unreachable, the user can still proceed
      // to profile setup, which will retry the write.
      try {
        await _users.doc(user.uid).set(appUser.toMap()).timeout(_fsTimeout);
        debugPrint('AuthRepository.signUp: profile doc written for ${user.uid}');
      } catch (e, st) {
        debugPrint(
          'AuthRepository.signUp: profile doc write FAILED (non-fatal): $e\n$st',
        );
      }

      return AuthResult(AuthOutcome.success, appUser);
    } on TimeoutException {
      debugPrint('AuthRepository.signUp: createUserWithEmailAndPassword timed out');
      return const AuthResult(
        AuthOutcome.networkError,
        null,
        'Signup timed out — check your internet connection and try again.',
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

      // Profile fetch is best-effort. If Firestore is unreachable, we return
      // a stub so the user reaches the dashboard / profile-setup screen
      // rather than getting stuck on the login button.
      final profile = await fetchProfile(cred.user!.uid);
      final user = profile ??
          AppUser(
            uid: cred.user!.uid,
            email: cred.user!.email ?? email.toLowerCase(),
            name: '',
            createdAt: DateTime.now(),
          );

      // Self-heal: if the profile doc was missing (Firestore write failed at
      // signup), try to (re)create it now.
      if (profile == null) {
        try {
          await _users.doc(user.uid).set(user.toMap()).timeout(_fsTimeout);
          debugPrint('AuthRepository.logIn: created missing profile doc for ${user.uid}');
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
        'Login timed out — check your internet connection and try again.',
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

  /// Writes the updated profile. Returns the new AppUser on success. If the
  /// Firestore write fails (timeout, permission denied, network), throws so
  /// the caller can surface a UI error. Callers MUST try/catch around this.
  Future<AppUser> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? dob,
    String? location,
    bool? profileComplete,
  }) async {
    // Tolerant fetch — if the profile doesn't exist yet (recovery path),
    // build a stub from Firebase Auth state.
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

    await _users.doc(uid).set(updated.toMap()).timeout(_fsTimeout);
    debugPrint('AuthRepository.updateProfile($uid): success');
    return updated;
  }

  /// Connectivity probe — reads one doc from the meta collection with a tight
  /// timeout. Returns true if Firestore round-trips, false otherwise. Used
  /// by the login screen banner.
  Future<bool> probeFirestore() async {
    try {
      await _db
          .collection('meta')
          .doc('_probe')
          .get()
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('AuthRepository.probeFirestore failed: $e');
      return false;
    }
  }
}
