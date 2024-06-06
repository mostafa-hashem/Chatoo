  class NotificationModel {
    String title;
    String body;
    bool mutableContent;
    String sound;

    NotificationModel({
      required this.title,
      required this.body,
      required this.mutableContent,
      required this.sound,
    });

    Map<String, dynamic> toJson() {
      return {
        'title': title,
        'body': body,
        'mutable_content': mutableContent,
        'sound': sound,
      };
    }
  }

  class FCMRequest {
    NotificationModel notification;
    String priority;
    Map<String, dynamic> data;
    String to;

    FCMRequest({
      required this.notification,
      required this.priority,
      required this.data,
      required this.to,
    });

    Map<String, dynamic> toJson() {
      return {
        'notification': notification.toJson(),
        'priority': priority,
        'data': data,
        'to': to,
      };
    }
  }
