import 'dart:io';

import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_members.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
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
import 'package:image_picker/image_picker.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo({
    super.key,
  });

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  File? imageFile;
  final GlobalKey listTileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    final groupCubit = GroupCubit.get(context);
    final profileCubit = ProfileCubit.get(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Group Info",
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Exit"),
                    content:
                        const Text("Are you sure you want Exit the group ?"),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                      BlocListener<GroupCubit, GroupStates>(
                        listener: (_, state) {
                          if (state is LeaveGroupLoading) {
                            const LoadingIndicator();
                          } else {
                            if (state is LeaveGroupSuccess) {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                              groupCubit.sendMessageToGroup(
                                group: groupData,
                                sender: profileCubit.user,
                                message:
                                    '${profileCubit.user.userName} left the group',
                                type: MessageType.text,
                                isAction: true,
                              );
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                Routes.layout,
                                (route) => false,
                              );
                            }
                            if (state is LeaveGroupError) {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                              const ErrorIndicator();
                            }
                          }
                        },
                        child: IconButton(
                          onPressed: () {
                            GroupCubit.get(context).leaveGroup(
                              groupData,
                              ProfileCubit.get(context).user,
                            );
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        child: ListView(
          key: listTileKey,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    if (groupData.groupAdmins!
                        .any((groupId) => groupId == profileCubit.user.id!))
                      BlocBuilder<GroupCubit, GroupStates>(
                        builder: (_, state) {
                          return GestureDetector(
                            onTap: () {
                              groupCubit
                                  .getAllGroupMRequests(groupData.groupId!);
                              Navigator.pushNamed(
                                context,
                                Routes.joinGroupRequestsScreen,
                                arguments: groupData,
                              );
                            },
                            child: Stack(
                              alignment: Alignment.topLeft,
                              children: [
                                if (groupData.requests == null ||
                                    groupData.requests!.isNotEmpty)
                                  Container(
                                    width: 24, // Adjust as needed
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        groupData.requests!.length.toString(),
                                      ),
                                    ),
                                  ),
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(Icons.group_add_outlined),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        showMenu(
                          context: context,
                          position: RelativeRect.fromRect(
                            getWidgetPosition(listTileKey),
                            Offset.zero & MediaQuery.of(context).size,
                          ),
                          items: [
                            if (groupData.groupAdmins!.any(
                              (adminId) => adminId == profileCubit.user.id,
                            ))
                                PopupMenuItem(
                                  child: TextButton(
                                    onPressed: () {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                      showChangeGroupNameSheet(
                                        context,
                                        groupData.groupId!,
                                        groupData.groupName!,
                                      );
                                    },
                                    child: const Text('Change group name'),
                                  ),
                                ),
                            PopupMenuItem(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    Routes.addFriendsToGroup,
                                    arguments: groupData,
                                  );
                                },
                                child: const Text('Add friend'),
                              ),
                            ),
                            if (groupData.mainAdminId == profileCubit.user.id!)
                              PopupMenuItem(
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: const Text(
                                            "Are you sure you want delete the group ?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            BlocListener<GroupCubit,
                                                GroupStates>(
                                              listener: (_, state) {
                                                if (state
                                                    is DeleteGroupLoading) {
                                                  const LoadingIndicator();
                                                } else {
                                                  if (context.mounted) {
                                                    Navigator.pop(context);
                                                  }
                                                  if (state
                                                      is DeleteGroupSuccess) {
                                                    Navigator
                                                        .pushReplacementNamed(
                                                      context,
                                                      Routes.layout,
                                                    );
                                                  }
                                                  if (state
                                                      is DeleteGroupError) {
                                                    const ErrorIndicator();
                                                  }
                                                }
                                              },
                                              child: TextButton(
                                                onPressed: () {
                                                  groupCubit.deleteGroup(
                                                    groupData.groupId!,
                                                  );
                                                },
                                                child: const Text("Delete"),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Delete group'),
                                ),
                              ),
                          ],
                        );
                      },
                      child: const Icon(Icons.more_vert_outlined),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.03,
                ),
                BlocListener<GroupCubit, GroupStates>(
                  listener: (_, state) {
                    if (state is UploadImageAndUpdateGroupIconLoading) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const LoadingIndicator();
                        },
                      );
                    } else {
                      if (state is UploadImageAndUpdateGroupIconError) {
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
                      if (state is UploadImageAndUpdateGroupIconSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Successfully Uploaded",
                              style: TextStyle(fontSize: 15),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      if (groupData.groupIcon!.isNotEmpty)
                        InkWell(
                          onTap: () => showImageDialog(
                            context,
                            groupData.groupIcon!,
                          ),
                          child: FancyShimmerImage(
                            imageUrl: groupData.groupIcon!,
                            height: 140.h,
                            width: 170.w,
                            boxFit: BoxFit.contain,
                            errorWidget:
                                const Icon(Icons.error_outline_outlined),
                          ),
                        )
                      else
                        ClipOval(
                          child: SizedBox(
                            height: 140.h,
                            width: 170.w,
                            child: const Icon(
                              Icons.groups_outlined,
                              size: 90,
                            ),
                          ),
                        ),
                      if (groupData.groupAdmins!.any(
                        (adminId) =>
                            adminId == ProfileCubit.get(context).user.id!,
                      ))
                        GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? xFile = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (xFile != null) {
                              File xFilePathToFile(XFile xFile) {
                                return File(xFile.path);
                              }

                              imageFile = xFilePathToFile(xFile);
                              if (context.mounted) {
                                GroupCubit.get(context)
                                    .uploadImageAndUpdateGroupIcon(
                                  imageFile!,
                                  groupData.groupId!,
                                )
                                    .then((downloadUrl) {
                                  setState(() {
                                    groupData.groupIcon = downloadUrl;
                                  });
                                });
                              }
                            }
                          },
                          child: const Icon(Icons.edit),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.03,
                ),
                Text(
                  "${groupData.groupName}",
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
                BlocBuilder<GroupCubit, GroupStates>(
                  builder: (context, state) {
                    if (state is GetAllGroupMembersLoading) {
                      return const LoadingIndicator();
                    } else if (state is GetAllGroupMembersLoading) {
                      return const ErrorIndicator();
                    }
                    return GroupMembers(
                      group: groupData,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
