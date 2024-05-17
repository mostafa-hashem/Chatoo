import 'dart:convert';

import 'package:chat_app/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationsServices {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    FirebaseMessaging.onBackgroundMessage(
      (message) => handelBackgroundMessage(message),
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    // Handle notification when app is opened from terminated state
    await _firebaseMessaging.getInitialMessage();

    // await FirebaseMessaging.instance.setAutoInitEnabled(true);
    return fCMToken;
  }

  Future<void> handelBackgroundMessage(RemoteMessage message) async {}

  Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    required String action,
  }) async {
    final notification = {
      'title': title,
      'body': body,
      'mutable_content': true,
      'sound': 'Tri-tone',
    };

    final data = {
      'notification': notification,
      'priority': 'high',
      'data': {
        'click_action': "Flutter_click_action",
        'title': title,
        'body': body,
      },
      'to': fcmToken,
    };

    await http.post(
      Uri.parse(FirebasePath.fcmUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${FirebasePath.serverKey}',
      },
      body: jsonEncode(data),
    );
  }
}
