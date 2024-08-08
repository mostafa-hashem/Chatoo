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
  File? mediaFile;
  final audioPlayer = AudioPlayer();
  String? notificationBody;
  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;
  bool _isMounted = false;

  @override
  void didChangeDependencies() {
    groupCubit = GroupCubit.get(context);
    sender = ProfileCubit.get(context).user;
    groupCubit.messageController.addListener(_checkTextDirection);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    _isMounted = true;
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _isMounted = false;
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
                groupCubit
                    .uploadMediaToGroup(
                  FirebasePath.audios,
                  audioFile,
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
                    ) .whenComplete(
                          () => audioPlayer.play(
                        AssetSource(
                          "audios/message_received.wav",
                        ),
                      ),
                    );
                  },
                ).catchError((error) {
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
                    .whenComplete(
                  () {
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
      if (_isMounted) {
        setState(() {
          _textAlign = TextAlign.right;
          _textDirection = TextDirection.rtl;
        });
      }
    } else {
      if (_isMounted) {
        setState(() {
          _textAlign = TextAlign.left;
          _textDirection = TextDirection.ltr;
        });
      }
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
    if (_isMounted && groupCubit.scrollController.hasClients) {
      groupCubit.scrollController.animateTo(
        groupCubit.scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    return BlocConsumer<GroupCubit, GroupStates>(
      listener: (_, state) {
        if (state is SendMessageToGroupSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollToBottom();
          });
          audioPlayer.play(AssetSource("audios/message_received.wav"));
          final List<dynamic> memberIds = widget.groupData.members!.toList();
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
            for (final String? fCMToken
                in groupCubit.userData!.fCMTokens! as List<String>) {
              NotificationsCubit.get(context).sendNotification(
                fCMToken: fCMToken ?? '',
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
        }
      },
      buildWhen: (_, current) => current is SetRepliedMessageSuccess,
      builder: (_, state) {
        return Column(
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
                    ),
                  if (isRecording)
                    const Flexible(
                      child: CustomRecordingWaveWidget(),
                    )
                  else
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (groupCubit.replayedMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        groupCubit.replayedMessage!.sender
                                                ?.userName ??
                                            'Unknown',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.sp,
                                          color: Colors.black,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          groupCubit.setRepliedMessage(null);
                                        },
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${groupCubit.replayedMessage!.message}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: TextField(
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
                                suffixIcon: groupCubit.messageController.text.isEmpty ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                      IconButton(
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
                                      IconButton(
                                        onPressed: _pickAudioFile,
                                        icon: const Icon(Icons.audiotrack),
                                      ),
                                  ],
                                ) : null,
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
                  if (groupCubit.messageController.text.isNotEmpty)
                    IconButton(
                      padding: const EdgeInsets.all(4),
                      onPressed: () async {
                        notificationBody = groupCubit.messageController.text;
                        if (groupCubit.messageController.text.isNotEmpty) {
                          groupCubit.messageController.clear();
                          groupCubit
                              .sendMessageToGroup(
                                group: widget.groupData,
                                sender: sender,
                                message: notificationBody ?? '',
                                type: MessageType.text,
                                isAction: false,
                                repliedMessage: groupCubit.replayedMessage,
                              )
                              .whenComplete(
                                () => groupCubit.setRepliedMessage(null),
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
        );
      },
    );
  }
}
