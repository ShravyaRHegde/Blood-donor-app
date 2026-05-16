import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/remote/rtdb_seed.dart';
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

  // The Android google-services Gradle plugin auto-initializes a "[DEFAULT]"
  // Firebase app from google-services.json before this Dart code runs. If we
  // ever try to initializeApp() again with the same name, it throws
  // [core/duplicate-app]. So only init if no app exists yet.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10));
    }
    debugPrint('Firebase init OK — project=${Firebase.app().options.projectId} '
        'db=${Firebase.app().options.databaseURL}');
  } catch (e, st) {
    debugPrint('Firebase init FAILED: $e\n$st');
  }

  // Seeding is fire-and-forget. If RTDB is unreachable, rules deny, or the
  // project isn't fully configured, the boot path must NOT block — the
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
    await RtdbSeed.ensureSeeded().timeout(const Duration(seconds: 20));
    debugPrint('RTDB seed: complete');
  } on TimeoutException {
    debugPrint(
      'RTDB seed TIMED OUT — likely Realtime Database is not enabled in the '
      'project, rules deny the write, or the device is offline. App boots '
      'with no seed donors; signup will still work once writes are allowed.',
    );
  } catch (e, st) {
    debugPrint('RTDB seed FAILED (non-fatal): $e\n$st');
  }
}
