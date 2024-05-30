import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/groups/ui/widgets/custom_group_text_field.dart';
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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class GroupTypeMessageWidget extends StatefulWidget {
  final Group groupData;

  const GroupTypeMessageWidget({super.key, required this.groupData});

  @override
  State<GroupTypeMessageWidget> createState() => _GroupTypeMessageWidgetState();
}

class _GroupTypeMessageWidgetState extends State<GroupTypeMessageWidget> {
  bool emojiShowing = false;

  late GroupCubit groupCubit;
  late User sender;
  bool isRecording = false;
  late final AudioRecorder _audioRecorder;
  String? _audioPath;
  final audioPlayer = AudioPlayer();
  String? notificationBody;

  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    super.didChangeDependencies();
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

  void _onBackspacePressed() {
    groupCubit.messageController
      ..text = groupCubit.messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: groupCubit.messageController.text.length),
      );
  }

  void scrollToBottom() {
    groupCubit.scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<GroupCubit, GroupStates>(
          listener: (_, state) {
            if (state is SendMessageToGroupSuccess) {
              scrollToBottom();
              audioPlayer.play(AssetSource("audios/message_received.wav"));
              final List<dynamic> memberIds =
                  widget.groupData.members!.toList();
              for (final memberId in memberIds) {
                groupCubit.getUserData(memberId.toString());
                bool isMuted() {
                  if (groupCubit.userData?.mutedGroups != null) {
                    return groupCubit.userData!.mutedGroups!
                        .any((groupId) => groupId == widget.groupData.groupId);
                  }
                  return false;
                }

                if (memberId == sender.id || isMuted()) {
                  continue;
                }
                NotificationsCubit.get(context).sendNotification(
                  fCMToken: groupCubit.userData?.fCMToken ?? '',
                  title: 'New Messages in ${widget.groupData.groupName}',
                  body:
                      "${ProfileCubit.get(context).user.userName}: \n$notificationBody",
                  imageUrl: groupCubit.mediaUrls.isNotEmpty
                      ? groupCubit.mediaUrls.first
                      : null,
                  groupData: widget.groupData,
                );
              }
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
                    child: CustomGroupTextField(
                      groupData: widget.groupData,
                    ),
                  ),
                if (groupCubit.messageController.text.isNotEmpty)
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    onPressed: () async {
                      notificationBody = groupCubit.messageController.text;
                      if (groupCubit.messageController.text.isNotEmpty) {
                        groupCubit.messageController.clear();
                        groupCubit.sendMessageToGroup(
                          group: widget.groupData,
                          sender: sender,
                          message: notificationBody ?? '',
                          type: MessageType.text,
                          isAction: false,
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
                            await groupCubit
                                .uploadMediaToGroup(
                              FirebasePath.records,
                              recordFile,
                              widget.groupData.groupId!,
                              getAudioFileName,
                            )
                                .whenComplete(
                              () {
                                notificationBody = 'sent a recording';
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
                            //     .play(AssetSource("audios/Notification.mp3"));
                            await _record();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              radius: 20.r,
                              child: const Center(
                                child: Icon(
                                  Icons.mic,
                                  color: Colors.white,
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
            child: EmojiPicker(
              textEditingController: groupCubit.messageController,
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
