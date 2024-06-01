import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/image_widget.dart';
import 'package:chat_app/ui/widgets/record_tile.dart';
import 'package:chat_app/ui/widgets/video_widget.dart';
import 'package:chat_app/utils/data/models/audio_manager.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupMessagesTile extends StatefulWidget {
  final GroupMessage groupMessage;
  final Function(GroupMessage)? onSwipe;
  final Function(String)? onRepliedMessageTap;

  const GroupMessagesTile({
    super.key,
    required this.groupMessage,
    this.onSwipe,
    this.onRepliedMessageTap,
  });

  @override
  State<GroupMessagesTile> createState() => _GroupMessagesTileState();
}

class _GroupMessagesTileState extends State<GroupMessagesTile> {
  AudioManager audioManager = AudioManager();
  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;

  late GroupCubit groupCubit;

  @override
  void didChangeDependencies() {
    widget.groupMessage.messageType ??= MessageType.text;
    groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
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
    final bool isSender =
        ProfileCubit.get(context).user.id == widget.groupMessage.sender!.id;
    final EdgeInsetsGeometry messagePadding = isSender
        ? EdgeInsets.only(top: 6.h, bottom: 2.h, right: 15.w)
        : EdgeInsets.only(top: 4, bottom: 4, left: 15.w);
    final EdgeInsetsGeometry messageMargin =
        isSender ? EdgeInsets.only(left: 30.w) : EdgeInsets.only(right: 30.w);
    final EdgeInsetsGeometry containerPadding =
        EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w);
    final messageText = widget.groupMessage.message;
    _checkTextDirection(messageText!);

    return BlocListener<GroupCubit, GroupStates>(
      listener: (_, state) {
        if (state is SetRepliedMessageSuccess) {}
      },
      child: InkWell(
        onDoubleTap: () {
          groupCubit.setRepliedMessage(widget.groupMessage);
        },
        onLongPress: () {
          widget.groupMessage.isAction!
              ? const SizedBox.shrink()
              : isSender
                  ? showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Message'),
                          content: const Text(
                            'Are you sure you want to delete this message?',
                          ),
                          actionsOverflowDirection: VerticalDirection.down,
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            BlocListener<GroupCubit, GroupStates>(
                              listener: (_, state) {
                                if (state is DeleteMessageForAllSuccess) {}
                              },
                              child: TextButton(
                                child: const Text('Delete for everyone'),
                                onPressed: () {
                                  GroupCubit.get(context)
                                      .deleteMessageForeAll(
                                        widget.groupMessage.groupId!,
                                        widget.groupMessage.messageId!,
                                        ProfileCubit.get(context)
                                            .user
                                            .userName!,
                                      )
                                      .whenComplete(
                                          () => Navigator.pop(context),);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: const Text('Delete Message'),
                          content: const Text(
                            "Sorry you cannot delete other people's messages till now",
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
        },
        child: widget.groupMessage.isAction!
            ? Padding(
                padding: const EdgeInsets.all(6.0),
                child: Center(
                  child: Text(
                    widget.groupMessage.message!,
                    style: GoogleFonts.alexandria(
                      fontSize: 12.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              )
            : Container(
                padding: widget.groupMessage.messageType == MessageType.record
                    ? null
                    : messagePadding,
                alignment:
                    isSender ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: messageMargin,
                  padding: containerPadding,
                  decoration:
                      widget.groupMessage.messageType == MessageType.record
                          ? null
                          : BoxDecoration(
                              borderRadius: isSender
                                  ? const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                    )
                                  : const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                              color: isSender
                                  ? const Color(0xffecae7d)
                                  : const Color(0xff8db4ad),
                            ),
                  child: _buildMessageContent(context, isSender),
                ),
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
        widget.groupMessage.repliedMessage?.message ?? '',);
    switch (widget.groupMessage.messageType!) {
      case MessageType.text:
        final bool isLink = containsLink(widget.groupMessage.message!);
        return Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (widget.groupMessage.repliedMessage != null)
              GestureDetector(
                onTap: () {
                  widget.onRepliedMessageTap
                      ?.call(widget.groupMessage.repliedMessage!.messageId!);
                },
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
                        widget.groupMessage.repliedMessage!.sender?.userName ??
                            'UnKnown',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12.sp,),
                      ),
                      Text(
                        '${widget.groupMessage.repliedMessage!.message}',
                        textDirection: _replayedTextDirection,
                        textAlign: _replayedTextAlign,
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12.sp,),
                      ),
                    ],
                  ),
                ),
              ),
            GestureDetector(
              onTap: isLink
                  ? () async {
                      if (await canLaunchUrl(
                        Uri.parse(widget.groupMessage.message!),
                      )) {
                        await launchUrl(
                          Uri.parse(widget.groupMessage.message!),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        throw 'Could not launch ${widget.groupMessage.message}';
                      }
                    }
                  : null,
              child: Text(
                widget.groupMessage.message!,
                textAlign: _textAlign,
                textDirection: _textDirection,
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
                widget.groupMessage.sentAt!.millisecondsSinceEpoch,
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
          imagePath: widget.groupMessage.mediaUrls?.first ?? '',
          sentAt:
              widget.groupMessage.sentAt?.toLocal().millisecondsSinceEpoch ??
                  DateTime.now().millisecondsSinceEpoch,
          senderName: widget.groupMessage.sender?.userName ?? '',
          senderId: widget.groupMessage.sender?.id ?? '',
          isInGroup: true,
        );
      case MessageType.video:
        return VideoWidget(
          videoPath: widget.groupMessage.mediaUrls?.first ?? '',
          sentAt:
              widget.groupMessage.sentAt?.toLocal().millisecondsSinceEpoch ??
                  DateTime.now().millisecondsSinceEpoch,
          senderName: widget.groupMessage.sender?.userName ?? '',
          senderId: widget.groupMessage.sender?.id ?? '',
          isInGroup: true,
        );
      case MessageType.record:
        return RecordTile(
          recordPath: widget.groupMessage.mediaUrls?.first ?? '',
          sentAt:
              widget.groupMessage.sentAt?.toLocal().millisecondsSinceEpoch ??
                  DateTime.now().millisecondsSinceEpoch,
          senderName: widget.groupMessage.sender?.userName ?? '',
          senderId: widget.groupMessage.sender?.id ?? '',
          isInGroup: true,
          audioManager: audioManager,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
