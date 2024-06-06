import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/combined_friend.dart';
import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
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
  const FriendTile({
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
    final friendCubit = FriendCubit.get(context);

    final bool isMuted = friendCubit.mutedFriends
        .any((friendId) => friendId == widget.friendData.user?.id);

    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (_, current) =>
          current is GetUserSuccess ||
          current is ProfileLoading ||
          current is GetUserError,
      builder: (_, state) {
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
              sentAt: widget.friendData.recentMessageData.sentAt != null
                  ? Timestamp.fromDate(
                      widget.friendData.recentMessageData.sentAt!,
                    )
                  : null,
            ),
            subtitle: RecentMessage(
              friendRecentMessage: widget.friendData.recentMessageData,
              isTyping: widget.friendData.recentMessageData.typing ?? false,
              isRecording:
                  widget.friendData.recentMessageData.recording ?? false,
              unreadCount: widget.friendData.recentMessageData.unreadCount,
            ),
            trailing: isMuted
                ? Icon(
                    Icons.notifications_off,
                    color: AppColors.primary,
                    size: 20.sp,
                  )
                : const SizedBox.shrink(),
            onTap: () {
              friendCubit.getFriendData(widget.friendData.user!.id!);
              Future.wait([
                friendCubit.markMessagesAsRead(widget.friendData.user!.id!),
              ]);

              Future.delayed(const Duration(milliseconds: 50), () {
                Navigator.pushNamed(
                  context,
                  Routes.friendChatScreen,
                  arguments: widget.friendData.user,
                );
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
                        isMuted
                            ? friendCubit.unMuteFriend(
                                widget.friendData.user!.id ?? '',
                              )
                            : friendCubit
                                .muteFriend(widget.friendData.user!.id ?? '');
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child:
                          isMuted ? const Text('Un Mute') : const Text('Mute'),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        friendCubit.deleteChat(
                          widget.friendData.user?.id ?? '',
                          widget.friendData.recentMessageData.addedAt ??
                              DateTime.now().toLocal(),
                        );
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
                        friendCubit.deleteChatForAll(
                          widget.friendData.user?.id ?? '',
                          widget.friendData.recentMessageData.addedAt ??
                              DateTime.now().toLocal(),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Delete chat for all'),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: const Text(
                                "Are you sure you want to remove friend ?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                BlocListener<FriendCubit, FriendStates>(
                                  listener: (_, state) {
                                    if (state is RemoveFriendLoading) {
                                      const LoadingIndicator();
                                    } else {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                      if (state is RemoveFriendSuccess) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Removed successfully",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            backgroundColor: AppColors.primary,
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      }
                                      if (state is RemoveFriendError) {
                                        const ErrorIndicator();
                                      }
                                    }
                                  },
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text("Leave"),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
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
                fontSize: 14.sp,
              ),
            ),
          )
        else
          InkWell(
            onTap: () {
              showImageDialog(context, imageUrl);
            },
            child: ClipOval(
              child: CircleAvatar(
                radius: 26.r,
                child: FancyShimmerImage(
                  imageUrl: imageUrl,
                  errorWidget: ClipOval(
                    child: FancyShimmerImage(
                      imageUrl: FirebasePath.defaultImage,
                    ),
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
            fontSize: 12.sp,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Text(
          sentAt != null
              ? getFormattedTime(
                  sentAt!.millisecondsSinceEpoch,
                )
              : '',
          style: GoogleFonts.novaSquare(
            fontWeight: FontWeight.w700,
            fontSize: 7.sp,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class RecentMessage extends StatefulWidget {
  const RecentMessage({
    super.key,
    required this.friendRecentMessage,
    required this.unreadCount,
    this.isTyping = false,
    this.isRecording = false,
  });

  final FriendRecentMessage? friendRecentMessage;
  final int? unreadCount;
  final bool isTyping;
  final bool isRecording;

  @override
  State<RecentMessage> createState() => _RecentMessageState();
}

class _RecentMessageState extends State<RecentMessage> {
  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;

  void _checkTextDirection(String text) {
    if (text.isNotEmpty && isArabic(text)) {
      setState(() {
        _textAlign = TextAlign.right;
        _textDirection = TextDirection.rtl;
      });
    } else {
      setState(() {
        _textAlign = TextAlign.left;
        _textDirection = TextDirection.ltr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context);
    final messageText = widget.friendRecentMessage?.recentMessage;
    _checkTextDirection(messageText ?? '');
    return Row(
      children: [
        if (widget.friendRecentMessage?.seen != null &&
            widget.friendRecentMessage!.seen! &&
            widget.friendRecentMessage!.recentMessageSenderId ==
                profileCubit.user.id)
          Text(
            "✓✓",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.blue, fontSize: 8.sp),
          ),
        if (widget.friendRecentMessage?.seen != null &&
            !widget.friendRecentMessage!.seen! &&
            widget.friendRecentMessage!.recentMessageSenderId ==
                profileCubit.user.id)
          Text(
            "✓",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey, fontSize: 8.sp),
          ),
        Flexible(
          child: Text(
            widget.isTyping
                ? 'Typing...'
                : widget.isRecording
                    ? 'Recording...'
                    : widget.friendRecentMessage?.recentMessage ?? '',
            textAlign: _textAlign,
            textDirection: _textDirection,
            style: GoogleFonts.novaSquare(
              color: widget.isTyping || widget.isRecording
                  ? Colors.greenAccent
                  : null,
              fontWeight: FontWeight.w700,
              fontSize: 10.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        if (widget.unreadCount != null && widget.unreadCount! > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              "${widget.unreadCount}",
              style: GoogleFonts.novaSquare(
                fontWeight: FontWeight.w400,
                fontSize: 10.sp,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
