import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unilink/screens/login_screen.dart';
import 'package:unilink/providers/auth_provider.dart';
import 'package:unilink/providers/auth_notifier.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class MockAuthNotifier extends StateNotifier<AsyncValue<firebase_auth.User?>> with Mock implements AuthNotifier {
  MockAuthNotifier() : super(const AsyncValue.data(null));
}

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('LoginScreen shows initial UI components', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Shows error if fields are empty and login is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => MockAuthNotifier()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Press login button without entering data
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });
  });
}
