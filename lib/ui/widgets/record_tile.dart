import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecordTile extends StatefulWidget {
  final String recordPath;
  final String senderName;
  final String senderId;
  final bool isInGroup;
  final int sentAt;

  const RecordTile({
    super.key,
    required this.recordPath,
    required this.sentAt,
    required this.senderName,
    required this.senderId,
    required this.isInGroup,
  });

  @override
  State<RecordTile> createState() => _RecordTileState();
}

class _RecordTileState extends State<RecordTile> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  late int durationInSeconds;
  late User sender;
  Duration _currentPosition = Duration.zero;

  @override
  void didChangeDependencies() {
    _audioPlayer = AudioPlayer();
    sender = ProfileCubit.get(context).user;
    _extractDurationFromPath();

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        durationInSeconds = duration.inSeconds;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    super.didChangeDependencies();
  }

  void _extractDurationFromPath() {
    final fileName = widget.recordPath.split('/').last;
    final durationStr = fileName.split('%').last.substring(2).split('s').first;
    durationInSeconds = int.tryParse(durationStr) ?? 0;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final durationText =
        '${durationInSeconds ~/ 60}:${(durationInSeconds % 60).toString().padLeft(2, '0')}';
    final currentPositionText =
        '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}';

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.6,
      ),
      child: Column(
        crossAxisAlignment: sender.id == widget.senderId
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (widget.isInGroup)
            Text(
              widget.senderName,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_isPlaying) {
                      _audioPlayer.stop();
                      setState(() {
                        _isPlaying = false;
                        _currentPosition = Duration.zero;
                      });
                    } else {
                      _audioPlayer.play(UrlSource(widget.recordPath));
                      setState(() {
                        _isPlaying = true;
                      });
                    }
                  },
                  child: Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _currentPosition.inSeconds.toDouble(),
                    max: durationInSeconds.toDouble(),
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _isPlaying ? currentPositionText : durationText,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Align(
            alignment: sender.id == widget.senderId
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Text(
              getFormattedTime(widget.sentAt),
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
