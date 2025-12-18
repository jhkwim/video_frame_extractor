import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../repositories/video_repository.dart';
import 'pick_video_usecase.dart'; // for UseCase interface

import '../entities/video_media.dart';
import '../entities/video_metadata.dart';

class ExtractFrameParams {
  final XFile videoFile;
  final double positionMs;
  final int quality;
  final ImageFormat format;
  final String originalName;
  final VideoMetadata? metadata;

  ExtractFrameParams({
    required this.videoFile,
    required this.positionMs,
    this.quality = 100,
    this.format = ImageFormat.jpeg,
    this.originalName = 'video',
    this.metadata,
  });
}

class ExtractFrameUseCase implements UseCase<XFile, ExtractFrameParams> {
  final VideoRepository repository;

  ExtractFrameUseCase(this.repository);

  @override
  Future<Either<Failure, XFile>> call(ExtractFrameParams params) {
    return repository.extractFrame(
      videoFile: params.videoFile,
      positionMs: params.positionMs,
      quality: params.quality,
      format: params.format,
      originalName: params.originalName,
      metadata: params.metadata,
    );
  }
}
