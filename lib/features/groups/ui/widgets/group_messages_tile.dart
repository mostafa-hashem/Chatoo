import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/image_widget.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMessagesTile extends StatefulWidget {
  final GroupMessage groupMessage;

  const GroupMessagesTile({
    super.key,
    required this.groupMessage,
  });

  @override
  State<GroupMessagesTile> createState() => _GroupMessagesTileState();
}

class _GroupMessagesTileState extends State<GroupMessagesTile> {
  @override
  void didChangeDependencies() {
    widget.groupMessage.messageType ??= MessageType.text;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        widget.groupMessage.isAction!
            ? const SizedBox.shrink()
            : ProfileCubit.get(context).user.id ==
                    widget.groupMessage.sender!.id
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
                                      ProfileCubit.get(context).user.userName!,
                                    )
                                    .whenComplete(
                                      () => Navigator.pop(context),
                                    );
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
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          : Container(
              padding: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: ProfileCubit.get(context).user.id ==
                        widget.groupMessage.sender!.id
                    ? 0
                    : 15,
                right: ProfileCubit.get(context).user.id ==
                        widget.groupMessage.sender!.id
                    ? 15
                    : 0,
              ),
              alignment: ProfileCubit.get(context).user.id ==
                      widget.groupMessage.sender!.id
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: ProfileCubit.get(context).user.id ==
                        widget.groupMessage.sender!.id
                    ? const EdgeInsets.only(left: 30)
                    : const EdgeInsets.only(right: 30),
                padding: ProfileCubit.get(context).user.id ==
                        widget.groupMessage.sender!.id
                    ? const EdgeInsets.only(
                        top: 12,
                        bottom: 12,
                        left: 15,
                        right: 15,
                      )
                    : const EdgeInsets.only(
                        top: 15,
                        bottom: 15,
                        left: 15,
                        right: 15,
                      ),
                decoration: BoxDecoration(
                  borderRadius: ProfileCubit.get(context).user.id ==
                          widget.groupMessage.sender!.id
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
                  color: ProfileCubit.get(context).user.id ==
                          widget.groupMessage.sender!.id
                      ? const Color(0xffecae7d)
                      : const Color(0xff8db4ad),
                ),
                child: widget.groupMessage.messageType! == MessageType.text
                    ? Column(
                        crossAxisAlignment: ProfileCubit.get(context).user.id ==
                                widget.groupMessage.sender!.id
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.groupMessage.sender!.userName!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Text(
                            widget.groupMessage.message!,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Text(
                            getFormattedTime(
                              widget
                                  .groupMessage.sentAt!.millisecondsSinceEpoch,
                            ),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : ImageWidget(
                        imagePath: widget.groupMessage.mediaUrls?.first ?? '',
                        sentAt: widget
                                .groupMessage.sentAt?.millisecondsSinceEpoch ??
                            DateTime.now().millisecondsSinceEpoch,
                        senderName: widget.groupMessage.sender?.userName ?? '',
                        senderId: widget.groupMessage.sender?.id ?? '',
                        isInGroup: true,
                      ),
              ),
            ),
    );
  }
}
