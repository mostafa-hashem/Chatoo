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
  DateTime? createdAt;

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
    this.recentMessageSentAt ,
    required this.createdAt,
  });

  Group.fromJson(Map<String, dynamic> json){
    groupId =
    json['groupId'] as String;
    groupName = json['groupName'] as String;
    mainAdminId = json['mainAdminId'] as String;
    groupIcon = json['groupIcon'] as String;
    groupAdmins = json['groupAdmins'] as List<dynamic>?;
    members = json['members'] as List<dynamic>?;
    requests = json['requests'] != null
        ? json['requests'] as List<dynamic>?
        : [];
    if(json['recentMessage'] != null){
    recentMessage = json['recentMessage'] as String;
    }
    if(json['recentMessageSentAt'] != null){
    recentMessageSentAt =
        (json['recentMessageSentAt'] as Timestamp).toDate();
    }
    if(json['recentMessageSender'] != null){
    recentMessageSender = json['recentMessageSender'] as String;
    }
    createdAt = (json['createdAt'] as Timestamp).toDate();
  }

  Map<String, dynamic> toJson() =>
      {
        'groupId': groupId,
        'groupName': groupName,
        'mainAdminId': mainAdminId,
        'groupIcon': groupIcon,
        'groupAdmins': groupAdmins,
        'members': members,
        'requests': requests!.isNotEmpty ? requests : [],
        'recentMessage': recentMessage,
        'recentMessageSentAt': recentMessageSentAt ?? recentMessageSentAt,
        'recentMessageSender': recentMessageSender,
        'createdAt': Timestamp.fromDate(createdAt!),
      };
}
