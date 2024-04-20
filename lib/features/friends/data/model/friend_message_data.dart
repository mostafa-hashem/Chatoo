import 'package:cloud_firestore/cloud_firestore.dart';

class FriendMessage {
   String friendId = '';
   String messageId = '';
   String message = '';
   String sender = '';
   DateTime sentAt = DateTime.now();

  FriendMessage({
    required this.friendId,
    required this.messageId,
    required this.message,
    required this.sender,
    required this.sentAt,
  });

  FriendMessage.fromJson(Map<String, dynamic> json) {
    if (json['friendId'] != null) {
      friendId = json['friendId'] as String;
    }
    if (json['messageId'] != null) {
      messageId = json['messageId'] as String;
    }
    if (json['message'] != null) {
      message = json['message'] as String;
    }
    if (json['sender'] != null) {
      sender = json['sender'] as String;
    }
    if (json['sentAt'] != null) {
      sentAt = (json['sentAt'] as Timestamp).toDate();
    }
  }
  Map<String, dynamic> toJson() => {
        'friendId': friendId,
        'messageId': messageId,
        'message': message,
        'sender': sender,
        'sentAt': Timestamp.fromDate(sentAt),
      };
}
