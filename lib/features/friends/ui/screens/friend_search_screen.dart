import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_search_widget.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendSearchScreen extends StatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {

  @override
  void deactivate() {
    FriendCubit.get(context).searchedFriends.clear();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final friendData = FriendCubit.get(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          "Search",
          style: GoogleFonts.ubuntu(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      if (value.isEmpty) {
                        friendData.searchedFriends.clear();
                      }
                      if (value.isNotEmpty) {
                        friendData.searchOnFriend(value);
                      }
                    },
                    style: GoogleFonts.ubuntu(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search friends....",
                      hintStyle: GoogleFonts.novaFlat(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<FriendCubit, FriendStates>(
              builder: (context, state) {
                return ListView.separated(
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      // friendData.checkUserInGroup(
                      //   userdata.user.id!,
                      //   friendData.allUserGroups[index].groupId,
                      // );
                    },
                    child: FriendSearchWidget(
                      friendData: friendData.searchedFriends[index],
                      isFriend: false,
                    ),
                  ),
                  separatorBuilder: (context, index) => Divider(
                    thickness: 4.h,
                  ),
                  itemCount: friendData.searchedFriends.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
