import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_requests_tile.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friendCubit = FriendCubit.get(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Requests',
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return FriendRequestsTile(
                      requesterData: friendCubit.allUserRequests[index],
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(color: AppColors.primary,),
                  itemCount: friendCubit.allUserRequests.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
