import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../repositories/video_repository.dart';
import 'pick_video_usecase.dart'; // for UseCase interface

class ExtractFrameParams {
  final File videoFile;
  final double positionMs;
  final int quality;

  ExtractFrameParams({
    required this.videoFile,
    required this.positionMs,
    this.quality = 100,
  });
}

class ExtractFrameUseCase implements UseCase<File, ExtractFrameParams> {
  final VideoRepository repository;

  ExtractFrameUseCase(this.repository);

  @override
  Future<Either<Failure, File>> call(ExtractFrameParams params) {
    return repository.extractFrame(
      videoFile: params.videoFile,
      positionMs: params.positionMs,
      quality: params.quality,
    );
  }
}
