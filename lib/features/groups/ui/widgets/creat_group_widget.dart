import 'dart:io';

import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
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
  late GroupCubit groupCubit;

  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
  }

  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            minimumAspectRatio: 1.0,
          ),
          WebUiSettings(
            context: context,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          imageFile = File(croppedFile.path);
        });
        if(context.mounted){
          groupCubit.uploadGroupImageToFireStorage(imageFile!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ProfileCubit.get(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Create a Group",
                    style: GoogleFonts.novaFlat(
                      textStyle: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: _pickAndCropImage,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 150.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: imageFile != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Center(
                          child: Icon(
                            Icons.group,
                            size: 60.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 20.r,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    validator: (value) => validateGeneral(value, "Group name"),
                    onChanged: (value) {
                      setState(() {
                        groupName = value;
                      });
                    },
                    style: TextStyle(fontSize: 16.sp),
                    decoration: InputDecoration(
                      labelText: 'Group name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 14.h,
                        horizontal: 16.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 24.w,
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    ElevatedButton(
                      onPressed: () async {
                        final group = Group(
                          groupIcon: groupCubit.groupIcon,
                          groupName: groupName,
                          mainAdminId: userData.user.id,
                          createdAt: DateTime.now(),
                          recentMessageSentAt: DateTime.now(),
                          requests: [],
                          groupAdmins: [],
                        );
                        final user = userData.user;
                        if (formKey.currentState!.validate()) {
                          groupCubit.createGroup(group, user).whenComplete(() {
                            Navigator.pop(context);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                          horizontal: 24.w,
                        ),
                      ),
                      child: Text(
                        "Create",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
