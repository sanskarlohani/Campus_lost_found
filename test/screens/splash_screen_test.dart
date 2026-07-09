import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unilink/screens/splash_screen.dart';
import 'package:unilink/providers/auth_provider.dart';
import 'package:unilink/providers/auth_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class MockAuthNotifier extends StateNotifier<AsyncValue<firebase_auth.User?>> with Mock implements AuthNotifier {
  MockAuthNotifier() : super(const AsyncValue.data(null));
}

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('SplashScreen renders logo and text', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('Login Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Verify logo icon is present
      expect(find.byIcon(Icons.link_rounded), findsOneWidget);
      // Verify brand name
      expect(find.text('UniLink'), findsOneWidget);
      
      // Advance time to trigger navigation
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify it moved to login page (since auth is null)
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('Animations start correctly', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Verify that we can pump frames for animation
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Complete the timer
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('Displays version tag', (WidgetTester tester) async {
      PackageInfo.setMockInitialValues(
        appName: "UniLink",
        packageName: "com.example.unilink",
        version: "1.0.0",
        buildNumber: "1",
        buildSignature: "buildSignature",
      );

      final router = GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(
            path: '/splash',
            builder: (context, state) => const SplashScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      expect(find.text('v1.0.0'), findsOneWidget);
      
      // Complete the timer
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}
