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
import '../../l10n/generated/app_localizations.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final VideoMedia videoMedia;
  const VideoPlayerScreen({super.key, required this.videoMedia});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  String? _errorMessage;
  bool _showControls = true;
  bool _showSettingsPanel = false; // Collapsible options state
  bool _quickSave = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (kIsWeb) {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoMedia.file.path));
      } else {
        _videoPlayerController = VideoPlayerController.file(File(widget.videoMedia.file.path));
      }
      
      await _videoPlayerController.initialize();
      
      if (!mounted) return;
      
      // Load Metadata
      ref.read(playerNotifierProvider.notifier).loadMetadata(widget.videoMedia.file);
  
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: true,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        showControls: false, 
      );
      
      _videoPlayerController.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '${AppLocalizations.of(context)!.videoLoadError}\n($e)';
        });
      }
    }
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
      return [ImageFormat.jpeg, ImageFormat.png, ImageFormat.webp];
    }
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerNotifierProvider);
    final position = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;

    ref.listen(playerNotifierProvider, (previous, next) {
       // Quick Save Logic or Normal Flow
       if (next.extractedImage != null && !next.isExtracting && next.error == null) {
          if (_quickSave) {
            // Auto Save triggered by Quick Save
             ref.read(playerNotifierProvider.notifier).saveImageToGallery(next.extractedImage!).then((success) {
               if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text(AppLocalizations.of(context)!.imageSavedToGallery)),
                  );
               }
             });
          } else {
             context.push('/preview', extra: next.extractedImage);
          }
       }
       
       if (next.error != null) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(next.error!.message)),
         );
       }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Fullscreen Video with Zoom
          Center(
            child: _errorMessage != null
                ? Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  )
                : _chewieController != null &&
                        _chewieController!.videoPlayerController.value.isInitialized
                    ? GestureDetector(
                        onTap: _toggleControls,
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 5.0,
                          child: AspectRatio(
                            aspectRatio: _videoPlayerController.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(),
          ),

          // Layer 2: Top AppBar (Overlay)
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                       const BackButton(color: Colors.white),
                       Text(
                         widget.videoMedia.name ?? 'Video',
                         style: const TextStyle(color: Colors.white, fontSize: 16, shadows: [
                           Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 1))
                         ]),
                       ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Layer 3: Bottom Controls (Overlay)
          AnimatedOpacity(
             opacity: _showControls ? 1.0 : 0.0,
             duration: const Duration(milliseconds: 300),
             child: IgnorePointer(
               ignoring: !_showControls,
               child: Align(
                 alignment: Alignment.bottomCenter,
                 child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Time & Slider
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                               style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 2, color: Colors.black)]
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(
                                color: Colors.white70,
                                shadows: [Shadow(blurRadius: 2, color: Colors.black)]
                              ),
                            ),
                          ],
                        ),
                        // Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          ),
                          child: Slider(
                            value: position.inMilliseconds.toDouble().clamp(0, duration.inMilliseconds.toDouble()),
                            min: 0,
                            max: duration.inMilliseconds.toDouble(),
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Colors.white24,
                            onChanged: (value) {
                               _videoPlayerController.seekTo(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        
                        const Gap(8),
                        
                        // Frame Controls & Quick Save
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             IconButton(onPressed: () => _seekRelative(const Duration(milliseconds: -1000)), icon: const Icon(Icons.replay_10, color: Colors.white, size: 28)),
                             IconButton(onPressed: () => _seekRelative(const Duration(milliseconds: -33)), icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20)),
                             const Gap(16),
                             Container(
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                             const Gap(16),
                             IconButton(onPressed: () => _seekRelative(const Duration(milliseconds: 33)), icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20)),
                             IconButton(onPressed: () => _seekRelative(const Duration(milliseconds: 1000)), icon: const Icon(Icons.forward_10, color: Colors.white, size: 28)),
                             const Gap(16),
                             // Settings Toggle
                             IconButton(
                               onPressed: () {
                                 setState(() {
                                   _showSettingsPanel = !_showSettingsPanel;
                                 });
                               },
                               icon: Icon(
                                 _showSettingsPanel ? Icons.settings : Icons.settings_outlined,
                                 color: _showSettingsPanel ? Theme.of(context).primaryColor : Colors.white,
                               ),
                             ),
                          ],
                        ),
                        
                        const Gap(16),
                        
                        // Collapsible Options Panel
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: _showSettingsPanel
                              ? Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min, // Wrap content
                                    children: [
                                      // Format
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<ImageFormat>(
                                          value: playerState.imageFormat,
                                          dropdownColor: Colors.black87,
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                                          items: _getAvailableFormats().map((format) {
                                            return DropdownMenuItem(
                                              value: format,
                                              child: Text(format.name.toUpperCase()),
                                            );
                                          }).toList(),
                                          onChanged: (value) =>
                                              ref.read(playerNotifierProvider.notifier).updateFormat(value!),
                                        ),
                                      ),
                                      const SizedBox(height: 20, child: VerticalDivider(color: Colors.white24)),
                                      // Quality
                                      InkWell(
                                        onTap: () {
                                          final newQ = playerState.quality == 100 ? 80 : 100;
                                          ref.read(playerNotifierProvider.notifier).updateQuality(newQ);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Row(
                                            children: [
                                              Text('${AppLocalizations.of(context)!.quality}: ',
                                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                              Text(
                                                playerState.quality == 100
                                                    ? AppLocalizations.of(context)!.original
                                                    : '${playerState.quality}%',
                                                style: TextStyle(
                                                    color: playerState.quality == 100
                                                        ? Colors.amber
                                                        : Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20, child: VerticalDivider(color: Colors.white24)),
                                      // Quick Save Toggle
                                      InkWell(
                                        onTap: () => setState(() => _quickSave = !_quickSave),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _quickSave ? Icons.check_box : Icons.check_box_outline_blank,
                                              color: _quickSave
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.white70,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(AppLocalizations.of(context)!.quickSave,
                                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        
                        const Gap(16),
                        
                        // Extract Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            key: const Key('extract_frame_button'),
                            onPressed: playerState.isExtracting ? null : () {
                              _videoPlayerController.pause();
                              _extractFrame();
                            },
                             style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: playerState.isExtracting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(AppLocalizations.of(context)!.extractButtonLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                 ),
               ),
             ),
          ),
        ],
      ),
    );
  }
}
