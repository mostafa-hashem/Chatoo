import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/screens/friends_screen.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/ui/screens/groups_screen.dart';
import 'package:chat_app/features/groups/ui/widgets/creat_group_widget.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/stories/ui/screens/stories_screen.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/drawer_tile.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_handleTabChange);
    Future.wait([
      GroupCubit.get(context).getAllUserGroups(),
      FriendCubit.get(context).getAllUserRequests(),
    ]);
    ProfileCubit.get(context).fetchStories();
    FriendCubit.get(context).getCombinedFriends();
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    final friendCubit = FriendCubit.get(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: BlocBuilder<FriendCubit, FriendStates>(
            buildWhen: (_, currentState) =>
                currentState is GetAllUserRequestsLoading ||
                currentState is GetAllUserRequestsSuccess ||
                currentState is GetAllUserRequestsError,
            builder: (context, state) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  if (friendCubit.allUserRequests.isNotEmpty)
                    const Positioned(
                      right: 11,
                      top: 11,
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                provider.themeMode == ThemeMode.light
                    ? provider.changeTheme(ThemeMode.dark)
                    : provider.changeTheme(ThemeMode.light);
              },
              icon: Icon(
                provider.themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
            if (tabController.index != 2)
              IconButton(
                onPressed: () {
                  tabController.index == 0
                      ? Navigator.pushNamed(context, Routes.friendSearchScreen)
                      : Navigator.pushNamed(context, Routes.groupSearchScreen);
                },
                icon: const Icon(
                  Icons.search,
                ),
              ),
          ],
          bottom: TabBar(
            controller: tabController,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(
                child: Text(
                  "Chats",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  "Groups",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white),
                ),
              ),
              Tab(
                child: Text(
                  "Stories",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        drawer: const Drawer(
          child: DrawerTile(),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: tabController,
              children: [
                BlocBuilder<FriendCubit, FriendStates>(
                  buildWhen: (_, currentState) =>
                      currentState is GetCombinedFriendsLoading ||
                      currentState is GetCombinedFriendsSuccess ||
                      currentState is GetCombinedFriendsError,
                  builder: (_, state) {
                    if (state is GetAllUserFriendsLoading) {
                      return const LoadingIndicator();
                    } else if (state is GetAllUserFriendsError) {
                      return const ErrorIndicator();
                    } else {
                      return const FriendsScreen();
                    }
                  },
                ),
                BlocConsumer<GroupCubit, GroupStates>(
                  listenWhen:  (_, current) =>
                  current is CreateGroupError ||
                      current is CreateGroupLoading ||
                      current is CreateGroupSuccess ||
                      current is GetAllGroupsLoading ||
                      current is GetAllGroupsSuccess ||
                      current is GetAllGroupsError,
                  listener: (_, state) {
                    if (state is CreateGroupLoading) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const LoadingIndicator();
                        },
                      );
                    } else {
                      if (state is CreateGroupError) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.message,
                              style: const TextStyle(fontSize: 15),
                            ),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                      if (state is CreateGroupSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Successfully Created",
                              style: TextStyle(fontSize: 15),
                            ),
                            backgroundColor: AppColors.accent,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  // buildWhen: (_, current) =>
                  //     current is CreateGroupError ||
                  //     current is CreateGroupLoading ||
                  //     current is CreateGroupSuccess ||
                  //     current is GetAllGroupsLoading ||
                  //     current is GetAllGroupsSuccess ||
                  //     current is GetAllGroupsError,
                  builder: (_, state) => GroupsScreen(),
                ),
                StoriesScreen(),
              ],
            ),
          ],
        ),
        floatingActionButton: tabController.index == 1
            ? FloatingActionButton(
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return const CreateGroupWidget();
                    },
                  );
                },
                elevation: 0,
                backgroundColor: AppColors.accent,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              )
            : null,
      ),
    );
  }
}
