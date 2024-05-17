import 'dart:async';
import 'dart:io';

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
  List<User?> allFriends = [];
  List<User> allUserRequests = [];
  List<User> searchedFriends = [];
  User? friendData;
  List<FriendMessage> filteredMessages = [];
  List<Friend> recentMessageData = [];
  ScrollController scrollController = ScrollController();
  List<String> mediaUrls = [];
  TextEditingController messageController = TextEditingController();

  Future<void> requestToAddFriend(String friendId) async {
    emit(RequestToAddFriendLoading());
    try {
      await _friendFirebaseServices.requestToAddFriend(friendId);
      emit(RequestToAddFriendSuccess());
    } catch (e) {
      emit(RequestToAddFriendError(Failure.fromException(e).message));
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

  Future<void> getAllUserRequests() async {
    emit(GetAllUserRequestsLoading());
    try {
      _friendFirebaseServices.getAllUserRequests().listen((requests) {
        allUserRequests = requests;
        emit(GetAllUserRequestsSuccess());
      });
    } catch (e) {
      emit(GetAllUserRequestsError(Failure.fromException(e).message));
    }
  }

  Future<void> approveToAddFriend(String friendId) async {
    emit(ApproveToAddFriendLoading());
    try {
      await _friendFirebaseServices.approveFriendRequest(friendId);
      emit(ApproveToAddFriendSuccess());
    } catch (e) {
      emit(ApproveToAddFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> declineToAddFriend(String friendId) async {
    emit(DeclineToAddFriendLoading());
    try {
      await _friendFirebaseServices.declineFriendRequest(friendId);
      emit(DeclineToAddFriendSuccess());
    } catch (e) {
      emit(DeclineToAddFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> getFriendData(String friendId) async {
    emit(GetFriendDataLoading());
    try {
      _friendFirebaseServices.getFriendData(friendId).listen((friend) {
        friendData = friend;
        emit(GetFriendDataSuccess());
      });
    } catch (e) {
      emit(GetFriendDataError(Failure.fromException(e).message));
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

  Future<void> sendMessageToFriend({
    required User friend,
    required String message,
    required User sender,
    required MessageType type,
    double? duration,
  }) async {
    emit(SendMessageToFriendLoading());
    try {
      await _friendFirebaseServices.sendMessageToFriend(
        friend,
        message,
        sender,
        mediaUrls,
        type,
        duration
      );
      emit(SendMessageToFriendSuccess());
    } catch (e) {
      emit(SendMessageToFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> sendMediaToFriend(
      String mediaPath, File mediaFile, String friendPathId) async {
    emit(SendMediaToFriendLoading());
    try {
      mediaUrls.clear();
      final String downloadUrl = await _friendFirebaseServices
          .sendMediaToFriend(mediaPath, mediaFile, friendPathId);
      mediaUrls.add(downloadUrl);
      emit(SendMediaToFriendSuccess());
    } catch (e) {
      emit(SendMediaToFriendError(Failure.fromException(e).message));
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

  Future<void> removeFriendRequest(String friendId) async {
    emit(RemoveFriendRequestLoading());
    try {
      await _friendFirebaseServices.requestFriendRequest(friendId);
      emit(RemoveFriendRequestSuccess());
    } catch (e) {
      emit(RemoveFriendRequestError(Failure.fromException(e).message));
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
