import 'package:flutter_test/flutter_test.dart';
import 'package:unilink/utils/karma_utils.dart';

void main() {
  group('KarmaUtils Tests', () {
    test('Identify finders for FOUND items (Reporter gets reward)', () {
      final result = KarmaUtils.identifyFindersToReward(
        itemType: 'found',
        reporterId: 'user1',
        claimerIds: ['user2'],
      );

      expect(result.length, 1);
      expect(result.contains('user1'), true);
      expect(result.contains('user2'), false);
    });

    test('Identify finders for LOST items (Claimers get reward)', () {
      final result = KarmaUtils.identifyFindersToReward(
        itemType: 'lost',
        reporterId: 'user1',
        claimerIds: ['user2', 'user3'],
      );

      expect(result.length, 2);
      expect(result.contains('user1'), false);
      expect(result.contains('user2'), true);
      expect(result.contains('user3'), true);
    });

    test('Returns empty set if no claimers for LOST item', () {
      final result = KarmaUtils.identifyFindersToReward(
        itemType: 'lost',
        reporterId: 'user1',
        claimerIds: [],
      );

      expect(result.isEmpty, true);
    });
  });
}
