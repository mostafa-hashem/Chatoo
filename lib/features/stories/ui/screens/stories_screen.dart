import 'package:chat_app/features/stories/ui/widgets/friends_story.dart';
import 'package:chat_app/features/stories/ui/widgets/user_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserStory(),
          SizedBox(height: 8.h),
          Text("Friends stories", style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 8.h),
          Expanded(
            child: FriendsStory(),
          ),
        ],
      ),
    );
  }
}

class StoryCirclePainter extends CustomPainter {
  final int storyCount;
  final double strokeWidth = 3.0;

  StoryCirclePainter({required this.storyCount});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final double radius = (size.width / 2) - strokeWidth / 2;

    for (int i = 0; i < storyCount; i++) {
      final double startAngle = (2 * 3.14159 * i) / storyCount;
      final double sweepAngle = (2 * 3.14159) / storyCount;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
