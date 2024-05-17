import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupTile extends StatefulWidget {
  const GroupTile({
    super.key,
    required this.userName,
    required this.groupData,
    required this.isLeftOrJoined,
  });

  final String userName;
  final Group groupData;
  final bool isLeftOrJoined;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  final GlobalKey listTileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final groupCubit = GroupCubit.get(context);
    return InkWell(
      onTap: () {
        groupCubit.getAllGroupMembers(
          widget.groupData.groupId!,
        );
        groupCubit
            .getAllGroupMessages(
              widget.groupData.groupId!,
            )
            .whenComplete(
              () => Future.delayed(
                const Duration(
                  milliseconds: 50,
                ),
                () => Navigator.pushNamed(
                  context,
                  Routes.groupChatScreen,
                  arguments: widget.groupData,
                ),
              ),
            );
      },
      onLongPress: () {
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            getWidgetPosition(listTileKey),
            Offset.zero & MediaQuery.of(context).size,
          ),
          items: [
            PopupMenuItem(
              child: TextButton(
                onPressed: () {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Mute'),
              ),
            ),
            PopupMenuItem(
              child: TextButton(
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: const Text(
                          "Are you sure you want leave the group ?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          BlocListener<GroupCubit, GroupStates>(
                            listener: (_, state) {
                              if (state is DeleteGroupLoading) {
                                const LoadingIndicator();
                              } else {
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                                if (state is DeleteGroupSuccess) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    Routes.layout,
                                  );
                                }
                                if (state is DeleteGroupError) {
                                  const ErrorIndicator();
                                }
                              }
                            },
                            child: TextButton(
                              onPressed: () {},
                              child: const Text("Leave"),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Leave group'),
              ),
            ),
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          key: listTileKey,
          leading: widget.groupData.groupIcon!.isEmpty
              ? CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.groupData.groupName!.substring(0, 1).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                )
              : InkWell(
                  onTap: () =>
                      showImageDialog(context, widget.groupData.groupIcon!),
                  child: ClipOval(
                    child: FancyShimmerImage(
                      imageUrl: widget.groupData.groupIcon!,
                      width: 50.w,
                    ),
                  ),
                ),
          title: Text(
            widget.groupData.groupName!,
            style: GoogleFonts.novaSquare(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Test for last message",
            style: GoogleFonts.ubuntu(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
