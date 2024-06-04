
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class GetUserSuccess extends ProfileState {}

class GetUserError extends ProfileState {
  final String message;

  GetUserError(this.message);
}

class UpdateUserLoading extends ProfileState {}

class UpdateUserSuccess extends ProfileState {}

class UpdateUserError extends ProfileState {
  final String message;

  UpdateUserError(this.message);
}

class UpdateUserBioLoading extends ProfileState {}

class UpdateUserBioSuccess extends ProfileState {}

class UpdateUserBioError extends ProfileState {
  final String message;

  UpdateUserBioError(this.message);
}

class UploadProfileImageLoading extends ProfileState {}

class UploadProfileImageSuccess extends ProfileState {}

class UploadProfileImageError extends ProfileState {
  final String message;

  UploadProfileImageError(this.message);
}

class DeleteProfileImageLoading extends ProfileState {}

class DeleteProfileImageSuccess extends ProfileState {}

class DeleteProfileImageError extends ProfileState {
  final String message;

  DeleteProfileImageError(this.message);
}

class GetUserStoriesLoading extends ProfileState {}

class GetUserStoriesSuccess extends ProfileState {}

class GetUserStoriesError extends ProfileState {
  final String message;

  GetUserStoriesError(this.message);
}
