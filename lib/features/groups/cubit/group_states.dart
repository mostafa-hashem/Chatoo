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

class GetAllGroupsLoading extends GroupStates {}

class GetAllGroupsSuccess extends GroupStates {}

class GetAllGroupsError extends GroupStates {
  final String message;

  GetAllGroupsError(this.message);
}

class GetAllGroupMessagesLoading extends GroupStates {}

class GetAllGroupMessagesSuccess extends GroupStates {}

class GetAllGroupMessagesError extends GroupStates {
  final String message;

  GetAllGroupMessagesError(this.message);
}

class SendMessageLoading extends GroupStates {}

class SendMessageSuccess extends GroupStates {}

class SendMessageError extends GroupStates {
  final String message;

  SendMessageError(this.message);
}

class SearchOnGroupLoading extends GroupStates {}

class SearchOnGroupSuccess extends GroupStates {}

class SearchOnGroupError extends GroupStates {
  final String message;

  SearchOnGroupError(this.message);
}

class CheckUserInGroupLoading extends GroupStates {}

class CheckUserInGroupSuccess extends GroupStates {}

class CheckUserInGroupError extends GroupStates {
  final String message;

  CheckUserInGroupError(this.message);
}

class JoinGroupLoading extends GroupStates {}

class JoinGroupSuccess extends GroupStates {}

class JoinGroupError extends GroupStates {
  final String message;

  JoinGroupError(this.message);
}

class LeaveGroupLoading extends GroupStates {}

class LeaveGroupSuccess extends GroupStates {}

class LeaveGroupError extends GroupStates {
  final String message;

  LeaveGroupError(this.message);
}
