import 'package:cloud_firestore/cloud_firestore.dart';

class FriendMessage {
  final String friendId;
  final String messageId;
  final String message;
  final String sender;
  final DateTime sentAt;

  FriendMessage({
    required this.friendId,
    required this.messageId,
    required this.message,
    required this.sender,
    required this.sentAt,
  });

  FriendMessage.fromJson(Map<String, dynamic> json)
      : this(
          friendId: json['friendId'] as String,
          messageId: json['messageId'] as String,
          message: json['message'] as String,
          sender: json['sender'] as String,
          sentAt: json['sentAt'] != null
              ? (json['sentAt'] as Timestamp).toDate()
              : DateTime.now(),
        );

  Map<String, dynamic> toJson() => {
        'friendId': friendId,
        'messageId': messageId,
        'message': message,
        'sender': sender,
        'sentAt': Timestamp.fromDate(sentAt),
      };
}
