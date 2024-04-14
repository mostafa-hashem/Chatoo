import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/ui/widgets/groupe_tile.dart';
import 'package:chat_app/features/groups/ui/widgets/no_groups_widget.dart';
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
    final groups = GroupCubit.get(context);
    return groups.allUserGroups.isNotEmpty
        ? BlocConsumer<GroupCubit, GroupStates>(
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
                  GroupCubit.get(context).getAllUserGroups();
                }
              }
            },
            builder: (context, state) => ListView.builder(
              itemCount: groups.allUserGroups.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    GroupCubit.get(context)
                        .getAllGroupMessages(
                            groups.allUserGroups[index].groupId)
                        .whenComplete(
                          () => Navigator.pushNamed(
                            context,
                            Routes.groupChatScreen,
                            arguments: groups.allUserGroups[index],
                          ),
                        );
                  },
                  child: GroupTile(
                    groupId: groups.allUserGroups[index].groupId,
                    groupName: groups.allUserGroups[index].groupName,
                    userName: groups.allUserGroups[index].adminName,
                  ),
                );
              },
            ),
          )
        : const NoGroupsWidget();
  }
}
