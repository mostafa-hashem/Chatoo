import 'package:chat_app/features/auth/data/models/login_data.dart';
import 'package:chat_app/features/auth/data/models/register_data.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';

class AuthFirebaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _usersCollection =
      FirebaseFirestore.instance.collection(FirebasePath.users);

  Future<User> register(RegisterData registerModel) async {
    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: registerModel.email,
      password: registerModel.password,
    );
    final uId = userCredential.user!.uid;
    final userModel = User(
      id: uId,
      email: registerModel.email,
      userName: registerModel.userName,
      fCMTokens: [registerModel.fCMToken],
      phoneNumber: registerModel.phoneNumber,
      city: registerModel.city,
      bio: 'Hello my friends!',
      requests: [],
      friends: [],
      groups: [],
      profileImage: FirebasePath.defaultImage,
    );
    await _usersCollection.doc(uId).set(userModel.toJson());
    await userCredential.user?.sendEmailVerification();
    return userModel;
  }

  Future<User> login(LoginData loginData) async {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: loginData.email,
      password: loginData.password,
    );
    final String uId = userCredential.user!.uid;

    if (!userCredential.user!.emailVerified) {
      throw Exception("Email not verified");
    }
    final DocumentSnapshot docSnapshot = await _usersCollection.doc(uId).get();
    if (docSnapshot.exists) {
      final user = docSnapshot.data()! as Map<String, dynamic>;
      List<String> fCMTokens = List<String>.from(user['fCMToken'] as Iterable<dynamic>);
      if (!fCMTokens.contains(loginData.fCMToken)) {
        fCMTokens.add(loginData.fCMToken);
        await _usersCollection.doc(uId).update({'fCMToken': fCMTokens});
      }
    }

    final userModel =
        User.fromJson(docSnapshot.data()! as Map<String, dynamic>);
    return userModel;
  }

  Future<void> logout() => FirebaseAuth.instance.signOut();

  Future<void> requestPasswordReset(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);

  bool getAuthStatus() => FirebaseAuth.instance.currentUser != null;

  Future<void> deleteAccount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser!.uid;


    await _usersCollection.doc(currentUserId).delete();

    final userProfileImageRef = _storage
        .ref()
        .child(FirebasePath.users)
        .child(FirebasePath.profilePictures)
        .child(currentUserId);
    final ListResult result = await userProfileImageRef.listAll();
    for (final fileRef in result.items) {
      await fileRef.delete();
    }

    await currentUser.delete();
  }
}
