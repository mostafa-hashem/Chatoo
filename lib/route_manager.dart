import 'package:chat_app/features/auth/ui/screens/login_screen.dart';
import 'package:chat_app/features/auth/ui/screens/register_screen.dart';
import 'package:chat_app/features/auth/ui/screens/reset_password.dart';
import 'package:chat_app/features/friends/ui/screens/friend_info_screen.dart';
import 'package:chat_app/features/friends/ui/screens/friend_search_screen.dart';
import 'package:chat_app/features/friends/ui/screens/friend_chat_screen.dart';
import 'package:chat_app/features/groups/ui/screens/grop_search_screen.dart';
import 'package:chat_app/features/groups/ui/screens/group_chat_screen.dart';
import 'package:chat_app/features/groups/ui/screens/group_info_screen.dart';
import 'package:chat_app/features/groups/ui/screens/groups_screen.dart';
import 'package:chat_app/features/profile/ui/screens/profile_screen.dart';
import 'package:chat_app/ui/screens/home_layout.dart';
import 'package:chat_app/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String layout = "/layout";
  static const String splash = "/splashScreen";
  static const String login = "/login";
  static const String resetPassword = "/resetPassword";
  static const String register = "/register";
  static const String groupsScreen = "/groupsScreen";
  static const String groupChatScreen = "/groupChatScreen";
  static const String groupInfo = "/groupInfo";
  static const String groupSearchScreen = "/groupSearchScreen";
  static const String friendChatScreen = "/friendChatScreen";
  static const String friendInfoScreen = "/friendInfoScreen";
  static const String friendSearchScreen = "/friendSearchScreen";
  static const String profile = "/profile";
}

Route? onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Routes.layout:
      return MaterialPageRoute(
        builder: (_) => const HomeLayout(),
        settings: routeSettings,
      );
    case Routes.splash:
      return MaterialPageRoute(
        builder: (_) => const SplashScreen(),
      );
    case Routes.login:
      return MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      );
    case Routes.resetPassword:
      return MaterialPageRoute(
        builder: (_) => const ResetPasswordScreen(),
      );
    case Routes.register:
      return MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      );
    case Routes.groupsScreen:
      return MaterialPageRoute(
        builder: (_) => const GroupsScreen(),
        settings: routeSettings,
      );
    case Routes.groupChatScreen:
      return MaterialPageRoute(
        builder: (_) => const GroupChatScreen(),
        settings: routeSettings,
      );
    case Routes.groupInfo:
      return MaterialPageRoute(
        builder: (_) => const GroupInfo(),
        settings: routeSettings,
      );
    case Routes.groupSearchScreen:
      return MaterialPageRoute(
        builder: (_) => const GroupSearchScreen(),
        settings: routeSettings,
      );
    case Routes.friendChatScreen:
      return MaterialPageRoute(
        builder: (_) => const FriendChatScreen(),
        settings: routeSettings,
      );
      case Routes.friendInfoScreen:
      return MaterialPageRoute(
        builder: (_) => const FriendInfoScreen(),
        settings: routeSettings,
      );
    case Routes.friendSearchScreen:
      return MaterialPageRoute(
        builder: (_) => const FriendSearchScreen(),
        settings: routeSettings,
      );
    case Routes.profile:
      return MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      );
    default:
      return null;
  }
}
