import 'package:chat_app/features/groups/data/model/group_data.dart';
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
    required this.groupData,
    required this.isLeftOrJoined,
  });

  final String userName;
  final Group groupData;
  final bool isLeftOrJoined;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: ListTile(
        leading: widget.groupData.groupIcon!.isEmpty
            ? CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.groupData.groupName!.substring(0, 1).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              )
            : InkWell(
                onTap: () =>
                    showImageDialog(context, widget.groupData.groupIcon!),
                child: ClipOval(
                  child: FancyShimmerImage(
                    imageUrl: widget.groupData.groupIcon!,
                    width: 50.w,
                  ),
                ),
              ),
        title: Text(
          widget.groupData.groupName!,
          style: GoogleFonts.novaSquare(fontWeight: FontWeight.bold),
        ),
        subtitle: widget.isLeftOrJoined
            ? const SizedBox.shrink()
            : Text(
                "Test for last message",
                style: GoogleFonts.ubuntu(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}
