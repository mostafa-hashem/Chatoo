import 'dart:async';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
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
  bool _showPlayPauseButton = false;
  Timer? _hideButtonTimer;

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
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
        isPlaying = false;
      } else {
        _videoController.play();
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

  @override
  void dispose() {
    if (isVideo) {
      _videoController.dispose();
    }
    _hideButtonTimer?.cancel();
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
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
                AnimatedOpacity(
                  opacity: _showPlayPauseButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      radius: 30,
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
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
            : const LoadingIndicator()
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
    );
  }
}
