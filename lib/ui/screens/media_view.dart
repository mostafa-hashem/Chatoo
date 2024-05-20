import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class MediaView extends StatefulWidget {
  const MediaView({super.key});

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  late VideoPlayerController _videoController;
  bool isVideo = false;
  String mediaPath = '';
  bool isPlaying = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments! as Map;
    mediaPath = args['path'] as String;
    isVideo = args['isVideo'] as bool;

    if (isVideo) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaPath))
        ..initialize().then((_) {
          setState(() {});
          _videoController.play();
          isPlaying = true;
          _videoController.addListener(_updatePosition);
        });
    }
  }

  void _updatePosition() {
    _videoController.value.position.inSeconds.toDouble();
    _videoController.value.duration.inSeconds.toDouble();
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    if (isVideo) {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Center(
        child: isVideo
            ? _videoController.value.isInitialized
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                      Row(
                        children: [
                          Text(
                            _formatDuration(
                              _videoController.value.position,
                            ),
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.sp),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 9.w),
                              child: VideoProgressIndicator(
                                _videoController,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: Colors.red,
                                  bufferedColor: Colors.grey,
                                  backgroundColor: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            _formatDuration(
                              _videoController.value.duration,
                            ),
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ],
                  )
                : const CircularProgressIndicator()
            : PhotoView(
                minScale: PhotoViewComputedScale.contained,
                maxScale: 5.0,
                initialScale: PhotoViewComputedScale.contained,
                imageProvider: NetworkImage(mediaPath),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
              ),
      ),
      floatingActionButton: isVideo
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_videoController.value.isPlaying) {
                    _videoController.pause();
                    isPlaying = false;
                  } else {
                    _videoController.play();
                    isPlaying = true;
                  }
                });
              },
              child: Icon(
                _videoController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}
