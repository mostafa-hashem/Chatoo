import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_chat_messages.dart';
import 'package:chat_app/features/groups/ui/widgets/group_type_message_widget.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({
    super.key,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  late GroupCubit groupCubit;
  final audioPlayer = AudioPlayer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    groupCubit.filteredMessages.clear();
    groupCubit.allGroupMembers.clear();
    groupCubit.allGroupRequests.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    final profileCubit = ProfileCubit.get(context);
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
              if (groupData.groupIcon!.isNotEmpty)
                ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: groupData.groupIcon!,
                    width: 40.w,
                    height: 36.h,
                    errorWidget: ClipOval(
                      child: SizedBox(
                        height: 40.h,
                        width: 40.w,
                        child: const Icon(
                          Icons.groups_outlined,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                )
              else
                ClipOval(
                  child: SizedBox(
                    height: 40.h,
                    width: 40.w,
                    child: const Icon(
                      Icons.groups_outlined,
                      size: 35,
                    ),
                  ),
                ),
              SizedBox(
                width: 10.w,
              ),
              Flexible(
                child: Text(
                  groupData.groupName!,
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<GroupCubit, GroupStates>(
              buildWhen: (_, currentState) =>
                  currentState is GetAllGroupRequestsSuccess ||
                  currentState is GetAllGroupRequestsError ||
                  currentState is GetAllGroupRequestsLoading,
              builder: (_, state) {
                return Stack(
                  alignment: Alignment.topLeft,
                  children: [
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
                    if (groupData.requests!.isNotEmpty &&
                        groupData.groupAdmins!.any(
                          (adminId) => adminId == profileCubit.user.id,
                        ))
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircleAvatar(
                          radius: 6.r,
                          backgroundColor: Colors.black,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            BlocConsumer<GroupCubit, GroupStates>(
              listener: (context, state) {
                if (state is GetAllGroupMembersSuccess) {
                  // audioPlayer.play(AssetSource("audios/message_received.wav"));
                }
              },
              buildWhen: (_, currentState) =>
                  currentState is GetAllGroupMessagesSuccess ||
                  currentState is GetAllGroupMessagesError ||
                  currentState is GetAllGroupMessagesLoading,
              builder: (_, state) {
                return GroupChatMessages();
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            GroupTypeMessageWidget(
              groupData: groupData,
            ),
          ],
        ),
      ),
    );
  }
}
