import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String? groupId;
  String? groupName;
  String? groupIcon;
  String? mainAdminId;
  List<dynamic>? groupAdmins;
  List<dynamic>? members;
  List<dynamic>? requests;
  String? recentMessage;
  DateTime? recentMessageSentAt;
  String? recentMessageSender;
  String? recentMessageSenderId;
  DateTime? createdAt;
  Map<String, dynamic>? unreadMessageCounts;

  Group({
    this.groupId = '',
    required this.groupName,
    this.groupIcon = "",
    this.mainAdminId = "",
    this.groupAdmins,
    this.members,
    this.requests,
    this.recentMessage = "",
    this.recentMessageSender = "",
    this.recentMessageSenderId = "",
    this.recentMessageSentAt,
    this.createdAt,
    this.unreadMessageCounts,
  });

  Group.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'] as String?;
    groupName = json['groupName'] as String;
    mainAdminId = json['mainAdminId'] as String?;
    groupIcon = json['groupIcon'] as String?;
    groupAdmins = json['groupAdmins'] as List<dynamic>?;
    members = json['members'] as List<dynamic>?;
    requests = json['requests'] != null ? json['requests'] as List<dynamic>? : [];
    recentMessage = json['recentMessage'] as String?;
    if (json['recentMessageSentAt'] != null) {
      if (json['recentMessageSentAt'] is Timestamp) {
        recentMessageSentAt = (json['recentMessageSentAt'] as Timestamp).toDate().toLocal();
      } else if (json['recentMessageSentAt'] is String) {
        recentMessageSentAt = DateTime.parse(json['recentMessageSentAt'] as String).toLocal();
      }
    }
    recentMessageSender = json['recentMessageSender'] as String?;
    recentMessageSenderId = json['recentMessageSenderId'] as String?;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        createdAt = (json['createdAt'] as Timestamp).toDate().toLocal();
      } else if (json['createdAt'] is String) {
        createdAt = DateTime.parse(json['createdAt'] as String).toLocal();
      }
    }
    if (json['unreadMessageCounts'] != null) {
      unreadMessageCounts = json['unreadMessageCounts'] as Map<String, dynamic>?;
    }
  }

  Map<String, dynamic> toJson() => {
    'groupId': groupId,
    'groupName': groupName,
    'mainAdminId': mainAdminId,
    'groupIcon': groupIcon,
    'groupAdmins': groupAdmins,
    'members': members,
    'requests': requests!.isNotEmpty ? requests : [],
    'recentMessage': recentMessage,
    'recentMessageSentAt': recentMessageSentAt?.toIso8601String(),
    'recentMessageSender': recentMessageSender,
    'recentMessageSenderId': recentMessageSenderId,
    'createdAt': createdAt?.toIso8601String(),
    if (unreadMessageCounts != null) 'unreadMessageCounts': unreadMessageCounts,
  };
}
