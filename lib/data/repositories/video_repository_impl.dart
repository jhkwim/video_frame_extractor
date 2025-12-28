import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/video_media.dart';
import '../../domain/entities/video_metadata.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_local_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoLocalDataSource dataSource;

  VideoRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, VideoMetadata>> getMetadata(XFile videoFile) async {
    try {
      final metadata = await dataSource.getMetadata(videoFile);
      return Right(metadata);
    } catch (e) {
      return Left(ProcessFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, VideoMedia>> pickVideo() async {
    try {
      final file = await dataSource.pickVideoFromGallery();
      if (file != null) {
        return Right(VideoMedia(file: file, name: file.name));
      } else {
        return const Left(UserCanceledFailure());
      }
    } catch (e) {
      return Left(ProcessFailure(e.toString()));
    }
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
    try {
      final file = await dataSource.extractFrame(
        videoFile.path,
        positionMs,
        quality,
        format,
        originalName,
        metadata,
      );
      if (file != null) {
        return Right(file);
      } else {
        return const Left(ProcessFailure('프레임 추출 실패'));
      }
    } catch (e) {
      return Left(ProcessFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> saveImageToGallery(XFile imageFile) async {
    try {
      final success = await dataSource.saveImage(imageFile);
      if (success == true) {
        return const Right(true);
      } else {
        return const Left(ProcessFailure('저장 실패'));
      }
    } catch (e) {
      return Left(ProcessFailure(e.toString()));
    }
  }
}
