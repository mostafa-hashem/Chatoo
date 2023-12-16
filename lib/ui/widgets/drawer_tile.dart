import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/profile/ui/screens/profile_screen.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/screens/about_us.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawerTile extends StatefulWidget {
  const DrawerTile({super.key});

  @override
  State<DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<DrawerTile> {
  String userName = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    final profile = ProfileCubit.get(context);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 50),
      children: <Widget>[
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) => profile.user.profileImage != null &&
                  profile.user.profileImage!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    profile.user.profileImage!,
                    height: 150.h,
                    fit: BoxFit.contain,
                  ),
                )
              : Icon(
                  Icons.account_circle,
                  size: 150,
                  color: Colors.grey[700],
                ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        const Divider(
          height: 2,
        ),
        ListTile(
          onTap: () {
            nextScreen(context, const ProfileScreen());
          },
          selected: true,
          selectedColor: AppColors.primary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.person),
          title: Text(
            "Profile",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        ListTile(
          onTap: () {
            nextScreen(context, const AboutUs());
          },
          selected: true,
          selectedColor: AppColors.primary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.info),
          title: Text(
            "About us",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
    //   ListTile(
    //   onTap: () {
    //     nextScreen(context, page);
    //   },
    //   selected: isSelected,
    //   selectedColor: AppColors.primaryColor,
    //   contentPadding:
    //   const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    //   leading: Icon(icon),
    //   title: Text(
    //     title,
    //     style: Theme.of(context).textTheme.bodyMedium)
    // );
  }
}
