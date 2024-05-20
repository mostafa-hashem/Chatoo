import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/route_manager.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
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
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final hours = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minutes = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$hours:$minutes $period';
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
            arguments: imageUrl,
          );
        },
        child: Dialog(
          child: SizedBox(
            child: FancyShimmerImage(
              imageUrl: imageUrl,
              boxFit: BoxFit.contain,
            ),
          ),
        ),
      );
    },
  );
}

Future<String> getImageFileName(File imageFile) async {
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
  final AudioPlayer audioPlayer = AudioPlayer();
  await audioPlayer.setSourceUrl(
    audioFile.path,
  );
  final Duration? duration = await audioPlayer.getDuration();

  await audioPlayer.dispose();

  final int? durationInSeconds = duration?.inSeconds;
  final String fileName =
      '${durationInSeconds}s.${audioFile.path.split('.').last}';
  return fileName;
}
