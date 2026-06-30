import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/notification.dart';

// Separate provider for personal notifications
// Removed .orderBy() to avoid index requirements; sorting is done in memory.
final personalNotificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs
          .map((doc) => NotificationItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
        // Sort descending by date in memory
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });
});

// Separate provider for global campus alerts
// Removed .orderBy() to avoid index requirements; sorting is done in memory.
final globalNotificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('isGlobal', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs
          .map((doc) => NotificationItem.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
        // Sort descending by date in memory
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return items;
      });
});

// Combined provider that merges both streams in memory
final notificationsProvider = Provider<AsyncValue<List<NotificationItem>>>((ref) {
  final personal = ref.watch(personalNotificationsProvider);
  final global = ref.watch(globalNotificationsProvider);

  if (personal.isLoading || global.isLoading) return const AsyncValue.loading();
  if (personal.hasError) return AsyncValue.error(personal.error!, personal.stackTrace!);
  if (global.hasError) return AsyncValue.error(global.error!, global.stackTrace!);

  final allItems = [...personal.value ?? [], ...global.value ?? []];
  
  // De-duplicate by ID
  final seenIds = <String>{};
  final uniqueItems = <NotificationItem>[];
  for (var item in allItems) {
    if (seenIds.add(item.id)) {
      uniqueItems.add(item);
    }
  }

  // Final sort by date descending
  uniqueItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  return AsyncValue.data(uniqueItems);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final asyncNotifications = ref.watch(notificationsProvider);
  return asyncNotifications.maybeWhen(
    data: (notifications) =>
        notifications.where((notification) => !notification.isRead).length,
    orElse: () => 0,
  );
});

class NotificationService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String itemId,
    bool isGlobal = false,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'itemId': itemId,
        'isRead': false,
        'isGlobal': isGlobal,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      dev.log('Error creating notification: $e', name: 'NotificationService');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final doc = await _firestore.collection('notifications').doc(notificationId).get();
      if (!doc.exists) return;
      
      if (doc.data()?['isGlobal'] == true) return;

      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      dev.log('Error marking notification read: $e', name: 'NotificationService');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      dev.log('Error deleting notification: $e', name: 'NotificationService');
    }
  }
}
