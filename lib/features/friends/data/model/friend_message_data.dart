import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendMessage {
  final String friendId;
  final String messageId;
  final String message;
  final User sender;
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
          sender: User.fromJson(json['sender'] as Map<String, dynamic>),
          sentAt: json['sentAt'] != null
              ? (json['sentAt'] as Timestamp).toDate()
              : DateTime.now(),
        );

  Map<String, dynamic> toJson() => {
        'friendId': friendId,
        'messageId': messageId,
        'message': message,
        'sender': sender.toJson(),
        'sentAt': Timestamp.fromDate(sentAt),
      };
}
