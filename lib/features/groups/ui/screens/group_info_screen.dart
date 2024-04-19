import 'dart:io';

import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_members.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    final groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    final groupCubit = GroupCubit.get(context);
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
                        listener: (c, state) {
                          if (state is LeaveGroupLoading) {
                            const LoadingIndicator();
                          } else {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            if (state is LeaveGroupSuccess) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                Routes.layout,
                                (route) => false,
                              );
                            }
                            if (state is LeaveGroupError) {
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
      body: BlocBuilder<GroupCubit, GroupStates>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ListView(
              children: [
                Column(
                  children: [
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
                      child: GestureDetector(
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
                                groupData.groupId,
                              )
                                  .then((downloadUrl) {
                                setState(() {
                                  groupData.groupIcon = downloadUrl!;
                                });
                              });
                            }
                          }
                        },
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            if (groupData.groupIcon.isNotEmpty)
                              InkWell(
                                onTap: () => showImageDialog(
                                  context,
                                  groupData.groupIcon,
                                ),
                                child: FancyShimmerImage(
                                  imageUrl: groupData.groupIcon,
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
                            const Icon(Icons.edit),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    BlocBuilder<GroupCubit, GroupStates>(
                      builder: (context, state) {
                        if (state is GetAdminNameLoading) {
                          return Container(
                            height: 100.h,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                            child: const LoadingIndicator(),
                          );
                        } else if (state is GetAdminNameError) {
                          return const ErrorIndicator();
                        }
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30.r,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  groupCubit.adminName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.04,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Group: ${groupData.groupName}",
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  Text(
                                    "Admin: ${groupCubit.adminName}",
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    BlocBuilder<GroupCubit, GroupStates>(
                      builder: (context, state) {
                        if (state is GetAllGroupMembersLoading) {
                          return const LoadingIndicator();
                        } else if (state is GetAllGroupMembersLoading) {
                          return const ErrorIndicator();
                        }
                        return GroupMembers();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
