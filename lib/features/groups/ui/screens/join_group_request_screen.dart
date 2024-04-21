import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/ui/widgets/group_requests_tile.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinGroupRequestsScreen extends StatelessWidget {
  const JoinGroupRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupData = ModalRoute.of(context)!.settings.arguments! as Group;
    final groupCubit = GroupCubit.get(context);
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
                    return GroupRequestsTile(
                      group: groupData,
                      requesterData: groupCubit.allGroupRequests[index],
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(color: AppColors.primary,),
                  itemCount: groupCubit.allGroupRequests.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
