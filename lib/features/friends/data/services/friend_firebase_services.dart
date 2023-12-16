import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendFirebaseServices {
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);


  Future<List<Group>> getAllUserFriends() async {
    final querySnapshot = await _usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('friends')
        .get();

    return querySnapshot.docs
        .map((queryDocSnapshot) => Group.fromJson(queryDocSnapshot.data()))
        .toList();
  }
  Future<void> addFriend() async {

  }
}
