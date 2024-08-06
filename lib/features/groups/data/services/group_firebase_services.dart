import 'dart:io';

import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class GroupFirebaseServices {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);
  final _groupsCollection =
      FirebaseFirestore.instance.collection(FirebasePath.groups);

  Stream<List<Group?>> getAllUserGroups() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _usersCollection
        .doc(currentUser.uid)
        .snapshots()
        .flatMap((snapshot) {
      final userData = snapshot.data();
      if (userData != null) {
        final List<dynamic> groupIds =
            userData['groups'] as List<dynamic>? ?? [];
        if (groupIds.isEmpty) {
          return Stream.value([]);
        }

        final List<Stream<Group?>> groupStreams = groupIds.map((groupId) {
          return _groupsCollection
              .doc(groupId.toString())
              .snapshots()
              .map((groupSnapshot) {
            if (groupSnapshot.exists) {
              return Group.fromJson(groupSnapshot.data()!);
            }
            return null;
          });
        }).toList();

        return Rx.combineLatestList(groupStreams).map((groups) {
          return groups.where((group) => group != null).toList();
        });
      } else {
        return Stream.value([]);
      }
    });
  }

  Stream<List<User?>> getAllGroupMembers(String groupId) {
    return _groupsCollection.doc(groupId).snapshots().flatMap((snapshot) {
      final List<dynamic> memberIds =
          (snapshot.data()?['members'] ?? []) as List<dynamic>;
      if (memberIds.isEmpty) {
        return Stream.value([]);
      }

      final List<Stream<User?>> userStreams = memberIds.map((memberId) {
        return _usersCollection
            .doc(memberId.toString())
            .snapshots()
            .map((userSnapshot) {
          if (userSnapshot.exists) {
            final userData = userSnapshot.data();
            if (userData != null) {
              return User.fromJson(userData);
            }
          }
          return null;
        });
      }).toList();

      return Rx.combineLatestList(userStreams).map((users) {
        return users.where((user) => user != null).toList();
      });
    });
  }

  Stream<List<User>> getAllGroupRequests(String groupId) {
    return _groupsCollection.doc(groupId).snapshots().flatMap((snapshot) {
      final List<dynamic> userIds =
          (snapshot.data()?['requests'] ?? []) as List<dynamic>;
      if (userIds.isEmpty) {
        return Stream.value([]);
      }

      final List<Stream<User?>> userStreams = userIds.map((userId) {
        return _usersCollection
            .doc(userId.toString())
            .snapshots()
            .map((userSnapshot) {
          if (userSnapshot.exists) {
            final userData = userSnapshot.data();
            if (userData != null) {
              return User.fromJson(userData);
            }
          }
          return null;
        });
      }).toList();

      return Rx.combineLatestList(userStreams).map((users) {
        return users.where((user) => user != null).cast<User>().toList();
      });
    });
  }

  Future<void> approveToJoinGroup(
    String groupId,
    String requesterId,
  ) async {
    await _groupsCollection.doc(groupId).update({
      'requests': FieldValue.arrayRemove([requesterId]),
    });
    await _groupsCollection.doc(groupId).update({
      'members': FieldValue.arrayUnion([requesterId]),
    });
    await _usersCollection.doc(requesterId).update({
      'groups': FieldValue.arrayUnion([groupId]),
    });
  }

  Future<void> declineToJoinGroup(
    String groupId,
    String requesterId,
  ) async {
    await _groupsCollection.doc(groupId).update({
      'requests': FieldValue.arrayRemove([requesterId]),
    });
  }

  Future<void> makeAsAdmin(String groupId, String memberId) async {
    await _groupsCollection.doc(groupId).update({
      'groupAdmins': FieldValue.arrayUnion([memberId]),
    });
  }

  Future<void> removeFromAdmins(String groupId, String memberId) async {
    await _groupsCollection.doc(groupId).update({
      'groupAdmins': FieldValue.arrayRemove([memberId]),
    });
  }

  Future<void> changeGroupName(String groupId, String newGroupName) async {
    await _groupsCollection.doc(groupId).update({
      'groupName': newGroupName,
    });
  }

  Stream<List<GroupMessage>> getAllGroupMessages(String groupId) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return _usersCollection
        .doc(currentUserId)
        .collection(FirebasePath.groups)
        .doc(groupId)
        .collection(FirebasePath.messages)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (queryDocSnapshot) =>
                    GroupMessage.fromJson(queryDocSnapshot.data()),
              )
              .toList(),
        );
  }

  Stream<List<Group>> getGroupsForSearch() {
    return _groupsCollection.snapshots().map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (queryDocSnapshot) => Group.fromJson(queryDocSnapshot.data()),
              )
              .toList(),
        );
  }

  Future<void> createGroup(
    Group group,
    User currentUser,
  ) async {
    final userGroupDocRef = await _groupsCollection.add(group.toJson());
    group.groupId = userGroupDocRef.id;

    final String currentUserId = currentUser.id!;
    final groupDocRef = _groupsCollection.doc(group.groupId);
    groupDocRef.update({
      "members": FieldValue.arrayUnion([
        currentUserId,
      ]),
      "groupId": group.groupId,
      "groupAdmins": FieldValue.arrayUnion([
        currentUserId,
      ]),
    });
    await _usersCollection.doc(currentUserId).update({
      "groups": FieldValue.arrayUnion([group.groupId]),
    });
  }

  Future<void> requestToJoinGroup(Group group) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    await _groupsCollection.doc(group.groupId).update({
      "requests": FieldValue.arrayUnion([currentUserId]),
    });
  }

  Future<void> requestAddFriendToGroup(Group group, User friend) async {
    await _groupsCollection.doc(group.groupId).update({
      "requests": FieldValue.arrayUnion([friend.id]),
    });
  }

  Future<void> addFriendToGroup(Group group, User friend) async {
    await _groupsCollection.doc(group.groupId).update({
      "members": FieldValue.arrayUnion([friend.id]),
    });
    await _usersCollection.doc(friend.id).update({
      "groups": FieldValue.arrayUnion([group.groupId]),
    });
  }

  Future<void> cancelRequestToJoinGroup(String groupId) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    await _groupsCollection.doc(groupId).update({
      "requests": FieldValue.arrayRemove([currentUserId]),
    });
  }

  Future<String> uploadImage(File imageFile) async {
    final Reference storageRef =
        _storage.ref().child(FirebasePath.groups).child('groupIcon');
    final UploadTask uploadImage =
        storageRef.child('${imageFile.hashCode}').putFile(imageFile);
    final TaskSnapshot snapshot = await uploadImage;
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadImageAndUpdateGroupIcon(
    File imageFile,
    String groupId,
  ) async {
    final String downloadUrl = await uploadImage(imageFile);
    await _groupsCollection.doc(groupId).update({
      'groupIcon': downloadUrl,
    });
    return downloadUrl;
  }

  Future<User> getUserData(String userId) async {
    final currentUserId = userId;
    final docSnapshot = await _usersCollection.doc(currentUserId).get();
    return User.fromJson(docSnapshot.data()!);
  }

  Future<void> sendMessageToGroup(
    Group group,
    String message,
    User sender,
    List<String> mediaUrls,
    MessageType type,
    bool isAction,
    GroupMessage? repliedMessage,
  ) async {
    if (message.isEmpty && mediaUrls.isEmpty) {
      return;
    }
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final DocumentReference groupMessageDocRef = _groupsCollection
        .doc(group.groupId)
        .collection(FirebasePath.messages)
        .doc();
    final messageId = groupMessageDocRef.id;

    final GroupMessage groupMessage = GroupMessage(
      groupId: group.groupId,
      messageId: messageId,
      message: message,
      mediaUrls: mediaUrls,
      sender: sender,
      senderId: currentUserUid,
      messageType: type,
      isAction: isAction,
      repliedMessage: repliedMessage,
    );
    // For group
    groupMessageDocRef.set(groupMessage.toJson());

    final Map<String, dynamic> updatedUnreadCounts = {
      ...?group.unreadMessageCounts,
    };

    for (final dynamic memberId in group.members!) {
      if (memberId != currentUserUid) {
        updatedUnreadCounts[memberId as String] =
            (updatedUnreadCounts[memberId] ?? 0) + 1;
      }
    }
    _groupsCollection.doc(group.groupId).update({
      'recentMessage': message,
      'recentMessageSentAt': Timestamp.now().toDate(),
      'recentMessageSender': sender.userName,
      'recentMessageSenderId': sender.id,
      'unreadMessageCounts': updatedUnreadCounts,
    });
    //For every user in group
    for (final userId in group.members!) {
      final user = _usersCollection
          .doc(userId as String)
          .collection(FirebasePath.groups)
          .doc(group.groupId);

      user
          .collection(FirebasePath.messages)
          .doc(groupMessageDocRef.id)
          .set(groupMessage.toJson())
          .whenComplete(() {
        user.set(
          {
            'recentMessage': message,
            'recentMessageSentAt': Timestamp.now().toDate(),
            'recentMessageSender': sender.userName,
            'recentMessageSenderId': sender.id,
            if (userId != currentUserUid) 'unreadMessageCounts': FieldValue.increment(1),
          },
          SetOptions(merge: true),
        );
      });
    }
  }

  Future<void> markMessagesAsRead(String groupId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference groupDocRef = _groupsCollection.doc(groupId);

    final QuerySnapshot messagesSnapshot = await _groupsCollection
        .doc(groupId)
        .collection(FirebasePath.messages)
        .get();

    final DocumentSnapshot groupSnapshot = await groupDocRef.get();
    final groupData = groupSnapshot.data()! as Map<String, dynamic>;
    if (groupData['unreadMessageCounts'] != null) {
      final int unreadMessages =
          groupData['unreadMessageCounts'][currentUserId] as int;

      if (unreadMessages != 0) {
        await groupDocRef.update({
          'unreadMessageCounts.$currentUserId': 0,
        });
      }
      _usersCollection
          .doc(currentUserId)
          .collection(FirebasePath.groups)
          .doc(groupId)
          .update(
        {'unreadMessageCounts': 0},
      );
    }

    if (messagesSnapshot.docs.isNotEmpty) {
      for (final message in messagesSnapshot.docs) {
        final messageData = message.data()! as Map<String, dynamic>;
        final List seenList = messageData['readBy'] as List<dynamic>? ?? [];

        final bool alreadySeen =
            seenList.any((seen) => seen['userId'] == currentUserId);

        if (!alreadySeen) {
          await _groupsCollection
              .doc(groupId)
              .collection(FirebasePath.messages)
              .doc(message.id)
              .update({
            'readBy': FieldValue.arrayUnion([
              {'userId': currentUserId, 'viewAt': Timestamp.now().toDate()},
            ]),
          });
        }
      }
    }
  }

  Future<String> uploadMediaToGroup(
    String mediaPath,
    File mediaFile,
    String groupId,
    Future<String> Function(File imageFile) getFileName,
  ) async {
    final String fileName = await getFileName(mediaFile);
    final Reference storageRef = _storage
        .ref()
        .child(FirebasePath.groups)
        .child(mediaPath)
        .child(groupId)
        .child(fileName);

    final UploadTask uploadTask = storageRef.putFile(mediaFile);
    final TaskSnapshot snapshot = await uploadTask;

    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> leaveGroup(Group group, User user) async {
    await _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.groups)
        .doc(group.groupId)
        .delete()
        .whenComplete(() async {
      if (group.members!.isEmpty) {
        if (user.id == group.mainAdminId) {
          final groupSnapshot =
              await _groupsCollection.doc(group.groupId).get();
          final groupData = Group.fromJson(groupSnapshot.data()!);
          if (groupData.members!.isEmpty && groupData.mainAdminId == user.id) {
            await _groupsCollection.doc(group.groupId).delete();
          }
        }
      }
    });
    await _usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "groups": FieldValue.arrayRemove([group.groupId]),
    });
    await _groupsCollection.doc(group.groupId).update({
      "members": FieldValue.arrayRemove([user.id]),
    });
  }

  Future<void> kickUserFromGroup(String groupId, String userId) async {
    await _usersCollection.doc(userId).update({
      "groups": FieldValue.arrayRemove([groupId]),
    });
    await _groupsCollection.doc(groupId).update({
      "members": FieldValue.arrayRemove([userId]),
    });
  }

  Future<void> muteGroup(String groupId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection.doc(currentUserId).update({
      "mutedGroups": FieldValue.arrayUnion([groupId]),
    });
  }

  Future<void> unMuteGroup(String groupId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _usersCollection.doc(currentUserId).update({
      "mutedGroups": FieldValue.arrayRemove([groupId]),
    });
  }

  Stream<List<String>> getAllMutedGroups() {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data()!;
        if (data.containsKey('mutedGroups')) {
          final mutedGroups =
              List<String>.from(data['mutedGroups'] as List<dynamic>);
          return mutedGroups;
        }
      }
      return [];
    });
  }

  Future<void> deleteMessageForeAll({
    required String groupId,
    required String messageId,
    required String senderName,
    required String lastMessage,
    required String lastMessageSender,
    required DateTime lastMessageSentAt,
    required String lastMessageSenderId,
  }) async {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    _groupsCollection
        .doc(groupId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
    _usersCollection
        .doc(currentUserUid)
        .collection(FirebasePath.groups)
        .doc(groupId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
    final updates = {
      'recentMessage': lastMessage,
      'recentMessageSender': lastMessageSender,
      'recentMessageSentAt': Timestamp.fromDate(lastMessageSentAt),
      'recentMessageSenderId': lastMessageSenderId,
    };
    //*********************** For group ***********************
    final DocumentSnapshot<Map<String, dynamic>> groupSenderSnapshot =
        await _groupsCollection.doc(groupId).get();
    final groupSenderData = groupSenderSnapshot.data();

    if (groupSenderData != null &&
        groupSenderData['recentMessageSender'] == senderName) {
      _groupsCollection.doc(groupId).update(updates);
    }

    //*********************** For me ***********************
    final groupData = await _groupsCollection.doc(groupId).get();
    final usersIds = groupData['members'] as List<dynamic>;
    for (final userId in usersIds) {
      final senderSnapshot = await _usersCollection
          .doc(userId as String)
          .collection(FirebasePath.groups)
          .doc(groupId)
          .get();
      final senderData = senderSnapshot.data();

      if (senderData != null) {
        _usersCollection
            .doc(userId)
            .collection(FirebasePath.groups)
            .doc(groupId)
            .update(updates);
      }
    }
  }

  Future<void> deleteMessageForMe({
    required String groupId,
    required String messageId,
    required String senderName,
    required String lastMessage,
    required String lastMessageSender,
    required DateTime lastMessageSentAt,
    required String lastMessageSenderId,
  }) async {
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    _usersCollection
        .doc(currentUserUid)
        .collection(FirebasePath.groups)
        .doc(groupId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
    final updates = {
      'recentMessage': lastMessage,
      'recentMessageSender': lastMessageSender,
      'recentMessageSentAt': Timestamp.fromDate(lastMessageSentAt),
      'recentMessageSenderId': lastMessageSenderId,
    };

    //*********************** For me ***********************
    _usersCollection
        .doc(currentUserUid)
        .collection(FirebasePath.groups)
        .doc(groupId)
        .update(updates);
  }

  Future<void> editeMessage({
    required String groupId,
    required String messageId,
    required String newMessage,
  }) async {
    final groupData = await _groupsCollection.doc(groupId).get();
    final usersIds = groupData['members'] as List<dynamic>;
    for (final userId in usersIds) {
      _usersCollection
          .doc(userId as String)
          .collection(FirebasePath.groups)
          .doc(groupId)
          .collection(FirebasePath.messages)
          .doc(messageId)
          .update({'message': newMessage, 'edited': true});
    }
    _groupsCollection
        .doc(groupId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .update({'message': newMessage, 'edited': true});
  }

  Future<void> deleteGroup(String groupId) async {
    final groupData = await _groupsCollection.doc(groupId).get();
    final usersIds = groupData['members'] as List<dynamic>;
    for (final userId in usersIds) {
      _usersCollection
          .doc(userId as String)
          .collection(FirebasePath.groups)
          .doc(groupId)
          .delete();
      _usersCollection.doc(userId).update({
        'groups': FieldValue.arrayRemove([groupId]),
      });
    }
    _groupsCollection.doc(groupId).delete();
  }
}
