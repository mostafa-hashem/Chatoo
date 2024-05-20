import 'dart:typed_data';

import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoWidget extends StatefulWidget {
  final String videoPath;
  final String senderName;
  final String senderId;
  final bool isInGroup;
  final int sentAt;

  const VideoWidget({
    super.key,
    required this.videoPath,
    required this.sentAt,
    required this.senderName,
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
    final uint8List = await VideoThumbnail.thumbnailData(
      video: widget.videoPath,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    if (mounted) {
      setState(() {
        _thumbnail = uint8List;
      });
    }
  }
  @override
  void didChangeDependencies() {
    sender = ProfileCubit.get(context).user;
    super.didChangeDependencies();
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

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.mediaView,
          arguments: {'path': widget.videoPath, 'isVideo': true},
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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          if (_thumbnail != null)
            Stack(
              alignment: Alignment.center,
              children: [
                Image.memory(
                  _thumbnail!,
                  height: width > MediaQuery.sizeOf(context).width * 3
                      ? MediaQuery.sizeOf(context).height * 0.25
                      : height > MediaQuery.sizeOf(context).height * 1
                      ? MediaQuery.sizeOf(context).height * 1
                      : height,
                  width: width,
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
              height: width > MediaQuery.sizeOf(context).width * 3
                  ? MediaQuery.sizeOf(context).height * 0.25
                  : height > MediaQuery.sizeOf(context).height * 1
                  ? MediaQuery.sizeOf(context).height * 1
                  : height,
              width: width,
              color: Colors.grey,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Align(
            alignment: sender.id == widget.senderId
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              getFormattedTime(widget.sentAt),
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
