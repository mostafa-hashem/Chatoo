import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/route_manager.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

String? validateEmail(String? value) {
  final RegExp regex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  if (value == null || value.isEmpty) {
    return "Please Enter Email";
  } else {
    if (!regex.hasMatch(value)) {
      return 'Enter valid Email';
    } else {
      return null;
    }
  }
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter password';
  } else if (value.length < 6) {
    return "Password can't be less than 6 characters";
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value != password) {
    return "Password doesn't match";
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number only for search';
  }
  return null;
}

String? validateGeneral(String? value, String label) {
  if (value == null || value.isEmpty) {
    return 'Please enter $label';
  }
  return null;
}

String getFormattedTime(int timestamp) {
  final DateTime lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final DateTime now = DateTime.now();

  if (lastSeen.year == now.year &&
      lastSeen.month == now.month &&
      lastSeen.day == now.day) {
    return DateFormat('hh:mm a').format(lastSeen);
  }

  final DateTime yesterday = now.subtract(const Duration(days: 1));
  if (lastSeen.year == yesterday.year &&
      lastSeen.month == yesterday.month &&
      lastSeen.day == yesterday.day) {
    return 'Yesterday';
  }

  if (lastSeen.year == now.year) {
    return DateFormat('MMM d').format(lastSeen);
  }

  return DateFormat('MMM d, yyyy').format(lastSeen);
}

String getFormattedDateHeader(int timestamp) {
  final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final DateTime now = DateTime.now();

  if (now.year == date.year && now.month == date.month && now.day == date.day) {
    return 'Today';
  } else if (now.year == date.year &&
      now.month == date.month &&
      now.day == date.day + 1) {
    return 'Yesterday';
  } else {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

void showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.mediaView,
            arguments: {'path': imageUrl, 'isVideo': false},
          );
        },
        child: Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FancyShimmerImage(
                imageUrl: imageUrl,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _requestPermissions() async {
  final statuses = await [
    Permission.audio,
    Permission.videos,
    Permission.photos,
    Permission.microphone,
  ].request();

  final isAllGranted =
      statuses.values.every((status) => status == PermissionStatus.granted);
  if (!isAllGranted) {
    debugPrint('Permissions not granted');
  }
}

Future<String> getImageFileName(File imageFile) async {
  await _requestPermissions();

  final image = img.decodeImage(imageFile.readAsBytesSync());
  if (image == null) {
    throw Exception('Unable to decode image');
  }

  final int width = image.width;
  final int height = image.height;
  final String fileName = '${width}x$height.${imageFile.path.split('.').last}';
  return fileName;
}

Future<String> getVideoFileName(File videoFile) async {
  await _requestPermissions();
  final VideoPlayerController videoController =
      VideoPlayerController.file(videoFile);
  await videoController.initialize();
  final int duration = videoController.value.duration.inSeconds;
  final double width = videoController.value.size.width;
  final double height = videoController.value.size.height;

  await videoController.dispose();

  final String fileName =
      '${width}x$height^${duration}s.${videoFile.path.split('.').last}';
  return fileName;
}

Future<String> getAudioFileName(File audioFile) async {
  await _requestPermissions();
  final AudioPlayer audioPlayer = AudioPlayer();
  await audioPlayer.setSourceUrl(
    audioFile.path,
  );
  final Duration? duration = await audioPlayer.getDuration();

  await audioPlayer.dispose();

  final int? durationInSeconds = duration?.inSeconds;
  final String fileExtension = audioFile.path.split('.').last;
  final String fileName = '${durationInSeconds}s.$fileExtension';
  return fileName;
}
