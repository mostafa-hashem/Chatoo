import 'package:chat_app/features/stories/cubit/stories_cubit.dart';
import 'package:chat_app/features/stories/cubit/stories_state.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoryViewersBottomSheet extends StatelessWidget {
  final List<User?> viewers;
  final List<MapEntry<String, dynamic>> seenEntries;

  StoryViewersBottomSheet({
    super.key,
    required this.viewers,
    required this.seenEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      constraints: BoxConstraints(maxHeight: 400.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Viewers',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: ListView.builder(
              itemCount: viewers.length,
              itemBuilder: (context, index) {
                if (index >= viewers.length || index >= seenEntries.length) {
                  return const SizedBox.shrink();
                }

                final User? user = viewers[index];
                final DateTime viewedAt =
                    (seenEntries[index].value as Timestamp).toDate();

                if (user == null) {
                  return ListTile(
                    title: const Text("Unknown user"),
                    subtitle: Text(viewedAt.toString()),
                  );
                }
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      user.profileImage ?? FirebasePath.defaultImage,
                    ),
                  ),
                  title: Text(user.userName ?? ''),
                  subtitle: Text(
                    getFormattedTime(
                      viewedAt.millisecondsSinceEpoch,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
