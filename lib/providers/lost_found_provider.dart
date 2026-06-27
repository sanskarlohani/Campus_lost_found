import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/lost_found_item.dart';
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

final userItemsProvider = StreamProvider<List<LostFoundItem>>((ref) {
  final service = ref.watch(lostFoundServiceProvider);
  return service.getUserItems();
});

final itemDetailProvider = StreamProvider.family<LostFoundItem?, String>((ref, id) {
  final service = ref.watch(lostFoundServiceProvider);
  return service.getItemById(id);
});

final userItemStatsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final userItems = ref.watch(userItemsProvider);
  
  return userItems.whenData((items) {
    int reported = items.length;
    int found = items.where((item) => item.status == 'resolved').length;
    return {'reported': reported, 'found': found};
  });
});
