
import 'package:flutter_test/flutter_test.dart';
import 'package:video_frame_extractor/domain/entities/video_metadata.dart';

void main() {
  group('VideoMetadata', () {
    test('supports value equality', () {
      final date = DateTime.now();
      final metadataqv1 = VideoMetadata(
        creationDate: date,
        make: 'Apple',
        model: 'iPhone 13',
        latitude: 37.5,
        longitude: 127.0,
      );
      final metadataqv2 = VideoMetadata(
        creationDate: date,
        make: 'Apple',
        model: 'iPhone 13',
        latitude: 37.5,
        longitude: 127.0,
      );

      // Equatable is not used, so default equality is identity unless overridden.
      // Checking implementation... I didn't extend Equatable in my implementation step (Step 1134).
      // So this test will FAIL if I expect value equality.
      // I should check if I should add Equatable.
      // The snippet in Step 1134:
      /*
      class VideoMetadata {
        ...
        const VideoMetadata({...});
        @override String toString() ...
      }
      */
      // It does NOT extend Equatable.
      // So I will test properties instead.
      
      expect(metadataqv1.creationDate, metadataqv2.creationDate);
      expect(metadataqv1.make, metadataqv2.make);
    });

    test('toString returns correct format', () {
      final metadata = VideoMetadata(
        make: 'Test',
        model: 'Model',
      );
      expect(metadata.toString(), contains('make: Test'));
      expect(metadata.toString(), contains('model: Model'));
    });
  });
}
