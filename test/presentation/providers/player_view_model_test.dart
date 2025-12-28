import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:cross_file/cross_file.dart';
import 'package:video_frame_extractor/presentation/providers/player_view_model.dart';
import 'package:video_frame_extractor/domain/usecases/extract_frame_usecase.dart';

import 'package:video_frame_extractor/presentation/providers/dependency_injection.dart';

class MockExtractFrameUseCase extends Mock implements ExtractFrameUseCase {}

void main() {
  late MockExtractFrameUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockExtractFrameUseCase();
    registerFallbackValue(
      ExtractFrameParams(videoFile: XFile(''), positionMs: 0),
    );
  });

  test('프레임 추출 성공 시 상태가 업데이트되어야 한다', () async {
    // Arrange
    final container = ProviderContainer(
      overrides: [extractFrameUseCaseProvider.overrideWithValue(mockUseCase)],
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

  test('추출 실패 시 에러 상태로 업데이트되어야 한다', () async {
    // TODO: Implement error case
  });
}
