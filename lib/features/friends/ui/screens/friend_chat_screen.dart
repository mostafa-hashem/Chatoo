import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/combined_friend.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_chat_messages.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_type_message_widget.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
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
  late CombinedFriend friendData;
  final audioPlayer = AudioPlayer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    friendCubit = FriendCubit.get(context);
    friendData = ModalRoute.of(context)!.settings.arguments! as CombinedFriend;
    friendCubit.listenToTypingStatus(friendData.user!.id!);
    friendCubit.listenToRecordingStatus(friendData.user!.id!);
  }

  @override
  void dispose() {
    friendCubit.filteredMessages.clear();
    friendCubit.setRepliedMessage(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              if (friendData.user?.profileImage != null &&
                  friendData.user!.profileImage!.isNotEmpty)
                ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: friendCubit.friendData?.profileImage ??
                        friendData.user!.profileImage!,
                    width: 44.w,
                    height: 40.h,
                    errorWidget: ClipOval(
                      child: FancyShimmerImage(
                        imageUrl: FirebasePath.defaultImage,
                        width: 44.w,
                        height: 40.w,
                      ),
                    ),
                  ),
                )
              else
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.dark,
                  child: Text(
                    friendCubit.friendData?.userName
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        friendData.user!.userName!
                            .substring(0, 1)
                            .toUpperCase(),
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
                      friendCubit.friendData?.userName ?? friendData.user!.userName!,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    BlocBuilder<FriendCubit, FriendStates>(
                      buildWhen: (_, current) =>
                          current is UpdateTypingStatus ||
                          current is UpdateRecordingStatus ||
                          current is UpdateTypingStatusSuccess ||
                          current is UpdateTypingStatusError ||
                          current is UpdateTypingStatusLoading ||
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
                                friendCubit.friendData?.lastSeen != null
                                    ? const SizedBox.shrink()
                                    : Icon(
                                        Icons.circle,
                                        color: Colors.grey,
                                        size: 10.r,
                                      ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.01,
                              ),
                              Flexible(
                                child: Text(
                                  friendCubit.isTyping
                                      ? 'Typing...'
                                      : friendCubit.isRecording
                                          ? 'Recording...'
                                          : friendCubit.friendData!.onLine!
                                              ? 'Online'
                                              : friendCubit.friendData
                                                          ?.lastSeen !=
                                                      null
                                                  ? "Last seen: ${getFormattedTime(
                                                      friendCubit
                                                          .friendData!
                                                          .lastSeen!
                                                          .millisecondsSinceEpoch,
                                                    )}"
                                                  : 'Offline',
                                  style: GoogleFonts.ubuntu(
                                    color: friendCubit.isTyping ||
                                            friendCubit.isRecording
                                        ? Colors.greenAccent
                                        : null,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 9.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                  arguments: friendCubit.friendData ?? friendData,
                );
              },
              icon: const Icon(Icons.info),
            ),
          ],
        ),
        body: Column(
          children: [
            BlocConsumer<FriendCubit, FriendStates>(
              listener: (_, state) {
                if (state is GetAllFriendMessagesSuccess) {
                  // audioPlayer.play(AssetSource("audios/message_received.wav"));
                }
                if (state is GetCombinedFriendsSuccess) {
                  // audioPlayer.play(AssetSource("audios/message_received.wav"));
                  friendCubit.markMessagesAsRead(friendData.user!.id!);
                }
              },
              buildWhen: (_, currentState) =>
                  currentState is GetAllFriendMessagesSuccess ||
                  currentState is GetAllFriendMessagesError ||
                  currentState is GetAllFriendMessagesLoading,
              builder: (_, state) {
                if (state is GetAllFriendMessagesLoading) {
                  return const LoadingIndicator();
                }
                return FriendChatMessages(
                  friendData: friendCubit.friendData ?? User.empty(),
                );
              },
            ),
            FriendTypeMessageWidget(
              friendData: friendCubit.friendData ?? friendData.user!,
            ),
          ],
        ),
      ),
    );
  }
}
