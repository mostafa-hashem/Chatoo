import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/notifications/cubit/notifications_states.dart';
import 'package:chat_app/features/notifications/data/services/notification_services.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsStates> {
  final GlobalKey<NavigatorState> navigatorKey;
  late final NotificationsServices notificationsServices;

  NotificationsCubit(this.navigatorKey) : super(NotificationsInitial()) {
    notificationsServices = NotificationsServices(navigatorKey);
  }

  static NotificationsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  String? fCMToken;
  Future<void> initNotifications() async {
    emit(NotificationsLoading());
    try {
      fCMToken = await notificationsServices.initNotifications();
      emit(NotificationsSuccess());
    } catch (e) {
      emit(NotificationsError(Failure.fromException(e).message));
    }
  }

  Future<void> sendNotification({
    required String fCMToken,
    required String title,
    required String body,
    String? imageUrl,
    User? friendData,
    Group? groupData,
    String? isFriendRequest,
  }) async {
    emit(SendNotificationLoading());
    try {
      notificationsServices.sendNotification(
        fcmToken: fCMToken,
        title: title,
        body: body,
        imageUrl: imageUrl,
        friendData: friendData,
        groupData: groupData,
        isFriendRequest: isFriendRequest
      );
      emit(SendNotificationSuccess());
    } catch (e) {
      emit(SendNotificationError(Failure.fromException(e).message));
    }
  }
}
