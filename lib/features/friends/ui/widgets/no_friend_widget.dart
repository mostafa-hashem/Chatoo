import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoFriendWidget extends StatelessWidget {
  const NoFriendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, Routes.friendSearchScreen);
            },
            child: const Icon(
              Icons.add_circle,
              color: AppColors.accent,
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "You've no friends till now, tap on the add icon to add friend or also search from top search button.",
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(),
          ),
        ],
      ),
    );
  }
}
