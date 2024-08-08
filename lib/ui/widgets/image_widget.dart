import 'package:chat_app/features/friends/data/model/friend_message_data.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageWidget extends StatefulWidget {
  final String imagePath;
  final String? senderName;
  final String senderId;
  final bool isInGroup;
  final int? sentAt;
  final bool? isLink;
  final FriendMessage? friendMessage;

  const ImageWidget({
    super.key,
    required this.imagePath,
     this.friendMessage,
     this.isLink,
     this.sentAt,
     this.senderName,
    required this.senderId,
    required this.isInGroup,
  });

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  late User sender;
  TextAlign _textAlign = TextAlign.left;
  TextDirection _textDirection = TextDirection.ltr;

  @override
  void didChangeDependencies() {
    sender = ProfileCubit.get(context).user;
    super.didChangeDependencies();
  }
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
  Widget build(BuildContext context) {
    final fileName = widget.imagePath.split('/').last;
    final dimensions = fileName.split('.').first.split('x');
    final width =
        double.tryParse(dimensions[0].split('%').last.substring(2)) ?? 100.0.w;
    final height = double.tryParse(dimensions[1]) ?? 100.0.h;

    final maxWidth = MediaQuery.of(context).size.width * 0.6;
    final maxHeight = MediaQuery.of(context).size.height * 0.4;

    final adjustedWidth = width > maxWidth ? maxWidth : width;
    final adjustedHeight = height > maxHeight ? maxHeight : height;
    final messageText = widget.friendMessage?.message;
    _checkTextDirection(messageText ?? "");

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.mediaView,
          arguments: {
            'path': widget.imagePath,
            'isVideo': false,
            'isStory': false,
            'mediaTitle': widget.friendMessage?.message ?? '',
            'mediaOwner': widget.senderName,
            'mediaTime': widget.sentAt,
            'profilePicture': false,
          },
        );
      },
      child: Column(
        crossAxisAlignment: sender.id == widget.senderId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (widget.isInGroup)
            if (widget.senderName != null)
              Text(
                widget.senderName!,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          if (widget.isInGroup)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
          FancyShimmerImage(
            height: adjustedHeight,
            width: adjustedWidth,
            imageUrl: widget.imagePath,
            boxFit: BoxFit.cover,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          if (widget.friendMessage != null) GestureDetector(
            onTap: widget.isLink ?? false
                ? () async {
              if (await canLaunchUrl(
                Uri.parse(widget.friendMessage?.message ?? ""),
              )) {
                await launchUrl(
                  Uri.parse(widget.friendMessage?.message ?? ""),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                throw 'Could not launch ${widget.friendMessage?.message ?? ""}';
              }
            }
                : null,
            child: Text(
              widget.friendMessage?.message ?? "",
              textDirection: _textDirection,
              textAlign: _textAlign,
              style: TextStyle(
                fontSize: 15.sp,
                color: widget.isLink ?? false ? Colors.blue : Colors.white,
              ),
            ),
          ) ,
          if (widget.sentAt != null)
          Text(
            getFormattedTime(
              widget.sentAt!,
            ),
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
