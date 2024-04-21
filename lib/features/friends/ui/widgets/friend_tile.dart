import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/friends/cubit/friend_states.dart';
import 'package:chat_app/features/friends/data/model/friend_data.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendTile extends StatefulWidget {
  const FriendTile({
    super.key,
    required this.friendData,
    required this.lastMessageData,
  });

  final User friendData;
  final Friend lastMessageData;

  @override
  State<FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendCubit, FriendStates>(
      builder: (context, state) {
        if (state is GetRecentMessageDataLoading) {
          return const LoadingIndicator();
        } else if (state is GetRecentMessageDataError) {
          return const ErrorIndicator();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: ListTile(
            leading: widget.friendData.profileImage!.isEmpty
                ? CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.friendData.userName!.substring(0, 1).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () =>
                        showImageDialog(context, widget.friendData.profileImage!),
                    child: ClipOval(
                      child: FancyShimmerImage(
                        imageUrl: widget.friendData.profileImage!,
                        width: 50.w,
                      ),
                    ),
                  ),
            title: Text(
              widget.friendData.userName ?? 'Unknown',
              style: GoogleFonts.novaSquare(fontWeight: FontWeight.bold),
            ),
            subtitle: widget.lastMessageData.recentMessage != null ? Text(
              widget.lastMessageData.recentMessage!,
              style:
                  GoogleFonts.novaSquare(fontWeight: FontWeight.w700, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ) : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
