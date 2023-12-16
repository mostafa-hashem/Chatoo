import 'package:chat_app/features/friends/cubit/states.dart';
import 'package:chat_app/features/friends/data/services/friend_firebase_services.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendCubit extends Cubit<FriendStates> {
  FriendCubit() : super(FriendInit());

  static FriendCubit get(BuildContext context) => BlocProvider.of(context);
  final _friendFirebaseServices = FriendFirebaseServices();
  List<Group> allFriends = [];

  Future<void> addFriend() async {
    emit(AddFriendLoading());
    try {
      await _friendFirebaseServices.addFriend();
      emit(AddFriendSuccess());
    } catch (e) {
      emit(AddFriendError(Failure.fromException(e).message));
    }
  }

  Future<void> getAllUserFriends() async {
    emit(GetAllFriendsLoading());
    try {
      allFriends = await _friendFirebaseServices.getAllUserFriends();
      emit(GetAllFriendsSuccess());
    } catch (e) {
      emit(
        GetAllFriendsError(Failure.fromException(e).message),
      );
    }
  }
}
