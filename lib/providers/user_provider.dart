import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/user.dart';
import 'package:unilink/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final userProfileProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(userServiceProvider);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots()
      .map((doc) => doc.exists ? User.fromJson(doc.data()!) : null);
});

final isEditingProfileProvider = StateProvider<bool>((ref) => false);