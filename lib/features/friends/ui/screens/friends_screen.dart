import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_tile.dart';
import 'package:chat_app/features/friends/ui/widgets/no_friend_widget.dart';
import 'package:chat_app/route_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  Stream? friends;

  @override
  Widget build(BuildContext context) {
    final friends = FriendCubit.get(context);

    return friends.allFriends.isNotEmpty
        ? BlocBuilder<FriendCubit, FriendStates>(
            builder: (context, state) {
              return ListView.builder(
                itemCount: friends.allFriends.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      print("User Name : ${friends.allFriends[index].friendData?.userName}");
                      Navigator.pushNamed(
                        context,
                        Routes.friendChatScreen,
                        arguments: friends.allFriends[index],
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
            },
          )
        : const NoFriendWidget();
  }
}
