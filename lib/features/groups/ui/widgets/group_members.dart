import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMembers extends StatefulWidget {
  // Note: Avoid using `const` with constructors.
  GroupMembers({
    required this.group,
    super.key,
  });

  final Group group;

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  @override
  Widget build(BuildContext context) {
    final groupCubit = GroupCubit.get(context);
    final profileCubit = ProfileCubit.get(context);
    final friendCubit = FriendCubit.get(context);
    final notificationCubit = NotificationsCubit.get(context);
    return ListView.builder(
      itemCount: groupCubit.allGroupMembers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final GlobalKey listTileKey = GlobalKey();
        return InkWell(
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
                      if (widget.group.members![index] ==
                          profileCubit.user.id) {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        Navigator.pushNamed(context, Routes.profile);
                      } else {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                        Navigator.pushNamed(
                          context,
                          Routes.friendInfoScreen,
                          arguments: groupCubit.allGroupMembers[index],
                        );
                      }
                    },
                    child: const Text('View profile'),
                  ),
                ),
                if (widget.group.members![index] != profileCubit.user.id)
                  PopupMenuItem(
                    child: BlocListener<FriendCubit, FriendStates>(
                      listener: (context, state) {
                        if (state is RequestToAddFriendSuccess) {
                          showSnackBar(
                            context,
                            Colors.green,
                            "Requested successfully",
                          );
                          notificationCubit.sendNotification(
                            groupCubit.allGroupMembers[index]!.fCMToken!,
                            "${profileCubit.user.userName}",
                            "Friend request",
                            'friend',
                          );
                        }
                        if (state is RemoveFriendSuccess) {
                          showSnackBar(
                            context,
                            Colors.green,
                            "Friend removed successfully",
                          );
                        }
                      },
                      child: TextButton(
                        onPressed: () {
                          friendCubit.allFriends.any(
                            (friend) =>
                                friend?.id ==
                                groupCubit.allGroupMembers[index]!.id,
                          )
                              ? friendCubit.removeFriend(
                                  groupCubit.allGroupMembers[index]!.id!,
                                )
                              : friendCubit.requestToAddFriend(
                                  groupCubit.allGroupMembers[index]!.id!,
                                );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: friendCubit.allFriends.any(
                          (friend) =>
                              friend?.id ==
                              groupCubit.allGroupMembers[index]!.id,
                        )
                            ? const Text('Remove friend')
                            : const Text('Send friend request'),
                      ),
                    ),
                  ),
                if (groupCubit.allGroupMembers[index]!.id !=
                        widget.group.mainAdminId &&
                    !widget.group.groupAdmins!.any(
                      (adminId) =>
                          adminId == groupCubit.allGroupMembers[index]!.id,
                    ))
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        groupCubit
                            .makeAsAdmin(
                          widget.group.groupId!,
                          groupCubit.allGroupMembers[index]!.id!,
                        )
                            .whenComplete(
                          () {
                            groupCubit.getAllUserGroups();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                      child: const Text('Make as admin'),
                    ),
                  ),
                if (groupCubit.allGroupMembers[index]!.id !=
                        widget.group.mainAdminId &&
                    widget.group.groupAdmins!.any(
                      (adminId) =>
                          adminId == groupCubit.allGroupMembers[index]!.id,
                    ))
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        groupCubit
                            .removeFromAdmins(
                          widget.group.groupId!,
                          groupCubit.allGroupMembers[index]!.id!,
                        )
                            .whenComplete(
                          () {
                            groupCubit.getAllUserGroups();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                      child: const Text('Remove from admins'),
                    ),
                  ),
                if (widget.group.groupAdmins!.any(
                      (adminId) => adminId == profileCubit.user.id,
                    ) &&
                    widget.group.members![index] != profileCubit.user.id &&
                    widget.group.members![index] != widget.group.mainAdminId)
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        groupCubit
                            .kickUserFromGroup(
                          widget.group.groupId!,
                          groupCubit.allGroupMembers[index]!.id!,
                        )
                            .whenComplete(
                          () {
                            groupCubit.sendMessageToGroup(
                              group: widget.group,
                              sender: profileCubit.user,
                              message:
                                  '${profileCubit.user.userName!} kick ${groupCubit.allGroupMembers[index]!.userName}',
                              leave: true,
                              joined: false,
                              requested: false,
                              declined: false,
                            );
                            groupCubit
                                .getAllGroupMembers(widget.group.groupId!);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        );
                      },
                      child: const Text('Kick'),
                    ),
                  ),
              ],
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    key: listTileKey,
                    leading: groupCubit.allGroupMembers[index]!.profileImage !=
                                null ||
                            groupCubit.allGroupMembers[index]!.profileImage!
                                .isNotEmpty
                        ? InkWell(
                            onTap: () => showImageDialog(
                              context,
                              groupCubit.allGroupMembers[index]!.profileImage!,
                            ),
                            child: FancyShimmerImage(
                              imageUrl: groupCubit
                                  .allGroupMembers[index]!.profileImage!,
                              height: 40.h,
                              width: 40.w,
                              boxFit: BoxFit.contain,
                              errorWidget: const Icon(
                                Icons.error_outline_outlined,
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 25.r,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              groupCubit.allGroupMembers[index]!.userName!
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    title: Text(
                      groupCubit.allGroupMembers[index]!.userName!,
                      style: GoogleFonts.alexandria(fontSize: 14.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "Bio: ${groupCubit.allGroupMembers[index]!.bio}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Visibility(
                      visible: widget.group.groupAdmins!.any(
                        (adminId) =>
                            adminId == groupCubit.allGroupMembers[index]!.id,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                        child: Text(
                          widget.group.mainAdminId ==
                                  groupCubit.allGroupMembers[index]!.id
                              ? 'Owner'
                              : 'Group Admin',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
