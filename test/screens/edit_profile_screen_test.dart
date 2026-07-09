import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unilink/screens/edit_profile_screen.dart';
import 'package:unilink/models/user.dart';
import 'package:unilink/providers/user_provider.dart';
import 'package:unilink/services/user_service.dart';

class MockUserService extends Mock implements UserService {}

void main() {
  group('EditProfileScreen Widget Tests', () {
    testWidgets('Renders all input fields', (WidgetTester tester) async {
      // Set a larger surface size to avoid scrolling issues in tests
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockUser = User(
        name: 'Test User',
        sic: '12345',
        college: 'Test College',
      );
      final mockService = MockUserService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userServiceProvider.overrideWithValue(mockService),
          ],
          child: MaterialApp(
            home: EditProfileScreen(initialUser: mockUser),
          ),
        ),
      );

      expect(find.text('Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Test User'), findsOneWidget);
    });

    testWidgets('Shows validation errors for mandatory fields', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockService = MockUserService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );

      // Tap save
      final saveButton = find.byType(ElevatedButton);
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your SIC'), findsOneWidget);
    });
  });
}
