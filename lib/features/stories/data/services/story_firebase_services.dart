import 'dart:io';

import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StoryFirebaseServices {
  final _storiesCollection =
      FirebaseFirestore.instance.collection(FirebasePath.stories);
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadStory(
    File mediaFile,
    String mediaPath,
    String storyCaption,
    Future<String> Function(File imageFile) getFileName,
  ) async {
    final String fileName = await getFileName(mediaFile);

    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final Reference storageRef = _storage
        .ref()
        .child(FirebasePath.users)
        .child('stories').child(mediaPath)
        .child(currentUserId)
        .child(fileName);

    final UploadTask uploadTask = storageRef.putFile(mediaFile);
    final TaskSnapshot snapshot = await uploadTask;
    final String downloadUrl = await snapshot.ref.getDownloadURL();

    final DocumentReference storyDocRef = await _storiesCollection.add(
      Story(
        userId: currentUserId,
        mediaUrl: downloadUrl,
        uploadedAt: DateTime.now().toLocal(),
        fileName: fileName,
        storyTitle: storyCaption,
      ).toJson(),
    );

    final String storyId = storyDocRef.id;

    await _storiesCollection.doc(storyId).update({"id": storyId});

    await _usersCollection.doc(currentUserId).update({
      'stories': FieldValue.arrayUnion([storyId])
    ,});

    Future.delayed(const Duration(hours: 24), () {
      deleteStory(storyId, fileName);
    });

    return downloadUrl;
  }

  Future<void> deleteStory(String storyId, String fileName) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await _storiesCollection.doc(storyId).delete();

      await _usersCollection.doc(currentUserId).update({
        'stories': FieldValue.arrayRemove([storyId])
      ,});

      final Reference storageRef = _storage
          .ref()
          .child(FirebasePath.users)
          .child('stories')
          .child(currentUserId)
          .child(fileName);

      await storageRef.delete();
    } catch (e) {}
  }

  Stream<List<Story>> fetchStories() {
    return FirebaseFirestore.instance
        .collection('stories')
        .where('uploadedAt',
            isGreaterThanOrEqualTo:
                DateTime.now().subtract(const Duration(hours: 24)),)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Story.fromJson(doc.data()))
          .toList();
    });
  }
}
