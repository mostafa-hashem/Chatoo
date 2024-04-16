import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMembers extends StatelessWidget {
  // Note: Avoid using `const` with constructors.
   GroupMembers({super.key,});
  @override
  Widget build(BuildContext context) {
    final groupCubit = GroupCubit.get(context);
    return ListView.builder(
      itemCount: groupCubit.allGroupMembers.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: ListTile(
            leading: CircleAvatar(
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
              "ID: ${groupCubit.allGroupMembers[index].id}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}
