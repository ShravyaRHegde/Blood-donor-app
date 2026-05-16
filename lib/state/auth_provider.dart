import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  StreamSubscription<User?>? _authSub;

  AppUser? _current;
  AppUser? get current => _current;
  bool get isSignedIn => _current != null;
  bool get needsProfileSetup => _current != null && !_current!.profileComplete;

  void init() {
    // Pick up a cached session synchronously so the splash decision works
    // even if the Firestore profile fetch is mid-flight.
    final fbUser = _repo.firebaseUser;
    if (fbUser != null) {
      _current = AppUser(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        name: '',
        createdAt: DateTime.now(),
      );
      _hydrateProfile(fbUser.uid);
    }
    _authSub = _repo.authStateChanges().listen(_onAuthChange);
    notifyListeners();
  }

  Future<void> _onAuthChange(User? user) async {
    if (user == null) {
      _current = null;
      notifyListeners();
      return;
    }
    // Same uid as the cached stub — just hydrate.
    if (_current?.uid == user.uid && _current?.profileComplete == true) {
      return;
    }
    await _hydrateProfile(user.uid);
  }

  Future<void> _hydrateProfile(String uid) async {
    try {
      final profile = await _repo.fetchProfile(uid);
      if (profile != null) {
        _current = profile;
        notifyListeners();
      }
    } catch (_) {
      // Don't blow the boot path on a transient fetch failure — the listener
      // will retry on the next auth-state event.
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _repo.signUp(name: name, email: email, password: password);
    if (res.outcome == AuthOutcome.success) {
      _current = res.user;
      notifyListeners();
    }
    return res;
  }

  Future<AuthResult> logIn({
    required String email,
    required String password,
  }) async {
    final res = await _repo.logIn(email: email, password: password);
    if (res.outcome == AuthOutcome.success) {
      _current = res.user;
      notifyListeners();
    }
    return res;
  }

  Future<void> logOut() async {
    await _repo.logOut();
    _current = null;
    notifyListeners();
  }

  Future<void> completeProfile({
    required String name,
    required String phone,
    required String dob,
    required String location,
  }) async {
    final u = _current;
    if (u == null) return;
    final updated = await _repo.updateProfile(
      uid: u.uid,
      name: name,
      phone: phone,
      dob: dob,
      location: location,
      profileComplete: true,
    );
    _current = updated;
    notifyListeners();
  }

  Future<void> editProfile({
    String? name,
    String? phone,
    String? dob,
    String? location,
  }) async {
    final u = _current;
    if (u == null) return;
    final updated = await _repo.updateProfile(
      uid: u.uid,
      name: name,
      phone: phone,
      dob: dob,
      location: location,
    );
    _current = updated;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
