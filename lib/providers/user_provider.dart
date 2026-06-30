import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unilink/models/user.dart';
import 'package:unilink/providers/auth_provider.dart';
import 'package:unilink/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final userProfileProvider = StreamProvider<User?>((ref) {
  // Watch the auth state to get the current user reactively
  final authState = ref.watch(authProvider);
  final firebaseUser = authState.value;

  if (firebaseUser == null) {
    return Stream.value(null);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return User.fromJson(doc.data()!);
      });
});

final otherUserProfileProvider = StreamProvider.family<User?, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.exists && doc.data() != null ? User.fromJson(doc.data()!) : null);
});

final leaderboardProvider = StreamProvider<List<User>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) {
        final users = snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
        // Sort by karma points descending
        users.sort((a, b) => b.karmaPoints.compareTo(a.karmaPoints));
        return users;
      });
});

final isEditingProfileProvider = StateProvider<bool>((ref) => false);
