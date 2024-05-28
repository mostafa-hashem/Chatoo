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
    required this.createdAt,
    this.unreadMessageCounts,
  });

  Group.fromJson(Map<String, dynamic> json) {
    groupId = json['groupId'] as String?;
    groupName = json['groupName'] as String;
    mainAdminId = json['mainAdminId'] as String?;
    groupIcon = json['groupIcon'] as String?;
    groupAdmins = json['groupAdmins'] as List<dynamic>?;
    members = json['members'] as List<dynamic>?;
    requests =
        json['requests'] != null ? json['requests'] as List<dynamic>? : [];
    recentMessage = json['recentMessage'] as String?;
    recentMessageSentAt =
        (json['recentMessageSentAt'] as Timestamp?)?.toDate().toLocal();
    recentMessageSender = json['recentMessageSender'] as String?;
    recentMessageSenderId = json['recentMessageSenderId'] as String?;
    createdAt = (json['createdAt'] as Timestamp).toDate().toLocal();
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
        'recentMessageSentAt':
            recentMessageSentAt?.toLocal() ?? DateTime.now().toLocal(),
        'recentMessageSender': recentMessageSender,
        'recentMessageSenderId': recentMessageSenderId,
        'createdAt': createdAt!.toLocal(),
        if (unreadMessageCounts != null)
          'unreadMessageCounts': unreadMessageCounts,
      };
}
