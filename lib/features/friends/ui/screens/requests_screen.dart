import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_requests_tile.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              BlocBuilder<FriendCubit, FriendStates>(
                buildWhen: (_, currentState) =>
                    currentState is GetAllUserRequestsLoading ||
                    currentState is GetAllUserRequestsSuccess ||
                    currentState is GetAllUserRequestsError,
                builder: (context, state) {
                  return Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return FriendRequestsTile(
                          friendData: friendCubit.allUserRequests[index],
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(
                        color: AppColors.primary,
                      ),
                      itemCount: friendCubit.allUserRequests.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
