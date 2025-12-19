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
    final dummyImage = File('${testVideoFile.parent.path}/extracted_frame.png');
    
    // Valid 1x1 Red PNG Base64
    const String validPngBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==";
    
    await dummyImage.writeAsBytes(base64Decode(validPngBase64));
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
