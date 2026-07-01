import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:unilink/screens/report_item_screen.dart';
import 'package:unilink/providers/lost_found_provider.dart' as lost_found;
import 'package:unilink/services/lost_found_service.dart';

class MockLostFoundService extends Mock implements LostFoundService {}

void main() {
  group('ReportItemScreen Widget Tests', () {
    testWidgets('Toggles between Lost and Found types', (WidgetTester tester) async {
      final mockService = MockLostFoundService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lost_found.lostFoundServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: ReportItemScreen(),
          ),
        ),
      );

      // Verify initial UI state
      expect(find.text('Submit LOST Report'), findsOneWidget);
      expect(find.text('Add a Photo'), findsOneWidget);

      // Tap on 'Found' type button
      await tester.tap(find.text('Found'));
      await tester.pump();

      // Verify button text changed
      expect(find.text('Submit FOUND Report'), findsOneWidget);
    });

    testWidgets('Image picker section is visible', (WidgetTester tester) async {
      final mockService = MockLostFoundService();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lost_found.lostFoundServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: ReportItemScreen(),
          ),
        ),
      );

      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
      expect(find.text('Increases chances of success by 70%'), findsOneWidget);
    });
  });
}
