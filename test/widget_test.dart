// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:unilink/main.dart';

void main() {
  testWidgets('App builds with minimal router', (WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Text('Hello')),
      ],
    );

    await tester.pumpWidget(UniLinkApp(router: router));

    // Verify that the root route widget is present
    expect(find.text('Hello'), findsOneWidget);
  });
}
