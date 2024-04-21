import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/ui/widgets/group_messages_tile.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  final String groupId;

  // Note: Avoid using `const` with constructors.
  ChatMessages({
    super.key,
    required this.groupId,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {
    final groupMessages =
        GroupCubit.get(context).filteredMessages.reversed.toList();
    return Expanded(
      child: ListView.builder(
        reverse: true,
        controller: GroupCubit.get(context).scrollController,
        itemCount: groupMessages.length,
        itemBuilder: (context, index) {
          return GroupMessagesTile(
            groupMessage: groupMessages[index],
            sentByMe: ProfileCubit.get(context).user.id ==
                groupMessages[index].sender!.id,
            groupId: widget.groupId,
            isUserLeft: groupMessages[index].left!,
            isUserJoined: groupMessages[index].joined!,
            isUserRequested: groupMessages[index].requested!,
            isUserUserDeclined: groupMessages[index].declined!,
          );
        },
      ),
    );
  }
}
