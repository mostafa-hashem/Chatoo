import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_messages_tile.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendChatMessages extends StatefulWidget {
  final String friendName;

  FriendChatMessages({super.key, required this.friendName});

  @override
  State<FriendChatMessages> createState() => _FriendChatMessagesState();
}

class _FriendChatMessagesState extends State<FriendChatMessages> {
  @override
  Widget build(BuildContext context) {
    final friendMessages = FriendCubit.get(context).filteredMessages.reversed.toList();

    final Map<String, List<FriendMessage>> messagesByDate = {};
    for (final message in friendMessages) {
      final String date = getFormattedDateHeader(message.sentAt!.millisecondsSinceEpoch);
      if (messagesByDate.containsKey(date)) {
        messagesByDate[date]!.add(message);
      } else {
        messagesByDate[date] = [message];
      }
    }

    final List<MapEntry<String, List<FriendMessage>>> dateEntries = messagesByDate.entries.toList().reversed.toList();


    return Expanded(
      child: ListView.builder(
        reverse: true,
        controller: FriendCubit.get(context).scrollController,
        itemCount: dateEntries.length,
        itemBuilder: (_, index) {
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
                return FriendMessagesTile(
                  friendMessage: message,
                  sentByMe: ProfileCubit.get(context).user.id == message.sender,
                  friendName: widget.friendName,
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
