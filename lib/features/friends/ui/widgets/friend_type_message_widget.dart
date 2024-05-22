import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
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
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class FriendTypeMessageWidget extends StatefulWidget {
  final User friendData;

  const FriendTypeMessageWidget({super.key, required this.friendData});

  @override
  State<FriendTypeMessageWidget> createState() =>
      _FriendTypeMessageWidgetState();
}

class _FriendTypeMessageWidgetState extends State<FriendTypeMessageWidget> {
  bool emojiShowing = false;
  late FriendCubit friendCubit;
  late User sender;
  bool isRecording = false;
  final audioPlayer = AudioPlayer();
  late final AudioRecorder _audioRecorder;
  String? _audioPath;
  File? mediaFile;
  String? notificationBody;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sender = ProfileCubit.get(context).user;
    friendCubit = FriendCubit.get(context);
  }

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
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

  void scrollToBottom() {
    final scrollController = FriendCubit.get(context).scrollController;
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  bool isMuted() {
    if (widget.friendData.mutedGroups != null) {
      return widget.friendData.mutedFriends!
          .any((userId) => userId == sender.id);
    }
    return false;
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
        notificationBody = 'sent photo';
        friendCubit
            .sendMediaToFriend(
          FirebasePath.images,
          mediaFile!,
          widget.friendData.id!,
          getImageFileName,
        )
            .then((value) {
          friendCubit.sendMessageToFriend(
            friend: widget.friendData,
            message: notificationBody ?? '',
            sender: sender,
            type: MessageType.image,
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
                  friendCubit.sendMessageToFriend(
                    friend: widget.friendData,
                    message: notificationBody ?? '',
                    sender: sender,
                    type: MessageType.video,
                  );
                }).catchError((error) {
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
                  friendCubit.sendMessageToFriend(
                    friend: widget.friendData,
                    message: notificationBody ?? '',
                    sender: sender,
                    type: MessageType.audio,
                  );
                }).catchError((error) {
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<FriendCubit, FriendStates>(
          listener: (_, state) {
            if (state is SendMessageToFriendSuccess) {
              scrollToBottom();
              if (!isMuted()) {
                NotificationsCubit.get(context).sendNotification(
                  fCMToken: widget.friendData.fCMToken ?? '',
                  title: sender.userName!,
                  body: notificationBody ?? '',
                  imageUrl: friendCubit.mediaUrls.isNotEmpty
                      ? friendCubit.mediaUrls.first
                      : null,
                  friendData: ProfileCubit.get(context).user,
                );
              }
            }
          },
        ),
        BlocListener<FriendCubit, FriendStates>(
          listener: (_, state) {
            if (state is SendMediaToFriendSuccess) {
              debugPrint("HIIIIIIIIIIIIIIIIIII");
            }
          },
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  padding: const EdgeInsets.all(4),
                  onPressed: () {
                    setState(() {
                      emojiShowing = !emojiShowing;
                      FocusScope.of(context).unfocus();
                    });
                  },
                  icon: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 20.r,
                    child: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    constraints:
                        BoxConstraints(minHeight: 50.h, maxHeight: 180.h),
                    child: isRecording
                        ? Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await _stopRecording();
                                  setState(() {
                                    isRecording = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 45,
                                ),
                              ),
                              const Flexible(
                                child: CustomRecordingWaveWidget(),
                              ),
                            ],
                          )
                        : TextField(
                            controller: friendCubit.messageController,
                            onChanged: (value) {
                              setState(() {
                                final bool isTyping = friendCubit
                                    .messageController.text.isNotEmpty;
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
                            maxLines: null,
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
                                  if (friendCubit
                                      .messageController.text.isEmpty)
                                    IconButton(
                                      onPressed: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? xFile =
                                            await picker.pickMedia();
                                        if (xFile != null) {
                                          File xFilePathToFile(XFile xFile) {
                                            return File(xFile.path);
                                          }

                                          mediaFile = xFilePathToFile(xFile);
                                          final String fileType = xFile.name
                                              .split('.')
                                              .last
                                              .toLowerCase();
                                          if (['jpg', 'jpeg', 'png', 'gif']
                                              .contains(fileType)) {
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
                              contentPadding: const EdgeInsets.only(
                                left: 16.0,
                                bottom: 8.0,
                                top: 8.0,
                                right: 16.0,
                              ),
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
                ),
                if (friendCubit.messageController.text.isNotEmpty)
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    onPressed: () async {
                      notificationBody = friendCubit.messageController.text;
                      if (friendCubit.messageController.text.isNotEmpty) {
                        friendCubit.messageController.clear();
                        friendCubit.updateTypingStatus(
                          friendId: widget.friendData.id!,
                          isTyping: false,
                        );
                        await friendCubit.sendMessageToFriend(
                          friend: widget.friendData,
                          message: notificationBody ?? '',
                          sender: sender,
                          type: MessageType.text,
                        );
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
                            await friendCubit
                                .sendMediaToFriend(
                              FirebasePath.records,
                              recordFile,
                              widget.friendData.id!,
                              getAudioFileName,
                            )
                                .whenComplete(
                              () {
                                friendCubit.sendMessageToFriend(
                                  friend: widget.friendData,
                                  sender: sender,
                                  message: '',
                                  type: MessageType.record,
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
                            // await audioPlayer
                            //     .play(
                            //       AssetSource("audios/Notification.mp3"),
                            //     );
                            _record();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              radius: 20.r,
                              child: const Center(
                                child: Icon(
                                  Icons.mic,
                                  size: 24,
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
            child: SizedBox(
              height: 220.h,
              child: EmojiPicker(
                textEditingController: friendCubit.messageController,
                config: Config(
                  emojiSizeMax: 30 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.30
                          : 1.0),
                  bgColor: provider.themeMode == ThemeMode.light
                      ? const Color(0xFFF2F2F2)
                      : AppColors.dark,
                  indicatorColor: AppColors.primary,
                  iconColorSelected: AppColors.primary,
                  backspaceColor: AppColors.primary,
                  noRecents: Text(
                    'No Recents',
                    style: TextStyle(fontSize: 16.sp, color: Colors.black26),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
