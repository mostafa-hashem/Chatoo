import 'dart:io';

import 'package:chat_app/features/stories/data/models/story.dart';
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

    // Update the user's data
    await userDoc.update(updatedUser.toJson());
  }

  Future<void> updateBio(String newBio) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection.doc(currentUserId).update({
      'bio': newBio,
    });
  }

  Future<void> uploadProfileImage(
    File imageFile,
    String oldImageUrl,
    Future<String> Function(File imageFile) getFileName,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final Uri uri = Uri.parse(oldImageUrl);
    final String path = uri.path;
    final String oldFileName = path.split('%2F').last.split('?').last;
    _storage
        .ref()
        .child(FirebasePath.users)
        .child(FirebasePath.profilePictures)
        .child(currentUserId)
        .child(oldFileName)
        .delete();

    final String fileName = await getFileName(imageFile);
    final Reference storageRef = _storage
        .ref()
        .child(FirebasePath.users)
        .child(FirebasePath.profilePictures)
        .child(currentUserId)
        .child(fileName);
    final UploadTask uploadTask = storageRef.putFile(imageFile);
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    final userDoc = _usersCollection.doc(currentUserId);

    await userDoc.update({'profileImage': downloadUrl});
  }

  Future<void> deleteProfileImage(
    String oldImageUrl,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final Uri uri = Uri.parse(oldImageUrl);
    final String path = uri.path;
    final String oldFileName = path.split('%2F').last.split('?').last;
    _storage
        .ref()
        .child(FirebasePath.users)
        .child(FirebasePath.profilePictures)
        .child(currentUserId)
        .child(oldFileName)
        .delete();

    final userDoc = _usersCollection.doc(currentUserId);

    await userDoc.update({'profileImage': FirebasePath.defaultImage});
  }

  Stream<List<Story>> fetchStories() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('stories')
        .where(
          'uploadedAt',
          isGreaterThanOrEqualTo:
              DateTime.now().subtract(const Duration(hours: 24)),
        )
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Story.fromJson(doc.data()))
          .where((story) => story.userId == currentUserId)
          .toList();
    });
  }
}
