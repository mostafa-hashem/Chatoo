import 'package:chat_app/features/auth/ui/screens/login_screen.dart';
import 'package:chat_app/features/auth/ui/screens/register_screen.dart';
import 'package:chat_app/features/auth/ui/screens/reset_password.dart';
import 'package:chat_app/features/friends/ui/screens/friend_chat_screen.dart';
import 'package:chat_app/features/friends/ui/screens/friend_info_screen.dart';
import 'package:chat_app/features/friends/ui/screens/friend_search_screen.dart';
import 'package:chat_app/features/friends/ui/screens/requests_screen.dart';
import 'package:chat_app/features/groups/ui/screens/add_friends_to_group_screen.dart';
import 'package:chat_app/features/groups/ui/screens/grop_search_screen.dart';
import 'package:chat_app/features/groups/ui/screens/group_chat_screen.dart';
import 'package:chat_app/features/groups/ui/screens/group_info_screen.dart';
import 'package:chat_app/features/groups/ui/screens/groups_screen.dart';
import 'package:chat_app/features/groups/ui/screens/join_group_request_screen.dart';
import 'package:chat_app/features/profile/ui/screens/profile_screen.dart';
import 'package:chat_app/features/stories/ui/screens/stories_screen.dart';
import 'package:chat_app/features/stories/ui/screens/story_view.dart';
import 'package:chat_app/ui/screens/home_layout.dart';
import 'package:chat_app/ui/screens/media_view.dart';
import 'package:chat_app/ui/screens/splash_screen.dart';
import 'package:chat_app/ui/screens/suggestions_screens.dart';
import 'package:chat_app/ui/screens/update_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String updateScreen = "/updateScreen";
  static const String layout = "/layout";
  static const String splash = "/splashScreen";
  static const String login = "/login";
  static const String resetPassword = "/resetPassword";
  static const String register = "/register";
  static const String storiesScreen = "/storiesScreen";
  static const String groupsScreen = "/groupsScreen";
  static const String groupChatScreen = "/groupChatScreen";
  static const String groupInfo = "/groupInfo";
  static const String requestsScreen = "/requestsScreen";
  static const String addFriendsToGroup = "/addFriendToGroup";
  static const String joinGroupRequestsScreen = "/joinGroupRequestsScreen";
  static const String groupSearchScreen = "/groupSearchScreen";
  static const String friendChatScreen = "/friendChatScreen";
  static const String friendInfoScreen = "/friendInfoScreen";
  static const String friendSearchScreen = "/friendSearchScreen";
  static const String profile = "/profile";
  static const String suggestionsScreen = "/suggestionsScreen";
  static const String mediaView = "/mediaView";
  static const String storyView = "/storyView";
}

Route? onGenerateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case Routes.updateScreen:
      return MaterialPageRoute(
        builder: (_) => const UpdateScreen(),
        settings: routeSettings,
      );
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
        settings: routeSettings,
      );
    case Routes.resetPassword:
      return MaterialPageRoute(
        builder: (_) => const ResetPasswordScreen(),
      );
    case Routes.register:
      return MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      );
    case Routes.storiesScreen:
      return MaterialPageRoute(
        builder: (_) => StoriesScreen(),
        settings: routeSettings,
      );
    case Routes.requestsScreen:
      return MaterialPageRoute(
        builder: (_) => const RequestsScreen(),
        settings: routeSettings,
      );
    case Routes.groupsScreen:
      return MaterialPageRoute(
        builder: (_) => GroupsScreen(),
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
    case Routes.addFriendsToGroup:
      return MaterialPageRoute(
        builder: (_) => const AddFriendsToGroupScreen(),
        settings: routeSettings,
      );
    case Routes.joinGroupRequestsScreen:
      return MaterialPageRoute(
        builder: (_) => const JoinGroupRequestsScreen(),
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
    case Routes.suggestionsScreen:
      return MaterialPageRoute(
        builder: (_) => const SuggestionsScreen(),
      );
    case Routes.mediaView:
      return MaterialPageRoute(
        builder: (_) => const MediaView(),
        settings: routeSettings,
      );
    case Routes.storyView:
      return MaterialPageRoute(
        builder: (_) => const StoryView(),
        settings: routeSettings,
      );
    default:
      return null;
  }
}
