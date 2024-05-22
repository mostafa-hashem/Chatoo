abstract class FriendStates {}

class FriendInit extends FriendStates {}

class RequestToAddFriendLoading extends FriendStates {}

class RequestToAddFriendSuccess extends FriendStates {}

class RequestToAddFriendError extends FriendStates {
  final String message;

  RequestToAddFriendError(this.message);
}

class GetAllUserFriendsLoading extends FriendStates {}

class GetAllUserFriendsSuccess extends FriendStates {}

class GetAllUserFriendsError extends FriendStates {
  final String message;

  GetAllUserFriendsError(this.message);
}

class GetAllUserRequestsLoading extends FriendStates {}

class GetAllUserRequestsSuccess extends FriendStates {}

class GetAllUserRequestsError extends FriendStates {
  final String message;

  GetAllUserRequestsError(this.message);
}

class ApproveToAddFriendLoading extends FriendStates {}

class ApproveToAddFriendSuccess extends FriendStates {}

class ApproveToAddFriendError extends FriendStates {
  final String message;

  ApproveToAddFriendError(this.message);
}

class DeclineToAddFriendLoading extends FriendStates {}

class DeclineToAddFriendSuccess extends FriendStates {}

class DeclineToAddFriendError extends FriendStates {
  final String message;

  DeclineToAddFriendError(this.message);
}

class GetFriendDataLoading extends FriendStates {}

class GetFriendDataSuccess extends FriendStates {}

class GetFriendDataError extends FriendStates {
  final String message;

  GetFriendDataError(this.message);
}

class SearchOnFriendLoading extends FriendStates {}

class SearchOnFriendSuccess extends FriendStates {}

class SearchOnFriendError extends FriendStates {
  final String message;

  SearchOnFriendError(this.message);
}

class SendMediaToFriendLoading extends FriendStates {}

class SendMediaToFriendSuccess extends FriendStates {}

class SendMediaToFriendError extends FriendStates {
  final String message;

  SendMediaToFriendError(this.message);
}

class SendMessageToFriendLoading extends FriendStates {}

class SendMessageToFriendSuccess extends FriendStates {}

class SendMessageToFriendError extends FriendStates {
  final String message;

  SendMessageToFriendError(this.message);
}

class GetAllFriendMessagesLoading extends FriendStates {}

class GetAllFriendMessagesSuccess extends FriendStates {}

class GetAllFriendMessagesError extends FriendStates {
  final String message;

  GetAllFriendMessagesError(this.message);
}

class GetCombinedFriendsLoading extends FriendStates {}

class GetCombinedFriendsSuccess extends FriendStates {}

class GetCombinedFriendsError extends FriendStates {
  final String message;

  GetCombinedFriendsError(this.message);
}

class UpdateTypingStatus extends FriendStates {
  bool isTyping;
  UpdateTypingStatus(this.isTyping);
}
class UpdateTypingStatusLoading extends FriendStates {}

class UpdateTypingStatusSuccess extends FriendStates {}

class UpdateTypingStatusError extends FriendStates {
  final String message;

  UpdateTypingStatusError(this.message);
}

class MuteFriendLoading extends FriendStates {}

class MuteFriendSuccess extends FriendStates {}

class MuteFriendError extends FriendStates {
  final String message;

  MuteFriendError(this.message);
}

class UnMuteFriendLoading extends FriendStates {}

class UnMuteFriendSuccess extends FriendStates {}

class UnMuteFriendError extends FriendStates {
  final String message;

  UnMuteFriendError(this.message);
}

class RemoveFriendRequestLoading extends FriendStates {}

class RemoveFriendRequestSuccess extends FriendStates {}

class RemoveFriendRequestError extends FriendStates {
  final String message;

  RemoveFriendRequestError(this.message);
}

class RemoveFriendLoading extends FriendStates {}

class RemoveFriendSuccess extends FriendStates {}

class RemoveFriendError extends FriendStates {
  final String message;

  RemoveFriendError(this.message);
}

class DeleteChatLoading extends FriendStates {}

class DeleteChatSuccess extends FriendStates {}

class DeleteChatError extends FriendStates {
  final String message;

  DeleteChatError(this.message);
}

class DeleteMessageForMeLoading extends FriendStates {}

class DeleteMessageForMeSuccess extends FriendStates {}

class DeleteMessageForMeError extends FriendStates {
  final String message;

  DeleteMessageForMeError(this.message);
}

class DeleteMessageForMeAndFriendLoading extends FriendStates {}

class DeleteMessageForMeAndFriendSuccess extends FriendStates {}

class DeleteMessageForMeAndFriendError extends FriendStates {
  final String message;

  DeleteMessageForMeAndFriendError(this.message);
}
