import 'package:chat_app/utils/cubit/suggestion_state.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:chat_app/utils/data/models/suggestion.dart';
import 'package:chat_app/utils/data/services/suggestion_firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SuggestionCubit extends Cubit<SuggestionStates> {
  SuggestionCubit() : super(SuggestionInit());

  static SuggestionCubit get(BuildContext context) => BlocProvider.of(context);
  final _suggestionServices = SuggestionFirebaseServices();

  Future<void> sendSuggestion(Suggestion suggestion) async {
    emit(SendSuggestionLoading());
    try {
      await _suggestionServices.sendSuggestion(suggestion);
      emit(SendSuggestionSuccess());
    } catch (e) {
      emit(SendSuggestionError(Failure.fromException(e).message));
    }
  }
}
