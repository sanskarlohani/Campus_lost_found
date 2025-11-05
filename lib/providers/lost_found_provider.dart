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