import 'dart:io';

import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupWidget extends StatefulWidget {
  const CreateGroupWidget({super.key});

  @override
  State<CreateGroupWidget> createState() => _CreateGroupWidgetState();
}

class _CreateGroupWidgetState extends State<CreateGroupWidget> {
  String groupName = "";
  File? imageFile;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userData = ProfileCubit.get(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              "Create a group",
              textAlign: TextAlign.left,
              style: GoogleFonts.novaFlat(),
            ),
            content: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocConsumer<GroupCubit, GroupStates>(
                    listener: (_, state) {
                      if (state is UploadGroupImageToFireStorageLoading) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const LoadingIndicator();
                          },
                        );
                      } else {
                        if (state is UploadGroupImageToFireStorageError) {
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
                        if (state is UploadGroupImageToFireStorageSuccess) {
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
                    builder: (context, state) => GestureDetector(
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
                                .uploadGroupImageToFireStorage(
                              imageFile!,
                            );
                          }
                        }
                      },
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          if (GroupCubit.get(context).groupIcon.isNotEmpty)
                            FancyShimmerImage(
                              imageUrl: GroupCubit.get(context).groupIcon,
                              height: 115.h,
                              width: 115.w,
                            )
                          else
                            Container(
                              height: 130.h,
                              width: 145.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.r),
                              ),
                              child: const ClipOval(
                                child: Icon(Icons.groups_outlined),
                              ),
                            ),
                          const Icon(Icons.edit),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  TextFormField(
                    validator: (value) => validateGeneral(value, "group name"),
                    onChanged: (value) {
                      setState(() {
                        groupName = value;
                      });
                    },
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text("CANCEL"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final group = Group(
                    groupIcon: GroupCubit.get(context).groupIcon,
                    groupName: groupName,
                    mainAdminId: userData.user.id,
                    createdAt: DateTime.now(),
                    requests: [],
                    groupAdmins: [],
                  );
                  final user = User(
                    id: userData.user.id,
                    email: userData.user.email,
                    userName: userData.user.userName,
                    bio: userData.user.bio,
                    profileImage: userData.user.profileImage,
                    phoneNumber: userData.user.phoneNumber,
                  );
                  if (formKey.currentState!.validate()) {
                    GroupCubit.get(context)
                        .createGroup(
                      group,
                      user,
                    )
                        .whenComplete(
                      () {
                        Navigator.pop(context);
                        // GroupCubit.get(context).groupIcon = '';
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text("CREATE"),
              ),
            ],
          );
        },
      ),
    );
  }
}
