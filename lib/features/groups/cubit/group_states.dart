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
