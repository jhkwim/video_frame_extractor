import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/video_media.dart';
import '../../domain/usecases/pick_video_usecase.dart';
import 'dependency_injection.dart';

// State can be null (no video), VideoMedia (selected), or loading/error via AsyncValue if preferred.
// Here using Notifier for explicit state handling.

class HomeState {
  final bool isLoading;
  final VideoMedia? selectedVideo;
  final Failure? error;

  HomeState({this.isLoading = false, this.selectedVideo, this.error});

  HomeState copyWith({
    bool? isLoading,
    VideoMedia? selectedVideo,
    Failure? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      selectedVideo: selectedVideo ?? this.selectedVideo,
      error: error ?? this.error,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState();
  }

  Future<void> pickVideo() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await ref.read(pickVideoUseCaseProvider).call(NoParams());

    result.fold(
      (failure) {
        if (failure is UserCanceledFailure) {
          state = state.copyWith(isLoading: false);
        } else {
          state = state.copyWith(isLoading: false, error: failure);
        }
      },
      (video) => state = state.copyWith(isLoading: false, selectedVideo: video),
    );
  }

  void clearVideo() {
    state = HomeState();
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);
