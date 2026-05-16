// Template for lib/firebase_options.dart, which is gitignored.
//
// To generate your own copy:
//   1. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
//   2. From the project root: `flutterfire configure`
//      → pick your Firebase project, select Android (and any other platforms).
//      This writes the real lib/firebase_options.dart AND
//      android/app/google-services.json.
//
// Or paste your own values manually using the structure below.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured — run `flutterfire configure`.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Only Android is configured. Run `flutterfire configure` for other '
          'platforms.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:PROJECT_NUMBER:android:APP_HASH',
    messagingSenderId: 'PROJECT_NUMBER',
    projectId: 'your-firebase-project-id',
    storageBucket: 'your-firebase-project-id.firebasestorage.app',
  );
}
