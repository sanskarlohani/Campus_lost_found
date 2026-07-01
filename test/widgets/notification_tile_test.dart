import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/screens/notifications_screen.dart';
import 'package:unilink/models/notification.dart';

void main() {
  group('NotificationTile Widget Tests', () {
    testWidgets('Renders global notification with campaign icon', (WidgetTester tester) async {
      final notification = NotificationItem(
        id: '1',
        title: 'Global Alert',
        message: 'Something was found',
        type: 'found',
        itemId: 'item1',
        userId: 'user1',
        isGlobal: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NotificationTile(notification: notification),
            ),
          ),
        ),
      );

      expect(find.text('Global Alert'), findsOneWidget);
      // Verify campaign icon (Icons.campaign_rounded) is present for global notifications
      expect(find.byIcon(Icons.campaign_rounded), findsOneWidget);
    });

    testWidgets('Renders personal match notification with handshake icon', (WidgetTester tester) async {
      final notification = NotificationItem(
        id: '2',
        title: 'Match Found',
        message: 'Your keys were found',
        type: 'match',
        itemId: 'item2',
        userId: 'user1',
        isGlobal: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NotificationTile(notification: notification),
            ),
          ),
        ),
      );

      expect(find.text('Match Found'), findsOneWidget);
      expect(find.byIcon(Icons.handshake_outlined), findsOneWidget);
    });
  });
}
