import 'dart:async';
import 'dart:io';

import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/groups/data/services/group_firebase_services.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupCubit extends Cubit<GroupStates> {
  GroupCubit() : super(GroupInit());

  static GroupCubit get(BuildContext context) => BlocProvider.of(context);
  final _groupFirebaseServices = GroupFirebaseServices();
  String groupIcon = "";
  String adminName = "";
  User? userData;
  List<Group> allUserGroups = [];
  List<User> allGroupMembers = [];
  List<User> allGroupRequests = [];
  List<Group> searchedGroups = [];
  List<Group> filteredGroups = [];
  List<GroupMessage> filteredMessages = [];
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();

  Future<void> createGroup(Group group, User user) async {
    emit(CreateGroupLoading());
    try {
      await _groupFirebaseServices.createGroup(group, user);
      emit(CreateGroupSuccess());
    } catch (e) {
      emit(CreateGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> uploadGroupImageToFireStorage(File imageFiles) async {
    emit(UploadGroupImageToFireStorageLoading());
    try {
      groupIcon = await _groupFirebaseServices.uploadImage(imageFiles);
      emit(UploadGroupImageToFireStorageSuccess());
    } catch (e) {
      emit(
        UploadGroupImageToFireStorageError(Failure.fromException(e).message),
      );
    }
  }

  Future<String?> uploadImageAndUpdateGroupIcon(
    File imageFiles,
    String groupId,
  ) async {
    emit(UploadImageAndUpdateGroupIconLoading());
    try {
      await _groupFirebaseServices.uploadImageAndUpdateGroupIcon(
        imageFiles,
        groupId,
      );
      emit(UploadImageAndUpdateGroupIconSuccess());
      return _groupFirebaseServices.uploadImageAndUpdateGroupIcon(
        imageFiles,
        groupId,
      );
    } catch (e) {
      emit(
        UploadImageAndUpdateGroupIconError(Failure.fromException(e).message),
      );
    }
    return null;
  }

  Future<void> getAllUserGroups() async {
    emit(GetAllGroupsLoading());
    try {
      _groupFirebaseServices.getAllUserGroups().listen((groups) {
        allUserGroups = groups;
        allUserGroups.sort((a, b) {
          if (a.recentMessageSentAt != null || b.recentMessageSentAt != null) {
            return b.recentMessageSentAt!.compareTo(a.recentMessageSentAt!);
          }
          return b.createdAt!.compareTo(a.createdAt!);
        });

        emit(GetAllGroupsSuccess());
      });
    } catch (e) {
      emit(
        GetAllGroupsError(
          Failure.fromException(e).message,
        ),
      );
    }
  }

  Future<void> getAllGroupMessages(String groupId) async {
    emit(GetAllGroupMessagesLoading());
    try {
      _groupFirebaseServices.getAllGroupMessages(groupId).listen((messages) {
        filteredMessages = messages;
        filteredMessages.sort((a, b) => a.sentAt!.compareTo(b.sentAt!));
        emit(GetAllGroupMessagesSuccess());
      });
    } catch (e) {
      emit(GetAllGroupMessagesError(Failure.fromException(e).message));
    }
  }

  Future<void> getAdminName(String adminId) async {
    emit(GetAdminNameLoading());
    try {
      adminName = await _groupFirebaseServices.getAdminName(adminId);
      emit(GetAdminNameSuccess());
    } catch (e) {
      emit(GetAdminNameError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllGroupMembers(String groupId) async {
    emit(GetAllGroupMembersLoading());
    try {
      allGroupMembers =
          await _groupFirebaseServices.getAllGroupMembers(groupId);
      emit(GetAllGroupMembersSuccess());
    } catch (e) {
      emit(GetAllGroupMembersError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllGroupMRequests(String groupId) async {
    emit(GetAllGroupRequestsLoading());
    try {
      _groupFirebaseServices.getAllGroupRequests(groupId).listen((requests) {
        allGroupRequests = requests;
        emit(GetAllGroupRequestsSuccess());
      });
    } catch (e) {
      emit(GetAllGroupRequestsError(Failure.fromException(e).message));
    }
  }

  Future<void> sendMessageToGroup({
    required Group group,
    User? sender,
    required String message,
    required bool leave,
    required bool joined,
    required bool requested,
    required bool declined,
  }) async {
    emit(SendMessageToGroupLoading());
    try {
      await _groupFirebaseServices.sendMessageToGroup(
        group,
        message,
        sender!,
        leave,
        joined,
        requested,
        declined,
      );
      emit(SendMessageToGroupSuccess());
    } catch (e) {
      emit(SendMessageToGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> getUserData(
    String userId,
  ) async {
    emit(GetUserDataLoading());
    try {
      userData = await _groupFirebaseServices.getUserData(userId);
      emit(GetUserDataSuccess());
    } catch (e) {
      emit(GetUserDataError(Failure.fromException(e).message));
    }
  }

  Future<void> searchOnGroup(String groupName) async {
    emit(SearchOnGroupLoading());
    try {
      _groupFirebaseServices.getGroupsForSearch().listen((search) {
        searchedGroups = search
            .where(
              (group) => group.groupName!.contains(groupName),
            )
            .toList();
      });
      emit(SearchOnGroupSuccess());
    } catch (e) {
      emit(SearchOnGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> requestToJoinGroup(Group group) async {
    emit(RequestToJoinGroupLoading());
    try {
      await _groupFirebaseServices.requestToJoinGroup(group);
      emit(RequestToJoinGroupSuccess());
    } catch (e) {
      emit(RequestToJoinGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> approveToJoinGroup(String groupId, String requesterId) async {
    emit(ApproveToJoinGroupLoading());
    try {
      await _groupFirebaseServices.approveToJoinGroup(groupId, requesterId);
      emit(ApproveToJoinGroupSuccess());
    } catch (e) {
      emit(ApproveToJoinGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> declineToJoinGroup(String groupId, String requesterId) async {
    emit(DeclineToJoinGroupLoading());
    try {
      await _groupFirebaseServices.declineToJoinGroup(groupId, requesterId);
      emit(DeclineToJoinGroupSuccess());
    } catch (e) {
      emit(DeclineToJoinGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> leaveGroup(Group group, User user) async {
    emit(LeaveGroupLoading());
    try {
      await _groupFirebaseServices.leaveGroup(group, user);
      emit(LeaveGroupSuccess());
    } catch (e) {
      emit(LeaveGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> kickUserFromGroup(String groupId, String userId) async {
    emit(KickUserFromGroupLoading());
    try {
      await _groupFirebaseServices.kickUserFromGroup(groupId, userId);
      emit(KickUserFromGroupSuccess());
    } catch (e) {
      emit(KickUserFromGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> deleteMessageForeAll(
    String groupId,
    String messageId,
    String senderName,
  ) async {
    emit(DeleteMessageForAllLoading());
    try {
      await _groupFirebaseServices.deleteMessageForeAll(
        groupId,
        messageId,
        senderName,
        filteredMessages.elementAt(filteredMessages.length - 2).message!,
        filteredMessages
            .elementAt(filteredMessages.length - 2)
            .sender!
            .userName!,
      );
      emit(DeleteMessageForAllSuccess());
    } catch (e) {
      emit(DeleteMessageForAllError(Failure.fromException(e).message));
    }
  }
}
