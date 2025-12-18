import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failure.dart';
import 'dependency_injection.dart';

class PreviewState {
  final bool isSaving;
  final bool isSaved;
  final Failure? error;

  PreviewState({this.isSaving = false, this.isSaved = false, this.error});

  PreviewState copyWith({bool? isSaving, bool? isSaved, Failure? error}) {
    return PreviewState(
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      error: error ?? this.error,
    );
  }
}

class PreviewViewModel extends Notifier<PreviewState> {
  @override
  PreviewState build() {
    return PreviewState();
  }

  Future<void> saveImage(File imageFile) async {
    state = state.copyWith(isSaving: true, error: null);
    
    final result = await ref.read(saveImageUseCaseProvider).call(imageFile);
    
    result.fold(
      (failure) => state = state.copyWith(isSaving: false, error: failure),
      (success) => state = state.copyWith(isSaving: false, isSaved: success),
    );
  }
}

final previewViewModelProvider = NotifierProvider<PreviewViewModel, PreviewState>(PreviewViewModel.new);
