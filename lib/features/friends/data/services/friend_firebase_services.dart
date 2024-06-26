import 'dart:io';

import 'package:chat_app/features/friends/data/model/combined_friend.dart';
import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class FriendFirebaseServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);
  final _friendsCollection = FirebaseFirestore.instance
      .collection(FirebasePath.users)
      .doc(FirebaseAuth.instance.currentUser?.uid)
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

  Stream<List<CombinedFriend>> getCombinedFriends() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    final Stream<List<String>> friendIdsStream =
        _usersCollection.doc(currentUser.uid).snapshots().map((snapshot) {
      final dynamic userData = snapshot.data();
      if (userData != null && userData is Map<String, dynamic>) {
        final List<dynamic> friendIds =
            (userData['friends'] ?? []) as List<dynamic>;
        return friendIds.map((id) => id.toString()).toList();
      } else {
        return [];
      }
    });

    final Stream<List<User?>> allUserFriendsStream =
        friendIdsStream.switchMap((friendIds) {
      if (friendIds.isEmpty) {
        return Stream.value([]);
      }
      final friendStreams = friendIds.map((friendId) {
        return _usersCollection.doc(friendId).snapshots().map((snapshot) {
          if (snapshot.exists) {
            return User.fromJson(snapshot.data()!);
          }
          return null;
        });
      });
      return CombineLatestStream.list(friendStreams);
    });

    final Stream<List<FriendRecentMessage>> recentMessageDataStream =
        _friendsCollection.orderBy('sentAt', descending: true).snapshots().map(
              (querySnapshot) => querySnapshot.docs
                  .map(
                    (queryDocSnapshot) =>
                        FriendRecentMessage.fromJson(queryDocSnapshot.data()),
                  )
                  .toList(),
            );

    final Stream<List<Story>> storiesStream = FirebaseFirestore.instance
        .collection(FirebasePath.stories)
        .where(
          'uploadedAt',
          isGreaterThanOrEqualTo:
              DateTime.now().toLocal().subtract(const Duration(hours: 24)),
        )
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map((doc) => Story.fromJson(doc.data()))
              .toList(),
        );

    return Rx.combineLatest3<List<User?>, List<FriendRecentMessage>,
        List<Story>, List<CombinedFriend>>(
      allUserFriendsStream,
      recentMessageDataStream,
      storiesStream,
      (users, messages, stories) {
        final combinedFriends = users.map((user) {
          final recentMessage = messages.firstWhere(
            (message) => message.friendId == user?.id,
            orElse: () => FriendRecentMessage.empty(),
          );

          final List<Story> userStories =
              stories.where((story) => story.userId == user?.id).toList();

          return CombinedFriend(
            user: user,
            recentMessageData: recentMessage,
            stories: userStories,
          );
        }).toList();
        combinedFriends.sort((a, b) {
          final aTime = a.recentMessageData.sentAt?.toLocal() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.recentMessageData.sentAt?.toLocal() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

        return combinedFriends;
      },
    );
  }

  Future<void> markMessagesAsRead(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final DocumentReference myRef = _usersCollection
        .doc(friendId)
        .collection(FirebasePath.friends)
        .doc(currentUserId);
    final DocumentReference friendRef = _friendsCollection.doc(friendId);
    final data = await myRef.get();
    if (data["recentMessageSenderId"] != currentUserId) {
      await myRef.update({
        'seen': true,
      });
    }
    await friendRef.update({
      'unreadCount': 0,
    });

    final QuerySnapshot friendMessagesSnapshot = await _friendsCollection
        .doc(friendId)
        .collection(FirebasePath.messages)
        .get();

    if (friendMessagesSnapshot.docs.isNotEmpty) {
      for (final message in friendMessagesSnapshot.docs) {
        final messageData = message.data()! as Map<String, dynamic>;
        final Map<String, dynamic> seenMap =
            messageData['readBy'] as Map<String, dynamic>? ?? {};
        final bool alreadySeen = seenMap["userId"] == currentUserId;
        if (alreadySeen) continue;
        if (!alreadySeen && messageData['sender'] != currentUserId) {
          final DocumentReference newMessage =
              myRef.collection(FirebasePath.messages).doc(message.id);

          await newMessage.update({'readBy.$currentUserId': Timestamp.now()});
        }
      }
    }
  }

  Future<void> updateTypingStatus({
    required String friendId,
    required bool isTyping,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection
        .doc(friendId)
        .collection(FirebasePath.friends)
        .doc(currentUserId)
        .update({'typing': isTyping});
  }

  Future<void> updateRecordingStatus({
    required bool isRecording,
    required String friendId,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection
        .doc(friendId)
        .collection(FirebasePath.friends)
        .doc(currentUserId)
        .update(
      {"recording": isRecording},
    );
  }

  Stream<List<FriendMessage>> getAllUserMessages(String friendId) {
    return _friendsCollection
        .doc(friendId)
        .collection(FirebasePath.messages)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      final messages = querySnapshot.docs
          .map(
            (queryDocSnapshot) =>
                FriendMessage.fromJson(queryDocSnapshot.data()),
          )
          .toList();
      return messages;
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

  Future<void> removeFriendRequest(String friendId) async {
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
      'friendId': currentUserId,
      'recentMessage': '',
      'recentMessageSender': '',
      'sentAt': Timestamp.now().toDate(),
      'addedAt': Timestamp.now().toDate(),
    });

    await _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .set({
      'friendId': friendId,
      'recentMessage': '',
      'recentMessageSender': '',
      'sentAt': Timestamp.now().toDate(),
      'addedAt': Timestamp.now().toDate(),
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
    FriendMessage? repliedMessage,
    Story? replayToStory,
  ) async {
    if (message!.isEmpty && (mediaUrls == null || mediaUrls.isEmpty)) {
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

    final now = Timestamp.now().toDate();
    final String messageId = userMessageDocRef.id;
    final FriendMessage currentUserMessage = FriendMessage(
      messageId: messageId,
      message: message,
      mediaUrls: mediaUrls ?? [],
      sender: sender.id!,
      friendId: currentUserUid,
      messageType: type,
      sentAt: now,
      repliedMessage: repliedMessage,
      replayToStory: replayToStory,
    );
    final FriendMessage friendMessage = FriendMessage(
      messageId: messageId,
      message: message,
      mediaUrls: mediaUrls ?? [],
      sender: sender.id!,
      friendId: friend.id!,
      messageType: type,
      sentAt: now,
      repliedMessage: repliedMessage,
      replayToStory: replayToStory,
    );

    await userMessageDocRef.set(currentUserMessage.toJson());
    await friendMessageDocRef.set(friendMessage.toJson());
    _friendsCollection.doc(friend.id).update({
      'sentAt': now,
      'recentMessage': message,
      'recentMessageSender': sender.userName,
      'recentMessageSenderId': sender.id,
      'seen': false,
    });
    _usersCollection
        .doc(friend.id)
        .collection(FirebasePath.friends)
        .doc(currentUserUid)
        .update({
      'sentAt': now,
      'recentMessage': message,
      'recentMessageSender': sender.userName,
      'recentMessageSenderId': sender.id,
      'unreadCount': FieldValue.increment(1),
      'seen': false,
    });
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

  Stream<List<String>> getAllMutedFriends() {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data()!;
        if (data.containsKey('mutedFriends')) {
          final mutedFriends =
              List<String>.from(data['mutedFriends'] as List<dynamic>);
          return mutedFriends;
        }
      }
      return [];
    });
  }

  Future<void> removeFriend(String friendId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final friendID = friendId;
     _friendsCollection.doc(friendID).delete();
     _usersCollection
        .doc(friendID)
        .collection(FirebasePath.friends)
        .doc(currentUserId)
        .delete();
     _usersCollection.doc(currentUserId).update({
      'friends': FieldValue.arrayRemove([friendID]),
    });
     _usersCollection.doc(friendId).update({
      'friends': FieldValue.arrayRemove([currentUserId]),
    });
  }

  Future<void> deleteChat(String friendId, DateTime addedAt) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .update({
      'sentAt': addedAt,
      'recentMessage': '',
      'recentMessageSender': '',
      'recentMessageSenderId': '',
      'unreadCount': 0,
      'seen': false,
    });
    final messagesCollection = _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .collection(FirebasePath.messages);

    final querySnapshot = await messagesCollection.get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteChatForAll(String friendId, DateTime addedAt) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final userDocRef = _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId);

    final friendDocRef = _usersCollection
        .doc(friendId)
        .collection(FirebasePath.friends)
        .doc(currentUserId);

    final updates = {
      'sentAt': addedAt,
      'recentMessage': '',
      'recentMessageSender': '',
      'recentMessageSenderId': '',
      'unreadCount': 0,
      'seen': false,
    };

    await userDocRef.update(updates);
    await friendDocRef.update(updates);

    final messagesCollection = userDocRef.collection(FirebasePath.messages);
    final querySnapshot = await messagesCollection.get();
    for (final doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

    final friendMessagesCollection =
        friendDocRef.collection(FirebasePath.messages);
    final friendQuerySnapshot = await friendMessagesCollection.get();
    for (final doc in friendQuerySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteMessageForMe({
    required String friendId,
    required String messageId,
    required String lastMessage,
    required String lastMessageSender,
    required String lastMessageSenderId,
    required DateTime? sentAt,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
    _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .update({
      'sentAt': Timestamp.fromDate(sentAt!),
      'recentMessage': lastMessage,
      'recentMessageSender': lastMessageSender,
      'recentMessageSenderId': lastMessageSenderId,
    });
  }

  Future<void> deleteMessageForAll({
    required String friendId,
    required String messageId,
    required String lastMessage,
    required String lastMessageSender,
    required String recentMessageSenderId,
    required DateTime sentAt,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
    _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .update({
      'sentAt': Timestamp.fromDate(sentAt),
      'recentMessage': lastMessage,
      'recentMessageSender': lastMessageSender,
      'recentMessageSenderId': recentMessageSenderId,
    });
    _usersCollection
        .doc(friendId)
        .collection(FirebasePath.friends)
        .doc(currentUserId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
    _usersCollection
        .doc(friendId)
        .collection(FirebasePath.friends)
        .doc(currentUserId)
        .update({
      'sentAt': Timestamp.fromDate(sentAt),
      'recentMessage': lastMessage,
      'recentMessageSender': lastMessageSender,
      'recentMessageSenderId': recentMessageSenderId,
    });
  }

  Future<void> editeMessage({
    required String friendId,
    required String messageId,
    required String newMessage,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .update({'message': newMessage, 'edited': true});

    _usersCollection
        .doc(friendId)
        .collection(FirebasePath.friends)
        .doc(currentUserId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .update({'message': newMessage, 'edited': true});
  }
}
