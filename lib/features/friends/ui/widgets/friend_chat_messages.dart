import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_messages_tile.dart';
import 'package:flutter/material.dart';

class FriendChatMessages extends StatefulWidget {
  // Note: Avoid using `const` with constructors.
  FriendChatMessages({
    super.key,
  });

  @override
  State<FriendChatMessages> createState() => _FriendChatMessagesState();
}

class _FriendChatMessagesState extends State<FriendChatMessages> {
  @override
  Widget build(BuildContext context) {
    final friendMessages =
        FriendCubit.get(context).filteredMessages.reversed.toList();
    return Expanded(
      child: ListView.builder(
        reverse: true,
        controller: FriendCubit.get(context).scrollController,
        itemBuilder: (context, index) {
          return FriendMessagesTile(
            friendMessage: friendMessages[index],
            sentByMe: ProfileCubit.get(context).user.userName ==
                friendMessages[index].sender.userName,
          );
        },
        itemCount: friendMessages.length,
      ),
    );
  }
}
