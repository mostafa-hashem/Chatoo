import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType type;
  final void Function(String)? onSubmit;
  final void Function(String)? onChange;
  final void Function()? onTap;
  final String? Function(String?)? validate;
  final String label;
  final IconData? suffix;
  final void Function()? suffixPressed;
  final bool isClickable;
  final int? maxLines;

  const DefaultFormField({
    required this.controller,
    required this.type,
    this.onSubmit,
    this.onChange,
    this.onTap,
    required this.validate,
    required this.label,
    this.suffix,
    this.suffixPressed,
    this.isClickable = true,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        TextFormField(
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.sp),
          maxLines: maxLines,
          controller: controller,
          keyboardType: type,
          textInputAction: TextInputAction.next,
          enabled: isClickable,
          onFieldSubmitted: onSubmit,
          onChanged: onChange,
          onTap: onTap,
          validator: validate,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            labelText: label,
            suffixIcon: suffix != null
                ? IconButton(
                    onPressed: suffixPressed,
                    icon: Icon(
                      suffix,
                      color: AppColors.primary,
                    ),
                  )
                : null,
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
        if (maxLines != null)
          Image.asset("assets/images/upload photo.png")
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
