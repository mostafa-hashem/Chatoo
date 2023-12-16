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
    await userDoc.update(updatedUserData);
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
    await userDoc.update({'profileImage': downloadUrl});
  }
}
