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
  List<Group> allGroups = [];
  List<Group> searchedGroups = [];
  List<Group> filteredGroups = [];
  List<GroupMessage> allMessages = [];
  List<GroupMessage> filteredMessages = [];
  bool isUserMember = false;
  ScrollController scrollController = ScrollController();

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
      });
      emit(GetAllGroupsSuccess());
    } catch (e) {
      emit(GetAllGroupsError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllGroupMessages(String groupId) async {
    emit(GetAllGroupMessagesLoading());
    try {
      _groupFirebaseServices.getAllGroupMessages(groupId).listen((messages) {
        filteredMessages =
            messages.where((message) => message.groupId == groupId).toList();
        filteredMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
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

  Future<void> sendMessageToGroup(
    Group group,
    User sender,
    String message,
  ) async {
    emit(SendMessageToGroupLoading());
    try {
      await _groupFirebaseServices.sendMessageToGroup(group, message, sender);
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
              (group) => group.groupName.contains(groupName),
            )
            .toList();
      });
      emit(SearchOnGroupSuccess());
    } catch (e) {
      emit(SearchOnGroupError(Failure.fromException(e).message));
    }
  }

  Future<bool> checkUserInGroup(String groupId, String userId) async {
    try {
      final isMember =
          await _groupFirebaseServices.isUserInGroup(groupId, userId).first;
      isUserMember = isMember;
      return isMember;
    } catch (e) {
      throw Failure.fromException(e).message;
    }
  }

  Future<void> joinGroup(Group group, User user) async {
    emit(JoinGroupLoading());
    try {
      await _groupFirebaseServices.joinGroup(group, user);
      emit(JoinGroupSuccess());
    } catch (e) {
      emit(JoinGroupError(Failure.fromException(e).message));
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

  Future<void> deleteMessageForeAll(String groupId, String messageId) async {
    emit(DeleteMessageForAllLoading());
    try {
      await _groupFirebaseServices.deleteMessageForeAll(groupId, messageId);
      emit(DeleteMessageForAllSuccess());
    } catch (e) {
      emit(DeleteMessageForAllError(Failure.fromException(e).message));
    }
  }
}
