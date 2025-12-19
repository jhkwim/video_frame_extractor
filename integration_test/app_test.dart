import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:video_frame_extractor/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_frame_extractor/presentation/providers/dependency_injection.dart';
import 'package:video_frame_extractor/presentation/screens/home_screen.dart';
import 'package:video_frame_extractor/presentation/screens/video_player_screen.dart';
import 'package:video_frame_extractor/presentation/screens/preview_screen.dart';
import 'test_video_helper.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'fake_video_player_platform.dart';
import 'fake_video_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full verification flow: Pick -> Extract -> Save', (WidgetTester tester) async {
    // 0. Mock Video Player Platform
    final fakeVideoPlayer = FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = fakeVideoPlayer;
    
    // 1. Prepare Fake Data
    final testFile = await TestVideoHelper.createTestVideoFile();
    final fakeRepository = FakeVideoRepository(testVideoFile: testFile);

    // 2. Launch App with Override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          videoRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 3. Verify Home Screen
    expect(find.byType(HomeScreen), findsOneWidget);
    // Use generic find or English default
    // expect(find.text('동영상 선택'), findsOneWidget); 
    
    // 4. Tap Pick Video
    // Find by Icon is safer than text
    await tester.tap(find.byIcon(Icons.add_a_photo)); 
    await tester.pumpAndSettle();

    // 5. Verify Video Player Screen
    expect(find.byType(VideoPlayerScreen), findsOneWidget);
    
    // 6. Tap Extract Frame
    // Using Key for robustness against localization
    await tester.tap(find.byKey(const Key('extract_frame_button')));
    await tester.pumpAndSettle();

    // 7. Verify Preview Screen
    expect(find.byType(PreviewScreen), findsOneWidget);

    // 8. Tap Save
    await tester.tap(find.byKey(const Key('save_image_button')));
    await tester.pumpAndSettle();

    // 9. Verify Success SnackBar (Check for partial match or both)
    expect(find.byType(SnackBar), findsOneWidget); // Simpler check for success
    
    // Cleanup
    if (await testFile.exists()) await testFile.delete();
    // Ensure all animations and timers are settled before test ends
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
  });
}
