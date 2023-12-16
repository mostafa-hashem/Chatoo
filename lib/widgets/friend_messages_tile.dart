import 'package:chat_app/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';


class FriendMessagesTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  final int timeOfMessage;
  final String friendId;
  final String messageId;
  final String userId;

  const FriendMessagesTile(
      {super.key, required this.message,
      required this.sender,
      required this.sentByMe,
      required this.timeOfMessage,
      required this.friendId,
      required this.messageId,
      required this.userId,
      });

  @override
  State<FriendMessagesTile> createState() => _FriendMessagesTileState();
}

class _FriendMessagesTileState extends State<FriendMessagesTile> {
  String getFormattedTime() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(widget.timeOfMessage);
    final formatter = DateFormat.jm();

    return formatter.format(dateTime);
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {
        widget.sentByMe
            ? showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Message'),
              content: const Text(
                  'Are you sure you want to delete this message?',),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Delete for everyone'),
                  onPressed: () {

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        )
            : showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Message'),
              content: const Text(
                  "Sorry you cannot delete other people's messages till now",),
              actions: [
                TextButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: widget.sentByMe ? 0 : 24,
          right: widget.sentByMe ? 24 : 0,
        ),
        alignment:
        widget.sentByMe == false ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: widget.sentByMe
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding: widget.sentByMe
              ? const EdgeInsets.only(top: 17, bottom: 17, left: 30, right: 18)
              : const EdgeInsets.only(top: 17, bottom: 17, left: 18, right: 30),
          decoration: BoxDecoration(
            borderRadius: widget.sentByMe == false
                ? const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            )
                : const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: widget.sentByMe == false
                ? const Color(0xffecae7d)
                : const Color(0xff8db4ad),
          ),
          child: Column(
            crossAxisAlignment: widget.sentByMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                widget.sender.toUpperCase(),
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text(
                widget.message,
                style: TextStyle(fontSize: 15.sp, color: Colors.white),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              Text(
                getFormattedTime(),
                style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
