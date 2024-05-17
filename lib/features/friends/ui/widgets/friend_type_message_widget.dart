import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/notifications/cubit/notifications_states.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/custom_recording_wave_widget.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
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
  bool isRecording = false;
  late final AudioRecorder _audioRecorder;
  String? _audioPath;
  File? imageFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  @override
  Widget build(BuildContext context) {
    final sender = ProfileCubit.get(context).user;
    final provider = Provider.of<MyAppProvider>(context);
    return BlocListener<FriendCubit, FriendStates>(
      listener: (_, state) {
        if (state is SendMediaToFriendSuccess) {
          debugPrint("HIIIIIIIIIIIIIIIIIII");
          friendCubit.sendMessageToFriend(
            friend: widget.friendData,
            message: "",
            sender: sender,
            type: MessageType.image,
          );
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          emojiShowing = !emojiShowing;
                          FocusScope.of(context).unfocus();
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (isRecording)
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
                          const Flexible(child: CustomRecordingWaveWidget()),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: friendCubit.messageController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          textInputAction: TextInputAction.newline,
                          minLines: 1,
                          maxLines: 20,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: provider.themeMode == ThemeMode.light
                                ? Colors.black87
                                : AppColors.light,
                          ),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () async {
                                final ImagePicker picker = ImagePicker();
                                final XFile? xFile = await picker.pickImage(
                                    source: ImageSource.gallery);
                                if (xFile != null) {
                                  File xFilePathToFile(XFile xFile) {
                                    return File(xFile.path);
                                  }

                                  imageFile = xFilePathToFile(xFile);
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Send image?'),
                                          actionsOverflowDirection:
                                              VerticalDirection.down,
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Send'),
                                              onPressed: () {
                                                friendCubit.sendMediaToFriend(
                                                  FirebasePath.images,
                                                  imageFile!,
                                                  widget.friendData.id!,
                                                );

                                                Navigator.pop(context);
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
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (friendCubit.messageController.text.isNotEmpty)
                    BlocListener<NotificationsCubit, NotificationsStates>(
                      listener: (_, state) {
                        if (state is SendNotificationSuccess) {}
                      },
                      child: Material(
                        color: Colors.transparent,
                        child: IconButton(
                          onPressed: () {
                            final notificationBody =
                                friendCubit.messageController.text;
                            if (friendCubit.messageController.text.isNotEmpty) {
                              friendCubit.messageController.clear();
                              FriendCubit.get(context)
                                  .sendMessageToFriend(
                                friend: widget.friendData,
                                message: notificationBody,
                                sender: sender,
                                type: MessageType.text,
                              )
                                  .whenComplete(
                                () {
                                  scrollToBottom();
                                  NotificationsCubit.get(context)
                                      .sendNotification(
                                    widget.friendData.fCMToken ?? '',
                                    sender.userName!,
                                    notificationBody,
                                    'friend',
                                  );
                                },
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    // CustomRecordingButton(
                    //   isRecording: isRecording,
                    //   onPressed: () => _record(),
                    // ),

                    GestureDetector(
                      onLongPress: () async {
                        final audioPlayer = AudioPlayer();
                        await audioPlayer
                            .play(AssetSource("audios/Notification.mp3"));
                        _record();
                      },
                      onLongPressEnd: (details) {
                        debugPrint('End');
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
