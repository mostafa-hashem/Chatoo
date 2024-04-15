import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupSearchWidget extends StatefulWidget {
  final Group groupData;
  final bool isJoined;

  const GroupSearchWidget({
    super.key,
    required this.groupData,
    required this.isJoined,
  });

  @override
  State<GroupSearchWidget> createState() => _GroupSearchWidgetState();
}

class _GroupSearchWidgetState extends State<GroupSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: Text(
            widget.groupData.groupName.substring(0, 1).toUpperCase(),
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          widget.groupData.groupName,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          "Admin: ${widget.groupData.adminName}",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: widget.isJoined
            ? Container(
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
                  "Joined",
                  style: GoogleFonts.ubuntu(color: Colors.white),
                ),
              )
            : InkWell(
                onTap: () async {
                  GroupCubit.get(context)
                      .joinGroup(
                    widget.groupData,
                    ProfileCubit.get(context).user,
                  )
                      .whenComplete(() {
                    showSnackBar(
                      context,
                      Colors.green,
                      "Successfully joined he group",
                    );
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pop(context);
                    });
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    "Join",
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ),
              ),
      ),
    );
  }
}
