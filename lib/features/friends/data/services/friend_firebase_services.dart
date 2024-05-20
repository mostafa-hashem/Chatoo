import 'dart:io';

import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';

class FriendFirebaseServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);
  final _friendsCollection = FirebaseFirestore.instance
      .collection(FirebasePath.users)
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection(FirebasePath.friends);

  Stream<List<User>> getUsers() {
    return _usersCollection.snapshots().map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (queryDocSnapshot) => User.fromJson(queryDocSnapshot.data()),
              )
              .toList(),
        );
  }

  Stream<User> getFriendData(String friendId) {
    return _usersCollection.doc(friendId).snapshots().map(
          (querySnapshot) => User.fromJson(querySnapshot.data()!),
        );
  }

  Stream<List<User?>> getAllUserFriends() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _usersCollection
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      final dynamic userData = snapshot.data();
      if (userData != null && userData is Map<String, dynamic>) {
        final List<dynamic> friendIds =
            (userData['friends'] ?? []) as List<dynamic>;
        final List<Future<User?>> friendFutures =
            friendIds.map((friendId) async {
          final DocumentSnapshot friendFutures =
              await _usersCollection.doc(friendId.toString()).get();
          if (friendFutures.exists) {
            return User.fromJson(friendFutures.data()! as Map<String, dynamic>);
          }
        }).toList();
        final List<User?> users = await Future.wait(friendFutures);
        return users;
      } else {
        return [];
      }
    });
  }

  Stream<List<User>> getAllUserRequests() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }
    return _usersCollection
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      final dynamic userData = snapshot.data();
      if (userData != null && userData is Map<String, dynamic>) {
        final List<dynamic> requestsIds =
            (userData['requests'] ?? []) as List<dynamic>;
        final List<Future<User>> friendFutures =
            requestsIds.map((requestData) async {
          final DocumentSnapshot friendFutures =
              await _usersCollection.doc(requestData.toString()).get();
          return User.fromJson(friendFutures.data()! as Map<String, dynamic>);
        }).toList();
        final List<User> users = await Future.wait(friendFutures);
        return users;
      } else {
        return [];
      }
    });
  }

  Future<void> requestToAddFriend(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection.doc(friendId).update({
      'requests': FieldValue.arrayUnion([
        currentUserId,
      ]),
    });
  }

  Future<void> requestFriendRequest(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection.doc(friendId).update({
      'requests': FieldValue.arrayRemove([
        currentUserId,
      ]),
    });
  }

  Future<void> approveFriendRequest(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUserRef = _usersCollection.doc(currentUserId);
    final friendRef = _usersCollection.doc(friendId);

    await friendRef.collection(FirebasePath.friends).doc(currentUserId).set({
      'recentMessage': '',
      'recentMessageSender': '',
      'sentAt': DateTime.now(),
      'addedAt': DateTime.now(),
    });

    await _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .set({
      'recentMessage': '',
      'recentMessageSender': '',
      'sentAt': DateTime.now(),
      'addedAt': DateTime.now(),
    });
    // Update the current user's friends field
    await currentUserRef.update({
      'friends': FieldValue.arrayUnion([friendId]),
    });
    await currentUserRef.update({
      'requests': FieldValue.arrayRemove([friendId]),
    });

    // Update the friend's friends field
    await friendRef.update({
      'friends': FieldValue.arrayUnion([currentUserId]),
    });
  }

  Future<void> declineFriendRequest(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection.doc(currentUserId).update({
      'requests': FieldValue.arrayRemove([friendId]),
    });
  }

  Future<String> sendMediaToFriend(
    String mediaPath,
    File mediaFile,
    String friendPathId,
    Future<String> Function(File imageFile) getFileName,
  ) async {
    final String fileName = await getFileName(mediaFile);

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final Reference storageRef = _storage
        .ref()
        .child(FirebasePath.users)
        .child(mediaPath)
        .child(currentUserId)
        .child(friendPathId);
    final UploadTask uploadRecord =
        storageRef.child(fileName).putFile(mediaFile);
    final TaskSnapshot snapshot = await uploadRecord;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> sendMessageToFriend(
    User friend,
    String? message,
    User sender,
    List<String>? mediaUrls,
    MessageType type,
  ) async {
    if (message!.isEmpty && mediaUrls!.isEmpty) {
      return;
    }
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference userMessageDocRef = _usersCollection
        .doc(friend.id)
        .collection(FirebasePath.friends)
        .doc(currentUserUid)
        .collection(FirebasePath.messages)
        .doc();
    final DocumentReference friendMessageDocRef = _usersCollection
        .doc(currentUserUid)
        .collection(FirebasePath.friends)
        .doc(friend.id)
        .collection(FirebasePath.messages)
        .doc(userMessageDocRef.id);

    final String messageId = userMessageDocRef.id;
    final FriendMessage currentUserMessage = FriendMessage(
      messageId: messageId,
      message: message,
      mediaUrls: mediaUrls ?? [],
      sender: sender.id!,
      friendId: currentUserUid,
      messageType: type,
      sentAt: DateTime.now(),
    );
    final FriendMessage friendMessage = FriendMessage(
      messageId: messageId,
      message: message,
      mediaUrls: mediaUrls ?? [],
      sender: sender.id!,
      friendId: friend.id!,
      messageType: type,
      sentAt: DateTime.now(),
    );

    userMessageDocRef.set(currentUserMessage.toJson());

    friendMessageDocRef.set(friendMessage.toJson());

    _friendsCollection.doc(friend.id).update({
      'sentAt': FieldValue.serverTimestamp(),
      'recentMessage': message,
      'recentMessageSender': sender.userName,
    });

    _usersCollection
        .doc(friend.id)
        .collection(FirebasePath.friends)
        .doc(currentUserUid)
        .update({
      'sentAt': FieldValue.serverTimestamp(),
      'recentMessage': message,
      'recentMessageSender': sender.userName,
    });
  }

  Stream<List<FriendMessage>> getAllUserMessages(String friendId) {
    return _friendsCollection
        .doc(friendId)
        .collection(FirebasePath.messages)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (queryDocSnapshot) =>
                    FriendMessage.fromJson(queryDocSnapshot.data()),
              )
              .toList(),
        );
  }

  Stream<List<Friend>> getRecentMessageData() {
    return _friendsCollection
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (queryDocSnapshot) => Friend.fromJson(queryDocSnapshot.data()),
              )
              .toList(),
        );
  }

  Future<void> muteFriend(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection.doc(currentUserId).update({
      "mutedFriends": FieldValue.arrayUnion([friendId]),
    });
  }

  Future<void> unMuteFriend(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection.doc(currentUserId).update({
      "mutedFriends": FieldValue.arrayRemove([friendId]),
    });
  }

  Future<void> removeFriend(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final friendID = friendId;
    await _friendsCollection.doc(friendID).delete();
    await _usersCollection
        .doc(friendID)
        .collection(FirebasePath.friends)
        .doc(currentUserId)
        .delete();
    await _usersCollection.doc(currentUserId).update({
      'friends': FieldValue.arrayRemove([friendID]),
    });
    await _usersCollection.doc(friendId).update({
      'friends': FieldValue.arrayRemove([currentUserId]),
    });
  }

  Future<void> deleteMessageForMe(String friendId, String messageId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
  }

  Future<void> deleteMessageForAll(String friendId, String messageId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
    _usersCollection
        .doc(friendId)
        .collection(FirebasePath.friends)
        .doc(currentUserId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
  }
}
