import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
});

final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final appUserProvider = FutureProvider<AppUser?>((ref) {
  ref.watch(firebaseAuthStateProvider);
  return ref.watch(authRepositoryProvider).getCurrentProfile();
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._repository) : super(const AsyncData(null));

  final AuthRepository _repository;

  Future<void> createAccount({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.createAccount(email: email, password: password);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.login(email: email, password: password);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> saveRole({required String name, required UserRole role}) async {
    state = const AsyncLoading();
    try {
      await _repository.savePublicRole(name: name, role: role);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
