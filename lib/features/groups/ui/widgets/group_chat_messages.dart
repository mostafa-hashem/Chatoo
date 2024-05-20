import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/ui/widgets/group_messages_tile.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  // Note: Avoid using `const` with constructors.
  ChatMessages({
    super.key,
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
          // if( GroupCubit.get(context).filteredMessages[index].messageType == MessageType.text) {
          return GroupMessagesTile(
            groupMessage: groupMessages[index],
          );
          // }else{
          // return const RecordTile(duration: "00:00:00",recordPath: "audios/Notification.mp3",);
          // }
        },
      ),
    );
  }
}
