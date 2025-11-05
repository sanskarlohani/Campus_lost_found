import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/user.dart';
import 'package:unilink/providers/auth_notifier.dart';
import 'package:unilink/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<firebase_auth.User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

final userProfileProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  try {
    final doc = await authService.getUserProfile();
    if (!doc.exists) return null;
    return User.fromJson(doc.data() as Map<String, dynamic>);
  } catch (e) {
    return null;
  }
});