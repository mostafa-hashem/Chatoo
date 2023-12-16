import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/ui/widgets/chat_messages.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/shared/provider/app_provider.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({
    super.key,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  TextEditingController messageController = TextEditingController();

  bool emojiShowing = false;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _onBackspacePressed() {
    messageController
      ..text = messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length),
      );
  }
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    final sender = ProfileCubit.get(context).user;
    final groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupData.groupName,
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.groupInfo,
                arguments: groupData,
              );
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          BlocConsumer<GroupCubit, GroupStates>(
            listener: (context, state) {

            },
            builder: (context, state) {
              if(state is GetAllGroupMessagesLoading){
                return const Expanded(child: LoadingIndicator());
              }
              return ChatMessages(
                groupData: GroupCubit.get(context).filteredMessages,
              );
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
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: messageController,
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
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      if (messageController.text.isNotEmpty) {
                        GroupCubit.get(context).sendMessage(
                          groupData,
                          sender,
                          messageController.text,
                        );
                        setState(() {
                          messageController.clear();
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
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
                textEditingController: messageController,
                onBackspacePressed: _onBackspacePressed,
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
    );
  }
}
