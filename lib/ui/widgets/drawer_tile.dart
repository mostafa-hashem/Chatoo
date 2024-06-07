import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/screens/requests_screen.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/profile/ui/screens/profile_screen.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/screens/about_us.dart';
import 'package:chat_app/ui/screens/suggestions_screens.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(context),
          const Divider(),
          _createDrawerItem(
            context: context,
            icon: Icons.person,
            text: 'Profile',
            onTap: () => nextScreen(context, const ProfileScreen()),
          ),
          _createDrawerItemWithCounter(
            context: context,
            icon: Icons.person_add_alt_1,
            text: 'Requests',
            counterCubit: FriendCubit.get(context),
            onTap: () => nextScreen(context, const RequestsScreen()),
          ),
          _createDrawerItem(
            context: context,
            icon: Icons.comment,
            text: 'Suggestions',
            onTap: () => nextScreen(context, const SuggestionsScreen()),
          ),
          _createDrawerItem(
            context: context,
            icon: Icons.info,
            text: 'About us',
            onTap: () => nextScreen(context, const AboutUs()),
          ),
          const Divider(),
          _createLogoutItem(context),
        ],
      ),
    );
  }

  Widget _createHeader(BuildContext context) {
    final profile = ProfileCubit.get(context);

    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      accountName: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (_, state) {
          return Text(
            profile.user.userName ?? 'Unknown',
            style: GoogleFonts.ubuntu(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      accountEmail: null,
      currentAccountPicture: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (_, state) {
          return profile.user.profileImage != null &&
                  profile.user.profileImage!.isNotEmpty
              ? GestureDetector(
                  onTap: () => showImageDialog(
                    context: context,
                    imageUrl: profile.user.profileImage!,
                    chatName: 'You',
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: FancyShimmerImage(
                      imageUrl: profile.user.profileImage!,
                      boxFit: BoxFit.cover,
                      width: 100.w,
                      height: 100.h,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 50.r,
                      ),
                    ),
                  ),
          )
              : CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text(
                    profile.user.userName != null
                        ? profile.user.userName!.substring(0, 1).toUpperCase()
                        : 'M',
                    style: GoogleFonts.ubuntu(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _createDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _createDrawerItemWithCounter({
    required BuildContext context,
    required IconData icon,
    required String text,
    required FriendCubit counterCubit,
    required GestureTapCallback onTap,
  }) {
    return BlocBuilder<FriendCubit, FriendStates>(
      builder: (_, state) {
        return ListTile(
          title: Row(
            children: <Widget>[
              Icon(icon),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Spacer(),
              if(counterCubit.allUserRequests.isNotEmpty)
              CircleAvatar(
                radius: 12.r,
                backgroundColor: AppColors.primary,
                child: Text(
                counterCubit.allUserRequests.length.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }

  Widget _createLogoutItem(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    final groupCubit = GroupCubit.get(context);
    final friendCubit = FriendCubit.get(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (_, state) {
        if (state is AuthLoading) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const LoadingIndicator();
            },
          );
        } else {
          Navigator.pop(context);
          if (state is LoggedOut) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.login,
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Successfully logout",
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: AppColors.snackBar,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "There is an error",
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: AppColors.primary,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: _createDrawerItem(
        context: context,
        icon: Icons.logout,
        text: 'Logout',
        onTap: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text(
                  "Are you sure you want to logout?",
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      groupCubit.allUserGroups.clear();
                      friendCubit.combinedFriends.clear();
                      await updateStatus(false);
                      authCubit.logout();
                    },
                    icon: const Icon(
                      Icons.done,
                      color: Colors.green,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
