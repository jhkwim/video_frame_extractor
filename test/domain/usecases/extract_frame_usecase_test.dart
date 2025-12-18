
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:cross_file/cross_file.dart';
import 'package:video_frame_extractor/domain/entities/video_media.dart';
import 'package:video_frame_extractor/domain/repositories/video_repository.dart';
import 'package:video_frame_extractor/domain/usecases/extract_frame_usecase.dart';

class MockVideoRepository extends Mock implements VideoRepository {}

void main() {
  late ExtractFrameUseCase useCase;
  late MockVideoRepository mockRepository;

  setUp(() {
    mockRepository = MockVideoRepository();
    useCase = ExtractFrameUseCase(mockRepository);
    // Register fallback values if needed, but XFile is simple
  });

  test('매개변수가 리포지토리로 올바르게 전달되어야 한다', () async {
    // Arrange
    final videoFile = XFile('test_video.mp4');
    final extractedFile = XFile('test_frame.jpg');
    
    when(() => mockRepository.extractFrame(
          videoFile: videoFile,
          positionMs: 1000,
          quality: 80,
          format: ImageFormat.jpeg,
          originalName: 'video',
        )).thenAnswer((_) async => Right(extractedFile));

    // Act
    final result = await useCase(ExtractFrameParams(
      videoFile: videoFile,
      positionMs: 1000,
      quality: 80,
      format: ImageFormat.jpeg,
      originalName: 'video',
    ));

    // Assert
    expect(result, Right(extractedFile));
    verify(() => mockRepository.extractFrame(
          videoFile: videoFile,
          positionMs: 1000,
          quality: 80,
          format: ImageFormat.jpeg,
          originalName: 'video',
        )).called(1);
  });
}
