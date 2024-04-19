import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupTile extends StatefulWidget {
  const GroupTile({
    super.key,
    required this.userName,
    required this.groupId,
    required this.groupName,
    required this.groupIcon,
  });

  final String userName;
  final String groupId;
  final String groupName;
  final String groupIcon;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: ListTile(
        leading: widget.groupIcon.isEmpty
            ? CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.groupName.substring(0, 1).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              )
            : InkWell(
                onTap: () => showImageDialog(context, widget.groupIcon),
                child: ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: widget.groupIcon,
                    width: 50.w,
                  ),
                ),
              ),
        title: Text(
          widget.groupName,
          style: GoogleFonts.novaSquare(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              GroupCubit.get(context).filteredMessages.isNotEmpty
                  ? '${GroupCubit.get(context).filteredMessages.last.sender.userName}: ${GroupCubit.get(context).filteredMessages.last.message}'
                  : '',
              style: GoogleFonts.ubuntu(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
