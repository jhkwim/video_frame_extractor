import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../repositories/video_repository.dart';
import 'pick_video_usecase.dart';

class SaveImageUseCase implements UseCase<bool, File> {
  final VideoRepository repository;

  SaveImageUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(File imageFile) {
    return repository.saveImageToGallery(imageFile);
  }
}
