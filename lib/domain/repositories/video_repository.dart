import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../entities/video_media.dart';

abstract class VideoRepository {
  Future<Either<Failure, VideoMedia>> pickVideo();
  Future<Either<Failure, File>> extractFrame({
    required File videoFile,
    required double positionMs,
    required int quality,
  });
  Future<Either<Failure, bool>> saveImageToGallery(File imageFile);
}
