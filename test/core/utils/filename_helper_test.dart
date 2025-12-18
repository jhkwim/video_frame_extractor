import 'package:flutter_test/flutter_test.dart';
import 'package:video_frame_extractor/core/utils/filename_helper.dart';

void main() {
  group('FilenameHelperTests', () {
    test('Should generate correct filename for normal file', () {
      final result = FilenameHelper.generateFilename(
        originalName: 'my_video.mp4',
        positionMs: 1500,
        extension: 'jpg',
      );
      expect(result, 'my_video_1500.jpg');
    });

    test('Should remove extension from original name', () {
      final result = FilenameHelper.generateFilename(
        originalName: 'movie.mov',
        positionMs: 0,
        extension: 'png',
      );
      expect(result, 'movie_0.png');
    });

    test('Should handle file without extension in originalName', () {
      final result = FilenameHelper.generateFilename(
        originalName: 'raw_video',
        positionMs: 333,
        extension: 'webp',
      );
      expect(result, 'raw_video_333.webp');
    });

    test('Should strip image_picker prefix and random characters', () {
      // Assuming pattern image_picker_HEX...
      final result = FilenameHelper.generateFilename(
        originalName: 'image_picker_8A2F1C.mp4',
        positionMs: 500,
        extension: 'jpg',
      );
      // The logic removes 'image_picker_' and leading hex. 
      // result might be empty string -> 'Video'
      expect(result, 'Video_500.jpg');
    });
    
    test('Should strip image_picker prefix but keep subsequent meaningful name if exists', () {
      // If the User picks a file via picker, often it is just random UUID.
      // But if we had 'image_picker_123_MyVideo.mp4', does logic handle it?
      // Logic: replaceFirst hexPattern.
      final result = FilenameHelper.generateFilename(
        originalName: 'image_picker_123AB_MyVideo.mp4',
        positionMs: 1000,
        extension: 'jpg',
      );
      expect(result, '_MyVideo_1000.jpg');
    });

    test('Should default to Video if name becomes empty', () {
      final result = FilenameHelper.generateFilename(
        originalName: '.mp4', // edge case
        positionMs: 100,
        extension: 'png',
      );
      expect(result, 'Video_100.png');
    });
    
    test('Should handle path separators in originalName if passed accidentally', () {
       final result = FilenameHelper.generateFilename(
        originalName: '/path/to/video.mp4',
        positionMs: 10,
        extension: 'jpg',
      );
      expect(result, 'video_10.jpg');
    });
  });
}
