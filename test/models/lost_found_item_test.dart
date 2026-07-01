import 'package:flutter_test/flutter_test.dart';
import 'package:unilink/models/lost_found_item.dart';

void main() {
  group('LostFoundItem Model Tests', () {
    test('Constructor generates UUID and timestamp if not provided', () {
      final item = LostFoundItem();
      expect(item.id, isNotEmpty);
      expect(item.status, 'active');
      expect(item.imageUrl, '');
    });

    test('LostFoundItem.fromJson creates a valid object with imageUrl', () {
      final json = {
        'id': 'item-123',
        'title': 'Keys',
        'type': 'lost',
        'status': 'active',
        'imageUrl': 'https://example.com/image.jpg',
      };
      final item = LostFoundItem.fromJson(json);
      expect(item.id, 'item-123');
      expect(item.type, 'lost');
      expect(item.imageUrl, 'https://example.com/image.jpg');
    });

    test('toJson includes imageUrl', () {
      final item = LostFoundItem(imageUrl: 'https://test.com/img.png');
      final json = item.toJson();
      expect(json['imageUrl'], 'https://test.com/img.png');
    });
  });
}
