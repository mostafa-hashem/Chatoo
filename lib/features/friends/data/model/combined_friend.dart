import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:chat_app/utils/data/models/user.dart';

class CombinedFriend {
  final User? user;
  final FriendRecentMessage recentMessageData;
  final  List<Story>? stories;

  CombinedFriend({
    required this.user,
    required this.recentMessageData,
    this.stories,
  });
}
