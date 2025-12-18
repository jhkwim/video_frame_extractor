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
      final originalFile = File(videoPath);
      final String originalName = originalFile.uri.pathSegments.last;
      
      String nameWithoutExt = originalName.lastIndexOf('.') != -1 
          ? originalName.substring(0, originalName.lastIndexOf('.')) 
          : originalName;
          
      // Clean garbage from image_picker
      // Example: image_picker_UUID...IMG_1605
      // Strategy: Remove 'image_picker_' and leading Hex/Dash chars
      if (nameWithoutExt.startsWith('image_picker_')) {
        nameWithoutExt = nameWithoutExt.replaceFirst('image_picker_', '');
        // Remove UUID-like prefix (Hex + dashes)
        // We match until we hit something that looks like a real name start (like 'IMG', 'VID', or just non-hex)
        // However, 'A-F' are also valid in 'IMG' (no 'I' 'M' 'G' are not hex except 'A'-'F').
        // 'I', 'M', 'G', 'S', 'V' are definitely NOT hex.
        // So we remove leading [0-9A-F-]+
        final hexPattern = RegExp(r'^[0-9A-F-]+');
        nameWithoutExt = nameWithoutExt.replaceFirst(hexPattern, '');
      }

      if (nameWithoutExt.isEmpty) {
        nameWithoutExt = 'Video';
      }
      
      final String newName = '${nameWithoutExt}_${positionMs.toInt()}ms.png';
      final String newPath = '${File(fileName).parent.path}/$newName';
      
      final renamedFile = await File(fileName).rename(newPath);
      return renamedFile;
    }
    return null;
  }

  @override
  Future<bool?> saveImage(String path) async {
    return await GallerySaver.saveImage(path);
  }
}
