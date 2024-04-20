import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_chat_messages.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({
    super.key,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  TextEditingController messageController = TextEditingController();

  bool emojiShowing = false;
  late Group groupData;
  late GroupCubit groupCubit;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    groupCubit.filteredGroups.clear();
    super.deactivate();
  }

  void _onBackspacePressed() {
    messageController
      ..text = messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length),
      );
  }

  void scrollToBottom() {
    GroupCubit.get(context).scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    final sender = ProfileCubit.get(context).user;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: [
              if (groupData.groupIcon.isNotEmpty)
                ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: groupData.groupIcon,
                    width: 40.w,
                    height: 36.h,
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
              Text(
                groupData.groupName,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                groupCubit.getAllGroupMembers(groupData.groupId);
                groupCubit.getAdminName(groupData.adminId);
                Navigator.pushNamed(
                  context,
                  Routes.groupInfo,
                  arguments: groupData,
                );
              },
              icon: const Icon(Icons.info),
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<GroupCubit, GroupStates>(
              builder: (context, state) {
                return ChatMessages(
                  groupId: groupData.groupId,
                );
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
              height: 60.h,
              color: Colors.grey[600],
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          emojiShowing = !emojiShowing;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: TextField(
                        controller: messageController,
                        textInputAction: TextInputAction.newline,
                        maxLines: 20,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: provider.themeMode == ThemeMode.light
                              ? Colors.black87
                              : AppColors.light,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: Theme.of(context).textTheme.bodySmall,
                          filled: true,
                          fillColor: provider.themeMode == ThemeMode.light
                              ? Colors.white
                              : AppColors.dark,
                          contentPadding: const EdgeInsets.only(
                            left: 16.0,
                            bottom: 8.0,
                            top: 8.0,
                            right: 16.0,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () async {
                        if (messageController.text.isNotEmpty) {
                          GroupCubit.get(context)
                              .sendMessageToGroup(
                            group: groupData,
                            sender: sender,
                            message: messageController.text,
                            leave: false,
                            joined: false,
                          )
                              .whenComplete(() {
                            scrollToBottom();
                            final List<dynamic> memberIds =
                                groupData.members!.toList();
                            int completedOperations = 0;
                            for (final memberId in memberIds) {
                              if (memberId ==
                                  ProfileCubit.get(context).user.id) {
                                continue;
                              }
                              groupCubit
                                  .getUserData(memberId.toString())
                                  .whenComplete(
                                () {
                                  NotificationsCubit.get(context)
                                      .sendNotification(
                                    groupCubit.userData!.fCMToken!,
                                    'New Messages in ${groupData.groupName}',
                                    "${ProfileCubit.get(context).user.userName}: \n${messageController.text}",
                                  );
                                  if (completedOperations ==
                                      memberIds.length - 1) {
                                    Future.delayed(
                                      const Duration(milliseconds: 15),
                                      () => messageController.clear(),
                                    );
                                  }
                                },
                              );
                              completedOperations++;
                            }
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: !emojiShowing,
              child: SizedBox(
                height: 220.h,
                child: EmojiPicker(
                  textEditingController: messageController,
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                    emojiSizeMax: 30 *
                        (foundation.defaultTargetPlatform == TargetPlatform.iOS
                            ? 1.30
                            : 1.0),
                    bgColor: provider.themeMode == ThemeMode.light
                        ? const Color(0xFFF2F2F2)
                        : AppColors.dark,
                    indicatorColor: AppColors.primary,
                    iconColorSelected: AppColors.primary,
                    backspaceColor: AppColors.primary,
                    noRecents: Text(
                      'No Resents',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
