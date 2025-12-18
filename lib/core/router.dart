import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/video_player_screen.dart';
import '../../presentation/screens/preview_screen.dart';
import '../../domain/entities/video_media.dart';
import 'dart:io';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) {
        final videoMedia = state.extra as VideoMedia;
        return VideoPlayerScreen(videoMedia: videoMedia);
      },
    ),
    GoRoute(
      path: '/preview',
      builder: (context, state) {
        final imageFile = state.extra as File;
        return PreviewScreen(imageFile: imageFile);
      },
    ),
  ],
);
