import 'package:chat_app/features/groups/data/model/message_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/widgets/friend_messages_tile.dart';
import 'package:flutter/material.dart';

class FriendChatMessages extends StatefulWidget {
  final List<Message> friendData;

  const FriendChatMessages({
    super.key,
    required this.friendData,
  });

  @override
  State<FriendChatMessages> createState() => _FriendChatMessagesState();
}

class _FriendChatMessagesState extends State<FriendChatMessages> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:  ListView.builder(
        itemCount: widget.friendData.length,
        itemBuilder: (context, index) {
          return FriendMessagesTile(
            friendMessage:widget.friendData[index],
            sentByMe: ProfileCubit.get(context).user.userName ==
                widget.friendData[index].sender.userName,
          );
        },
      ),
    );
  }
}
