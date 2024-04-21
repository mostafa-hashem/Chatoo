import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMembers extends StatelessWidget {
  // Note: Avoid using `const` with constructors.
  GroupMembers({
    required this.isAdmin,
    required this.group,
    super.key,
  });

  final bool isAdmin;
  final Group group;

  @override
  Widget build(BuildContext context) {
    final groupCubit = GroupCubit.get(context);
    return ListView.builder(
      itemCount: groupCubit.allGroupMembers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
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
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    Routes.friendInfoScreen,
                    arguments: groupCubit.allGroupMembers[index],
                  ),
                  child: ListTile(
                    leading: groupCubit.allGroupMembers[index].profileImage !=
                                null ||
                            groupCubit
                                .allGroupMembers[index].profileImage!.isNotEmpty
                        ? InkWell(
                            onTap: () => showImageDialog(
                              context,
                              groupCubit.allGroupMembers[index].profileImage!,
                            ),
                            child: FancyShimmerImage(
                              imageUrl: groupCubit
                                  .allGroupMembers[index].profileImage!,
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
                              groupCubit.allGroupMembers[index].userName!
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: GoogleFonts.ubuntu(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    title: Text(
                      groupCubit.allGroupMembers[index].userName!,
                      style: GoogleFonts.alexandria(fontSize: 14.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      "Bio: ${groupCubit.allGroupMembers[index].bio}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              ),
              if (groupCubit.allGroupMembers[index].id !=
                  ProfileCubit.get(context).user.id!)
                if (isAdmin)
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Kick member ?'),
                            actionsOverflowDirection: VerticalDirection.down,
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const Text('Kick'),
                                onPressed: () {
                                  groupCubit
                                      .kickUserFromGroup(
                                    group.groupId!,
                                    groupCubit.allGroupMembers[index].id!,
                                  )
                                      .whenComplete(
                                    () {
                                      groupCubit.sendMessageToGroup(
                                        group: group,
                                        sender: ProfileCubit.get(context).user,
                                        message:
                                            '${ProfileCubit.get(context).user.userName!} kick ${groupCubit.allGroupMembers[index].userName}',
                                        leave: true,
                                        joined: false,
                                        requested: false,
                                        declined: false,
                                      );
                                      groupCubit
                                          .getAllGroupMembers(group.groupId!);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            ],
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
                        "Kick",
                        style: GoogleFonts.ubuntu(color: Colors.white),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
