import 'dart:async';
import 'dart:io';

import 'package:chat_app/features/stories/cubit/stories_cubit.dart';
import 'package:chat_app/features/stories/cubit/stories_state.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_player/video_player.dart';

class EditStoryScreen extends StatefulWidget {
  final File mediaFile;
  final bool isVideo;

  const EditStoryScreen({required this.mediaFile, required this.isVideo});

  @override
  _EditStoryScreenState createState() => _EditStoryScreenState();
}

class _EditStoryScreenState extends State<EditStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  late VideoPlayerController _videoPlayerController;
   Duration _startTrim = Duration.zero;
  Duration _endTrim = Duration.zero;
  bool isPlaying = true;
  bool _showPlayPauseButton = true;
  Timer? _hideButtonTimer;

  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _videoPlayerController = VideoPlayerController.file(widget.mediaFile)
        ..initialize().then((_) {
          setState(() {});
          _endTrim = _videoPlayerController.value.duration;
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
        });
    }

    _textController.addListener(_checkTextDirection);
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _videoPlayerController.dispose();
    }
    _textController.dispose();
    _hideButtonTimer?.cancel();
    super.dispose();
  }

  void _checkTextDirection() {
    final text = _textController.text;
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


  Future<void> _trimVideo() async {
    final String outputPath = '${widget.mediaFile.path}.mp4';
    final String command =
        '-i ${widget.mediaFile.path} -ss ${_startTrim.inSeconds} -to ${_endTrim.inSeconds} -c copy $outputPath';
    // await _flutterFFmpeg.execute(command).then((rc) {
    //   if (rc == 0) {
    //     final trimmedFile = File(outputPath);
    //     _uploadMedia(trimmedFile);
    //     Fluttertoast.showToast(msg: 'Uploading...');
    //   } else {
    //     Fluttertoast.showToast(msg: 'Error trimming video');
    //   }
    // });
  }

  void _uploadMedia(File file) {
    final storyCubit = StoriesCubit.get(context);
    Fluttertoast.showToast(msg: 'Uploading...');
    storyCubit.uploadStory(
      mediaFile: file,
      getFileName: widget.isVideo ? getVideoFileName : getImageFileName,
      storyCaption: _textController.text,
    ).catchError((error) {
      Fluttertoast.showToast(msg: 'Error: $error');
      debugPrint('Error sending file: $error');
    });
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _videoPlayerController.pause();
      } else {
        _videoPlayerController.play();
      }
      isPlaying = !isPlaying;
    });
    _startHideButtonTimer();
  }

  void _startHideButtonTimer() {
    _hideButtonTimer?.cancel();
    setState(() {
      _showPlayPauseButton = true;
    });
    _hideButtonTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _showPlayPauseButton = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Story'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (widget.isVideo) {
                  _uploadMedia(widget.mediaFile);
                } else {
                  _uploadMedia(widget.mediaFile);
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: BlocListener<StoriesCubit, StoriesState>(
                listener: (_, state) {
                  if (state is UploadStorySuccess) {
                    Fluttertoast.showToast(msg: 'Story uploaded');
                  }
                },
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isVideo)
                        (_videoPlayerController.value.isInitialized)
                            ? Flexible(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: _videoPlayerController.value.aspectRatio,
                                child: VideoPlayer(_videoPlayerController),
                              ),
                              AnimatedOpacity(
                                opacity: _showPlayPauseButton ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: IconButton(
                                  icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                  onPressed: _togglePlayPause,
                                ),
                              ),
                            ],
                          ),
                        )
                            : const CircularProgressIndicator()
                      else
                        Expanded(
                          child: Image.file(widget.mediaFile),
                        ),
                      if (false)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Start: ${_startTrim.inSeconds} s'),
                                  Expanded(
                                    child: Slider(
                                      value: _startTrim.inSeconds.toDouble(),
                                      max: _videoPlayerController
                                          .value.duration.inSeconds
                                          .toDouble(),
                                      onChanged: (value) {
                                        setState(() {
                                          _startTrim =
                                              Duration(seconds: value.toInt());
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('End: ${_endTrim.inSeconds} s'),
                                  Expanded(
                                    child: Slider(
                                      value: _endTrim.inSeconds.toDouble(),
                                      max: _videoPlayerController
                                          .value.duration.inSeconds
                                          .toDouble(),
                                      onChanged: (value) {
                                        setState(() {
                                          _endTrim =
                                              Duration(seconds: value.toInt());
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _textController,
                  style: TextStyle(fontSize: 16.sp),
                  minLines: 1,
                  maxLines: 5,
                  textAlign: _textAlign,
                  textDirection: _textDirection,
                  decoration: InputDecoration(
                    hintText: 'Add a caption',
                    hintStyle: TextStyle(fontSize: 16.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
