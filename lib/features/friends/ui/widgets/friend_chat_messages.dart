import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/data/model/combined_friend.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_messages_tile.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendChatMessages extends StatefulWidget {
  final CombinedFriend friendData;

  FriendChatMessages({super.key, required this.friendData});

  @override
  State<FriendChatMessages> createState() => _FriendChatMessagesState();
}

class _FriendChatMessagesState extends State<FriendChatMessages> {
  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context);
    final friendMessages = FriendCubit.get(context)
        .filteredMessages[widget.friendData.user?.id ?? '']
        ?.reversed
        .toList();

    final Map<String, List<FriendMessage>> messagesByDate = {};
    for (final message in friendMessages ?? []) {
      final String date =
          getFormattedDateHeader(message.sentAt!.millisecondsSinceEpoch as int);
      if (messagesByDate.containsKey(date)) {
        messagesByDate[date]!.add(message as FriendMessage);
      } else {
        messagesByDate[date] = [message as FriendMessage];
      }
    }

    final List<MapEntry<String, List<FriendMessage>>> dateEntries =
        messagesByDate.entries.toList().reversed.toList();

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
                return Column(
                  children: [
                    FriendMessagesTile(
                      friendMessage: message,
                      sentByMe: profileCubit.user.id == message.sender,
                      friendName: widget.friendData.user?.userName ?? '',
                    ),
                    if (widget.friendData.recentMessageData.seen != null &&
                        widget.friendData.recentMessageData.seen! &&
                        profileCubit.user.id ==
                            widget.friendData.recentMessageData
                                .recentMessageSenderId &&
                        message.sentAt ==
                            widget.friendData.recentMessageData.sentAt)
                      Padding(
                        padding: EdgeInsets.only(right: 22.w),
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Seen ✓✓",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 8.sp),
                            )),
                      ),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
