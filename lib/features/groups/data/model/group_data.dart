import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String groupId;
  final String groupName;
  String groupIcon;
  final String adminId;
  List<dynamic>? members;
  String recentMessage;
  String recentMessageSender;
  final DateTime createdAt;

  Group({
    this.groupId = '',
    required this.groupName,
    this.groupIcon = "",
    this.adminId = "",
    this.members,
    this.recentMessage = "",
    this.recentMessageSender = "",
    required this.createdAt,
  });

  Group.fromJson(Map<String, dynamic> json)
      : this(
          groupId: json['groupId'] as String,
          groupName: json['groupName'] as String,
          adminId: json['adminId'] as String,
          groupIcon: json['groupIcon'] as String,
          members: json['members'] as List<dynamic>?,
          recentMessage: json['recentMessage'] as String,
          recentMessageSender: json['recentMessageSender'] as String,
          createdAt: (json['createdAt'] as Timestamp).toDate(),
        );

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'groupName': groupName,
        'adminId': adminId,
        'groupIcon': groupIcon,
        'members': members,
        'recentMessage': recentMessage,
        'recentMessageSender': recentMessageSender,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
