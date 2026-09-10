import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> sendCode({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onError,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onError,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: onCodeSent,
    );
  }

  Future<void> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _auth.signInWithCredential(credential);
  }

  Future<AppUser?> getCurrentProfile() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    final snapshot =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    final data = snapshot.data();
    if (data == null || data['role'] == null) return null;
    return AppUser(
      id: firebaseUser.uid,
      phone: firebaseUser.phoneNumber ?? '',
      role: UserRoleCodec.fromValue(data['role'] as String),
      name: (data['name'] as String?) ?? '',
    );
  }

  Future<void> savePublicRole({
    required String name,
    required UserRole role,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw StateError('You must verify your phone first.');
    }
    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'role': role.value,
      'name': name.trim(),
      'phone': firebaseUser.phoneNumber,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() => _auth.signOut();
}
