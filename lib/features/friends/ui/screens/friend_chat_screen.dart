import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_chat_messages.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/notifications/cubit/notifications_states.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FriendChatScreen extends StatefulWidget {
  const FriendChatScreen({
    super.key,
  });

  @override
  State<FriendChatScreen> createState() => _FriendChatScreenState();
}

class _FriendChatScreenState extends State<FriendChatScreen> {
  bool emojiShowing = false;
  late FriendCubit friendCubit;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    friendCubit = FriendCubit.get(context);
  }

  void scrollToBottom() {
    FriendCubit.get(context).scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
        );
  }

  @override
  Widget build(BuildContext context) {
    final friendData = ModalRoute.of(context)!.settings.arguments! as User;
    final sender = ProfileCubit.get(context).user;
    final provider = Provider.of<MyAppProvider>(context);
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
                    width: 40.w,
                    height: 36.h,
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
                child: Text(
                  friendData.userName!,
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Container(
              height: 60.h,
              color: Colors.grey[600],
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          emojiShowing = !emojiShowing;
                          FocusScope.of(context).unfocus();
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: TextField(
                        controller: friendCubit.messageController,
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: provider.themeMode == ThemeMode.light
                              ? Colors.black87
                              : AppColors.light,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          hintStyle: Theme.of(context).textTheme.bodySmall,
                          filled: true,
                          fillColor: provider.themeMode == ThemeMode.light
                              ? Colors.white
                              : AppColors.dark,
                          contentPadding: const EdgeInsets.only(
                            left: 16.0,
                            bottom: 8.0,
                            top: 8.0,
                            right: 16.0,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  BlocListener<NotificationsCubit, NotificationsStates>(
                    listener: (_, state) {
                      if (state is SendNotificationSuccess) {}
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () {
                          final notificationBody =
                              friendCubit.messageController.text;
                          if (friendCubit.messageController.text.isNotEmpty) {
                            friendCubit.messageController.clear();
                            FriendCubit.get(context)
                                .sendMessageToFriend(
                              friendData,
                              notificationBody,
                              sender,
                            )
                                .whenComplete(
                              () {
                                scrollToBottom();
                                NotificationsCubit.get(context)
                                    .sendNotification(
                                  friendData.fCMToken ?? '',
                                  sender.userName!,
                                  notificationBody,
                                  'friend',
                                );
                              },
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: !emojiShowing,
              child: SizedBox(
                height: 220.h,
                child: EmojiPicker(
                  textEditingController: friendCubit.messageController,
                  config: Config(
                    emojiSizeMax: 30 *
                        (foundation.defaultTargetPlatform == TargetPlatform.iOS
                            ? 1.30
                            : 1.0),
                    bgColor: provider.themeMode == ThemeMode.light
                        ? const Color(0xFFF2F2F2)
                        : AppColors.dark,
                    indicatorColor: AppColors.primary,
                    iconColorSelected: AppColors.primary,
                    backspaceColor: AppColors.primary,
                    noRecents: Text(
                      'No Recents',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
