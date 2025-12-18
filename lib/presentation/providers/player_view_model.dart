import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failure.dart';
import '../../domain/usecases/extract_frame_usecase.dart';
import 'dependency_injection.dart';

import '../../domain/entities/video_media.dart';
import '../../domain/entities/video_metadata.dart';

class PlayerState {
  final bool isExtracting;
  final XFile? extractedImage;
  final Failure? error;
  final ImageFormat imageFormat;
  final int quality;
  final VideoMetadata? metadata;

  PlayerState({
    this.isExtracting = false, 
    this.extractedImage, 
    this.error,
    this.imageFormat = ImageFormat.jpeg,
    this.quality = 100,
    this.metadata,
  });

  PlayerState copyWith({
    bool? isExtracting, 
    XFile? extractedImage, 
    Failure? error,
    ImageFormat? imageFormat,
    int? quality,
    VideoMetadata? metadata,
  }) {
    return PlayerState(
      isExtracting: isExtracting ?? this.isExtracting,
      extractedImage: extractedImage ?? this.extractedImage,
      error: error ?? this.error,
      imageFormat: imageFormat ?? this.imageFormat,
      quality: quality ?? this.quality,
      metadata: metadata ?? this.metadata,
    );
  }
}

class PlayerViewModel extends Notifier<PlayerState> {
  @override
  PlayerState build() {
    return PlayerState();
  }

  void updateFormat(ImageFormat format) {
    state = state.copyWith(imageFormat: format);
  }

  void updateQuality(int quality) {
    state = state.copyWith(quality: quality);
  }

  Future<void> loadMetadata(XFile videoFile) async {
    final result = await ref.read(videoRepositoryProvider).getMetadata(videoFile);
    result.fold(
      (failure) => null, // Ignore error, simple metadata missing is fine
      (metadata) => state = state.copyWith(metadata: metadata),
    );
  }

  Future<void> extractFrame(XFile videoFile, double positionMs) async {
    state = state.copyWith(isExtracting: true, error: null);
    
    // Slight delay to ensure UI updates
    await Future.delayed(const Duration(milliseconds: 100));

    final result = await ref.read(extractFrameUseCaseProvider).call(
      ExtractFrameParams(
        videoFile: videoFile, 
        positionMs: positionMs,
        quality: state.quality,
        format: state.imageFormat,
        originalName: videoFile.name,
        metadata: state.metadata,
      )
    );

    result.fold(
      (failure) => state = state.copyWith(isExtracting: false, error: failure),
      (file) => state = state.copyWith(isExtracting: false, extractedImage: file),
    );
  }
  
  void reset() {
    state = PlayerState();
  }
}

final playerNotifierProvider = NotifierProvider<PlayerViewModel, PlayerState>(PlayerViewModel.new);
