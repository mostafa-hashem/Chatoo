import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
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
  File? mediaFile;
  String? notificationBody;

  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    sender = ProfileCubit.get(context).user;
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
      duration: const Duration(milliseconds: 700),
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
                        BoxConstraints(minHeight: 40.h, maxHeight: 180.h),
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
                                  controller: groupCubit.messageController,
                                  onChanged: (value) {
                                    setState(() {});
                                  },

                                  textInputAction: TextInputAction.newline,
                                  minLines: 1,
                                  maxLines: null,
                                  // expands: true,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: provider.themeMode == ThemeMode.light
                                        ? Colors.black87
                                        : AppColors.light,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Type a message',
                                    hintStyle:
                                        Theme.of(context).textTheme.bodySmall,
                                    filled: true,
                                    fillColor:
                                        provider.themeMode == ThemeMode.light
                                            ? Colors.white
                                            : AppColors.dark,
                                    suffixIcon:
                                        groupCubit
                                                .messageController.text.isEmpty
                                            ? IconButton(
                                                padding:
                                                    const EdgeInsets.all(4),
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
                                                      final String fileType =
                                                          xFile.name
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
                                                                child:
                                                                    const Text(
                                                                  'Cancel',
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                              ),
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                  'Send',
                                                                ),
                                                                onPressed: () {
                                                                  if (isImage) {
                                                                    groupCubit
                                                                        .uploadMediaToGroup(
                                                                      FirebasePath
                                                                          .images,
                                                                      mediaFile!,
                                                                      widget
                                                                          .groupData
                                                                          .groupId!,
                                                                      getImageFileName,
                                                                    )
                                                                        .then(
                                                                      (value) {
                                                                        groupCubit
                                                                            .sendMessageToGroup(
                                                                          group:
                                                                              widget.groupData,
                                                                          sender:
                                                                              sender,
                                                                          mediaUrls:
                                                                              groupCubit.mediaUrls,
                                                                          message: groupCubit.messageController.text.isEmpty
                                                                              ? ''
                                                                              : groupCubit.messageController.text,
                                                                          type:
                                                                              MessageType.image,
                                                                          isAction:
                                                                              false,
                                                                        );
                                                                      },
                                                                    );
                                                                  } else if (isVideo) {
                                                                    groupCubit
                                                                        .uploadMediaToGroup(
                                                                      FirebasePath
                                                                          .videos,
                                                                      mediaFile!,
                                                                      widget
                                                                          .groupData
                                                                          .groupId!,
                                                                      getVideoFileName,
                                                                    )
                                                                        .then(
                                                                      (value) {
                                                                        groupCubit
                                                                            .sendMessageToGroup(
                                                                          group:
                                                                              widget.groupData,
                                                                          sender:
                                                                              sender,
                                                                          mediaUrls:
                                                                              groupCubit.mediaUrls,
                                                                          message: groupCubit.messageController.text.isEmpty
                                                                              ? ''
                                                                              : groupCubit.messageController.text,
                                                                          type:
                                                                              MessageType.video,
                                                                          isAction:
                                                                              false,
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
                                    contentPadding: const EdgeInsets.only(
                                      left: 16.0,
                                      bottom: 8.0,
                                      top: 8.0,
                                      right: 16.0,
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
                                ),
                              ),
                            ],
                          ),
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
                            await groupCubit
                                .uploadMediaToGroup(
                              FirebasePath.records,
                              recordFile,
                              widget.groupData.groupId!,
                              getAudioFileName,
                            )
                                .whenComplete(
                              () {
                                groupCubit.sendMessageToGroup(
                                  group: widget.groupData,
                                  sender: sender,
                                  message: '',
                                  type: MessageType.record,
                                  isAction: false,
                                  mediaUrls: groupCubit.mediaUrls,
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
                textEditingController: groupCubit.messageController,
                onBackspacePressed: _onBackspacePressed,
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
                    'No Resents',
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
