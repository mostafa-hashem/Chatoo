import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRecentMessage {
  String? friendId;
  String? recentMessage;
  String? recentMessageSender;
  DateTime? sentAt;
  DateTime? addedAt;
  bool? typing;
  bool? recording;
  int? unreadCount;

  FriendRecentMessage({
    required this.recentMessage,
    required this.recentMessageSender,
    required this.sentAt,
    required this.addedAt,
    this.unreadCount = 0,
    this.typing = false,
    this.recording = false,
  });

  FriendRecentMessage.empty()
      : recentMessage = '',
        recentMessageSender = '',
        unreadCount = 0,
        sentAt = null,
        addedAt = null,
        typing = false,
        recording = false;

  FriendRecentMessage.fromJson(Map<String, dynamic> json) {
    if (json['friendId'] != null) {
      friendId = json['friendId'] as String;
    }
    if (json['recentMessage'] != null) {
      recentMessage = json['recentMessage'] as String;
    }
    if (json['recentMessageSender'] != null) {
      recentMessageSender = json['recentMessageSender'] as String;
    }
    if (json['sentAt'] != null) {
      sentAt = (json['sentAt'] as Timestamp).toDate().toLocal();
    }
    if (json['addedAt'] != null) {
      addedAt = (json['addedAt'] as Timestamp).toDate().toLocal();
    }
    if (json['typing'] != null) {
      typing = json['typing'] as bool?;
    }
    if (json['recording'] != null) {
      recording = json['recording'] as bool?;
    }
    if (json['unreadCount'] != null) {
      unreadCount = json['unreadCount'] as int?;
    }
  }

  Map<String, dynamic> toJson() => {
        if (friendId != null) 'friendId': friendId,
        if (recentMessage != null) 'recentMessage': recentMessage,
        if (recentMessageSender != null)
          'recentMessageSender': recentMessageSender,
       'sentAt': Timestamp.now(),
        if (addedAt != null) 'addedAt': Timestamp.now(),
        if (typing != null) 'typing': typing,
        if (recording != null) 'recording': typing,
        if (unreadCount != null) 'unreadCount': unreadCount,
      };
}
