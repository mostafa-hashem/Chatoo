import 'package:equatable/equatable.dart';

abstract class FriendStates extends Equatable {
  const FriendStates();

  @override
  List<Object?> get props => [];
}

class FriendInit extends FriendStates {}

class RequestToAddFriendLoading extends FriendStates {}

class RequestToAddFriendSuccess extends FriendStates {}

class RequestToAddFriendError extends FriendStates {
  final String message;

  const RequestToAddFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetAllUserFriendsLoading extends FriendStates {}

class GetAllUserFriendsSuccess extends FriendStates {}

class GetAllUserFriendsError extends FriendStates {
  final String message;

  const GetAllUserFriendsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetAllUserRequestsLoading extends FriendStates {}

class GetAllUserRequestsSuccess extends FriendStates {}

class GetAllUserRequestsError extends FriendStates {
  final String message;

  const GetAllUserRequestsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ApproveToAddFriendLoading extends FriendStates {}

class ApproveToAddFriendSuccess extends FriendStates {}

class ApproveToAddFriendError extends FriendStates {
  final String message;

  const ApproveToAddFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeclineToAddFriendLoading extends FriendStates {}

class DeclineToAddFriendSuccess extends FriendStates {}

class DeclineToAddFriendError extends FriendStates {
  final String message;

  const DeclineToAddFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetFriendDataLoading extends FriendStates {}

class GetFriendDataSuccess extends FriendStates {}

class GetFriendDataError extends FriendStates {
  final String message;

  const GetFriendDataError(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchOnFriendLoading extends FriendStates {}

class SearchOnFriendSuccess extends FriendStates {}

class SearchOnFriendError extends FriendStates {
  final String message;

  const SearchOnFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class SendMediaToFriendLoading extends FriendStates {}

class SendMediaToFriendSuccess extends FriendStates {}

class SendMediaToFriendError extends FriendStates {
  final String message;

  const SendMediaToFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class SendMessageToFriendLoading extends FriendStates {}

class SendMessageToFriendSuccess extends FriendStates {}

class SendMessageToFriendError extends FriendStates {
  final String message;

  const SendMessageToFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetAllFriendMessagesLoading extends FriendStates {}

class GetAllFriendMessagesSuccess extends FriendStates {}

class GetAllFriendMessagesError extends FriendStates {
  final String message;

  const GetAllFriendMessagesError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetCombinedFriendsLoading extends FriendStates {}

class GetCombinedFriendsSuccess extends FriendStates {}

class GetCombinedFriendsError extends FriendStates {
  final String message;

  const GetCombinedFriendsError(this.message);

  @override
  List<Object?> get props => [message];
}

class MarkMessagesAsReadLoading extends FriendStates {}

class MarkMessagesAsReadSuccess extends FriendStates {}

class MarkMessagesAsReadError extends FriendStates {
  final String message;

  const MarkMessagesAsReadError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateTypingStatus extends FriendStates {
  final bool isTyping;

  const UpdateTypingStatus(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

class UpdateRecordingStatus extends FriendStates {
  final bool isRecording;

  const UpdateRecordingStatus(this.isRecording);

  @override
  List<Object?> get props => [isRecording];
}

class UpdateTypingStatusLoading extends FriendStates {}

class UpdateTypingStatusSuccess extends FriendStates {}

class UpdateTypingStatusError extends FriendStates {
  final String message;

  const UpdateTypingStatusError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateRecordingStatusLoading extends FriendStates {}

class UpdateRecordingStatusSuccess extends FriendStates {}

class UpdateRecordingStatusError extends FriendStates {
  final String message;

  const UpdateRecordingStatusError(this.message);

  @override
  List<Object?> get props => [message];
}

class MuteFriendLoading extends FriendStates {}

class MuteFriendSuccess extends FriendStates {}

class MuteFriendError extends FriendStates {
  final String message;

  const MuteFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class UnMuteFriendLoading extends FriendStates {}

class UnMuteFriendSuccess extends FriendStates {}

class UnMuteFriendError extends FriendStates {
  final String message;

  const UnMuteFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetMutedFriendsLoading extends FriendStates {}

class GetMutedFriendsSuccess extends FriendStates {}

class GetMutedFriendsError extends FriendStates {
  final String message;

  const GetMutedFriendsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RemoveFriendRequestLoading extends FriendStates {}

class RemoveFriendRequestSuccess extends FriendStates {}

class RemoveFriendRequestError extends FriendStates {
  final String message;

  const RemoveFriendRequestError(this.message);

  @override
  List<Object?> get props => [message];
}

class RemoveFriendLoading extends FriendStates {}

class RemoveFriendSuccess extends FriendStates {}

class RemoveFriendError extends FriendStates {
  final String message;

  const RemoveFriendError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteChatLoading extends FriendStates {}

class DeleteChatSuccess extends FriendStates {}

class DeleteChatError extends FriendStates {
  final String message;

  const DeleteChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteMessageForMeLoading extends FriendStates {}

class DeleteMessageForMeSuccess extends FriendStates {}

class DeleteMessageForMeError extends FriendStates {
  final String message;

  const DeleteMessageForMeError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeleteMessageForMeAndFriendLoading extends FriendStates {}

class DeleteMessageForMeAndFriendSuccess extends FriendStates {}

class DeleteMessageForMeAndFriendError extends FriendStates {
  final String message;

  const DeleteMessageForMeAndFriendError(this.message);

  @override
  List<Object?> get props => [message];
}
