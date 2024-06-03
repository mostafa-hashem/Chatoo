import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;

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
  GroupMessage? repliedMessage;
  List<Map<String, dynamic>>? readBy;

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
    this.repliedMessage,
    this.readBy,
  });

  GroupMessage.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'] as String?;
    messageId = json['messageId'] as String?;
    message = json['message'] as String?;
    senderId = json['senderId'] as String?;
    sender = json['sender'] != null
        ? User.fromJson(json['sender'] as Map<String, dynamic>)
        : null;
    sentAt = json['sentAt'] != null
        ? (json['sentAt'] as Timestamp).toDate().toLocal()
        : null;
    mediaUrls = json['mediaUrls'] != null
        ? List<String>.from(json['mediaUrls'] as List<dynamic>)
        : null;
    messageType = json['messageType'] != null
        ? MessageType.values[json['messageType'] as int]
        : null;
    isAction = json['isAction'] as bool?;
    repliedMessage = json['repliedMessage'] != null
        ? GroupMessage.fromJson(json['repliedMessage'] as Map<String, dynamic>)
        : null;
    readBy = json['readBy'] != null
        ? List<Map<String, dynamic>>.from(json['readBy'] as List<dynamic>)
        : null;
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
        if (readBy != null) 'readBy': readBy,
      };

  List<String> getUserIds() {
    return readBy?.map((entry) => entry['userId'] as String).toList() ?? [];
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
    for (final entry in readBy ?? []) {
      if(entry['userId'] == FirebaseAuth.instance.currentUser!.uid){
        continue;
      }
      final user = users.firstWhere((user) => user.id == entry['userId'],
          orElse: () => User.empty());
      combined.add({
        'user': user,
        'viewAt': entry['viewAt'],
      });
    }
    combined.sort((a, b) =>
        (a['viewAt'] as Timestamp).compareTo(b['viewAt'] as Timestamp));
    return combined;
  }
}
