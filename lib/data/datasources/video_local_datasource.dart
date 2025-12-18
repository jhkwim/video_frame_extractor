import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:universal_io/io.dart' as uio;
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import 'package:cross_platform_video_thumbnails/cross_platform_video_thumbnails.dart';
import 'package:file_selector/file_selector.dart';

abstract class VideoLocalDataSource {
  Future<XFile?> pickVideoFromGallery();
  Future<XFile?> extractFrame(String videoPath, double positionMs, int quality);
  Future<bool?> saveImage(XFile imageFile);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final ImagePicker _picker;

  VideoLocalDataSourceImpl(this._picker);

  @override
  Future<XFile?> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    return video;
  }

  @override
  Future<XFile?> extractFrame(String videoPath, double positionMs, int quality) async {
    if (kIsWeb) {
      return await _extractFrameWeb(videoPath, positionMs, quality);
    } else if (uio.Platform.isAndroid || uio.Platform.isIOS) {
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
            
        if (nameWithoutExt.startsWith('image_picker_')) {
          nameWithoutExt = nameWithoutExt.replaceFirst('image_picker_', '');
          final hexPattern = RegExp(r'^[0-9A-F-]+');
          nameWithoutExt = nameWithoutExt.replaceFirst(hexPattern, '');
        }

        if (nameWithoutExt.isEmpty) {
          nameWithoutExt = 'Video';
        }
        
        final String newName = '${nameWithoutExt}_${positionMs.toInt()}ms.png';
        final String newPath = '${File(fileName).parent.path}/$newName';
        
        try {
          final renamedFile = await File(fileName).rename(newPath);
          return XFile(renamedFile.path);
        } catch (e) {
          // Fallback if rename fails
          return XFile(fileName);
        }
      }
    } else if (uio.Platform.isMacOS) {
       try {
         // Use cross_platform_video_thumbnails
         final bytes = await CrossPlatformVideoThumbnails().getThumbnail(
           videoPath, 
           timeMs: positionMs.toInt(), 
           quality: quality,
         );
         
         if (bytes != null) {
           final tempDir = await getTemporaryDirectory();
           final fileName = 'frame_${DateTime.now().millisecondsSinceEpoch}.png';
           final file = File('${tempDir.path}/$fileName');
           await file.writeAsBytes(bytes);
           return XFile(file.path);
         }
       } catch (e) {
         debugPrint('MacOS extraction error: $e');
       }
    }
    return null;
  }

  Future<XFile?> _extractFrameWeb(String videoUrl, double positionMs, int quality) async {
    final completer = Completer<XFile?>();
    final video = html.VideoElement();
    
    // crossOrigin must be anonymous for CORS loaded videos to be drawn on canvas
    video.crossOrigin = 'anonymous'; 
    video.src = videoUrl;
    
    // Logic: Wait for metadata -> seek -> wait for seeked -> draw -> blob
    
    video.onLoadedMetadata.listen((_) {
      video.currentTime = positionMs / 1000.0;
    });

    video.onSeeked.listen((_) async {
      try {
        final canvas = html.CanvasElement(
          width: video.videoWidth,
          height: video.videoHeight,
        );
        final ctx = canvas.context2D;
        ctx.drawImage(video, 0, 0);
        
        final blob = await canvas.toBlob('image/png');
        if (blob != null) {
          // Create object URL for XFile
          final url = html.Url.createObjectUrlFromBlob(blob);
          completer.complete(XFile(url, name: 'frame.png')); 
        } else {
          completer.complete(null);
        }
      } catch (e) {
        debugPrint('Web extraction error: $e');
        completer.complete(null);
      }
    });
    
    video.onError.listen((e) {
       completer.complete(null);
    });

    // If seek doesn't happen quickly, we might hang, but usually it works.
    // Ideally add timeout.

    return completer.future;
  }

  @override
  Future<bool?> saveImage(XFile imageFile) async {
    if (kIsWeb) {
      try {
        final anchor = html.AnchorElement(href: imageFile.path);
        anchor.download = 'extracted_frame_${DateTime.now().millisecondsSinceEpoch}.png';
        anchor.click();
        return true;
      } catch (e) {
        return false;
      }
    } else if (uio.Platform.isMacOS) {
      try {
        final FileSaveLocation? result = await getSaveLocation(
          suggestedName: 'extracted_frame.png',
          acceptedTypeGroups: [const XTypeGroup(label: 'Images', extensions: ['png', 'jpg'])],
        );

        if (result != null) {
          final Uint8List fileData = await imageFile.readAsBytes();
          final XFile textFile = XFile.fromData(fileData, mimeType: 'image/png');
          await textFile.saveTo(result.path);
          return true;
        }
        return false; // User cancelled
      } catch (e) {
        debugPrint('Mac save error: $e');
        return false;
      }
    } else {
      // Mobile
      return await GallerySaver.saveImage(imageFile.path);
    }
  }
}
