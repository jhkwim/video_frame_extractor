import 'package:cross_file/cross_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failure.dart';
import '../../domain/usecases/extract_frame_usecase.dart';
import 'dependency_injection.dart';

class PlayerState {
  final bool isExtracting;
  final XFile? extractedImage;
  final Failure? error;

  PlayerState({this.isExtracting = false, this.extractedImage, this.error});

  PlayerState copyWith({bool? isExtracting, XFile? extractedImage, Failure? error}) {
    return PlayerState(
      isExtracting: isExtracting ?? this.isExtracting,
      extractedImage: extractedImage ?? this.extractedImage,
      error: error ?? this.error,
    );
  }
}

class PlayerViewModel extends Notifier<PlayerState> {
  @override
  PlayerState build() {
    return PlayerState();
  }

  Future<void> extractFrame(XFile videoFile, double positionMs) async {
    state = state.copyWith(isExtracting: true, error: null);
    
    // Slight delay to ensure UI updates
    await Future.delayed(const Duration(milliseconds: 100));

    final result = await ref.read(extractFrameUseCaseProvider).call(
      ExtractFrameParams(videoFile: videoFile, positionMs: positionMs)
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
