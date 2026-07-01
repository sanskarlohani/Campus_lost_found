import 'package:flutter_test/flutter_test.dart';
import 'package:unilink/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User constructor initializes with default values', () {
      final user = User();
      expect(user.name, '');
      expect(user.karmaPoints, 0);
      expect(user.uid, '');
    });

    test('User.fromJson creates a valid User object', () {
      final json = {
        'name': 'John Doe',
        'email': 'john@test.com',
        'uid': 'user123',
        'karmaPoints': 50,
      };
      final user = User.fromJson(json);
      expect(user.name, 'John Doe');
      expect(user.karmaPoints, 50);
    });

    test('copyWith updates specific fields correctly', () {
      final user = User(name: 'Original', karmaPoints: 10);
      final updatedUser = user.copyWith(name: 'Updated', karmaPoints: 20);
      expect(updatedUser.name, 'Updated');
      expect(updatedUser.karmaPoints, 20);
    });
  });
}