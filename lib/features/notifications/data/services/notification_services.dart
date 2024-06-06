import 'dart:convert';

import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationsServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationsServices(this.navigatorKey);

  Future<String?> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {});

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    await _firebaseMessaging.getInitialMessage();

    return fCMToken;
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
  }

  Future<void> _handleNotificationClick(RemoteMessage message) async {
    final data = message.data;
    if (data['friendData'] != null) {
      final friend = User.fromJson(
        jsonDecode(data['friendData'] as String) as Map<String, dynamic>,
      );
      navigatorKey.currentState?.pushNamed(
        Routes.friendChatScreen,
        arguments: friend,
      );
    } else if (data['groupData'] != null) {
      final group = Group.fromJson(
        jsonDecode(data['groupData'] as String) as Map<String, dynamic>,
      );

      navigatorKey.currentState?.pushNamed(
        Routes.groupChatScreen,
        arguments: group,
      );
    } else if (data['isFriendRequest'] == 'true') {
      navigatorKey.currentState?.pushNamed(
        Routes.requestsScreen,
      );
    }
  }

  Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    String? imageUrl,
    User? friendData,
    Group? groupData,
    String? isFriendRequest,
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
        'isFriendRequest': isFriendRequest ?? 'false',
        if (friendData != null) 'friendData': jsonEncode(friendData),
        if (groupData != null) 'groupData': jsonEncode(groupData),
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
