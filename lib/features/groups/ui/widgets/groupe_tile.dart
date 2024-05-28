import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupTile extends StatefulWidget {
  const GroupTile({
    super.key,
    required this.userName,
    required this.groupData,
    required this.isLeftOrJoined,
  });

  final String userName;
  final Group groupData;
  final bool isLeftOrJoined;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  late ProfileCubit profileCubit;
  late GroupCubit groupCubit;
  final GlobalKey listTileKey = GlobalKey();

  @override
  void didChangeDependencies() {
    profileCubit = ProfileCubit.get(context);
    groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMuted = groupCubit.mutedGroups
        .any((groupId) => groupId == widget.groupData.groupId);
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (_, current) =>
          current is GetUserSuccess ||
          current is GetUserError ||
          current is ProfileLoading,
      builder: (_, state) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: ListTile(
            key: listTileKey,
            leading: widget.groupData.groupIcon!.isEmpty
                ? CircleAvatar(
                    radius: 26.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.groupData.groupName!.substring(0, 1).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () =>
                        showImageDialog(context, widget.groupData.groupIcon!),
                    child: ClipOval(
                      child: FancyShimmerImage(
                        imageUrl: widget.groupData.groupIcon!,
                        width: 50.w,
                        height: 50.w,
                        errorWidget: CircleAvatar(
                          radius: 26.r,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            widget.groupData.groupName!
                                .substring(0, 1)
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            title: Row(
              children: [
                Text(
                  widget.groupData.groupName!,
                  style: GoogleFonts.novaSquare(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  widget.groupData.recentMessageSentAt != null
                      ? getFormattedTime(
                          widget.groupData.recentMessageSentAt!
                              .millisecondsSinceEpoch,
                        )
                      : '',
                  style: GoogleFonts.novaSquare(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.groupData.recentMessage!.isNotEmpty
                        ? "${widget.groupData.recentMessageSenderId == profileCubit.user.id ? 'You' : widget.groupData.recentMessageSender}: ${widget.groupData.recentMessage ?? ''}"
                        : '',
                    style: GoogleFonts.ubuntu(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                if (widget.groupData.unreadMessageCounts != null &&
                    widget.groupData.unreadMessageCounts![profileCubit.user.id] != null &&
                    widget.groupData.unreadMessageCounts![profileCubit.user.id] as int > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Text(
                      "${widget.groupData.unreadMessageCounts![profileCubit.user.id]}",
                      style: GoogleFonts.novaSquare(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            trailing: isMuted
                ? Icon(
                    Icons.notifications_off,
                    color: AppColors.primary,
                    size: 20.sp,
                  )
                : const SizedBox.shrink(),
            onTap: () {
              Future.wait([
                groupCubit.getAllGroupMembers(
                  widget.groupData.groupId!,
                ),
                groupCubit.markMessagesAsRead(
                  groupId: widget.groupData.groupId!,
                ),
                groupCubit.getAllGroupMessages(
                  widget.groupData.groupId!,
                ),
              ]);

              Future.delayed(
                const Duration(
                  milliseconds: 50,
                ),
                () => Navigator.pushNamed(
                  context,
                  Routes.groupChatScreen,
                  arguments: widget.groupData,
                ),
              );
            },
            onLongPress: () {
              showMenu(
                context: context,
                position: RelativeRect.fromRect(
                  getWidgetPosition(listTileKey),
                  Offset.zero & MediaQuery.of(context).size,
                ),
                items: [
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        isMuted
                            ? groupCubit
                                .unMuteGroup(widget.groupData.groupId ?? '')
                            : groupCubit
                                .muteGroup(widget.groupData.groupId ?? '');
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child:
                          isMuted ? const Text('Un Mute') : const Text('Mute'),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: const Text(
                                "Are you sure you want leave the group?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                BlocListener<GroupCubit, GroupStates>(
                                  listener: (_, state) {
                                    if (state is DeleteGroupLoading) {
                                      const LoadingIndicator();
                                    } else {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                      if (state is DeleteGroupSuccess) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          Routes.layout,
                                        );
                                      }
                                      if (state is DeleteGroupError) {
                                        const ErrorIndicator();
                                      }
                                    }
                                  },
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text("Leave"),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Leave group'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
