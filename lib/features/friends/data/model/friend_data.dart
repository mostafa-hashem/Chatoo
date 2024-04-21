

import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  String? recentMessage;
  String? recentMessageSender;
   DateTime? sentAt;
   DateTime? addedAt;

  Friend({
    required this.recentMessage,
    required this.recentMessageSender,
    required this.sentAt,
    required this.addedAt,
  });

  Friend.fromJson(Map<String, dynamic> json) {
    if (json['recentMessage'] != null) {
      recentMessage = json['recentMessage'] as String;
    }
    if (json['recentMessageSender'] != null) {
      recentMessageSender = json['recentMessageSender'] as String;
    }
    if (json['sentAt'] != null) {
      sentAt = (json['sentAt'] as Timestamp).toDate();
    }
    if (json['addedAt'] != null) {
      sentAt = (json['addedAt'] as Timestamp).toDate();
    }
  }

  Map<String, dynamic> toJson() => {
        if (recentMessage != null) 'recentMessage': recentMessage,
        if (recentMessageSender != null)
          'recentMessageSender': recentMessageSender,
    if (sentAt != null)
          'sentAt': sentAt,
    if (addedAt != null)
          'addedAt': addedAt,
      };
}
