import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_tile.dart';
import 'package:chat_app/features/friends/ui/widgets/no_friend_widget.dart';
import 'package:chat_app/route_manager.dart';
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
    final friends = FriendCubit.get(context);

    return friends.allFriends.isNotEmpty
        ? BlocBuilder<FriendCubit, FriendStates>(
            buildWhen: (_, currentState) =>
                currentState is AddFriendError ||
                currentState is AddFriendSuccess ||
                currentState is AddFriendLoading,
            builder: (context, state) {
              if (state is GetAllUserFriendsLoading) {
                return  const LoadingIndicator();
              } else if (state is GetAllUserFriendsError) {
                return const ErrorIndicator();
              } else {
                return ListView.builder(
                  itemCount: friends.allFriends.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        friends
                            .getAllFriendMessages(
                              friends.allFriends[index].friendData!.id!,
                            )
                            .whenComplete(
                              () => Future.delayed(
                                const Duration(
                                  milliseconds: 50,
                                ),
                                () => Navigator.pushNamed(
                                  context,
                                  Routes.friendChatScreen,
                                  arguments: friends.allFriends[index],
                                ),
                              ),
                            );
                      },
                      child: FriendTile(
                        friendName:
                            friends.allFriends[index].friendData?.userName ??
                                'Unknown',
                      ),
                    );
                  },
                );
              }
            },
          )
        : const NoFriendWidget();
  }
}
