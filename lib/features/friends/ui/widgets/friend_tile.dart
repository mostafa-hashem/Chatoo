import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
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

  final User friendData;

  @override
  State<FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile> {
  late ProfileCubit profileCubit;
  final GlobalKey listTileKey = GlobalKey();

  bool isMuted() {
    if (profileCubit.user.mutedGroups != null) {
      return profileCubit.user.mutedFriends!
          .any((friendId) => friendId == widget.friendData.id);
    }
    return false;
  }

  @override
  void didChangeDependencies() {
    profileCubit = ProfileCubit.get(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final friendCubit = FriendCubit.get(context);
    return BlocConsumer<FriendCubit, FriendStates>(
      listener: (_, state) {
        if (state is MuteFriendSuccess || state is UnMuteFriendSuccess) {
          profileCubit.getUser();
        }
        if (state is DeleteChatSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Deleted successfully",
                style: TextStyle(fontSize: 15),
              ),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (_, state) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: ListTile(
            key: listTileKey,
            leading: widget.friendData.profileImage!.isEmpty
                ? CircleAvatar(
                    radius: 26.r,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.friendData.userName!.substring(0, 1).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      showImageDialog(context, widget.friendData.profileImage!);
                    },
                    child: ClipOval(
                      child: FancyShimmerImage(
                        imageUrl: widget.friendData.profileImage!,
                        width: 50.w,
                      ),
                    ),
                  ),
            title: Text(
              widget.friendData.userName ?? 'Unknown',
              style: GoogleFonts.novaSquare(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "Test for last message",
              style: GoogleFonts.novaSquare(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: isMuted()
                ? const Icon(
                    Icons.notifications_off,
                    color: AppColors.primary,
                    size: 20,
                  )
                : const SizedBox.shrink(),
            onTap: () {
              friendCubit.getFriendData(
                widget.friendData.id!,
              );
              friendCubit
                  .getAllFriendMessages(
                widget.friendData.id!,
              )
                  .whenComplete(() {
                Future.delayed(
                  const Duration(
                    milliseconds: 50,
                  ),
                  () => Navigator.pushNamed(
                    context,
                    Routes.friendChatScreen,
                    arguments: widget.friendData,
                  ),
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
                        isMuted()
                            ? friendCubit
                                .unMuteFriend(widget.friendData.id ?? '')
                            : friendCubit
                                .muteFriend(widget.friendData.id ?? '');
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: isMuted()
                          ? const Text('Un Mute')
                          : const Text('Mute'),
                    ),
                  ),
                  PopupMenuItem(
                    child: TextButton(
                      onPressed: () {
                        friendCubit.deleteChat(widget.friendData.id ?? '');
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
                        friendCubit.removeFriend(widget.friendData.id ?? '');
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
