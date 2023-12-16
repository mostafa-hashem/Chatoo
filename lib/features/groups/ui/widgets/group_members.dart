import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMembers extends StatelessWidget {
  final Group groupData;

  const GroupMembers({super.key, required this.groupData});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 0,
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
                groupData.members![index].userName!
                    .substring(0, 1)
                    .toUpperCase(),
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            title: Text(groupData.members![index].userName!),
            subtitle: Text(
              "ID: ${groupData.members![index].id}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}
