import 'package:chat_app/features/notifications/cubit/notifications_states.dart';
import 'package:chat_app/features/notifications/data/services/notification_services.dart';
import 'package:chat_app/utils/data/failure/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsStates> {
  NotificationsCubit() : super(NotificationsInitial());

  static NotificationsCubit get(BuildContext context) =>
      BlocProvider.of(context);

  final notificationsServices = NotificationsServices();
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
  }) async {
    emit(SendNotificationLoading());
    try {
      notificationsServices.sendNotification(
        fcmToken: fCMToken,
        title: title,
        body: body,
        imageUrl: imageUrl,
      );
      emit(SendNotificationSuccess());
    } catch (e) {
      emit(SendNotificationError(Failure.fromException(e).message));
    }
  }
}
