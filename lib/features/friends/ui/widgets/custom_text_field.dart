import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
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

class CustomTextField extends StatefulWidget {
  final User friendData;

  const CustomTextField({super.key, required this.friendData});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FriendCubit friendCubit;
  late User sender;
  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;
  String? notificationBody;
  File? mediaFile;
  final audioPlayer = AudioPlayer();

  @override
  void didChangeDependencies() {
    friendCubit = FriendCubit.get(context);
    friendCubit.messageController.addListener(_checkTextDirection);
    sender = ProfileCubit.get(context).user;
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
      setState(() {
        mediaFile = File(croppedImage.path);
      });
      if (context.mounted) {
        Fluttertoast.showToast(msg: 'Sending...');
        notificationBody = 'sent photo';
        friendCubit
            .sendMediaToFriend(
          FirebasePath.images,
          mediaFile!,
          widget.friendData.id!,
          getImageFileName,
        )
            .then((value) {
          friendCubit
              .sendMessageToFriend(
                friend: widget.friendData,
                message: notificationBody ?? '',
                sender: sender,
                type: MessageType.image,
              )
              .whenComplete(
                () => audioPlayer.play(
                  AssetSource(
                    "audios/message_received.wav",
                  ),
                ),
              );
        });
      }
    }
  }

  Future<void> _handleVideoFile(File videoFile) async {
    debugPrint('Selected video file: ${videoFile.path}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send video?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                debugPrint('Video sending canceled');
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () {
                debugPrint('Sending video file...');
                Fluttertoast.showToast(msg: 'Sending...');
                friendCubit
                    .sendMediaToFriend(
                  FirebasePath.videos,
                  videoFile,
                  widget.friendData.id!,
                  getVideoFileName,
                )
                    .then((value) {
                  notificationBody = 'sent video';
                  debugPrint('Video file sent successfully');
                  friendCubit
                      .sendMessageToFriend(
                        friend: widget.friendData,
                        message: notificationBody ?? '',
                        sender: sender,
                        type: MessageType.video,
                      )
                      .whenComplete(
                        () => audioPlayer.play(
                          AssetSource(
                            "audios/message_received.wav",
                          ),
                        ),
                      );
                }).catchError((error) {
                  Fluttertoast.showToast(msg: 'Error: $error');
                  debugPrint('Error sending video file: $error');
                });
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAudioFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'mp3',
          'wav',
          'aac',
          'flac',
          'ogg',
          'm4a',
        ],
      );

      if (result != null && result.files.single.path != null) {
        final String path = result.files.single.path!;
        final File audioFile = File(path);

        if (await audioFile.exists()) {
          await _handleAudioFile(audioFile);
        } else {
          debugPrint('The selected audio file does not exist: $path');
        }
      } else {
        debugPrint('No audio file selected.');
      }
    } catch (e) {
      debugPrint('Error picking audio file: $e');
    }
  }

  Future<void> _handleAudioFile(File audioFile) async {
    debugPrint('Selected audio file: ${audioFile.path}');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send audio?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                debugPrint('Audio sending canceled');
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () {
                debugPrint('Sending audio file...');
                Fluttertoast.showToast(msg: 'Sending...');
                friendCubit
                    .sendMediaToFriend(
                  FirebasePath.audios,
                  audioFile,
                  widget.friendData.id!,
                  getAudioFileName,
                )
                    .then((value) {
                  notificationBody = 'sent audio';
                  debugPrint('Audio file sent successfully');
                  friendCubit
                      .sendMessageToFriend(
                        friend: widget.friendData,
                        message: notificationBody ?? '',
                        sender: sender,
                        type: MessageType.audio,
                      )
                      .whenComplete(
                        () => audioPlayer.play(
                          AssetSource(
                            "audios/message_received.wav",
                          ),
                        ),
                      );
                }).catchError((error) {
                  Fluttertoast.showToast(msg: 'Error: $error');
                  debugPrint('Error sending audio file: $error');
                });
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _checkTextDirection() {
    final text = friendCubit.messageController.text;
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
      controller: friendCubit.messageController,
      onChanged: (value) {
        setState(() {
          final bool isTyping = friendCubit.messageController.text.isNotEmpty;
          if (isTyping) {
            friendCubit.updateTypingStatus(
              friendId: widget.friendData.id!,
              isTyping: true,
            );
          } else {
            friendCubit.updateTypingStatus(
              friendId: widget.friendData.id!,
              isTyping: false,
            );
          }
        });
      },
      textInputAction: TextInputAction.newline,
      minLines: 1,
      maxLines: 8,
      textAlign: _textAlign,
      textDirection: _textDirection,
      style: TextStyle(
        fontSize: 14.sp,
        color: provider.themeMode == ThemeMode.light
            ? Colors.black87
            : AppColors.light,
      ),
      decoration: InputDecoration(
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (friendCubit.messageController.text.isEmpty)
              IconButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? xFile = await picker.pickMedia();
                  if (xFile != null) {
                    File xFilePathToFile(XFile xFile) {
                      return File(xFile.path);
                    }

                    mediaFile = xFilePathToFile(xFile);
                    final String fileType =
                        xFile.name.split('.').last.toLowerCase();
                    if (['jpg', 'jpeg', 'png', 'gif'].contains(fileType)) {
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
        hintText: 'Type a message',
        hintStyle: Theme.of(context).textTheme.bodySmall,
        filled: true,
        fillColor: provider.themeMode == ThemeMode.light
            ? Colors.white
            : AppColors.dark,
        border: OutlineInputBorder(
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
