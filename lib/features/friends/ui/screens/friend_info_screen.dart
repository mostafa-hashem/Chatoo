import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_info.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendInfoScreen extends StatefulWidget {
  const FriendInfoScreen({super.key});

  @override
  State<FriendInfoScreen> createState() => _FriendInfoScreenState();
}

class _FriendInfoScreenState extends State<FriendInfoScreen> {

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendsData = ModalRoute.of(context)!.settings.arguments! as Friend;
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 22.h,
                ),
                ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: friendsData.friendData!.profileImage!,
                    boxFit: BoxFit.cover,
                    width: 180.w,
                    height: 170.h,
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Text(
                  friendsData.friendData!.bio!,
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
                  info: friendsData.friendData!.userName!,
                ),
                const Divider(
                  thickness: 3,
                  color: AppColors.primary,
                ),
                FriendInfo(
                  labelText: 'Email',
                  info: friendsData.friendData!.email!,
                ),
                const Divider(
                  thickness: 3,
                  color: AppColors.primary,
                ),
                FriendInfo(
                  labelText: 'Phone',
                  info: friendsData.friendData!.phoneNumber!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
