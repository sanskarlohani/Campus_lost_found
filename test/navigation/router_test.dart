import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:unilink/navigation/app_router.dart';
import 'package:unilink/providers/analytics_provider.dart';
import 'package:unilink/providers/auth_notifier.dart';
import 'package:unilink/providers/auth_provider.dart';
import 'package:unilink/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthNotifier extends StateNotifier<AsyncValue<firebase_auth.User?>> with Mock implements AuthNotifier {
  MockAuthNotifier() : super(const AsyncValue.data(null));
}

class MockAuthService extends Mock implements AuthService {}
class MockAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('Router Configuration', () {
    test('routerProvider provides a GoRouter instance', () {
      final mockAuthService = MockAuthService();
      final mockAnalytics = MockAnalytics();
      
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(null));

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          authProvider.overrideWith((ref) => MockAuthNotifier()),
          analyticsProvider.overrideWithValue(mockAnalytics),
        ],
      );
      final router = container.read(routerProvider);
      expect(router, isA<GoRouter>());
    });
  });
}
