import 'package:cross_file/cross_file.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../repositories/video_repository.dart';
import 'pick_video_usecase.dart';

class SaveImageUseCase implements UseCase<bool, XFile> {
  final VideoRepository repository;

  SaveImageUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(XFile imageFile) {
    return repository.saveImageToGallery(imageFile);
  }
}
