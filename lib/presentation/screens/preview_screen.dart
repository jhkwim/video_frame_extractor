import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../providers/preview_view_model.dart';
import '../providers/player_view_model.dart';

class PreviewScreen extends ConsumerWidget {
  final File imageFile;
  const PreviewScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewState = ref.watch(previewViewModelProvider);

    ref.listen(previewViewModelProvider, (previous, next) {
      if (next.isSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('갤러리에 저장되었습니다.')),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('결과 확인'),
        actions: [
          IconButton(
            onPressed: () {
              // Reset player state when going back home entirely or starting over
              // simplest way is just popping, but let's allow "Finish" action
              context.go('/'); 
              ref.read(playerNotifierProvider.notifier).reset();
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Share.shareXFiles([XFile(imageFile.path)], text: 'Extracted Frame');
                    },
                    icon: const Icon(Icons.share),
                    label: const Text(AppConstants.shareButtonLabel),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: previewState.isSaving
                        ? null
                        : () {
                            ref.read(previewViewModelProvider.notifier).saveImage(imageFile);
                          },
                    icon: const Icon(Icons.save),
                    label: previewState.isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(AppConstants.saveButtonLabel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
