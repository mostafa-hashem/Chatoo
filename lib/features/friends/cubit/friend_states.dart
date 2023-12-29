abstract class FriendStates {}

class FriendInit extends FriendStates {}

class AddFriendLoading extends FriendStates {}

class AddFriendSuccess extends FriendStates {}

class AddFriendError extends FriendStates {
  final String message;

  AddFriendError(this.message);
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

class SearchOnFriendLoading extends FriendStates {}

class SearchOnFriendSuccess extends FriendStates {}

class SearchOnFriendError extends FriendStates {
  final String message;

  SearchOnFriendError(this.message);
}

class SendMessageLoading extends FriendStates {}

class SendMessageSuccess extends FriendStates {}

class SendMessageError extends FriendStates {
  final String message;

  SendMessageError(this.message);
}
 class GetAllFriendMessagesLoading extends FriendStates {}

class GetAllFriendMessagesSuccess extends FriendStates {}

class GetAllFriendMessagesError extends FriendStates {
  final String message;

  GetAllFriendMessagesError(this.message);
}
