import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRecentMessage {
  User? friend;
  String? recentMessage;
  String? recentMessageSender;
  DateTime? sentAt;
  DateTime? addedAt;

  FriendRecentMessage({
    required this.recentMessage,
    required this.recentMessageSender,
    required this.sentAt,
    required this.addedAt,
  });

  FriendRecentMessage.empty()
      : recentMessage = '',
        recentMessageSender = '',
        sentAt = null,
        addedAt = null;

  FriendRecentMessage.fromJson(Map<String, dynamic> json) {
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
      addedAt = (json['addedAt'] as Timestamp).toDate();
    }
  }

  Map<String, dynamic> toJson() => {
        if (recentMessage != null) 'recentMessage': recentMessage,
        if (recentMessageSender != null)
          'recentMessageSender': recentMessageSender,
        if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
        if (addedAt != null) 'addedAt': addedAt,
      };
}
