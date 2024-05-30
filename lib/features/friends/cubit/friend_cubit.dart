import 'dart:async';
import 'dart:io';

import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/combined_friend.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/friends/data/services/friend_firebase_services.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendCubit extends Cubit<FriendStates> {
  FriendCubit() : super(FriendInit());

  static FriendCubit get(BuildContext context) => BlocProvider.of(context);
  final _friendFirebaseServices = FriendFirebaseServices();
  List<User> allUserRequests = [];
  List<CombinedFriend> combinedFriends = [];
  List<String> mutedFriends = [];
  List<User> searchedFriends = [];
  User? friendData;
  List<FriendMessage> filteredMessages = [];
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

  void getFriendData(String friendId) {
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
                  friend.userName?.toLowerCase() == friendData.toLowerCase() ||
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
  }) async {
    emit(SendMessageToFriendLoading());
    try {
      await _friendFirebaseServices.sendMessageToFriend(
        friend,
        message,
        sender,
        mediaUrls,
        type,
      );
      emit(SendMessageToFriendSuccess());
    } catch (e) {
      emit(SendMessageToFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> sendMediaToFriend(
    String mediaPath,
    File mediaFile,
    String friendPathId,
    Future<String> Function(File imageFile) getFileName,
  ) async {
    emit(SendMediaToFriendLoading());
    try {
      mediaUrls.clear();
      final String downloadUrl =
          await _friendFirebaseServices.sendMediaToFriend(
        mediaPath,
        mediaFile,
        friendPathId,
        getFileName,
      );
      mediaUrls.add(downloadUrl);
      emit(SendMediaToFriendSuccess());
    } catch (e) {
      emit(SendMediaToFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllFriendMessages(String friendId) async {
    emit(GetAllFriendMessagesLoading());
    try {
      _friendFirebaseServices.getAllUserMessages(friendId).listen((messages) {
        filteredMessages = messages
            .where((message) => message.sentAt?.toLocal() != null)
            .toList();

        if (filteredMessages.isNotEmpty) {
          filteredMessages.sort(
            (a, b) => b.sentAt!.toLocal().compareTo(a.sentAt!.toLocal()),
          );
        }
        emit(GetAllFriendMessagesSuccess());
      });
    } catch (e) {
      emit(GetAllFriendMessagesError(Failure.fromException(e).message));
    }
  }

  void getCombinedFriends() {
    emit(GetCombinedFriendsLoading());
    try {
      _friendFirebaseServices.getCombinedFriends().listen((combinedFriend) {
        combinedFriends = combinedFriend;

        // Filter out CombinedFriend entries where recentMessageData is null
        combinedFriends = combinedFriends.toList();

        // Sort the combinedFriends list
        combinedFriends.sort((a, b) {
          final aTime = a.recentMessageData.sentAt?.toLocal() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.recentMessageData.sentAt?.toLocal() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

        emit(GetCombinedFriendsSuccess());
      });
    } catch (e) {
      emit(GetCombinedFriendsError(Failure.fromException(e).message));
    }
  }

  Future<void> markMessagesAsRead(String friendId) async {
    emit(MarkMessagesAsReadLoading());
    try {
      await _friendFirebaseServices.markMessagesAsRead(
        friendId,
      );
      emit(MarkMessagesAsReadSuccess());
    } catch (e) {
      emit(MarkMessagesAsReadError(Failure.fromException(e).message));
    }
  }

  Future<void> updateTypingStatus({
    required String friendId,
    required bool isTyping,
  }) async {
    emit(UpdateTypingStatusLoading());
    try {
      await _friendFirebaseServices.updateTypingStatus(
        friendId: friendId,
        isTyping: isTyping,
      );
      emit(UpdateTypingStatusSuccess());
    } catch (e) {
      emit(UpdateTypingStatusError(Failure.fromException(e).message));
    }
  }

  bool isTyping = false;

  void listenToTypingStatus(String friendId) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection(FirebasePath.users)
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        isTyping = (snapshot.data()!['typing'] as bool?)!;
        emit(UpdateTypingStatus(isTyping));
      }
    });
  }

  Future<void> updateRecordingStatus({
    required String friendId,
    required bool isRecording,
  }) async {
    emit(UpdateRecordingStatusLoading());
    try {
      await _friendFirebaseServices.updateRecordingStatus(
        friendId: friendId,
        isRecording: isRecording,
      );
      emit(UpdateRecordingStatusSuccess());
    } catch (e) {
      emit(UpdateRecordingStatusError(Failure.fromException(e).message));
    }
  }

  bool isRecording = false;

  void listenToRecordingStatus(String friendId) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection(FirebasePath.users)
        .doc(currentUserId)
        .collection(FirebasePath.friends)
        .doc(friendId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        isRecording = (snapshot.data()!['recording'] as bool?)!;
        emit(UpdateRecordingStatus(isRecording));
      }
    });
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

  Future<void> muteFriend(String friendId) async {
    emit(MuteFriendLoading());
    try {
      await _friendFirebaseServices.muteFriend(friendId);
      emit(MuteFriendSuccess());
    } catch (e) {
      emit(MuteFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> unMuteFriend(String friendId) async {
    emit(UnMuteFriendLoading());
    try {
      await _friendFirebaseServices.unMuteFriend(friendId);
      emit(UnMuteFriendSuccess());
    } catch (e) {
      emit(UnMuteFriendError(Failure.fromException(e).message));
    }
  }

  void getMutedFriends() {
    emit(GetMutedFriendsLoading());
    try {
      _friendFirebaseServices.getAllMutedFriends().listen((muted) {
        mutedFriends = muted;

        emit(GetMutedFriendsSuccess());
      });
    } catch (e) {
      emit(GetMutedFriendsError(Failure.fromException(e).message));
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

  Future<void> deleteChat(String friendId, DateTime addedAt) async {
    emit(DeleteChatLoading());
    try {
      await _friendFirebaseServices.deleteChat(friendId, addedAt);
      emit(DeleteChatSuccess());
    } catch (e) {
      emit(DeleteChatError(Failure.fromException(e).message));
    }
  }

  Future<void> deleteMessageForMe(
    String friendId,
    String messageId,
    String currentUserId,
    String currentUserName,
    String friendName,
  ) async {
    emit(DeleteMessageForMeLoading());
    try {
      await _friendFirebaseServices.deleteMessageForMe(
        friendId,
        messageId,
        filteredMessages.length > 2
            ? filteredMessages.elementAt(filteredMessages.length - 2).message
            : '',
        filteredMessages.length > 2
            ? filteredMessages.elementAt(filteredMessages.length - 2).sender ==
                    currentUserId
                ? currentUserName
                : friendName
            : '',
        filteredMessages.length > 2
            ? filteredMessages.elementAt(filteredMessages.length - 2).sentAt
            : null,
      );
      emit(DeleteMessageForMeSuccess());
    } catch (e) {
      emit(DeleteMessageForMeError(Failure.fromException(e).message));
    }
  }

  Future<void> deleteMessageForAll(
    String friendId,
    String messageId,
    String currentUserId,
    String currentUserName,
    String friendName,
  ) async {
    emit(DeleteMessageForMeAndFriendLoading());
    try {
      await _friendFirebaseServices.deleteMessageForAll(
        friendId,
        messageId,
        filteredMessages.length > 2
            ? filteredMessages.elementAt(filteredMessages.length - 2).message
            : '',
        filteredMessages.length > 2
            ? filteredMessages.elementAt(filteredMessages.length - 2).sender ==
                    currentUserId
                ? currentUserName
                : friendName
            : '',
        filteredMessages.length > 2
            ? filteredMessages.elementAt(filteredMessages.length - 2).sentAt!
            : null,
      );
      emit(DeleteMessageForMeAndFriendSuccess());
    } catch (e) {
      emit(DeleteMessageForMeAndFriendError(Failure.fromException(e).message));
    }
  }
}
