import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:unilink/models/lost_found_item.dart';
import 'package:unilink/providers/notification_provider.dart';

class LostFoundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

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

    // Log event
    await _analytics.logEvent(
      name: 'report_item',
      parameters: {
        'item_type': item.type,
        'item_id': docRef.id,
      },
    );

    return itemWithUser;
  }

  Stream<List<LostFoundItem>> getItemsByType(String type) {
    try {
      // Fetch without orderBy to avoid complex index requirements
      final query = _firestore
          .collection('lost_found_items')
          .where('type', isEqualTo: type)
          .where('status', isEqualTo: 'active');

      final stream = query.snapshots().map((snapshot) {
        final items = snapshot.docs
            .map((doc) => LostFoundItem.fromJson(doc.data()))
            .toList();
        
        // Sort in memory instead
        items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // Limit to 50 items manually
        return items.take(50).toList();
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
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => LostFoundItem.fromJson(doc.data()))
              .toList();
          // Sort descending by timestamp in memory to avoid index requirements
          items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return items;
        });
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

    // Log claim event
    await _analytics.logEvent(
      name: 'claim_item',
      parameters: {
        'item_id': itemId,
        'item_type': itemData['type'],
      },
    );
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    await _firestore
        .collection('lost_found_items')
        .doc(itemId)
        .update({'status': status});
  }

  Future<void> resolveItem(String itemId) async {
    // 1. Get item details to determine the type
    final itemDoc = await _firestore.collection('lost_found_items').doc(itemId).get();
    if (!itemDoc.exists) return;
    
    final itemData = itemDoc.data()!;
    final itemType = itemData['type'] as String;
    final reporterId = itemData['userId'] as String;

    final batch = _firestore.batch();
    final Set<String> findersToReward = {};

    // 2. Identify the hero (The Finder)
    if (itemType == 'found') {
      // Scenario: "I found this phone" -> Resolver (Reporter) is the finder
      findersToReward.add(reporterId);
    }

    // 3. Mark associated claims as resolved and find finders of 'lost' items
    final claimsSnapshot = await _firestore
        .collection('claims')
        .where('itemId', isEqualTo: itemId)
        .where('status', isEqualTo: 'pending')
        .get();

    for (var doc in claimsSnapshot.docs) {
      batch.update(doc.reference, {'status': 'resolved'});
      
      if (itemType == 'lost') {
        // Scenario: "I lost my keys" -> The person who sent the claim is the finder
        findersToReward.add(doc.data()['finderId'] as String);
      }
    }

    // 4. Update the item itself
    batch.update(itemDoc.reference, {'status': 'resolved'});

    // 5. Award Karma Points (10 per person who helped)
    for (String finderId in findersToReward) {
      final userRef = _firestore.collection('users').doc(finderId);
      batch.update(userRef, {
        'karmaPoints': FieldValue.increment(10),
      });
      
      await _notificationService.createNotification(
        userId: finderId,
        title: 'Karma Points Earned! 🌟',
        message: 'You earned 10 Karma points for helping return this item!',
        type: 'match',
        itemId: itemId,
      );
    }

    await batch.commit();

    // Log resolve event
    await _analytics.logEvent(
      name: 'resolve_item',
      parameters: {
        'item_id': itemId,
        'item_type': itemType,
      },
    );
  }

  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    return user.uid;
  }
}