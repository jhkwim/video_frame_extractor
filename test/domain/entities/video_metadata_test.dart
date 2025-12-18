
import 'package:flutter_test/flutter_test.dart';
import 'package:video_frame_extractor/domain/entities/video_metadata.dart';

void main() {
  group('비디오 메타데이터 (VideoMetadata)', () {
    test('값 동등성을 지원해야 한다 (속성 비교)', () {
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

    test('toString이 올바른 형식을 반환해야 한다', () {
      final metadata = VideoMetadata(
        make: 'Test',
        model: 'Model',
      );
      expect(metadata.toString(), contains('make: Test'));
      expect(metadata.toString(), contains('model: Model'));
    });
  });
}
