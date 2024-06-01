import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_messages_tile.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupChatMessages extends StatefulWidget {
  final String groupId;

  GroupChatMessages({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupChatMessages> createState() => _GroupChatMessagesState();
}

class _GroupChatMessagesState extends State<GroupChatMessages> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToMessage(String messageId) {
    final groupMessages = GroupCubit.get(context).filteredMessages[widget.groupId]?.toList();
    final index = groupMessages?.indexWhere((message) => message.messageId == messageId);

    if (index != null && index >= 0 && _scrollController.hasClients) {
      final position = index * 20.0;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupMessages = GroupCubit.get(context).filteredMessages[widget.groupId]?.toList();

    final Map<String, List<GroupMessage>> messagesByDate = {};
    for (final message in groupMessages ?? []) {
      final String date = getFormattedDateHeader(message.sentAt!.millisecondsSinceEpoch as int);
      if (messagesByDate.containsKey(date)) {
        messagesByDate[date]!.add(message as GroupMessage);
      } else {
        messagesByDate[date] = [message as GroupMessage];
      }
    }

    final List<MapEntry<String, List<GroupMessage>>> dateEntries = messagesByDate.entries.toList().reversed.toList();

    return Expanded(
      child: ListView.builder(
        reverse: true,
        controller: _scrollController,
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              ...messages.map((message) {
                return GroupMessagesTile(
                  key: ValueKey(message.messageId),
                  groupMessage: message,
                  onRepliedMessageTap: (messageId) {
                    _scrollToMessage(messageId);
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
