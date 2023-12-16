import 'package:chat_app/utils/data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String groupId;
  final String groupName;
  String groupIcon;
  final String adminName;
  List<User>? members;
  String recentMessage;
  String recentMessageSender;
  final DateTime createdAt;

  Group({
    this.groupId = '',
    required this.groupName,
    this.groupIcon = "",
    this.adminName = "",
    this.members,
    this.recentMessage = "",
    this.recentMessageSender = "",
    required this.createdAt,
  });

  Group.fromJson(Map<String, dynamic> json)
      : this(
          groupId: json['groupId'] as String,
          groupName: json['groupName'] as String,
          adminName: json['adminName'] as String,
          groupIcon: json['groupIcon'] as String,
          members: (json['members'] as List<dynamic>?)
              ?.map((member) => User.fromJson(member as Map<String, dynamic>))
              .toList(),
          recentMessage: json['recentMessage'] as String,
          recentMessageSender: json['recentMessageSender'] as String,
          createdAt: (json['createdAt'] as Timestamp).toDate(),
        );

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'groupName': groupName,
        'adminName': adminName,
        'groupIcon': groupIcon,
        'members': members?.map((user) => user.toJson()).toList(),
        'recentMessage': recentMessage,
        'recentMessageSender': recentMessageSender,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
