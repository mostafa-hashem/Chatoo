import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_messages_tile.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupChatMessages extends StatefulWidget {
  GroupChatMessages({
    super.key,
  });

  @override
  State<GroupChatMessages> createState() => _GroupChatMessagesState();
}

class _GroupChatMessagesState extends State<GroupChatMessages> {
  @override
  Widget build(BuildContext context) {
    final groupMessages = GroupCubit.get(context).filteredMessages.toList();

    final Map<String, List<GroupMessage>> messagesByDate = {};
    for (final message in groupMessages) {
      final String date = getFormattedDateHeader(message.sentAt!.millisecondsSinceEpoch);
      if (messagesByDate.containsKey(date)) {
        messagesByDate[date]!.add(message);
      } else {
        messagesByDate[date] = [message];
      }
    }

    final List<MapEntry<String, List<GroupMessage>>> dateEntries = messagesByDate.entries.toList();

    return Expanded(
      child: ListView.builder(
        reverse: true,
        controller: GroupCubit.get(context).scrollController,
        itemCount: dateEntries.length,
        itemBuilder: (context, index) {
          final dateEntry = dateEntries[index];
          final date = dateEntry.key;
          final messages = dateEntry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Text(
                    date,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                  ),
                ),
              ),
              ...messages.map((message) {
                return GroupMessagesTile(
                  groupMessage: message,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
