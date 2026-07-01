import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unilink/widgets/glass_container.dart';
import 'dart:ui';

void main() {
  group('GlassContainer Widget Tests', () {
    testWidgets('GlassContainer renders child and backdrop filter', (WidgetTester tester) async {
      const childText = 'Glass Content';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              child: Text(childText),
            ),
          ),
        ),
      );

      // Verify child is present
      expect(find.text(childText), findsOneWidget);

      // Verify BackdropFilter is used for the blur effect
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('GlassContainer applies correct border radius', (WidgetTester tester) async {
      const radius = 25.0;
      
      await tester.pumpWidget(
        const MaterialApp(
          home: GlassContainer(
            borderRadius: radius,
            child: SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(radius));
    });
  });
}
