abstract class GroupStates {}

class GroupInit extends GroupStates {}

class CreateGroupLoading extends GroupStates {}

class CreateGroupSuccess extends GroupStates {}

class CreateGroupError extends GroupStates {
  final String message;

  CreateGroupError(this.message);
}

class UploadGroupImageToFireStorageLoading extends GroupStates {}

class UploadGroupImageToFireStorageSuccess extends GroupStates {}

class UploadGroupImageToFireStorageError extends GroupStates {
  final String message;

  UploadGroupImageToFireStorageError(this.message);
}

class UploadImageAndUpdateGroupIconLoading extends GroupStates {}

class UploadImageAndUpdateGroupIconSuccess extends GroupStates {}

class UploadImageAndUpdateGroupIconError extends GroupStates {
  final String message;

  UploadImageAndUpdateGroupIconError(this.message);
}

class GetAllGroupsLoading extends GroupStates {}

class GetAllGroupsSuccess extends GroupStates {}

class GetAllGroupsError extends GroupStates {
  final String message;

  GetAllGroupsError(this.message);
}

class GetAdminNameLoading extends GroupStates {}

class GetAdminNameSuccess extends GroupStates {}

class GetAdminNameError extends GroupStates {
  final String message;

  GetAdminNameError(this.message);
}

class GetAllGroupMessagesLoading extends GroupStates {}

class GetAllGroupMessagesSuccess extends GroupStates {}

class GetAllGroupMessagesError extends GroupStates {
  final String message;

  GetAllGroupMessagesError(this.message);
}

class GetAllGroupMembersLoading extends GroupStates {}

class GetAllGroupMembersSuccess extends GroupStates {}

class GetAllGroupMembersError extends GroupStates {
  final String message;

  GetAllGroupMembersError(this.message);
}

class GetAllGroupRequestsLoading extends GroupStates {}

class GetAllGroupRequestsSuccess extends GroupStates {}

class GetAllGroupRequestsError extends GroupStates {
  final String message;

  GetAllGroupRequestsError(this.message);
}

class GetUserDataLoading extends GroupStates {}

class GetUserDataSuccess extends GroupStates {}

class GetUserDataError extends GroupStates {
  final String message;

  GetUserDataError(this.message);
}

class SendMessageToGroupLoading extends GroupStates {}

class SendMessageToGroupSuccess extends GroupStates {}

class SendMessageToGroupError extends GroupStates {
  final String message;

  SendMessageToGroupError(this.message);
}

class SearchOnGroupLoading extends GroupStates {}

class SearchOnGroupSuccess extends GroupStates {}

class SearchOnGroupError extends GroupStates {
  final String message;

  SearchOnGroupError(this.message);
}

class CheckUserInGroupLoading extends GroupStates {}

class RequestToJoinGroupLoading extends GroupStates {}

class RequestToJoinGroupSuccess extends GroupStates {}

class RequestToJoinGroupError extends GroupStates {
  final String message;

  RequestToJoinGroupError(this.message);
}

class ApproveToJoinGroupLoading extends GroupStates {}

class ApproveToJoinGroupSuccess extends GroupStates {}

class ApproveToJoinGroupError extends GroupStates {
  final String message;

  ApproveToJoinGroupError(this.message);
}

class DeclineToJoinGroupLoading extends GroupStates {}

class DeclineToJoinGroupSuccess extends GroupStates {}

class DeclineToJoinGroupError extends GroupStates {
  final String message;

  DeclineToJoinGroupError(this.message);
}

class LeaveGroupLoading extends GroupStates {}

class LeaveGroupSuccess extends GroupStates {}

class LeaveGroupError extends GroupStates {
  final String message;

  LeaveGroupError(this.message);
}

class KickUserFromGroupLoading extends GroupStates {}

class KickUserFromGroupSuccess extends GroupStates {}

class KickUserFromGroupError extends GroupStates {
  final String message;

  KickUserFromGroupError(this.message);
}

class DeleteMessageForAllLoading extends GroupStates {}

class DeleteMessageForAllSuccess extends GroupStates {}

class DeleteMessageForAllError extends GroupStates {
  final String message;

  DeleteMessageForAllError(this.message);
}
