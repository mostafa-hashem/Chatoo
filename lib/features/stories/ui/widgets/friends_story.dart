import 'dart:typed_data';

import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/stories/ui/screens/stories_screen.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FriendsStory extends StatefulWidget {
  FriendsStory({super.key});

  @override
  State<FriendsStory> createState() => _FriendsStoryState();
}

class _FriendsStoryState extends State<FriendsStory> {
  final Map<String, Uint8List?> _friendThumbnails = {};

  Future<void> _generateFriendThumbnail(String videoUrl) async {
    final unit8List = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
    if (mounted) {
      setState(() {
        _friendThumbnails[videoUrl] = unit8List;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendCubit = FriendCubit.get(context);
    return BlocBuilder<FriendCubit, FriendStates>(
      buildWhen: (_, current) =>
      current is GetFriendDataLoading ||
          current is GetFriendDataSuccess ||
          current is GetFriendDataSuccess,
      builder: (_, state) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: friendCubit.combinedFriends.length,
          itemBuilder: (context, index) {
            final combinedFriend = friendCubit.combinedFriends[index];
            final stories = combinedFriend.stories?.reversed.toList() ?? [];

            if (stories.isEmpty) {
              return const SizedBox.shrink();
            }
            final mediaUrl = stories.first.mediaUrl!;
            final fileName = mediaUrl
                .split('%')
                .last
                .split('.')
                .last
                .substring(0, 3)
                .toLowerCase();
            final isVideo = ['mp4', 'mov', 'avi', 'mkv'].contains(fileName);

            if (isVideo && !_friendThumbnails.containsKey(mediaUrl)) {
              _generateFriendThumbnail(mediaUrl);
            }

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: isVideo
                        ? (_friendThumbnails[mediaUrl] != null
                        ? MemoryImage(_friendThumbnails[mediaUrl]!)
                        : null)
                        : NetworkImage(mediaUrl) as ImageProvider,
                    radius: 28.r,
                    child: isVideo && _friendThumbnails[mediaUrl] == null
                        ? const LoadingIndicator()
                        : null,
                  ),
                  CustomPaint(
                    painter: StoryCirclePainter(storyCount: stories.length),
                    child: SizedBox(
                      width: 56.r,
                      height: 56.r,
                    ),
                  ),
                ],
              ),
              title: Text(
                combinedFriend.user?.userName ?? '',
                style: TextStyle(fontSize: 14.sp),
              ),
              subtitle: Text(
                getFormattedTime(
                  stories.first.uploadedAt!.toLocal().millisecondsSinceEpoch,
                ),
                style: TextStyle(fontSize: 10.sp),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.storyView,
                  arguments: {
                    'stories': stories,
                    'initialIndex': 0,
                    'myStory' : false,
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
