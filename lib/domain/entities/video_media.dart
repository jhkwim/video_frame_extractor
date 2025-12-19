import 'package:cross_file/cross_file.dart';

class VideoMedia {
  final XFile file;
  final Duration? duration;
  final String? name;

  const VideoMedia({
    required this.file,
    this.duration,
    this.name,
  });
}

enum ImageFormat {
  jpeg,
  png,
  webp;

  String get extension => this == ImageFormat.jpeg ? 'jpg' : name;
}
