import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/utils/data/models/user.dart';
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

  const ImageWidget({
    super.key,
    required this.imagePath,
    required this.sentAt,
    required this.senderName,
    required this.senderId,
    required this.isInGroup,
  });

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  late User sender;

  @override
  void didChangeDependencies() {
    sender = ProfileCubit.get(context).user;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.imagePath.split('/').last;
    final dimensions = fileName.split('.').first.split('x');
    final width =
        double.tryParse(dimensions[0].split('%').last.substring(2)) ?? 100.0.w;
    final height = double.tryParse(dimensions[1]) ?? 100.0.h;

    final maxWidth = MediaQuery.of(context).size.width * 0.6;
    final maxHeight = MediaQuery.of(context).size.height * 0.4;

    final adjustedWidth = width > maxWidth ? maxWidth : width;
    final adjustedHeight = height > maxHeight ? maxHeight : height;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.mediaView,
          arguments: {
            'path': widget.imagePath,
            'isVideo': false,
            'isStory': false,
            'mediaTitle': ''
          },
        );
      },
      child: Column(
        crossAxisAlignment: sender.id == widget.senderId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (widget.isInGroup)
            Text(
              widget.senderName,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (widget.isInGroup)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
          FancyShimmerImage(
            height: adjustedHeight,
            width: adjustedWidth,
            imageUrl: widget.imagePath,
            boxFit: BoxFit.cover,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            getFormattedTime(
              widget.sentAt,
            ),
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
