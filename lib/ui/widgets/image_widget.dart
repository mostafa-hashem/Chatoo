import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImageWidget extends StatefulWidget {
  final String imagePath;
  final String senderName;
  final String senderId;
  final bool isInGroup;
  final int sentAt;

  const ImageWidget(
      {super.key,
      required this.imagePath,
      required this.sentAt,
      required this.senderName,
      required this.senderId,
      required this.isInGroup});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.imageView,
          arguments: widget.imagePath,
        );
      },
      child: Column(
        crossAxisAlignment: ProfileCubit.get(context).user.id == widget.senderId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if(widget.isInGroup)
          Text(
            widget.senderName,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Center(
              child: FancyShimmerImage(
                imageUrl: widget.imagePath,
                boxFit: BoxFit.contain,
              ),
            ),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            getFormattedTime(
              widget.sentAt,
            ),
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
