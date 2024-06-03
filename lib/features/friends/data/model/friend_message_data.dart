import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  }

  Map<String, dynamic> toJson() {
    debugPrint("Holla: ${Timestamp.now().toDate()}");
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
    };
  }
}
