import 'dart:async';

import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
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
  List<Friend> allFriends = [];
  List<User> searchedFriends = [];
  List<FriendMessage> filteredMessages = [];
  ScrollController scrollController = ScrollController();
  bool isUserFriend = false;


  Future<void> addFriend(User friend, User currentUser) async {
    emit(AddFriendLoading());
    try {
      await _friendFirebaseServices.addFriend(friend, currentUser);
      emit(AddFriendSuccess());
    } catch (e) {
      emit(AddFriendError(Failure.fromException(e).message));
    }
  }
  Future<void> checkUserIsFriend(String friendId) async {
    emit(CheckIsUserFriendLoading());
    try {
      _friendFirebaseServices.isUserFriend(friendId).listen((isFriend) {
        isUserFriend = isFriend;
        emit(CheckIsUserFriendSuccess());
      });
    } catch (e) {
      emit(CheckIsUserFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllUserFriends() async {
    emit(GetAllUserFriendsLoading());
    try {
          _friendFirebaseServices.getAllUserFriends().listen((friends) {
        allFriends = friends;
      });
      emit(GetAllUserFriendsSuccess());
    } catch (e) {
      emit(GetAllUserFriendsError(Failure.fromException(e).message));
    }
  }

  Future<void> searchOnFriend(String friendName) async {
    emit(SearchOnFriendLoading());
    try {
      _friendFirebaseServices.getUsers().listen((search){
      searchedFriends = search
          .where(
            (friend) => friend.userName?.contains(friendName) ?? false,
          )
          .toList();
      });
      emit(SearchOnFriendSuccess());
    } catch (e) {
      emit(SearchOnFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> sendMessageToFriend(
    User friend,
    String message,
    User sender,
  ) async {
    emit(SendMessageLoading());
    try {
      await _friendFirebaseServices.sendMessageToFriend(
        friend,
        message,
        sender,
      );
      emit(SendMessageSuccess());
    } catch (e) {
      emit(SendMessageError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllFriendMessages(String friendId) async {
    emit(GetAllFriendMessagesLoading());
    try {
       _friendFirebaseServices
          .getAllUserMessages(friendId)
          .listen((messages) {
         filteredMessages = messages;
        filteredMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      });
      emit(GetAllFriendMessagesSuccess());
    } catch (e) {
      emit(GetAllFriendMessagesError(Failure.fromException(e).message));
    }
  }

}
