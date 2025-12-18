import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;
import 'package:gal/gal.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart' as uio;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:file_selector/file_selector.dart';
import '../../domain/entities/video_media.dart';
import '../../domain/entities/video_metadata.dart';
import '../../core/utils/filename_helper.dart';

abstract class VideoLocalDataSource {
  Future<XFile?> pickVideoFromGallery();
  Future<XFile?> extractFrame(String videoPath, double positionMs, int quality, ImageFormat format, String originalName, VideoMetadata? metadata);
  Future<VideoMetadata> getMetadata(XFile videoFile);
  Future<bool?> saveImage(XFile imageFile);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final ImagePicker _picker;
  static const MethodChannel _channel = MethodChannel('com.example.videoFrameExtractor/macos');

  VideoLocalDataSourceImpl(this._picker);

  @override
  Future<XFile?> pickVideoFromGallery() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    return video;
  }

  @override
  Future<VideoMetadata> getMetadata(XFile videoFile) async {
    try {
      if (kIsWeb) {
        // Web: Limited metadata access
        final lastModified = await videoFile.lastModified();
        return VideoMetadata(
          creationDate: lastModified,
          make: 'Web',
          model: 'Browser',
        );
      } else {
        // Native: Use flutter_media_metadata
        // Note: The package focuses on ID3 tags. Creation Date might not be accurate.
        // We use file lastModified as a reliable fallback.
        final lastModified = await videoFile.lastModified();
        
        // We can still try to get other info if needed, but for now stick to file date
        // final metadata = await MetadataRetriever.fromFile(File(videoFile.path));

        return VideoMetadata(
          creationDate: lastModified,
          make: null, 
          model: null,
        );
      }
    } catch (e) {
      debugPrint('Metadata reading error: $e');
      return const VideoMetadata();
    }
  }



  @override
  Future<XFile?> extractFrame(String videoPath, double positionMs, int quality, ImageFormat format, String originalName, VideoMetadata? metadata) async {
    final String fileName = FilenameHelper.generateFilename(
      originalName: originalName,
      positionMs: positionMs,
      extension: format.extension,
    );

    XFile? extractedFile;
    if (kIsWeb) {
      extractedFile = await _extractFrameWeb(videoPath, positionMs, quality, format, fileName);
    } else if (uio.Platform.isAndroid || uio.Platform.isIOS) {
       // ... existing mobile logic ...
       extractedFile = await _extractFrameMobile(videoPath, positionMs, quality, format, fileName);
    } else if (uio.Platform.isMacOS) {
       // ... existing macOS logic ...
       extractedFile = await _extractFrameMacOS(videoPath, positionMs, quality, format, fileName);
    }
    
    // Inject Metadata (Native Only)
    if (extractedFile != null && metadata != null && !kIsWeb) {
      try {
        final exif = await Exif.fromPath(extractedFile.path);
        await exif.writeAttributes({
          if (metadata.creationDate != null) 'DateTimeOriginal': metadata.creationDate!.toIso8601String(),
          if (metadata.make != null) 'Make': metadata.make!,
          if (metadata.model != null) 'Model': metadata.model!,
          // GPS is harder with native_exif basic writeAttributes (needs specific format), skipping complex GPS for now as per plan "Basic"
        });
        await exif.close();
      } catch (e) {
        debugPrint('Error writing metadata: $e');
      }
    }

    return extractedFile;
  }
  
  // Helper methods to keep code clean (Need to refactor existing logic into these helpers)
  Future<XFile?> _extractFrameMobile(String videoPath, double positionMs, int quality, ImageFormat format, String fileName) async {
      vt.ImageFormat vtFormat;
      switch (format) {
        case ImageFormat.jpeg:
          vtFormat = vt.ImageFormat.JPEG;
          break;
        case ImageFormat.png:
          vtFormat = vt.ImageFormat.PNG;
          break;
        case ImageFormat.webp:
          vtFormat = vt.ImageFormat.WEBP;
          break;
      }

      final thumbPath = await vt.VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: vtFormat,
        timeMs: positionMs.toInt(),
        quality: quality,
      );
      
      if (thumbPath != null) {
        final newPath = '${File(thumbPath).parent.path}/$fileName';
        try {
          final renamedFile = await File(thumbPath).rename(newPath);
          return XFile(renamedFile.path, name: fileName);
        } catch (e) {
          return XFile(thumbPath, name: fileName);
        }
      }
      return null;
  }

  Future<XFile?> _extractFrameMacOS(String videoPath, double positionMs, int quality, ImageFormat format, String fileName) async {
       try {
         final Uint8List? byteData = await _channel.invokeMethod('extractFrame', {
           'path': videoPath,
           'position': positionMs,
           'quality': quality,
           'format': format.extension, 
         });
         
         if (byteData != null) {
           final tempDir = await getTemporaryDirectory();
           final file = File('${tempDir.path}/$fileName');
           await file.writeAsBytes(byteData);
           return XFile(file.path, name: fileName);
         }
       } catch (e) {
         debugPrint('MacOS extraction error: $e');
       }
       return null;
  }

  Future<XFile?> _extractFrameWeb(String videoUrl, double positionMs, int quality, ImageFormat format, String fileName) async {
    final completer = Completer<XFile?>();
    final video = html.VideoElement();
    
    video.crossOrigin = 'anonymous'; 
    video.src = videoUrl;
    
    video.onLoadedMetadata.listen((_) {
      video.currentTime = positionMs / 1000.0;
    });

    video.onSeeked.listen((_) async {
      try {
        final canvas = html.CanvasElement(
          width: (video as dynamic).videoWidth,
          height: (video as dynamic).videoHeight,
        );
        final ctx = canvas.context2D;
        ctx.drawImage(video, 0, 0);
        
        final String mimeType = 'image/${format.extension == 'jpg' ? 'jpeg' : format.extension}';
        final blob = await canvas.toBlob(mimeType, quality / 100.0);
        
        final url = html.Url.createObjectUrlFromBlob(blob);
        completer.complete(XFile(url, name: fileName, mimeType: mimeType)); 
        
      } catch (e) {
        debugPrint('Web extraction error: $e');
        completer.complete(null);
      }
    });
    
    video.onError.listen((e) {
       completer.complete(null);
    });

    return completer.future;
  }

  @override
  Future<bool?> saveImage(XFile imageFile) async {
    if (kIsWeb) {
      try {
        final anchor = html.AnchorElement(href: imageFile.path);
        anchor.download = imageFile.name.isNotEmpty ? imageFile.name : 'extracted_frame_${DateTime.now().millisecondsSinceEpoch}.png';
        anchor.click();
        return true;
      } catch (e) {
        return false;
      }
    } else if (uio.Platform.isMacOS) {
      try {
        final FileSaveLocation? result = await getSaveLocation(
          suggestedName: imageFile.name.isNotEmpty ? imageFile.name : 'extracted_frame.png',
          acceptedTypeGroups: [const XTypeGroup(label: 'Images', extensions: ['png', 'jpg', 'jpeg', 'webp'])],
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
      try {
        await Gal.putImage(imageFile.path);
        return true;
      } catch (e) {
        debugPrint('Mobile save error: $e');
        return false;
      }
    }
  }
}
