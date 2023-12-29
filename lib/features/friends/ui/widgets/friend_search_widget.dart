import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendSearchWidget extends StatefulWidget {
  final User friendData;
  final bool isFriend;

  const FriendSearchWidget({
    super.key,
    required this.friendData,
    required this.isFriend,
  });

  @override
  State<FriendSearchWidget> createState() => _FriendSearchWidgetState();
}

class _FriendSearchWidgetState extends State<FriendSearchWidget> {
  @override
  Widget build(BuildContext context) {
    final userdata = ProfileCubit.get(context);
    final friendData = FriendCubit.get(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: Text(
            widget.friendData.userName!.substring(0, 1).toUpperCase(),
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          widget.friendData.userName!,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          widget.friendData.bio!,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: InkWell(
          onTap: () async {
            friendData
                .addFriend(widget.friendData, userdata.user)
                .whenComplete(() {
              showSnackBar(
                context,
                Colors.green,
                "Successfully added the friend",
              );
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacementNamed(
                  context,
                  Routes.layout,
                );
              });
            });
          },
          child: widget.isFriend
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    border: Border.all(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    "Added",
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    "Add",
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ),
        ),
      ),
    );
  }
}
