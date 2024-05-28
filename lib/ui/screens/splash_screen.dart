import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/route_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen();

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _initStart();
    super.initState();
  }

  Future<void> _initStart() async {
    if (AuthCubit.get(context).isLoggedIn) {
      Future.wait([
        ProfileCubit.get(context).getUser(),
        NotificationsCubit.get(context).initNotifications(),
      ]);
      FriendCubit.get(context).getMutedFriends();
      GroupCubit.get(context).getMutedGroups();
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacementNamed(context, Routes.login);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (_, state) {
        if (state is GetUserSuccess) {
          Navigator.pushReplacementNamed(context, Routes.layout);
        }
      },
      child: Scaffold(
        body: Center(
          child: Image.asset("assets/images/logo.png"),
        ),
      ),
    );
  }
}
