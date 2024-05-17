import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/data/model/group_data.dart';
import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/notifications/cubit/notifications_states.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/custom_recording_wave_widget.dart';
import 'package:chat_app/utils/constants.dart';
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
  bool isRecording = false;
  late final AudioRecorder _audioRecorder;
  String? _audioPath;
  final audioPlayer = AudioPlayer();
  File? imageFile;

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
    final sender = ProfileCubit.get(context).user;
    return BlocListener<GroupCubit, GroupStates>(
      listener: (_, state) {
        if (state is UploadMediaToGroupSuccess) {
          debugPrint("HIIIIIIIIIIIIIIIIIII");
          groupCubit.sendMessageToGroup(
            group: widget.groupData,
            duration: 0,
            sender: sender,
            mediaUrls: groupCubit.mediaUrls,
            message: groupCubit.messageController.text.isEmpty ? '' : groupCubit.messageController.text ,
            type: MessageType.image,
            isAction: false,
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
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: TextField(
                          controller: groupCubit.messageController,
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
                            hintText: 'Type a message',
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            filled: true,
                            fillColor: provider.themeMode == ThemeMode.light
                                ? Colors.white
                                : AppColors.dark,
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
                                                groupCubit.uploadMediaToGroup(
                                                  FirebasePath.images,
                                                  imageFile!,
                                                  widget.groupData.groupId!,
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
                  // if (groupCubit.messageController.text.isNotEmpty)
                  BlocListener<NotificationsCubit, NotificationsStates>(
                    listener: (context, state) {
                      if (state is SendNotificationSuccess) {}
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        onPressed: () async {
                          final notificationBody =
                              groupCubit.messageController.text;
                          if (groupCubit.messageController.text.isNotEmpty) {
                            groupCubit.messageController.clear();
                            groupCubit
                                .sendMessageToGroup(
                              group: widget.groupData,
                              sender: sender,
                              message: notificationBody,
                              type: MessageType.text,
                              isAction: false,
                            )
                                .whenComplete(() {
                              scrollToBottom();
                              final List<dynamic> memberIds =
                                  widget.groupData.members!.toList();
                              for (final memberId in memberIds) {
                                if (memberId ==
                                    ProfileCubit.get(context).user.id) {
                                  continue;
                                }
                                groupCubit
                                    .getUserData(memberId.toString())
                                    .whenComplete(
                                  () {
                                    NotificationsCubit.get(context)
                                        .sendNotification(
                                      groupCubit.userData?.fCMToken ?? '',
                                      'New Messages in ${widget.groupData.groupName}',
                                      "${ProfileCubit.get(context).user.userName}: \n$notificationBody",
                                      'group',
                                    );
                                  },
                                );
                              }
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                  // else
                  // BlocListener<GroupCubit, GroupStates>(
                  //   listener: (_, state) async {
                  //     if (state is UploadRecordToGroupSuccess)  {
                  //
                  //       final Duration? duration = await audioPlayer.getDuration();
                  //       debugPrint('Duration: $duration');
                  //     //   groupCubit.sendMessageToGroup(
                  //     //     group: widget.groupData,
                  //     //     message: '',
                  //     //     type: MessageType.record,
                  //     //     isAction: false,
                  //     //     mediaUrls: groupCubit.mediaUrls,
                  //     //     duration: 0,
                  //     //   );
                  //     }
                  //   },
                  //   child: GestureDetector(
                  //     onLongPress: () async {
                  //       await audioPlayer
                  //           .play(AssetSource("audios/Notification.mp3"));
                  //       _record();
                  //     },
                  //     onLongPressEnd: (details) async {
                  //       final File recordFile = File(_audioPath!);
                  //       await groupCubit.uploadRecordToGroup(
                  //         recordFile,
                  //         widget.groupData.groupId!,
                  //       );
                  //       debugPrint('End');
                  //     },
                  //     child: isRecording
                  //         ? Padding(
                  //             padding: const EdgeInsets.all(8.0),
                  //             child: CircleAvatar(
                  //               backgroundColor: Colors.greenAccent,
                  //               radius: 38.r,
                  //               child: const Center(child: Icon(Icons.mic)),
                  //             ),
                  //           )
                  //         : const Padding(
                  //             padding: EdgeInsets.all(8.0),
                  //             child: Icon(Icons.mic),
                  //           ),
                  //   ),
                  // ),
                ],
              ),
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
