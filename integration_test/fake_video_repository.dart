import 'package:video_frame_extractor/domain/repositories/video_repository.dart';
import 'package:video_frame_extractor/domain/entities/video_media.dart';
import 'package:video_frame_extractor/domain/entities/video_metadata.dart';
import 'package:video_frame_extractor/core/errors/failure.dart';
import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:io';
import 'dart:convert';

class FakeVideoRepository implements VideoRepository {
  final File testVideoFile;
  
  FakeVideoRepository({required this.testVideoFile});

  @override
  Future<Either<Failure, VideoMedia>> pickVideo() async {
    // Return the test file immediately
    return Right(VideoMedia(
      file: XFile(testVideoFile.path),
      name: 'Test Video',
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Future<Either<Failure, XFile>> extractFrame({
    required XFile videoFile,
    required double positionMs,
    required int quality,
    required ImageFormat format,
    required String originalName,
    VideoMetadata? metadata,
  }) async {
    // Fake extraction logic
    final dummyImage = File('${testVideoFile.parent.path}/extracted_frame.jpg');
    
    // Valid 1x1 JPEG Base64
    // Valid 1x1 White JPEG Base64
    const String validJpegBase64 = "/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAMCAgMCAgMDAwMEAwMEBQgFBQQEBQoHBwYIDAoMDAsKCwsNDhIQDQ4RDgsLEBYQERMUFRUVDA8XGBYUGBIUFRT/2wBDAQMEBAUEBQkFBQkUDQsNFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBT/wAARCAABAAEEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9sAQwACAgICAgIDAgIDBQMEBQUHBQUFBQcIBwcHBwcICQoKCgoKCgkMDAwMDAwMDQ0NDQ0NDxEREQ8UFBUUFCAcICAj/9sAQwECAgIDAwMFAwMFFAcGBxQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU/90ABAB//9k=";
    
    await dummyImage.writeAsBytes(base64Decode(validJpegBase64));
    return Right(XFile(dummyImage.path));
  }

  @override
  Future<Either<Failure, VideoMetadata>> getMetadata(XFile videoFile) async {
    return Right(VideoMetadata(
      creationDate: DateTime.now(),
      make: 'TestMake',
      model: 'TestModel',
    ));
  }

  @override
  Future<Either<Failure, bool>> saveImageToGallery(XFile imageFile) async {
    // Fake save
    return const Right(true);
  }
}
