import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRecentMessage {
  String? friendId;
  String? recentMessage;
  String? recentMessageSender;
  String? recentMessageSenderId;
  DateTime? sentAt;
  DateTime? addedAt;
  bool? typing;
  bool? recording;
  bool? seen;
  int? unreadCount;

  FriendRecentMessage({
    required this.recentMessage,
    required this.recentMessageSender,
    required this.recentMessageSenderId,
    required this.sentAt,
    required this.addedAt,
    this.unreadCount = 0,
    this.typing = false,
    this.recording = false,
    this.seen = false,
  });

  FriendRecentMessage.empty()
      : recentMessage = '',
        recentMessageSender = '',
        recentMessageSenderId = '',
        unreadCount = 0,
        sentAt = null,
        addedAt = null,
        typing = false,
        recording = false,
        seen = false;

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
    if (json['recentMessageSenderId'] != null) {
      recentMessageSenderId = json['recentMessageSenderId'] as String;
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
    if (json['seen'] != null) {
      seen = json['seen'] as bool?;
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
        if (recentMessageSenderId != null)
          'recentMessageSenderId': recentMessageSenderId,
        'sentAt': sentAt ?? Timestamp.now(),
        if (addedAt != null) 'addedAt': Timestamp.now(),
        if (typing != null) 'typing': typing,
        if (recording != null) 'recording': typing,
        if (seen != null) 'seen': seen,
        if (unreadCount != null) 'unreadCount': unreadCount,
      };
}
