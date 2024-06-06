import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class MediaView extends StatefulWidget {
  const MediaView({super.key});

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  late ProfileCubit profileCubit;
  VideoPlayerController? _videoController;
  bool isVideo = false;
  String mediaTitle = '';
  String mediaPath = '';
  String mediaOwner = '';
  int mediaTime = 0;
  bool profilePicture = false;
  bool isPlaying = false;
  bool _showPlayPauseButton = false;
  Timer? _hideButtonTimer;
  bool _isBuffering = false;
  File? _localFile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    profileCubit = ProfileCubit.get(context);
    if (args != null) {
      mediaPath = args['path'] as String;
      isVideo = args['isVideo'] as bool;
      mediaTitle = args['mediaTitle'] as String;
      mediaOwner = args['mediaOwner'] as String;
      mediaTime = args['mediaTime'] as int;
      profilePicture = args['profilePicture'] as bool;
      _checkLocalFile();
    }
  }

  Future<void> _checkLocalFile() async {
    final directory = await getExternalStorageDirectory();
    final fileName = mediaPath.split('/').last;
    final filePath = '${directory!.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      _localFile = file;
      if (isVideo) {
        _initializeVideoController(file);
      }
    } else {
      _fetchFromNetwork();
    }
  }

  Future<void> _initializeVideoController(File file) async {
    _videoController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        setState(() {});
        _videoController!.play();
        isPlaying = true;
        _videoController!.addListener(_updatePosition);
      })
      ..addListener(() {
        final bool isBuffering = _videoController!.value.isBuffering;
        if (isBuffering != _isBuffering) {
          setState(() {
            _isBuffering = isBuffering;
          });
        }
      });
  }

  Future<void> _fetchFromNetwork() async {
    if (isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaPath))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
          isPlaying = true;
          _videoController!.addListener(_updatePosition);
        })
        ..addListener(() {
          final bool isBuffering = _videoController!.value.isBuffering;
          if (isBuffering != _isBuffering) {
            setState(() {
              _isBuffering = isBuffering;
            });
          }
        });
    }
  }

  void _updatePosition() {
    if (_videoController != null) {
      setState(() {});
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    if (_videoController != null) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          isPlaying = false;
        } else {
          _videoController!.play();
          isPlaying = true;
        }
        _showPlayPauseButton = true;
        _hideButtonTimer?.cancel();
        _hideButtonTimer = Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            _showPlayPauseButton = false;
          });
        });
      });
    }
  }

  Future<void> _downloadMedia() async {
    try {
      if (await Permission.mediaLibrary.request().isGranted) {
        Fluttertoast.showToast(msg: 'Downloading...');
        final response = await http.get(Uri.parse(mediaPath));

        if (isVideo) {
          await _saveVideoToGallery(response.bodyBytes);
        } else {
          await _saveImageToGallery(response.bodyBytes);
        }
      } else {
        Fluttertoast.showToast(msg: 'MediaLibrary permission denied');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error downloading file: $e');
    }
  }

  Future<void> _saveImageToGallery(Uint8List bytes) async {
    final result = await ImageGallerySaver.saveImage(
      bytes,
      name: "IMG_${DateTime.now().toLocal().millisecondsSinceEpoch}",
    );
    if (result["isSuccess"] as bool) {
      Fluttertoast.showToast(msg: 'Image saved to gallery');
    } else {
      Fluttertoast.showToast(msg: 'Failed to save image');
    }
  }

  Future<void> _saveVideoToGallery(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath =
        '${tempDir.path}/VID_${DateTime.now().toLocal().millisecondsSinceEpoch}.mp4';
    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(bytes);

    final result = await ImageGallerySaver.saveFile(tempFilePath);
    if (result["isSuccess"] as bool) {
      Fluttertoast.showToast(msg: 'Video saved to gallery');
    } else {
      Fluttertoast.showToast(msg: 'Failed to save video');
    }
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    _hideButtonTimer?.cancel();
    super.dispose();
  }

  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;

  void _checkTextDirection(String text) {
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

  @override
  Widget build(BuildContext context) {
    _checkTextDirection(mediaTitle);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mediaOwner == profileCubit.user.userName ? 'You' : mediaOwner,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
              ),
            ),
            if (mediaTime != 0)
              Text(
                getFormattedTime(mediaTime),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
          ],
        ),
        actions: [
          if (!profilePicture)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadMedia,
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isVideo)
              (_videoController != null &&
                      _videoController!.value.isInitialized)
                  ? Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showPlayPauseButton = true;
                                    });
                                    _hideButtonTimer?.cancel();
                                    _hideButtonTimer = Timer(
                                        const Duration(milliseconds: 1000), () {
                                      setState(() {
                                        _showPlayPauseButton = false;
                                      });
                                    });
                                  },
                                  child: AspectRatio(
                                    aspectRatio:
                                        _videoController!.value.aspectRatio,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ),
                                if (_isBuffering)
                                  const Center(
                                    child: LoadingIndicator(),
                                  ),
                                AnimatedOpacity(
                                  opacity: _showPlayPauseButton ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: GestureDetector(
                                    onTap: _togglePlayPause,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black45,
                                      radius: 30.r,
                                      child: Icon(
                                        isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  _formatDuration(
                                    _videoController!.value.position,
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.w),
                                  child: VideoProgressIndicator(
                                    _videoController!,
                                    allowScrubbing: true,
                                    colors: const VideoProgressColors(
                                      playedColor: Colors.red,
                                      bufferedColor: Colors.grey,
                                      backgroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Text(
                                  _formatDuration(
                                    _videoController!.value.duration,
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const LoadingIndicator()
            else
              _localFile != null
                  ? Flexible(
                      child: PhotoView(
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: 5.0,
                        initialScale: PhotoViewComputedScale.contained,
                        imageProvider: FileImage(_localFile!),
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.black),
                      ),
                    )
                  : Flexible(
                      child: PhotoView(
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: 5.0,
                        initialScale: PhotoViewComputedScale.contained,
                        imageProvider: NetworkImage(mediaPath),
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.black),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
