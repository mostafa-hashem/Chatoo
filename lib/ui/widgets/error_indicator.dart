import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.error,
        color: AppColors.primary,
        size: 40,
      ),
    );
  }
}
