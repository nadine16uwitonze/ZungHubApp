import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Run flutterfire configure to generate web Firebase options.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Run flutterfire configure to generate mobile Firebase options.',
        );
      default:
        throw UnsupportedError('Firebase is not configured for this platform.');
    }
  }
}
