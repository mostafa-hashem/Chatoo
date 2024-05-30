import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CustomGroupTextField extends StatefulWidget {
  final Group groupData;
  const CustomGroupTextField({super.key, required this.groupData});

  @override
  State<CustomGroupTextField> createState() => _CustomGroupTextFieldState();
}

class _CustomGroupTextFieldState extends State<CustomGroupTextField> {
  String? notificationBody;
  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;
  final audioPlayer = AudioPlayer();
  File? mediaFile;
  late GroupCubit groupCubit;
  late User sender;
  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    sender = ProfileCubit.get(context).user;
    groupCubit.messageController.addListener(_checkTextDirection);
    super.didChangeDependencies();
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
        WebUiSettings(
          context: context,
          boundary: const CroppieBoundary(
            width: 520,
            height: 520,
          ),
          viewPort:
          const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          enableExif: true,
          enableZoom: true,
          showZoomer: true,
        ),
      ],
    );
    if (croppedImage != null) {
      Fluttertoast.showToast(msg: 'Sending...');
      setState(() {
        mediaFile = File(croppedImage.path);
      });
      if (context.mounted) {
        notificationBody = 'sent photo';
        groupCubit
            .uploadMediaToGroup(
          FirebasePath.images,
          mediaFile!,
          widget.groupData.groupId!,
          getImageFileName,
        )
            .then(
              (value) {
            notificationBody = 'sent photo';
            groupCubit.sendMessageToGroup(
              group: widget.groupData,
              sender: sender,
              mediaUrls: groupCubit.mediaUrls,
              message: notificationBody ?? '',
              type: MessageType.image,
              isAction: false,
            );
          },
        );
      }
    }
  }

  Future<void> _handleAudioFile(File audioFile) async {
    debugPrint('Selected audio file: ${audioFile.path}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Send audio?',
          ),
          actionsOverflowDirection: VerticalDirection.down,
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
            ),
            TextButton(
              child: const Text(
                'Send',
              ),
              onPressed: () {
                Fluttertoast.showToast(msg: 'Sending...');
                groupCubit
                    .uploadMediaToGroup(
                  FirebasePath.audios,
                  mediaFile!,
                  widget.groupData.groupId!,
                  getAudioFileName,
                )
                    .whenComplete(
                      () {
                    notificationBody = 'sent audio';
                    groupCubit.sendMessageToGroup(
                      group: widget.groupData,
                      sender: sender,
                      message: notificationBody ?? '',
                      type: MessageType.record,
                      isAction: false,
                      mediaUrls: groupCubit.mediaUrls,
                    );
                  },
                );
                Navigator.pop(
                  context,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAudioFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a'],
    );

    if (result != null) {
      final File audioFile = File(result.files.single.path!);
      await _handleAudioFile(audioFile);
    } else {
      debugPrint('No audio file selected.');
    }
  }

  Future<void> _handleVideoFile(File videoFile) async {
    debugPrint('Selected video file: ${videoFile.path}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Send video?',
          ),
          actionsOverflowDirection: VerticalDirection.down,
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                );
              },
            ),
            TextButton(
              child: const Text(
                'Send',
              ),
              onPressed: () {
                Fluttertoast.showToast(msg: 'Sending...');
                groupCubit
                    .uploadMediaToGroup(
                  FirebasePath.videos,
                  mediaFile!,
                  widget.groupData.groupId!,
                  getVideoFileName,
                )
                    .then(
                      (value) {
                    notificationBody = 'sent video';
                    groupCubit.sendMessageToGroup(
                      group: widget.groupData,
                      sender: sender,
                      mediaUrls: groupCubit.mediaUrls,
                      message: notificationBody ?? '',
                      type: MessageType.video,
                      isAction: false,
                    );
                  },
                );
                Navigator.pop(
                  context,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _checkTextDirection() {
    final text = groupCubit.messageController.text;
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
    final provider = Provider.of<MyAppProvider>(context);

    return TextField(
      controller: groupCubit.messageController,
      onChanged: (value) {
        setState(() {});
      },
      textInputAction: TextInputAction.newline,
      minLines: 1,
      maxLines: 8,
      style: TextStyle(
        fontSize: 14.sp,
        color: provider.themeMode == ThemeMode.light
            ? Colors.black87
            : AppColors.light,
      ),
      textDirection: _textDirection,
      textAlign: _textAlign,
      decoration: InputDecoration(
        hintText: 'Type a message',
        hintStyle: Theme.of(context).textTheme.bodySmall,
        filled: true,
        fillColor: provider.themeMode == ThemeMode.light
            ? Colors.white
            : AppColors.dark,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (groupCubit.messageController.text.isEmpty)
              IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? xFile = await picker.pickMedia();
                  if (xFile != null) {
                    File xFilePathToFile(
                        XFile xFile,
                        ) {
                      return File(xFile.path);
                    }

                    mediaFile = xFilePathToFile(xFile);
                    final String fileType = xFile.name
                        .split('.')
                        .last
                        .toLowerCase();
                    if ([
                      'jpg',
                      'jpeg',
                      'png',
                      'gif',
                    ].contains(fileType)) {
                      await _cropImage(mediaFile!);
                    } else if ([
                      'mp4',
                      'mov',
                      'avi',
                      'mkv',
                    ].contains(fileType)) {
                      await _handleVideoFile(
                        mediaFile!,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.image),
              ),
            if (false)
              IconButton(
                onPressed: _pickAudioFile,
                icon: const Icon(Icons.audiotrack),
              ),
          ],
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
