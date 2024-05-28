import 'dart:async';
import 'dart:io';

import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/groups/data/services/group_firebase_services.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupCubit extends Cubit<GroupStates> {
  GroupCubit() : super(GroupInit());

  static GroupCubit get(BuildContext context) => BlocProvider.of(context);
  final _groupFirebaseServices = GroupFirebaseServices();
  String groupIcon = "";
  User? userData;
  List<Group?> allUserGroups = [];
  List<String> mutedGroups = [];
  List<User?> allGroupMembers = [];
  List<User> allGroupRequests = [];
  List<Group> searchedGroups = [];
  List<GroupMessage> filteredMessages = [];
  ScrollController scrollController = ScrollController();
  List<String> mediaUrls = [];
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

  Future<void> makeAsAdmin(String groupId, String memberId) async {
    emit(MakeAsAdminLoading());
    try {
      await _groupFirebaseServices.makeAsAdmin(groupId, memberId);
      emit(MakeAsAdminSuccess());
    } catch (e) {
      emit(MakeAsAdminError(Failure.fromException(e).message));
    }
  }

  Future<void> removeFromAdmins(String groupId, String memberId) async {
    emit(RemoveFromAdminsLoading());
    try {
      await _groupFirebaseServices.removeFromAdmins(groupId, memberId);
      emit(RemoveFromAdminsSuccess());
    } catch (e) {
      emit(RemoveFromAdminsError(Failure.fromException(e).message));
    }
  }

  Future<void> changeGroupName(String groupId, String newGroupName) async {
    emit(ChangeGroupNameLoading());
    try {
      await _groupFirebaseServices.changeGroupName(groupId, newGroupName);
      emit(ChangeGroupNameSuccess());
    } catch (e) {
      emit(ChangeGroupNameError(Failure.fromException(e).message));
    }
  }

  Future<void> uploadGroupImageToFireStorage(File imageFiles) async {
    emit(UploadGroupImageToFireStorageLoading());
    try {
      groupIcon = await _groupFirebaseServices.uploadImage(imageFiles);
      emit(UploadGroupImageToFireStorageSuccess());
    } catch (e) {
      emit(
        UploadGroupImageToFireStorageError(
          Failure.fromException(e).message,
        ),
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
          final recentMessageA = a?.recentMessageSentAt;
          final recentMessageB = b?.recentMessageSentAt;

          if (recentMessageA != null && recentMessageB != null) {
            return recentMessageB.compareTo(recentMessageA);
          } else {
            final createdAtA = a?.createdAt;
            final createdAtB = b?.createdAt;

            if (createdAtA != null && createdAtB != null) {
              return createdAtB.compareTo(createdAtA);
            } else if (createdAtA == null && createdAtB == null) {
              return 0;
            } else if (createdAtA == null) {
              return 1;
            } else {
              return -1;
            }
          }
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
        filteredMessages =
            messages.where((message) => message.sentAt != null).toList();

        if (filteredMessages.isNotEmpty) {
          filteredMessages.sort((a, b) => a.sentAt!.compareTo(b.sentAt!));
        }
        emit(GetAllGroupMessagesSuccess());
      });
    } catch (e) {
      emit(GetAllGroupMessagesError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllGroupMembers(String groupId) async {
    emit(GetAllGroupMembersLoading());
    try {
      _groupFirebaseServices.getAllGroupMembers(groupId).listen((members) {
        allGroupMembers = members;
        emit(GetAllGroupMembersSuccess());
      });
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
    List<String>? mediaUrls,
    required MessageType type,
    required bool isAction,
  }) async {
    emit(SendMessageToGroupLoading());
    try {
      await _groupFirebaseServices.sendMessageToGroup(
        group,
        message,
        sender!,
        mediaUrls ?? [],
        type,
        isAction,
      );
      emit(SendMessageToGroupSuccess());
    } catch (e) {
      emit(SendMessageToGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> markMessagesAsRead({
    required String groupId,
  }) async {
    emit(MakeGroupMessageAsReadLoading());
    try {
      await _groupFirebaseServices.markMessagesAsRead(
        groupId,
      );
      emit(MakeGroupMessageAsReadSuccess());
    } catch (e) {
      emit(MakeGroupMessageAsReadError(Failure.fromException(e).message));
    }
  }

  Future<void> uploadMediaToGroup(
    String mediaPath,
    File mediaFile,
    String groupId,
    Future<String> Function(File imageFile) getFileName,
  ) async {
    try {
      if (mediaPath == FirebasePath.images) {
        emit(UploadImageToGroupLoading());
      } else if (mediaPath == FirebasePath.videos) {
        emit(UploadVideoToGroupLoading());
      } else if (mediaPath == FirebasePath.records) {
        emit(UploadAudioToGroupLoading());
      }

      mediaUrls.clear();
      final String downloadUrl =
          await _groupFirebaseServices.uploadMediaToGroup(
        mediaPath,
        mediaFile,
        groupId,
        getFileName,
      );

      if (downloadUrl.isNotEmpty) {
        mediaUrls.add(downloadUrl);

        if (mediaPath == FirebasePath.images) {
          emit(UploadImageToGroupSuccess());
        } else if (mediaPath == FirebasePath.videos) {
          emit(UploadVideoToGroupSuccess());
        } else {
          emit(UploadAudioToGroupSuccess());
        }
      } else {
        throw Exception('Download URL is empty');
      }
    } catch (e) {
      final errorMessage = Failure.fromException(e).message;

      if (mediaPath == FirebasePath.images) {
        emit(UploadImageToGroupError(errorMessage));
      } else if (mediaPath == FirebasePath.videos) {
        emit(UploadVideoToGroupError(errorMessage));
      } else {
        emit(UploadAudioToGroupError(errorMessage));
      }
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
              (group) => group.groupName!
                  .toLowerCase()
                  .contains(groupName.toLowerCase()),
            )
            .toList();
        emit(SearchOnGroupSuccess());
      });
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

  Future<void> requestAddFriendToGroup(Group group, User friend) async {
    emit(RequestAddToGroupLoading());
    try {
      await _groupFirebaseServices.requestAddFriendToGroup(group, friend);
      emit(RequestAddToGroupSuccess());
    } catch (e) {
      emit(RequestAddToGroupError(Failure.fromException(e).message));
    }
  }

  // ********** while admin **********
  Future<void> addFriendToGroup(Group group, User friend) async {
    emit(AddToGroupLoading());
    try {
      await _groupFirebaseServices.addFriendToGroup(group, friend);
      emit(AddToGroupSuccess());
    } catch (e) {
      emit(AddToGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> cancelRequestToJoinGroup(String groupId) async {
    emit(CancelRequestToJoinGroupLoading());
    try {
      await _groupFirebaseServices.cancelRequestToJoinGroup(groupId);
      emit(CancelRequestToJoinGroupSuccess());
    } catch (e) {
      emit(CancelRequestToJoinGroupError(Failure.fromException(e).message));
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

  Future<void> muteGroup(String groupId) async {
    emit(MuteGroupLoading());
    try {
      await _groupFirebaseServices.muteGroup(groupId);
      emit(MuteGroupSuccess());
    } catch (e) {
      emit(MuteGroupError(Failure.fromException(e).message));
    }
  }

  Future<void> unMuteGroup(String groupId) async {
    emit(UnMuteGroupLoading());
    try {
      await _groupFirebaseServices.unMuteGroup(groupId);
      emit(UnMuteGroupSuccess());
    } catch (e) {
      emit(UnMuteGroupError(Failure.fromException(e).message));
    }
  }

  void getMutedGroups() {
    emit(GetMutedGroupsLoading());
    try {
      _groupFirebaseServices.getAllMutedGroups().listen((muted) {
        mutedGroups = muted;

        emit(GetMutedGroupsSuccess());
      });
    } catch (e) {
      emit(GetMutedGroupsError(Failure.fromException(e).message));
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
        filteredMessages.length > 2
            ? filteredMessages.elementAt(filteredMessages.length - 2).message!
            : '',
        filteredMessages.length > 2
            ? filteredMessages
                .elementAt(filteredMessages.length - 2)
                .sender!
                .userName!
            : '',
        filteredMessages.length > 2
            ? filteredMessages.elementAt(filteredMessages.length - 2).sentAt!
            : null,
        filteredMessages.length > 2
            ? filteredMessages
                .elementAt(filteredMessages.length - 2)
                .sender!
                .id!
            : '',
      );
      emit(DeleteMessageForAllSuccess());
    } catch (e) {
      emit(DeleteMessageForAllError(Failure.fromException(e).message));
    }
  }

  Future<void> deleteGroup(
    String groupId,
  ) async {
    emit(DeleteGroupLoading());
    try {
      await _groupFirebaseServices.deleteGroup(
        groupId,
      );
      emit(DeleteGroupSuccess());
    } catch (e) {
      emit(DeleteGroupError(Failure.fromException(e).message));
    }
  }
}
