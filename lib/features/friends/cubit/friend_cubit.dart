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
  List<User> allFriends = [];
  List<User> searchedFriends = [];
  List<FriendMessage> filteredMessages = [];
  List<Friend> recentMessageData = [];
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  Future<void> addFriend(User friend, User currentUser) async {
    emit(AddFriendLoading());
    try {
      await _friendFirebaseServices.addFriend(friend, currentUser);
      emit(AddFriendSuccess());
    } catch (e) {
      emit(AddFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllUserFriends() async {
    emit(GetAllUserFriendsLoading());
    try {
      _friendFirebaseServices.getAllUserFriends().listen((friends) {
        allFriends = friends;
      emit(GetAllUserFriendsSuccess());
      });
    } catch (e) {
      emit(GetAllUserFriendsError(Failure.fromException(e).message));
    }
  }

  Future<void> searchOnFriend(String friendData) async {
    emit(SearchOnFriendLoading());
    try {
      _friendFirebaseServices.getUsers().listen((search) {
        searchedFriends = search
            .where(
              (friend) =>
                  friend.userName == friendData ||
                  friend.phoneNumber == friendData,
            )
            .toList();
      emit(SearchOnFriendSuccess());
      });
    } catch (e) {
      emit(SearchOnFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> sendMessageToFriend(
    User friend,
    String message,
    User sender,
  ) async {
    emit(SendMessageToFriendLoading());
    try {
      await _friendFirebaseServices.sendMessageToFriend(
        friend,
        message,
        sender,
      );
      emit(SendMessageToFriendSuccess());
    } catch (e) {
      emit(SendMessageToFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllFriendMessages(String friendId) async {
    emit(GetAllFriendMessagesLoading());
    try {
      _friendFirebaseServices.getAllUserMessages(friendId).listen((
        messages,
      ) {
        filteredMessages = messages;
        filteredMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      emit(GetAllFriendMessagesSuccess());
      });
    } catch (e) {
      emit(GetAllFriendMessagesError(Failure.fromException(e).message));
    }
  }

  Future<void> getRecentMessageData() async {
    emit(GetRecentMessageDataLoading());
    try {
      _friendFirebaseServices.getRecentMessageData().listen((
        messages,
      ) {
        recentMessageData = messages;
        recentMessageData.sort((a, b) => a.sentAt!.compareTo(b.sentAt!));
      });
      emit(GetRecentMessageDataSuccess());
    } catch (e) {
      emit(GetRecentMessageDataError(Failure.fromException(e).message));
    }
  }

  Future<void> removeFriend(String friendId) async {
    emit(RemoveFriendLoading());
    try {
      await _friendFirebaseServices.removeFriend(friendId);
      emit(RemoveFriendSuccess());
    } catch (e) {
      emit(RemoveFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> deleteMessageForMe(String friendId, String messageId) async {
    emit(DeleteMessageForMeLoading());
    try {
      await _friendFirebaseServices.deleteMessageForMe(friendId, messageId);
      emit(DeleteMessageForMeSuccess());
    } catch (e) {
      emit(DeleteMessageForMeError(Failure.fromException(e).message));
    }
  }

  Future<void> deleteMessageForAll(String friendId, String messageId) async {
    emit(DeleteMessageForMeAndFriendLoading());
    try {
      await _friendFirebaseServices.deleteMessageForAll(friendId, messageId);
      emit(DeleteMessageForMeAndFriendSuccess());
    } catch (e) {
      emit(DeleteMessageForMeAndFriendError(Failure.fromException(e).message));
    }
  }
}
