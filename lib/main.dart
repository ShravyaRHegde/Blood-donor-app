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

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Push the seed donor catalog into Firestore exactly once across all clients.
  // Guarded by a meta doc so the second device to boot doesn't duplicate.
  await FirestoreSeed.ensureSeeded();

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
