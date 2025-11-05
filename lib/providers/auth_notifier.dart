import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/services/auth_service.dart';

class AuthNotifier extends StateNotifier<AsyncValue<firebase_auth.User?>> {
  final AuthService _authService;
  late final Stream<firebase_auth.User?> _authStateChanges;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _authStateChanges = firebase_auth.FirebaseAuth.instance.authStateChanges();
    _authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _authService.signIn(email, password);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      state = const AsyncValue.loading();
      await _authService.signUp(email, password, name);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}