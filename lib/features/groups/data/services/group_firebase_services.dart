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

  Stream<List<Group>> getAllUserGroups() {
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
        final List<Future<Group>> groupFutures = groupIds.map((groupId) async {
          final DocumentSnapshot groupSnapshot =
              await _groupsCollection.doc(groupId.toString()).get();
          return Group.fromJson(groupSnapshot.data()! as Map<String, dynamic>);
        }).toList();
        final List<Group> groups = await Future.wait(groupFutures);
        return groups;
      } else {
        return [];
      }
    });
  }

  Future<List<User>> getAllGroupMembers(String groupId) async {
    final DocumentSnapshot<Map<String, dynamic>> groupSnapshot =
        await _groupsCollection.doc(groupId).get();
    if (groupSnapshot.exists) {
      final List<dynamic> memberIds =
          groupSnapshot.data()?['members'] as List<dynamic>;
      final List<User> users = [];
      for (final memberId in memberIds) {
        final DocumentSnapshot userSnapshot =
            await _usersCollection.doc(memberId.toString()).get();
        if (userSnapshot.exists) {
          final userData = userSnapshot.data();
          if (userData != null && userData is Map<String, dynamic>) {
            final User user = User.fromJson(userData);
            users.add(user);
          }
        }
      }
      return users;
    } else {
      return [];
    }
  }

  Future<String> getAdminName(String adminId) async {
    final DocumentSnapshot<Map<String, dynamic>> adminSnapshot =
        await _usersCollection.doc(adminId).get();
    final adminData = adminSnapshot.data();
    return adminData?['userName'] as String? ?? 'Unknown';
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
    });
    await userGroupDocRef.update({
      "members": FieldValue.arrayUnion([
        currentUserId,
      ]),
      "groupId": group.groupId,
    });
    await _usersCollection.doc(currentUserId).update({
      "groups": FieldValue.arrayUnion([group.groupId]),
    });
  }

  Future<void> joinGroup(Group group, User user) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    await _groupsCollection.doc(group.groupId).update({
      "members": FieldValue.arrayUnion([currentUserId]),
    });

    await _usersCollection.doc(currentUserId).update({
      "groups": FieldValue.arrayUnion([group.groupId]),
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
  ) async {
    if (message.isEmpty) {
      return;
    }
    final String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference userMessageDocRef = _usersCollection
        .doc(currentUserUid)
        .collection(FirebasePath.groups)
        .doc(group.groupId)
        .collection(FirebasePath.messages)
        .doc();
    final DocumentReference groupMessageDocRef = _groupsCollection
        .doc(group.groupId)
        .collection(FirebasePath.messages)
        .doc(userMessageDocRef.id);

    final String messageId = userMessageDocRef.id;

    userMessageDocRef.set({
      'groupId': group.groupId,
      'messageId': messageId,
      'message': message,
      'sender': sender.toJson(),
      'sentAt': FieldValue.serverTimestamp(),
    });

    groupMessageDocRef.set({
      'groupId': group.groupId,
      'messageId': messageId,
      'message': message,
      'sender': sender.toJson(),
      'sentAt': FieldValue.serverTimestamp(),
    });

    _groupsCollection.doc(group.groupId).update({
      'recentMessage': message,
      'recentMessageSender': sender.userName,
    });
  }

  Stream<bool> isUserInGroup(String groupId, String userId) {
    return _groupsCollection.doc(groupId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final Map<String, dynamic>? data = snapshot.data();
        if (data != null && data.containsKey('members')) {
          final List<dynamic> members = data['members'] as List<dynamic>;
          return members.contains(userId);
        }
      }
      return false;
    });
  }

  Future<void> leaveGroup(Group group, User user) async {
    _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.groups)
        .doc(group.groupId)
        .delete();
    await _usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "groups": FieldValue.arrayRemove([group.groupId]),
    });
    await _groupsCollection.doc(group.groupId).update({
      "members": FieldValue.arrayRemove([user.id]),
    }).whenComplete(() async {
      if (group.members!.isEmpty) {
        if (user.id == group.adminId) {
          final groupSnapshot =
              await _groupsCollection.doc(group.groupId).get();
          final groupData = Group.fromJson(groupSnapshot.data()!);
          if (groupData.members!.isEmpty && groupData.adminId == user.id) {
            await _groupsCollection.doc(group.groupId).delete();
          }
        }
      }
    });
  }

  Future<void> deleteMessageForeAll(String groupId, String messageId) async {
    _groupsCollection
        .doc(groupId)
        .collection(FirebasePath.messages)
        .doc(messageId)
        .delete();
  }
}
