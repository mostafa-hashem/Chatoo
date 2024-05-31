import 'dart:async';
import 'dart:io';

import 'package:chat_app/features/stories/cubit/stories_cubit.dart';
import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class StoryView extends StatefulWidget {
  const StoryView({super.key});

  @override
  State<StoryView> createState() => _StoryViewState();
}

class _StoryViewState extends State<StoryView> {
  VideoPlayerController? _videoController;
  bool isVideo = false;
  bool isLoading = true;
  String mediaTitle = '';
  String fileName = '';
  List<Story> stories = [];
  int currentIndex = 0;
  bool isPlaying = false;
  bool myStory = false;
  Timer? _storyTimer;
  double _progress = 0.0;
  static const int defaultStoryDurationSeconds = 10;
  static const Duration storyTransitionDelay = Duration(milliseconds: 500); // مدة التأخير بين الاستوري
  File? _localFile;
  final PageController _pageController = PageController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      stories = args['stories'] as List<Story>;
      currentIndex = args['initialIndex'] as int;
      myStory = args['myStory'] as bool;
      _pageController.addListener(() {
        setState(() {
          currentIndex = _pageController.page!.round();
          _loadStory();
        });
      });
      _loadStory();
    }
  }

  void _loadStory() {
    if (currentIndex >= stories.length) {
      Navigator.of(context).pop();
      return;
    }
    final story = stories[currentIndex];
    isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(
      story.mediaUrl!
          .split('%')
          .last
          .split('.')
          .last
          .substring(0, 3)
          .toLowerCase(),
    );
    mediaTitle = story.storyTitle ?? '';
    fileName = extractFileName(story.mediaUrl!, isVideo);

    _videoController?.dispose();
    _videoController = null;
    isLoading = true;
    if (isVideo) {
      _initializeVideoController(story.mediaUrl!);
    } else {
      _startStoryTimer(const Duration(seconds: defaultStoryDurationSeconds));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _initializeVideoController(String videoUrl) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        _videoController!.play();
        isPlaying = true;
        _videoController!.addListener(_updatePosition);
        _startStoryTimer(_videoController!.value.duration);
      });
  }

  void _startStoryTimer(Duration duration) {
    _storyTimer?.cancel();
    _progress = 0.0;
    final int storyDurationSeconds =
    isVideo ? duration.inSeconds : defaultStoryDurationSeconds;
    _storyTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.1 / storyDurationSeconds;
        if (_progress >= 1.0) {
          timer.cancel();
          _goToNextStory();
        }
      });
    });
  }

  Future<void> _goToNextStory() async {
    if (currentIndex < stories.length - 1) {
      await Future.delayed(storyTransitionDelay);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goToPreviousStory() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _updatePosition() {
    if (!mounted) return;
    setState(() {});
  }

  String extractFileName(String url, bool isVideo) {
    String fileName = '';
    if (isVideo) {
      fileName = url.split('/').last;
      final dimensionsAndDuration = fileName.split('%5E');
      final dimensions = dimensionsAndDuration[0].split('x');
      final durationStr = dimensionsAndDuration[1].split('?').first;

      final width = double.tryParse(dimensions[0].split('%2F').last);
      final height = double.tryParse(dimensions[1]);

      return '${width}x$height^$durationStr';
    } else {
      final Uri uri = Uri.parse(url);
      final String path = uri.path;
      return path.split('%2F').last.split('?').last;
    }
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
  void dispose() {
    _videoController?.removeListener(_updatePosition);
    _videoController?.dispose();
    _storyTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyCubit = StoriesCubit.get(context);
    _checkTextDirection(mediaTitle);
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (myStory)
            IconButton(
              onPressed: () {
                storyCubit
                    .deleteStory(fileName: fileName, storyId: stories[currentIndex].id!)
                    .whenComplete(
                      () => _goToNextStory(),
                );
              },
              icon: const Icon(Icons.delete_forever_outlined),
            ),
        ],
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return GestureDetector(
                onTapDown: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final dx = details.globalPosition.dx;
                  if (dx < screenWidth / 3) {
                    _goToPreviousStory();
                  } else if (dx > 2 * screenWidth / 3) {
                    _goToNextStory();
                  }
                },
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isVideo)
                            (_videoController != null &&
                                _videoController!.value.isInitialized)
                                ? Flexible(
                              child: AspectRatio(
                                aspectRatio:
                                _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                            )
                                : const SizedBox.shrink()
                          else
                            _localFile != null
                                ? Expanded(
                              child: PhotoView(
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: 5.0,
                                initialScale:
                                PhotoViewComputedScale.contained,
                                imageProvider: FileImage(_localFile!),
                                backgroundDecoration:
                                const BoxDecoration(color: Colors.black),
                              ),
                            )
                                : Expanded(
                              child: PhotoView(
                                minScale: PhotoViewComputedScale.contained,
                                maxScale: 5.0,
                                initialScale:
                                PhotoViewComputedScale.contained,
                                imageProvider:
                                NetworkImage(story.mediaUrl!),
                                backgroundDecoration:
                                const BoxDecoration(color: Colors.black),
                              ),
                            ),
                        ],
                      ),
                      if (isLoading) const Center(child: LoadingIndicator()),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: List.generate(stories.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: LinearProgressIndicator(
                      value: currentIndex == index ? _progress : (currentIndex > index ? 1.0 : 0.0),
                      backgroundColor: Colors.black.withOpacity(0.5),
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: Text(
                  textAlign: _textAlign,
                  textDirection: _textDirection,
                  mediaTitle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
