import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/video_media.dart';
import '../providers/player_view_model.dart';
import '../../core/constants/app_constants.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoMedia videoMedia;
  const VideoPlayerScreen({super.key, required this.videoMedia});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.file(widget.videoMedia.file);
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(context).primaryColor,
        handleColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey[300]!,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _extractFrame() async {
    final currentPosition = await _videoPlayerController.position;
    if (currentPosition != null) {
      await ref.read(playerNotifierProvider.notifier).extractFrame(
            widget.videoMedia.file,
            currentPosition.inMilliseconds.toDouble(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerNotifierProvider);

    ref.listen(playerNotifierProvider, (previous, next) {
       if (next.extractedImage != null && !next.isExtracting && next.error == null) {
          // Reset extraction state to avoid re-triggering just in case, but usually unnecessary with immutable state flow
          // Navigate to Preview
          context.push('/preview', extra: next.extractedImage);
       }
       
       if (next.error != null) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(next.error!.message)),
         );
       }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('장면 선택'),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _chewieController != null &&
                        _chewieController!.videoPlayerController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: Chewie(controller: _chewieController!),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  const Text(
                    '원하는 장면에서 정지 후 버튼을 누르세요',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Gap(16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: playerState.isExtracting ? null : _extractFrame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: playerState.isExtracting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              AppConstants.extractButtonLabel,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
