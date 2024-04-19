import 'package:chat_app/utils/data/models/user.dart';

class Friend {
  User? friendData;
  String? recentMessage;
  String? recentMessageSender;

  Friend({
    required this.friendData,
    required this.recentMessage,
    required this.recentMessageSender,
  });

  Friend.fromJson(Map<String, dynamic> json) {
    if (json['friendData'] != null) {
      friendData = User.fromJson(json['friendData'] as Map<String, dynamic>);
    }
    if (json['recentMessage'] != null) {
      recentMessage = json['recentMessage'] as String;
    }
    if (json['recentMessageSender'] != null) {
      recentMessageSender = json['recentMessageSender'] as String;
    }
  }

  Map<String, dynamic> toJson() => {
        if (friendData != null) 'friendData': friendData?.toJson(),
        if (recentMessage != null) 'recentMessage': recentMessage,
        if (recentMessageSender != null)
          'recentMessageSender': recentMessageSender,
      };
}
