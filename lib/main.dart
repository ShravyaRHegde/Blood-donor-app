import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/remote/firestore_seed.dart';
import 'firebase_options.dart';
import 'state/auth_provider.dart';
import 'state/donor_provider.dart';
import 'state/receiver_provider.dart';
import 'state/request_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase init must succeed before any provider touches Firestore/Auth.
  // If config is wrong, fail loudly in logcat instead of black-screen-hang.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    debugPrint('Firebase init OK — project=${Firebase.app().options.projectId}');
  } catch (e, st) {
    debugPrint('Firebase init FAILED: $e\n$st');
    // Continue to runApp anyway so the user sees a non-black screen
    // explaining the failure rather than a black void.
  }

  // Seeding is fire-and-forget. If Firestore is unreachable, rules deny, or
  // the project isn't fully configured, the boot path must NOT block — the
  // login screen has to render so the user can sign in / debug.
  unawaited(_seedInBackground());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => DonorProvider()..init()),
        ChangeNotifierProvider(create: (_) => ReceiverProvider()..init()),
        ChangeNotifierProvider(create: (_) => RequestProvider()..init()),
      ],
      child: const BloodDonorApp(),
    ),
  );
}

Future<void> _seedInBackground() async {
  try {
    await FirestoreSeed.ensureSeeded().timeout(const Duration(seconds: 20));
    debugPrint('Firestore seed: complete');
  } on TimeoutException {
    debugPrint(
      'Firestore seed TIMED OUT — likely Firestore is not enabled, rules '
      'deny unauthenticated writes, or the device is offline. App will boot '
      'with no seed donors; signup will still work once writes are allowed.',
    );
  } catch (e, st) {
    debugPrint('Firestore seed FAILED (non-fatal): $e\n$st');
  }
}
