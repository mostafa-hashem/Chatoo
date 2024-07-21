import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendRequestsTile extends StatefulWidget {
  // Note: Avoid using `const` with constructors.
  const FriendRequestsTile({
    required this.friendData,
    super.key,
  });

  final User friendData;

  @override
  State<FriendRequestsTile> createState() => _FriendRequestsTileState();
}

class _FriendRequestsTileState extends State<FriendRequestsTile> {
  late NotificationsCubit notificationCubit;
  late FriendCubit friendCubit;
  late ProfileCubit profileCubit;
  late List<String> friendFcmTokens;

  @override
  void didChangeDependencies() {
    notificationCubit = NotificationsCubit.get(context);
    friendCubit = FriendCubit.get(context);
    profileCubit = ProfileCubit.get(context);
    friendFcmTokens = widget.friendData.fCMTokens! as List<String>;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              Routes.friendInfoScreen,
              arguments: widget.friendData,
            ),
            child: ListTile(
              leading: widget.friendData.profileImage != null ||
                      widget.friendData.profileImage!.isNotEmpty
                  ? InkWell(
                      onTap: () => showImageDialog(
                        context: context,
                        imageUrl: widget.friendData.profileImage!,
                        chatName: widget.friendData.userName!,
                      ),
                      child: FancyShimmerImage(
                        imageUrl: widget.friendData.profileImage!,
                        height: 44.h,
                        width: 44.w,
                        boxFit: BoxFit.contain,
                        errorWidget: const Icon(
                          Icons.error_outline_outlined,
                        ),
                      ),
                    )
                  : CircleAvatar(
                      radius: 28.r,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        widget.friendData.userName!
                            .substring(0, 1)
                            .toUpperCase(),
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
              title: Text(
                widget.friendData.userName!,
                style: GoogleFonts.alexandria(fontSize: 14.sp),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "Bio: ${widget.friendData.bio}",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          SizedBox(
            height: 18.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  friendCubit.declineToAddFriend(
                    widget.friendData.id!,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary,
                    border: Border.all(color: Colors.white),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Text(
                    "Decline",
                    style: GoogleFonts.ubuntu(color: Colors.white),
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  friendCubit
                      .approveToAddFriend(
                    widget.friendData.id!,
                  )
                      .whenComplete(() {
                    for (final String? friendFcmToken in friendFcmTokens) {
                      notificationCubit.sendNotification(
                        fCMToken: friendFcmToken ?? "",
                        title: profileCubit.user.userName!,
                        body: 'Approved your friend request',
                      );
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary,
                    border: Border.all(color: Colors.white),
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
            ],
          ),
        ],
      ),
    );
  }
}
