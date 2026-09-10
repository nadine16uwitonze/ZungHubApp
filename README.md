# ZungHub

ZungHub is a Flutter marketplace and compliance app for street vendors, customers, and verified government officials.

## Phase 1 setup

1. Install Flutter and Firebase CLI.
2. From this directory, run `flutter pub get`.
3. Install FlutterFire CLI and run `flutterfire configure` to replace `lib/core/services/firebase_options.dart` with project-specific Firebase configuration.
4. Enable Phone Authentication, Firestore, and Storage in Firebase Console.
5. Deploy rules with `firebase deploy --only firestore:rules,storage`.
6. Run `flutter run` for mobile, or `flutter run -d chrome` for the web dashboard shell.

Government users are intentionally excluded from public role registration. A government account must be provisioned or whitelisted in Firestore by an operator.
