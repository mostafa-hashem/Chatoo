import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
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

class AddFriendsToGroupScreen extends StatelessWidget {
  const AddFriendsToGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friendCubit = FriendCubit.get(context);
    final groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Friends',
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
            children: [
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
                    currentState is RequestToAddFriendSuccess ||
                    currentState is RequestToAddFriendLoading ||
                    currentState is RequestToAddFriendError ||
                    currentState is AddToGroupSuccess ||
                    currentState is AddToGroupLoading ||
                    currentState is AddToGroupError,
                builder: (_, state) {
                  return Expanded(
                    child: ListView.separated(
                      itemBuilder: (_, index) {
                        if (friendCubit.combinedFriends[index].user == null) {
                          return const SizedBox.shrink();
                        } else {
                          return AddFriendToGroupTile(
                            friendData: friendCubit.combinedFriends[index].user!,
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
                      itemCount: friendCubit.combinedFriends.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
