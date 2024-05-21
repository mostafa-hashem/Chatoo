// import 'package:audioplayers/audioplayers.dart';
// import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
// import 'package:chat_app/ui/resources/app_colors.dart';
// import 'package:chat_app/ui/widgets/loading_indicator.dart';
// import 'package:chat_app/utils/data/models/user.dart';
// import 'package:chat_app/utils/helper_methods.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// class AudioWidget extends StatefulWidget {
//   final String recordPath;
//   final String senderName;
//   final String senderId;
//   final bool isInGroup;
//   final int sentAt;
//
//   const AudioWidget({
//     super.key,
//     required this.recordPath,
//     required this.sentAt,
//     required this.senderName,
//     required this.senderId,
//     required this.isInGroup,
//   });
//
//   @override
//   State<AudioWidget> createState() => _AudioWidgetState();
// }
//
// class _AudioWidgetState extends State<AudioWidget> {
//   late AudioPlayer _audioPlayer;
//   bool _isPlaying = false;
//   bool _isLoading = false;
//   late int durationInSeconds;
//   late User sender;
//   Duration _currentPosition = Duration.zero;
//   late List<double> _waveformSamples;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _audioPlayer = AudioPlayer();
//     sender = ProfileCubit.get(context).user;
//     _waveformSamples = [];
//     _extractDurationFromPath();
//
//     _audioPlayer.onPlayerComplete.listen((event) {
//       setState(() {
//         _isPlaying = false;
//         _currentPosition = Duration.zero;
//       });
//     });
//
//     _audioPlayer.onDurationChanged.listen((duration) {
//       setState(() {
//         durationInSeconds = duration.inSeconds;
//       });
//     });
//
//     _audioPlayer.onPositionChanged.listen((position) {
//       setState(() {
//         _currentPosition = position;
//       });
//     });
//
//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       if (state == PlayerState.playing) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     });
//
//     // Load waveform data
//     _loadWaveformSamples();
//   }
//
//   void _extractDurationFromPath() {
//     final fileName = widget.recordPath.split('/').last;
//     final durationStr = fileName.split('%').last.substring(2).split('s').first;
//     durationInSeconds = int.tryParse(durationStr) ?? 0;
//   }
//
//   void _loadWaveformSamples() async {
//     // Replace this with the actual method to extract waveform samples
//     final samples = await extractWaveformSamples(widget.recordPath, 100);
//     setState(() {
//       _waveformSamples = samples;
//     });
//   }
//
//   Future<List<double>> extractWaveformSamples(
//       String path, int sampleCount) async {
//     // Your implementation to extract waveform samples
//     // For example, using a package or custom logic
//     return List<double>.filled(sampleCount, 0.0); // Dummy data
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final durationText =
//         '${durationInSeconds ~/ 60}:${(durationInSeconds % 60).toString().padLeft(2, '0')}';
//     final currentPositionText =
//         '${_currentPosition.inMinutes}:${(_currentPosition.inSeconds % 60).toString().padLeft(2, '0')}';
//
//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.sizeOf(context).width * 0.6,
//       ),
//       child: Column(
//         crossAxisAlignment: sender.id == widget.senderId
//             ? CrossAxisAlignment.end
//             : CrossAxisAlignment.start,
//         children: [
//           if (widget.isInGroup)
//             Text(
//               widget.senderName,
//               style: TextStyle(
//                 fontSize: 10.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.01,
//           ),
//           Container(
//             width: MediaQuery.of(context).size.width * 0.7,
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.mainColor,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () async {
//                         if (_isPlaying) {
//                           _audioPlayer.stop();
//                           setState(() {
//                             _isPlaying = false;
//                             _currentPosition = Duration.zero;
//                           });
//                         } else {
//                           setState(() {
//                             _isLoading = true;
//                           });
//                           await _audioPlayer.play(UrlSource(widget.recordPath));
//                           setState(() {
//                             _isPlaying = true;
//                           });
//                         }
//                       },
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           if (_isLoading) const LoadingIndicator(),
//                           Icon(
//                             _isPlaying ? Icons.stop : Icons.play_arrow,
//                             color: Colors.white,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: Slider(
//                         value: _currentPosition.inSeconds.toDouble(),
//                         max: durationInSeconds.toDouble(),
//                         onChanged: (value) {
//                           _audioPlayer.seek(Duration(seconds: value.toInt()));
//                         },
//                         activeColor: Colors.white,
//                         inactiveColor: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       _isPlaying ? currentPositionText : durationText,
//                       style: const TextStyle(fontSize: 12, color: Colors.white),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 // if (_waveformSamples.isNotEmpty)
//
//               ],
//             ),
//           ),
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.01,
//           ),
//           Text(
//             getFormattedTime(widget.sentAt),
//             style: TextStyle(
//               fontSize: 10.sp,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
