import 'package:chat_app/features/friends/ui/screens/friends_screen.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/ui/screens/groups_screen.dart';
import 'package:chat_app/features/groups/ui/widgets/creat_group_widget.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/drawer_tile.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  late final TabController _tabController;
  String appBarTitle = "Chats";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    GroupCubit.get(context).getAllUserGroups();
  }

  void _handleTabChange() {
    setState(() {
      if (_tabController.index == 0) {
        appBarTitle = AppLocalizations.of(context)!.chats;
      } else {
        appBarTitle = AppLocalizations.of(context)!.groups;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                showLanguageSheet(context);
              },
              icon: const Icon(
                Icons.translate,
              ),
            ),
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
                _tabController.index == 0
                    ? Navigator.pushNamed(context, Routes.friendSearchScreen)
                    : Navigator.pushNamed(context, Routes.groupSearchScreen);
              },
              icon: const Icon(
                Icons.search,
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: <Widget>[
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
              controller: _tabController,
              children: const <Widget>[
                FriendsScreen(),
                GroupsScreen(),
              ],
            ),
          ],
        ),
        floatingActionButton: _tabController.index == 1
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
