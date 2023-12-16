abstract class FriendStates {}

class FriendInit extends FriendStates {}

class AddFriendLoading extends FriendStates {}

class AddFriendSuccess extends FriendStates {}

class AddFriendError extends FriendStates {
  final String message;

  AddFriendError(this.message);
}

class GetAllFriendsLoading extends FriendStates {}

class GetAllFriendsSuccess extends FriendStates {}

class GetAllFriendsError extends FriendStates {
  final String message;

  GetAllFriendsError(this.message);
}
