import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/cupertino.dart';

enum MessageType {
  text,
  image,
  video,
  record,
  audio,
}

class FriendMessage {
  String friendId = '';
  String messageId = '';
  String message = '';
  String sender = '';
  List<String>? mediaUrls;
  MessageType? messageType;
  DateTime? sentAt;
  FriendMessage? repliedMessage;
  Story? replayToStory;
  Map<String, dynamic>? readBy; // تعديل الحقل ليكون خريطة

  FriendMessage({
    required this.friendId,
    required this.messageId,
    required this.message,
    required this.sender,
    this.mediaUrls,
    this.messageType,
    this.sentAt,
    this.repliedMessage,
    this.replayToStory,
    this.readBy,
  });

  FriendMessage.empty()
      : friendId = '',
        messageId = '',
        message = '',
        sender = '',
        mediaUrls = [],
        messageType = MessageType.text,
        sentAt = null;

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
      sentAt = (json['sentAt'] as Timestamp).toDate().toLocal();
    }
    if (json['repliedMessage'] != null) {
      repliedMessage = FriendMessage.fromJson(
        json['repliedMessage'] as Map<String, dynamic>,
      );
    }
    if (json['replayToStory'] != null) {
      replayToStory =
          Story.fromJson(json['replayToStory'] as Map<String, dynamic>);
    }
    readBy = json['readBy'] != null
        ? Map<String, dynamic>.from(json['readBy'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'messageId': messageId,
      'message': message,
      'sender': sender,
      if (mediaUrls != null) 'mediaUrls': mediaUrls,
      if (messageType != null) 'messageType': messageType!.index,
      'sentAt': sentAt ?? Timestamp.now(),
      if (repliedMessage != null) 'repliedMessage': repliedMessage!.toJson(),
      if (replayToStory != null) 'replayToStory': replayToStory!.toJson(),
      if (readBy != null) 'readBy': readBy,
    };
  }

  List<String> getUserIds() {
    return readBy?.keys.toList() ?? [];
  }

  Future<List<User>> fetchUsersByIds(List<String> userIds) async {
    final List<User> users = [];
    for (final String userId in userIds) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(FirebasePath.users)
          .doc(userId)
          .get();
      if (userDoc.exists) {
        users.add(User.fromJson(userDoc.data()! as Map<String, dynamic>));
      }
    }
    return users;
  }

  Future<List<Map<String, dynamic>>> combinedSeen() async {
    final List<String> userIds = getUserIds();
    final List<User> users = await fetchUsersByIds(userIds);

    final combined = <Map<String, dynamic>>[];
    readBy?.forEach((userId, viewAt) {
      final user = users.firstWhere((user) => user.id == userId,
        orElse: () => User.empty(),);
      combined.add({
        'user': user,
        'viewAt': viewAt,
      });
    });
    combined.sort((a, b) =>
        (a['viewAt'] as Timestamp).compareTo(b['viewAt'] as Timestamp),);
    return combined;
  }
}

