import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/lost_found_item.dart';
import 'package:unilink/providers/auth_provider.dart';
import 'package:unilink/services/lost_found_service.dart';

final lostFoundServiceProvider = Provider<LostFoundService>((ref) {
  return LostFoundService();
});

final lostItemsProvider = StreamProvider<List<LostFoundItem>>((ref) {
  final service = ref.watch(lostFoundServiceProvider);
  return service.getItemsByType('lost');
});

final foundItemsProvider = StreamProvider<List<LostFoundItem>>((ref) {
  final service = ref.watch(lostFoundServiceProvider);
  return service.getItemsByType('found');
});

// Changed to family to support viewing stats for any user
final userItemsProvider = StreamProvider.family<List<LostFoundItem>, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value([]);
  
  final service = ref.watch(lostFoundServiceProvider);
  return service.getUserItemsForUser(uid);
});

// Detail provider for a single item
final itemDetailProvider = StreamProvider.family<LostFoundItem?, String>((ref, itemId) {
  final service = ref.watch(lostFoundServiceProvider);
  return service.getItemById(itemId);
});

// Changed to family to calculate stats for a specific user ID
final userItemStatsProvider = Provider.family<AsyncValue<Map<String, int>>, String>((ref, uid) {
  final userItems = ref.watch(userItemsProvider(uid));
  
  return userItems.whenData((items) {
    int reported = items.length;
    int found = items.where((item) => item.status == 'resolved').length;
    return {'reported': reported, 'found': found};
  });
});
