import 'package:chat_app/features/groups/data/model/group_message_data.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageSeenBottomSheet extends StatefulWidget {
  final GroupMessage groupMessages;

  const MessageSeenBottomSheet({super.key, required this.groupMessages});

  @override
  State<MessageSeenBottomSheet> createState() => _MessageSeenBottomSheetState();
}

class _MessageSeenBottomSheetState extends State<MessageSeenBottomSheet> {
  late Future<List<Map<String, dynamic>>> combinedSeenFuture;

  @override
  void initState() {
    super.initState();
    combinedSeenFuture = widget.groupMessages.combinedSeen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: combinedSeenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(child: LoadingIndicator());
        } else if (snapshot.hasError) {
          return const Expanded(child: ErrorIndicator());
        } else {
          final combinedSeen = snapshot.data ?? [];
          return DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
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
                          '${combinedSeen.length}',
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  if (combinedSeen.isEmpty)
                    Center(
                      child: Text(
                        "No viewers",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  Flexible(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: combinedSeen.length,
                      itemBuilder: (context, index) {
                        final user = combinedSeen[index]['user'] as User;
                        final viewAt =
                            combinedSeen[index]['viewAt'] as Timestamp;

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
                              viewAt.millisecondsSinceEpoch as int,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }
}
