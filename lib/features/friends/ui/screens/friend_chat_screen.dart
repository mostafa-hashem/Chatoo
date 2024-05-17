
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_chat_messages.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_type_message_widget.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendChatScreen extends StatefulWidget {
  const FriendChatScreen({
    super.key,
  });

  @override
  State<FriendChatScreen> createState() => _FriendChatScreenState();
}

class _FriendChatScreenState extends State<FriendChatScreen> {
  late FriendCubit friendCubit;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    friendCubit = FriendCubit.get(context);
  }

  @override
  void dispose() {
    friendCubit.filteredMessages.clear();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final friendData = ModalRoute.of(context)!.settings.arguments! as User;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          title: Row(
            children: [
              if (friendData.profileImage != null &&
                  friendData.profileImage!.isNotEmpty)
                ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: friendData.profileImage!,
                    width: 44.w,
                    height: 40.h,
                  ),
                )
              else
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.dark,
                  child: Text(
                    friendData.userName!.substring(0, 1).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(
                width: 10.w,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friendCubit.friendData?.userName ?? '',
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    BlocBuilder<FriendCubit, FriendStates>(
                      buildWhen: (_, current) =>
                          current is GetFriendDataError ||
                          current is GetFriendDataSuccess ||
                          current is GetFriendDataLoading,
                      builder: (_, state) {
                        if (friendCubit.friendData?.onLine != null) {
                          return Row(
                            children: [
                              if (friendCubit.friendData!.onLine!)
                                Icon(
                                  Icons.circle,
                                  color: Colors.greenAccent,
                                  size: 10.r,
                                )
                              else
                                Icon(
                                  Icons.circle,
                                  color: Colors.grey,
                                  size: 10.r,
                                ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.01,
                              ),
                              Text(
                                friendCubit.friendData!.onLine!
                                    ? 'Online'
                                    : 'Offline',
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.friendInfoScreen,
                  arguments: friendData,
                );
              },
              icon: const Icon(Icons.info),
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<FriendCubit, FriendStates>(
              buildWhen: (_, currentState) =>
                  currentState is GetAllFriendMessagesSuccess ||
                  currentState is GetAllFriendMessagesError ||
                  currentState is GetAllFriendMessagesLoading,
              builder: (_, state) {
                return FriendChatMessages();
              },
            ),
            FriendTypeMessageWidget(
              friendData: friendData,
            ),
          ],
        ),
      ),
    );
  }
}
