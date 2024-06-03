
abstract class StoriesState {}

class StoriesInitial extends StoriesState {}

class UploadStoryLoading extends StoriesState {}

class UploadStorySuccess extends StoriesState {}

class UploadStoryError extends StoriesState {
  final String message;

  UploadStoryError(this.message);
}

class DeleteStoryLoading extends StoriesState {}

class DeleteStorySuccess extends StoriesState {}

class DeleteStoryError extends StoriesState {
  final String message;

  DeleteStoryError(this.message);
}

class UpdateStorySeenLoading extends StoriesState {}

class UpdateStorySeenSuccess extends StoriesState {}

class UpdateStorySeenError extends StoriesState {
  final String message;

  UpdateStorySeenError(this.message);
}
class GetUserByIdLoading extends StoriesState {}

class GetUserByIdSuccess extends StoriesState {}

class GetUserByIdError extends StoriesState {
  final String message;

  GetUserByIdError(this.message);
}
