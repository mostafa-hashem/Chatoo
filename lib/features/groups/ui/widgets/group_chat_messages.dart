import 'package:chat_app/features/groups/data/model/message_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_messages_tile.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  final List<Message> groupData;

  const ChatMessages({
    super.key,
    required this.groupData,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child:  ListView.builder(
        itemCount: widget.groupData.length,
        itemBuilder: (context, index) {
          return GroupMessagesTile(
            groupMessage:widget.groupData[index],
            sentByMe: ProfileCubit.get(context).user.id ==
                widget.groupData[index].sender.id,
          );
        },
      ),
    );
  }
}
