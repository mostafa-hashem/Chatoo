import 'package:equatable/equatable.dart';

abstract class GroupStates extends Equatable {
  @override
  List<Object?> get props => [];
}

class GroupInit extends GroupStates {}

class CreateGroupLoading extends GroupStates {}

class CreateGroupSuccess extends GroupStates {}

class CreateGroupError extends GroupStates {
  final String message;

  CreateGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class MakeAsAdminLoading extends GroupStates {}

class MakeAsAdminSuccess extends GroupStates {}

class MakeAsAdminError extends GroupStates {
  final String message;

  MakeAsAdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class RemoveFromAdminsLoading extends GroupStates {}

class RemoveFromAdminsSuccess extends GroupStates {}

class RemoveFromAdminsError extends GroupStates {
  final String message;

  RemoveFromAdminsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChangeGroupNameLoading extends GroupStates {}

class ChangeGroupNameSuccess extends GroupStates {}

class ChangeGroupNameError extends GroupStates {
  final String message;

  ChangeGroupNameError(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadGroupImageToFireStorageLoading extends GroupStates {}

class UploadGroupImageToFireStorageSuccess extends GroupStates {}

class UploadGroupImageToFireStorageError extends GroupStates {
  final String message;

  UploadGroupImageToFireStorageError(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadImageAndUpdateGroupIconLoading extends GroupStates {}

class UploadImageAndUpdateGroupIconSuccess extends GroupStates {}

class UploadImageAndUpdateGroupIconError extends GroupStates {
  final String message;

  UploadImageAndUpdateGroupIconError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetAllGroupsLoading extends GroupStates {}

class GetAllGroupsSuccess extends GroupStates {}

class GetAllGroupsError extends GroupStates {
  final String message;

  GetAllGroupsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetAllGroupMessagesLoading extends GroupStates {}

class GetAllGroupMessagesSuccess extends GroupStates {}

class GetAllGroupMessagesError extends GroupStates {
  final String message;

  GetAllGroupMessagesError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetAllGroupMembersLoading extends GroupStates {}

class GetAllGroupMembersSuccess extends GroupStates {}

class GetAllGroupMembersError extends GroupStates {
  final String message;

  GetAllGroupMembersError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetAllGroupRequestsLoading extends GroupStates {}

class GetAllGroupRequestsSuccess extends GroupStates {}

class GetAllGroupRequestsError extends GroupStates {
  final String message;

  GetAllGroupRequestsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetUserDataLoading extends GroupStates {}

class GetUserDataSuccess extends GroupStates {}

class GetUserDataError extends GroupStates {
  final String message;

  GetUserDataError(this.message);

  @override
  List<Object?> get props => [message];
}

class SendMessageToGroupLoading extends GroupStates {}

class SendMessageToGroupSuccess extends GroupStates {}

class SendMessageToGroupError extends GroupStates {
  final String message;

  SendMessageToGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class MakeGroupMessageAsReadLoading extends GroupStates {}

class MakeGroupMessageAsReadSuccess extends GroupStates {}

class MakeGroupMessageAsReadError extends GroupStates {
  final String message;

  MakeGroupMessageAsReadError(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadImageToGroupLoading extends GroupStates {}

class UploadImageToGroupSuccess extends GroupStates {}

class UploadImageToGroupError extends GroupStates {
  final String message;

  UploadImageToGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadVideoToGroupLoading extends GroupStates {}

class UploadVideoToGroupSuccess extends GroupStates {}

class UploadVideoToGroupError extends GroupStates {
  final String message;

  UploadVideoToGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadAudioToGroupLoading extends GroupStates {}

class UploadAudioToGroupSuccess extends GroupStates {}

class UploadAudioToGroupError extends GroupStates {
  final String message;

  UploadAudioToGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchOnGroupLoading extends GroupStates {}

class SearchOnGroupSuccess extends GroupStates {}

class SearchOnGroupError extends GroupStates {
  final String message;

  SearchOnGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestToJoinGroupLoading extends GroupStates {}

class RequestToJoinGroupSuccess extends GroupStates {}

class RequestToJoinGroupError extends GroupStates {
  final String message;

  RequestToJoinGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestAddToGroupLoading extends GroupStates {}

class RequestAddToGroupSuccess extends GroupStates {}

class RequestAddToGroupError extends GroupStates {
  final String message;

  RequestAddToGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddToGroupLoading extends GroupStates {}

class AddToGroupSuccess extends GroupStates {}

class AddToGroupError extends GroupStates {
  final String message;

  AddToGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class CancelRequestToJoinGroupLoading extends GroupStates {}

class CancelRequestToJoinGroupSuccess extends GroupStates {}

class CancelRequestToJoinGroupError extends GroupStates {
  final String message;

  CancelRequestToJoinGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class ApproveToJoinGroupLoading extends GroupStates {}

class ApproveToJoinGroupSuccess extends GroupStates {}

class ApproveToJoinGroupError extends GroupStates {
  final String message;

  ApproveToJoinGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeclineToJoinGroupLoading extends GroupStates {}

class DeclineToJoinGroupSuccess extends GroupStates {}

class DeclineToJoinGroupError extends GroupStates {
  final String message;

  DeclineToJoinGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class LeaveGroupLoading extends GroupStates {}

class LeaveGroupSuccess extends GroupStates {}

class LeaveGroupError extends GroupStates {
  final String message;

  LeaveGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class KickUserFromGroupLoading extends GroupStates {}

class KickUserFromGroupSuccess extends GroupStates {}

class KickUserFromGroupError extends GroupStates {
  final String message;

  KickUserFromGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class MuteGroupLoading extends GroupStates {}

class MuteGroupSuccess extends GroupStates {}

class MuteGroupError extends GroupStates {
  final String message;

  MuteGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class UnMuteGroupLoading extends GroupStates {}

class UnMuteGroupSuccess extends GroupStates {}

class UnMuteGroupError extends GroupStates {
  final String message;

  UnMuteGroupError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetMutedGroupsLoading extends GroupStates {}

class GetMutedGroupsSuccess extends GroupStates {}

class GetMutedGroupsError extends GroupStates {
  final String message;

  GetMutedGroupsError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteMessageForAllLoading extends GroupStates {}

class DeleteMessageForAllSuccess extends GroupStates {}

class DeleteMessageForAllError extends GroupStates {
  final String message;

  DeleteMessageForAllError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteGroupLoading extends GroupStates {}

class DeleteGroupSuccess extends GroupStates {}

class DeleteGroupError extends GroupStates {
  final String message;

  DeleteGroupError(this.message);

  @override
  List<Object?> get props => [message];
}
