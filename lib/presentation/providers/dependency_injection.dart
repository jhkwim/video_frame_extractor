import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/video_local_datasource.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/usecases/extract_frame_usecase.dart';
import '../../domain/usecases/pick_video_usecase.dart';
import '../../domain/usecases/save_image_usecase.dart';

// Data Sources
final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

final videoLocalDataSourceProvider = Provider<VideoLocalDataSource>((ref) {
  return VideoLocalDataSourceImpl(ref.watch(imagePickerProvider));
});

// Repositories
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepositoryImpl(ref.watch(videoLocalDataSourceProvider));
});

// UseCases
final pickVideoUseCaseProvider = Provider<PickVideoUseCase>((ref) {
  return PickVideoUseCase(ref.watch(videoRepositoryProvider));
});

final extractFrameUseCaseProvider = Provider<ExtractFrameUseCase>((ref) {
  return ExtractFrameUseCase(ref.watch(videoRepositoryProvider));
});

final saveImageUseCaseProvider = Provider<SaveImageUseCase>((ref) {
  return SaveImageUseCase(ref.watch(videoRepositoryProvider));
});
