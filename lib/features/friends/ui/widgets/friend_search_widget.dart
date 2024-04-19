import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendSearchWidget extends StatefulWidget {
  final User friendData;

  const FriendSearchWidget({
    super.key,
    required this.friendData,
  });

  @override
  State<FriendSearchWidget> createState() => _FriendSearchWidgetState();
}

class _FriendSearchWidgetState extends State<FriendSearchWidget> {
  @override
  Widget build(BuildContext context) {
    final userdata = ProfileCubit.get(context);
    final friendCubit = FriendCubit.get(context);
    return BlocBuilder<FriendCubit, FriendStates>(
      builder: (context, state) {
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
            trailing: FriendCubit.get(context).isUserFriend
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
                : BlocListener<FriendCubit, FriendStates>(
                    listener: (context, state) {
                      if (state is AddFriendLoading) {
                        const LoadingIndicator();
                      } else {
                        if (state is AddFriendSuccess) {
                          friendCubit.getAllUserFriends();
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          showSnackBar(
                            context,
                            Colors.green,
                            "Successfully added the friend",
                          );
                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.layout,
                              (route) => false,
                            );
                          });
                        }
                        if (state is AddFriendError) {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          const ErrorIndicator();
                        }
                      }
                    },
                    child: InkWell(
                      onTap: () async {
                        friendCubit.addFriend(widget.friendData, userdata.user);
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
                          "Add",
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
