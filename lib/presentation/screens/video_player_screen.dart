import 'dart:io';
import 'package:universal_io/io.dart' as uio;
import 'package:flutter/foundation.dart';
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
    if (kIsWeb) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoMedia.file.path));
    } else {
      _videoPlayerController = VideoPlayerController.file(File(widget.videoMedia.file.path));
    }
    
    await _videoPlayerController.initialize();
    
    if (!mounted) return;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      showControls: false, // Hide default controls
    );
    
    // Listen to updates for custom slider
    _videoPlayerController.addListener(() {
      if (mounted) setState(() {});
    });
    
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(() {});
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _extractFrame() async {
    final currentPosition = _videoPlayerController.value.position;
    await ref.read(playerNotifierProvider.notifier).extractFrame(
          widget.videoMedia.file,
          currentPosition.inMilliseconds.toDouble(),
        );
  }
  
  void _seekRelative(Duration duration) {
    final newPos = _videoPlayerController.value.position + duration;
    _videoPlayerController.seekTo(newPos);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final millis = (duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds:$millis';
  }

  List<ImageFormat> _getAvailableFormats() {
    if (kIsWeb) {
      return [ImageFormat.jpeg, ImageFormat.png, ImageFormat.webp];
    } else if (uio.Platform.isMacOS) {
      return [ImageFormat.jpeg, ImageFormat.png];
    } else {
      // Mobile
      return [ImageFormat.jpeg, ImageFormat.png, ImageFormat.webp];
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerNotifierProvider);
    final position = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;

    ref.listen(playerNotifierProvider, (previous, next) {
       if (next.extractedImage != null && !next.isExtracting && next.error == null) {
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
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video Area
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
            
            // Custom Controls Area
            Container(
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time Display
                  Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.w500,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const Gap(8),
                  
                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble()),
                      min: 0,
                      max: duration.inMilliseconds.toDouble(),
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.grey[800],
                      onChanged: (value) {
                         _videoPlayerController.seekTo(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  
                  // Precision Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => _seekRelative(const Duration(milliseconds: -1000)),
                        icon: const Icon(Icons.replay_10, color: Colors.white),
                        tooltip: '-1초',
                      ),
                      IconButton(
                        onPressed: () => _seekRelative(const Duration(milliseconds: -33)), // approx 1 frame at 30fps
                        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                        tooltip: '이전 프레임',
                      ),
                      
                      // Play/Pause
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_videoPlayerController.value.isPlaying) {
                              _videoPlayerController.pause();
                            } else {
                              _videoPlayerController.play();
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                      
                      IconButton(
                        onPressed: () => _seekRelative(const Duration(milliseconds: 33)),
                        icon: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white),
                        tooltip: '다음 프레임',
                      ),
                      IconButton(
                        onPressed: () => _seekRelative(const Duration(milliseconds: 1000)),
                        icon: const Icon(Icons.forward_10, color: Colors.white),
                        tooltip: '+1초',
                      ),
                    ],
                  ),
                  const Gap(16),
                  
                  // Settings Row (Format & Quality)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                         // Format Dropdown
                        DropdownButtonHideUnderline(
                          child: DropdownButton<ImageFormat>(
                            value: playerState.imageFormat,
                            dropdownColor: const Color(0xFF1E1E1E),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            items: _getAvailableFormats().map((format) {
                              return DropdownMenuItem(
                                value: format,
                                child: Text(format.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                ref.read(playerNotifierProvider.notifier).updateFormat(value);
                              }
                            },
                          ),
                        ),
                        const Gap(16),
                        
                        // Quality Slider
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Quality', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text('${playerState.quality}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                ),
                                child: Slider(
                                  value: playerState.quality.toDouble(),
                                  min: 0,
                                  max: 100,
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
                                  onChanged: (value) {
                                    ref.read(playerNotifierProvider.notifier).updateQuality(value.toInt());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(24),
                  
                  // Extract Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: playerState.isExtracting ? null : () {
                        // Ensure paused for accurate extraction
                        _videoPlayerController.pause();
                        _extractFrame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
