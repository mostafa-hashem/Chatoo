import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/stories/cubit/stories_cubit.dart';
import 'package:chat_app/features/stories/cubit/stories_state.dart';
import 'package:chat_app/features/stories/ui/widgets/friends_story.dart';
import 'package:chat_app/features/stories/ui/widgets/user_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class StoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<StoriesCubit, StoriesState>(
      listener: (_, state) {
        if (state is UploadStorySuccess) {
          Fluttertoast.showToast(msg: 'Story uploaded');
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<ProfileCubit, ProfileState>(
              buildWhen: (_, current) =>
                  current is GetUserStoriesLoading ||
                  current is GetUserStoriesSuccess ||
                  current is GetUserStoriesError,
              builder: (_, state) {
                return UserStory();
              },
            ),
            SizedBox(height: 8.h),
            Text("Friends stories", style: TextStyle(fontSize: 12.sp)),
            SizedBox(height: 8.h),
            Expanded(
              child: FriendsStory(),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryCirclePainter extends CustomPainter {
  final int storyCount;

  StoryCirclePainter({required this.storyCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final angle = 360 / storyCount;
    final radius = size.width / 2;
    for (int i = 0; i < storyCount; i++) {
      final startAngle = radians(i * angle);
      final sweepAngle = radians(angle - 2); // to add space between segments
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: radius,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double radians(double degrees) {
    return degrees * (3.1415926535897932 / 180);
  }
}
