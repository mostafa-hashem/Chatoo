abstract class FriendStates {}

class FriendInit extends FriendStates {}

class RequestToAddFriendLoading extends FriendStates {}

class RequestToAddFriendSuccess extends FriendStates {}

class RequestToAddFriendError extends FriendStates {
  final String message;

  RequestToAddFriendError(this.message);
}

class CheckIsUserFriendLoading extends FriendStates {}

class CheckIsUserFriendSuccess extends FriendStates {}

class CheckIsUserFriendError extends FriendStates {
  final String message;

  CheckIsUserFriendError(this.message);
}

class GetAllUsersLoading extends FriendStates {}

class GetAllUsersSuccess extends FriendStates {}

class GetAllUsersError extends FriendStates {
  final String message;

  GetAllUsersError(this.message);
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

class SearchOnFriendLoading extends FriendStates {}

class SearchOnFriendSuccess extends FriendStates {}

class SearchOnFriendError extends FriendStates {
  final String message;

  SearchOnFriendError(this.message);
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

class GetRecentMessageDataLoading extends FriendStates {}

class GetRecentMessageDataSuccess extends FriendStates {}

class GetRecentMessageDataError extends FriendStates {
  final String message;

  GetRecentMessageDataError(this.message);
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
