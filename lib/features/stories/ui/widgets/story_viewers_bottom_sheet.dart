import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StoryViewersBottomSheet extends StatelessWidget {
  final List<User?> viewers;
  final List<MapEntry<String, dynamic>> seenEntries;

  const StoryViewersBottomSheet({
    super.key,
    required this.viewers,
    required this.seenEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            color: AppColors.primary,
          ),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Row(
            children: [
              const Text(
                'Viewers',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${viewers.length}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        if (viewers.isEmpty)
          Center(
            child: Text(
              "No viewers",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        Flexible(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
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
                title: Text(
                  user.userName ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                subtitle: Text(
                    getFormattedTime(
                      viewedAt.millisecondsSinceEpoch,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,),
              );
            },
          ),
        ),
      ],
    );
  }
}
