import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangeGroupNameBottomSheet extends StatefulWidget {
  final String groupName;
  final String groupId;

  const ChangeGroupNameBottomSheet(this.groupName, this.groupId);

  @override
  State<ChangeGroupNameBottomSheet> createState() =>
      _ChangeGroupNameBottomSheetState();
}

class _ChangeGroupNameBottomSheetState
    extends State<ChangeGroupNameBottomSheet> {
  TextEditingController groupNameController = TextEditingController();

  @override
  void initState() {
    groupNameController.text = widget.groupName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final groupCubit = GroupCubit.get(context);
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
            controller: groupNameController,
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
          BlocListener<GroupCubit, GroupStates>(
            listener: (context, state) {
              if (state is ChangeGroupNameSuccess) {
                showSnackBar(
                  context,
                  Colors.greenAccent,
                  'Group name updated successfully',
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: DefaultTextButton(
              function: () {
                if (groupNameController.text == widget.groupName) {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  groupCubit.changeGroupName(
                    widget.groupId,
                    groupNameController.text,
                  );
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
