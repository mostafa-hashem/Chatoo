import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMessagesTile extends StatefulWidget {
  final bool sentByMe;
  final GroupMessage groupMessage;
  final String groupId;
  final bool isAction;

  const GroupMessagesTile({
    super.key,
    required this.sentByMe,
    required this.groupMessage,
    required this.groupId,
    required this.isAction,
  });

  @override
  State<GroupMessagesTile> createState() => _GroupMessagesTileState();
}

class _GroupMessagesTileState extends State<GroupMessagesTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        widget.isAction
            ? const SizedBox.shrink()
            : widget.sentByMe
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
                              if (state is DeleteMessageForAllSuccess) {
                              }
                            },
                            child: TextButton(
                              child: const Text('Delete for everyone'),
                              onPressed: () {
                                GroupCubit.get(context)
                                    .deleteMessageForeAll(
                                      widget.groupId,
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
      child: widget.isAction
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
                    left: widget.sentByMe ? 0 : 15,
                    right: widget.sentByMe ? 15 : 0,
                  ),
                  alignment: widget.sentByMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: widget.sentByMe
                        ? const EdgeInsets.only(left: 30)
                        : const EdgeInsets.only(right: 30),
                    padding: widget.sentByMe
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
                      borderRadius: widget.sentByMe
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
                      color: widget.sentByMe
                          ? const Color(0xffecae7d)
                          : const Color(0xff8db4ad),
                    ),
                    child: Column(
                      crossAxisAlignment: widget.sentByMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.groupMessage.sender!.userName!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8.sp,
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
                            widget.groupMessage.sentAt!.millisecondsSinceEpoch,
                          ),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
