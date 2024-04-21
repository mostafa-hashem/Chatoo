import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  String? groupId;
  String? messageId;
  String? message;
  User? sender;
  DateTime? sentAt;
  bool? left;
  bool? joined;
  bool? requested;
  bool? declined;

  GroupMessage({
    this.groupId,
    this.messageId,
    this.message,
    this.sender,
    this.sentAt,
    this.left,
    this.joined,
    this.requested,
    this.declined,
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
    if (json['left'] != null) {
      left = json['left'] as bool;
    }
    if (json['joined'] != null) {
      joined = json['joined'] as bool;
    }
    if (json['requested'] != null) {
      requested = json['requested'] as bool;
    }
    if (json['declined'] != null) {
      declined = json['declined'] as bool;
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
        if (left != null) 'left': left,
        if (joined != null) 'joined': joined,
        if (requested != null) 'requested': requested,
        if (declined != null) 'declined': declined,
      };
}
