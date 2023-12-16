import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomProfileContainer extends StatefulWidget {
  final TextEditingController controller;
  final void Function()? onTap;
  final void Function()? suffixPressed;
  final bool? isClickable;
  final int? maxLines;
  final TextInputType textInputType;
  final String labelText;
  final IconData? icon;

  const CustomProfileContainer({
    required this.labelText,
    required this.textInputType,
    this.icon,
    required this.controller,
    this.onTap,
    this.suffixPressed,
    this.isClickable,
    this.maxLines,
  });

  @override
  State<CustomProfileContainer> createState() => _CustomProfileContainerState();
}

class _CustomProfileContainerState extends State<CustomProfileContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: novaFlat18WhiteLight().copyWith(color: AppColors.primary),
        ),
        SizedBox(
          height: 8.h,
        ),
        TextField(
          controller: widget.controller,
          style: Theme.of(context).textTheme.bodyMedium,
          keyboardType: widget.textInputType,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor, width: 2.w),
              borderRadius: BorderRadius.circular(7.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor, width: 2.w),
              borderRadius: BorderRadius.circular(7.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor, width: 2.w),
              borderRadius: BorderRadius.circular(7.r),
            ),
          ),
        ),
      ],
    );
  }
}
