import 'package:chat_app/route_manager.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class ImageWidget extends StatefulWidget {
  final String imagePath;

  const ImageWidget({super.key, required this.imagePath});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.imageView,
          arguments: widget.imagePath,
        );
      },
      child: FancyShimmerImage(
        imageUrl: widget.imagePath,
      ),
    );
  }
}
