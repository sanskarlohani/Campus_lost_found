import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unilink/models/lost_found_item.dart';

class ItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addItem(LostFoundItem item) async {
    try {
      await _firestore.collection('items').add(item.toJson());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('items').doc(id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getLostItems() {
    return _firestore
        .collection('items')
        .where('type', isEqualTo: 'lost')
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getFoundItems() {
    return _firestore
        .collection('items')
        .where('type', isEqualTo: 'found')
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getItem(String id) async {
    try {
      return await _firestore.collection('items').doc(id).get();
    } catch (e) {
      rethrow;
    }
  }
}