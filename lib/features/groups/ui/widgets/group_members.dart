import 'package:chat_app/features/groups/cubit/group_cubit.dart';
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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final groupCubit = GroupCubit.get(context);
    return ListView.builder(
      itemCount: groupCubit.allGroupMembers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            Routes.friendInfoScreen,
            arguments: groupCubit.allGroupMembers[index],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: ListTile(
              leading: groupCubit.allGroupMembers[index].profileImage != null ||
                      groupCubit.allGroupMembers[index].profileImage!.isNotEmpty
                  ? InkWell(
                      onTap: () => showImageDialog(
                        context,
                        groupCubit.allGroupMembers[index].profileImage!,
                      ),
                      child: FancyShimmerImage(
                        imageUrl:
                            groupCubit.allGroupMembers[index].profileImage!,
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
              title: Text(groupCubit.allGroupMembers[index].userName!),
              subtitle: Text(
                "Bio: ${groupCubit.allGroupMembers[index].bio}",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        );
      },
    );
  }
}
