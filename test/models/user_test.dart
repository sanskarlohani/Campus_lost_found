import 'package:flutter_test/flutter_test.dart';
import 'package:unilink/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson creates a valid object', () {
      final json = {
        'uid': 'user-123',
        'name': 'John Doe',
        'email': 'john@test.com',
        'profileImageUrl': 'https://example.com/avatar.svg',
        'karmaPoints': 50,
      };
      final user = User.fromJson(json);
      expect(user.uid, 'user-123');
      expect(user.name, 'John Doe');
      expect(user.profileImageUrl, 'https://example.com/avatar.svg');
      expect(user.karmaPoints, 50);
    });

    test('toJson includes profileImageUrl', () {
      final user = User(
        uid: 'user-123',
        profileImageUrl: 'https://example.com/photo.jpg',
      );
      final json = user.toJson();
      expect(json['profileImageUrl'], 'https://example.com/photo.jpg');
    });

    test('copyWith updates profileImageUrl', () {
      final user = User(uid: '123', profileImageUrl: 'old');
      final updated = user.copyWith(profileImageUrl: 'new');
      expect(updated.profileImageUrl, 'new');
      expect(updated.uid, '123');
    });
  });
}
