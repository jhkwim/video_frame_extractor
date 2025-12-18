import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../entities/video_media.dart';
import '../repositories/video_repository.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}

class PickVideoUseCase implements UseCase<VideoMedia, NoParams> {
  final VideoRepository repository;

  PickVideoUseCase(this.repository);

  @override
  Future<Either<Failure, VideoMedia>> call(NoParams params) {
    return repository.pickVideo();
  }
}
