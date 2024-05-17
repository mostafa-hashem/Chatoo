import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/ui/widgets/group_search_widget.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupSearchScreen extends StatefulWidget {
  const GroupSearchScreen({super.key});

  @override
  State<GroupSearchScreen> createState() => _GroupSearchScreenState();
}

class _GroupSearchScreenState extends State<GroupSearchScreen> {
  late GroupCubit groupCubit;

  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
  }

  @override
  void deactivate() {
    groupCubit.searchedGroups.clear();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppColors.primary,
          title: Text(
            "Search",
            style: GoogleFonts.ubuntu(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (String? value) {
                        if (value == null || value.isEmpty) {
                          groupCubit.searchedGroups.clear();
                        }
                        if (value != null && value.isNotEmpty) {
                          groupCubit.searchOnGroup(value);
                        }
                      },
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups....",
                        hintStyle: GoogleFonts.novaFlat(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<GroupCubit, GroupStates>(
                listener: (_, state) {
                  if (state is RequestToJoinGroupSuccess) {
                    showSnackBar(
                      context,
                      Colors.green,
                      "Successfully requested",
                    );
                  }
                  if (state is CancelRequestToJoinGroupSuccess) {
                    showSnackBar(
                      context,
                      Colors.green,
                      "Successfully canceled",
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                  if (state is LeaveGroupSuccess) {
                    showSnackBar(
                      context,
                      Colors.green,
                      "Successfully left",
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                  if (state is RequestToJoinGroupError) {
                    showSnackBar(
                      context,
                      Colors.red,
                      state.message,
                    );
                  }
                },
                builder: (_, state) {
                  return ListView.separated(
                    itemBuilder: (_, index) {
                      return GroupSearchWidget(
                        searchedGroupData: groupCubit.searchedGroups[index],
                        isUserMember: groupCubit.allUserGroups.any(
                          (group) =>
                              group != null &&
                              group.groupId!.contains(
                                groupCubit.searchedGroups[index].groupId!,
                              ),
                        ),
                        isRequested:
                            groupCubit.searchedGroups[index].requests!.any(
                          (requesterId) =>
                              requesterId == ProfileCubit.get(context).user.id!,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        thickness: 4.h,
                      );
                    },
                    itemCount: groupCubit.searchedGroups.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
