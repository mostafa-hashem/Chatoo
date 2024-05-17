import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/ui/widgets/groupe_tile.dart';
import 'package:chat_app/features/groups/ui/widgets/no_groups_widget.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:flutter/material.dart';

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
            child: ListView.builder(
              itemCount: groupsCubit.allUserGroups.length,
              itemBuilder: (_, index) {
                if (groupsCubit.allUserGroups[index]?.groupId != null) {
                  return GroupTile(
                    groupData: groupsCubit.allUserGroups[index]!,
                    userName: ProfileCubit.get(context).user.userName!,
                    isLeftOrJoined: groupsCubit
                        .allUserGroups[index]!.recentMessage!.isEmpty,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
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
