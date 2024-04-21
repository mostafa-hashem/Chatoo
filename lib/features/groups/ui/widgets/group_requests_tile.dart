import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupRequestsTile extends StatelessWidget {
  // Note: Avoid using `const` with constructors.
  GroupRequestsTile({
    required this.group,
    required this.requesterData,
    super.key,
  });

  final Group group;
  final User requesterData;

  @override
  Widget build(BuildContext context) {
    final groupCubit = GroupCubit.get(context);
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
              arguments: requesterData,
            ),
            child: ListTile(
              leading: requesterData.profileImage != null ||
                      requesterData.profileImage!.isNotEmpty
                  ? InkWell(
                      onTap: () => showImageDialog(
                        context,
                        requesterData.profileImage!,
                      ),
                      child: FancyShimmerImage(
                        imageUrl: requesterData.profileImage!,
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
                        requesterData.userName!.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
              title: Text(
                requesterData.userName!,
                style: GoogleFonts.alexandria(fontSize: 14.sp),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "Bio: ${requesterData.bio}",
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
                    group.groupId!,
                    requesterData.id!,
                  )
                      .whenComplete(
                    () {
                      groupCubit.sendMessageToGroup(
                        group: group,
                        sender: ProfileCubit.get(context).user,
                        message:
                            '${ProfileCubit.get(context).user.userName!} Declined ${requesterData.userName}',
                        leave: false,
                        joined: false,
                        requested: false,
                        declined: true,
                      );
                      Navigator.pop(context);
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
                    group.groupId!,
                    requesterData.id!,
                  )
                      .whenComplete(
                    () {
                      groupCubit.sendMessageToGroup(
                        group: group,
                        sender: ProfileCubit.get(context).user,
                        message:
                            '${ProfileCubit.get(context).user.userName!} Approved ${requesterData.userName}',
                        leave: false,
                        joined: false,
                        requested: true,
                        declined: true,
                      );
                      groupCubit.getAllGroupMembers(group.groupId!);
                      Navigator.pop(context);
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