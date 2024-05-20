import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  video,
  record,
}

class FriendMessage {
  String friendId = '';
  String messageId = '';
  String message = '';
  String sender = '';
  List<String>? mediaUrls;
  MessageType? messageType;
  DateTime sentAt = DateTime.now();

  FriendMessage({
    required this.friendId,
    required this.messageId,
    required this.message,
    required this.sender,
    this.mediaUrls,
    this.messageType,
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
    if (json['mediaUrls'] != null) {
      mediaUrls = List<String>.from(json['mediaUrls'] as List<dynamic>);
    }
    if (json['messageType'] != null) {
      messageType = MessageType.values[json['messageType'] as int];
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
        if (mediaUrls != null) 'mediaUrls': mediaUrls,
        if (messageType != null) 'messageType': messageType!.index,
        'sentAt': Timestamp.fromDate(sentAt),
      };
}
