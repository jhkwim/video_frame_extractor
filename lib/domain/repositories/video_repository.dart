import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../entities/video_media.dart';

abstract class VideoRepository {
  Future<Either<Failure, VideoMedia>> pickVideo();
  Future<Either<Failure, XFile>> extractFrame({
    required XFile videoFile,
    required double positionMs,
    required int quality,
  });
  Future<Either<Failure, bool>> saveImageToGallery(XFile imageFile);
}
