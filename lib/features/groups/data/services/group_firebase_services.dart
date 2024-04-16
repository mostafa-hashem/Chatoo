import 'dart:io';

import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/helper/notification_services.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';

class GroupFirebaseServices {
  final _notificationServices = NotificationServices();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);
  final _groupsCollection =
      FirebaseFirestore.instance.collection(FirebasePath.groups);

  Stream<List<Group>> getAllUserGroups() {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.groups)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (queryDocSnapshot) => Group.fromJson(queryDocSnapshot.data()),
              )
              .toList(),
        );
  }

  Future<List<User>> getAllGroupMembers(String groupId) async {
    final DocumentSnapshot<Map<String, dynamic>> groupSnapshot =
        await _groupsCollection.doc(groupId).get();
    if (groupSnapshot.exists) {
      final List<dynamic> memberDataList =
          groupSnapshot.data()?['members'] as List<dynamic>;
      final List<User> users = memberDataList.map((userData) {
        return User.fromJson(userData as Map<String, dynamic>);
      }).toList();
      return users;
    } else {
      return [];
    }
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

  static CollectionReference<Group> getGroupsCollection() {
    return FirebaseFirestore.instance
        .collection(FirebasePath.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.groups)
        .withConverter<Group>(
          fromFirestore: (snapshot, _) => Group.fromJson(snapshot.data()!),
          toFirestore: (equipment, options) => equipment.toJson(),
        );
  }

  Stream<List<Group>> getGroups() {
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
    final groups = getGroupsCollection();
    final userGroupDocRef = await groups.add(group);
    group.groupId = userGroupDocRef.id;
    final Map<String, dynamic> currentUserMap = currentUser.toJson();
    _groupsCollection.doc(group.groupId).set(group.toJson());
    final groupDocRef = _groupsCollection.doc(group.groupId);
    groupDocRef.update({
      "members": FieldValue.arrayUnion([
        currentUserMap,
      ]),
    });
    await userGroupDocRef.update({
      "members": FieldValue.arrayUnion([
        currentUserMap,
      ]),
      "groupId": group.groupId,
    });
    await _usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "groups": FieldValue.arrayUnion([group.groupId]),
    });
  }

  Future<void> joinGroup(Group group, User user) async {
    _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.groups)
        .doc(group.groupId)
        .set(group.toJson());
    await _groupsCollection.doc(group.groupId).update({
      "members": FieldValue.arrayUnion([user.toJson()]),
    });
    await _usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
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
  Future<String> uploadImageAndUpdateGroupIcon(File imageFile, String groupId) async {
      final String downloadUrl = await uploadImage(imageFile);
      await _groupsCollection.doc(groupId).update({
        'groupIcon': downloadUrl,
      });
      final QuerySnapshot usersSnapshot = await _usersCollection.get();
      for (final userDoc in usersSnapshot.docs) {
        final String userId = userDoc.id;
        final DocumentReference userGroupDocRef = _usersCollection
            .doc(userId)
            .collection(FirebasePath.groups)
            .doc(groupId);
        final DocumentSnapshot userGroupSnapshot = await userGroupDocRef.get();
        if (userGroupSnapshot.exists) {
          await userGroupDocRef.update({
            'groupIcon': downloadUrl,
          });
        }
      }
      return downloadUrl;
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

    _usersCollection
        .doc(currentUserUid)
        .collection(FirebasePath.groups)
        .doc(group.groupId)
        .update({
      'recentMessage': message,
      'recentMessageSender': sender.userName,
    });
    final List<String> memberIds =
        group.members!.map((member) => member.id!).toList();
    for (final memberId in memberIds) {
      await _notificationServices.sendNotification(
        fcmToken: group.members
                ?.firstWhere((member) => member.id == memberId)
                .fCMToken ??
            '',
        title: 'New Message in ${group.groupName}',
        body: message,
      );
    }
  }

  Stream<bool> isUserInGroup(String groupId) {
    return _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection(FirebasePath.groups)
        .doc(groupId)
        .snapshots()
        .map((event) => event.exists);
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
      "members": FieldValue.arrayRemove([user.toJson()]),
    }).whenComplete(() async {
      final groupSnapshot = await _groupsCollection.doc(group.groupId).get();
      final groupData = Group.fromJson(groupSnapshot.data()!);
      if (groupData.members!.isEmpty && groupData.adminId == user.id) {
        await _groupsCollection.doc(group.groupId).delete();
      }
    });
  }
}
