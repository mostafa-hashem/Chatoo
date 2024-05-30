part of 'stories_cubit.dart';

abstract class StoriesState {}

class StoriesInitial extends StoriesState {}

class UploadStoryLoading extends StoriesState {}

class UploadStorySuccess extends StoriesState {}

class UploadStoryError extends StoriesState {
  String message;

  UploadStoryError(this.message);
}
