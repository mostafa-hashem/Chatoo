import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupSearchWidget extends StatefulWidget {
  final Group searchedGroupData;
  final bool isUserMember;

  const GroupSearchWidget({
    super.key,
    required this.searchedGroupData,
    required this.isUserMember,
  });

  @override
  State<GroupSearchWidget> createState() => _GroupSearchWidgetState();
}

class _GroupSearchWidgetState extends State<GroupSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupCubit, GroupStates>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: widget.searchedGroupData.groupIcon.isEmpty
                ? CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.searchedGroupData.groupName
                          .substring(0, 1)
                          .toUpperCase(),
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ClipOval(
                    child: FancyShimmerImage(
                      imageUrl: widget.searchedGroupData.groupIcon,
                      width: 50.w,
                    ),
                  ),
            title: Text(
              widget.searchedGroupData.groupName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: widget.isUserMember
                ? Text(
                    "Joined",
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                : Text(
                    "Join as ${ProfileCubit.get(context).user.userName}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
            trailing: widget.isUserMember
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
                : BlocListener<GroupCubit, GroupStates>(
                    listener: (c, state) {
                        if (state is JoinGroupSuccess) {
                          GroupCubit.get(context).sendMessageToGroup(
                            group: widget.searchedGroupData,
                            sender: ProfileCubit.get(context).user,
                            message:
                                '${ProfileCubit.get(context).user.userName} joined the group',
                            leave: false,
                            joined: true,
                          );
                          showSnackBar(
                            context,
                            Colors.green,
                            "Successfully joined he group",
                          );
                        }
                        if (state is JoinGroupError) {
                          showSnackBar(
                            context,
                            Colors.red,
                            state.message,
                          );
                        }
                    },
                    child: InkWell(
                      onTap: () async {
                        GroupCubit.get(context).joinGroup(
                          widget.searchedGroupData,
                          ProfileCubit.get(context).user,
                        );
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
          ),
        );
      },
    );
  }
}
