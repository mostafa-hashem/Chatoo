import 'dart:io';

import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/message_data.dart';
import 'package:chat_app/features/groups/data/services/group_firebase_services.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupCubit extends Cubit<GroupStates> {
  GroupCubit() : super(GroupInit());

  static GroupCubit get(BuildContext context) => BlocProvider.of(context);
  final _groupFirebaseServices = GroupFirebaseServices();
  List<Group> allUserGroups = [];
  List<Group> allGroups = [];
  List<Group> searchedGroups = [];
  List<Group> filteredGroups = [];
  List<Message> allMessages = [];
  List<Message> filteredMessages = [];
  bool isUserMember = false;

  Future<void> createGroup(Group group, String userName, User user) async {
    emit(CreateGroupLoading());
    try {
      await _groupFirebaseServices.createGroup(group, userName, user);
      emit(CreateGroupSuccess());
    } catch (e) {
      emit(CreateGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> uploadGroupImageToFireStorage(
    File imageFiles,
  ) async {
    emit(UploadGroupImageToFireStorageLoading());
    try {
      await _groupFirebaseServices.uploadImage(imageFiles);
      emit(UploadGroupImageToFireStorageSuccess());
    } catch (e) {
      emit(
        UploadGroupImageToFireStorageError(Failure.fromException(e).message),
      );
    }
  }

  Future<void> getAllUserGroups() async {
    emit(GetAllGroupsLoading());
    try {
      allUserGroups = await _groupFirebaseServices.getAllUserGroups();
      emit(GetAllGroupsSuccess());
    } catch (e) {
      emit(GetAllGroupsError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllGroupMessages(String groupId) async {
    emit(GetAllGroupMessagesLoading());
    try {
      allMessages = await _groupFirebaseServices.getAllGroupMessages(groupId);
      filteredMessages =
          allMessages.where((message) => message.groupId == groupId).toList();
      emit(GetAllGroupMessagesSuccess());
    } catch (e) {
      emit(GetAllGroupMessagesError(Failure.fromException(e).message));
    }
  }

  Future<void> sendMessageToGroup(Group group, User sender, String message) async {
    emit(SendMessageLoading());
    try {
      await _groupFirebaseServices.sendMessageToGroup(group, message, sender);
      emit(SendMessageSuccess());
    } catch (e) {
      emit(SendMessageError(Failure.fromException(e).message));
    }
  }

  Future<void> searchOnGroup(String groupName) async {
    emit(SearchOnGroupLoading());
    try {
      allGroups = await _groupFirebaseServices.getGroups();
      searchedGroups = allGroups
          .where(
            (group) =>
                group.groupId == groupName || group.groupName == groupName,
          )
          .toList();
      emit(SearchOnGroupSuccess());
    } catch (e) {
      emit(SearchOnGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> checkUserInGroup(String userId, String groupId) async {
    emit(CheckUserInGroupLoading());
    try {
      isUserMember =
          await _groupFirebaseServices.isUserInGroup(userId, groupId);

      if (isUserMember) {
        emit(CheckUserInGroupSuccess());
      } else {
        emit(CheckUserInGroupError("User is not a member of the group"));
      }
    } catch (e) {
      emit(CheckUserInGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> joinGroup(String userId, Group group, User user) async {
    emit(JoinGroupLoading());
    try {
      await _groupFirebaseServices.joinGroup(userId, group, user);
      emit(JoinGroupSuccess());
    } catch (e) {
      emit(JoinGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> leaveGroup(String userId, String groupId, User user) async {
    emit(LeaveGroupLoading());
    try {
      await _groupFirebaseServices.leaveGroup(userId, groupId, user);
      emit(LeaveGroupSuccess());
    } catch (e) {
      emit(LeaveGroupError(Failure.fromException(e).message));
    }
  }
}
