import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DefaultPasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String)? onSubmit;
  final void Function(String)? onChange;
  final void Function()? onTap;
  final String? Function(String?)? validate;
  final String label;
  final bool isClickable;

  const DefaultPasswordFormField({
    required this.controller,
    this.onSubmit,
    this.onChange,
    this.onTap,
    required this.validate,
    required this.label,
    this.isClickable = true,
  });

  @override
  State<DefaultPasswordFormField> createState() =>
      _DefaultPasswordFormFieldState();
}

class _DefaultPasswordFormFieldState extends State<DefaultPasswordFormField> {
  bool isPassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14.sp),
      controller: widget.controller,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      obscureText: isPassword,
      enabled: widget.isClickable,
      onFieldSubmitted: widget.onSubmit,
      onChanged: widget.onChange,
      onTap: widget.onTap,
      validator: widget.validate,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(12),
        labelText: widget.label,
        labelStyle: Theme.of(context).textTheme.bodySmall,
        suffixIcon: isPassword
            ? IconButton(
                onPressed: suffixPressed,
                icon: const Icon(
                  Icons.visibility_off,
                  color: AppColors.primary,
                ),
              )
            : IconButton(
                onPressed: suffixPressed,
                icon: const Icon(
                  Icons.visibility,
                  color: AppColors.primary,
                ),
              ),
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
    );
  }

  void suffixPressed() {
    setState(() {
      isPassword = !isPassword;
    });
  }
}
