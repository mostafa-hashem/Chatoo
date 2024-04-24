import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/screens/requests_screen.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/profile/ui/screens/profile_screen.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/screens/about_us.dart';
import 'package:chat_app/ui/screens/suggestions_screens.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerTile extends StatefulWidget {
  const DrawerTile({super.key});

  @override
  State<DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<DrawerTile> {
  String email = '';

  @override
  Widget build(BuildContext context) {
    final profile = ProfileCubit.get(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 50.h),
      child: Column(
        children: <Widget>[
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return profile.user.profileImage != null &&
                      profile.user.profileImage!.isNotEmpty
                  ? InkWell(
                      onTap: () => showImageDialog(
                        context,
                        profile.user.profileImage!,
                      ),
                      child: ClipOval(
                        child: FancyShimmerImage(
                          imageUrl: profile.user.profileImage!,
                          height: 150.h,
                          width: 180.w,
                          boxFit: BoxFit.contain,
                          errorWidget: const Icon(Icons.error_outline_outlined),
                        ),
                      ),
                    )
                  : ClipOval(
                      child: FancyShimmerImage(
                        imageUrl: FirebasePath.defaultImage,
                        height: 150.h,
                        width: 180.w,
                        boxFit: BoxFit.contain,
                        errorWidget: const Icon(Icons.error_outline_outlined),
                      ),
                    );
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            ProfileCubit.get(context).user.userName!,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          const Divider(
            height: 2,
          ),
          ListTile(
            onTap: () {
              nextScreen(context, const ProfileScreen());
            },
            selected: true,
            selectedColor: AppColors.primary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.person),
            title: Text(
              "Profile",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  onTap: () {
                    nextScreen(context, const RequestsScreen());
                  },
                  selected: true,
                  selectedColor: AppColors.primary,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  leading: const Icon(Icons.person_add_alt_1),
                  title: Text(
                    "Requests",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              BlocBuilder<FriendCubit, FriendStates>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        FriendCubit.get(context)
                            .allUserRequests
                            .length
                            .toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 14.sp),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          ListTile(
            onTap: () {
              nextScreen(context, const SuggestionsScreen());
            },
            selected: true,
            selectedColor: AppColors.primary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.comment),
            title: Text(
              "Suggestions",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ListTile(
            onTap: () {
              nextScreen(context, const AboutUs());
            },
            selected: true,
            selectedColor: AppColors.primary,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.info),
            title: Text(
              "About us",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
