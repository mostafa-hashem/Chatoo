import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/stories/cubit/stories_cubit.dart';
import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/custom_recording_wave_widget.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class StoryTextField extends StatefulWidget {
  final User userData;
  final Story story;
  final void Function() resumeStory;
  final void Function() pauseStory;

  const StoryTextField(
      {super.key,
      required this.userData,
      required this.story,
      required this.resumeStory,
      required this.pauseStory});

  @override
  State<StoryTextField> createState() => _StoryTextFieldState();
}

class _StoryTextFieldState extends State<StoryTextField> {
  late FriendCubit friendCubit;
  late NotificationsCubit notificationsCubit;
  late StoriesCubit storiesCubit;
  late User sender;
  TextEditingController storyController = TextEditingController();
  TextAlign _textFiledAlign = TextAlign.left;
  TextDirection _textFieldDirection = TextDirection.ltr;
  bool isRecording = false;
  final audioPlayer = AudioPlayer();
  late final AudioRecorder _audioRecorder;
  String? _audioPath;
  bool emojiShowing = false;
  File? mediaFile;
  String? notificationBody;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notificationsCubit = NotificationsCubit.get(context);
    friendCubit = FriendCubit.get(context);
    storiesCubit = StoriesCubit.get(context);
    sender = ProfileCubit.get(context).user;
    storyController.addListener(_checkTextFiledDirection);
    _focusNode.addListener(_onFocusChange);
  }

  bool isMuted() {
    if (widget.userData.mutedFriends != null) {
      return widget.userData.mutedFriends!.any((userId) => userId == sender.id);
    }
    return false;
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.resumeStory();
    }
    if (_focusNode.hasFocus) {
      widget.pauseStory();
    }
  }

  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      10,
      (index) => chars[random.nextInt(chars.length)],
      growable: false,
    ).join();
  }

  Future<void> _startRecording() async {
    try {
      debugPrint(
        '=========>>>>>>>>>>> RECORDING!!!!!!!!!!!!!!! <<<<<<===========',
      );

      final String filePath = await getApplicationDocumentsDirectory()
          .then((value) => '${value.path}/${_generateRandomId()}.wav');

      await _audioRecorder.start(
        const RecordConfig(
          // specify the codec to be `.wav`
          encoder: AudioEncoder.wav,
        ),
        path: filePath,
      );
    } catch (e) {
      debugPrint('ERROR WHILE RECORDING: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final String? path = await _audioRecorder.stop();
      setState(() {
        _audioPath = path;
        friendCubit.updateRecordingStatus(
          friendId: widget.userData.id ?? '',
          isRecording: false,
        );
      });
    } catch (e) {
      debugPrint('ERROR WHILE STOP RECORDING: $e');
    }
  }

  Future<void> _record() async {
    if (isRecording == false) {
      final status = await Permission.microphone.request();

      if (status == PermissionStatus.granted) {
        setState(() {
          isRecording = true;
          friendCubit.updateRecordingStatus(
            friendId: widget.userData.id ?? '',
            isRecording: true,
          );
        });
        await _startRecording();
      } else if (status == PermissionStatus.permanentlyDenied) {
        debugPrint('Permission permanently denied');
      }
    } else {
      await _stopRecording();
      setState(() {
        isRecording = false;
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
          widget.userData.id ?? '',
          getImageFileName,
        )
            .then((value) {
          friendCubit
              .sendMessageToFriend(
                friend: widget.userData,
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
                  widget.userData.id ?? '',
                  getVideoFileName,
                )
                    .then((value) {
                  notificationBody = 'sent video';
                  debugPrint('Video file sent successfully');
                  friendCubit
                      .sendMessageToFriend(
                        friend: widget.userData,
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
          'aiff',
          'alac',
          'dsd',
          'wma',
        ],
      );

      if (result != null && result.files.single.path != null) {
        final String originalPath = result.files.single.path!;
        final File originalAudioFile = File(originalPath);

        if (await originalAudioFile.exists()) {
          final String newFileName = '${_generateRandomId()}.mp3';

          final String newPath = await getApplicationDocumentsDirectory()
              .then((value) => '${value.path}/$newFileName');

          final File newAudioFile = await originalAudioFile.copy(newPath);

          await _handleAudioFile(newAudioFile);
        } else {
          debugPrint(
            'The selected audio file does not exist: ${originalAudioFile.path}',
          );
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
                  widget.userData.id ?? '',
                  getAudioFileName,
                )
                    .then((value) {
                  notificationBody = 'sent audio';
                  debugPrint('Audio file sent successfully');
                  friendCubit
                      .sendMessageToFriend(
                        friend: widget.userData,
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

  void _onBackspacePressed() {
    friendCubit.messageController
      ..text = friendCubit.messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: friendCubit.messageController.text.length),
      );
  }

  void _checkTextFiledDirection() {
    final text = friendCubit.messageController.text;
    if (text.isNotEmpty && isArabic(text)) {
      setState(() {
        _textFiledAlign = TextAlign.right;
        _textFieldDirection = TextDirection.rtl;
      });
    } else {
      setState(() {
        _textFiledAlign = TextAlign.left;
        _textFieldDirection = TextDirection.ltr;
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    return BlocListener<FriendCubit, FriendStates>(
      listener: (_, state) {
        if (state is SendMessageToFriendSuccess) {
          if (!isMuted()) {
            for (final String? fcmToken in widget.userData.fCMTokens! as List<String>)  {
              notificationsCubit.sendNotification(
                fCMToken: fcmToken ?? "",
                title: ProfileCubit.get(context).user.userName ?? '',
                body: notificationBody ?? '',
                imageUrl: friendCubit.mediaUrls.isNotEmpty
                    ? friendCubit.mediaUrls.first
                    : null,
              );
            }
          }
        }
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 16.h,
              bottom: 22.h,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isRecording)
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    onPressed: () async {
                      await _stopRecording();
                      setState(() {
                        isRecording = false;
                      });
                    },
                    icon: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20.r,
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                if (isRecording)
                  const Flexible(
                    child: CustomRecordingWaveWidget(),
                  )
                else
                  Flexible(
                    child: TextField(
                      controller: storyController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      textInputAction: TextInputAction.newline,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 8,
                      textAlign: _textFiledAlign,
                      textDirection: _textFieldDirection,
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
                            if (storyController.text.isEmpty)
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

                                    mediaFile = xFilePathToFile(
                                      xFile,
                                    );
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
                                      await _cropImage(
                                        mediaFile!,
                                      );
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
                              IconButton(
                                onPressed: _pickAudioFile,
                                icon: const Icon(
                                  Icons.audiotrack,
                                ),
                              ),
                          ],
                        ),
                        prefixIcon: IconButton(
                          padding: const EdgeInsets.all(4),
                          onPressed: () {
                            setState(() {
                              emojiShowing = !emojiShowing;
                              FocusScope.of(context).unfocus();
                            });
                          },
                          icon: const Icon(
                            Icons.emoji_emotions,
                            color: Colors.white,
                            size: 24,
                          ),
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
                    ),
                  ),
                if (storyController.text.isNotEmpty)
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    onPressed: () async {
                      notificationBody = storyController.text;
                      if (storyController.text.isNotEmpty) {
                        storyController.clear();
                        await friendCubit
                            .sendMessageToFriend(
                          friend: widget.userData,
                          message: notificationBody ?? '',
                          sender: sender,
                          type: MessageType.text,
                          replayToStory: widget.story,
                        )
                            .whenComplete(() {
                          friendCubit.setRepliedMessage(null);
                          audioPlayer.play(
                            AssetSource(
                              "audios/message_received.wav",
                            ),
                          );
                        });
                      }
                    },
                    icon: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20.r,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                else
                  isRecording
                      ? IconButton(
                          padding: const EdgeInsets.all(4),
                          onPressed: () async {
                            await _record();
                            final File recordFile = File(_audioPath!);
                            await Fluttertoast.showToast(
                              msg: 'Sending...',
                            );
                            await friendCubit
                                .sendMediaToFriend(
                              FirebasePath.records,
                              recordFile,
                              widget.userData.id ?? '',
                              getAudioFileName,
                            )
                                .whenComplete(
                              () {
                                friendCubit
                                    .sendMessageToFriend(
                                      friend: widget.userData,
                                      sender: sender,
                                      message: '',
                                      type: MessageType.record,
                                      replayToStory: widget.story,
                                    )
                                    .whenComplete(
                                      () => audioPlayer.play(
                                        AssetSource(
                                          "audios/message_received.wav",
                                        ),
                                      ),
                                    );
                                notificationBody = 'sent a recording';
                              },
                            );
                            debugPrint('End');
                          },
                          icon: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 20.r,
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onLongPress: () async {
                            _record();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              radius: 20.r,
                              child: const Center(
                                child: Icon(
                                  Icons.mic,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
              ],
            ),
          ),
          Offstage(
            offstage: !emojiShowing,
            child: EmojiPicker(
              textEditingController: storyController,
              onBackspacePressed: _onBackspacePressed,
              config: Config(
                height: 220.h,
                emojiViewConfig: EmojiViewConfig(
                  emojiSizeMax: 30 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.2
                          : 1.0),
                  noRecents: const Text(
                    'No Recents',
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: provider.themeMode == ThemeMode.light
                      ? const Color(0xFFF2F2F2)
                      : AppColors.dark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
