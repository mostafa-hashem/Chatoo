import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFriendToGroupTile extends StatefulWidget {
  // Note: Avoid using `const` with constructors.
  const AddFriendToGroupTile({
    required this.friendData,
    required this.groupData,
    super.key,
  });

  final User friendData;
  final Group groupData;

  @override
  State<AddFriendToGroupTile> createState() => _AddFriendToGroupTileState();
}

class _AddFriendToGroupTileState extends State<AddFriendToGroupTile> {
  @override
  Widget build(BuildContext context) {
    final notificationCubit = NotificationsCubit.get(context);
    final groupCubit = GroupCubit.get(context);
    final profileCubit = ProfileCubit.get(context);
    final friendFcmToken = widget.friendData.fCMToken!;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              Routes.friendInfoScreen,
              arguments: widget.friendData,
            ),
            child: ListTile(
              leading: widget.friendData.profileImage != null ||
                      widget.friendData.profileImage!.isNotEmpty
                  ? InkWell(
                      onTap: () => showImageDialog(
                        context,
                        widget.friendData.profileImage!,
                      ),
                      child: FancyShimmerImage(
                        imageUrl: widget.friendData.profileImage!,
                        height: 44.h,
                        width: 44.w,
                        boxFit: BoxFit.contain,
                        errorWidget: const Icon(
                          Icons.error_outline_outlined,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 28.r,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        widget.friendData.userName!
                            .substring(0, 1)
                            .toUpperCase(),
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
              title: Text(
                widget.friendData.userName!,
                style: GoogleFonts.alexandria(fontSize: 14.sp),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "Bio: ${widget.friendData.bio}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          SizedBox(
            height: 18.h,
          ),
          Row(
            children: [
              const Spacer(),
              InkWell(
                onTap: () {
                  if (widget.groupData.requests!.any(
                    (requesterId) => requesterId == widget.friendData.id,
                  )) {
                    return;
                  }
                  widget.groupData.groupAdmins!
                          .any((adminId) => adminId == profileCubit.user.id)
                      ? groupCubit
                          .addFriendToGroup(
                          widget.groupData,
                          widget.friendData,
                        )
                          .whenComplete(() {
                          groupCubit.sendMessageToGroup(
                            group: widget.groupData,
                            message:
                                '${profileCubit.user.userName} added ${widget.friendData.userName}',
                            sender: profileCubit.user,
                            type: MessageType.text,
                            isAction: true,
                          );
                          notificationCubit.sendNotification(
                            friendFcmToken,
                            '${widget.groupData.groupName}',
                            "${profileCubit.user.userName} add you to ${widget.groupData.groupName}",
                            'group',
                          );
                        })
                      : groupCubit
                          .requestAddFriendToGroup(
                          widget.groupData,
                          widget.friendData,
                        )
                          .whenComplete(() {
                          groupCubit.sendMessageToGroup(
                            group: widget.groupData,
                            message:
                                "${profileCubit.user.userName} request's to add ${widget.friendData.userName}",
                            sender: profileCubit.user,
                            type: MessageType.text,
                            isAction: true,
                          );
                          notificationCubit.sendNotification(
                            friendFcmToken,
                            '${widget.groupData.groupName}',
                            "${profileCubit.user.userName} request to add you to ${widget.groupData.groupName}",
                            'group',
                          );
                          final List<dynamic> adminsIds =
                              widget.groupData.groupAdmins!.toList();
                          for (final adminId in adminsIds) {
                            if (adminId == profileCubit.user.id) {
                              continue;
                            }
                            groupCubit
                                .getUserData(adminId.toString())
                                .whenComplete(
                              () {
                                notificationCubit.sendNotification(
                                  groupCubit.userData!.fCMToken!,
                                  '${widget.groupData.groupName}',
                                  "${profileCubit.user.userName} request's to add ${widget.friendData.userName}",
                                  'group',
                                );
                              },
                            );
                          }
                        });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: widget.groupData.requests!.any(
                              (friendId) => friendId == widget.friendData.id!,
                            ) ||
                            widget.groupData.members!.any(
                              (friendId) => friendId == widget.friendData.id!,
                            )
                        ? Colors.black
                        : AppColors.primary,
                    border: Border.all(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    widget.groupData.requests!.any(
                      (friendId) => friendId == widget.friendData.id!,
                    )
                        ? "Requested"
                        : widget.groupData.members!.any(
                            (friendId) => friendId == widget.friendData.id!,
                          )
                            ? "Added"
                            : "Add",
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
