import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unilink/widgets/profile_image.dart';

void main() {
  group('ProfileImage Widget Tests', () {
    testWidgets('Renders placeholder text when imageUrl is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileImage(imageUrl: '', placeholderText: 'JD'),
        ),
      );

      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets('Renders a container with correct size', (WidgetTester tester) async {
      const size = 150.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileImage(imageUrl: '', size: size),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.minWidth, size);
      expect(container.constraints?.minHeight, size);
    });
  });
}
