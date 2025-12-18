import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';

abstract class VideoLocalDataSource {
  Future<File?> pickVideoFromGallery();
  Future<File?> extractFrame(String videoPath, double positionMs, int quality);
  Future<bool?> saveImage(String path);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final ImagePicker _picker;

  VideoLocalDataSourceImpl(this._picker);

  @override
  Future<File?> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      return File(video.path);
    }
    return null;
  }

  @override
  Future<File?> extractFrame(String videoPath, double positionMs, int quality) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      timeMs: positionMs.toInt(),
      quality: quality,
    );
    
    if (fileName != null) {
      return File(fileName);
    }
    return null;
  }

  @override
  Future<bool?> saveImage(String path) async {
    return await GallerySaver.saveImage(path);
  }
}
