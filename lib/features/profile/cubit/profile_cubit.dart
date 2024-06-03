import 'dart:io';

import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/profile/data/services/profile_firebase_service.dart';
import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  static ProfileCubit get(BuildContext context) => BlocProvider.of(context);

  final profileFirebaseService = ProfileFirebaseService();
  late User user;
  List<Story> stories = [];

  Future<void> getUser() async {
    emit(ProfileLoading());
    try {
      user = await profileFirebaseService.getUser();
      emit(GetUserSuccess());
    } catch (e) {
      emit(GetUserError(Failure.fromException(e).message));
    }
  }

  Future<void> updateUser(User updatedUser) async {
    emit(UpdateUserLoading());
    try {
      await profileFirebaseService.updateUser(updatedUser);
      emit(UpdateUserSuccess());
    } catch (e) {
      emit(UpdateUserError(Failure.fromException(e).message));
    }
  }

  Future<void> updateBio(String newBio) async {
    emit(UpdateUserBioLoading());
    try {
      await profileFirebaseService.updateBio(newBio);
      emit(UpdateUserBioSuccess());
    } catch (e) {
      emit(UpdateUserBioError(Failure.fromException(e).message));
    }
  }

  Future<void> uploadProfileImageToFireStorage(
    File imageFile,
  ) async {
    emit(UploadProfileImageLoading());
    try {
      await profileFirebaseService
          .uploadProfileImage(imageFile, getImageFileName)
          .then((value) => getUser());
      emit(UploadProfileImageSuccess());
    } catch (e) {
      emit(
        UploadProfileImageError(Failure.fromException(e).message),
      );
    }
  }

  void fetchStories() {
    emit(GetUserStoriesLoading());
    try {
      profileFirebaseService.fetchStories().listen((newStories) {
        stories = newStories;
        emit(GetUserStoriesSuccess());
      });
    } catch (e) {
      emit(
        GetUserStoriesError(Failure.fromException(e).message),
      );
    }
  }
}
