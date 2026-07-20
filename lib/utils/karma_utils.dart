class KarmaUtils {
  static const int pointsPerReturn = 10;

  static Set<String> identifyFindersToReward({
    required String itemType,
    required String reporterId,
    required List<String> claimerIds,
  }) {
    final Set<String> findersToReward = {};

    if (itemType == 'found') {
      // If I report a found item, I am the finder.
      findersToReward.add(reporterId);
    } else if (itemType == 'lost') {
      // If I report a lost item, anyone who claimed to have found it gets rewarded.
      findersToReward.addAll(claimerIds);
    }

    findersToReward.removeWhere((id) => id.trim().isEmpty);
    return findersToReward;
  }
}
