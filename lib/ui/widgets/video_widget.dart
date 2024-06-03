
import 'dart:typed_data';

import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoWidget extends StatefulWidget {
  final String videoPath;
  final String? senderName;
  final String senderId;
  final bool isInGroup;
  final int? sentAt;

  const VideoWidget({
    super.key,
    required this.videoPath,
     this.sentAt,
     this.senderName,
    required this.senderId,
    required this.isInGroup,
  });

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  Uint8List? _thumbnail;
  late User sender;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final unit8List = await VideoThumbnail.thumbnailData(
      video: widget.videoPath,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    if (mounted) {
      setState(() {
        _thumbnail = unit8List;
      });
    }
  }

  @override
  void didChangeDependencies() {
    sender = ProfileCubit.get(context).user;
    super.didChangeDependencies();
  }

  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;
  void _checkTextDirection(String text) {
    if (text.isNotEmpty && isArabic(text)) {
      setState(() {
        _textAlign = TextAlign.right;
        _textDirection = TextDirection.rtl;
      });
    } else {
      setState(() {
        _textAlign = TextAlign.left;
        _textDirection = TextDirection.ltr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.videoPath.split('/').last;
    final dimensionsAndDuration = fileName.split('%5E');
    final dimensions = dimensionsAndDuration[0].split('x');
    final durationStr = dimensionsAndDuration[1].split('s').first;

    final width = double.tryParse(dimensions[0].split('%2F').last) ?? 100.0.w;
    final height = double.tryParse(dimensions[1]) ?? 100.0.h;
    final duration = int.tryParse(durationStr) ?? 0;
    final durationText =
        '${duration ~/ 60}:${(duration % 60).toString().padLeft(2, '0')}';

    final maxWidth = MediaQuery.of(context).size.width * 0.8;
    final maxHeight = MediaQuery.of(context).size.height * 0.4;

    final adjustedWidth = width > maxWidth ? maxWidth : width;
    final adjustedHeight = height > maxHeight ? maxHeight : height;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.mediaView,
          arguments: {
            'path': widget.videoPath,
            'isVideo': true,
            'isStory': false,
            'mediaTitle': '',
          },
        );
      },
      child: Column(
        crossAxisAlignment: sender.id == widget.senderId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (widget.isInGroup)
          if (widget.senderName!= null)
            Text(
              widget.senderName!,
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
          if (_thumbnail != null)
            Stack(
              alignment: Alignment.center,
              children: [
                Image.memory(
                  _thumbnail!,
                  height: adjustedHeight,
                  width: adjustedWidth,
                  fit: BoxFit.cover,
                ),
                const Icon(
                  Icons.play_circle_outline,
                  size: 50,
                  color: Colors.white,
                ),
                Positioned(
                  bottom: 8.h,
                  left: sender.id == widget.senderId ? 8.w : null,
                  right: sender.id == widget.senderId ? null : 8.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      durationText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              height: adjustedHeight,
              width: adjustedWidth,
              color: Colors.grey,
              child: const LoadingIndicator(),
            ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          if (widget.sentAt!= null)
          Text(
            getFormattedTime(widget.sentAt!),
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
