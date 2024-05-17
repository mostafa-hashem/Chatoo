import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_search_widget.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
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
  late FriendCubit friendCubit;

  @override
  void didChangeDependencies() {
    friendCubit = FriendCubit.get(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    friendCubit.searchedFriends.clear();
    super.dispose();
  }

  @override
  void deactivate() {
    friendCubit.searchedFriends.clear();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final friendCubit = FriendCubit.get(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
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
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        if (value.isEmpty) {
                          friendCubit.searchedFriends.clear();
                        }
                        if (value.isNotEmpty) {
                          friendCubit.searchOnFriend(value);
                        }
                      },
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search friends....",
                        hintStyle: GoogleFonts.novaFlat(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 40.w,
                    height: 40.h,
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
              child: BlocConsumer<FriendCubit, FriendStates>(
                listener: (_, state) {
                  if (state is RequestToAddFriendLoading) {
                    const LoadingIndicator();
                  } else {
                    if (state is RequestToAddFriendSuccess) {
                      showSnackBar(
                        context,
                        Colors.green,
                        "Requested successfully",
                      );
                    }
                    if (state is RequestToAddFriendError) {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      const ErrorIndicator();
                    }
                  }
                  if (state is RemoveFriendLoading) {
                    const LoadingIndicator();
                  } else {
                    if (state is RemoveFriendSuccess) {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      showSnackBar(
                        context,
                        Colors.green,
                        "Friend removed successfully",
                      );
                    }
                    if (state is RequestToAddFriendError) {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                      const ErrorIndicator();
                    }
                  }
                  if (state is RemoveFriendRequestSuccess) {
                    showSnackBar(
                      context,
                      Colors.green,
                      "Request removed successfully",
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                builder: (_, state) {
                  return ListView.separated(
                    itemBuilder: (_, index) => FriendSearchWidget(
                      friendData: friendCubit.searchedFriends[index],
                      isUserFriend: friendCubit.allFriends.any(
                        (friend) =>
                            friend != null &&
                            friend.id!.contains(
                              friendCubit.searchedFriends[index].id!,
                            ),
                      ),
                      isRequested: friendCubit.searchedFriends.any(
                        (friend) => friend.requests!.any(
                          (id) => id.toString().contains(
                                ProfileCubit.get(context).user.id ?? "",
                              ),
                        ),
                      ),
                    ),
                    separatorBuilder: (context, index) => Divider(
                      thickness: 4.h,
                    ),
                    itemCount: friendCubit.searchedFriends.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
