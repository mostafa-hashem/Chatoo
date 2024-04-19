import 'dart:io';

import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';

class ProfileFirebaseService {
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<User> getUser() async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final docSnapshot = await _usersCollection.doc(currentUserId).get();
    return User.fromJson(docSnapshot.data()!);
  }

  Future<void> updateUser(User updatedUser) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = _usersCollection.doc(currentUserId);
    final updatedUserData = updatedUser.toJson();

    // Update the user's data
    await userDoc.update(updatedUserData);

    // Retrieve the list of friend IDs from the user's document
    final userSnapshot = await userDoc.get();
    final List<dynamic> friendIds =
        userSnapshot.data()?['friends'] as List<dynamic>;

    // Update friendData for each friend
    for (final friendId in friendIds) {
      final friendDoc = _usersCollection
          .doc(friendId.toString())
          .collection(FirebasePath.friends)
          .doc(currentUserId);

      final friendSnapshot = await friendDoc.get();
      if (friendSnapshot.exists) {
        // Update the friendData field with the updated user data
        await friendDoc.update({'friendData': updatedUserData});
      }
    }
  }

  Future<void> uploadProfileImage(String filePath, File imageFile) async {
    final Reference storageRef =
        _storage.ref().child(FirebasePath.users).child(filePath);
    final UploadTask uploadTask =
        storageRef.child('${imageFile.hashCode}').putFile(imageFile);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = _usersCollection.doc(currentUserId);

    // Update user's profile image
    await userDoc.update({'profileImage': downloadUrl});

    final userSnapshot = await userDoc.get();
    final List<dynamic> friendIds =
        userSnapshot.data()?['friends'] as List<dynamic>;

    // Update profile image for each friend
    for (final friendId in friendIds) {
      final friendDoc = _usersCollection
          .doc(friendId.toString())
          .collection(FirebasePath.friends)
          .doc(currentUserId);

      final friendSnapshot = await friendDoc.get();
      if (friendSnapshot.exists) {
        // Update the friendData field with the new profile image URL
        await friendDoc.update({'friendData.profileImage': downloadUrl});
      }
    }
  }
}
