import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/utils/data/models/user.dart';

class CombinedFriend {
  User? user;
  FriendRecentMessage? recentMessageData;

  CombinedFriend({required this.user, required this.recentMessageData,});
}
