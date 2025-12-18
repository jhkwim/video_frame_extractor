import 'package:flutter/material.dart';
import '../../domain/entities/video_media.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoMedia videoMedia;
  const VideoPlayerScreen({super.key, required this.videoMedia});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Player')),
      body: Center(child: Text('Playing: ${videoMedia.file.path}')),
    );
  }
}
