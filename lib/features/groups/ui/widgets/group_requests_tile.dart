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

class GroupRequestsTile extends StatefulWidget {
  // Note: Avoid using `const` with constructors.
  const GroupRequestsTile({
    required this.group,
    required this.requesterData,
    super.key,
  });

  final Group group;
  final User requesterData;

  @override
  State<GroupRequestsTile> createState() => _GroupRequestsTileState();
}

class _GroupRequestsTileState extends State<GroupRequestsTile> {
  late GroupCubit groupCubit;
  late NotificationsCubit notificationsCubit;
  late ProfileCubit profileCubit;

  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    notificationsCubit = NotificationsCubit.get(context);
    profileCubit = ProfileCubit.get(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
              arguments: widget.requesterData,
            ),
            child: ListTile(
              leading: widget.requesterData.profileImage != null ||
                      widget.requesterData.profileImage!.isNotEmpty
                  ? InkWell(
                      onTap: () => showImageDialog(
                        context: context,
                        imageUrl: widget.requesterData.profileImage!,
                        chatName: widget.requesterData.profileImage!,
                      ),
                      child: FancyShimmerImage(
                        imageUrl: widget.requesterData.profileImage!,
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
                        widget.requesterData.userName!
                            .substring(0, 1)
                            .toUpperCase(),
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
              title: Text(
                widget.requesterData.userName!,
                style: GoogleFonts.alexandria(fontSize: 14.sp),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "Bio: ${widget.requesterData.bio}",
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  groupCubit
                      .declineToJoinGroup(
                    widget.group.groupId!,
                    widget.requesterData.id!,
                  )
                      .whenComplete(
                    () {
                      groupCubit.sendMessageToGroup(
                        group: widget.group,
                        sender: profileCubit.user,
                        message:
                            '${profileCubit.user.userName!} Declined ${widget.requesterData.userName}',
                        type: MessageType.text,
                        isAction: true,
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    border: Border.all(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    "Decline",
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  groupCubit
                      .approveToJoinGroup(
                    widget.group.groupId!,
                    widget.requesterData.id!,
                  )
                      .whenComplete(
                    () {
                      groupCubit.sendMessageToGroup(
                        group: widget.group,
                        sender: profileCubit.user,
                        message:
                            '${profileCubit.user.userName!} Approved ${widget.requesterData.userName}',
                        type: MessageType.text,
                        isAction: true,
                      );
                      notificationsCubit.sendNotification(
                        fCMToken: widget.requesterData.fCMToken!,
                        title: widget.group.groupName!,
                        body:
                            "Your request to join ${widget.group.groupName} have been accepted",
                      );
                      // groupCubit.getAllGroupMembers(widget.group.groupId!);
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary,
                    border: Border.all(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    "Approve",
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
