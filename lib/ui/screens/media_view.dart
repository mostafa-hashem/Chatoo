import 'package:flutter/material.dart';
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
  bool _isPlaying = false;
  double _currentPosition = 0;

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
          _isPlaying = true;
          _videoController.addListener(_updatePosition);
        });
    }
  }

  void _updatePosition() {
    final currentPosition = _videoController.value.position.inSeconds.toDouble();
    final totalDuration = _videoController.value.duration.inSeconds.toDouble();
    setState(() {
      _currentPosition = currentPosition / totalDuration;
    });
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
            Slider(
              value: _currentPosition,
              onChanged: (value) {
                final newPosition = value *
                    _videoController.value.duration.inSeconds;
                _videoController.seekTo(Duration(seconds: newPosition.toInt()));
              },
              activeColor: Colors.red,
              inactiveColor: Colors.grey,
            ),
          ],
        )
            : const CircularProgressIndicator()
            : PhotoView(
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
              _isPlaying = false;
            } else {
              _videoController.play();
              _isPlaying = true;
            }
          });
        },
        child: Icon(
          _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      )
          : null,
    );
  }
}
