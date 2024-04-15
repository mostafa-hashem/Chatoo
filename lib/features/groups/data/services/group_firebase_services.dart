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

  Future<List<Group>> getGroups() async {
    final querySnapshot = await _groupsCollection.get();
    return querySnapshot.docs
        .map((queryDocSnapshot) => Group.fromJson(queryDocSnapshot.data()))
        .toList();
  }

  Future<void> createGroup(
    Group group,
    String userName,
    User currentUser,
  ) async {
    final groups = getGroupsCollection();
    final userGroupDocRef = await groups.add(group);
    group.groupId = userGroupDocRef.id;
    final Map<String, dynamic> currentUserMap = currentUser.toJson();
    final groupDocRef = await _groupsCollection.add(group.toJson());
    groupDocRef.update({
      "members": FieldValue.arrayUnion([
        currentUserMap,
      ]),
    });
    await userGroupDocRef.update({
      "members": FieldValue.arrayUnion([
        currentUserMap,
      ]),
      "groupId": userGroupDocRef.id,
    });
    await _usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).update({
      "groups": FieldValue.arrayUnion(["${group.groupId}_${group.groupName}"]),
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
        .doc();

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
  }

  Future<bool> isUserInGroup(String userId, String groupId) async {
    final DocumentSnapshot userDocSnapshot = await _usersCollection
        .doc(userId)
        .collection(FirebasePath.groups)
        .doc(groupId)
        .get();

    return userDocSnapshot.exists;
  }

  Future<void> joinGroup(String userId, Group group, User user) async {
    _usersCollection
        .doc(userId)
        .collection(FirebasePath.groups)
        .add(group.toJson());

    await _usersCollection.doc(userId).update({
      "groups": FieldValue.arrayUnion([group.groupId]),
    });
    await _groupsCollection.doc(group.groupId).update({
      "members": FieldValue.arrayUnion([user]),
    });
  }

  Future<void> leaveGroup(String userId, String groupId, User user) async {
    final DocumentReference userDocReference = _usersCollection
        .doc(userId)
        .collection(FirebasePath.groups)
        .doc(groupId);

    await userDocReference.delete();

    await _usersCollection.doc(userId).update({
      "groups": FieldValue.arrayRemove([groupId]),
    });
    await _groupsCollection.doc(groupId).update({
      "members": FieldValue.arrayRemove([user]),
    });
  }
}
