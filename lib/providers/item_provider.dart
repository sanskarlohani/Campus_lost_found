import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/lost_found_item.dart';
import 'package:unilink/services/item_service.dart';

final itemServiceProvider = Provider<ItemService>((ref) => ItemService());

final lostItemsProvider = StreamProvider<List<LostFoundItem>>((ref) {
  final itemService = ref.watch(itemServiceProvider);
  return itemService.getLostItems().map((snapshot) {
    return snapshot.docs
        .map((doc) => LostFoundItem.fromJson(
              Map<String, dynamic>.from(doc.data() as Map<String, dynamic>)
                ..['id'] = doc.id,
            ))
        .toList();
  });
});

final foundItemsProvider = StreamProvider<List<LostFoundItem>>((ref) {
  final itemService = ref.watch(itemServiceProvider);
  return itemService.getFoundItems().map((snapshot) {
    return snapshot.docs
        .map((doc) => LostFoundItem.fromJson(
              Map<String, dynamic>.from(doc.data() as Map<String, dynamic>)
                ..['id'] = doc.id,
            ))
        .toList();
  });
});

final selectedItemProvider = FutureProvider.family<LostFoundItem?, String>(
  (ref, String id) async {
    final itemService = ref.watch(itemServiceProvider);
    try {
      final doc = await itemService.getItem(id);
      if (!doc.exists) return null;
      return LostFoundItem.fromJson(
        Map<String, dynamic>.from(doc.data() as Map<String, dynamic>)
          ..['id'] = doc.id,
      );
    } catch (e) {
      return null;
    }
  },
);