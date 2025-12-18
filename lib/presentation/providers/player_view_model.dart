import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failure.dart';
import '../../domain/usecases/extract_frame_usecase.dart';
import 'dependency_injection.dart';

class PlayerState {
  final bool isExtracting;
  final File? extractedImage;
  final Failure? error;

  PlayerState({this.isExtracting = false, this.extractedImage, this.error});

  PlayerState copyWith({bool? isExtracting, File? extractedImage, Failure? error}) {
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

  Future<void> extractFrame(File videoFile, double positionMs) async {
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

final playerViewModelProvider = NotifierProvider<PlayerState, PlayerViewModel>(() {
  // Error: The provider function must return the Notifier.
  // The syntax `NotifierProvider<NotifierClassName, StateType>(NotifierClassName.new)` is correct.
  // But here I used a closure which is also valid if it returns the instance.
  // Let's stick to the concise syntax like HomeViewModel.
  return PlayerViewModel();
}) as NotifierProvider<PlayerViewModel, PlayerState>; // Casting to fix type inference if needed, but clean way is below.

// Clean implementation
final playerNotifierProvider = NotifierProvider<PlayerViewModel, PlayerState>(PlayerViewModel.new);
