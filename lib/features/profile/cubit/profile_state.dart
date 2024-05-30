import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class GetUserSuccess extends ProfileState {}

class GetUserError extends ProfileState {
  final String message;

  GetUserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateUserLoading extends ProfileState {}

class UpdateUserSuccess extends ProfileState {}

class UpdateUserError extends ProfileState {
  final String message;

  UpdateUserError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateUserBioLoading extends ProfileState {}

class UpdateUserBioSuccess extends ProfileState {}

class UpdateUserBioError extends ProfileState {
  final String message;

  UpdateUserBioError(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadProfileImageLoading extends ProfileState {}

class UploadProfileImageSuccess extends ProfileState {}

class UploadProfileImageError extends ProfileState {
  final String message;

  UploadProfileImageError(this.message);

  @override
  List<Object?> get props => [message];
}

class GetUserStoriesLoading extends ProfileState {}

class GetUserStoriesSuccess extends ProfileState {}

class GetUserStoriesError extends ProfileState {
  final String message;

  GetUserStoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
