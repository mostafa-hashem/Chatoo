import 'package:equatable/equatable.dart';

abstract class StoriesState extends Equatable {
  const StoriesState();

  @override
  List<Object?> get props => [];
}

class StoriesInitial extends StoriesState {}

class UploadStoryLoading extends StoriesState {}

class UploadStorySuccess extends StoriesState {}

class UploadStoryError extends StoriesState {
  final String message;

  const UploadStoryError(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteStoryLoading extends StoriesState {}

class DeleteStorySuccess extends StoriesState {}

class DeleteStoryError extends StoriesState {
  final String message;

  const DeleteStoryError(this.message);

  @override
  List<Object> get props => [message];
}
