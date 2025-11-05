import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unilink/models/lost_found_item.dart';

class LostFoundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

    return _firestore
        .collection('lost_found_items')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LostFoundItem.fromJson(doc.data()))
            .toList());
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    await _firestore
        .collection('lost_found_items')
        .doc(itemId)
        .update({'status': status});
  }

  String getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    return user.uid;
  }
}