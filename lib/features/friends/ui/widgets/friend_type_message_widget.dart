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
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      debugPrint('=========>>>>>> PATH: $_audioPath <<<<<<===========');
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
    FriendCubit.get(context).scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 700),
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
                              Flexible(
                                child: Row(
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
                                      ),
                                    ),
                                    const Flexible(
                                      child: CustomRecordingWaveWidget(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Flexible(
                                child: TextField(
                                  controller: friendCubit.messageController,
                                  onChanged: (value) {
                                    setState(() {});
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
                                    suffixIcon: friendCubit
                                            .messageController.text.isEmpty
                                        ? IconButton(
                                            onPressed: () async {
                                              final ImagePicker picker =
                                                  ImagePicker();
                                              final XFile? xFile =
                                                  await picker.pickMedia();
                                              if (xFile != null) {
                                                File xFilePathToFile(
                                                  XFile xFile,
                                                ) {
                                                  return File(xFile.path);
                                                }

                                                mediaFile =
                                                    xFilePathToFile(xFile);
                                                if (context.mounted) {
                                                  final String fileType = xFile
                                                      .name
                                                      .split('.')
                                                      .last
                                                      .toLowerCase();
                                                  final bool isImage = [
                                                    'jpg',
                                                    'jpeg',
                                                    'png',
                                                    'gif',
                                                  ].contains(fileType);
                                                  final bool isVideo = [
                                                    'mp4',
                                                    'mov',
                                                    'avi',
                                                    'mkv',
                                                  ].contains(fileType);
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                          isImage
                                                              ? 'Send image?'
                                                              : isVideo
                                                                  ? 'Send video?'
                                                                  : 'Send media?',
                                                        ),
                                                        actionsOverflowDirection:
                                                            VerticalDirection
                                                                .down,
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
                                                              if (isImage) {
                                                                friendCubit
                                                                    .sendMediaToFriend(
                                                                  FirebasePath
                                                                      .images,
                                                                  mediaFile!,
                                                                  widget
                                                                      .friendData
                                                                      .id!,
                                                                  getImageFileName,
                                                                )
                                                                    .then(
                                                                  (value) {
                                                                    friendCubit
                                                                        .sendMessageToFriend(
                                                                      friend: widget
                                                                          .friendData,
                                                                      message:
                                                                          "",
                                                                      sender:
                                                                          sender,
                                                                      type: MessageType
                                                                          .image,
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                              if (isVideo) {
                                                                friendCubit
                                                                    .sendMediaToFriend(
                                                                  FirebasePath
                                                                      .images,
                                                                  mediaFile!,
                                                                  widget
                                                                      .friendData
                                                                      .id!,
                                                                  getVideoFileName,
                                                                )
                                                                    .then(
                                                                  (value) {
                                                                    friendCubit
                                                                        .sendMessageToFriend(
                                                                      friend: widget
                                                                          .friendData,
                                                                      message:
                                                                          "",
                                                                      sender:
                                                                          sender,
                                                                      type: MessageType
                                                                          .video,
                                                                    );
                                                                    notificationBody =
                                                                        'sent video';
                                                                  },
                                                                );
                                                              }
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
                                              }
                                            },
                                            icon: const Icon(Icons.image),
                                          )
                                        : const SizedBox.shrink(),
                                    hintText: 'Type a message',
                                    hintStyle:
                                        Theme.of(context).textTheme.bodySmall,
                                    filled: true,
                                    fillColor:
                                        provider.themeMode == ThemeMode.light
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
                            ],
                          ),
                  ),
                ),
                if (friendCubit.messageController.text.isNotEmpty)
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    onPressed: () {
                      notificationBody = friendCubit.messageController.text;
                      if (friendCubit.messageController.text.isNotEmpty) {
                        friendCubit.messageController.clear();
                        FriendCubit.get(context).sendMessageToFriend(
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
                                notificationBody = 'Mostafa sent a recording';
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
                            await audioPlayer
                                .play(AssetSource("audios/Notification.mp3"))
                                .whenComplete(
                                  () => _record(),
                                );
                          },
                          child: isRecording
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.greenAccent,
                                    radius: 38.r,
                                    child: const Center(child: Icon(Icons.mic)),
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Icons.mic),
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
