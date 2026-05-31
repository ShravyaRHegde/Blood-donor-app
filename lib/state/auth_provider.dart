import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  AppUser? _current;
  AppUser? get current => _current;
  bool get isSignedIn => _current != null;
  bool get needsProfileSetup =>
      _current != null && !_current!.profileComplete;

  // True while we are fetching the profile from RTDB on startup.
  // Splash screen waits for this to be false before deciding where to go.
  bool _hydrating = false;
  bool get isHydrating => _hydrating;

  bool? _databaseReachable;
  bool? get databaseReachable => _databaseReachable;

  void init() {
    final fbUser = _repo.firebaseUser;
    if (fbUser != null) {
      // Don't create a stub — just set hydrating and wait for real profile
      _hydrating = true;
      _hydrateProfile(fbUser.uid);
    }
    _authSub = _repo.authStateChanges().listen(_onAuthChange);
    _startConnectivityMonitoring();
    notifyListeners();
  }

  void _startConnectivityMonitoring() {
    _checkConnectivity();
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        _runProbe();
      } else {
        _databaseReachable = false;
        notifyListeners();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final hasConnection = results.any((r) => r != ConnectivityResult.none);
    if (hasConnection) {
      await _runProbe();
    } else {
      _databaseReachable = false;
      notifyListeners();
    }
  }

  Future<void> _runProbe() async {
    final ok = await _repo.probeDatabase();
    _databaseReachable = ok;
    notifyListeners();
  }

  Future<void> recheckConnection() => _checkConnectivity();

  Future<void> _onAuthChange(User? user) async {
    if (user == null) {
      _current = null;
      _hydrating = false;
      notifyListeners();
      return;
    }
    if (_current?.uid == user.uid && _current?.profileComplete == true) {
      return;
    }
    _hydrating = true;
    notifyListeners();
    await _hydrateProfile(user.uid);
  }

  Future<void> _hydrateProfile(String uid) async {
    try {
      final profile = await _repo.fetchProfile(uid);
      if (profile != null) {
        _current = profile;
      }
    } catch (e) {
      debugPrint('AuthProvider._hydrateProfile failed: $e');
    } finally {
      _hydrating = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final res =
        await _repo.signUp(name: name, email: email, password: password);
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

  Future<bool> completeProfile({
    required String name,
    required String phone,
    required String dob,
    required String location,
  }) async {
    final u = _current;
    if (u == null) return false;
    try {
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
      return true;
    } catch (e, st) {
      debugPrint('AuthProvider.completeProfile failed: $e\n$st');
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) =>
    _repo.sendPasswordReset(email);

  Future<bool> editProfile({
    String? name,
    String? phone,
    String? dob,
    String? location,
  }) async {
    final u = _current;
    if (u == null) return false;
    try {
      final updated = await _repo.updateProfile(
        uid: u.uid,
        name: name,
        phone: phone,
        dob: dob,
        location: location,
      );
      _current = updated;
      notifyListeners();
      return true;
    } catch (e, st) {
      debugPrint('AuthProvider.editProfile failed: $e\n$st');
      return false;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}