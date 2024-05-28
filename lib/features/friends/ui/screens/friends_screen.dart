import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_tile.dart';
import 'package:chat_app/features/friends/ui/widgets/no_friend_widget.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  Widget build(BuildContext context) {
    final friendsCubit = FriendCubit.get(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocBuilder<FriendCubit, FriendStates>(
        buildWhen: (_, currentState) =>
            currentState is GetCombinedFriendsLoading ||
            currentState is GetCombinedFriendsSuccess ||
            currentState is GetCombinedFriendsError ||
            currentState is GetFriendDataError ||
            currentState is GetFriendDataSuccess ||
            currentState is GetFriendDataLoading,
        builder: (_, state) {
          if (state is GetCombinedFriendsLoading) {
            return const LoadingIndicator();
          } else if (state is GetCombinedFriendsError) {
            return const ErrorIndicator();
          } else if (friendsCubit.combinedFriends.isEmpty) {
            return const NoFriendWidget();
          } else {
            return ListView.builder(
              itemCount: friendsCubit.combinedFriends.length,
              itemBuilder: (_, index) {

                final friendData = friendsCubit.combinedFriends[index];
                if (friendData.user != null) {
                  return FriendTile(
                    friendData: friendData,
                  );
                }
                return const SizedBox.shrink();
              },
            );
          }
        },
      ),
    );
  }
}
