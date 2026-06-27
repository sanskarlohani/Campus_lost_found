import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unilink/models/lost_found_item.dart';
import 'package:unilink/providers/notification_provider.dart';

class LostFoundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  Future<LostFoundItem> createItem(LostFoundItem item) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('You must be logged in to report an item');

    final docRef = _firestore.collection('lost_found_items').doc();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final itemWithUser = LostFoundItem(
      id: docRef.id,
      title: item.title,
      description: item.description,
      location: item.location,
      type: item.type,
      userId: user.uid,
      timestamp: timestamp,
      status: item.status,
    );

    await docRef.set(itemWithUser.toJson());
    return itemWithUser;
  }

  Stream<List<LostFoundItem>> getItemsByType(String type) {
    try {
      // Create a query that will complete even if there are no documents
      final query = _firestore
          .collection('lost_found_items')
          .where('type', isEqualTo: type)
          .where('status', isEqualTo: 'active')
          .orderBy('timestamp', descending: true)
          .limit(50); // Add a limit to ensure the query completes

      final stream = query.snapshots().map((snapshot) {
        // Successfully got a snapshot (even if empty)
        return snapshot.docs
            .map((doc) => LostFoundItem.fromJson(doc.data()))
            .toList();
      });

      return stream.handleError((error) {
        dev.log('Error fetching items: $error', name: 'LostFoundService');
        if (error.toString().contains('requires an index')) {
          // Create a new stream with empty list while index is being built
          return Stream.value(<LostFoundItem>[]);
        }
        throw error;
      }).asBroadcastStream();
    } catch (e) {
      // Handle any synchronous errors
      dev.log('Unexpected error in getItemsByType: $e', name: 'LostFoundService');
      return Stream.value(<LostFoundItem>[]);
    }
  }

  Stream<List<LostFoundItem>> getUserItems() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return getUserItemsForUser(user.uid);
  }

  Stream<List<LostFoundItem>> getUserItemsForUser(String uid) {
    return _firestore
        .collection('lost_found_items')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LostFoundItem.fromJson(doc.data()))
            .toList());
  }

  Stream<LostFoundItem?> getItemById(String itemId) {
    return _firestore
        .collection('lost_found_items')
        .doc(itemId)
        .snapshots()
        .map((doc) => doc.exists ? LostFoundItem.fromJson(doc.data()!) : null);
  }

  Future<void> claimItem(String itemId, String message) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // 1. Get the item to find the owner
    final itemDoc = await _firestore.collection('lost_found_items').doc(itemId).get();
    if (!itemDoc.exists) throw Exception('Item not found');
    
    final itemData = itemDoc.data()!;
    final ownerId = itemData['userId'];

    // 2. Create a claim record
    await _firestore.collection('claims').add({
      'itemId': itemId,
      'itemTitle': itemData['title'],
      'finderId': user.uid,
      'ownerId': ownerId,
      'message': message,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 3. Notify the owner
    await _notificationService.createNotification(
      userId: ownerId,
      title: itemData['type'] == 'lost' ? 'Item Found!' : 'New Claim Request',
      message: '${user.displayName ?? 'Someone'} has ${itemData['type'] == 'lost' ? 'found' : 'claimed'} your ${itemData['title']}: "$message"',
      type: 'match',
      itemId: itemId,
    );
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    await _firestore
        .collection('lost_found_items')
        .doc(itemId)
        .update({'status': status});
  }

  Future<void> resolveItem(String itemId) async {
    // 1. Update item status
    await updateItemStatus(itemId, 'resolved');

    // 2. Find associated claims and mark them resolved
    final claimsSnapshot = await _firestore
        .collection('claims')
        .where('itemId', isEqualTo: itemId)
        .where('status', isEqualTo: 'pending')
        .get();

    final batch = _firestore.batch();
    final Set<String> findersToReward = {};

    for (var doc in claimsSnapshot.docs) {
      batch.update(doc.reference, {'status': 'resolved'});
      findersToReward.add(doc.data()['finderId'] as String);
    }

    // 3. Award Karma Points to finders (e.g., 10 points)
    for (String finderId in findersToReward) {
      final userRef = _firestore.collection('users').doc(finderId);
      batch.update(userRef, {
        'karmaPoints': FieldValue.increment(10),
      });
      
      // Optionally notify finder that they earned points
      await _notificationService.createNotification(
        userId: finderId,
        title: 'Karma Points Earned!',
        message: 'You earned 10 Karma points for helping return an item!',
        type: 'match',
        itemId: itemId,
      );
    }

    await batch.commit();
  }

  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    return user.uid;
  }
}