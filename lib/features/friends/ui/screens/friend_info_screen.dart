import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_info.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendInfoScreen extends StatefulWidget {
  const FriendInfoScreen({super.key});

  @override
  State<FriendInfoScreen> createState() => _FriendInfoScreenState();
}

class _FriendInfoScreenState extends State<FriendInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final friendData = ModalRoute.of(context)!.settings.arguments! as User;
    final friendCubit = FriendCubit.get(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData.fallback(),
            actions: [
              if (FriendCubit.get(context).allFriends.contains(friendData))
                Padding(
                  padding: const EdgeInsets.all(14),
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
                      "Added",
                      style: GoogleFonts.ubuntu(color: Colors.white),
                    ),
                  ),
                )
              else
                BlocListener<FriendCubit, FriendStates>(
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
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: InkWell(
                      onTap: () async {
                        friendCubit.addFriend(
                          friendData,
                          ProfileCubit.get(context).user,
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
                          "Add",
                          style: GoogleFonts.ubuntu(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 22.h,
                    ),
                    if (friendData.profileImage != null &&
                        friendData.profileImage!.isNotEmpty)
                      InkWell(
                        onTap: () =>
                            showImageDialog(context, friendData.profileImage!),
                        child: ClipOval(
                          child: FancyShimmerImage(
                            imageUrl: friendData.profileImage!,
                            boxFit: BoxFit.cover,
                            width: 180.w,
                            height: 170.h,
                          ),
                        ),
                      )
                    else
                      InkWell(
                        onTap: () => showImageDialog(
                          context,
                          FirebasePath.defaultImage,
                        ),
                        child: ClipOval(
                          child: FancyShimmerImage(
                            imageUrl: FirebasePath.defaultImage,
                            boxFit: BoxFit.cover,
                            width: 180.w,
                            height: 170.h,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      friendData.bio!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 28),
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    Text(
                      "Info",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 28),
                    ),
                    const Divider(
                      thickness: 3,
                      color: AppColors.primary,
                    ),
                    FriendInfo(
                      labelText: 'User Name',
                      info: friendData.userName!,
                    ),
                    const Divider(
                      thickness: 3,
                      color: AppColors.primary,
                    ),
                    FriendInfo(
                      labelText: 'Email',
                      info: friendData.email!,
                    ),
                    const Divider(
                      thickness: 3,
                      color: AppColors.primary,
                    ),
                    FriendInfo(
                      labelText: 'Phone',
                      info: friendData.phoneNumber!,
                    ),
                    const Divider(
                      thickness: 3,
                      color: AppColors.primary,
                    ),
                    FriendInfo(
                      labelText: 'Phone',
                      info: friendData.city!,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
