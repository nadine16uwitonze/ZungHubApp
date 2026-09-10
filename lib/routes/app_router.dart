import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/role_selection_page.dart';
import '../features/auth/presentation/verify_code_page.dart';
import '../features/vendor/product_upload/presentation/product_upload_page.dart';
import '../features/customer/presentation/marketplace_page.dart';
import '../features/government/presentation/government_dashboard_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(firebaseAuthStateProvider);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authRepositoryProvider).authStateChanges,
    ),
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/verify';
      final isPublicPage = state.matchedLocation == '/';
      final requiresAuthentication = state.matchedLocation == '/role' ||
          state.matchedLocation == '/vendor/products/new' ||
          state.matchedLocation == '/government';
      if (!isLoggedIn && requiresAuthentication) return '/login';
      if (isLoggedIn && isAuthPage) return '/role';
      if (!isLoggedIn && !isPublicPage && !isAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/verify', builder: (_, __) => const VerifyCodePage()),
      GoRoute(path: '/role', builder: (_, __) => const RoleSelectionPage()),
      GoRoute(path: '/', builder: (_, __) => const MarketplacePage()),
      GoRoute(
        path: '/vendor/products/new',
        builder: (_, __) => const ProductUploadPage(),
      ),
      GoRoute(
        path: '/government',
        builder: (_, __) => const GovernmentDashboardPage(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
