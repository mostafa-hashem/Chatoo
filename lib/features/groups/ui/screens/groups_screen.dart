import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/ui/widgets/groupe_tile.dart';
import 'package:chat_app/features/groups/ui/widgets/no_groups_widget.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    final groupsCubit = GroupCubit.get(context);
    return groupsCubit.allUserGroups.isNotEmpty
        ? GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: MultiBlocListener(
              listeners: [
                BlocListener<GroupCubit, GroupStates>(
                  listener: (_, state) {
                    if (state is CreateGroupLoading) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const LoadingIndicator();
                        },
                      );
                    } else {
                      if (state is CreateGroupError) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.message,
                              style: const TextStyle(fontSize: 15),
                            ),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                      if (state is CreateGroupSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Successfully Created",
                              style: TextStyle(fontSize: 15),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 3),
                          ),
                        );
                        // GroupCubit.get(context).getAllUserGroups();
                      }
                    }
                  },
                ),
                BlocListener<GroupCubit, GroupStates>(
                  listener: (_, state) {
                    if (state is GetAllGroupMessagesSuccess) {
                      GroupCubit.get(context).getAllUserGroups();
                    }
                  },
                ),
              ],
              child: BlocBuilder<GroupCubit, GroupStates>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: groupsCubit.allUserGroups.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          groupsCubit
                              .getAllGroupMessages(
                                groupsCubit.allUserGroups[index].groupId,
                              )
                              .whenComplete(
                                () => Future.delayed(
                                  const Duration(
                                    milliseconds: 55,
                                  ),
                                  () => Navigator.pushNamed(
                                    context,
                                    Routes.groupChatScreen,
                                    arguments: groupsCubit.allUserGroups[index],
                                  ),
                                ),
                              );
                        },
                        child: GroupTile(
                          groupData: groupsCubit.allUserGroups[index],
                          userName: ProfileCubit.get(context).user.userName!,
                          isLeftOrJoined: groupsCubit
                              .allUserGroups[index].recentMessage.isEmpty,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: const NoGroupsWidget(),
          );
  }
}
