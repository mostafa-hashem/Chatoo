import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  video,
  record,
}

class GroupMessage {
  String? groupId;
  String? messageId;
  String? message;
  String? senderId;
  User? sender;
  DateTime? sentAt;
  List<String>? mediaUrls;
  MessageType? messageType;
  bool? isAction;
  GroupMessage? repliedMessage; // إضافة خاصية الرسالة المردود عليها

  GroupMessage({
    this.groupId,
    this.messageId,
    this.message,
    this.senderId,
    this.sender,
    this.sentAt,
    this.mediaUrls,
    this.messageType,
    this.isAction,
    this.repliedMessage, // إضافة هنا
  });

  GroupMessage.fromJson(Map<String, dynamic> json) {
    if (json['groupId'] != null) {
      groupId = json['groupId'] as String;
    }
    if (json['messageId'] != null) {
      messageId = json['messageId'] as String;
    }
    if (json['message'] != null) {
      message = json['message'] as String;
    }
    if (json['senderId'] != null) {
      senderId = json['senderId'] as String;
    }
    if (json['sender'] != null) {
      sender = User.fromJson(json['sender'] as Map<String, dynamic>);
    }
    if (json['sentAt'] != null) {
      sentAt = (json['sentAt'] as Timestamp).toDate().toLocal();
    }
    if (json['mediaUrls'] != null) {
      mediaUrls = List<String>.from(json['mediaUrls'] as List<dynamic>);
    }
    if (json['messageType'] != null) {
      messageType = MessageType.values[json['messageType'] as int];
    }
    if (json['isAction'] != null) {
      isAction = json['isAction'] as bool;
    }
    if (json['repliedMessage'] != null) {
      repliedMessage =
          GroupMessage.fromJson(json['repliedMessage'] as Map<String, dynamic>);
    }
  }

  Map<String, dynamic> toJson() => {
        if (groupId != null) 'groupId': groupId,
        if (messageId != null) 'messageId': messageId,
        if (message != null) 'message': message,
        if (senderId != null) 'senderId': senderId,
        if (sender != null) 'sender': sender!.toJson(),
        'sentAt': Timestamp.now(),
        if (mediaUrls != null) 'mediaUrls': mediaUrls,
        if (messageType != null) 'messageType': messageType!.index,
        if (isAction != null) 'isAction': isAction,
        if (repliedMessage != null) 'repliedMessage': repliedMessage!.toJson(),
      };
}
