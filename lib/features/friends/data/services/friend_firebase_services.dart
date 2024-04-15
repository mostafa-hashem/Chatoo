import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class FriendFirebaseServices {
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);
  final _friendsCollection = FirebaseFirestore.instance
      .collection(FirebasePath.users)
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection(FirebasePath.friends);

  Stream<List<User>> getUsers()  {
    return _usersCollection
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
          .map(
            (queryDocSnapshot) => User.fromJson(queryDocSnapshot.data()),
      )
          .toList(),
    );

  }

  Stream<List<Friend>> getAllUserFriends() {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.friends)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (queryDocSnapshot) => Friend.fromJson(queryDocSnapshot.data()),
              )
              .toList(),
        );
  }

  Future<void> addFriend(User friend, User currentUser) async {
    _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.friends)
        .doc(friend.id)
        .set({
      'recentMessage': '',
      'recentMessageSender': '',
      "friendData": friend.toJson(),
    });
    _usersCollection.doc(friend.id).collection(FirebasePath.friends).doc(currentUser.id).set({
      'recentMessage': '',
      'recentMessageSender': '',
      "friendData": currentUser.toJson(),
    });
    _usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "friends": FieldValue.arrayUnion([
        friend.id,
      ]),
    });
    _usersCollection.doc(friend.id).update({
      "friends": FieldValue.arrayUnion([
        FirebaseAuth.instance.currentUser!.uid,
      ]),
    });
  }

  Future<void> sendMessageToFriend(
    User friend,
    String message,
    User sender,
  ) async {
    if (message.isEmpty) {
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
        .doc();

    final String messageId = userMessageDocRef.id;

    userMessageDocRef.set({
      'friendId': friend.id,
      'messageId': messageId,
      'message': message,
      'sender': sender.toJson(),
      'sentAt': FieldValue.serverTimestamp(),
    });

    friendMessageDocRef.set({
      'friendId': currentUserUid,
      'messageId': messageId,
      'message': message,
      'sender': sender.toJson(),
      'sentAt': FieldValue.serverTimestamp(),
    });

    _friendsCollection.doc(friend.id).update({
      'recentMessage': message,
      'recentMessageSender': sender.userName,
    });

    _usersCollection
        .doc(currentUserUid)
        .collection(FirebasePath.groups)
        .doc(friend.id)
        .update({
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
                (queryDocSnapshot) => FriendMessage.fromJson(queryDocSnapshot.data()),
              )
              .toList(),
        );
  }
}
