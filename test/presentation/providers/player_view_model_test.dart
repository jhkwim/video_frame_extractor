
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:cross_file/cross_file.dart';
import 'package:video_frame_extractor/presentation/providers/player_view_model.dart';
import 'package:video_frame_extractor/domain/usecases/extract_frame_usecase.dart';
import 'package:video_frame_extractor/domain/entities/video_media.dart';
import 'package:video_frame_extractor/presentation/providers/dependency_injection.dart';

class MockExtractFrameUseCase extends Mock implements ExtractFrameUseCase {}

void main() {
  late MockExtractFrameUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockExtractFrameUseCase();
    registerFallbackValue(ExtractFrameParams(
      videoFile: XFile(''),
      positionMs: 0,
    ));
  });

  test('should update state when extracting frame succeeds', () async {
    // Arrange
    final container = ProviderContainer(
      overrides: [
        extractFrameUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
    addTearDown(container.dispose);

    final videoFile = XFile('video.mp4', name: 'video.mp4');
    final extractedFile = XFile('frame.jpg');

    when(() => mockUseCase.call(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 10)); // Simulate work
      return Right(extractedFile);
    });

    // Act
    final notifier = container.read(playerNotifierProvider.notifier);
    final future = notifier.extractFrame(videoFile, 1500);
    
    // Assert Initial Loading State check might be tricky with async, 
    // but we can check final state.
    
    await future;
    
    final state = container.read(playerNotifierProvider);
    expect(state.isExtracting, false);
    expect(state.extractedImage, extractedFile);
    expect(state.error, null);
  });

  test('should update state with error when extraction fails', () async {
      // TODO: Implement error case
  });
}
