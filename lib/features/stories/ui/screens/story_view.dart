import 'dart:async';
import 'dart:io';

import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/stories/cubit/stories_cubit.dart';
import 'package:chat_app/features/stories/cubit/stories_state.dart';
import 'package:chat_app/features/stories/data/models/story.dart';
import 'package:chat_app/features/stories/ui/widgets/story_text_field.dart';
import 'package:chat_app/features/stories/ui/widgets/story_viewers_bottom_sheet.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool isLoading = false;
  String mediaTitle = '';
  String fileName = '';
  List<Story> stories = [];
  int currentIndex = 0;
  bool isPlaying = false;
  bool myStory = false;
  User? userData;
  Timer? _storyTimer;
  double _progress = 0.0;
  static const int defaultStoryDurationSeconds = 10;
  static const Duration storyTransitionDelay = Duration(milliseconds: 500);
  File? _localFile;
  final PageController _pageController = PageController();
  late FriendCubit friendCubit;
  late StoriesCubit storiesCubit;

  Duration? _lastVideoPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    friendCubit = FriendCubit.get(context);
    storiesCubit = StoriesCubit.get(context);
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      stories = args['stories'] as List<Story>;
      currentIndex = args['initialIndex'] as int;
      myStory = args['myStory'] as bool;
      userData = args['userData'] as User;
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
      _initializeImageController(story.mediaUrl!);
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

  Future<void> _initializeImageController(String imageUrl) async {
    NetworkImage(imageUrl).resolve(ImageConfiguration.empty).addListener(
          ImageStreamListener(
            (info, _) {
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
                _startStoryTimer(
                  const Duration(seconds: defaultStoryDurationSeconds),
                );
              }
            },
            onError: (_, __) {
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
                _startStoryTimer(
                  const Duration(seconds: defaultStoryDurationSeconds),
                );
              }
            },
          ),
        );
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

  void _pauseStory() {
    _storyTimer?.cancel();
    if (_videoController != null && _videoController!.value.isPlaying) {
      _lastVideoPosition = _videoController!.value.position;
      _videoController!.pause();
    }
  }

  void _resumeStory() {
    final remainingDuration = isVideo
        ? _videoController!.value.duration - _videoController!.value.position
        : const Duration(seconds: defaultStoryDurationSeconds) *
            (1.0 - _progress);
    _startStoryTimer(remainingDuration);
    if (_videoController != null && _lastVideoPosition != null) {
      _videoController!.seekTo(_lastVideoPosition!);
      _videoController!.play();
    }
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
    _checkTextDirection(mediaTitle);
    return GestureDetector(
      onTap: () {
        _resumeStory();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black45,
          elevation: 0,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                myStory ? "You" : userData?.userName ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                getFormattedTime(
                  stories[currentIndex].uploadedAt!.millisecondsSinceEpoch,
                ),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          actions: [
            if (myStory)
              IconButton(
                onPressed: () {
                  storiesCubit
                      .deleteStory(
                        fileName: fileName,
                        storyId: stories[currentIndex].id!,
                      )
                      .whenComplete(
                        () => _goToNextStory(),
                      );
                },
                icon: const Icon(Icons.delete_forever_outlined),
              ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0.h),
            child: Row(
              children: List.generate(stories.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: LinearProgressIndicator(
                      value: currentIndex == index
                          ? _progress
                          : (currentIndex > index ? 1.0 : 0.0),
                      backgroundColor: Colors.black.withOpacity(0.5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: stories.length,
              itemBuilder: (context, index) {
                if (!myStory) {
                  storiesCubit.updateStorySeen(
                    storyId: stories[currentIndex].id ?? '',
                  );
                }
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
                  onLongPressStart: (_) => _pauseStory(),
                  onLongPressEnd: (_) => _resumeStory(),
                  onTap: () {
                    _resumeStory();
                    FocusScope.of(context).unfocus();
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
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        maxScale: 5.0,
                                        initialScale:
                                            PhotoViewComputedScale.contained,
                                        imageProvider: FileImage(_localFile!),
                                        backgroundDecoration:
                                            const BoxDecoration(
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      child: PhotoView(
                                        minScale:
                                            PhotoViewComputedScale.contained,
                                        maxScale: 5.0,
                                        initialScale:
                                            PhotoViewComputedScale.contained,
                                        imageProvider:
                                            NetworkImage(story.mediaUrl!),
                                        backgroundDecoration:
                                            const BoxDecoration(
                                          color: Colors.black,
                                        ),
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
              bottom: 0.h,
              left: 0.w,
              right: 0.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 18.h),
                      child: Text(
                        textAlign: _textAlign,
                        textDirection: _textDirection,
                        mediaTitle,
                        style: TextStyle(
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    if (myStory)
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                showViewersBottomSheet(
                                  context,
                                  stories[currentIndex].seen,
                                  storiesCubit,
                                );
                              },
                              icon: const Icon(
                                Icons.remove_red_eye_outlined,
                              ),
                            ),
                            Text(
                              "${stories[currentIndex].seen?.length ?? 0}",
                            ),
                          ],
                        ),
                      ),
                    if (!myStory)
                      StoryTextField(
                        userData: userData ?? User.empty(),
                        story: stories[currentIndex],
                        resumeStory: _resumeStory,
                        pauseStory: _pauseStory,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showViewersBottomSheet(
      BuildContext context,
      Map<String, dynamic>? seen,
      StoriesCubit storiesCubit,
      ) async {
    if (seen == null || seen.isEmpty) return;

    final List<MapEntry<String, dynamic>> seenEntries = seen.entries.toList();
    seenEntries
        .sort((a, b) => (b.value as Timestamp).compareTo(a.value as Timestamp));

    final List<User?> cachedViewers = [];
    List<User?> viewers = [];
    for (final entry in seenEntries) {
      final User? user = await storiesCubit.getUserById(userId: entry.key);
      cachedViewers.add(user);
    }
    if (cachedViewers.length == seen.length) {
      viewers = cachedViewers;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return BlocBuilder<StoriesCubit, StoriesState>(
              builder: (_, state) {
                if (state is GetUserByIdLoading) {
                  return const LoadingIndicator();
                } else if (state is GetUserByIdError) {
                  return const ErrorIndicator();
                } else {
                  return StoryViewersBottomSheet(
                    viewers: viewers,
                    seenEntries: seenEntries,
                  );
                }
              },
            );
          },
        );
      },
    );
  }

}
