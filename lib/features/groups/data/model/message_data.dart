import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String groupId;
  final String messageId;
  final String message;
  final User sender;
  final DateTime sentAt;

  Message({
    required this.groupId,
    required this.messageId,
    required this.message,
    required this.sender,
    required this.sentAt,
  });

  Message.fromJson(Map<String, dynamic> json)
      : this(
    groupId: json['groupId'] as String,
    messageId: json['messageId'] as String,
    message: json['message'] as String,
    sender: User.fromJson(json['sender'] as Map<String, dynamic>),
    sentAt: json['sentAt'] != null ? (json['sentAt'] as Timestamp).toDate() : DateTime.now(),
  );


  Map<String, dynamic> toJson() => {
    'groupId': groupId,
    'messageId': messageId,
    'message': message,
    'sender': sender.toJson(),
    'sentAt': Timestamp.fromDate(sentAt),
  };
}
