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
