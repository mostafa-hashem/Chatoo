import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class NotificationServices {
  final _firebaseMessaging = FirebaseMessaging.instance;
  String? fCMToken;
  Future<void> initNotifications() async {
    await _requestPermission();
    await _firebaseMessaging.requestPermission();
     fCMToken = await _firebaseMessaging.getToken();
    print("Token : $fCMToken");

    FirebaseMessaging.onBackgroundMessage(
      (message) => handelBackgroundMessage(message),
    );

    // Listen for incoming messages while app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Title : ${message.notification?.title}");
      print("Body : ${message.notification?.body}");
      print("Payload : ${message.data}");
    });

    // Handle notification when app is opened from terminated state
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {}
  }

  Future<void> handelBackgroundMessage(RemoteMessage message) async {}

  Future<void> _requestPermission() async {
     await [
      Permission.notification,
      Permission.systemAlertWindow,
      Permission.storage,
    ].request();
  }

  Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    try {
      const String serverKey =
          'AAAAk5E-P4Y:APA91bEDflwLO5Lalz6bCqClF25vdfDnwPuxSYETPQxEfuT_5MwdRQzNvTZPlPSVmoPO_kJinYLHU8sggaqqjhvRCTVB3IZP2c7e_Sq-W4oksNlQsbcdJB3ZnUP2nPoMNV1ZtMfnA1eA';
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

      final Map<String, dynamic> data = {
        'notification': {
          'title': title,
          'body': body,
          "mutable_content": true,
          "sound": "Tri-tone"
        },
        'priority': 'high',
        'data': {'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
        'to': fcmToken,
      };
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Error sending notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
