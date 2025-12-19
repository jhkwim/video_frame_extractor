import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  final Completer<void> initialized = Completer<void>();
  final List<String> calls = <String>[];
  final List<DataSource> dataSources = <DataSource>[];
  final Map<int, bool> _isPlaying = {};
  
  @override
  Future<void> init() async {
    calls.add('init');
  }

  @override
  Future<void> dispose(int textureId) async {
    calls.add('dispose');
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    calls.add('create');
    dataSources.add(dataSource);
    return 0; // Texture ID 0
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    calls.add('setLooping');
  }

  @override
  Future<void> play(int textureId) async {
    calls.add('play');
    _isPlaying[textureId] = true;
  }

  @override
  Future<void> pause(int textureId) async {
    calls.add('pause');
    _isPlaying[textureId] = false;
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    calls.add('setVolume');
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    calls.add('seekTo');
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    return const Duration(seconds: 0);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    late StreamController<VideoEvent> controller;
    controller = StreamController<VideoEvent>(
      onListen: () {
        // Emit initialized event immediately when listened to
        scheduleMicrotask(() {
           if (!controller.isClosed) {
            controller.add(VideoEvent(
              eventType: VideoEventType.initialized,
              duration: const Duration(seconds: 10),
              size: const Size(1920, 1080),
            ));
          } 
        });
      },
    );
    return controller.stream;
  }

  @override
  Widget buildView(int textureId) {
    return const SizedBox(width: 1920, height: 1080); // Dummy/Blank View
  }
}
