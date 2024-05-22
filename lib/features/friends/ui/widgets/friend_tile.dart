import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/combined_friend.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendTile extends StatefulWidget {
  FriendTile({
    super.key,
    required this.friendData,
  });

  final CombinedFriend friendData;

  @override
  State<FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile> {
  final GlobalKey listTileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context);
    final friendCubit = FriendCubit.get(context);

    bool isMuted() {
      if (profileCubit.user.mutedGroups != null) {
        return profileCubit.user.mutedFriends!
            .any((friendId) => friendId == widget.friendData.user?.id);
      }
      return false;
    }

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (_, current) =>
          current is GetUserSuccess ||
          current is GetUserError ||
          current is ProfileLoading,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: ListTile(
            key: listTileKey,
            leading: ProfileImage(
              imageUrl: widget.friendData.user!.profileImage!,
              userName: widget.friendData.user!.userName!,
              isOnline: widget.friendData.user!.onLine!,
            ),
            title: FriendTitle(
              userName: widget.friendData.user!.userName,
              sentAt: Timestamp.fromDate(
                widget.friendData.recentMessageData!.sentAt ?? DateTime.now(),
              ),
            ),
            subtitle: RecentMessage(
              recentMessage: widget.friendData.recentMessageData?.recentMessage,
            ),
            trailing: isMuted()
                ? Icon(
                    Icons.notifications_off,
                    color: AppColors.primary,
                    size: 20.sp,
                  )
                : const SizedBox.shrink(),
            onTap: () {
              friendCubit.getFriendData(widget.friendData.user!.id!);
              friendCubit
                  .getAllFriendMessages(widget.friendData.user!.id!)
                  .whenComplete(() {
                Future.delayed(const Duration(milliseconds: 50), () {
                  Navigator.pushNamed(
                    context,
                    Routes.friendChatScreen,
                    arguments: widget.friendData.user,
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
                    child: BlocListener<FriendCubit, FriendStates>(
                      listener: (_, state) {
                        if (state is MuteFriendSuccess ||
                            state is UnMuteFriendSuccess) {
                          profileCubit.getUser();
                        }
                      },
                      child: TextButton(
                        onPressed: () {
                          isMuted()
                              ? friendCubit.unMuteFriend(
                                  widget.friendData.user!.id ?? '',
                                )
                              : friendCubit
                                  .muteFriend(widget.friendData.user!.id ?? '');
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: isMuted()
                            ? const Text('Un Mute')
                            : const Text('Mute'),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        friendCubit
                            .deleteChat(widget.friendData.user!.id ?? '');
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
                        friendCubit
                            .removeFriend(widget.friendData.user!.id ?? '');
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
      },
    );
  }
}

class ProfileImage extends StatelessWidget {
  ProfileImage({
    super.key,
    required this.imageUrl,
    required this.userName,
    required this.isOnline,
  });

  final String imageUrl;
  final String userName;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (imageUrl.isEmpty)
          CircleAvatar(
            radius: 26.r,
            backgroundColor: AppColors.primary,
            child: Text(
              userName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 18.sp,
              ),
            ),
          )
        else
          InkWell(
            onTap: () {
              showImageDialog(context, imageUrl);
            },
            child: ClipOval(
              child: FancyShimmerImage(
                imageUrl: imageUrl,
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
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.5.w,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class FriendTitle extends StatelessWidget {
  const FriendTitle({
    super.key,
    required this.userName,
    required this.sentAt,
  });

  final String? userName;
  final Timestamp? sentAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          userName ?? 'Unknown',
          style: GoogleFonts.novaSquare(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Text(
          sentAt != null
              ? getFormattedTime(sentAt!.millisecondsSinceEpoch)
              : '',
          style: GoogleFonts.novaSquare(
            fontWeight: FontWeight.w700,
            fontSize: 10.sp,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class RecentMessage extends StatelessWidget {
  const RecentMessage({
    super.key,
    required this.recentMessage,
  });

  final String? recentMessage;

  @override
  Widget build(BuildContext context) {
    return Text(
      recentMessage ?? '',
      style: GoogleFonts.novaSquare(
        fontWeight: FontWeight.w700,
        fontSize: 12.sp,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
