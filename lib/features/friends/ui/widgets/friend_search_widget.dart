import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendSearchWidget extends StatefulWidget {
  final User friendData;
  final bool isUserFriend;
  final bool isRequested;

  const FriendSearchWidget({
    super.key,
    required this.friendData,
    required this.isUserFriend,
    required this.isRequested,
  });

  @override
  State<FriendSearchWidget> createState() => _FriendSearchWidgetState();
}

class _FriendSearchWidgetState extends State<FriendSearchWidget> {
  @override
  Widget build(BuildContext context) {
    final notificationCubit = NotificationsCubit.get(context);
    final friendCubit = FriendCubit.get(context);
    final profileCubit = ProfileCubit.get(context);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        leading: widget.friendData.profileImage == null ||
                widget.friendData.profileImage!.isEmpty
            ? CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.friendData.userName!.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              )
            : ClipOval(
                child: FancyShimmerImage(
                  imageUrl: widget.friendData.profileImage!,
                  width: 50.w,
                  errorWidget: ClipOval(
                    child: FancyShimmerImage(
                      imageUrl: FirebasePath.defaultImage,
                      width: 50.w,
                    ),
                  ),
                ),
              ),
        title: Text(
          widget.friendData.userName!,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        subtitle: Text(
          "Bio: ${widget.friendData.bio!}",
          style:
              Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 10.sp),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: widget.isRequested
            ? InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Remove request?'),
                        actionsOverflowDirection: VerticalDirection.down,
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text('Remove'),
                            onPressed: () {
                              friendCubit
                                  .removeFriendRequest(widget.friendData.id!);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
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
                    "Requested",
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ),
              )
            : widget.isUserFriend
                ? InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Remove friend?'),
                            actionsOverflowDirection: VerticalDirection.down,
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const Text('Remove'),
                                onPressed: () {
                                  friendCubit.removeFriend(
                                    widget.friendData.id!,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
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
                        "Remove",
                        style: GoogleFonts.ubuntu(color: Colors.white),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      friendCubit
                          .requestToAddFriend(widget.friendData.id!)
                          .whenComplete(
                            () => notificationCubit.sendNotification(
                              fCMToken: widget.friendData.fCMToken!,
                              title: "${profileCubit.user.userName}",
                              body: "Friend request",
                            ),
                          );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.primary,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        "Send Request",
                        style: GoogleFonts.ubuntu(color: Colors.white),
                      ),
                    ),
                  ),
      ),
    );
  }
}
