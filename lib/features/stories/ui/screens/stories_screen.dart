import 'dart:io';
import 'dart:typed_data';

import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/stories/cubit/stories_cubit.dart';
import 'package:chat_app/features/stories/ui/screens/edit_story_screen.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class StoriesScreen extends StatefulWidget {
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final ImagePicker _picker = ImagePicker();
  late FriendCubit friendCubit;
  late StoriesCubit storyCubit;
  File? mediaFile;
  final Map<String, Uint8List?> _thumbnails = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    friendCubit = FriendCubit.get(context);
    storyCubit = StoriesCubit.get(context);
  }

  Future<void> _cropImage(File imageFile) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          minimumAspectRatio: 1.0,
        ),
      ],
    );
    if (croppedImage != null) {
      setState(() {
        mediaFile = File(croppedImage.path);
      });
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditStoryScreen(
              mediaFile: mediaFile!,
              isVideo: false,
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleVideoFile(File videoFile) async {
    setState(() {
      mediaFile = videoFile;
    });
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditStoryScreen(
            mediaFile: mediaFile!,
            isVideo: true,
          ),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final XFile? xFile = await _picker.pickMedia();
    if (xFile != null) {
      File xFilePathToFile(XFile xFile) {
        return File(xFile.path);
      }

      mediaFile = xFilePathToFile(xFile);
      final String fileType = xFile.name.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png', 'gif'].contains(fileType)) {
        await _cropImage(mediaFile!);
      } else if (['mp4', 'mov', 'avi', 'mkv'].contains(fileType)) {
        await _handleVideoFile(mediaFile!);
      }
    }
  }

  Future<void> _generateThumbnail(String videoUrl) async {
    final unit8List = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    if (mounted) {
      setState(() {
        _thumbnails[videoUrl] = unit8List;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        profileCubit.user.profileImage ??
                            'https://via.placeholder.com/150',
                      ),
                      radius: 28.r,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, size: 16.r, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12.w),
                Text(
                  "My Status",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text("Friends stories", style: TextStyle(fontSize: 12.sp)),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: friendCubit.combinedFriends.length,
              itemBuilder: (context, index) {
                final combinedFriend = friendCubit.combinedFriends[index];
                final stories = combinedFriend.stories ?? [];

                if (stories.isEmpty) {
                  return const SizedBox.shrink();
                }
                final mediaUrl = stories.first.mediaUrl!;
                final fileName = mediaUrl
                    .split('%')
                    .last
                    .split('.')
                    .last
                    .substring(0, 3)
                    .toLowerCase();
                final isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(fileName);

                if (isVideo && !_thumbnails.containsKey(mediaUrl)) {
                  _generateThumbnail(mediaUrl);
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: isVideo
                            ? (_thumbnails[mediaUrl] != null
                                ? MemoryImage(_thumbnails[mediaUrl]!)
                                : null)
                            : NetworkImage(mediaUrl) as ImageProvider,
                        radius: 28.r,
                        child: isVideo && _thumbnails[mediaUrl] == null
                            ? const LoadingIndicator()
                            : null,
                      ),
                      CustomPaint(
                        painter: StoryCirclePainter(storyCount: stories.length),
                        child: SizedBox(
                          width: 56.r,
                          height: 56.r,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    combinedFriend.user?.userName ?? '',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  subtitle: Text(
                    getFormattedTime(
                      stories.first.uploadedAt!
                          .toLocal()
                          .millisecondsSinceEpoch,
                    ),
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.mediaView,
                      arguments: {
                        'path': mediaUrl,
                        'isVideo': isVideo,
                        'isStory': true,
                        'mediaTitle': stories.first.storyTitle ?? '',
                      },
                    );
                  },
                );
              },
            ),
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
