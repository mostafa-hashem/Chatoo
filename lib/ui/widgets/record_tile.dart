import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:flutter/material.dart';

class RecordTile extends StatefulWidget {
  final String duration;
  final String recordPath;

  const RecordTile({
    super.key,
    required this.duration,
    required this.recordPath,
  });

  @override
  State<RecordTile> createState() => _RecordTileState();
}

class _RecordTileState extends State<RecordTile> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_isPlaying) {
                _audioPlayer.stop();
              } else {
                _audioPlayer.play(AssetSource(widget.recordPath));
              }
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
            child: Icon(
              _isPlaying ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.zero,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Text(audioController.completedPercentage.value.toString(),style: TextStyle(color: Colors.white),),
                  LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: Colors.grey,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    // value: (audioController.isRecordPlaying &&
                    //     audioController.currentId == index)
                    //     ? audioController.completedPercentage.value
                    //     : audioController.totalDuration.value.toDouble(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            widget.duration,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
