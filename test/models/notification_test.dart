import 'package:flutter_test/flutter_test.dart';
import 'package:unilink/models/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('NotificationItem Model Tests', () {
    test('NotificationItem.fromJson handles valid data', () {
      final now = DateTime.now();
      final json = {
        'id': 'notif-123',
        'title': 'Test Title',
        'message': 'Test Message',
        'type': 'match',
        'itemId': 'item-456',
        'userId': 'user-789',
        'isRead': false,
        'isGlobal': true,
        'createdAt': Timestamp.fromDate(now),
      };

      final item = NotificationItem.fromJson(json);

      expect(item.id, 'notif-123');
      expect(item.isGlobal, true);
      expect(item.createdAt.year, now.year);
    });

    test('NotificationItem.fromJson handles null/missing timestamp gracefully', () {
      final json = {
        'id': 'notif-123',
        'title': 'Test Title',
        'message': 'Test Message',
        'type': 'match',
        'itemId': 'item-456',
        'userId': 'user-789',
        // 'createdAt' is missing or not a Timestamp
      };

      final item = NotificationItem.fromJson(json);

      expect(item.id, 'notif-123');
      // Should default to now
      expect(item.createdAt, isA<DateTime>());
    });
  });
}
