import 'dart:io';

import 'package:chat_app/features/stories/cubit/stories_state.dart';
import 'package:chat_app/features/stories/data/services/story_firebase_services.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoriesCubit extends Cubit<StoriesState> {
  StoriesCubit() : super(StoriesInitial());
  final _storyFirebaseServices = StoryFirebaseServices();

  static StoriesCubit get(BuildContext context) => BlocProvider.of(context);

  Future<void> uploadStory({
    required File mediaFile,
    required String storyCaption,
    required Future<String> Function(File imageFile) getFileName,
  }) async {
    emit(UploadStoryLoading());
    try {
      await _storyFirebaseServices.uploadStory(
        mediaFile,
        storyCaption,
        getFileName,
      );
      emit(UploadStorySuccess());
    } catch (e) {
      emit(UploadStoryError(Failure.fromException(e).message));
    }
  }

  Future<void> deleteStory({
    required String storyId,
    required String fileName,
  }) async {
    emit(DeleteStoryLoading());
    try {
      await _storyFirebaseServices.deleteStory(
        storyId,
        fileName,
      );
      emit(DeleteStorySuccess());
    } catch (e) {
      emit(DeleteStoryError(Failure.fromException(e).message));
    }
  }
}
