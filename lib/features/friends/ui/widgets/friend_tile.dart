import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/data/model/combined_friend.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendTile extends StatelessWidget {
  const FriendTile({
    super.key,
    required this.friendData,
  });

  final CombinedFriend friendData;

  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context);
    final friendCubit = FriendCubit.get(context);
    final GlobalKey listTileKey = GlobalKey();

    bool isMuted() {
      if (profileCubit.user.mutedGroups != null) {
        return profileCubit.user.mutedFriends!
            .any((friendId) => friendId == friendData.user?.id);
      }
      return false;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListTile(
        leading: friendData.user!.profileImage!.isEmpty
            ? CircleAvatar(
          radius: 26.r,
          backgroundColor: AppColors.primary,
          child: Text(
            friendData.user!.userName!.substring(0, 1).toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
        )
            : InkWell(
          onTap: () {
            showImageDialog(context, friendData.user!.profileImage!);
          },
          child: ClipOval(
            child: FancyShimmerImage(
              imageUrl: friendData.user!.profileImage!,
              width: 50.w,
              height: 50.w,
              errorWidget: ClipOval(
                child: FancyShimmerImage(
                  imageUrl: FirebasePath.defaultImage,
                  width: 50.w,
                  height: 50.w,
                ),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              friendData.user!.userName ?? 'Unknown',
              style: GoogleFonts.novaSquare(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              friendData.recentMessageData?.sentAt != null
                  ? getFormattedTime(friendData.recentMessageData!.sentAt!.millisecondsSinceEpoch)
                  : '',
              style: GoogleFonts.novaSquare(
                fontWeight: FontWeight.w700,
                fontSize: 12.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        subtitle: Text(

          friendData.recentMessageData?.recentMessage ?? '',
          style: GoogleFonts.novaSquare(
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isMuted()
            ? Icon(
          Icons.notifications_off,
          color: AppColors.primary,
          size: 20.sp,
        )
            : const SizedBox.shrink(),
        onTap: () {
          friendCubit.getFriendData(friendData.user!.id!);
          friendCubit.getAllFriendMessages(friendData.user!.id!).whenComplete(() {
            Future.delayed(const Duration(milliseconds: 50), () {
              Navigator.pushNamed(
                context,
                Routes.friendChatScreen,
                arguments: friendData.user,
              );
            });
          });
        },
        onLongPress: () {
          showMenu(
            context: context,
            position: RelativeRect.fromRect(
              getWidgetPosition(listTileKey),
              Offset.zero & MediaQuery.of(context).size,
            ),
            items: [
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    isMuted()
                        ? friendCubit.unMuteFriend(friendData.user!.id ?? '')
                        : friendCubit.muteFriend(friendData.user!.id ?? '');
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: isMuted() ? const Text('Un Mute') : const Text('Mute'),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    friendCubit.deleteChat(friendData.user!.id ?? '');
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Delete chat'),
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  onPressed: () {
                    friendCubit.removeFriend(friendData.user!.id ?? '');
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Remove friend'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
