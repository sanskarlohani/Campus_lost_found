import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unilink/models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> updateProfile(User user) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    await _firestore.collection('users').doc(currentUser.uid).update(
      user.copyWith(
        uid: currentUser.uid,
        email: currentUser.email ?? user.email,
      ).toJson(),
    );
  }

  Future<String> uploadProfileImage(XFile imageFile) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('Not logged in');

      final fileName = 'profile_${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('profile_images').child(currentUser.uid).child(fileName);
      
      final bytes = await imageFile.readAsBytes();
      final uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      dev.log('Error uploading profile image: $e', name: 'UserService');
      throw Exception('Failed to upload profile image');
    }
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
