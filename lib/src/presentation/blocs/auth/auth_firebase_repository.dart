// lib/src/presentation/blocs/auth/auth_firebase_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseAuthRepository {
  final _auth = FirebaseAuth.instance;
  final _storage = const FlutterSecureStorage();

  Future<String> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final token = await cred.user?.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw Exception('Failed to obtain ID token.');
    }

    try {
      await _storage.write(key: 'id_token', value: token);
    } catch (e) {
      // ignore: avoid_print
      print('Warning: failed to write token to secure storage: $e');
      // continue — you’re still logged in (Firebase session is valid)
    }

    return token;
  }

  Future<void> signOut() async {
    try { await _storage.delete(key: 'id_token'); } catch (_) {}
    await _auth.signOut();
  }

  Future<bool> hasValidSession() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final fresh = await user.getIdToken(true);
      if (fresh!.isEmpty) return false;
      try { await _storage.write(key: 'id_token', value: fresh); } catch (_) {}
      return true;
    } catch (_) {
      return false;
    }
  }
}
