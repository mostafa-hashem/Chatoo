import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/services/friend_firebase_services.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendCubit extends Cubit<FriendStates> {
  FriendCubit() : super(FriendInit());

  static FriendCubit get(BuildContext context) => BlocProvider.of(context);
  final _friendFirebaseServices = FriendFirebaseServices();
  List<User> allUsers = [];
  List<User> allFriends = [];
  List<User> searchedFriends = [];

  Future<void> addFriend(User friend,User currentUser) async {
    emit(AddFriendLoading());
    try {
      await _friendFirebaseServices.addFriend(friend, currentUser);
      emit(AddFriendSuccess());
    } catch (e) {
      emit(AddFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllUsers() async {
    emit( GetAllUsersLoading());
    try {
      allUsers = await _friendFirebaseServices.getUsers();
      emit( GetAllUsersSuccess());
    } catch (e) {
      emit(
        GetAllUsersError(Failure.fromException(e).message),
      );
    }
  }

  Future<void> getAllUserFriends() async {
    emit(GetAllUserFriendsLoading());
    try {
      allFriends = await _friendFirebaseServices.getAllUserFriends();
      emit(GetAllUserFriendsSuccess());
    } catch (e) {
      emit(GetAllUserFriendsError(Failure.fromException(e).message));
    }
  }


  Future<void> searchOnFriend(String friendName) async {
    emit(SearchOnFriendLoading());
    try {
      allUsers = await _friendFirebaseServices.getUsers();
      searchedFriends = allUsers
          .where(
            (friend) =>
            friend.userName == friendName || friend.id == friendName,
      )
          .toList();
      emit(SearchOnFriendSuccess());
    } catch (e) {
      emit(SearchOnFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> sendMessageToFriend(User friend, User sender, String message) async {
    emit(SendMessageLoading());
    try {
      await _friendFirebaseServices.sendMessageToFriend(friend, message, sender);
      emit(SendMessageSuccess());
    } catch (e) {
      emit(SendMessageError(Failure.fromException(e).message));
    }
  }

}
