import 'dart:io';

import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';

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
        .asyncMap((snapshot) async {
      final dynamic userData = snapshot.data();
      if (userData != null && userData is Map<String, dynamic>) {
        final List<dynamic> groupIds =
            (userData['groups'] ?? []) as List<dynamic>;
        final List<Future<Group?>> groupFutures = groupIds.map((groupId) async {
          final DocumentSnapshot groupSnapshot =
              await _groupsCollection.doc(groupId.toString()).get();
          if (groupSnapshot.exists) {
            return Group.fromJson(
              groupSnapshot.data()! as Map<String, dynamic>,
            );
          }
        }).toList();
        final List<Group?> groups = await Future.wait(groupFutures);
        return groups;
      } else {
        return [];
      }
    });
  }

  Stream<List<User?>> getAllGroupMembers(String groupId) {
    return _groupsCollection
        .doc(groupId)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<dynamic> memberIds =
          (snapshot.data()?['members'] ?? []) as List<dynamic>;
      final List<Future<User?>> userFutures = memberIds.map((memberId) async {
        final DocumentSnapshot userSnapshot =
            await _usersCollection.doc(memberId.toString()).get();
        if (userSnapshot.exists) {
          final userData = userSnapshot.data();
          if (userData != null && userData is Map<String, dynamic>) {
            return User.fromJson(userData);
          }
        }
        return null; // or handle the absence of user data differently
      }).toList();
      final List<User?> users = await Future.wait(userFutures);
      return users.where((user) => user != null).toList();
    });
  }

  Stream<List<User>> getAllGroupRequests(String groupId) {
    return _groupsCollection
        .doc(groupId)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<dynamic> userIds =
          (snapshot.data()?['requests'] ?? []) as List<dynamic>;
      final List<Future<User>> userFutures = userIds.map((userId) async {
        final DocumentSnapshot userSnapshot =
            await _usersCollection.doc(userId.toString()).get();
        return User.fromJson(userSnapshot.data()! as Map<String, dynamic>);
      }).toList();
      final List<User> users = await Future.wait(userFutures);
      return users;
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
    return _groupsCollection
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
    final Reference storageRef = _storage.ref().child('groups');
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
    bool isAction,
  ) async {
    if (message.isEmpty) {
      return;
    }
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final DocumentReference groupMessageDocRef = _groupsCollection
        .doc(group.groupId)
        .collection(FirebasePath.messages)
        .doc();
    final messageId = groupMessageDocRef.id;
    await groupMessageDocRef.set({
      'groupId': group.groupId,
      'messageId': messageId,
      'senderId': currentUserUid,
      'message': message,
      'sender': sender.toJson(),
      'sentAt': FieldValue.serverTimestamp(),
      'isAction': isAction,
    });

    await _groupsCollection.doc(group.groupId).update({
      'recentMessage': message,
      'recentMessageSentAt': DateTime.now(),
      'recentMessageSender': sender.userName,
    });
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

  Future<void> deleteMessageForeAll(
    String groupId,
    String messageId,
    String senderName,
    String lastMessage,
    String lastMessageSender,
  ) async {
    _groupsCollection
        .doc(groupId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete()
        .whenComplete(() async {
      final DocumentSnapshot<Map<String, dynamic>> senderSnapshot =
          await _groupsCollection.doc(groupId).get();
      final senderData = senderSnapshot.data();
      if (senderData?['recentMessageSender'] == senderName) {
        _groupsCollection.doc(groupId).update({
          'recentMessage': lastMessage,
          'recentMessageSender': lastMessageSender,
        });
      }
    });
  }
  Future<void> deleteGroup(String groupId) async {
    await _groupsCollection.doc(groupId).delete();
  }
}
