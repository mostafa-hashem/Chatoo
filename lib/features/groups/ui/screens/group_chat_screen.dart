import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_chat_messages.dart';
import 'package:chat_app/features/groups/ui/widgets/group_type_message_widget.dart';
import 'package:chat_app/features/groups/ui/widgets/message_seen_bottom_sheet.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({
    super.key,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late GroupCubit groupCubit;
  final audioPlayer = AudioPlayer();
  late Group groupData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GroupMessage? selectedMessage;
  bool isSender = false;

  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    groupCubit.filteredMessages.clear();
    groupCubit.allGroupMembers.clear();
    groupCubit.allGroupRequests.clear();
    selectedMessage = null;
    groupCubit.setRepliedMessage(null);
    super.dispose();
  }

  void onMessageSelected(GroupMessage message) {
    setState(() {
      selectedMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context);
    if (selectedMessage != null) {
      isSender = profileCubit.user.id == selectedMessage?.sender?.id;
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMessage = null;
        });
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          title: selectedMessage != null
              ? const SizedBox.shrink()
              : Row(
            children: [
              if (groupData.groupIcon!.isNotEmpty)
                ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: groupData.groupIcon!,
                    width: 40.w,
                    height: 36.h,
                    errorWidget: ClipOval(
                      child: SizedBox(
                        height: 40.h,
                        width: 40.w,
                        child: const Icon(
                          Icons.groups_outlined,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ClipOval(
                  child: SizedBox(
                    height: 40.h,
                    width: 40.w,
                    child: const Icon(
                      Icons.groups_outlined,
                      size: 35,
                    ),
                  ),
                ),
              SizedBox(
                width: 10.w,
              ),
              Flexible(
                child: Text(
                  groupData.groupName!,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            if (selectedMessage != null)
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      isSender
                          ? showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Message'),
                            content: const Text(
                              'Are you sure you want to delete this message?',
                            ),
                            actionsOverflowDirection:
                            VerticalDirection.down,
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  setState(() {
                                    selectedMessage = null;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                              BlocListener<GroupCubit, GroupStates>(
                                listener: (_, state) {
                                  if (state is DeleteMessageForAllSuccess) {}
                                },
                                child: TextButton(
                                  child:
                                  const Text('Delete for everyone'),
                                  onPressed: () {
                                    setState(() {
                                      selectedMessage = null;
                                    });
                                    GroupCubit.get(context)
                                        .deleteMessageForeAll(
                                      selectedMessage?.groupId ?? '',
                                      selectedMessage?.messageId ??
                                          '',
                                      ProfileCubit.get(context)
                                          .user
                                          .userName!,
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
                                  setState(() {
                                    selectedMessage = null;
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_forever),
                  ),
                  IconButton(
                    onPressed: () {
                      if (selectedMessage != null) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return MessageSeenBottomSheet(
                              groupMessages: selectedMessage!,
                            );
                          },
                        );
                      }
                    },
                    icon: const Icon(Icons.info),
                  ),

                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedMessage = null;
                      });
                    },
                    icon: const Icon(Icons.cancel),
                  ),
                ],
              )
            else
              BlocBuilder<GroupCubit, GroupStates>(
                buildWhen: (_, currentState) =>
                currentState is GetAllGroupRequestsSuccess ||
                    currentState is GetAllGroupRequestsError ||
                    currentState is GetAllGroupRequestsLoading,
                builder: (_, state) {
                  return Stack(
                    alignment: Alignment.topLeft,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.groupInfo,
                            arguments: groupData,
                          );
                        },
                        icon: const Icon(Icons.info),
                      ),
                      if (groupData.requests!.isNotEmpty &&
                          groupData.groupAdmins!.any(
                                (adminId) => adminId == profileCubit.user.id,
                          ))
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircleAvatar(
                            radius: 6.r,
                            backgroundColor: Colors.black,
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
        body: Column(
          children: [
            BlocConsumer<GroupCubit, GroupStates>(
              listener: (context, state) {
                if (state is GetAllGroupMembersSuccess) {
                  // audioPlayer.play(AssetSource("audios/message_received.wav"));
                  groupCubit.markMessagesAsRead(
                    groupId: groupData.groupId!,
                  );
                }
              },
              buildWhen: (_, currentState) =>
              currentState is GetAllGroupMessagesSuccess ||
                  currentState is GetAllGroupMessagesError ||
                  currentState is GetAllGroupMessagesLoading,
              builder: (_, state) {
                if (state is GetAllGroupMessagesLoading) {
                  return const LoadingIndicator();
                } else if (state is GetAllGroupMessagesError) {
                  return const LoadingIndicator();
                } else {
                  return GroupChatMessages(
                    groupId: groupData.groupId ?? '',
                    onMessageSelected: onMessageSelected,
                  );
                }
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            GroupTypeMessageWidget(
              groupData: groupData,
            ),
          ],
        ),
      ),
    );
  }
}
