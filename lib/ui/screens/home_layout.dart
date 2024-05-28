import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/screens/friends_screen.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/ui/screens/groups_screen.dart';
import 'package:chat_app/features/groups/ui/widgets/creat_group_widget.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/drawer_tile.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

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
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabChange);
    Future.wait([
      GroupCubit.get(context).getAllUserGroups(),
      FriendCubit.get(context).getAllUserRequests(),
    ]);
    FriendCubit.get(context).getCombinedFriends();
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            // IconButton(
            //   onPressed: () {
            //     showLanguageSheet(context);
            //   },
            //   icon: const Icon(
            //     Icons.translate,
            //   ),
            // ),
            IconButton(
              onPressed: () {
                showThemeSheet(context);
              },
              icon: Icon(
                provider.themeMode == ThemeMode.light
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
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
            tabs: [
              Tab(
                child:
                    Text("Chats", style: Theme.of(context).textTheme.bodySmall),
              ),
              Tab(
                child: Text(
                  "Groups",
                  style: Theme.of(context).textTheme.bodySmall,
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
                BlocListener<GroupCubit, GroupStates>(
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
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: GroupsScreen(),
                ),
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
                backgroundColor: AppColors.primary,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
