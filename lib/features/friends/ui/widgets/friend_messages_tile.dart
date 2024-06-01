import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/widgets/image_widget.dart';
import 'package:chat_app/ui/widgets/record_tile.dart';
import 'package:chat_app/ui/widgets/video_widget.dart';
import 'package:chat_app/utils/data/models/audio_manager.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

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
  AudioManager audioManager = AudioManager();
  late User profileCubit;
  late FriendCubit friendCubit;
  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileCubit = ProfileCubit.get(context).user;
    friendCubit = FriendCubit.get(context);
    widget.friendMessage.messageType ??= MessageType.text;
  }

  void _checkTextDirection(String text) {
    if (text.isNotEmpty && isArabic(text)) {
      setState(() {
        _textAlign = TextAlign.right;
        _textDirection = TextDirection.rtl;
      });
    } else {
      setState(() {
        _textAlign = TextAlign.left;
        _textDirection = TextDirection.ltr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSender = widget.sentByMe;
    final EdgeInsetsGeometry messagePadding = isSender
        ? EdgeInsets.only(top: 4.h, bottom: 4.h, left: 0.w, right: 15.w)
        : EdgeInsets.only(top: 4.h, bottom: 4.h, left: 15.w, right: 0.w);
    final EdgeInsetsGeometry messageMargin =
        isSender ? EdgeInsets.only(left: 30.w) : EdgeInsets.only(right: 30.w);
    final EdgeInsetsGeometry containerPadding =
        EdgeInsets.symmetric(vertical: 8.h, horizontal: 15.w);

    final messageText = widget.friendMessage.message;
    _checkTextDirection(messageText);

    return InkWell(
      onDoubleTap: () {
        friendCubit.setRepliedMessage(widget.friendMessage);
      },
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
        padding: widget.friendMessage.messageType == MessageType.record
            ? null
            : messagePadding,
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: messageMargin,
          padding: containerPadding,
          decoration: widget.friendMessage.messageType == MessageType.record
              ? null
              : BoxDecoration(
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
                  color: isSender
                      ? const Color(0xffecae7d)
                      : const Color(0xff8db4ad),
                ),
          child: _buildMessageContent(context, isSender),
        ),
      ),
    );
  }

  TextAlign _replayedTextAlign = TextAlign.left;
  TextDirection _replayedTextDirection = TextDirection.ltr;

  void _checkReplayedMessageDirection(String text) {
    if (text.isNotEmpty && isArabic(text)) {
      setState(() {
        _replayedTextAlign = TextAlign.right;
        _replayedTextDirection = TextDirection.rtl;
      });
    } else {
      setState(() {
        _replayedTextAlign = TextAlign.left;
        _replayedTextDirection = TextDirection.ltr;
      });
    }
  }

  Widget _buildMessageContent(BuildContext context, bool isSender) {
    _checkReplayedMessageDirection(
      widget.friendMessage.repliedMessage?.message ?? '',
    );
    switch (widget.friendMessage.messageType!) {
      case MessageType.text:
        final bool isLink = containsLink(widget.friendMessage.message);
        return Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (widget.friendMessage.repliedMessage != null)
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.friendMessage.repliedMessage!.message,
                        textDirection: _replayedTextDirection,
                        textAlign: _replayedTextAlign,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            GestureDetector(
              onTap: isLink
                  ? () async {
                      if (await canLaunchUrl(
                        Uri.parse(widget.friendMessage.message),
                      )) {
                        await launchUrl(
                          Uri.parse(widget.friendMessage.message),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        throw 'Could not launch ${widget.friendMessage.message}';
                      }
                    }
                  : null,
              child: Text(
                widget.friendMessage.message,
                textDirection: _textDirection,
                textAlign: _textAlign,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isLink ? Colors.blue : Colors.white,
                  decoration:
                      isLink ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              getFormattedTime(
                widget.friendMessage.sentAt!.toLocal().millisecondsSinceEpoch,
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
          sentAt: widget.friendMessage.sentAt!.toLocal().millisecondsSinceEpoch,
          senderName: '',
          senderId: widget.friendMessage.sender,
          isInGroup: false,
        );
      case MessageType.video:
        return VideoWidget(
          videoPath: widget.friendMessage.mediaUrls?.first ?? '',
          sentAt: widget.friendMessage.sentAt!.toLocal().millisecondsSinceEpoch,
          senderName: '',
          senderId: widget.friendMessage.sender,
          isInGroup: false,
        );
      case MessageType.record:
        return RecordTile(
          recordPath: widget.friendMessage.mediaUrls?.first ?? '',
          sentAt: widget.friendMessage.sentAt!.toLocal().millisecondsSinceEpoch,
          senderName: '',
          senderId: widget.friendMessage.sender,
          isInGroup: false,
          audioManager: audioManager,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
