import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/resources/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FriendInfo extends StatelessWidget {
  final String labelText;
  final String info;

  const FriendInfo({
    super.key,
    required this.labelText,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            labelText,
            style: novaFlat18WhiteLight().copyWith(color: AppColors.primary),
          ),
        ),
        SizedBox(
          height: 6.h,
        ),
        Container(
          width: double.infinity,
          height: 42.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7.r),
            border: Border.all(
              color: AppColors.borderColor,
              width: 2.w,
            ),
          ),
          child: Center(
            child: Text(
              info,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
