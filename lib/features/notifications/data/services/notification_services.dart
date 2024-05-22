import 'dart:convert';

import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationsServices {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();

    FirebaseMessaging.onBackgroundMessage(handelBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    await _firebaseMessaging.getInitialMessage();

    return fCMToken;
  }

  static Future<void> handelBackgroundMessage(RemoteMessage message) async {
    // Handle background message
  }

  Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    String? imageUrl,
    User? friendData,
    Group? groupData,
  }) async {
    final notification = {
      'title': title,
      'body': body,
      'mutable_content': true,
      'sound': 'Tri-tone',
      if (imageUrl != null) 'image': imageUrl,
    };

    final data = {
      'notification': notification,
      'priority': 'high',
      'data': {
        'click_action': "FLUTTER_NOTIFICATION_CLICK",
        'title': title,
        'body': body,
        // if (friendData != null) 'friendData': friendData.toJson(),
        // if (groupData != null) 'groupData': groupData.toJson(),
        if (imageUrl != null) 'image': imageUrl,
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
