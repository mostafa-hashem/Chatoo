import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_messages_tile.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupChatMessages extends StatefulWidget {
  final String groupId;
  final Function(GroupMessage) onMessageSelected;

  const GroupChatMessages({
    super.key,
    required this.groupId,
    required this.onMessageSelected,
  });

  @override
  State<GroupChatMessages> createState() => _GroupChatMessagesState();
}

class _GroupChatMessagesState extends State<GroupChatMessages> {
  late GroupCubit _groupCubit;

  @override
  void didChangeDependencies() {
    _groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
  }

  void _scrollToMessage(String messageId) {
    final groupMessages = _groupCubit.filteredMessages[widget.groupId]?.toList();
    final index = groupMessages?.indexWhere((message) => message.messageId == messageId);

    if (index != null && index >= 0 && _groupCubit.scrollController.hasClients) {
      final position = index * 60.0;
      _groupCubit.scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupMessages = GroupCubit.get(context).filteredMessages[widget.groupId]?.toList();

    if (groupMessages == null || groupMessages.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No messages at this moment',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final Map<String, List<GroupMessage>> messagesByDate = {};
    for (final message in groupMessages) {
      final String date = getFormattedDateHeader(message.sentAt!.millisecondsSinceEpoch);
      if (messagesByDate.containsKey(date)) {
        messagesByDate[date]!.add(message);
      } else {
        messagesByDate[date] = [message];
      }
    }

    final List<MapEntry<String, List<GroupMessage>>> dateEntries = messagesByDate.entries.toList().reversed.toList();

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
                  onMessageSelected: () {
                    widget.onMessageSelected(message);
                  },
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
