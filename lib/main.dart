import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;
  StackTrace? startupStackTrace;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    startupError = error;
    startupStackTrace = stackTrace;
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'ZungHub startup',
        context: ErrorDescription('Firebase initialization failed.'),
      ),
    );
  }

  runApp(
    ProviderScope(
      child: startupError == null
          ? const ZungHubApp()
          : StartupErrorApp(error: startupError, stackTrace: startupStackTrace),
    ),
  );
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    required this.error,
    this.stackTrace,
    super.key,
  });

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZungHub setup',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff126B5B)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.settings_rounded, size: 56),
                  const SizedBox(height: 16),
                  Text(
                    'ZungHub needs Firebase configuration',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Run flutterfire configure in the project folder, then restart the app.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Check your Firebase project and app configuration, then restart the app.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ZungHubApp extends ConsumerWidget {
  const ZungHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'ZungHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff126B5B)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routerConfig: router,
    );
  }
}
