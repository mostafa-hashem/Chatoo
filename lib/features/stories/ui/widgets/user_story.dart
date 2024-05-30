import 'dart:io';
import 'dart:typed_data';

import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/stories/ui/screens/edit_story_screen.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class UserStory extends StatefulWidget {
  UserStory({super.key});

  @override
  State<UserStory> createState() => _UserStoryState();
}

final Map<String, Uint8List?> _thumbnails = {};

class _UserStoryState extends State<UserStory> {
  File? mediaFile;
  final ImagePicker _picker = ImagePicker();

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

  @override
  Widget build(BuildContext context) {
    final profileCubit = ProfileCubit.get(context);
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (_, current) =>
          current is GetUserStoriesLoading ||
          current is GetUserStoriesSuccess ||
          current is GetUserStoriesError,
      builder: (_, state) {
        final userStories = profileCubit.stories;
        final fileName = userStories[0]
            .mediaUrl
            ?.split('%')
            .last
            .split('.')
            .last
            .substring(0, 3)
            .toLowerCase();
        final isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(fileName);

        if (isVideo && !_thumbnails.containsKey(userStories.first.mediaUrl)) {
          _generateThumbnail(userStories.first.mediaUrl ?? '');
        }
        return Row(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (userStories.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        Routes.mediaView,
                        arguments: {
                          'path': userStories.first.mediaUrl,
                          'isVideo': isVideo,
                          'isStory': true,
                          'mediaTitle': userStories.first.storyTitle,
                        },
                      );
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage: userStories.isNotEmpty
                        ? isVideo
                            ? (_thumbnails[userStories.first.mediaUrl] != null
                                ? MemoryImage(
                                    _thumbnails[userStories.first.mediaUrl]!,
                                  )
                                : null)
                            : NetworkImage(userStories.first.mediaUrl ?? '')
                                as ImageProvider
                        : NetworkImage(
                            profileCubit.user.profileImage ??
                                'https://via.placeholder.com/150',
                          ),
                    radius: 28.r,
                    child: isVideo &&
                            _thumbnails[userStories.first.mediaUrl] == null
                        ? const LoadingIndicator()
                        : null,
                  ),
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
                    child: GestureDetector(
                        onTap: (){
                          _pickImage();
                        },
                        child: Icon(Icons.add, size: 16.r, color: Colors.white)),
                  ),
                ),
              ],
            ),
            SizedBox(width: 12.w),
            Text(
              "My Status",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}
