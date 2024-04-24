import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditBioBottomSheet extends StatefulWidget {
  final String bio;

  const EditBioBottomSheet(this.bio);

  @override
  State<EditBioBottomSheet> createState() => _EditBioBottomSheetState();
}

class _EditBioBottomSheetState extends State<EditBioBottomSheet> {
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    bioController.text = widget.bio;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        top: 24.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: bioController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.borderColor, width: 2.w),
                borderRadius: BorderRadius.circular(7.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.borderColor, width: 2.w),
                borderRadius: BorderRadius.circular(7.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColors.borderColor, width: 2.w),
                borderRadius: BorderRadius.circular(7.r),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),
          BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is UpdateUserBioSuccess) {
                profileCubit.getUser();
                showSnackBar(
                  context,
                  Colors.greenAccent,
                  'Bio updated successfully',
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: DefaultTextButton(
              function: () {
                if (bioController.text == widget.bio) {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  profileCubit.updateBio(bioController.text);
                }
              },
              text: 'Save',
              width: 140.w,
            ),
          ),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.08,
          ),
        ],
      ),
    );
  }
}
