import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateGroupWidget extends StatefulWidget {
  const CreateGroupWidget({super.key});

  @override
  State<CreateGroupWidget> createState() => _CreateGroupWidgetState();
}

class _CreateGroupWidgetState extends State<CreateGroupWidget> {
  String groupName = "";

  @override
  Widget build(BuildContext context) {
    final userData = ProfileCubit.get(context);
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(
            "Create a group",
            textAlign: TextAlign.left,
            style: GoogleFonts.novaFlat(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
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
                  groupName: groupName,
                  adminName: userData.user.userName!,
                  createdAt: DateTime.now(),
                );
                final user = User(
                  id: userData.user.id,
                  email: userData.user.email,
                  userName: userData.user.userName,
                  bio: userData.user.bio,
                  profileImage: userData.user.profileImage,
                  phoneNumber: userData.user.phoneNumber,
                );
                GroupCubit.get(context).createGroup(
                  group,
                  userData.user.userName!,
                  user,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text("CREATE"),
            ),
          ],
        );
      },
    );
  }
}
