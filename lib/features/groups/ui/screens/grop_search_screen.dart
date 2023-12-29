import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/ui/widgets/group_search_widget.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final userdata = ProfileCubit.get(context);
    final groupData = GroupCubit.get(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 60,
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: BlocBuilder<GroupCubit, GroupStates>(
                    builder: (context, state) {
                      return TextField(
                        onChanged: (value) => groupData.searchOnGroup(value),
                        style: GoogleFonts.ubuntu(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search groups....",
                          hintStyle: GoogleFonts.novaFlat(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
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
            child: BlocBuilder<GroupCubit, GroupStates>(
              builder: (context, state) {
                return ListView.separated(
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      groupData.checkUserInGroup(
                        userdata.user.id!,
                        groupData.allUserGroups[index].groupId,
                      );
                    },
                    child: GroupSearchWidget(
                      groupData: groupData.searchedGroups[index],
                      isJoined: groupData.isUserMember,
                    ),
                  ),
                  separatorBuilder: (context, index) => Divider(
                    thickness: 4.h,
                  ),
                  itemCount: groupData.searchedGroups.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
