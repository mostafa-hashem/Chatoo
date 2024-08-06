import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/ui/widgets/friend_requests_tile.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friendCubit = FriendCubit.get(context);
    debugPrint("Number of user requests: ${friendCubit.allUserRequests.length}");

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
                  if (state is GetAllUserRequestsLoading) {
                    return const Expanded(child: LoadingIndicator());
                  } else if (state is GetAllUserRequestsError) {
                    return const Expanded(child: ErrorIndicator());
                  } else if (friendCubit.allUserRequests.isNotEmpty) {
                    return Expanded(
                      child: ListView.separated(
                        itemBuilder: (_, index) {
                          debugPrint("Rendering friend request at index: $index");
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
                  } else {
                    return Expanded(
                      child: Center(
                        child: Text(
                          'There are no friend requests at the moment.',
                          style: GoogleFonts.ubuntu(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
