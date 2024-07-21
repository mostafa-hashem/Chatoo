import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/ui/widgets/add_friend_to_group_tile.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFriendsToGroupScreen extends StatefulWidget {
  const AddFriendsToGroupScreen({super.key});

  @override
  State<AddFriendsToGroupScreen> createState() =>
      _AddFriendsToGroupScreenState();
}

class _AddFriendsToGroupScreenState extends State<AddFriendsToGroupScreen> {
  late FriendCubit friendCubit;
  late GroupCubit groupCubit;

  @override
  void didChangeDependencies() {
    friendCubit = FriendCubit.get(context);
    groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    groupCubit.searchedFriendAddToGroup.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Friends',
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        if (value.isEmpty) {
                          groupCubit.searchedFriendAddToGroup.clear();
                        }
                        if (value.isNotEmpty) {
                          groupCubit.searchOnFriendAddToGroup(
                              friendCubit.combinedFriends, value);
                        }
                      },
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search on friends",
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
            BlocConsumer<GroupCubit, GroupStates>(
              listener: (_, state) {
                if (state is AddToGroupSuccess) {
                  showSnackBar(
                    context,
                    Colors.greenAccent,
                    'Successfully added',
                  );
                }

                if (state is RequestAddToGroupSuccess) {
                  showSnackBar(
                    context,
                    Colors.greenAccent,
                    'Successfully requested',
                  );
                }
              },
              buildWhen: (_, currentState) =>
                  currentState is GetAllGroupMembersLoading ||
                  currentState is GetAllGroupMembersSuccess ||
                  currentState is GetAllGroupMembersError ||
                  currentState is RequestAddToGroupLoading ||
                  currentState is RequestAddToGroupSuccess ||
                  currentState is RequestAddToGroupError ||
                  currentState is AddToGroupSuccess ||
                  currentState is AddToGroupLoading ||
                  currentState is AddToGroupError ||
                  currentState is SearchOnFriendAddToGroupError ||
                  currentState is SearchOnFriendAddToGroupSuccess ||
                  currentState is SearchOnFriendAddToGroupLoading,
              builder: (_, state) {
                return Expanded(
                  child: ListView.separated(
                    itemBuilder: (_, index) {
                      if (friendCubit.combinedFriends[index].user == null &&
                          (groupCubit.searchedFriendAddToGroup.isEmpty ||
                              groupCubit.searchedFriendAddToGroup[index].user ==
                                  null)) {
                        return const SizedBox.shrink();
                      } else {
                        return AddFriendToGroupTile(
                          friendData: groupCubit
                                  .searchedFriendAddToGroup.isNotEmpty
                              ? groupCubit.searchedFriendAddToGroup[index].user!
                              : friendCubit.combinedFriends[index].user!,
                          groupData: groupData,
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      if (friendCubit.combinedFriends[index].user == null) {
                        return const SizedBox.shrink();
                      }
                      return const Divider(
                        color: AppColors.primary,
                      );
                    },
                    itemCount: groupCubit.searchedFriendAddToGroup.isNotEmpty
                        ? groupCubit.searchedFriendAddToGroup.length
                        : friendCubit.combinedFriends.length,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
