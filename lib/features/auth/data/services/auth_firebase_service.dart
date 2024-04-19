import 'package:chat_app/features/auth/data/models/login_data.dart';
import 'package:chat_app/features/auth/data/models/register_data.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

class AuthFirebaseService {
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
      fCMToken: registerModel.fCMToken,
      phoneNumber: registerModel.phoneNumber,
      city: registerModel.city,
      bio: 'Hello my friends!',
      profileImage: FirebasePath.defaultImage,
    );
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentReference userDocRef = _usersCollection.doc(uId);
      transaction.set(userDocRef, userModel.toJson());
    });
    await userCredential.user?.sendEmailVerification();
    return userModel;
  }

  Future<User> login(LoginData loginData) async {
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: loginData.email,
      password: loginData.password,
    );

    if (!userCredential.user!.emailVerified) {
      throw Exception("Email not verified");
    }

    final String uId = userCredential.user!.uid;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final DocumentReference userDocRef = _usersCollection.doc(uId);
      final DocumentSnapshot userSnapshot = await transaction.get(userDocRef);

      if (userSnapshot.exists) {
        transaction.update(userDocRef, {'fCMToken': loginData.fCMToken});
      }
    });

    final DocumentSnapshot docSnapshot = await _usersCollection.doc(uId).get();
    final userModel =
        User.fromJson(docSnapshot.data()! as Map<String, dynamic>);
    return userModel;
  }

  Future<void> logout() => FirebaseAuth.instance.signOut();

  Future<void> requestPasswordReset(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);

  bool getAuthStatus() => FirebaseAuth.instance.currentUser != null;
}
