import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/data/models/audio_manager.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class RecordTile extends StatefulWidget {
  final String recordPath;
  final String senderName;
  final String senderId;
  final bool isInGroup;
  final int sentAt;
  final AudioManager audioManager;

  const RecordTile({
    super.key,
    required this.recordPath,
    required this.sentAt,
    required this.senderName,
    required this.senderId,
    required this.isInGroup,
    required this.audioManager,
  });

  @override
  State<RecordTile> createState() => _RecordTileState();
}

class _RecordTileState extends State<RecordTile> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  late int durationInSeconds;
  late User sender;
  Duration _currentPosition = Duration.zero;
  late String localFilePath;

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

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          _isLoading = false;
        });
      }
    });

    super.didChangeDependencies();
  }

  void _extractDurationFromPath() {
    final fileName = widget.recordPath.split('/').last;
    final durationStr = fileName.split('%').last.substring(2).split('s').first;
    durationInSeconds = int.tryParse(durationStr) ?? 0;
  }

  Future<void> _loadFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      localFilePath = '${directory.path}/${widget.recordPath.split('/').last}';
      final localFile = File(localFilePath);

      if (!await localFile.exists()) {
        final response = await http.get(Uri.parse(widget.recordPath));
        await localFile.writeAsBytes(response.bodyBytes);
      }
    } catch (e) {
      print('Error loading file: $e');
    }

    setState(() {
      _isLoading = false;
    });
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
                  onTap: () async {
                    if (_isPlaying) {
                      widget.audioManager.stop(_audioPlayer);
                      setState(() {
                        _isPlaying = false;
                        _currentPosition = Duration.zero;
                      });
                    } else {
                      await _loadFile();
                      await widget.audioManager.play(_audioPlayer, localFilePath);
                      setState(() {
                        _isPlaying = true;
                      });
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isLoading) const LoadingIndicator(),
                      Icon(
                        _isPlaying ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ],
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
          Text(
            getFormattedTime(widget.sentAt),
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
