import 'dart:io';

class VideoMedia {
  final File file;
  final Duration? duration;
  final String? name;

  const VideoMedia({
    required this.file,
    this.duration,
    this.name,
  });
}
