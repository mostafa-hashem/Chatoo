import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  String? groupId;
  String? messageId;
  String? message;
  User? sender;
  DateTime? sentAt;
  bool? isAction;

  GroupMessage({
    this.groupId,
    this.messageId,
    this.message,
    this.sender,
    this.sentAt,
    this.isAction,
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
    if (json['isAction'] != null) {
      isAction = json['isAction'] as bool;
    }
    if (json['sender'] != null) {
      sender = User.fromJson(json['sender'] as Map<String, dynamic>);
    }
    if (json['sentAt'] != null) {
      sentAt = (json['sentAt'] as Timestamp).toDate();
    }
  }

  Map<String, dynamic> toJson() => {
        if (groupId != null) 'groupId': groupId,
        if (messageId != null) 'messageId': messageId,
        if (message != null) 'message': message,
        if (sender != null) 'sender': sender!.toJson(),
        if (sentAt != null) 'sentAt': Timestamp.fromDate(sentAt!),
        if (isAction != null) 'isAction': isAction,
      };
}
