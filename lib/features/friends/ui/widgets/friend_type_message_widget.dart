import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/friends/ui/widgets/custom_text_field.dart';
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
import 'package:fluttertoast/fluttertoast.dart';
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
        friendCubit.updateRecordingStatus(
          friendId: widget.friendData.id!,
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
            friendId: widget.friendData.id!,
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

  void scrollToBottom() {
    final scrollController = FriendCubit.get(context).scrollController;
    scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  void _onBackspacePressed() {
    friendCubit.messageController
      ..text = friendCubit.messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: friendCubit.messageController.text.length),
      );
  }

  bool isMuted() {
    if (widget.friendData.mutedFriends != null) {
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
                  friendData: ProfileCubit.get(context).user,
                );
              }
            }
          },
        ),
        BlocListener<FriendCubit, FriendStates>(
          listener: (_, state) {
            if (state is SendMediaToFriendSuccess) {
              Fluttertoast.showToast(msg: 'Media uploaded successfully.');
            }
          },
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 10.h),
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
                  )
                else
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
                if (isRecording)
                  const Flexible(
                    child: CustomRecordingWaveWidget(),
                  )
                else
                  Flexible(
                    child: CustomTextField(
                      friendData: widget.friendData,
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
                        await friendCubit
                            .sendMessageToFriend(
                              friend: widget.friendData,
                              message: notificationBody ?? '',
                              sender: sender,
                              type: MessageType.text,
                            )
                            .whenComplete(
                              () => audioPlayer.play(
                                AssetSource(
                                  "audios/message_received.wav",
                                ),
                              ),
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
                            await Fluttertoast.showToast(msg: 'Sending...');
                            await friendCubit
                                .sendMediaToFriend(
                              FirebasePath.records,
                              recordFile,
                              widget.friendData.id!,
                              getAudioFileName,
                            )
                                .whenComplete(
                              () {
                                friendCubit
                                    .sendMessageToFriend(
                                      friend: widget.friendData,
                                      sender: sender,
                                      message: '',
                                      type: MessageType.record,
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
              textEditingController: friendCubit.messageController,
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
