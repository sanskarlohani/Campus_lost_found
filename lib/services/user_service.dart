import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:unilink/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateProfile(User user) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    await _firestore.collection('users').doc(currentUser.uid).set(
      user.copyWith(
        uid: currentUser.uid,
        email: currentUser.email ?? user.email,
      ).toJson(),
    );
  }

  Future<User?> getProfile() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!doc.exists) return null;
    return User.fromJson(doc.data()!);
  }
}