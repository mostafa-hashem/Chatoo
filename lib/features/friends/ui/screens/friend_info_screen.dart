import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_info.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendInfoScreen extends StatefulWidget {
  const FriendInfoScreen({super.key});

  @override
  State<FriendInfoScreen> createState() => _FriendInfoScreenState();
}

class _FriendInfoScreenState extends State<FriendInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final friendsCubit = ModalRoute.of(context)!.settings.arguments! as Friend;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData.fallback(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 22.h,
                ),
                if (friendsCubit.friendData!.profileImage == null &&
                    friendsCubit.friendData!.profileImage!.isNotEmpty)
                  ClipOval(
                    child: FancyShimmerImage(
                      imageUrl: friendsCubit.friendData!.profileImage!,
                      boxFit: BoxFit.cover,
                      width: 180.w,
                      height: 170.h,
                    ),
                  )
                else
                  ClipOval(
                    child: FancyShimmerImage(
                      imageUrl: FirebasePath.defaultImage,
                      boxFit: BoxFit.cover,
                      width: 180.w,
                      height: 170.h,
                    ),
                  ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  friendsCubit.friendData!.bio!,
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
                  info: friendsCubit.friendData!.userName!,
                ),
                const Divider(
                  thickness: 3,
                  color: AppColors.primary,
                ),
                FriendInfo(
                  labelText: 'Email',
                  info: friendsCubit.friendData!.email!,
                ),
                const Divider(
                  thickness: 3,
                  color: AppColors.primary,
                ),
                FriendInfo(
                  labelText: 'Phone',
                  info: friendsCubit.friendData!.phoneNumber!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
