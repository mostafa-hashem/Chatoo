import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/widgets/image_widget.dart';
import 'package:chat_app/ui/widgets/record_tile.dart';
import 'package:chat_app/ui/widgets/video_widget.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendMessagesTile extends StatefulWidget {
  final bool sentByMe;
  final FriendMessage friendMessage;
  final String friendName;

  const FriendMessagesTile({
    super.key,
    required this.friendMessage,
    required this.sentByMe,
    required this.friendName,
  });

  @override
  State<FriendMessagesTile> createState() => _FriendMessagesTileState();
}

class _FriendMessagesTileState extends State<FriendMessagesTile> {
  @override
  void didChangeDependencies() {
    widget.friendMessage.messageType ??= MessageType.text;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context).user;
    final friendCubit = FriendCubit.get(context);
    final bool isSender = widget.sentByMe;
    final EdgeInsetsGeometry messagePadding = isSender
        ? EdgeInsets.only(top: 4.h, bottom: 4.h, left: 0.w, right: 15.w)
        : EdgeInsets.only(top: 4.h, bottom: 4.h, left: 15.w, right: 0.w);
    final EdgeInsetsGeometry messageMargin =
        isSender ? EdgeInsets.only(left: 30.w) : EdgeInsets.only(right: 30.w);
    final EdgeInsetsGeometry containerPadding =
        EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w);

    return InkWell(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Message'),
              content:
                  const Text('Are you sure you want to delete this message?'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Delete for me'),
                  onPressed: () {
                    friendCubit
                        .deleteMessageForMe(
                          widget.friendMessage.friendId,
                          widget.friendMessage.messageId,
                          profileCubit.id!,
                          profileCubit.userName!,
                          widget.friendName,
                        )
                        .whenComplete(() => Navigator.pop(context));
                  },
                ),
                if (isSender)
                  TextButton(
                    child: const Text('Delete for everyone'),
                    onPressed: () {
                      friendCubit
                          .deleteMessageForAll(
                            widget.friendMessage.friendId,
                            widget.friendMessage.messageId,
                            profileCubit.id!,
                            profileCubit.userName!,
                            widget.friendName,
                          )
                          .whenComplete(() => Navigator.pop(context));
                    },
                  ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: messagePadding,
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: messageMargin,
          padding: containerPadding,
          decoration: BoxDecoration(
            borderRadius: isSender
                ? BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(20.r),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                    bottomRight: Radius.circular(20.r),
                  ),
            color: isSender ? const Color(0xffecae7d) : const Color(0xff8db4ad),
          ),
          child: _buildMessageContent(context, isSender),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isSender) {
    switch (widget.friendMessage.messageType!) {
      case MessageType.text:
        return Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              widget.friendMessage.message,
              style: TextStyle(fontSize: 15.sp, color: Colors.white),
            ),
            SizedBox(height: 5.h),
            Text(
              getFormattedTime(
                widget.friendMessage.sentAt!.millisecondsSinceEpoch,
              ),
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case MessageType.image:
        return ImageWidget(
          imagePath: widget.friendMessage.mediaUrls?.first ?? '',
          sentAt: widget.friendMessage.sentAt!.millisecondsSinceEpoch,
          senderName: '',
          senderId: widget.friendMessage.sender,
          isInGroup: false,
        );
      case MessageType.video:
        return VideoWidget(
          videoPath: widget.friendMessage.mediaUrls?.first ?? '',
          sentAt: widget.friendMessage.sentAt!.millisecondsSinceEpoch,
          senderName: '',
          senderId: widget.friendMessage.sender,
          isInGroup: false,
        );
      case MessageType.record:
        return RecordTile(
          recordPath: widget.friendMessage.mediaUrls?.first ?? '',
          sentAt: widget.friendMessage.sentAt!.millisecondsSinceEpoch,
          senderName: '',
          senderId: widget.friendMessage.sender,
          isInGroup: false,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
