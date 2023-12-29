import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_tile.dart';
import 'package:chat_app/features/friends/ui/widgets/no_friend_widget.dart';
import 'package:chat_app/route_manager.dart';
import 'package:flutter/material.dart';

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
        ? ListView.builder(
            itemCount: friends.allFriends.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, Routes.friendChatScreen,arguments: friends.allFriends[index]);
                },
                child: FriendTile(
                  friendId: friends.allFriends[index].id!,
                  friendName: friends.allFriends[index].userName!,
                ),
              );
            },
          )
        : const NoFriendWidget();
  }
}
